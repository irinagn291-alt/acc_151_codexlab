import Foundation

enum CodexLabMockCatalog {
    private static func cover(_ isbn: String) -> URL? {
        URL(string: "https://covers.openlibrary.org/b/isbn/\(isbn)-L.jpg")
    }

    static let frankenstein = CodexLabBook(
        id: UUID(uuidString: "C0000001-0000-0000-0000-000000000001")!,
        isbn: "9780486282114", title: "Frankenstein", author: "Mary Shelley",
        coverURL: cover("9780486282114"), genre: "Gothic Horror", totalPages: 166, currentPage: 166,
        dateAdded: daysAgo(60), isActive: false, flavorMeta: "Gh-01",
        reactionPhase: .precipitated, purity: 100, reagentCode: "Gh-01"
    )
    static let jekyll = CodexLabBook(
        id: UUID(uuidString: "C0000002-0000-0000-0000-000000000002")!,
        isbn: "9780486266886", title: "Dr Jekyll and Mr Hyde", author: "Robert Louis Stevenson",
        coverURL: cover("9780486266886"), genre: "Horror", totalPages: 88, currentPage: 44,
        dateAdded: daysAgo(10), isActive: true, flavorMeta: "Gh-07",
        reactionPhase: .reacting, purity: 37.5, reagentCode: "Gh-07"
    )
    static let timeMachine = CodexLabBook(
        id: UUID(uuidString: "C0000003-0000-0000-0000-000000000003")!,
        isbn: "9780451528551", title: "The Time Machine", author: "H.G. Wells",
        coverURL: cover("9780451528551"), genre: "Science Fiction", totalPages: 118, currentPage: 30,
        dateAdded: daysAgo(3), isActive: false, flavorMeta: "Sf-12",
        reactionPhase: .heating, purity: 25, reagentCode: "Sf-12"
    )
    static let dracula = CodexLabBook(
        id: UUID(uuidString: "C0000004-0000-0000-0000-000000000004")!,
        isbn: "9780141439846", title: "Dracula", author: "Bram Stoker",
        coverURL: cover("9780141439846"), genre: "Horror", totalPages: 418, currentPage: 90,
        dateAdded: daysAgo(15), isActive: false, flavorMeta: "Gh-03",
        reactionPhase: .heating, purity: 22, reagentCode: "Gh-03"
    )
    static let foundation = CodexLabBook(
        id: UUID(uuidString: "C0000005-0000-0000-0000-000000000005")!,
        isbn: "9780553293357", title: "Foundation", author: "Isaac Asimov",
        coverURL: cover("9780553293357"), genre: "Science Fiction", totalPages: 244, currentPage: 120,
        dateAdded: daysAgo(22), isActive: false, flavorMeta: "Sf-04",
        reactionPhase: .reacting, purity: 49, reagentCode: "Sf-04"
    )
    static let andThen = CodexLabBook(
        id: UUID(uuidString: "C0000006-0000-0000-0000-000000000006")!,
        isbn: "9780062073488", title: "And Then There Were None", author: "Agatha Christie",
        coverURL: cover("9780062073488"), genre: "Mystery", totalPages: 264, currentPage: 80,
        dateAdded: daysAgo(8), isActive: false, flavorMeta: "My-02",
        reactionPhase: .heating, purity: 30, reagentCode: "My-02"
    )
    static let hobbit = CodexLabBook(
        id: UUID(uuidString: "C0000007-0000-0000-0000-000000000007")!,
        isbn: "9780547928227", title: "The Hobbit", author: "J.R.R. Tolkien",
        coverURL: cover("9780547928227"), genre: "Fantasy", totalPages: 310, currentPage: 150,
        dateAdded: daysAgo(28), isActive: false, flavorMeta: "Fa-01",
        reactionPhase: .reacting, purity: 48, reagentCode: "Fa-01"
    )
    static let pride = CodexLabBook(
        id: UUID(uuidString: "C0000008-0000-0000-0000-000000000008")!,
        isbn: "9780141439518", title: "Pride and Prejudice", author: "Jane Austen",
        coverURL: cover("9780141439518"), genre: "Romance", totalPages: 279, currentPage: 60,
        dateAdded: daysAgo(12), isActive: false, flavorMeta: "Ro-01",
        reactionPhase: .idle, purity: 21, reagentCode: "Ro-01"
    )
    static let girlDragon = CodexLabBook(
        id: UUID(uuidString: "C0000009-0000-0000-0000-000000000009")!,
        isbn: "9780307454546", title: "The Girl with the Dragon Tattoo", author: "Stieg Larsson",
        coverURL: cover("9780307454546"), genre: "Thriller", totalPages: 465, currentPage: 110,
        dateAdded: daysAgo(6), isActive: false, flavorMeta: "Th-01",
        reactionPhase: .heating, purity: 24, reagentCode: "Th-01"
    )
    static let gunsGerms = CodexLabBook(
        id: UUID(uuidString: "C000000A-0000-0000-0000-00000000000A")!,
        isbn: "9780393317558", title: "Guns, Germs, and Steel", author: "Jared Diamond",
        coverURL: cover("9780393317558"), genre: "History", totalPages: 480, currentPage: 40,
        dateAdded: daysAgo(19), isActive: false, flavorMeta: "Hi-01",
        reactionPhase: .idle, purity: 8, reagentCode: "Hi-01"
    )

    static let books = [
        frankenstein, jekyll, timeMachine, dracula, foundation,
        andThen, hobbit, pride, girlDragon, gunsGerms
    ]

    static func sessions() -> [CodexLabReadingSession] {
        let cal = Calendar.current
        return [
            CodexLabReadingSession(id: UUID(), bookId: jekyll.id, date: cal.date(byAdding: .day, value: -1, to: Date())!, pagesRead: 22, duration: 1800, flavorMeta: "Exothermic"),
            CodexLabReadingSession(id: UUID(), bookId: timeMachine.id, date: cal.date(byAdding: .day, value: -2, to: Date())!, pagesRead: 15, duration: 1200, flavorMeta: "Stable"),
            CodexLabReadingSession(id: UUID(), bookId: jekyll.id, date: cal.date(byAdding: .day, value: -3, to: Date())!, pagesRead: 22, duration: 1500, flavorMeta: "Catalyst added"),
            CodexLabReadingSession(id: UUID(), bookId: foundation.id, date: cal.date(byAdding: .day, value: -4, to: Date())!, pagesRead: 30, duration: 2100, flavorMeta: "Psychohistory"),
            CodexLabReadingSession(id: UUID(), bookId: andThen.id, date: cal.date(byAdding: .day, value: -5, to: Date())!, pagesRead: 25, duration: 1700, flavorMeta: "Titration"),
            CodexLabReadingSession(id: UUID(), bookId: hobbit.id, date: cal.date(byAdding: .day, value: -6, to: Date())!, pagesRead: 28, duration: 1900, flavorMeta: "Alchemy"),
            CodexLabReadingSession(id: UUID(), bookId: girlDragon.id, date: cal.date(byAdding: .day, value: -7, to: Date())!, pagesRead: 35, duration: 2400, flavorMeta: "Volatile")
        ]
    }

    static func experiments() -> [Experiment] {
        [
            Experiment(id: UUID(), bookId: jekyll.id, title: jekyll.title, startedAt: daysAgo(10), phase: .reacting, yield: 50, temperature: jekyll.boilingPoint, isArchived: false),
            Experiment(id: UUID(), bookId: timeMachine.id, title: timeMachine.title, startedAt: daysAgo(3), phase: .heating, yield: 25, temperature: timeMachine.boilingPoint, isArchived: false),
            Experiment(id: UUID(), bookId: frankenstein.id, title: frankenstein.title, startedAt: daysAgo(60), phase: .precipitated, yield: 100, temperature: frankenstein.boilingPoint, isArchived: true),
            Experiment(id: UUID(), bookId: foundation.id, title: foundation.title, startedAt: daysAgo(22), phase: .reacting, yield: 49, temperature: foundation.boilingPoint, isArchived: false),
            Experiment(id: UUID(), bookId: andThen.id, title: andThen.title, startedAt: daysAgo(8), phase: .heating, yield: 30, temperature: andThen.boilingPoint, isArchived: false),
            Experiment(id: UUID(), bookId: hobbit.id, title: hobbit.title, startedAt: daysAgo(28), phase: .reacting, yield: 48, temperature: hobbit.boilingPoint, isArchived: false)
        ]
    }

    static func reactions() -> [Reaction] {
        let cal = Calendar.current
        return [
            Reaction(id: UUID(), experimentId: nil, bookId: jekyll.id, date: cal.date(byAdding: .day, value: -1, to: Date())!, pagesRead: 22, phase: .reacting, note: "+22 pages", puritySnapshot: 37.5),
            Reaction(id: UUID(), experimentId: nil, bookId: timeMachine.id, date: cal.date(byAdding: .day, value: -2, to: Date())!, pagesRead: 15, phase: .heating, note: "+15 pages", puritySnapshot: 25),
            Reaction(id: UUID(), experimentId: nil, bookId: jekyll.id, date: cal.date(byAdding: .day, value: -3, to: Date())!, pagesRead: 22, phase: .heating, note: "Phase → Heating", puritySnapshot: 25),
            Reaction(id: UUID(), experimentId: nil, bookId: foundation.id, date: cal.date(byAdding: .day, value: -4, to: Date())!, pagesRead: 30, phase: .reacting, note: "+30 pages", puritySnapshot: 49),
            Reaction(id: UUID(), experimentId: nil, bookId: hobbit.id, date: cal.date(byAdding: .day, value: -6, to: Date())!, pagesRead: 28, phase: .reacting, note: "Fa yield up", puritySnapshot: 48)
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
        let existing = (try? await bookRepository.fetchAll()) ?? []

        if existing.isEmpty {
            for book in CodexLabMockCatalog.books { try? await bookRepository.save(book) }
            for session in CodexLabMockCatalog.sessions() { try? await bookRepository.logSession(session) }
            for experiment in CodexLabMockCatalog.experiments() { try? await labRepository.saveExperiment(experiment) }
            for reaction in CodexLabMockCatalog.reactions() { try? await labRepository.saveReaction(reaction) }
            UserDefaults.standard.set(true, forKey: CodexLabMetadata.seedKey)
            return
        }

        let ids = Set(existing.map(\.id))
        for book in CodexLabMockCatalog.books where !ids.contains(book.id) {
            try? await bookRepository.save(book)
        }
        UserDefaults.standard.set(true, forKey: CodexLabMetadata.seedKey)
    }
}
