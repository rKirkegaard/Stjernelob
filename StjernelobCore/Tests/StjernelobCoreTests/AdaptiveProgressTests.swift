import XCTest
@testable import StjernelobCore

/// Tests for den idempotente, historik-baserede progression (docs/loebeplan.md).
/// Sikkerhedskritisk: forkert progression ville give en begynder for hårde ture.
final class AdaptiveProgressTests: XCTestCase {
    private let program = StandardProgram.journey
    private func required(_ n: Int) -> (ProgramWeek) -> Int { { _ in n } }
    private func week(_ year: Int, _ number: Int) -> WeekIdentifier {
        WeekIdentifier(yearForWeekOfYear: year, weekOfYear: number)
    }

    func testNoHistoryStaysAtStart() {
        let result = AdaptiveProgress.evaluate(
            program: program, completedByWeek: [:],
            currentWeek: week(2026, 10), requiredSessions: required(3)
        )
        XCTAssertEqual(result.weekIndex, 0)
        XCTAssertEqual(result.consecutiveMissedWeeks, 0)
        XCTAssertEqual(result.completedThisWeek, 0)
    }

    func testCompletedWeeksAdvanceOnePerWeek() {
        let completed = [week(2026, 1): 3, week(2026, 2): 3, week(2026, 3): 3]
        let result = AdaptiveProgress.evaluate(
            program: program, completedByWeek: completed,
            currentWeek: week(2026, 4), requiredSessions: required(3)
        )
        XCTAssertEqual(result.weekIndex, 3)
        XCTAssertEqual(result.consecutiveMissedWeeks, 0)
    }

    func testCurrentWeekCompletionAdvancesImmediately() {
        let completed = [week(2026, 4): 3]
        let result = AdaptiveProgress.evaluate(
            program: program, completedByWeek: completed,
            currentWeek: week(2026, 4), requiredSessions: required(3)
        )
        XCTAssertEqual(result.weekIndex, 1)
        XCTAssertEqual(result.completedThisWeek, 3)
    }

    func testUnderThresholdWeekRepeats() {
        // Uge 1 gennemført → idx1; uge 2 kun 1 tur (under tærsklen) → bliver på idx1.
        let completed = [week(2026, 1): 3, week(2026, 2): 1]
        let result = AdaptiveProgress.evaluate(
            program: program, completedByWeek: completed,
            currentWeek: week(2026, 3), requiredSessions: required(3)
        )
        XCTAssertEqual(result.weekIndex, 1)
    }

    func testMissedWeekStepsBackOne() {
        let completed = [week(2026, 1): 3, week(2026, 2): 3, week(2026, 3): 3]  // uge 4 helt misset
        let result = AdaptiveProgress.evaluate(
            program: program, completedByWeek: completed,
            currentWeek: week(2026, 5), requiredSessions: required(3)
        )
        XCTAssertEqual(result.weekIndex, 2)
        XCTAssertEqual(result.consecutiveMissedWeeks, 1)
    }

    func testTwoMissedWeeksStepBackTwo() {
        let completed = [week(2026, 1): 3, week(2026, 2): 3, week(2026, 3): 3]  // uge 4 og 5 misset
        let result = AdaptiveProgress.evaluate(
            program: program, completedByWeek: completed,
            currentWeek: week(2026, 6), requiredSessions: required(3)
        )
        XCTAssertEqual(result.weekIndex, 0)
        XCTAssertEqual(result.consecutiveMissedWeeks, 2)
    }

    func testThreeMissedWeeksRestartCurrentPhase() {
        // Ti gennemførte uger → idx 10 (fase "maintain" begynder ved idx 8).
        var completed: [WeekIdentifier: Int] = [:]
        for number in 1...10 { completed[week(2026, number)] = 3 }
        // Uge 11, 12, 13 helt misset; indeværende uge 14 tom.
        let result = AdaptiveProgress.evaluate(
            program: program, completedByWeek: completed,
            currentWeek: week(2026, 14), requiredSessions: required(3)
        )
        XCTAssertEqual(result.consecutiveMissedWeeks, 3)
        // Aldrig under fasens start, og aldrig under programmets start.
        XCTAssertGreaterThanOrEqual(result.weekIndex, 0)
        XCTAssertLessThan(result.weekIndex, 10)
    }

    func testHardWeekStaysInsteadOfAdvancing() {
        // Uge 1 gennemført, men markeret som for hård → bliv på ugen (idx 0).
        let completed = [week(2026, 1): 3]
        let hard: (WeekIdentifier) -> Bool = { $0 == self.week(2026, 1) }
        let result = AdaptiveProgress.evaluate(
            program: program, completedByWeek: completed,
            currentWeek: week(2026, 1), requiredSessions: required(3),
            weekFeltTooHard: hard
        )
        XCTAssertEqual(result.weekIndex, 0)
        XCTAssertEqual(result.completedThisWeek, 3)
    }

    func testHardClosedWeekDoesNotAdvance() {
        // Uge 1 gennemført men hård → ingen fremgang; uge 2 gennemført og fin → +1.
        let completed = [week(2026, 1): 3, week(2026, 2): 3]
        let hard: (WeekIdentifier) -> Bool = { $0 == self.week(2026, 1) }
        let result = AdaptiveProgress.evaluate(
            program: program, completedByWeek: completed,
            currentWeek: week(2026, 3), requiredSessions: required(3),
            weekFeltTooHard: hard
        )
        XCTAssertEqual(result.weekIndex, 1)
    }

    func testIdempotentRecomputation() {
        // Samme historik → samme resultat, uanset hvor mange gange den køres.
        let completed = [week(2026, 1): 3, week(2026, 2): 2, week(2026, 3): 3]
        let first = AdaptiveProgress.evaluate(
            program: program, completedByWeek: completed,
            currentWeek: week(2026, 4), requiredSessions: required(3)
        )
        let second = AdaptiveProgress.evaluate(
            program: program, completedByWeek: completed,
            currentWeek: week(2026, 4), requiredSessions: required(3)
        )
        XCTAssertEqual(first, second)
    }
}
