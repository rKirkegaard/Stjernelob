import XCTest
@testable import StjernelobCore

/// Tests for det 20-ugers program (docs/loebeplan.md) og dets projektion ind i
/// forløbs-modellen. Planen er sikkerhedskritisk: forkerte interval-tal ville
/// give en begynder en for hård tur.
final class CouchToRunnerPlanTests: XCTestCase {
    func testHasTwentyWeeks() {
        XCTAssertEqual(CouchToRunnerPlan.totalWeeks, 20)
        XCTAssertEqual(CouchToRunnerPlan.weeks.count, 20)
        XCTAssertEqual(CouchToRunnerPlan.weeks.map(\.id), Array(1...20))
    }

    func testEveryWeekHasAtLeastTwoRequiredSessions() {
        for week in CouchToRunnerPlan.weeks {
            XCTAssertGreaterThanOrEqual(
                week.requiredSessionCount,
                2,
                "Uge \(week.id) skal have mindst 2 krævede ture"
            )
        }
    }

    func testWeekOneIsAGentleStart() throws {
        let week = try XCTUnwrap(CouchToRunnerPlan.week(id: 1))
        let session = week.sessions[0]
        XCTAssertEqual(session.warmUp, .minutes(3))
        XCTAssertEqual(
            session.blocks,
            [IntervalBlock(run: .seconds(20), walk: .seconds(90), reps: 4)]
        )
        XCTAssertEqual(session.coolDown, .minutes(3))
    }

    func testFinalWeekReachesThirtyMinutesContinuous() throws {
        let week = try XCTUnwrap(CouchToRunnerPlan.week(id: 20))
        // En af de sidste ture er 30 min sammenhængende løb (1800 sek, ingen gang).
        let hasContinuousThirty = week.sessions.contains { session in
            session.blocks.contains { $0.run == .seconds(1800) && $0.walk == .zero && $0.reps == 1 }
        }
        XCTAssertTrue(hasContinuousThirty, "Uge 20 skal nå 30 min sammenhængende løb")
    }

    func testRunDurationGrowsAcrossPhases() {
        func longestRun(weekId: Int) -> Duration {
            let week = CouchToRunnerPlan.week(id: weekId)!
            return week.sessions.flatMap(\.blocks).map(\.run).max() ?? .zero
        }
        // Det længste løb må aldrig falde over tid (blid, voksende progression).
        XCTAssertLessThan(longestRun(weekId: 1), longestRun(weekId: 5))
        XCTAssertLessThan(longestRun(weekId: 5), longestRun(weekId: 11))
        XCTAssertLessThan(longestRun(weekId: 11), longestRun(weekId: 18))
    }

    func testWeekBadgesResolveToRealBadges() {
        // Hver uge-badge i planen peger på et rigtigt Badge.
        for week in CouchToRunnerPlan.weeks {
            XCTAssertNotNil(week.badge, "Uge \(week.id) mangler et gyldigt badge")
        }
    }

    func testSessionBuildsExpectedWorkoutPlan() throws {
        let week = try XCTUnwrap(CouchToRunnerPlan.week(id: 1))
        let plan = week.sessions[0].workoutPlan()
        // opvarmning + 4 × (løb + gang) + nedkøling = 1 + 8 + 1 = 10 intervaller.
        XCTAssertEqual(plan.intervals.count, 10)
        XCTAssertEqual(plan.intervals.first?.kind, .warmUp)
        XCTAssertEqual(plan.intervals.last?.kind, .coolDown)
        XCTAssertEqual(plan.intervals.filter { $0.kind == .run }.count, 4)
    }

    func testContinuousBlockHasNoWalk() {
        // En blok med 1 rep og ingen gang giver netop ét løb (intet trailing gang).
        let plan = SessionTemplate.blocks(
            warmUp: .minutes(3),
            blocks: [IntervalBlock(run: .seconds(1800), walk: .zero, reps: 1)],
            coolDown: .minutes(5)
        ).plan(forSessionsPerWeek: 3)
        XCTAssertEqual(plan.intervals.map(\.kind), [.warmUp, .run, .coolDown])
    }

    // MARK: - Projektion ind i forløbs-modellen

    func testStandardProgramHasTwentyWeeks() {
        XCTAssertEqual(StandardProgram.journey.weeks.count, 20)
    }

    func testBaseProgramCoversFirstEightWeeks() {
        let base = StandardProgram.base
        XCTAssertEqual(base.weeks.count, 8)
        XCTAssertEqual(base.weeks.map(\.id), Array(1...8))
    }
}
