import Foundation
import HealthKit

/// Holder en `HKWorkoutSession` i gang under en tur på uret, så GPS og sensorer
/// bliver ved med at køre, mens skærmen er slukket / håndleddet er nede. Uden en
/// workout-session begrænser watchOS baggrundskørsel. Selve intervalmotoren og
/// belønningen er uafhængige af HealthKit — sessionen er kun "beholderen", der
/// holder turen i live.
@MainActor
final class WatchWorkoutController: NSObject {
    private let healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?

    /// Bed om adgang til at gemme workouts/rute. Kaldes før turen startes.
    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let share: Set = [HKQuantityType.workoutType()]
        _ = try? await healthStore.requestAuthorization(toShare: share, read: [])
    }

    /// Start en løbe-workout-session (udendørs). Fejler stille: turen kører stadig
    /// i forgrunden, bare uden baggrunds-sensorer.
    func start() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .running
        configuration.locationType = .outdoor
        do {
            let session = try HKWorkoutSession(
                healthStore: healthStore,
                configuration: configuration
            )
            let builder = session.associatedWorkoutBuilder()
            builder.dataSource = HKLiveWorkoutDataSource(
                healthStore: healthStore,
                workoutConfiguration: configuration
            )
            self.session = session
            self.builder = builder
            let start = Date()
            session.startActivity(with: start)
            builder.beginCollection(withStart: start) { _, _ in }
        } catch {
            session = nil
            builder = nil
        }
    }

    /// Afslut sessionen ved turslut.
    func end() {
        guard let session, let builder else { return }
        let end = Date()
        session.end()
        builder.endCollection(withEnd: end) { [weak builder] _, _ in
            builder?.finishWorkout { _, _ in }
        }
        self.session = nil
        self.builder = nil
    }
}
