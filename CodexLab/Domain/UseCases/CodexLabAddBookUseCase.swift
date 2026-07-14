import Foundation

struct CodexLabAddBookUseCase: Sendable {
    private let repository: CodexLabBookRepositoryProtocol
    private let labRepository: CodexLabLabRepositoryProtocol
    private let api: CodexLabOpenLibraryAPIProtocol

    init(
        repository: CodexLabBookRepositoryProtocol,
        labRepository: CodexLabLabRepositoryProtocol,
        api: CodexLabOpenLibraryAPIProtocol
    ) {
        self.repository = repository
        self.labRepository = labRepository
        self.api = api
    }

    func execute(isbn: String) async throws -> CodexLabBook {
        let normalized = isbn.uppercased().filter { $0.isNumber || $0 == "X" }
        let metadata = try await api.fetchBook(isbn: normalized)
        return try await save(metadata: metadata, isbn: normalized)
    }

    func execute(recommendation: CodexLabBookRecommendation) async throws -> CodexLabBook {
        let candidates = recommendation.isbnCandidates.isEmpty
            ? (recommendation.isbn.map { [$0] } ?? [])
            : recommendation.isbnCandidates
        guard !candidates.isEmpty else { throw CodexLabOpenLibraryError.notFound }

        var lastError: Error = CodexLabOpenLibraryError.notFound
        for isbn in candidates {
            do { return try await execute(isbn: isbn) }
            catch { lastError = error }
        }
        throw lastError
    }

    private func save(metadata: CodexLabOpenLibraryBook, isbn: String) async throws -> CodexLabBook {
        let genre = metadata.subjects?.first ?? "General"
        let code = ReagentCodeMapper.code(for: genre)
        let book = CodexLabBook(
            id: UUID(),
            isbn: isbn,
            title: metadata.title ?? "Unknown Title",
            author: metadata.authors?.first ?? "Unknown Author",
            coverURL: api.bestCoverURL(isbn: isbn, coverId: metadata.coverId),
            genre: genre,
            totalPages: metadata.numberOfPages ?? 300,
            currentPage: 0,
            dateAdded: Date(),
            isActive: true,
            flavorMeta: code,
            reactionPhase: .idle,
            purity: 0,
            reagentCode: code
        )
        try await repository.save(book)
        try await repository.setActive(book.id)
        let experiment = Experiment(
            id: UUID(),
            bookId: book.id,
            title: book.title,
            startedAt: Date(),
            phase: .idle,
            yield: 0,
            temperature: book.boilingPoint,
            isArchived: false
        )
        try await labRepository.saveExperiment(experiment)
        return book
    }
}
