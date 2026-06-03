import XCTest
@testable import Stjernelob

/// Tests for fordelingen af ugens ture på dage (hviledage imellem).
final class WeekSchedulerTests: XCTestCase {
    func testCountMatchesSessions() {
        XCTAssertEqual(WeekScheduler.trainingDays(sessionsPerWeek: 1).count, 1)
        XCTAssertEqual(WeekScheduler.trainingDays(sessionsPerWeek: 3).count, 3)
        XCTAssertEqual(WeekScheduler.trainingDays(sessionsPerWeek: 5).count, 5)
    }

    func testDaysAreWithinTheWeek() {
        for sessions in 1...5 {
            for day in WeekScheduler.trainingDays(sessionsPerWeek: sessions) {
                XCTAssertTrue((0...6).contains(day))
            }
        }
    }

    func testThreeSessionsHaveSpacing() {
        // 3 ture spredes, så der er hviledage imellem (ingen to på rad i starten).
        let days = WeekScheduler.trainingDays(sessionsPerWeek: 3)
        XCTAssertEqual(days, days.sorted())
        XCTAssertGreaterThan(days.last! - days.first!, 2)
    }
}
