import XCTest
import StjernelobCore
@testable import Stjernelob

/// Test for at GDPR-eksporten indeholder brugerens data (dataportabilitet).
@MainActor
final class DataExportServiceTests: XCTestCase {
    func testExportIncludesProfileAndWorkouts() throws {
        let env = AppEnvironment.preview
        try env.profileRepository.save(ProfileDTO(
            hasRunBefore: true, defaultWeeklySessions: 3, currentWeekIndex: 1,
            role: .runner, onboardingComplete: true, health: HealthScreening()
        ))
        try env.workoutRepository.add(CompletedWorkoutDTO(
            id: UUID(), date: Date(), programWeekId: 1, phase: .base,
            plannedIntervalCount: 10, intervalsCompleted: 10, runIntervalsCompleted: 6,
            activeDuration: .seconds(600), isComplete: true, starsEarned: 13,
            perceivedEffort: 5, photos: []
        ))

        let export = DataExportService(environment: env).makeExport()
        XCTAssertNotNil(export.profile)
        XCTAssertEqual(export.workouts.count, 1)
        XCTAssertEqual(export.workouts.first?.isComplete, true)
    }
}
