import XCTest
@testable import StjernelobCore

/// Tests for den adaptive planlægning (docs/loebeplan.md → adaptiveLogic).
/// Reglerne er tilgivende: tvivl falder altid ud til den blødere vej.
final class AdaptivePlannerTests: XCTestCase {

    // MARK: - Ugens beslutning

    func testFullWeekAdvances() {
        XCTAssertEqual(
            AdaptivePlanner.decide(required: 3, missed: 0, consecutiveFullyMissedWeeks: 0),
            .advance
        )
    }

    func testOneMissedExtendsWeek() {
        XCTAssertEqual(
            AdaptivePlanner.decide(required: 3, missed: 1, consecutiveFullyMissedWeeks: 0),
            .extendWeek
        )
    }

    func testTwoMissedRepeatsWeek() {
        XCTAssertEqual(
            AdaptivePlanner.decide(required: 3, missed: 2, consecutiveFullyMissedWeeks: 0),
            .repeatWeek
        )
    }

    func testWholeWeekMissedStepsBackOne() {
        XCTAssertEqual(
            AdaptivePlanner.decide(required: 3, missed: 3, consecutiveFullyMissedWeeks: 1),
            .stepBack(weeks: 1)
        )
    }

    func testTwoWeeksMissedStepsBackTwo() {
        XCTAssertEqual(
            AdaptivePlanner.decide(required: 3, missed: 3, consecutiveFullyMissedWeeks: 2),
            .stepBack(weeks: 2)
        )
    }

    func testThreeWeeksMissedRestartsPhase() {
        XCTAssertEqual(
            AdaptivePlanner.decide(required: 3, missed: 3, consecutiveFullyMissedWeeks: 3),
            .restartPhase
        )
    }

    // MARK: - Uge-gennemførsel (min. 2 af 3)

    func testWeekCompletionThreshold() {
        XCTAssertTrue(AdaptivePlanner.isWeekComplete(required: 3, completed: 3))
        XCTAssertTrue(AdaptivePlanner.isWeekComplete(required: 3, completed: 2))
        XCTAssertFalse(AdaptivePlanner.isWeekComplete(required: 3, completed: 1))
        // En 2-turs-uge må misse højst én.
        XCTAssertTrue(AdaptivePlanner.isWeekComplete(required: 2, completed: 1))
        XCTAssertFalse(AdaptivePlanner.isWeekComplete(required: 2, completed: 0))
    }

    // MARK: - Streak-nulstilling (>10 dage)

    func testStreakResetOnlyAfterTenDays() {
        XCTAssertFalse(AdaptivePlanner.streakIsBroken(daysSinceLastSession: 1))
        XCTAssertFalse(AdaptivePlanner.streakIsBroken(daysSinceLastSession: 10))
        XCTAssertTrue(AdaptivePlanner.streakIsBroken(daysSinceLastSession: 11))
    }
}
