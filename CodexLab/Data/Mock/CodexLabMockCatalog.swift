import Foundation

enum CodexLabMockCatalog {
    static let frankenstein = CodexLabBook(
        id: UUID(uuidString: "C0000001-0000-0000-0000-000000000001")!,
        isbn: "9780486282114",
        title: "Frankenstein",
        author: "Mary Shelley",
        coverURL: URL(string: "https://covers.openlibrary.org/b/isbn/9780486282114-L.jpg"),
        genre: "Gothic Horror",
        totalPages: 166,
        currentPage: 166,
        dateAdded: daysAgo(60),
        isActive: false,
        flavorMeta: "Gh-01",
        reactionPhase: .precipitated,
        purity: 100,
        reagentCode: "Gh-01"
    )

    static let jekyll = CodexLabBook(
        id: UUID(uuidString: "C0000002-0000-0000-0000-000000000002")!,
        isbn: "9780486266886",
        title: "Dr Jekyll and Mr Hyde",
        author: "Robert Louis Stevenson",
        coverURL: URL(string: "https://covers.openlibrary.org/b/isbn/9780486266886-L.jpg"),
        genre: "Horror",
        totalPages: 88,
        currentPage: 44,
        dateAdded: daysAgo(10),
        isActive: true,
        flavorMeta: "Gh-07",
        reactionPhase: .reacting,
        purity: 37.5,
        reagentCode: "Gh-07"
    )

    static let timeMachine = CodexLabBook(
        id: UUID(uuidString: "C0000003-0000-0000-0000-000000000003")!,
        isbn: "9780451528551",
        title: "The Time Machine",
        author: "H.G. Wells",
        coverURL: URL(string: "https://covers.openlibrary.org/b/isbn/9780451528551-L.jpg"),
        genre: "Science Fiction",
        totalPages: 118,
        currentPage: 30,
        dateAdded: daysAgo(3),
        isActive: false,
        flavorMeta: "Sf-12",
        reactionPhase: .heating,
        purity: 25,
        reagentCode: "Sf-12"
    )

    static let books = [frankenstein, jekyll, timeMachine]

    static func sessions() -> [CodexLabReadingSession] {
        let cal = Calendar.current
        return [
            CodexLabReadingSession(id: UUID(), bookId: jekyll.id, date: cal.date(byAdding: .day, value: -1, to: Date())!, pagesRead: 22, duration: 1800, flavorMeta: "Exothermic"),
            CodexLabReadingSession(id: UUID(), bookId: timeMachine.id, date: cal.date(byAdding: .day, value: -2, to: Date())!, pagesRead: 15, duration: 1200, flavorMeta: "Stable"),
            CodexLabReadingSession(id: UUID(), bookId: jekyll.id, date: cal.date(byAdding: .day, value: -3, to: Date())!, pagesRead: 22, duration: 1500, flavorMeta: "Catalyst added")
        ]
    }

    static func experiments() -> [Experiment] {
        [
            Experiment(id: UUID(), bookId: jekyll.id, title: jekyll.title, startedAt: daysAgo(10), phase: .reacting, yield: 50, temperature: jekyll.boilingPoint, isArchived: false),
            Experiment(id: UUID(), bookId: timeMachine.id, title: timeMachine.title, startedAt: daysAgo(3), phase: .heating, yield: 25, temperature: timeMachine.boilingPoint, isArchived: false),
            Experiment(id: UUID(), bookId: frankenstein.id, title: frankenstein.title, startedAt: daysAgo(60), phase: .precipitated, yield: 100, temperature: frankenstein.boilingPoint, isArchived: true)
        ]
    }

    static func reactions() -> [Reaction] {
        let cal = Calendar.current
        return [
            Reaction(id: UUID(), experimentId: nil, bookId: jekyll.id, date: cal.date(byAdding: .day, value: -1, to: Date())!, pagesRead: 22, phase: .reacting, note: "+22 pages", puritySnapshot: 37.5),
            Reaction(id: UUID(), experimentId: nil, bookId: timeMachine.id, date: cal.date(byAdding: .day, value: -2, to: Date())!, pagesRead: 15, phase: .heating, note: "+15 pages", puritySnapshot: 25),
            Reaction(id: UUID(), experimentId: nil, bookId: jekyll.id, date: cal.date(byAdding: .day, value: -3, to: Date())!, pagesRead: 22, phase: .heating, note: "Phase → Heating", puritySnapshot: 25)
        ]
    }

    private static func daysAgo(_ n: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -n, to: Date()) ?? Date()
    }
}

struct CodexLabSeedDataUseCase: Sendable {
    private let bookRepository: CodexLabBookRepositoryProtocol
    private let labRepository: CodexLabLabRepositoryProtocol

    init(bookRepository: CodexLabBookRepositoryProtocol, labRepository: CodexLabLabRepositoryProtocol) {
        self.bookRepository = bookRepository
        self.labRepository = labRepository
    }

    func executeIfNeeded() async {
        guard !UserDefaults.standard.bool(forKey: CodexLabMetadata.seedKey) else { return }
        guard ((try? await bookRepository.fetchAll()) ?? []).isEmpty else {
            UserDefaults.standard.set(true, forKey: CodexLabMetadata.seedKey)
            return
        }
        for book in CodexLabMockCatalog.books { try? await bookRepository.save(book) }
        for session in CodexLabMockCatalog.sessions() { try? await bookRepository.logSession(session) }
        for experiment in CodexLabMockCatalog.experiments() { try? await labRepository.saveExperiment(experiment) }
        for reaction in CodexLabMockCatalog.reactions() { try? await labRepository.saveReaction(reaction) }
        UserDefaults.standard.set(true, forKey: CodexLabMetadata.seedKey)
    }
}
