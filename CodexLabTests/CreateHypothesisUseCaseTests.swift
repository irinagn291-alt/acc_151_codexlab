import XCTest
@testable import CodexLab

final class CreateHypothesisUseCaseTests: XCTestCase {
    func testCreatesMonthlyHypothesis() async throws {
        let lab = InMemoryLabRepository()
        let sut = CreateHypothesisUseCase(labRepository: lab)
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 7, day: 14))!

        let hypothesis = try await sut.execute(
            genreA: "Horror",
            genreB: "Mystery",
            targetPages: 180,
            date: date
        )

        XCTAssertEqual(hypothesis.genreA, "Horror")
        XCTAssertEqual(hypothesis.genreB, "Mystery")
        XCTAssertEqual(hypothesis.targetPages, 180)
        XCTAssertEqual(hypothesis.monthKey, "2026-07")
        XCTAssertFalse(hypothesis.isComplete)
        let stored = try await lab.fetchHypotheses()
        XCTAssertEqual(stored.count, 1)
    }

    func testRejectsIdenticalGenres() async {
        let sut = CreateHypothesisUseCase(labRepository: InMemoryLabRepository())
        do {
            _ = try await sut.execute(genreA: "Horror", genreB: "horror", targetPages: 100)
            XCTFail("Expected invalidHypothesis")
        } catch CodexLabDomainError.invalidHypothesis {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected \(error)")
        }
    }

    func testRejectsDuplicateActiveMonth() async throws {
        let lab = InMemoryLabRepository()
        let sut = CreateHypothesisUseCase(labRepository: lab)
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 7, day: 1))!
        _ = try await sut.execute(genreA: "Horror", genreB: "Mystery", targetPages: 100, date: date)

        do {
            _ = try await sut.execute(genreA: "Fantasy", genreB: "Romance", targetPages: 120, date: date)
            XCTFail("Expected hypothesisExists")
        } catch CodexLabDomainError.hypothesisExists {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected \(error)")
        }
    }
}

final class InMemoryLabRepository: CodexLabLabRepositoryProtocol, @unchecked Sendable {
    private var experiments: [Experiment] = []
    private var reactions: [Reaction] = []
    private var hypotheses: [Hypothesis] = []
    private var elements: [GenreElement] = []

    nonisolated func fetchExperiments() async throws -> [Experiment] { experiments }
    nonisolated func fetchExperiment(by id: UUID) async throws -> Experiment? { experiments.first { $0.id == id } }
    nonisolated func saveExperiment(_ experiment: Experiment) async throws { experiments.append(experiment) }
    nonisolated func updateExperiment(_ experiment: Experiment) async throws {
        guard let idx = experiments.firstIndex(where: { $0.id == experiment.id }) else { return }
        experiments[idx] = experiment
    }
    nonisolated func fetchReactions() async throws -> [Reaction] { reactions }
    nonisolated func saveReaction(_ reaction: Reaction) async throws { reactions.append(reaction) }
    nonisolated func fetchHypotheses() async throws -> [Hypothesis] { hypotheses }
    nonisolated func fetchHypothesis(monthKey: String) async throws -> Hypothesis? {
        hypotheses.first { $0.monthKey == monthKey }
    }
    nonisolated func saveHypothesis(_ hypothesis: Hypothesis) async throws { hypotheses.append(hypothesis) }
    nonisolated func updateHypothesis(_ hypothesis: Hypothesis) async throws {
        guard let idx = hypotheses.firstIndex(where: { $0.id == hypothesis.id }) else { return }
        hypotheses[idx] = hypothesis
    }
    nonisolated func fetchGenreElements() async throws -> [GenreElement] { elements }
    nonisolated func saveGenreElements(_ elements: [GenreElement]) async throws { self.elements = elements }
}
