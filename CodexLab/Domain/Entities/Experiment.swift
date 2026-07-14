import Foundation

nonisolated struct Experiment: Identifiable, Equatable, Sendable {
    let id: UUID
    let bookId: UUID
    var title: String
    var startedAt: Date
    var phase: ReactionPhase
    var yield: Double
    var temperature: Int
    var isArchived: Bool
}
