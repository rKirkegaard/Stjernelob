import XCTest
@testable import StjernelobCore

/// Tests for "en træning er data": egne ture, JSON-import og den blide validator.
final class AuthoringTests: XCTestCase {
    // MARK: - Byg en kørbar plan af en tur

    func testTimeBasedPlanAddsWarmUpAndCoolDown() throws {
        let workout = Workout(name: "Min tur", steps: [
            .run(.minutes(1)), .walk(.minutes(2)),
        ])
        let plan = try XCTUnwrap(workout.timeBasedPlan())
        XCTAssertEqual(plan.intervals.first?.kind, .warmUp)
        XCTAssertEqual(plan.intervals.last?.kind, .coolDown)
        XCTAssertEqual(plan.intervals.map(\.kind), [.warmUp, .run, .walk, .coolDown])
    }

    func testTimeBasedPlanKeepsExistingWarmUpAndCoolDown() throws {
        let workout = Workout(name: "Med egen opvarmning", steps: [
            .init(kind: .warmUp, measure: .time(.minutes(3))),
            .run(.minutes(1)),
            .init(kind: .coolDown, measure: .time(.minutes(3))),
        ])
        let plan = try XCTUnwrap(workout.timeBasedPlan())
        XCTAssertEqual(plan.intervals.count, 3) // ingen ekstra tilføjet
        XCTAssertEqual(plan.intervals.first?.duration, .minutes(3))
    }

    func testEmptyWorkoutHasNoRunnablePlan() {
        XCTAssertNil(Workout(name: "Tom", steps: []).timeBasedPlan())
    }

    func testDistanceOnlyWorkoutIsNotRunnableYet() {
        let workout = Workout(name: "Distance", steps: [
            .init(kind: .run, measure: .distance(1000)),
        ])
        XCTAssertNil(workout.timeBasedPlan())
    }

    func testBlocksExpandRepeats() {
        let blocks = [WorkoutBlock(steps: [.run(.minutes(1)), .walk(.minutes(2))], repeats: 3)]
        XCTAssertEqual(blocks.expandedSteps().count, 6)
        XCTAssertEqual(blocks.expandedSteps().filter { $0.kind == .run }.count, 3)
    }

    // MARK: - JSON-import

    private func planJSON() -> Data {
        let json = """
        {
          "navn": "8-ugers begynder",
          "version": 1,
          "uger": [
            { "uge": 1, "ture": [
              { "blokke": [ {"type":"loeb","sek":60}, {"type":"gaa","sek":120} ], "gentag": 6 }
            ] },
            { "uge": 2, "ture": [
              { "blokke": [ {"type":"loeb","sek":90}, {"type":"gaa","sek":90} ], "gentag": 6 }
            ] }
          ]
        }
        """
        return Data(json.utf8)
    }

    func testImportDecodesPlan() throws {
        let plan = try TrainingPlanImporter.decode(planJSON())
        XCTAssertEqual(plan.source, .imported)
        XCTAssertEqual(plan.name, "8-ugers begynder")
        XCTAssertEqual(plan.weekNumbers, [1, 2])
        let week1 = try XCTUnwrap(plan.workouts(inWeek: 1).first)
        // 6 gentagelser af (løb + gå) = 12 trin.
        XCTAssertEqual(week1.steps.count, 12)
        XCTAssertEqual(week1.runIntervalCount, 6)
        // Bygger en kørbar plan med auto opvarmning/nedkøling.
        let runnable = try XCTUnwrap(week1.timeBasedPlan())
        XCTAssertEqual(runnable.intervals.first?.kind, .warmUp)
    }

    func testImportIgnoresUnknownFieldsRobustly() throws {
        let json = """
        { "navn": "X", "version": 99, "ekstra": "ignoreres",
          "uger": [ { "uge": 1, "note": "hej", "ture": [
            { "blokke": [ {"type":"loeb","sek":30,"farve":"blå"} ], "gentag": 2 } ] } ] }
        """
        let plan = try TrainingPlanImporter.decode(Data(json.utf8))
        XCTAssertEqual(plan.workouts(inWeek: 1).first?.steps.count, 2)
    }

    func testImportRejectsInvalidFile() {
        XCTAssertThrowsError(try TrainingPlanImporter.decode(Data("ikke json".utf8))) {
            XCTAssertEqual($0 as? PlanImportError, .unreadable)
        }
    }

    func testImportRejectsEmptyPlan() {
        let json = #"{ "navn": "Tom", "version": 1, "uger": [] }"#
        XCTAssertThrowsError(try TrainingPlanImporter.decode(Data(json.utf8))) {
            XCTAssertEqual($0 as? PlanImportError, .empty)
        }
    }

    // MARK: - Validator (nudge, blokerer ikke)

    private func plan(weeklyRunMinutes: [Int], sessionsPerWeek: Int = 3) -> TrainingPlan {
        var schedule: [ScheduledWorkout] = []
        for (index, minutes) in weeklyRunMinutes.enumerated() {
            let week = index + 1
            // Fordel løbetiden på `sessionsPerWeek` ens ture.
            let perSession = Double(minutes) / Double(sessionsPerWeek)
            for session in 0..<sessionsPerWeek {
                let workout = Workout(
                    name: "Uge \(week) Tur \(session + 1)",
                    steps: [.run(.seconds(perSession * 60))]
                )
                schedule.append(ScheduledWorkout(week: week, workout: workout))
            }
        }
        return TrainingPlan(name: "Test", source: .imported, schedule: schedule)
    }

    func testGentlePlanHasNoConcerns() {
        // Stiger blidt (~10 %), 3 ture/uge.
        let validation = PlanValidator.review(
            plan: plan(weeklyRunMinutes: [18, 20, 22]),
            currentWeeklyRunSeconds: 18 * 60
        )
        XCTAssertTrue(validation.isGentle)
    }

    func testBigJumpFromCurrentLevelIsFlagged() {
        let validation = PlanValidator.review(
            plan: plan(weeklyRunMinutes: [40]),
            currentWeeklyRunSeconds: 10 * 60 // hun løber kun 10 min/uge nu
        )
        XCTAssertTrue(validation.concerns.contains(.bigJumpFromCurrentLevel))
    }

    func testFastWeeklyIncreaseIsFlagged() {
        let validation = PlanValidator.review(plan: plan(weeklyRunMinutes: [20, 40]))
        XCTAssertTrue(validation.concerns.contains(.fastWeeklyIncrease))
    }

    func testTooFewRestDaysIsFlagged() {
        let validation = PlanValidator.review(plan: plan(
            weeklyRunMinutes: [30],
            sessionsPerWeek: 7
        ))
        XCTAssertTrue(validation.concerns.contains(.tooFewRestDays))
    }

    func testVeryLongWorkoutIsFlagged() {
        let long = TrainingPlan(name: "Lang", source: .imported, schedule: [
            ScheduledWorkout(week: 1, workout: Workout(name: "Maraton-agtig", steps: [
                .run(.minutes(90)),
            ])),
        ])
        XCTAssertTrue(PlanValidator.review(plan: long).concerns.contains(.veryLongWorkout))
    }
}
