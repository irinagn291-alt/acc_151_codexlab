import Foundation

nonisolated struct Hypothesis: Identifiable, Equatable, Sendable {
    let id: UUID
    var genreA: String
    var genreB: String
    var targetPages: Int
    var progressPages: Int
    var monthKey: String
    var createdAt: Date
    var isComplete: Bool

    var progress: Double {
        guard targetPages > 0 else { return 0 }
        return min(Double(progressPages) / Double(targetPages), 1.0)
    }

    nonisolated static func monthKey(for date: Date = Date(), calendar: Calendar = .current) -> String {
        let comps = calendar.dateComponents([.year, .month], from: date)
        return String(format: "%04d-%02d", comps.year ?? 0, comps.month ?? 0)
    }
}
