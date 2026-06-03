import Foundation

/// Resultatet af én træningstur, som progressionen lytter til. Bevidst kun
/// gennemførsel og en valgfri "hvordan føltes det?" (1–10) — aldrig fart eller
/// distance (jf. velbefindende-reglerne og spec afsnit 5/6).
public struct SessionOutcome: Sendable, Equatable, Codable {
    /// Om turen blev gennemført (modsat afbrudt eller sprunget over).
    public let wasCompleted: Bool
    /// Brugerens egen oplevede anstrengelse, 1 (meget let) – 10 (meget hårdt).
    /// `nil` hvis hun ikke svarede.
    public let perceivedEffort: Int?

    public init(wasCompleted: Bool, perceivedEffort: Int? = nil) {
        self.wasCompleted = wasCompleted
        self.perceivedEffort = perceivedEffort
    }

    var wasSkippedOrIncomplete: Bool { !wasCompleted }
    var feltHard: Bool { (perceivedEffort ?? 0) >= 8 }
    var feltVeryHard: Bool { (perceivedEffort ?? 0) >= 9 }
}

/// Hvad forløbet gør efter en uge.
public enum ProgressionDecision: Sendable, Equatable {
    /// Gå videre til næste uge.
    case advance
    /// Bliv på samme uge (blidt foreslået) — fx hvis flere ture føltes hårde.
    case repeatWeek
    /// Ét trin tilbage — hvis ugen var for hård eller ofte ikke blev gennemført.
    case stepBack
}

/// Beslutter blidt, om brugeren skal gå videre, gentage ugen eller et trin
/// tilbage (jf. spec afsnit 6.1: "Hvis hun markerer flere ture i træk som hårde
/// (eller springer ture over), foreslår appen blidt at gentage ugen").
///
/// Reglerne er konservative og ikke-dømmende: tvivl falder altid ud til den
/// blødere progression. Det er kun et *forslag* — brugeren kan altid selv vælge.
public enum ProgressionPolicy {
    public static func decide(outcomes: [SessionOutcome]) -> ProgressionDecision {
        guard !outcomes.isEmpty else { return .repeatWeek }

        let incomplete = outcomes.filter(\.wasSkippedOrIncomplete).count
        let veryHard = outcomes.filter(\.feltVeryHard).count
        let hard = outcomes.filter(\.feltHard).count

        // For hård/for ufuldstændig uge → blødt et trin tilbage.
        if incomplete >= 2 || veryHard >= 2 {
            return .stepBack
        }
        // Flere hårde eller oversprungne ture → gentag ugen.
        if hard + incomplete >= 2 {
            return .repeatWeek
        }
        return .advance
    }
}
