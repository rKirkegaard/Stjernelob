import Foundation
import StjernelobCore

/// Binder den adaptive progression (`StjernelobCore`) sammen med app-data: når
/// ugens ture er gennemført, vurderes ugen blidt, og forløbet rykker frem,
/// gentager eller går et trin tilbage (spec afsnit 6.1–6.2). Et trin tilbage
/// føles aldrig som nederlag — det er bare vejen til, at det passer brugeren.
@MainActor
struct ProgressionCoordinator {
    let environment: AppEnvironment
    private let calendar = Calendar.iso8601Monday

    /// Registrér en netop gemt tur. Hvis ugemålet for den aktuelle programuge er
    /// nået, anvendes progressionsbeslutningen, og tælleren nulstilles.
    func registerCompletedWorkout(programWeekId: Int, now: Date = Date()) {
        guard var profile = try? environment.profileRepository.load() else { return }
        var engine = ProgressionEngine(state: ProgressionState(weekIndex: profile.currentWeekIndex))
        // Tæl kun ture, der hører til den uge, brugeren faktisk står på.
        guard engine.currentWeek.id == programWeekId else { return }

        profile.completedSessionsThisProgramWeek += 1
        let target = max(1, weeklyTarget(profile: profile, now: now))

        if profile.completedSessionsThisProgramWeek >= target {
            let outcomes = recentOutcomes(forWeekId: programWeekId, limit: target)
            engine.completeWeek(outcomes: outcomes)
            profile.currentWeekIndex = engine.state.weekIndex
            profile.completedSessionsThisProgramWeek = 0
        }
        try? environment.profileRepository.save(profile)
    }

    private func weeklyTarget(profile: ProfileDTO, now: Date) -> Int {
        let week = WeekIdentifier(date: now, calendar: calendar)
        if let goal = try? environment.weeklyPlanRepository.goal(for: week) {
            return goal.targetSessions
        }
        return profile.defaultWeeklySessions
    }

    /// De seneste ture på den aktuelle programuge → blide outcomes til beslutningen.
    private func recentOutcomes(forWeekId weekId: Int, limit: Int) -> [SessionOutcome] {
        let workouts = (try? environment.workoutRepository.all()) ?? []
        return workouts
            .filter { $0.programWeekId == weekId }
            .prefix(limit)
            .map { SessionOutcome(wasCompleted: $0.isComplete, perceivedEffort: $0.perceivedEffort) }
    }
}
