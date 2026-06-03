import Foundation
import Observation
import StjernelobCore

/// Appens afhængigheds-container. Samler de tjenester, som ViewModels og views
/// får injiceret (jf. `arkitektur.md`: afhængigheder injiceres, ingen skjulte
/// singletons). Vokser efterhånden som datalag, lyd/haptik og synk kommer til.
@Observable
final class AppEnvironment {
    /// Monotont ur til intervalmotoren — udskifteligt i test/preview.
    let clock: any MonotonicClock

    init(clock: any MonotonicClock = SystemMonotonicClock()) {
        self.clock = clock
    }
}
