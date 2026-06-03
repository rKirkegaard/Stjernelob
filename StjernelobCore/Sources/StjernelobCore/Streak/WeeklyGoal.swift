import Foundation

/// Brugerens selvvalgte ugemål: hvor mange ture hun har tid til i en bestemt
/// uge (jf. spec afsnit 6.2). Mindst 1 tur tæller altid som en aktiv uge.
public struct WeeklyGoal: Codable, Sendable, Equatable {
    public let week: WeekIdentifier
    /// Antal ture, hun sigter efter i ugen. Klampes til mindst 1.
    public let targetSessions: Int

    public init(week: WeekIdentifier, targetSessions: Int) {
        self.week = week
        self.targetSessions = max(1, targetSessions)
    }
}

/// En uges status set fra streak-logikkens synspunkt.
public enum WeekOutcome: Sendable, Equatable, Codable {
    /// Ugemålet blev nået.
    case goalMet
    /// Ugen blev reddet af en streak-fryser (sygdom, eksamen, ferie).
    case frozen
    /// Brugeren satte bevidst appen på pause — påvirker ikke streaken.
    case paused
    /// Ugen nåede ikke i mål og blev ikke reddet.
    case missed
}

/// En uges faktiske fremdrift: mål mod gennemførte ture.
public struct WeekProgress: Sendable, Equatable, Codable {
    public let week: WeekIdentifier
    public let targetSessions: Int
    public let completedSessions: Int

    public init(week: WeekIdentifier, targetSessions: Int, completedSessions: Int) {
        self.week = week
        self.targetSessions = max(1, targetSessions)
        self.completedSessions = completedSessions
    }

    /// Mindst én tur = en aktiv uge (spec afsnit 5.3).
    public var isActive: Bool { completedSessions >= 1 }

    /// Ugemålet er nået, når antallet af gennemførte ture når målet.
    public var isGoalMet: Bool { completedSessions >= targetSessions }

    /// Hvor stor en del af ugemålet der er nået (0...1).
    public var fractionToGoal: Double {
        guard targetSessions > 0 else { return 1 }
        return min(1, Double(completedSessions) / Double(targetSessions))
    }
}
