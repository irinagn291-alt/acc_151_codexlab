import Foundation

nonisolated struct Reaction: Identifiable, Equatable, Sendable {
    let id: UUID
    var experimentId: UUID?
    let bookId: UUID
    let date: Date
    var pagesRead: Int
    var phase: ReactionPhase
    var note: String
    var puritySnapshot: Double
}
