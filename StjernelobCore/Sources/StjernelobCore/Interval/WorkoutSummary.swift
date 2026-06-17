import Foundation

/// Opsummering af en tur, når den slutter — enten fordi den blev gennemført,
/// eller fordi den blev afbrudt.
///
/// Bevidst handler opsummeringen om **gennemførsel**, ikke om fart eller
/// distance: belønning gives for at møde op og gøre intervaller færdige
/// (jf. de bindende velbefindende-regler). Distance/tempo håndteres et andet
/// sted (præsentations-/sensorlag) og er aldrig grundlag for belønning.
public struct WorkoutSummary: Codable, Sendable, Equatable {
    /// Planlagt samlet varighed for turen.
    public let plannedDuration: Duration
    /// Faktisk aktiv tid (eksklusive pauser) da turen sluttede.
    public let activeDuration: Duration
    /// Antal intervaller, der nåede at blive gennemført fuldt ud.
    public let intervalsCompleted: Int
    /// Samlet antal intervaller i planen.
    public let plannedIntervalCount: Int
    /// Hvor mange af de gennemførte intervaller, der var løbeintervaller.
    public let runIntervalsCompleted: Int
    /// Om hele turen blev gennemført (modsat afbrudt).
    public let isComplete: Bool
    /// Varigheden af det længste *sammenhængende* løbeinterval, der nåede at
    /// blive gennemført fuldt ud (løb adskilles af gå-intervaller). Bruges til
    /// milepæle som "første sammenhængende løb på X minutter" — fejrer at kunne
    /// løbe i længere tid ad gangen, aldrig fart eller distance.
    public let longestRunInterval: Duration

    public init(
        plannedDuration: Duration,
        activeDuration: Duration,
        intervalsCompleted: Int,
        plannedIntervalCount: Int,
        runIntervalsCompleted: Int,
        isComplete: Bool,
        longestRunInterval: Duration = .zero
    ) {
        self.plannedDuration = plannedDuration
        self.activeDuration = activeDuration
        self.intervalsCompleted = intervalsCompleted
        self.plannedIntervalCount = plannedIntervalCount
        self.runIntervalsCompleted = runIntervalsCompleted
        self.isComplete = isComplete
        self.longestRunInterval = longestRunInterval
    }
}
