import Foundation

/// Hvad forløbet gør efter en uge, ud fra hvor mange ture der blev misset
/// (jf. docs/loebeplan.md → adaptiveLogic). Tonen er altid blid og tilgivende:
/// et trin tilbage er ikke et nederlag, bare vejen til at det passer brugeren.
public enum AdaptiveDecision: Sendable, Equatable {
    /// Ugen er gennemført → videre til næste uge.
    case advance
    /// Én tur misset → flyt den til næste ledige dag og forlæng ugen lidt.
    case extendWeek
    /// To eller flere ture misset (men ikke hele ugen) → gentag ugen.
    case repeatWeek
    /// Hele ugen (eller to) misset → blidt et eller to trin tilbage.
    case stepBack(weeks: Int)
    /// Tre eller flere uger i træk misset → blød genstart af fasen.
    case restartPhase
}

/// Adaptiv planlægning: beslutter blidt forløbets næste skridt og afgør, om en
/// uge tæller som gennemført, og hvornår en streak er brudt. Rene regler, ingen
/// tilstand — så de kan testes isoleret (jf. `rules/test.md`).
public enum AdaptivePlanner {
    /// En streak nulstilles først efter **mere end** så mange dage uden en tur.
    public static let streakResetDays = 10

    /// En uge tæller som gennemført, når man har lavet mindst ugens krav minus
    /// én tur — dvs. man må misse højst én (mindst 2 ud af 3, jf. doc'en).
    public static func isWeekComplete(required: Int, completed: Int) -> Bool {
        completed >= completionThreshold(required: required)
    }

    /// Mindste antal ture for at ugen er gennemført — to tredjedele af ugens
    /// ture, rundet op (jf. doc'ens "min. 2 ud af 3"). Fx 3 → 2, 2 → 2, 1 → 1.
    public static func completionThreshold(required: Int) -> Int {
        max(1, Int((Double(max(1, required)) * 2.0 / 3.0).rounded(.up)))
    }

    /// Beslut næste skridt ud fra ugens missede ture og hvor mange uger i træk,
    /// der er blevet helt misset (inkl. denne, hvis den er tom).
    public static func decide(
        required: Int,
        missed: Int,
        consecutiveFullyMissedWeeks: Int
    ) -> AdaptiveDecision {
        let required = max(1, required)
        let missed = clamp(missed, lower: 0, upper: required)

        if missed >= required {
            // Hele ugen misset — kig på hvor længe det har stået på.
            if consecutiveFullyMissedWeeks >= 3 { return .restartPhase }
            if consecutiveFullyMissedWeeks >= 2 { return .stepBack(weeks: 2) }
            return .stepBack(weeks: 1)
        }
        if missed == 0 { return .advance }
        if missed == 1 { return .extendWeek }
        return .repeatWeek
    }

    /// Om streaken er brudt efter et antal dage uden en tur.
    public static func streakIsBroken(daysSinceLastSession: Int) -> Bool {
        daysSinceLastSession > streakResetDays
    }
}
