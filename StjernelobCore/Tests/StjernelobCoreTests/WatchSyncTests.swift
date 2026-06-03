import XCTest
@testable import StjernelobCore

/// Tests for at telefon↔ur-beskederne kan kodes og afkodes uændret.
final class WatchSyncTests: XCTestCase {
    func testSessionPayloadRoundTrips() throws {
        let plan = StandardProgram.base.weeks[0].plan(forSessionsPerWeek: 3)
        let payload = WatchSessionPayload(plan: plan, programWeekId: 1, programPhase: .base)
        let data = try JSONEncoder().encode(payload)
        let decoded = try JSONDecoder().decode(WatchSessionPayload.self, from: data)
        XCTAssertEqual(decoded, payload)
        XCTAssertEqual(decoded.plan.runIntervalCount, plan.runIntervalCount)
    }

    func testCompletionPayloadRoundTrips() throws {
        let payload = WatchCompletionPayload(
            programWeekId: 2, programPhase: .base, activeSeconds: 1200,
            intervalsCompleted: 12, plannedIntervalCount: 14,
            runIntervalsCompleted: 6, isComplete: true
        )
        let data = try JSONEncoder().encode(payload)
        XCTAssertEqual(try JSONDecoder().decode(WatchCompletionPayload.self, from: data), payload)
    }
}
