import XCTest
@testable import StjernelobCore

/// Tests for stjerner, point/niveauer og badges (jf. spec afsnit 5.1, 5.2, 5.4).
/// Belønning gives for gennemførsel — aldrig fart eller distance.
final class GamificationTests: XCTestCase {
    /// Slå et badge op på dets slug (testhjælper).
    private func badge(_ slug: String) -> Badge {
        guard let badge = Badge(slug: slug) else {
            fatalError("Ukendt badge-slug i test: \(slug)")
        }
        return badge
    }

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
            [badge("første-skridt"), badge("tur-1")]
        )
    }

    func testBraveStarterNeedsAFullRun() {
        let aborted = BadgeContext(
            totalCompletedWorkouts: 1,
            currentStreakWeeks: 0,
            hasCompletedFullRun: false
        )
        XCTAssertFalse(Set(BadgeEvaluator.newlyEarned(context: aborted, alreadyEarned: []))
            .contains(badge("modig-starter")))
        let full = BadgeContext(
            totalCompletedWorkouts: 1,
            currentStreakWeeks: 0,
            hasCompletedFullRun: true
        )
        XCTAssertTrue(Set(BadgeEvaluator.newlyEarned(context: full, alreadyEarned: []))
            .contains(badge("modig-starter")))
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
        XCTAssertEqual(earned(sessions: 2), [badge("2-i-en-uge")])
        XCTAssertEqual(earned(sessions: 3), [badge("2-i-en-uge"), badge("3-i-en-uge")])
        XCTAssertFalse(earned(sessions: 1).contains(badge("2-i-en-uge")))
    }

    func testStreakMilestones() {
        func earned(weeks: Int) -> Set<Badge> {
            Set(BadgeEvaluator.newlyEarned(
                context: BadgeContext(totalCompletedWorkouts: 0, currentStreakWeeks: weeks),
                alreadyEarned: []
            ))
        }
        XCTAssertEqual(earned(weeks: 1), [badge("en-uge-i-traek")])
        XCTAssertTrue(earned(weeks: 3).isSuperset(of: [
            badge("en-uge-i-traek"),
            badge("3-ugers-streak"),
        ]))
        XCTAssertTrue(earned(weeks: 8).contains(badge("ubrydelig")))
        XCTAssertFalse(earned(weeks: 2).contains(badge("3-ugers-streak")))
    }

    func testMonthHeroNeedsManyRunsInAMonth() {
        let few = BadgeContext(
            totalCompletedWorkouts: 7,
            currentStreakWeeks: 0,
            workoutsThisMonth: 7
        )
        XCTAssertFalse(Set(BadgeEvaluator.newlyEarned(context: few, alreadyEarned: []))
            .contains(badge("maanedshelt")))
        let many = BadgeContext(
            totalCompletedWorkouts: 8,
            currentStreakWeeks: 0,
            workoutsThisMonth: 8
        )
        XCTAssertTrue(Set(BadgeEvaluator.newlyEarned(context: many, alreadyEarned: []))
            .contains(badge("maanedshelt")))
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
        XCTAssertEqual(season(month: 1), [badge("is-i-maven")])
        XCTAssertEqual(season(month: 4), [badge("foraarsluft")])
        XCTAssertEqual(season(month: 7), [badge("solskinsloeber")])
        XCTAssertEqual(season(month: 10), [badge("efteraarsloeber")])
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
        XCTAssertTrue(earned(month: 12, day: 24).contains(badge("juleloeber")))
        XCTAssertTrue(earned(month: 1, day: 1).contains(badge("nytaarsstart")))
        XCTAssertTrue(earned(month: 12, day: 31).contains(badge("nytaarsstart")))
        XCTAssertFalse(earned(month: 1, day: 15).contains(badge("nytaarsstart")))
    }

    func testTimeAndExperienceBadges() {
        let context = BadgeContext(
            totalCompletedWorkouts: 0, currentStreakWeeks: 0,
            hasCompletedHardRun: true, startedInMorning: true, startedInEvening: false,
            tookPhoto: true, isComeback: true
        )
        let earned = Set(BadgeEvaluator.newlyEarned(context: context, alreadyEarned: []))
        XCTAssertEqual(earned, [
            badge("aldrig-give-op"), badge("tidlig-fugl"), badge("tur-foto"), badge("tilbage-igen"),
        ])
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
        XCTAssertTrue(earned.isDisjoint(with: Badge.all.filter(\.isManual)))
        // Alle ikke-manuelle mærker, der ikke afhænger af en anden årstid, er låst op.
        XCTAssertTrue(earned.contains(badge("første-skridt")))
        XCTAssertTrue(earned.contains(badge("ubrydelig")))
    }

    func testEveryAutomaticBadgeIsReachable() {
        // Hvert automatisk mærke skal kunne opfyldes af mindst én kontekst.
        let auto = Badge.all.filter { !$0.isManual }
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
                totalStars: 1000,
                didStretchAfterRun: true,
                didDrinkWaterBeforeAndAfter: true,
                longestContinuousRunMinutes: 30
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
            alreadyEarned: [badge("første-skridt"), badge("tur-1")]
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
                .sorted { Badge.all.firstIndex(of: $0)! < Badge.all.firstIndex(of: $1)! }
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
        XCTAssertTrue(at25.isSuperset(of: [
            badge("interval-5"),
            badge("interval-10"),
            badge("interval-25"),
        ]))
        XCTAssertFalse(at25.contains(badge("interval-50")))
    }

    func testIntervalsInOneSessionMilestones() {
        let at8 = earnedMilestones(BadgeContext(
            totalCompletedWorkouts: 0,
            currentStreakWeeks: 0,
            maxRunIntervalsInOneRun: 8
        ))
        XCTAssertTrue(at8.isSuperset(of: [
            badge("session-4-intervaller"),
            badge("session-6-intervaller"),
            badge("session-8-intervaller"),
        ]))
    }

    func testTotalRunMilestones() {
        let at10 = earnedMilestones(BadgeContext(totalCompletedWorkouts: 10, currentStreakWeeks: 0))
        XCTAssertTrue(at10.isSuperset(of: [
            badge("tur-1"),
            badge("tur-3"),
            badge("tur-5"),
            badge("tur-10"),
        ]))
        XCTAssertFalse(at10.contains(badge("tur-15")))
    }

    func testActiveWeekMilestones() {
        let at4 = earnedMilestones(BadgeContext(
            totalCompletedWorkouts: 0,
            currentStreakWeeks: 0,
            totalActiveWeeks: 4
        ))
        XCTAssertTrue(at4.isSuperset(of: [
            badge("aktiv-uge-1"),
            badge("aktiv-uge-2"),
            badge("aktiv-uge-4"),
        ]))
        XCTAssertFalse(at4.contains(badge("aktiv-uge-6")))
    }

    func testStarMilestones() {
        let at100 = earnedMilestones(BadgeContext(
            totalCompletedWorkouts: 0,
            currentStreakWeeks: 0,
            totalStars: 100
        ))
        XCTAssertTrue(at100.isSuperset(of: [
            badge("stjerner-10"), badge("stjerner-25"), badge("stjerner-50"), badge("stjerner-100"),
        ]))
        XCTAssertFalse(at100.contains(badge("stjerner-250")))
    }

    func testEveryCategoryHasBadges() {
        for category in BadgeCategory.allCases {
            XCTAssertFalse(
                Badge.all.filter { $0.category == category }.isEmpty,
                "Kategorien \(category) mangler badges"
            )
        }
    }

    func testSecretMilestonesAreFlagged() {
        XCTAssertTrue(badge("aktiv-uge-52").isSecret)
        XCTAssertTrue(badge("stjerner-1000").isSecret)
        XCTAssertTrue(badge("interval-1000").isSecret)
        XCTAssertTrue(badge("tur-100").isSecret)
        XCTAssertFalse(badge("første-skridt").isSecret)
        XCTAssertFalse(badge("tur-50").isSecret)
        XCTAssertFalse(badge("interval-15").isSecret)
    }

    func testMilestonesAreAutomatic() {
        // Ingen milepæl er manuel — de tildeles ud fra historikken.
        let milestones = [
            badge("interval-5"),
            badge("tur-1"),
            badge("aktiv-uge-1"),
            badge("stjerner-10"),
            badge("session-4-intervaller"),
        ]
        XCTAssertTrue(milestones.allSatisfy { !$0.isManual })
    }

    // MARK: - Vane- og sammenhængende-løb-mærker (automatiske)

    func testStretchAndWaterAreAutomaticNow() {
        // Stræk-stjerne og vand-dronning tildeles ud fra et lille ja efter turen.
        XCTAssertFalse(badge("straek-stjerne").isManual)
        XCTAssertFalse(badge("vand-dronning").isManual)

        let stretched = BadgeContext(
            totalCompletedWorkouts: 1,
            currentStreakWeeks: 0,
            didStretchAfterRun: true
        )
        XCTAssertTrue(earnedMilestones(stretched).contains(badge("straek-stjerne")))
        XCTAssertFalse(earnedMilestones(stretched).contains(badge("vand-dronning")))

        let drank = BadgeContext(
            totalCompletedWorkouts: 1,
            currentStreakWeeks: 0,
            didDrinkWaterBeforeAndAfter: true
        )
        XCTAssertTrue(earnedMilestones(drank).contains(badge("vand-dronning")))
        XCTAssertFalse(earnedMilestones(drank).contains(badge("straek-stjerne")))
    }

    func testStretchAndWaterNotAwardedWithoutTheLittleYes() {
        // Uden et ja gives ingen af vane-mærkerne — aldrig pres, aldrig som krav.
        let none = BadgeContext(totalCompletedWorkouts: 5, currentStreakWeeks: 2)
        let earned = earnedMilestones(none)
        XCTAssertFalse(earned.contains(badge("straek-stjerne")))
        XCTAssertFalse(earned.contains(badge("vand-dronning")))
    }

    func testContinuousRunMilestones() {
        func earned(minutes: Int) -> Set<Badge> {
            earnedMilestones(BadgeContext(
                totalCompletedWorkouts: 1,
                currentStreakWeeks: 0,
                longestContinuousRunMinutes: minutes
            ))
        }
        let ladder = [
            badge("uafbrudt-5"), badge("uafbrudt-10"), badge("uafbrudt-20"), badge("uafbrudt-30"),
        ]
        XCTAssertFalse(earned(minutes: 4).contains(badge("uafbrudt-5")))
        XCTAssertEqual(earned(minutes: 5).intersection(Set(ladder)), [badge("uafbrudt-5")])
        XCTAssertTrue(earned(minutes: 20).isSuperset(of: [
            badge("uafbrudt-5"), badge("uafbrudt-10"), badge("uafbrudt-20"),
        ]))
        XCTAssertFalse(earned(minutes: 20).contains(badge("uafbrudt-30")))
        XCTAssertTrue(earned(minutes: 30).contains(badge("uafbrudt-30")))
    }

    // MARK: - Katalog-integritet

    func testCatalogueHasNoDuplicateSlugs() {
        let slugs = BadgeCatalogue.all.map(\.slug)
        XCTAssertEqual(slugs.count, Set(slugs).count, "Dobbelte slugs i kataloget")
    }

    func testEverySlugRoundTripsThroughBadge() {
        for definition in BadgeCatalogue.all {
            XCTAssertNotNil(
                Badge(rawValue: definition.slug),
                "Slug kan ikke slås op: \(definition.slug)"
            )
        }
        XCTAssertNil(Badge(rawValue: "findes-ikke"))
    }
}
