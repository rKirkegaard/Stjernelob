import Foundation

/// Et øjebliksbillede af turens tilstand på et givet tidspunkt. Det er det,
/// under-tur-skærmen tegner: hvilket interval, hvor lang tid tilbage, samlet
/// forløbet tid osv. (jf. spec afsnit 4.1).
public struct WorkoutSnapshot: Sendable, Equatable {
    public enum Phase: Sendable, Equatable {
        case notStarted
        case active
        case paused
        case finished
    }

    /// Turens overordnede tilstand.
    public let phase: Phase
    /// Indeks i planens intervaller (0-baseret).
    public let intervalIndex: Int
    /// Det aktuelle interval.
    public let interval: Interval
    /// Forløbet tid inde i det aktuelle interval.
    public let elapsedInInterval: Duration
    /// Resterende tid på det aktuelle interval (nedtælling).
    public let remainingInInterval: Duration
    /// Samlet forløbet tid for hele turen (eksklusive pauser).
    public let totalElapsed: Duration
    /// Resterende tid for hele turen.
    public let totalRemaining: Duration
    /// Hvis det aktuelle interval er et løbeinterval: hvilket løbeinterval i
    /// rækken det er (1-baseret). Bruges til "Interval 3 af 6".
    public let runOrdinal: Int?
    /// Samlet antal løbeintervaller i turen.
    public let runCount: Int

    /// Om brugeren løber lige nu (modsat at gå).
    public var isRunning: Bool { interval.kind.isRunning }
}
