import Foundation
import Observation
import StjernelobCore

/// Dashboardets tilstand (spec afsnit 7.2): næste tur, om i dag er en hviledag,
/// streak, samlede stjerner og niveau. Forretningslogikken bor her, ikke i view'et.
@MainActor
@Observable
final class HomeViewModel {
    private let environment: AppEnvironment
    private let calendar = Calendar.iso8601Monday

    private(set) var currentWeek: ProgramWeek?
    private(set) var todaysPlan: WorkoutPlan?
    private(set) var isRestDay = false
    private(set) var streakWeeks = 0
    private(set) var totalStars = 0
    private(set) var level = 1
    private(set) var sessionsPerWeek = 3

    init(environment: AppEnvironment) {
        self.environment = environment
    }

    func load(now: Date = Date()) {
        let profile = try? environment.profileRepository.load()
        sessionsPerWeek = profile?.defaultWeeklySessions ?? 3

        let engine = ProgressionEngine(state: ProgressionState(weekIndex: profile?.currentWeekIndex ?? 0))
        let week = engine.currentWeek
        currentWeek = week

        let training = WeekScheduler.isTrainingDay(now, sessionsPerWeek: sessionsPerWeek, calendar: calendar)
        isRestDay = !training
        todaysPlan = training ? week.plan(forSessionsPerWeek: sessionsPerWeek) : nil

        let service = WeeklyStatusService(
            weeklyPlanRepository: environment.weeklyPlanRepository,
            workoutRepository: environment.workoutRepository,
            calendar: calendar
        )
        if let tracker = try? service.tracker() {
            streakWeeks = tracker.currentStreak(asOf: WeekIdentifier(date: now, calendar: calendar))
        }

        let workouts = (try? environment.workoutRepository.all()) ?? []
        totalStars = workouts.reduce(0) { $0 + $1.starsEarned }
        level = LevelSystem.standard.level(forPoints: Points.fromStars(totalStars))
    }
}
