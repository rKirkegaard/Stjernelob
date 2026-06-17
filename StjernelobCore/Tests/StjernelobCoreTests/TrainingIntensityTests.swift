import XCTest
@testable import StjernelobCore

/// Tests for den selvvalgte sværhedsgrad. Skalerer tid (løb/gå) — aldrig fart.
final class TrainingIntensityTests: XCTestCase {
    private func plan() -> WorkoutPlan {
        WorkoutPlan(intervals: [
            .warmUp(.minutes(3)),
            .run(.seconds(100)),
            .walk(.seconds(60)),
            .coolDown(.minutes(3)),
        ])
    }

    func testStandardLeavesPlanUnchanged() {
        XCTAssertEqual(TrainingIntensity.standard.scaled(plan()), plan())
    }

    func testHarderLengthensRunAndShortensWalk() {
        let scaled = TrainingIntensity.harder.scaled(plan())
        XCTAssertEqual(scaled.intervals[1].duration, .seconds(120)) // 100 * 1.2
        XCTAssertEqual(scaled.intervals[2].duration, .seconds(51)) // 60 * 0.85
    }

    func testLighterShortensRunAndLengthensWalk() {
        let scaled = TrainingIntensity.lighter.scaled(plan())
        XCTAssertEqual(scaled.intervals[1].duration, .seconds(80)) // 100 * 0.8
        XCTAssertEqual(scaled.intervals[2].duration, .seconds(72)) // 60 * 1.2
    }

    func testWarmUpAndCoolDownAreNeverScaled() {
        for intensity in TrainingIntensity.allCases {
            let scaled = intensity.scaled(plan())
            XCTAssertEqual(scaled.intervals.first?.kind, .warmUp)
            XCTAssertEqual(scaled.intervals.first?.duration, .minutes(3))
            XCTAssertEqual(scaled.intervals.last?.kind, .coolDown)
            XCTAssertEqual(scaled.intervals.last?.duration, .minutes(3))
        }
    }

    func testFloorsKeepIntervalsMeaningful() {
        // Selv et meget kort løb/pause forkortet voldsomt holder et gulv.
        let tiny = WorkoutPlan(intervals: [
            .warmUp(.minutes(1)),
            .run(.seconds(8)),
            .walk(.seconds(10)),
            .coolDown(.minutes(1)),
        ])
        let lighterRun = TrainingIntensity.lighter.scaled(tiny) // løb forkortes
        XCTAssertGreaterThanOrEqual(lighterRun.intervals[1].duration, .seconds(10))
        let harderWalk = TrainingIntensity.harder.scaled(tiny) // pause forkortes
        XCTAssertGreaterThanOrEqual(harderWalk.intervals[2].duration, .seconds(15))
    }
}
