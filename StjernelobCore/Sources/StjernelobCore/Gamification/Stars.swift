import Foundation

/// Stjerner — mikro-belønningen pr. interval plus en bonus for at gøre turen
/// færdig (jf. spec afsnit 5.1).
///
/// Stjerner gives for **gennemførsel**, aldrig for fart eller distance, og kan
/// aldrig mistes. Selv en langsom eller afbrudt tur giver fulde stjerner for det,
/// der blev gennemført.
public enum Stars {
    /// Bonusstjerner for at gennemføre hele turen — afslutning belønnes mere end
    /// enkeltintervaller, så der altid er grund til at gøre turen færdig.
    public static let completionBonus = 3

    /// Stjerner optjent på en tur ud fra dens opsummering.
    public static func earned(for summary: WorkoutSummary, completionBonus: Int = completionBonus) -> Int {
        let perInterval = summary.intervalsCompleted          // 1 stjerne pr. gennemført interval
        let bonus = summary.isComplete ? completionBonus : 0
        return perInterval + bonus
    }
}
