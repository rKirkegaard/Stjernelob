import Foundation
import WatchConnectivity
import StjernelobCore

/// WatchConnectivity på telefon-siden: sender den aktuelle uges tur til uret og
/// modtager turens resultat fra uret, så det gemmes i historikken.
@MainActor
final class PhoneSyncService: NSObject, WCSessionDelegate {
    private weak var environment: AppEnvironment?

    init(environment: AppEnvironment) {
        self.environment = environment
        super.init()
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    /// Send den aktuelle uges tur til uret som application context.
    func sendCurrentSession() {
        guard let environment, WCSession.isSupported(),
              WCSession.default.activationState == .activated else { return }
        let profile = try? environment.profileRepository.load()
        let engine = ProgressionEngine(state: ProgressionState(weekIndex: profile?.currentWeekIndex ?? 0))
        let week = engine.currentWeek
        let plan = week.plan(forSessionsPerWeek: profile?.defaultWeeklySessions ?? 3)
        let payload = WatchSessionPayload(plan: plan, programWeekId: week.id, programPhase: week.phase)
        if let data = try? JSONEncoder().encode(payload) {
            try? WCSession.default.updateApplicationContext(["session": data])
        }
    }

    private func saveCompletion(_ data: Data) {
        guard let environment,
              let payload = try? JSONDecoder().decode(WatchCompletionPayload.self, from: data) else { return }
        let summary = WorkoutSummary(
            plannedDuration: .seconds(payload.activeSeconds),
            activeDuration: .seconds(payload.activeSeconds),
            intervalsCompleted: payload.intervalsCompleted,
            plannedIntervalCount: payload.plannedIntervalCount,
            runIntervalsCompleted: payload.runIntervalsCompleted,
            isComplete: payload.isComplete
        )
        let workout = CompletedWorkoutDTO(
            id: UUID(),
            date: Date(),
            programWeekId: payload.programWeekId,
            phase: payload.programPhase,
            plannedIntervalCount: payload.plannedIntervalCount,
            intervalsCompleted: payload.intervalsCompleted,
            runIntervalsCompleted: payload.runIntervalsCompleted,
            activeDuration: .seconds(payload.activeSeconds),
            isComplete: payload.isComplete,
            starsEarned: Stars.earned(for: summary),
            perceivedEffort: nil,
            photos: []
        )
        try? environment.workoutRepository.add(workout)
        ProgressionCoordinator(environment: environment)
            .registerCompletedWorkout(programWeekId: payload.programWeekId)
    }

    // MARK: - WCSessionDelegate (nonisolated; hopper til MainActor)

    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}

    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}

    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }

    nonisolated func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        guard let data = userInfo["completion"] as? Data else { return }
        Task { @MainActor in self.saveCompletion(data) }
    }
}
