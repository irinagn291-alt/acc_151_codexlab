import Foundation

struct GetGenreElementsUseCase: Sendable {
    private let bookRepository: CodexLabBookRepositoryProtocol
    private let labRepository: CodexLabLabRepositoryProtocol

    init(bookRepository: CodexLabBookRepositoryProtocol, labRepository: CodexLabLabRepositoryProtocol) {
        self.bookRepository = bookRepository
        self.labRepository = labRepository
    }

    func execute() async throws -> [GenreElement] {
        let books = try await bookRepository.fetchAll()
        var stored = try await labRepository.fetchGenreElements()

        if stored.isEmpty {
            stored = Self.makeCatalog()
            try await labRepository.saveGenreElements(stored)
        }

        let related = Self.relationMap(for: stored)
        return stored.map { element in
            var copy = element
            let specimens = books.filter { ReagentCodeMapper.matches($0.genre, elementName: element.name) }
            copy.specimens = specimens
            copy.specimenCount = specimens.count
            copy.relatedElementIDs = related[element.id] ?? []
            return copy
        }.sorted { $0.atomicNumber < $1.atomicNumber }
    }

    private static func makeCatalog() -> [GenreElement] {
        GenreElement.catalogSeed.map { seed in
            GenreElement(
                id: UUID(),
                symbol: seed.symbol,
                name: seed.name,
                reagentPrefix: seed.prefix,
                specimenCount: 0,
                atomicNumber: seed.atomic,
                relatedElementIDs: [],
                specimens: []
            )
        }
    }

    private static func relationMap(for elements: [GenreElement]) -> [UUID: [UUID]] {
        func id(named name: String) -> UUID? {
            elements.first { $0.name.caseInsensitiveCompare(name) == .orderedSame }?.id
        }
        var map: [UUID: [UUID]] = [:]
        let pairs: [(String, String)] = [
            ("Horror", "Mystery"),
            ("Horror", "Thriller"),
            ("Science Fiction", "Fantasy"),
            ("Science Fiction", "Adventure"),
            ("Mystery", "Thriller"),
            ("Romance", "Drama"),
            ("History", "Biography"),
            ("Fantasy", "Adventure"),
            ("Poetry", "Drama"),
            ("Nonfiction", "Biography")
        ]
        for (a, b) in pairs {
            guard let left = id(named: a), let right = id(named: b) else { continue }
            map[left, default: []].append(right)
            map[right, default: []].append(left)
        }
        return map
    }
}
