import Foundation
import StjernelobCore

/// Bygger en `WeeklyTracker` ud fra de gemte data (ugemål, frys/pause og
/// gennemførte ture), så streaken kan beregnes ét sted. Holder domænelaget
/// (`StjernelobCore`) frit for persistens.
@MainActor
struct WeeklyStatusService {
    let weeklyPlanRepository: any WeeklyPlanRepository
    let workoutRepository: any WorkoutRepository
    var calendar: Calendar = .iso8601Monday

    func tracker() throws -> WeeklyTracker {
        let goals = try weeklyPlanRepository.allGoals()
        let statuses = try weeklyPlanRepository.allStatuses()
        let workouts = try workoutRepository.all()

        // Tæl gennemførte ture pr. uge (kun fuldførte tæller mod ugemålet).
        var completedByWeek: [WeekIdentifier: Int] = [:]
        for workout in workouts where workout.isComplete {
            let week = WeekIdentifier(date: workout.date, calendar: calendar)
            completedByWeek[week, default: 0] += 1
        }

        let goalByWeek = Dictionary(goals.map { ($0.week, $0.targetSessions) }, uniquingKeysWith: { a, _ in a })

        var progress: [WeekIdentifier: WeekProgress] = [:]
        for week in Set(goalByWeek.keys).union(completedByWeek.keys) {
            progress[week] = WeekProgress(
                week: week,
                targetSessions: goalByWeek[week] ?? 1,
                completedSessions: completedByWeek[week] ?? 0
            )
        }

        var frozen: Set<WeekIdentifier> = []
        var paused: Set<WeekIdentifier> = []
        for status in statuses {
            if status.isFrozen { frozen.insert(status.week) }
            if status.isPaused { paused.insert(status.week) }
        }

        return WeeklyTracker(progress: progress, frozenWeeks: frozen, pausedWeeks: paused, calendar: calendar)
    }
}
