import Foundation

/// Resultatet af at genberegne brugerens placering i forløbet ud fra historik.
public struct AdaptiveProgressResult: Sendable, Equatable {
    /// Indeks i `program.weeks` brugeren nu står på.
    public var weekIndex: Int
    /// Hvor mange kalenderuger i træk der er blevet helt misset (0 = ingen).
    public var consecutiveMissedWeeks: Int
    /// Gennemførte ture i den igangværende kalenderuge.
    public var completedThisWeek: Int

    public init(weekIndex: Int, consecutiveMissedWeeks: Int, completedThisWeek: Int) {
        self.weekIndex = weekIndex
        self.consecutiveMissedWeeks = consecutiveMissedWeeks
        self.completedThisWeek = completedThisWeek
    }
}

/// Genberegner placeringen i forløbet **idempotent** ud fra hvilke kalenderuger
/// der har gennemførte ture (jf. docs/loebeplan.md → adaptiveLogic).
///
/// Modellen er rent fremmøde-baseret og tilgivende: hver afsluttet kalenderuge
/// rykker forløbet ét trin frem (når ugen er gennemført), bliver stående (nogle
/// ture, men under tærsklen) eller går blidt et trin tilbage (helt misset uge),
/// og to/tre missede uger i træk trapper roligt ned. Da den genberegnes fra
/// bunden, kan den ikke "drive" — samme historik giver altid samme placering.
public enum AdaptiveProgress {
    /// - Parameters:
    ///   - completedByWeek: antal gennemførte ture pr. kalenderuge.
    ///   - currentWeek: den igangværende kalenderuge (er ikke "lukket" endnu).
    ///   - requiredSessions: ugens krævede antal ture (typisk 2–3 fra planen).
    /// - Parameter weekFeltTooHard: om en uge (selvom den blev gennemført) føltes
    ///   for hård — fx ≥2 ture markeret som meget hårde. Så bliver forløbet blidt
    ///   stående på ugen i stedet for at rykke frem (oplevelsen som indgang, ikke
    ///   fart). Aldrig et nederlag — bare at det passer hende.
    public static func evaluate(
        program: TrainingProgram,
        completedByWeek: [WeekIdentifier: Int],
        currentWeek: WeekIdentifier,
        requiredSessions: (ProgramWeek) -> Int,
        weekFeltTooHard: (WeekIdentifier) -> Bool = { _ in false },
        calendar: Calendar = .iso8601Monday,
        maxLookback: Int = 520
    ) -> AdaptiveProgressResult {
        // Ingen ture endnu → ingen progression og ingen straf (man er ikke i gang).
        guard let firstWeek = completedByWeek.keys.min() else {
            return AdaptiveProgressResult(
                weekIndex: 0,
                consecutiveMissedWeeks: 0,
                completedThisWeek: 0
            )
        }

        var index = program.firstWeekIndex
        var consecutiveMissed = 0
        var week = firstWeek
        var steps = 0

        // Gennemgå hver *afsluttet* kalenderuge fra den første tur og frem til
        // (men ikke inklusive) den igangværende uge.
        while week < currentWeek, steps < maxLookback {
            let completed = completedByWeek[week] ?? 0
            let required = requiredSessions(program.week(at: index))

            if completed == 0 {
                consecutiveMissed += 1
                index = indexAfterMissedWeek(
                    index: index,
                    consecutiveMissed: consecutiveMissed,
                    program: program
                )
            } else {
                consecutiveMissed = 0
                if AdaptivePlanner.isWeekComplete(required: required, completed: completed),
                   !weekFeltTooHard(week)
                {
                    index = min(index + 1, program.lastWeekIndex)
                }
                // Ellers: under tærsklen, eller ugen føltes for hård → bliv på ugen.
            }
            week = week.advanced(byWeeks: 1, calendar: calendar)
            steps += 1
        }

        // Den igangværende uge: hvis den allerede er gennemført, rykkes der frem
        // nu (man venter ikke til ugen er forbi for at føle fremgang).
        let completedThisWeek = completedByWeek[currentWeek] ?? 0
        let requiredNow = requiredSessions(program.week(at: index))
        if AdaptivePlanner.isWeekComplete(required: requiredNow, completed: completedThisWeek),
           !weekFeltTooHard(currentWeek)
        {
            index = min(index + 1, program.lastWeekIndex)
        }

        return AdaptiveProgressResult(
            weekIndex: index,
            consecutiveMissedWeeks: consecutiveMissed,
            completedThisWeek: completedThisWeek
        )
    }

    /// Hvor langt tilbage en helt misset uge fører — blidt og aldrig under fasens
    /// start: 1 uge → ét trin, 2 i træk → to trin, 3+ → genstart af fasen.
    private static func indexAfterMissedWeek(
        index: Int,
        consecutiveMissed: Int,
        program: TrainingProgram
    ) -> Int {
        if consecutiveMissed >= 3 { return phaseStartIndex(of: index, in: program) }
        let stepBack = consecutiveMissed >= 2 ? 2 : 1
        return max(index - stepBack, program.firstWeekIndex)
    }

    /// Indeks for den første uge i samme fase som `index`.
    private static func phaseStartIndex(of index: Int, in program: TrainingProgram) -> Int {
        let phase = program.week(at: index).phase
        return program.weeks.firstIndex { $0.phase == phase } ?? program.firstWeekIndex
    }
}
