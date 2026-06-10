import Foundation
import HealthKit
import StjernelobCore

/// Gemmer gennemførte ture som workouts i HealthKit og kan læse puls — alt med
/// samtykke og valgfrit (spec afsnit 10). Puls vises neutralt og er aldrig
/// grundlag for belønning. HealthKit er valgfrit: fejl og manglende samtykke
/// påvirker aldrig selve træningsoplevelsen.
@MainActor
final class HealthKitService {
    private let store = HKHealthStore()

    var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    func requestAuthorization() async -> Bool {
        guard isAvailable else { return false }
        let share: Set<HKSampleType> = [HKObjectType.workoutType()]
        var read: Set<HKObjectType> = [HKObjectType.workoutType()]
        if let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate) {
            read.insert(heartRate)
        }
        do {
            try await store.requestAuthorization(toShare: share, read: read)
            return true
        } catch {
            return false
        }
    }

    /// Gem en gennemført tur som et løbe-workout. Best-effort.
    func saveRun(start: Date, duration: Duration) async {
        guard isAvailable else { return }
        let end = start.addingTimeInterval(TimeInterval(duration.components.seconds))

        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .running

        let builder = HKWorkoutBuilder(
            healthStore: store,
            configuration: configuration,
            device: .local()
        )
        do {
            try await builder.beginCollection(at: start)
            try await builder.endCollection(at: end)
            _ = try await builder.finishWorkout()
        } catch {
            // Valgfrit — ignoreres bevidst.
        }
    }
}
