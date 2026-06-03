import XCTest
@testable import StjernelobCore

/// Tests for stjerner, point/niveauer og badges (jf. spec afsnit 5.1, 5.2, 5.4).
/// Belønning gives for gennemførsel — aldrig fart eller distance.
final class GamificationTests: XCTestCase {

    // MARK: - Stjerner

    func testStarsForCompletedWorkout() {
        let summary = WorkoutSummary(
            plannedDuration: .minutes(20), activeDuration: .minutes(20),
            intervalsCompleted: 5, plannedIntervalCount: 5,
            runIntervalsCompleted: 2, isComplete: true
        )
        XCTAssertEqual(Stars.earned(for: summary), 5 + Stars.completionBonus)
    }

    func testStarsForAbortedWorkoutStillRewardProgress() {
        let summary = WorkoutSummary(
            plannedDuration: .minutes(20), activeDuration: .minutes(8),
            intervalsCompleted: 2, plannedIntervalCount: 5,
            runIntervalsCompleted: 1, isComplete: false
        )
        XCTAssertEqual(Stars.earned(for: summary), 2)   // ingen bonus, men fulde stjerner for det gennemførte
    }

    // MARK: - Point og niveauer

    func testPointsAreStars() {
        XCTAssertEqual(Points.fromStars(42), 42)
    }

    func testLevelThresholds() {
        let system = LevelSystem.standard
        XCTAssertEqual(system.level(forPoints: 0), 1)
        XCTAssertEqual(system.level(forPoints: 24), 1)
        XCTAssertEqual(system.level(forPoints: 25), 2)
        XCTAssertEqual(system.level(forPoints: 1299), 9)
        XCTAssertEqual(system.level(forPoints: 1300), 10)
        XCTAssertEqual(system.level(forPoints: 99999), 10)   // klamper til max
    }

    func testLevelProgressFraction() {
        let system = LevelSystem.standard
        let progress = system.progress(forPoints: 42)   // niveau 2 (25..60)
        XCTAssertEqual(progress.level, 2)
        XCTAssertEqual(progress.pointsIntoLevel, 17)     // 42 - 25
        XCTAssertEqual(progress.pointsForLevel, 35)      // 60 - 25
        XCTAssertFalse(progress.isMaxLevel)
        XCTAssertEqual(progress.fraction, 17.0 / 35.0, accuracy: 0.0001)
    }

    func testMaxLevelHasNoCeiling() {
        let progress = LevelSystem.standard.progress(forPoints: 5000)
        XCTAssertTrue(progress.isMaxLevel)
        XCTAssertNil(progress.pointsForLevel)
        XCTAssertEqual(progress.fraction, 1)
    }

    // MARK: - Badges

    func testFirstWorkoutBadge() {
        let context = BadgeContext(totalCompletedWorkouts: 1, currentStreakWeeks: 0,
                                   longestContinuousRun: .minutes(1))
        XCTAssertEqual(BadgeEvaluator.newlyEarned(context: context, alreadyEarned: []), [.firstWorkout])
    }

    func testAlreadyEarnedBadgesAreNotRepeated() {
        let context = BadgeContext(totalCompletedWorkouts: 1, currentStreakWeeks: 0,
                                   longestContinuousRun: .minutes(1))
        XCTAssertTrue(BadgeEvaluator.newlyEarned(context: context, alreadyEarned: [.firstWorkout]).isEmpty)
    }

    func testMilestoneBadges() {
        let context = BadgeContext(
            totalCompletedWorkouts: 10,
            currentStreakWeeks: 3,
            longestContinuousRun: .minutes(5),
            startedInMorning: true,
            wasRaining: true,
            finishedBaseProgram: true
        )
        let earned = Set(BadgeEvaluator.newlyEarned(context: context, alreadyEarned: []))
        XCTAssertEqual(earned, Set(Badge.allCases))   // alle betingelser opfyldt
    }

    func testStableOrdering() {
        let context = BadgeContext(totalCompletedWorkouts: 10, currentStreakWeeks: 3,
                                   longestContinuousRun: .minutes(5))
        let earned = BadgeEvaluator.newlyEarned(context: context, alreadyEarned: [])
        XCTAssertEqual(earned, earned.sorted { Badge.allCases.firstIndex(of: $0)! < Badge.allCases.firstIndex(of: $1)! })
    }
}
