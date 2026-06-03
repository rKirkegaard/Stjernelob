import Foundation
import Observation
import StjernelobCore

/// Appens afhængigheds-container. Samler de tjenester, som ViewModels og views
/// får injiceret (jf. `arkitektur.md`: afhængigheder injiceres, ingen skjulte
/// singletons). Vokser efterhånden som lyd/haptik, synk og sikkerhed kommer til.
@MainActor
@Observable
final class AppEnvironment {
    /// Monotont ur til intervalmotoren — udskifteligt i test/preview.
    let clock: any MonotonicClock

    /// Lokal datalagring (kilden til sandhed, offline-først).
    let store: SwiftDataStore

    /// Billedfiler på disk (med Data Protection).
    let photoStore: any PhotoStore

    init(clock: any MonotonicClock = SystemMonotonicClock(),
         store: SwiftDataStore? = nil,
         photoStore: any PhotoStore = FilePhotoStore()) {
        self.clock = clock
        // makeDefault() er @MainActor; kaldes her i init-kroppen (MainActor-
        // isoleret) frem for som default-argument (nonisolated kontekst).
        self.store = store ?? SwiftDataStore.makeDefault()
        self.photoStore = photoStore
    }

    /// Bekvemmelig in-memory-opsætning til previews.
    static var preview: AppEnvironment {
        AppEnvironment(clock: ManualClock(), store: .makeInMemory())
    }

    // Repository-adgang (SwiftDataStore opfylder alle protokoller).
    var profileRepository: any ProfileRepository { store }
    var workoutRepository: any WorkoutRepository { store }
    var weeklyPlanRepository: any WeeklyPlanRepository { store }
    var badgeRepository: any BadgeRepository { store }
    var dataEraser: any DataEraser { store }
}
