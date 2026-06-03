import Foundation

/// Beregner den aktuelle streak på **ugeniveau** og er bevidst **tilgivende**
/// (jf. spec afsnit 5.3):
///
/// - En uge tæller, når ugemålet er nået (`goalMet`) eller reddet af en
///   streak-fryser (`frozen`).
/// - En `paused` uge er gennemsigtig: den hverken tæller eller bryder.
/// - Den aktuelle uge bryder aldrig streaken, bare fordi den ikke er færdig endnu.
/// - Først en rigtig `missed` uge (eller et hul uden data) afslutter streaken —
///   og selv da er tonen "velkommen tilbage", aldrig skyld (det håndteres i UI).
public enum StreakCalculator {
    public static func currentStreak(
        asOf currentWeek: WeekIdentifier,
        outcome: (_ week: WeekIdentifier, _ isCurrent: Bool) -> WeekOutcome?,
        calendar: Calendar = .iso8601Monday,
        maxLookback: Int = 520
    ) -> Int {
        var streak = 0
        var week = currentWeek
        var isCurrent = true

        for _ in 0..<maxLookback {
            switch outcome(week, isCurrent) {
            case .goalMet, .frozen:
                streak += 1
            case .paused:
                break // hverken tæller eller bryder
            case .missed:
                return streak
            case .none:
                if !isCurrent { return streak } // et hul = streaken slutter her
                // den aktuelle uge er måske bare ikke i mål endnu → kig videre bagud
            }
            week = week.previous(calendar: calendar)
            isCurrent = false
        }
        return streak
    }
}
