import XCTest
@testable import StjernelobCore

/// Tests for den tilgivende ugentlige streak og ugemålet (jf. spec afsnit 5.3,
/// 6.2 og uge-/tidszonegrænser i afsnit 16).
final class StreakTests: XCTestCase {

    private let calendar = Calendar.iso8601Monday

    private func week(_ year: Int, _ weekOfYear: Int) -> WeekIdentifier {
        WeekIdentifier(yearForWeekOfYear: year, weekOfYear: weekOfYear)
    }

    private func goalMet(_ week: WeekIdentifier, target: Int = 3) -> WeekProgress {
        WeekProgress(week: week, targetSessions: target, completedSessions: target)
    }

    // MARK: - Ugegrænser

    func testPreviousWeekViaDateMath() throws {
        let date = try XCTUnwrap(DateComponents(calendar: calendar, year: 2026, month: 6, day: 3).date)
        let current = WeekIdentifier(date: date, calendar: calendar)
        let earlier = try XCTUnwrap(calendar.date(byAdding: .day, value: -7, to: date))
        XCTAssertEqual(current.previous(calendar: calendar),
                       WeekIdentifier(date: earlier, calendar: calendar))
    }

    func testWeekRollsOverYearBoundary() throws {
        // Uge 1 i et år: den foregående uge ligger i året før.
        let firstWeek = week(2026, 1)
        let previous = firstWeek.previous(calendar: calendar)
        XCTAssertLessThan(previous, firstWeek)
        XCTAssertLessThanOrEqual(previous.yearForWeekOfYear, 2025)
    }

    // MARK: - Ugemål

    func testGoalIsAtLeastOneSession() {
        let goal = WeeklyGoal(week: week(2026, 20), targetSessions: 0)
        XCTAssertEqual(goal.targetSessions, 1)
    }

    func testAtLeastOneSessionCountsAsActiveWeek() {
        let progress = WeekProgress(week: week(2026, 20), targetSessions: 3, completedSessions: 1)
        XCTAssertTrue(progress.isActive)
        XCTAssertFalse(progress.isGoalMet)
    }

    func testBusyWeekKeptAliveWithLowGoal() {
        // At sætte målet lavt i en travl uge er et fuldgyldigt valg.
        let progress = WeekProgress(week: week(2026, 20), targetSessions: 1, completedSessions: 1)
        XCTAssertTrue(progress.isGoalMet)
    }

    // MARK: - Streak

    func testConsecutiveGoalMetWeeks() {
        let current = week(2026, 20)
        var tracker = WeeklyTracker(calendar: calendar)
        tracker.record(goalMet(current))
        tracker.record(goalMet(current.previous(calendar: calendar)))
        tracker.record(goalMet(current.previous(calendar: calendar).previous(calendar: calendar)))
        XCTAssertEqual(tracker.currentStreak(asOf: current), 3)
    }

    func testMissedWeekBreaksStreak() {
        let current = week(2026, 20)
        let last = current.previous(calendar: calendar)
        var tracker = WeeklyTracker(calendar: calendar)
        tracker.record(goalMet(current))
        tracker.record(WeekProgress(week: last, targetSessions: 3, completedSessions: 0)) // missed
        XCTAssertEqual(tracker.currentStreak(asOf: current), 1)
    }

    func testFreezeKeepsStreakAlive() {
        let current = week(2026, 20)
        let last = current.previous(calendar: calendar)
        let earlier = last.previous(calendar: calendar)
        var tracker = WeeklyTracker(calendar: calendar)
        tracker.record(goalMet(current))
        tracker.record(WeekProgress(week: last, targetSessions: 3, completedSessions: 0))
        tracker.freeze(last)               // reddet af en streak-fryser
        tracker.record(goalMet(earlier))
        XCTAssertEqual(tracker.currentStreak(asOf: current), 3)
    }

    func testPausedWeekIsTransparent() {
        let current = week(2026, 20)
        let last = current.previous(calendar: calendar)
        let earlier = last.previous(calendar: calendar)
        var tracker = WeeklyTracker(calendar: calendar)
        tracker.record(goalMet(current))
        tracker.pause(last)                // bevidst pause — bryder ikke
        tracker.record(goalMet(earlier))
        // Pausen tæller ikke med, men streaken fortsætter henover den.
        XCTAssertEqual(tracker.currentStreak(asOf: current), 2)
    }

    func testCurrentWeekInProgressDoesNotBreakStreak() {
        let current = week(2026, 20)
        let last = current.previous(calendar: calendar)
        let earlier = last.previous(calendar: calendar)
        var tracker = WeeklyTracker(calendar: calendar)
        // Aktuel uge i gang, men endnu ikke i mål.
        tracker.record(WeekProgress(week: current, targetSessions: 3, completedSessions: 1))
        tracker.record(goalMet(last))
        tracker.record(goalMet(earlier))
        XCTAssertEqual(tracker.currentStreak(asOf: current), 2)
    }

    func testNoHistoryGivesZeroStreakWithoutCrashing() {
        let tracker = WeeklyTracker(calendar: calendar)
        XCTAssertEqual(tracker.currentStreak(asOf: week(2026, 20)), 0)
    }
}
