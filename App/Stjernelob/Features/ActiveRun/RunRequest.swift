import Foundation
import StjernelobCore

/// En anmodning om at starte en konkret tur. Bærer den plan, der skal køres,
/// samt hvilken uge/fase i forløbet den hører til (så resultatet kan gemmes).
struct RunRequest: Identifiable {
    let id = UUID()
    let plan: WorkoutPlan
    let programWeekId: Int
    let programPhase: ProgramPhase
}
