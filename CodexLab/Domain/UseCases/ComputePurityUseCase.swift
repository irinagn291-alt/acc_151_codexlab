import Foundation

struct ComputePurityUseCase: Sendable {
    nonisolated init() {}

    nonisolated func execute(consecutiveDays: Int) -> Double {
        guard consecutiveDays > 0 else { return 0 }
        let base = Double(consecutiveDays) * 12.5
        let bonus = consecutiveDays >= 7 ? 12.5 : 0
        return min(100, base + bonus)
    }

    nonisolated func execute(dailyPages: [Date: Int], calendar: Calendar = .current, reference: Date = Date()) -> Double {
        var days = 0
        var day = calendar.startOfDay(for: reference)
        while dailyPages[day, default: 0] > 0 {
            days += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = prev
        }
        return execute(consecutiveDays: days)
    }
}
