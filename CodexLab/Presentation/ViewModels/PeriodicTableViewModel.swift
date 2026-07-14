import Foundation

@Observable
@MainActor
final class PeriodicTableViewModel {
    var elements: [GenreElement] = []
    var isLoading = false
    var errorMessage: String?

    private let getGenreElements: GetGenreElementsUseCase

    init(factory: CodexLabFactory = .shared) {
        getGenreElements = factory.getGenreElementsUseCase
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            elements = try await getGenreElements.execute()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func element(id: UUID) -> GenreElement? {
        elements.first { $0.id == id }
    }
}
