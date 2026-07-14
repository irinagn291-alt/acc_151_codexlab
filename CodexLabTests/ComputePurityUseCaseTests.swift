import XCTest
@testable import CodexLab

final class ComputePurityUseCaseTests: XCTestCase {
    private let sut = ComputePurityUseCase()

    func testZeroDaysYieldsZeroPurity() {
        XCTAssertEqual(sut.execute(consecutiveDays: 0), 0)
    }

    func testThreeDaysScalesLinearly() {
        XCTAssertEqual(sut.execute(consecutiveDays: 3), 37.5)
    }

    func testSevenDaysIncludesBonusAndCapsAtHundred() {
        XCTAssertEqual(sut.execute(consecutiveDays: 7), 100)
    }

    func testDailyPagesCountsConsecutiveStreak() {
        let calendar = Calendar(identifier: .gregorian)
        let reference = calendar.date(from: DateComponents(year: 2026, month: 7, day: 14))!
        let day0 = calendar.startOfDay(for: reference)
        let day1 = calendar.date(byAdding: .day, value: -1, to: day0)!
        let day2 = calendar.date(byAdding: .day, value: -2, to: day0)!
        let daily = [day0: 10, day1: 12, day2: 8]
        XCTAssertEqual(
            sut.execute(dailyPages: daily, calendar: calendar, reference: reference),
            37.5
        )
    }
}
