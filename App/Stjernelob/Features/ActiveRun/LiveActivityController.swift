import ActivityKit
import Foundation
import StjernelobCore
import StjernelobShared

/// Starter, opdaterer og afslutter Live Activity'en for en igangværende tur
/// (spec afsnit 10). Falder pænt tilbage, hvis Live Activities er slået fra.
@MainActor
final class LiveActivityController {
    private var activity: Activity<RunActivityAttributes>?

    private func state(
        from snapshot: WorkoutSnapshot,
        intervalLabel: String
    ) -> RunActivityAttributes.ContentState {
        RunActivityAttributes.ContentState(
            intervalLabel: intervalLabel,
            isRunning: snapshot.isRunning,
            remainingSeconds: max(0, snapshot.remainingInInterval.wholeSeconds),
            totalRemainingSeconds: max(0, snapshot.totalRemaining.wholeSeconds)
        )
    }

    func start(planTitle: String, snapshot: WorkoutSnapshot, intervalLabel: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let content = ActivityContent(
            state: state(from: snapshot, intervalLabel: intervalLabel),
            staleDate: nil
        )
        activity = try? Activity.request(
            attributes: RunActivityAttributes(planTitle: planTitle),
            content: content
        )
    }

    func update(snapshot: WorkoutSnapshot, intervalLabel: String) {
        guard let activity else { return }
        let content = ActivityContent(
            state: state(from: snapshot, intervalLabel: intervalLabel),
            staleDate: nil
        )
        Task { await activity.update(content) }
    }

    func end() {
        guard let activity else { return }
        Task { await activity.end(nil, dismissalPolicy: .immediate) }
        self.activity = nil
    }
}
