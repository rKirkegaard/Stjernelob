import Foundation

// Beskeder, der sendes mellem telefon og ur (WatchConnectivity). De er rene
// Codable-værdier uden platform-afhængigheder, så både iOS- og watchOS-appen
// deler præcis samme type. Selve transporten (WCSession) ligger i app-lagene.

/// Telefon → ur: den tur, uret skal kunne køre, og hvor i forløbet den hører til.
public struct WatchSessionPayload: Codable, Sendable, Equatable {
    public let plan: WorkoutPlan
    public let programWeekId: Int
    public let programPhase: ProgramPhase

    public init(plan: WorkoutPlan, programWeekId: Int, programPhase: ProgramPhase) {
        self.plan = plan
        self.programWeekId = programWeekId
        self.programPhase = programPhase
    }
}

/// Ur → telefon: resultatet af en tur gennemført på uret, så telefonen kan gemme
/// den i historikken (belønning for gennemførsel, ikke fart).
public struct WatchCompletionPayload: Codable, Sendable, Equatable {
    /// Stabil identitet for turen, så telefonen kan undgå at gemme den samme
    /// gennemførsel to gange, hvis beskeden skulle blive leveret mere end én gang.
    public let id: UUID
    public let programWeekId: Int
    public let programPhase: ProgramPhase
    public let activeSeconds: Double
    public let intervalsCompleted: Int
    public let plannedIntervalCount: Int
    public let runIntervalsCompleted: Int
    public let isComplete: Bool

    public init(
        id: UUID = UUID(),
        programWeekId: Int,
        programPhase: ProgramPhase,
        activeSeconds: Double,
        intervalsCompleted: Int,
        plannedIntervalCount: Int,
        runIntervalsCompleted: Int,
        isComplete: Bool
    ) {
        self.id = id
        self.programWeekId = programWeekId
        self.programPhase = programPhase
        self.activeSeconds = activeSeconds
        self.intervalsCompleted = intervalsCompleted
        self.plannedIntervalCount = plannedIntervalCount
        self.runIntervalsCompleted = runIntervalsCompleted
        self.isComplete = isComplete
    }
}
