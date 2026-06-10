import Foundation

/// Det indbyggede forløb (jf. docs/loebeplan.md): det 20-ugers program "fra sofa
/// til løber", målrettet en teenager-begynder i ringe form. Hver uges tur er
/// nøjagtigt fastlagt i `CouchToRunnerPlan` (produktets "sandhed"); her
/// projiceres planen ind i forløbs-modellen, så resten af appen er uændret.
///
/// Titlerne er lokaliseringsnøgler — den viste tekst ligger i app-lagets
/// strengkatalog.
public enum StandardProgram {
    /// Hele rejsen som én ordnet række uger (alle 20 uger).
    public static let journey = TrainingProgram(weeks: makeWeeks())

    /// Grundforløbet: de tidlige faser ("Første skridt" + "Bygger op").
    public static var base: TrainingProgram {
        TrainingProgram(weeks: journey.weeks.filter { $0.phase == .base })
    }

    private static func makeWeeks() -> [ProgramWeek] {
        CouchToRunnerPlan.weeks.map { week in
            ProgramWeek(
                id: week.id,
                phase: programPhase(for: week.phase),
                titleKey: week.titleKey,
                session: representativeSession(for: week)
            )
        }
    }

    /// Afbild planens fem faser ind på forløbs-modellens fire faser.
    private static func programPhase(for phase: PlanPhase) -> ProgramPhase {
        switch phase {
        case .firstSteps, .buildingUp: .base
        case .findingStrength: .maintain
        case .confidentRunner: .towardFiveKilometre
        case .continuousRunner: .beyond
        }
    }

    /// Ugens repræsentative tur (den første ikke-bonus-tur) som skabelon.
    private static func representativeSession(for week: PlannedWeek) -> SessionTemplate {
        let session = week.sessions.first { !$0.isBonus } ?? week.sessions[0]
        return .blocks(warmUp: session.warmUp, blocks: session.blocks, coolDown: session.coolDown)
    }
}
