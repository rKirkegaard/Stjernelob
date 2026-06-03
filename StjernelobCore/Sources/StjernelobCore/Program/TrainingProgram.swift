import Foundation

/// Hvilken fase af rejsen en uge tilhører (jf. spec afsnit 6.1).
public enum ProgramPhase: String, Sendable, Codable, CaseIterable {
    /// Grundforløb: fra "har aldrig løbet" til 20–30 min sammenhængende.
    case base
    /// "Hold ved": faste 20–30 min ture.
    case maintain
    /// Mod 5 km uden pause.
    case towardFiveKilometre
    /// Længere distancer.
    case beyond
}

/// Én uge i forløbet.
public struct ProgramWeek: Sendable, Equatable, Codable, Identifiable {
    /// Global, 1-baseret placering i hele rejsen.
    public let id: Int
    public let phase: ProgramPhase
    /// Lokaliseringsnøgle for ugens titel — aldrig hardcodet brugertekst i domænet.
    public let titleKey: String
    public let session: SessionTemplate

    public init(id: Int, phase: ProgramPhase, titleKey: String, session: SessionTemplate) {
        self.id = id
        self.phase = phase
        self.titleKey = titleKey
        self.session = session
    }

    /// Ugens tur for et givet ugentligt træningsantal.
    public func plan(forSessionsPerWeek sessions: Int) -> WorkoutPlan {
        session.plan(forSessionsPerWeek: sessions)
    }
}

/// Hele det progressive forløb som en ordnet række uger. Den sidste fase
/// (`beyond`) er tænkt som et "hold ved / pres lidt videre", brugeren kan blive
/// i, så hun aldrig står uden mål.
public struct TrainingProgram: Sendable, Equatable {
    public let weeks: [ProgramWeek]

    public init(weeks: [ProgramWeek]) {
        precondition(!weeks.isEmpty, "Et forløb skal have mindst én uge")
        self.weeks = weeks
    }

    public var firstWeekIndex: Int { 0 }
    public var lastWeekIndex: Int { weeks.count - 1 }

    public func week(at index: Int) -> ProgramWeek {
        weeks[clamp(index, lower: 0, upper: lastWeekIndex)]
    }
}
