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

    func testThreeSessionsHaveSpacing() throws {
        // 3 ture spredes, så der er hviledage imellem (ingen to på rad i starten).
        let days = WeekScheduler.trainingDays(sessionsPerWeek: 3)
        XCTAssertEqual(days, days.sorted())
        let first = try XCTUnwrap(days.first)
        let last = try XCTUnwrap(days.last)
        XCTAssertGreaterThan(last - first, 2)
    }

    // MARK: - Selvvalgte dage

    func testResolvedUsesChosenDaysWhenPresent() {
        // Brugerens egne valg vinder, sorteret og uden dubletter.
        XCTAssertEqual(
            WeekScheduler.resolvedTrainingDays(chosen: [4, 0, 2, 2], sessionsPerWeek: 1),
            [0, 2, 4]
        )
    }

    func testResolvedFallsBackToSuggestionWhenNoneChosen() {
        XCTAssertEqual(
            WeekScheduler.resolvedTrainingDays(chosen: [], sessionsPerWeek: 3),
            WeekScheduler.trainingDays(sessionsPerWeek: 3)
        )
    }

    func testResolvedIgnoresInvalidDays() {
        XCTAssertEqual(
            WeekScheduler.resolvedTrainingDays(chosen: [-1, 9, 3], sessionsPerWeek: 2),
            [3]
        )
    }

    func testIsTrainingDayWithExplicitDays() {
        let date = Date()
        let weekday = WeekScheduler.weekdayMondayBased(date)
        XCTAssertTrue(WeekScheduler.isTrainingDay(date, trainingDays: [weekday]))
        XCTAssertFalse(WeekScheduler.isTrainingDay(date, trainingDays: []))
    }
}
