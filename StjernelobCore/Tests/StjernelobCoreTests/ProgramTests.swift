import XCTest
@testable import StjernelobCore

/// Tests for programprogressionen: forløbets indhold, skalering efter ugens
/// træningsantal og den adaptive justering (jf. spec afsnit 6.1–6.2 og
/// `.claude/rules/test.md`).
final class ProgramTests: XCTestCase {

    // MARK: - Forløbets indhold

    func testBaseProgramHasEightWeeks() {
        XCTAssertEqual(StandardProgram.base.weeks.count, 8)
        XCTAssertTrue(StandardProgram.base.weeks.allSatisfy { $0.phase == .base })
    }

    func testJourneyContinuesPastBase() {
        let journey = StandardProgram.journey
        XCTAssertGreaterThan(journey.weeks.count, 8)
        XCTAssertEqual(journey.weeks.first?.phase, .base)
        XCTAssertEqual(journey.weeks.last?.phase, .beyond)
        // Globale id'er er fortløbende og 1-baserede.
        XCTAssertEqual(journey.weeks.map(\.id), Array(1...journey.weeks.count))
    }

    func testTitlesAreLocalizationKeysNotHardcodedText() {
        for week in StandardProgram.journey.weeks {
            XCTAssertTrue(week.titleKey.hasPrefix("program.week."),
                          "Titler skal være lokaliseringsnøgler, ikke brugertekst")
        }
    }

    // MARK: - Uge 1 struktur og skalering

    func testWeekOneStructure() {
        let week = StandardProgram.base.weeks[0]
        let plan = week.plan(forSessionsPerWeek: 1)   // 1 tur/uge → øvre ende = 8 reps
        XCTAssertEqual(plan.intervals.first?.kind, .warmUp)
        XCTAssertEqual(plan.intervals.first?.duration, .minutes(5))
        XCTAssertEqual(plan.intervals.last?.kind, .coolDown)
        XCTAssertEqual(plan.intervals.last?.duration, .minutes(5))
        XCTAssertEqual(plan.runIntervalCount, 8)
        // 1 opvarmning + 8×(løb+gå) + 1 nedkøling
        XCTAssertEqual(plan.intervals.count, 1 + 8 * 2 + 1)
        // Et løbeinterval er 1 minut, et gå-interval 2 minutter.
        XCTAssertEqual(plan.intervals[1], .run(.minutes(1)))
        XCTAssertEqual(plan.intervals[2], .walk(.minutes(2)))
    }

    func testFewerSessionsMeanMoreRepsPerSession() {
        let week = StandardProgram.base.weeks[0]   // reps 6...8
        XCTAssertEqual(week.plan(forSessionsPerWeek: 1).runIntervalCount, 8)
        XCTAssertEqual(week.plan(forSessionsPerWeek: 3).runIntervalCount, 7)
        XCTAssertEqual(week.plan(forSessionsPerWeek: 5).runIntervalCount, 6)
    }

    func testContinuousWeekScalesRunDuration() {
        let week8 = StandardProgram.base.weeks[7]
        let few = week8.plan(forSessionsPerWeek: 1)
        let many = week8.plan(forSessionsPerWeek: 5)
        XCTAssertEqual(few.intervals.count, 3)              // opvarmning, løb, nedkøling
        XCTAssertEqual(few.intervals[1], .run(.minutes(30)))  // 1 tur/uge → 30 min
        XCTAssertEqual(many.intervals[1], .run(.minutes(20))) // 5 ture/uge → 20 min
    }

    // MARK: - Adaptiv justering

    func testEasyWeekAdvances() {
        let outcomes = [
            SessionOutcome(wasCompleted: true, perceivedEffort: 4),
            SessionOutcome(wasCompleted: true, perceivedEffort: 5),
            SessionOutcome(wasCompleted: true, perceivedEffort: 3),
        ]
        XCTAssertEqual(ProgressionPolicy.decide(outcomes: outcomes), .advance)
    }

    func testTwoHardSessionsRepeatWeek() {
        let outcomes = [
            SessionOutcome(wasCompleted: true, perceivedEffort: 8),
            SessionOutcome(wasCompleted: true, perceivedEffort: 8),
            SessionOutcome(wasCompleted: true, perceivedEffort: 6),
        ]
        XCTAssertEqual(ProgressionPolicy.decide(outcomes: outcomes), .repeatWeek)
    }

    func testSkippedSessionsCountTowardRepeat() {
        let outcomes = [
            SessionOutcome(wasCompleted: false),
            SessionOutcome(wasCompleted: true, perceivedEffort: 8),
        ]
        XCTAssertEqual(ProgressionPolicy.decide(outcomes: outcomes), .repeatWeek)
    }

    func testVeryHardOrMostlyIncompleteStepsBack() {
        XCTAssertEqual(ProgressionPolicy.decide(outcomes: [
            SessionOutcome(wasCompleted: true, perceivedEffort: 9),
            SessionOutcome(wasCompleted: true, perceivedEffort: 10),
        ]), .stepBack)
        XCTAssertEqual(ProgressionPolicy.decide(outcomes: [
            SessionOutcome(wasCompleted: false),
            SessionOutcome(wasCompleted: false),
        ]), .stepBack)
    }

    func testNoOutcomesIsForgiving() {
        // En uge helt uden registrerede ture presser aldrig fremad.
        XCTAssertEqual(ProgressionPolicy.decide(outcomes: []), .repeatWeek)
    }

    // MARK: - Positionsmotor

    func testAdvanceRepeatStepBackBounds() {
        var engine = ProgressionEngine(program: StandardProgram.journey)
        XCTAssertEqual(engine.state.weekIndex, 0)

        engine.apply(.stepBack)                       // kan ikke gå under første uge
        XCTAssertEqual(engine.state.weekIndex, 0)

        engine.apply(.advance)
        XCTAssertEqual(engine.state.weekIndex, 1)
        engine.apply(.repeatWeek)
        XCTAssertEqual(engine.state.weekIndex, 1)
        engine.apply(.stepBack)
        XCTAssertEqual(engine.state.weekIndex, 0)
    }

    func testAdvanceStopsAtFinalWeek() {
        var engine = ProgressionEngine(program: StandardProgram.journey)
        for _ in 0..<100 { engine.apply(.advance) }
        XCTAssertEqual(engine.state.weekIndex, StandardProgram.journey.lastWeekIndex)
        XCTAssertTrue(engine.isOnFinalWeek)
    }

    func testCompleteWeekAppliesDecision() {
        var engine = ProgressionEngine(program: StandardProgram.journey)
        let decision = engine.completeWeek(outcomes: [
            SessionOutcome(wasCompleted: true, perceivedEffort: 4),
            SessionOutcome(wasCompleted: true, perceivedEffort: 5),
        ])
        XCTAssertEqual(decision, .advance)
        XCTAssertEqual(engine.state.weekIndex, 1)
    }

    // MARK: - Ugens ture (ekstra bliver til gå-ture)

    func testWeeklyPlansForModerateWeek() {
        let engine = ProgressionEngine(program: StandardProgram.journey)
        let plans = engine.weeklyPlans(forSessionsPerWeek: 3)
        XCTAssertEqual(plans.count, 3)
        XCTAssertTrue(plans.allSatisfy { $0.runIntervalCount > 0 })
    }

    func testExtraSessionsBecomeEasyWalks() {
        let engine = ProgressionEngine(program: StandardProgram.journey)
        let plans = engine.weeklyPlans(forSessionsPerWeek: 5)   // maks 4 løbeture
        XCTAssertEqual(plans.count, 5)
        let walkOnly = plans.filter { $0.runIntervalCount == 0 }
        XCTAssertEqual(walkOnly.count, 1)   // én ekstra blid gå-tur
    }
}
