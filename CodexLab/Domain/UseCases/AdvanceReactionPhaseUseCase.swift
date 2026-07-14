import Foundation

struct AdvanceReactionPhaseUseCase: Sendable {
    private let bookRepository: CodexLabBookRepositoryProtocol
    private let labRepository: CodexLabLabRepositoryProtocol
    private let computePurity: ComputePurityUseCase

    init(
        bookRepository: CodexLabBookRepositoryProtocol,
        labRepository: CodexLabLabRepositoryProtocol,
        computePurity: ComputePurityUseCase = ComputePurityUseCase()
    ) {
        self.bookRepository = bookRepository
        self.labRepository = labRepository
        self.computePurity = computePurity
    }

    func execute(bookId: UUID) async throws -> CodexLabBook {
        guard var book = try await bookRepository.fetch(by: bookId) else {
            throw CodexLabDomainError.bookNotFound
        }
        let next = book.reactionPhase.next
        book.reactionPhase = next

        let sessions = try await bookRepository.fetchSessions(for: bookId)
        let calendar = Calendar.current
        let daily = Dictionary(grouping: sessions, by: { calendar.startOfDay(for: $0.date) })
            .mapValues { $0.reduce(0) { $0 + $1.pagesRead } }
        book.purity = computePurity.execute(dailyPages: daily, calendar: calendar)

        try await bookRepository.updateBook(book)

        let experiments = try await labRepository.fetchExperiments()
        if var experiment = experiments.first(where: { $0.bookId == bookId && !$0.isArchived }) {
            experiment.phase = next
            experiment.yield = book.yieldPercent
            experiment.temperature = book.boilingPoint
            try await labRepository.updateExperiment(experiment)
        } else {
            let experiment = Experiment(
                id: UUID(),
                bookId: bookId,
                title: book.title,
                startedAt: Date(),
                phase: next,
                yield: book.yieldPercent,
                temperature: book.boilingPoint,
                isArchived: false
            )
            try await labRepository.saveExperiment(experiment)
        }

        let reaction = Reaction(
            id: UUID(),
            experimentId: nil,
            bookId: bookId,
            date: Date(),
            pagesRead: 0,
            phase: next,
            note: "Phase → \(next.label)",
            puritySnapshot: book.purity
        )
        try await labRepository.saveReaction(reaction)
        return book
    }
}

nonisolated enum CodexLabDomainError: Error, Sendable, Equatable {
    case bookNotFound
    case hypothesisExists
    case invalidHypothesis
}
