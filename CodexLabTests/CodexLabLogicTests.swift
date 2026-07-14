import Foundation

enum ComputePurityUseCaseTests {
    static func run() {
        let useCase = ComputePurityUseCase()
        precondition(useCase.execute(consecutiveDays: 0) == 0)
        precondition(useCase.execute(consecutiveDays: 4) == 50)
        precondition(useCase.execute(consecutiveDays: 8) == 100)
    }
}

enum CreateHypothesisUseCaseTests {
    static func run() async throws {
        let lab = MockCodexLabLabRepository()
        let created = try await CreateHypothesisUseCase(labRepository: lab).execute(
            genreA: "Horror",
            genreB: "Mystery",
            targetPages: 200
        )
        precondition(created.targetPages == 200)
        precondition(lab.hypotheses.count == 1)
    }
}

final class MockCodexLabLabRepository: CodexLabLabRepositoryProtocol, @unchecked Sendable {
    var hypotheses: [Hypothesis] = []
    var elements: [GenreElement] = []
    var reactions: [Reaction] = []
    var experiments: [Experiment] = []

    func fetchExperiments() async throws -> [Experiment] { experiments }
    func fetchExperiment(by id: UUID) async throws -> Experiment? { experiments.first { $0.id == id } }
    func saveExperiment(_ experiment: Experiment) async throws { experiments.append(experiment) }
    func updateExperiment(_ experiment: Experiment) async throws {
        if let i = experiments.firstIndex(where: { $0.id == experiment.id }) { experiments[i] = experiment }
    }
    func fetchReactions() async throws -> [Reaction] { reactions }
    func saveReaction(_ reaction: Reaction) async throws { reactions.append(reaction) }
    func fetchHypotheses() async throws -> [Hypothesis] { hypotheses }
    func fetchHypothesis(monthKey: String) async throws -> Hypothesis? {
        hypotheses.first { $0.monthKey == monthKey }
    }
    func saveHypothesis(_ hypothesis: Hypothesis) async throws { hypotheses.append(hypothesis) }
    func updateHypothesis(_ hypothesis: Hypothesis) async throws {
        if let i = hypotheses.firstIndex(where: { $0.id == hypothesis.id }) { hypotheses[i] = hypothesis }
    }
    func fetchGenreElements() async throws -> [GenreElement] { elements }
    func saveGenreElements(_ elements: [GenreElement]) async throws { self.elements = elements }
}
