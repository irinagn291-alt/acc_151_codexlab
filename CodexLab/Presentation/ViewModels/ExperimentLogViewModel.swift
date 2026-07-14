import Foundation

@Observable
@MainActor
final class ExperimentLogViewModel {
    struct TimelineItem: Identifiable {
        let id: UUID
        let date: Date
        let title: String
        let detail: String
        let phase: ReactionPhase
        let purity: Double
    }

    var items: [TimelineItem] = []

    private let labRepository: CodexLabLabRepositoryProtocol
    private let bookRepository: CodexLabBookRepositoryProtocol

    init(factory: CodexLabFactory = .shared) {
        labRepository = factory.labRepository
        bookRepository = factory.bookRepository
    }

    func load() async {
        let reactions = (try? await labRepository.fetchReactions()) ?? []
        let books = Dictionary(uniqueKeysWithValues: ((try? await bookRepository.fetchAll()) ?? []).map { ($0.id, $0) })
        items = reactions.map { reaction in
            let title = books[reaction.bookId]?.title ?? "Unknown specimen"
            return TimelineItem(
                id: reaction.id,
                date: reaction.date,
                title: title,
                detail: reaction.note.isEmpty ? "\(reaction.pagesRead) pages" : reaction.note,
                phase: reaction.phase,
                purity: reaction.puritySnapshot
            )
        }
    }
}
