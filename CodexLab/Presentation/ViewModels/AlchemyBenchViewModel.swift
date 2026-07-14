import Foundation

@Observable
@MainActor
final class AlchemyBenchViewModel {
    var availableGenres: [String] = GenreElement.catalogSeed.map(\.name)
    var genreA: String = "Horror"
    var genreB: String = "Mystery"
    var targetPages: Int = 200
    var hypothesis: Hypothesis?
    var message: String?
    var isSaving = false

    private let createHypothesis: CreateHypothesisUseCase
    private let updateProgress: UpdateHypothesisProgressUseCase
    private let getElements: GetGenreElementsUseCase

    init(factory: CodexLabFactory = .shared) {
        createHypothesis = factory.createHypothesisUseCase
        updateProgress = factory.updateHypothesisProgressUseCase
        getElements = factory.getGenreElementsUseCase
    }

    func load() async {
        if let elements = try? await getElements.execute(), !elements.isEmpty {
            availableGenres = elements.map(\.name)
        }
        hypothesis = try? await updateProgress.execute()
        if let hypothesis {
            genreA = hypothesis.genreA
            genreB = hypothesis.genreB
            targetPages = hypothesis.targetPages
        }
    }

    func create() async {
        isSaving = true
        defer { isSaving = false }
        do {
            hypothesis = try await createHypothesis.execute(
                genreA: genreA,
                genreB: genreB,
                targetPages: targetPages
            )
            message = nil
        } catch CodexLabDomainError.hypothesisExists {
            message = "Active monthly hypothesis already running."
        } catch CodexLabDomainError.invalidHypothesis {
            message = "Pick two distinct genres and a page target."
        } catch {
            message = error.localizedDescription
        }
    }

    func refreshProgress() async {
        hypothesis = try? await updateProgress.execute()
    }
}
