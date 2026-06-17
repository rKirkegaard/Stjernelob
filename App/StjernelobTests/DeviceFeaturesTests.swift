import StjernelobCore
import StjernelobShared
import XCTest
@testable import Stjernelob

/// Integrationstests med dummy data for device-delsystemerne (CloudKit-skema,
/// App Group-widget, ur-synk). De kører mod en in-memory-butik, så de verificerer
/// den rigtige kode uden at kræve iCloud/device — og dækker de mest risikable
/// ændringer: optionel foto-relation, badge-dedup uden unik-constraint, og at
/// turer fra uret kun gemmes én gang.
@MainActor
final class DeviceFeaturesTests: XCTestCase {
    private func dummyWorkout(daysAgo: Int) -> CompletedWorkoutDTO {
        CompletedWorkoutDTO(
            id: UUID(),
            date: Date().addingTimeInterval(Double(-daysAgo) * 86400),
            programWeekId: 1,
            phase: .base,
            plannedIntervalCount: 8,
            intervalsCompleted: 8,
            runIntervalsCompleted: 4,
            activeDuration: .seconds(1200),
            isComplete: true,
            starsEarned: 10,
            perceivedEffort: 5,
            distanceMeters: 2000,
            bodySignal: .allGood,
            reflection: "Det gik bedre end sidst",
            stretchedAfter: true,
            drankWater: true,
            longestRunSeconds: 300,
            photos: []
        )
    }

    // MARK: - SwiftData-skema (CloudKit-kompatibelt)

    func testSeededWorkoutsPersistAndQuery() throws {
        let env = AppEnvironment.preview
        for day in 0..<5 { try env.workoutRepository.add(dummyWorkout(daysAgo: day)) }

        XCTAssertEqual(try env.workoutRepository.count(), 5)
        XCTAssertEqual(try env.workoutRepository.recent(limit: 3).count, 3)

        let all = try env.workoutRepository.all()
        XCTAssertEqual(all.count, 5)
        // Nyeste først.
        let newest = try XCTUnwrap(all.first)
        let oldest = try XCTUnwrap(all.last)
        XCTAssertTrue(newest.date > oldest.date)
        // De nye felter overlever en tur gennem persistensen.
        XCTAssertEqual(newest.stretchedAfter, true)
        XCTAssertEqual(newest.drankWater, true)
        XCTAssertEqual(newest.longestRunSeconds, 300)
        XCTAssertEqual(newest.distanceMeters, 2000)
    }

    func testOptionalPhotoRelationshipRoundTrips() throws {
        let env = AppEnvironment.preview
        let workout = dummyWorkout(daysAgo: 0)
        try env.workoutRepository.add(workout)
        try env.workoutRepository.addPhoto(
            WorkoutPhotoDTO(id: UUID(), fileName: "tur.jpg", caption: "Skoven", createdAt: Date()),
            toWorkoutWithId: workout.id
        )
        let stored = try env.workoutRepository.all().first { $0.id == workout.id }
        XCTAssertEqual(stored?.photos.count, 1)
        XCTAssertEqual(stored?.photos.first?.caption, "Skoven")
    }

    // MARK: - Badge-dedup uden @Attribute(.unique)

    func testEarnedBadgeIsNotDuplicated() throws {
        let env = AppEnvironment.preview
        guard let badge = Badge(slug: "første-skridt") else {
            return XCTFail("Kendt badge-slug mangler i kataloget")
        }
        try env.badgeRepository.award(badge)
        try env.badgeRepository.award(badge) // samme mærke igen
        let earned = try env.badgeRepository.earned()
        XCTAssertEqual(earned.filter { $0 == badge }.count, 1)
    }

    // MARK: - Ur-synk er idempotent

    func testWatchCompletionSavedOnlyOnce() throws {
        let env = AppEnvironment.preview
        let sync = PhoneSyncService(environment: env)
        let payload = WatchCompletionPayload(
            id: UUID(),
            programWeekId: 1,
            programPhase: .base,
            activeSeconds: 1200,
            intervalsCompleted: 8,
            plannedIntervalCount: 8,
            runIntervalsCompleted: 4,
            isComplete: true
        )
        sync.handleCompletion(payload)
        sync.handleCompletion(payload) // leveret igen — må ikke give en dubletter
        XCTAssertEqual(try env.workoutRepository.count(), 1)
    }

    // MARK: - Widget-øjebliksbillede fra rigtige data

    func testWidgetSnapshotIsBuiltFromUserData() throws {
        let env = AppEnvironment.preview
        try env.profileRepository.save(ProfileDTO(
            hasRunBefore: false, defaultWeeklySessions: 3, currentWeekIndex: 0,
            role: .runner, onboardingComplete: true, health: HealthScreening()
        ))
        let snapshot = WidgetUpdater(environment: env).makeSnapshot()
        XCTAssertFalse(snapshot.nextRunDetail.isEmpty)
        XCTAssertTrue(snapshot.nextRunDetail.contains("min"))
        XCTAssertGreaterThanOrEqual(snapshot.streakWeeks, 0)
    }

    func testWidgetSnapshotCodableRoundTrips() throws {
        let snapshot = WidgetSnapshot(
            nextRunDetail: "3 løb · 20 min",
            streakWeeks: 2,
            updatedAt: Date()
        )
        let data = try JSONEncoder().encode(snapshot)
        let restored = try JSONDecoder().decode(WidgetSnapshot.self, from: data)
        XCTAssertEqual(snapshot, restored)
    }
}
