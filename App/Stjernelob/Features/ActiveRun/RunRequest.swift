import Foundation
import StjernelobCore

/// En anmodning om at starte en konkret tur. Bærer den plan, der skal køres,
/// samt hvilken uge/fase i forløbet den hører til (så resultatet kan gemmes).
struct RunRequest: Identifiable {
    let id = UUID()
    let plan: WorkoutPlan
    let programWeekId: Int
    let programPhase: ProgramPhase
    /// Sat, hvis turen genoptages efter en afbrydelse (forløbet tid at starte ved).
    var resumeElapsed: Duration?
    /// Om turen tæller i det indbyggede forløbs progression. Falsk for egne/
    /// importerede ture, så de ikke flytter på det indbyggede program. (Stjerner,
    /// streak og historik tæller stadig — belønning for gennemførsel.)
    var countsTowardProgression: Bool = true
}
