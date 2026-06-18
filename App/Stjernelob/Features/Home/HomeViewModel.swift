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
    private(set) var levelProgress = LevelSystem.standard.progress(forPoints: 0)
    private(set) var sessionsPerWeek = 3

    /// Aktiv egen/importeret plan (driver "dagens tur", når den er sat).
    private(set) var activePlan: TrainingPlan?
    private(set) var activePlanWeek = 1
    private(set) var activePlanWorkouts: [Workout] = []

    init(environment: AppEnvironment) {
        self.environment = environment
    }

    func load(now: Date = Date()) {
        // Genberegn placeringen i det indbyggede forløb ud fra historikken.
        ProgressionCoordinator(environment: environment).reconcile(now: now)

        let profile = try? environment.profileRepository.load()
        sessionsPerWeek = profile?.defaultWeeklySessions ?? 3

        if let activeId = profile?.activePlanId,
           let plan = try? environment.planLibraryRepository.plan(id: activeId)
        {
            loadActivePlan(plan, week: profile?.activePlanWeek ?? 1)
        } else {
            loadBuiltIn(profile: profile, now: now)
        }

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
        levelProgress = LevelSystem.standard.progress(forPoints: Points.fromStars(totalStars))
        level = levelProgress.level
    }

    // MARK: - Det indbyggede program

    private func loadBuiltIn(profile: ProfileDTO?, now: Date) {
        activePlan = nil
        activePlanWorkouts = []
        let engine =
            ProgressionEngine(state: ProgressionState(weekIndex: profile?.currentWeekIndex ?? 0))
        let week = engine.currentWeek
        currentWeek = week

        let days = WeekScheduler.resolvedTrainingDays(
            chosen: profile?.trainingDays ?? [],
            sessionsPerWeek: sessionsPerWeek
        )
        let training = WeekScheduler.isTrainingDay(now, trainingDays: days, calendar: calendar)
        isRestDay = !training
        todaysPlan = training
            ? environment.settings.trainingIntensity
            .scaled(week.plan(forSessionsPerWeek: sessionsPerWeek))
            : nil
    }

    // MARK: - Aktiv egen/importeret plan

    private func loadActivePlan(_ plan: TrainingPlan, week: Int) {
        activePlan = plan
        currentWeek = nil
        todaysPlan = nil
        isRestDay = false
        let weeks = plan.weekNumbers
        let clamped = min(max(week, weeks.first ?? 1), weeks.last ?? 1)
        activePlanWeek = clamped
        activePlanWorkouts = plan.workouts(inWeek: clamped)
    }

    var activePlanWeekCount: Int { activePlan?.weekNumbers.count ?? 0 }
    var canGoToPreviousPlanWeek: Bool {
        guard let plan = activePlan else { return false }
        return activePlanWeek > (plan.weekNumbers.first ?? 1)
    }

    var canAdvancePlanWeek: Bool {
        guard let plan = activePlan else { return false }
        return activePlanWeek < (plan.weekNumbers.last ?? 1)
    }

    func advancePlanWeek() { setPlanWeek(activePlanWeek + 1) }
    func goToPreviousPlanWeek() { setPlanWeek(activePlanWeek - 1) }

    private func setPlanWeek(_ week: Int) {
        guard let plan = activePlan else { return }
        let weeks = plan.weekNumbers
        let clamped = min(max(week, weeks.first ?? 1), weeks.last ?? 1)
        if var profile = try? environment.profileRepository.load() {
            profile.activePlanWeek = clamped
            try? environment.profileRepository.save(profile)
            environment.refreshWidget()
            environment.sendCurrentSessionToWatch()
        }
        load()
    }

    /// Kør-anmodning for en tur i den aktive plan (skaleret efter sværhedsgrad;
    /// tæller ikke i det indbyggede forløb, men i stjerner/streak/historik).
    func runRequest(for workout: Workout) -> RunRequest? {
        guard let plan = workout.timeBasedPlan() else { return nil }
        return RunRequest(
            plan: environment.settings.trainingIntensity.scaled(plan),
            programWeekId: 0,
            programPhase: .base,
            countsTowardProgression: false
        )
    }
}
