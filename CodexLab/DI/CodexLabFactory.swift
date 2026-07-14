import CoreData
import SwiftUI

@MainActor
final class CodexLabFactory {
    static let shared = CodexLabFactory()

    let persistence: NSPersistentContainer
    let bookRepository: CodexLabBookRepository
    let labRepository: CodexLabLabRepository
    let openLibrary: CodexLabOpenLibraryClient

    let addBookUseCase: CodexLabAddBookUseCase
    let logPagesUseCase: CodexLabLogPagesUseCase
    let getStatsUseCase: CodexLabGetStatsUseCase
    let getGenreElementsUseCase: GetGenreElementsUseCase
    let seedDataUseCase: CodexLabSeedDataUseCase
    let fetchBookRecommendationsUseCase: CodexLabFetchBookRecommendationsUseCase
    let advanceReactionPhaseUseCase: AdvanceReactionPhaseUseCase
    let computePurityUseCase: ComputePurityUseCase
    let createHypothesisUseCase: CreateHypothesisUseCase
    let updateHypothesisProgressUseCase: UpdateHypothesisProgressUseCase

    private(set) var coordinator: CodexLabCoordinator

    private init() {
        persistence = CodexLabPersistenceController.shared
        bookRepository = CodexLabBookRepository(container: persistence)
        labRepository = CodexLabLabRepository(container: persistence)
        openLibrary = CodexLabOpenLibraryClient()
        computePurityUseCase = ComputePurityUseCase()
        updateHypothesisProgressUseCase = UpdateHypothesisProgressUseCase(
            labRepository: labRepository,
            bookRepository: bookRepository
        )
        addBookUseCase = CodexLabAddBookUseCase(
            repository: bookRepository,
            labRepository: labRepository,
            api: openLibrary
        )
        logPagesUseCase = CodexLabLogPagesUseCase(
            repository: bookRepository,
            labRepository: labRepository,
            computePurity: computePurityUseCase,
            updateHypothesis: updateHypothesisProgressUseCase
        )
        getStatsUseCase = CodexLabGetStatsUseCase(repository: bookRepository)
        getGenreElementsUseCase = GetGenreElementsUseCase(
            bookRepository: bookRepository,
            labRepository: labRepository
        )
        seedDataUseCase = CodexLabSeedDataUseCase(
            bookRepository: bookRepository,
            labRepository: labRepository
        )
        fetchBookRecommendationsUseCase = CodexLabFetchBookRecommendationsUseCase(
            repository: bookRepository,
            api: openLibrary
        )
        advanceReactionPhaseUseCase = AdvanceReactionPhaseUseCase(
            bookRepository: bookRepository,
            labRepository: labRepository,
            computePurity: computePurityUseCase
        )
        createHypothesisUseCase = CreateHypothesisUseCase(labRepository: labRepository)
        coordinator = CodexLabCoordinator()
    }

    func makeCoordinator() -> CodexLabCoordinator {
        coordinator
    }

    func bootstrap() async {
        await seedDataUseCase.executeIfNeeded()
    }
}
