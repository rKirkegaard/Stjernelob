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
        XCTAssertEqual(
            Stars.earned(for: summary),
            2
        ) // ingen bonus, men fulde stjerner for det gennemførte
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
        XCTAssertEqual(system.level(forPoints: 99999), 10) // klamper til max
    }

    func testLevelProgressFraction() {
        let system = LevelSystem.standard
        let progress = system.progress(forPoints: 42) // niveau 2 (25..60)
        XCTAssertEqual(progress.level, 2)
        XCTAssertEqual(progress.pointsIntoLevel, 17) // 42 - 25
        XCTAssertEqual(progress.pointsForLevel, 35) // 60 - 25
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

    func testFirstStepIsAnEarlyWin() {
        // Den allerførste loggede tur giver "Første skridt" og milepælen "1 tur".
        let context = BadgeContext(totalCompletedWorkouts: 1, currentStreakWeeks: 0)
        XCTAssertEqual(
            BadgeEvaluator.newlyEarned(context: context, alreadyEarned: []),
            [.firstStep, .runs1]
        )
    }

    func testBraveStarterNeedsAFullRun() {
        let aborted = BadgeContext(
            totalCompletedWorkouts: 1,
            currentStreakWeeks: 0,
            hasCompletedFullRun: false
        )
        XCTAssertFalse(Set(BadgeEvaluator.newlyEarned(context: aborted, alreadyEarned: []))
            .contains(.braveStarter))
        let full = BadgeContext(
            totalCompletedWorkouts: 1,
            currentStreakWeeks: 0,
            hasCompletedFullRun: true
        )
        XCTAssertTrue(Set(BadgeEvaluator.newlyEarned(context: full, alreadyEarned: []))
            .contains(.braveStarter))
    }

    func testSessionsPerWeekBadges() {
        func earned(sessions: Int) -> Set<Badge> {
            Set(BadgeEvaluator.newlyEarned(
                context: BadgeContext(
                    totalCompletedWorkouts: 0,
                    currentStreakWeeks: 0,
                    sessionsThisWeek: sessions
                ),
                alreadyEarned: []
            ))
        }
        XCTAssertEqual(earned(sessions: 2), [.twoInOneWeek])
        XCTAssertEqual(earned(sessions: 3), [.twoInOneWeek, .threeInOneWeek])
        XCTAssertFalse(earned(sessions: 1).contains(.twoInOneWeek))
    }

    func testStreakMilestones() {
        func earned(weeks: Int) -> Set<Badge> {
            Set(BadgeEvaluator.newlyEarned(
                context: BadgeContext(totalCompletedWorkouts: 0, currentStreakWeeks: weeks),
                alreadyEarned: []
            ))
        }
        XCTAssertEqual(earned(weeks: 1), [.oneWeekStreak])
        XCTAssertTrue(earned(weeks: 3).isSuperset(of: [.oneWeekStreak, .threeWeekStreak]))
        XCTAssertTrue(earned(weeks: 8).contains(.unbreakable))
        XCTAssertFalse(earned(weeks: 2).contains(.threeWeekStreak))
    }

    func testMonthHeroNeedsManyRunsInAMonth() {
        let few = BadgeContext(
            totalCompletedWorkouts: 7,
            currentStreakWeeks: 0,
            workoutsThisMonth: 7
        )
        XCTAssertFalse(Set(BadgeEvaluator.newlyEarned(context: few, alreadyEarned: []))
            .contains(.monthHero))
        let many = BadgeContext(
            totalCompletedWorkouts: 8,
            currentStreakWeeks: 0,
            workoutsThisMonth: 8
        )
        XCTAssertTrue(Set(BadgeEvaluator.newlyEarned(context: many, alreadyEarned: []))
            .contains(.monthHero))
    }

    func testSeasonBadgesAreMutuallyExclusive() {
        func season(month: Int) -> Set<Badge> {
            Set(BadgeEvaluator.newlyEarned(
                context: BadgeContext(
                    totalCompletedWorkouts: 0,
                    currentStreakWeeks: 0,
                    month: month
                ),
                alreadyEarned: []
            ))
        }
        XCTAssertEqual(season(month: 1), [.iceInBelly])
        XCTAssertEqual(season(month: 4), [.springAir])
        XCTAssertEqual(season(month: 7), [.sunshineRunner])
        XCTAssertEqual(season(month: 10), [.autumnRunner])
    }

    func testSpecialDayBadges() {
        func earned(month: Int, day: Int) -> Set<Badge> {
            Set(BadgeEvaluator.newlyEarned(
                context: BadgeContext(
                    totalCompletedWorkouts: 0,
                    currentStreakWeeks: 0,
                    month: month,
                    day: day
                ),
                alreadyEarned: []
            ))
        }
        XCTAssertTrue(earned(month: 12, day: 24).contains(.christmasRunner))
        XCTAssertTrue(earned(month: 1, day: 1).contains(.newYearStart))
        XCTAssertTrue(earned(month: 12, day: 31).contains(.newYearStart))
        XCTAssertFalse(earned(month: 1, day: 15).contains(.newYearStart))
    }

    func testTimeAndExperienceBadges() {
        let context = BadgeContext(
            totalCompletedWorkouts: 0, currentStreakWeeks: 0,
            hasCompletedHardRun: true, startedInMorning: true, startedInEvening: false,
            tookPhoto: true, isComeback: true
        )
        let earned = Set(BadgeEvaluator.newlyEarned(context: context, alreadyEarned: []))
        XCTAssertEqual(earned, [.neverGiveUp, .earlyBird, .momentPhoto, .backAgain])
    }

    func testManualBadgesAreNeverAutoAwarded() {
        // Selv en "alt opfyldt"-kontekst tildeler aldrig de manuelle mærker.
        let context = BadgeContext(
            totalCompletedWorkouts: 100, currentStreakWeeks: 52, sessionsThisWeek: 7,
            workoutsThisMonth: 30, hasCompletedFullRun: true, hasCompletedHardRun: true,
            startedInMorning: true, startedInEvening: true, tookPhoto: true,
            isComeback: true, month: 1, day: 1
        )
        let earned = Set(BadgeEvaluator.newlyEarned(context: context, alreadyEarned: []))
        XCTAssertTrue(earned.isDisjoint(with: Badge.allCases.filter(\.isManual)))
        // Alle ikke-manuelle mærker, der ikke afhænger af en anden årstid, er låst op.
        XCTAssertTrue(earned.contains(.firstStep))
        XCTAssertTrue(earned.contains(.unbreakable))
    }

    func testEveryAutomaticBadgeIsReachable() {
        // Hvert automatisk mærke skal kunne opfyldes af mindst én kontekst.
        let auto = Badge.allCases.filter { !$0.isManual }
        var reachable = Set<Badge>()
        // Saml på tværs af repræsentative kontekster (inkl. hver årstid/mærkedag).
        let contexts = [
            BadgeContext(
                totalCompletedWorkouts: 100,
                currentStreakWeeks: 8,
                sessionsThisWeek: 3,
                workoutsThisMonth: 8,
                hasCompletedFullRun: true,
                hasCompletedHardRun: true,
                startedInMorning: true,
                startedInEvening: true,
                tookPhoto: true,
                isComeback: true,
                month: 4,
                day: 15,
                totalRunIntervals: 1000,
                maxRunIntervalsInOneRun: 8,
                totalActiveWeeks: 52,
                totalStars: 1000
            ),
            BadgeContext(totalCompletedWorkouts: 1, currentStreakWeeks: 1, month: 7, day: 1),
            BadgeContext(totalCompletedWorkouts: 1, currentStreakWeeks: 1, month: 10, day: 1),
            BadgeContext(totalCompletedWorkouts: 1, currentStreakWeeks: 1, month: 12, day: 24),
            BadgeContext(totalCompletedWorkouts: 1, currentStreakWeeks: 1, month: 1, day: 1),
        ]
        for context in contexts {
            reachable.formUnion(BadgeEvaluator.newlyEarned(context: context, alreadyEarned: []))
        }
        XCTAssertEqual(reachable, Set(auto), "Alle automatiske mærker skal kunne nås")
    }

    func testAlreadyEarnedBadgesAreNotRepeated() {
        let context = BadgeContext(totalCompletedWorkouts: 1, currentStreakWeeks: 0)
        XCTAssertTrue(BadgeEvaluator.newlyEarned(
            context: context,
            alreadyEarned: [.firstStep, .runs1]
        ).isEmpty)
    }

    func testStableOrdering() {
        let context = BadgeContext(
            totalCompletedWorkouts: 1,
            currentStreakWeeks: 3,
            sessionsThisWeek: 3
        )
        let earned = BadgeEvaluator.newlyEarned(context: context, alreadyEarned: [])
        XCTAssertEqual(
            earned,
            earned
                .sorted { Badge.allCases.firstIndex(of: $0)! < Badge.allCases.firstIndex(of: $1)! }
        )
    }

    // MARK: - Importerede milepæls-mærker

    private func earnedMilestones(_ context: BadgeContext) -> Set<Badge> {
        Set(BadgeEvaluator.newlyEarned(context: context, alreadyEarned: []))
    }

    func testTotalIntervalMilestones() {
        let at25 = earnedMilestones(BadgeContext(
            totalCompletedWorkouts: 0,
            currentStreakWeeks: 0,
            totalRunIntervals: 25
        ))
        XCTAssertTrue(at25.isSuperset(of: [.interval5, .interval10, .interval25]))
        XCTAssertFalse(at25.contains(.interval50))
    }

    func testIntervalsInOneSessionMilestones() {
        let at8 = earnedMilestones(BadgeContext(
            totalCompletedWorkouts: 0,
            currentStreakWeeks: 0,
            maxRunIntervalsInOneRun: 8
        ))
        XCTAssertTrue(at8.isSuperset(of: [
            .sessionFourIntervals,
            .sessionSixIntervals,
            .sessionEightIntervals,
        ]))
    }

    func testTotalRunMilestones() {
        let at10 = earnedMilestones(BadgeContext(totalCompletedWorkouts: 10, currentStreakWeeks: 0))
        XCTAssertTrue(at10.isSuperset(of: [.runs1, .runs3, .runs5, .runs10]))
        XCTAssertFalse(at10.contains(.runs15))
    }

    func testActiveWeekMilestones() {
        let at4 = earnedMilestones(BadgeContext(
            totalCompletedWorkouts: 0,
            currentStreakWeeks: 0,
            totalActiveWeeks: 4
        ))
        XCTAssertTrue(at4.isSuperset(of: [.activeWeeks1, .activeWeeks2, .activeWeeks4]))
        XCTAssertFalse(at4.contains(.activeWeeks6))
    }

    func testStarMilestones() {
        let at100 = earnedMilestones(BadgeContext(
            totalCompletedWorkouts: 0,
            currentStreakWeeks: 0,
            totalStars: 100
        ))
        XCTAssertTrue(at100.isSuperset(of: [.stars10, .stars25, .stars50, .stars100]))
        XCTAssertFalse(at100.contains(.stars250))
    }

    func testSecretMilestonesAreFlagged() {
        XCTAssertTrue(Badge.activeWeeks52.isSecret)
        XCTAssertTrue(Badge.stars1000.isSecret)
        XCTAssertTrue(Badge.interval1000.isSecret)
        XCTAssertTrue(Badge.runs100.isSecret)
        XCTAssertFalse(Badge.firstStep.isSecret)
        XCTAssertFalse(Badge.runs50.isSecret)
        XCTAssertFalse(Badge.interval15.isSecret)
    }

    func testMilestonesAreAutomatic() {
        // Ingen milepæl er manuel — de tildeles ud fra historikken.
        let milestones: [Badge] = [
            .interval5,
            .runs1,
            .activeWeeks1,
            .stars10,
            .sessionFourIntervals,
        ]
        XCTAssertTrue(milestones.allSatisfy { !$0.isManual })
    }
}
