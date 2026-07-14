import Foundation

@Observable
@MainActor
final class LaboratoryWorkspaceViewModel {
    var book: CodexLabBook?
    var temperature: Double = 0.2
    var yieldValue: Double = 0
    var purity: Double = 0
    var pagesToLog = 10
    var isAdvancing = false

    private let bookRepository: CodexLabBookRepositoryProtocol
    private let logPages: CodexLabLogPagesUseCase
    private let advancePhase: AdvanceReactionPhaseUseCase
    private let setActiveBookId: UUID?

    init(bookId: UUID?, factory: CodexLabFactory = .shared) {
        bookRepository = factory.bookRepository
        logPages = factory.logPagesUseCase
        advancePhase = factory.advanceReactionPhaseUseCase
        setActiveBookId = bookId
    }

    func load() async {
        if let setActiveBookId {
            book = try? await bookRepository.fetch(by: setActiveBookId)
        } else {
            book = try? await bookRepository.fetchActive()
        }
        syncGauges()
    }

    func logPagesAction() async {
        guard let book else { return }
        try? await logPages.execute(bookId: book.id, pages: pagesToLog)
        await load()
    }

    func advancePhaseAction() async {
        guard let book else { return }
        isAdvancing = true
        defer { isAdvancing = false }
        self.book = try? await advancePhase.execute(bookId: book.id)
        syncGauges()
    }

    private func syncGauges() {
        guard let book else { return }
        temperature = min(1, Double(book.boilingPoint) / 400)
        yieldValue = book.progress
        purity = book.purity / 100
    }
}
