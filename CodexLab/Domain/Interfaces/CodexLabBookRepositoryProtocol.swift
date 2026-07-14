import Foundation

protocol CodexLabBookRepositoryProtocol: Sendable {
    func fetchAll() async throws -> [CodexLabBook]
    func fetchActive() async throws -> CodexLabBook?
    func fetch(by id: UUID) async throws -> CodexLabBook?
    func save(_ book: CodexLabBook) async throws
    func setActive(_ bookId: UUID) async throws
    func updateProgress(bookId: UUID, currentPage: Int) async throws
    func updateBook(_ book: CodexLabBook) async throws
    func logSession(_ session: CodexLabReadingSession) async throws
    func fetchSessions(for bookId: UUID?) async throws -> [CodexLabReadingSession]
    func fetchSessions(from start: Date, to end: Date) async throws -> [CodexLabReadingSession]
}

protocol CodexLabLabRepositoryProtocol: Sendable {
    nonisolated func fetchExperiments() async throws -> [Experiment]
    nonisolated func fetchExperiment(by id: UUID) async throws -> Experiment?
    nonisolated func saveExperiment(_ experiment: Experiment) async throws
    nonisolated func updateExperiment(_ experiment: Experiment) async throws
    nonisolated func fetchReactions() async throws -> [Reaction]
    nonisolated func saveReaction(_ reaction: Reaction) async throws
    nonisolated func fetchHypotheses() async throws -> [Hypothesis]
    nonisolated func fetchHypothesis(monthKey: String) async throws -> Hypothesis?
    nonisolated func saveHypothesis(_ hypothesis: Hypothesis) async throws
    nonisolated func updateHypothesis(_ hypothesis: Hypothesis) async throws
    nonisolated func fetchGenreElements() async throws -> [GenreElement]
    nonisolated func saveGenreElements(_ elements: [GenreElement]) async throws
}

protocol CodexLabOpenLibraryAPIProtocol: Sendable {
    func fetchBook(isbn: String) async throws -> CodexLabOpenLibraryBook
    func fetchBook(isbns: [String]) async throws -> CodexLabOpenLibraryBook
    func fetchRecommendations(subjects: [String], limit: Int) async throws -> [CodexLabBookRecommendation]
    func coverURL(for isbn: String) -> URL
    func bestCoverURL(isbn: String, coverId: Int?) -> URL
    func coverURLs(isbn: String?, coverId: Int?, isbnCandidates: [String]) -> [URL]
    func sourceURL(isbn: String, workKey: String?) -> URL
}
