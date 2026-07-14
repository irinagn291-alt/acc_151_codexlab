import Foundation

struct CodexLabLogPagesUseCase: Sendable {
    private let repository: CodexLabBookRepositoryProtocol
    private let labRepository: CodexLabLabRepositoryProtocol
    private let computePurity: ComputePurityUseCase
    private let updateHypothesis: UpdateHypothesisProgressUseCase

    init(
        repository: CodexLabBookRepositoryProtocol,
        labRepository: CodexLabLabRepositoryProtocol,
        computePurity: ComputePurityUseCase = ComputePurityUseCase(),
        updateHypothesis: UpdateHypothesisProgressUseCase
    ) {
        self.repository = repository
        self.labRepository = labRepository
        self.computePurity = computePurity
        self.updateHypothesis = updateHypothesis
    }

    func execute(bookId: UUID, pages: Int, date: Date = Date()) async throws {
        guard pages > 0 else { return }
        guard var book = try await repository.fetch(by: bookId) else { return }
        let newPage = min(book.currentPage + pages, book.totalPages)
        try await repository.updateProgress(bookId: bookId, currentPage: newPage)

        let session = CodexLabReadingSession(
            id: UUID(),
            bookId: bookId,
            date: date,
            pagesRead: pages,
            duration: 0,
            flavorMeta: "Reaction +\(pages)"
        )
        try await repository.logSession(session)

        let sessions = try await repository.fetchSessions(for: bookId)
        let calendar = Calendar.current
        let daily = Dictionary(grouping: sessions, by: { calendar.startOfDay(for: $0.date) })
            .mapValues { $0.reduce(0) { $0 + $1.pagesRead } }
        book.currentPage = newPage
        book.purity = computePurity.execute(dailyPages: daily, calendar: calendar)
        if book.reactionPhase == .idle { book.reactionPhase = .heating }
        try await repository.updateBook(book)

        let reaction = Reaction(
            id: UUID(),
            experimentId: nil,
            bookId: bookId,
            date: date,
            pagesRead: pages,
            phase: book.reactionPhase,
            note: "+\(pages) pages",
            puritySnapshot: book.purity
        )
        try await labRepository.saveReaction(reaction)
        _ = try? await updateHypothesis.execute()
    }
}
