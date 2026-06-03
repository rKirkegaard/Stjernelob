import Foundation

/// Hændelser, som intervalmotoren udsender undervejs i en tur. Præsentations-
/// laget oversætter dem til lyd, stemmecoach, haptik, stjernepop og konfetti
/// (jf. spec afsnit 4.2–4.4). Motoren kender ikke til lyd eller UI — den
/// fortæller kun *hvad* der sker og *hvornår*.
public enum WorkoutEvent: Sendable, Equatable {
    /// Turen er begyndt; det første interval starter samtidig via
    /// `intervalStarted`.
    case started

    /// Et nyt interval er begyndt (også det første). Driver stemmecoach,
    /// start-lyd og haptik for skiftet.
    case intervalStarted(index: Int, interval: Interval)

    /// Et interval er gennemført. Driver "ding" + stjernepop (afsnit 4.3).
    case intervalCompleted(index: Int, interval: Interval)

    /// Nedtælling de sidste sekunder før et skift (3, 2, 1). Driver de tre
    /// korte bip, så skiftet aldrig kommer bag på brugeren (afsnit 4.2).
    case countdown(secondsRemaining: Int)

    /// Halvvejs i turen — en lille opmuntring (afsnit 4.2).
    case halfway

    /// Hele turen er gennemført. Driver konfetti-fejringen (afsnit 4.4).
    case finished(summary: WorkoutSummary)
}
