import Foundation
import StjernelobCore

/// Persisteret øjebliksbillede af en igangværende tur, så den kan genoptages
/// efter app-luk/genstart (spec afsnit 16). Tiden regnes ud fra vægur, fordi et
/// monotont ur nulstilles ved en ny proces.
struct ActiveRunRecord: Codable, Sendable {
    var plan: WorkoutPlan
    var programWeekId: Int
    var programPhase: ProgramPhase
    var startDate: Date
    var pausedAccumulatedSeconds: Double
    var pauseStartDate: Date?

    /// Forløbet aktiv tid på et givet tidspunkt (fryser, hvis turen var på pause).
    func elapsed(asOf now: Date) -> Duration {
        let reference = pauseStartDate ?? now
        let seconds = reference.timeIntervalSince(startDate) - pausedAccumulatedSeconds
        return .seconds(max(0, seconds))
    }

    var totalDuration: Duration { plan.totalDuration }

    /// Om der er en meningsfuld tur at genoptage (begyndt, men ikke færdig).
    func isResumable(asOf now: Date) -> Bool {
        let elapsed = elapsed(asOf: now)
        return elapsed > .seconds(1) && elapsed < totalDuration
    }
}

/// Gemmer/henter den igangværende tur (lokalt, UserDefaults).
@MainActor
final class RunStateStore {
    private let defaults: UserDefaults
    private let key = "activeRun.record"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func save(_ record: ActiveRunRecord) {
        if let data = try? JSONEncoder().encode(record) {
            defaults.set(data, forKey: key)
        }
    }

    func load() -> ActiveRunRecord? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(ActiveRunRecord.self, from: data)
    }

    func clear() {
        defaults.removeObject(forKey: key)
    }
}
