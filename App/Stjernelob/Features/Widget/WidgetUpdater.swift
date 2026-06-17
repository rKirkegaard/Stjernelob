import Foundation
import StjernelobCore
import StjernelobShared
import WidgetKit

/// Bygger det delte widget-øjebliksbillede ud fra brugerens egne data og beder
/// WidgetKit genindlæse. Kaldes når noget relevant ændrer sig (tur gemt, uge
/// planlagt, appstart). Holder kun blide, ikke-pressende data (spec afsnit 10).
@MainActor
struct WidgetUpdater {
    let environment: AppEnvironment

    /// Byg det delte øjebliksbillede ud fra brugerens data. Ren og testbar —
    /// rører hverken delt lagring eller WidgetKit.
    func makeSnapshot(now: Date = Date()) -> WidgetSnapshot {
        let profile = try? environment.profileRepository.load()
        let engine = ProgressionEngine(
            state: ProgressionState(weekIndex: profile?.currentWeekIndex ?? 0)
        )
        let week = engine.currentWeek
        let plan = week.plan(forSessionsPerWeek: profile?.defaultWeeklySessions ?? 3)

        let totalSeconds = plan.intervals.reduce(Duration.zero) { $0 + $1.duration }
            .components.seconds
        let minutes = Int((totalSeconds + 59) / 60)
        let detail = String(localized: Strings.Units.sessionSummary(
            runCount: plan.runIntervalCount,
            total: "\(minutes) min"
        ))

        return WidgetSnapshot(
            nextRunDetail: detail,
            streakWeeks: currentStreakWeeks(now: now),
            updatedAt: now
        )
    }

    func refresh() {
        WidgetSharedStore.save(makeSnapshot())
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func currentStreakWeeks(now: Date) -> Int {
        let service = WeeklyStatusService(
            weeklyPlanRepository: environment.weeklyPlanRepository,
            workoutRepository: environment.workoutRepository
        )
        guard let tracker = try? service.tracker() else { return 0 }
        return tracker.currentStreak(asOf: WeekIdentifier(date: now))
    }
}
