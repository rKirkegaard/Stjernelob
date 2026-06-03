import XCTest
import StjernelobCore
@testable import Stjernelob

/// Tests for at den adaptive progression faktisk rykker forløbet, når ugemålet
/// er nået — og at en hård uge i stedet gentages.
@MainActor
final class ProgressionCoordinatorTests: XCTestCase {
    private func makeProfile(sessions: Int) -> ProfileDTO {
        ProfileDTO(
            hasRunBefore: false,
            defaultWeeklySessions: sessions,
            currentWeekIndex: 0,
            role: .runner,
            onboardingComplete: true,
            health: HealthScreening()
        )
    }

    private func addWorkout(_ env: AppEnvironment, weekId: Int, effort: Int) throws {
        try env.workoutRepository.add(CompletedWorkoutDTO(
            id: UUID(), date: Date(), programWeekId: weekId, phase: .base,
            plannedIntervalCount: 10, intervalsCompleted: 10, runIntervalsCompleted: 6,
            activeDuration: .seconds(600), isComplete: true, starsEarned: 13,
            perceivedEffort: effort, photos: []
        ))
    }

    func testAdvancesAfterEasyWeek() throws {
        let env = AppEnvironment.preview
        try env.profileRepository.save(makeProfile(sessions: 3))
        let coordinator = ProgressionCoordinator(environment: env)
        let weekId = ProgressionEngine().currentWeek.id

        for _ in 0..<3 {
            try addWorkout(env, weekId: weekId, effort: 4) // let
            coordinator.registerCompletedWorkout(programWeekId: weekId)
        }

        let updated = try XCTUnwrap(env.profileRepository.load())
        XCTAssertEqual(updated.currentWeekIndex, 1)
        XCTAssertEqual(updated.completedSessionsThisProgramWeek, 0)
    }

    func testRepeatsHardWeek() throws {
        let env = AppEnvironment.preview
        try env.profileRepository.save(makeProfile(sessions: 3))
        let coordinator = ProgressionCoordinator(environment: env)
        let weekId = ProgressionEngine().currentWeek.id

        for _ in 0..<3 {
            try addWorkout(env, weekId: weekId, effort: 8) // hårdt
            coordinator.registerCompletedWorkout(programWeekId: weekId)
        }

        let updated = try XCTUnwrap(env.profileRepository.load())
        XCTAssertEqual(updated.currentWeekIndex, 0, "En hård uge skal gentages, ikke rykke frem")
    }

    func testDoesNotAdvanceBeforeGoal() throws {
        let env = AppEnvironment.preview
        try env.profileRepository.save(makeProfile(sessions: 3))
        let coordinator = ProgressionCoordinator(environment: env)
        let weekId = ProgressionEngine().currentWeek.id

        try addWorkout(env, weekId: weekId, effort: 4)
        coordinator.registerCompletedWorkout(programWeekId: weekId)

        let updated = try XCTUnwrap(env.profileRepository.load())
        XCTAssertEqual(updated.currentWeekIndex, 0)
        XCTAssertEqual(updated.completedSessionsThisProgramWeek, 1)
    }
}
