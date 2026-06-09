import Foundation
import StjernelobCore

/// Binder den adaptive progression (`StjernelobCore`) sammen med app-data.
///
/// Placeringen i forløbet genberegnes **idempotent** ud fra hele tur-historikken
/// (`AdaptiveProgress`): hver gennemført kalenderuge rykker blidt frem, en uge
/// under tærsklen gentages, og missede uger trapper roligt ned (spec afsnit
/// 6.1–6.2 / docs/loebeplan.md). Et trin tilbage er aldrig et nederlag — bare
/// vejen til, at det passer brugeren.
@MainActor
struct ProgressionCoordinator {
    let environment: AppEnvironment
    private let calendar = Calendar.iso8601Monday

    /// Genberegn placeringen i forløbet ud fra historikken. Kaldes ved app-åbning
    /// og efter hver gemt tur, så både fremgang og missede uger fanges blidt.
    func reconcile(now: Date = Date()) {
        guard var profile = try? environment.profileRepository.load() else { return }

        let workouts = (try? environment.workoutRepository.all()) ?? []
        // Kun gennemførte ture tæller som en "session" for ugen.
        let completedByWeek = Dictionary(
            grouping: workouts.filter(\.isComplete),
            by: { WeekIdentifier(date: $0.date, calendar: calendar) }
        ).mapValues(\.count)

        // En uge føltes "for hård", hvis mindst to gennemførte ture blev markeret
        // som meget hårde (oplevet anstrengelse ≥ 8). Så bliver forløbet blidt
        // stående på ugen (oplevelsen som indgang, ikke fart).
        let hardByWeek = Dictionary(
            grouping: workouts.filter { $0.isComplete && ($0.perceivedEffort ?? 0) >= 8 },
            by: { WeekIdentifier(date: $0.date, calendar: calendar) }
        ).mapValues(\.count)

        let result = AdaptiveProgress.evaluate(
            program: StandardProgram.journey,
            completedByWeek: completedByWeek,
            currentWeek: WeekIdentifier(date: now, calendar: calendar),
            requiredSessions: { week in
                CouchToRunnerPlan.week(id: week.id)?.requiredSessionCount
                    ?? max(1, profile.defaultWeeklySessions)
            },
            weekFeltTooHard: { (hardByWeek[$0] ?? 0) >= 2 },
            calendar: calendar
        )

        // Skriv kun, hvis noget faktisk ændrede sig.
        guard profile.currentWeekIndex != result.weekIndex
            || profile.completedSessionsThisProgramWeek != result.completedThisWeek
        else { return }

        profile.currentWeekIndex = result.weekIndex
        profile.completedSessionsThisProgramWeek = result.completedThisWeek
        try? environment.profileRepository.save(profile)
    }

    /// Kaldes efter en netop gemt tur. Progressionen afgøres nu af hele
    /// historikken, så dette blot genberegner placeringen.
    func registerCompletedWorkout(programWeekId: Int, now: Date = Date()) {
        reconcile(now: now)
    }
}
