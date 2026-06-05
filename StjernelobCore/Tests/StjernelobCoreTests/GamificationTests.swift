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

    func testFirstRunIntervalIsAnEarlyWin() {
        // Allerede ét gennemført løbestykke på den allerførste tur giver mærke.
        let context = BadgeContext(totalCompletedWorkouts: 1, currentStreakWeeks: 0,
                                   maxRunIntervalsInOneRun: 1, totalRunIntervals: 1)
        let earned = Set(BadgeEvaluator.newlyEarned(context: context, alreadyEarned: []))
        XCTAssertEqual(earned, [.firstRunInterval, .firstWorkout])
    }

    func testRunIntervalsInOneRunMilestones() {
        func earned(maxInOneRun: Int) -> Set<Badge> {
            Set(BadgeEvaluator.newlyEarned(
                context: BadgeContext(totalCompletedWorkouts: 0, currentStreakWeeks: 0,
                                      maxRunIntervalsInOneRun: maxInOneRun),
                alreadyEarned: []
            ))
        }
        XCTAssertEqual(earned(maxInOneRun: 1), [.firstRunInterval])
        XCTAssertEqual(earned(maxInOneRun: 2), [.firstRunInterval, .twoRunIntervalsInOneRun])
        XCTAssertEqual(earned(maxInOneRun: 5),
                       [.firstRunInterval, .twoRunIntervalsInOneRun, .fiveRunIntervalsInOneRun])
        XCTAssertTrue(earned(maxInOneRun: 8).contains(.eightRunIntervalsInOneRun))
    }

    func testTotalRunIntervalMilestones() {
        func earned(total: Int) -> Set<Badge> {
            Set(BadgeEvaluator.newlyEarned(
                context: BadgeContext(totalCompletedWorkouts: 0, currentStreakWeeks: 0,
                                      totalRunIntervals: total),
                alreadyEarned: []
            ))
        }
        XCTAssertEqual(earned(total: 10), [.tenRunIntervalsTotal])
        XCTAssertTrue(earned(total: 50).isSuperset(of: [
            .tenRunIntervalsTotal, .twentyFiveRunIntervalsTotal, .fiftyRunIntervalsTotal
        ]))
        XCTAssertFalse(earned(total: 9).contains(.tenRunIntervalsTotal))
    }

    func testTwoGoodRunsBadge() {
        let one = BadgeContext(totalCompletedWorkouts: 0, currentStreakWeeks: 0,
                               runsWithFourPlusIntervals: 1)
        XCTAssertFalse(Set(BadgeEvaluator.newlyEarned(context: one, alreadyEarned: []))
            .contains(.twoRunsWithFourIntervals))
        let two = BadgeContext(totalCompletedWorkouts: 0, currentStreakWeeks: 0,
                               runsWithFourPlusIntervals: 2)
        XCTAssertTrue(Set(BadgeEvaluator.newlyEarned(context: two, alreadyEarned: []))
            .contains(.twoRunsWithFourIntervals))
    }

    func testAlreadyEarnedBadgesAreNotRepeated() {
        let context = BadgeContext(totalCompletedWorkouts: 1, currentStreakWeeks: 0,
                                   maxRunIntervalsInOneRun: 1, totalRunIntervals: 1)
        XCTAssertTrue(BadgeEvaluator.newlyEarned(
            context: context, alreadyEarned: [.firstRunInterval, .firstWorkout]
        ).isEmpty)
    }

    func testWorkoutCountMilestones() {
        func earned(after count: Int) -> Set<Badge> {
            Set(BadgeEvaluator.newlyEarned(
                context: BadgeContext(totalCompletedWorkouts: count, currentStreakWeeks: 0),
                alreadyEarned: []
            ))
        }
        XCTAssertEqual(earned(after: 5), [.firstWorkout, .fiveWorkouts])
        XCTAssertTrue(earned(after: 25).isSuperset(of: [.fiveWorkouts, .tenWorkouts, .twentyFiveWorkouts]))
        XCTAssertFalse(earned(after: 4).contains(.fiveWorkouts))
    }

    func testStreakMilestones() {
        func earned(weeks: Int) -> Set<Badge> {
            Set(BadgeEvaluator.newlyEarned(
                context: BadgeContext(totalCompletedWorkouts: 0, currentStreakWeeks: weeks),
                alreadyEarned: []
            ))
        }
        XCTAssertTrue(earned(weeks: 5).isSuperset(of: [.threeWeekStreak, .fiveWeekStreak]))
        XCTAssertFalse(earned(weeks: 2).contains(.threeWeekStreak))
    }

    func testSeasonalBadgesAreMutuallyExclusive() {
        func season(month: Int) -> Set<Badge> {
            Set(BadgeEvaluator.newlyEarned(
                context: BadgeContext(totalCompletedWorkouts: 0, currentStreakWeeks: 0, month: month),
                alreadyEarned: []
            ))
        }
        XCTAssertEqual(season(month: 1), [.winterRunner])
        XCTAssertEqual(season(month: 7), [.summerRunner])
        XCTAssertTrue(season(month: 4).isDisjoint(with: [.winterRunner, .summerRunner]))  // forår
    }

    func testContextualBadges() {
        let context = BadgeContext(
            totalCompletedWorkouts: 0, currentStreakWeeks: 0,
            startedInMorning: true, startedInEvening: false, isWeekendWorkout: true,
            wasRaining: true, tookPhoto: true, isComeback: true
        )
        let earned = Set(BadgeEvaluator.newlyEarned(context: context, alreadyEarned: []))
        XCTAssertEqual(earned, [.earlyBird, .weekendWarrior, .rainHero, .photographer, .comeback])
    }

    func testEveryBadgeIsReachable() {
        // En maksimal vinter-kontekst skal låse alt op undtagen sommer-mærket
        // (årstiderne udelukker hinanden) — ingen badge er umulig at få.
        let context = BadgeContext(
            totalCompletedWorkouts: 25,
            currentStreakWeeks: 5,
            maxRunIntervalsInOneRun: 8,
            totalRunIntervals: 50,
            runsWithFourPlusIntervals: 2,
            startedInMorning: true,
            startedInEvening: true,
            isWeekendWorkout: true,
            wasRaining: true,
            tookPhoto: true,
            isComeback: true,
            month: 1,
            finishedBaseProgram: true
        )
        let earned = Set(BadgeEvaluator.newlyEarned(context: context, alreadyEarned: []))
        XCTAssertEqual(earned, Set(Badge.allCases).subtracting([.summerRunner]))
    }

    func testStableOrdering() {
        let context = BadgeContext(totalCompletedWorkouts: 10, currentStreakWeeks: 3,
                                   maxRunIntervalsInOneRun: 5, totalRunIntervals: 25)
        let earned = BadgeEvaluator.newlyEarned(context: context, alreadyEarned: [])
        XCTAssertEqual(earned, earned.sorted { Badge.allCases.firstIndex(of: $0)! < Badge.allCases.firstIndex(of: $1)! })
    }
}
