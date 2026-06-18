import Foundation

/// Fejl ved import af en plan — oversættes til en venlig besked i app-laget
/// (spec afsnit 10). Bevidst få, ikke-tekniske tilfælde.
public enum PlanImportError: Error, Equatable {
    /// Filen kunne slet ikke læses/afkodes som en plan.
    case unreadable
    /// Filen var gyldig JSON, men indeholdt ingen brugbare ture.
    case empty
}

/// Afkoder appens eget, enkle planformat (spec afsnit 5.2) til en `TrainingPlan`.
/// Varigheder er i sekunder; `type` er `opvarmning`, `loeb`, `gaa` eller
/// `nedkoeling`. Ukendte felter ignoreres robust; ugyldige filer giver en venlig
/// fejl. Det interne format er kilden til sandhed — eksterne formater kan senere
/// få egne mappere ovenpå dette.
public enum TrainingPlanImporter {
    public static let currentVersion = 1

    public static func decode(_ data: Data) throws -> TrainingPlan {
        let file: PlanFile
        do {
            file = try JSONDecoder().decode(PlanFile.self, from: data)
        } catch {
            throw PlanImportError.unreadable
        }

        let schedule: [ScheduledWorkout] = (file.uger ?? []).flatMap { week -> [ScheduledWorkout] in
            (week.ture ?? []).enumerated().compactMap { index, session in
                let steps = session.blokke.map(\.step).expandedRepeated(session.gentag ?? 1)
                guard !steps.isEmpty else { return nil }
                let name = "\(weekWord) \(week.uge) · \(sessionWord) \(index + 1)"
                return ScheduledWorkout(
                    week: week.uge,
                    workout: Workout(name: name, steps: steps)
                )
            }
        }

        guard !schedule.isEmpty else { throw PlanImportError.empty }

        return TrainingPlan(
            name: file.navn?.isEmpty == false ? file.navn! : defaultName,
            source: .imported,
            schedule: schedule
        )
    }

    // Navne-stumper holdes som rå strenge her (domænet er UI-frit); app-laget kan
    // vise et pænere, fuldt lokaliseret navn.
    private static let weekWord = "Uge"
    private static let sessionWord = "Tur"
    private static let defaultName = "Importeret plan"

    // MARK: - Fil-format (danske nøgler, jf. spec afsnit 5.2)

    private struct PlanFile: Decodable {
        let navn: String?
        let version: Int?
        let uger: [PlanWeek]?
    }

    private struct PlanWeek: Decodable {
        let uge: Int
        let ture: [PlanSession]?
    }

    private struct PlanSession: Decodable {
        let blokke: [PlanBlock]
        let gentag: Int?
    }

    private struct PlanBlock: Decodable {
        let type: String
        let sek: Double

        /// Oversæt et fil-blok til et tids-baseret interval-trin. Ukendte typer
        /// bliver til gå (det blideste/sikreste valg).
        var step: IntervalStep {
            let kind: IntervalKind = switch type.lowercased() {
            case "opvarmning": .warmUp
            case "loeb", "løb": .run
            case "nedkoeling", "nedkøling": .coolDown
            default: .walk
            }
            return IntervalStep(kind: kind, measure: .time(.seconds(sek)))
        }
    }
}

private extension [IntervalStep] {
    /// Gentag denne sekvens af trin `times` gange (mindst én gang).
    func expandedRepeated(_ times: Int) -> [IntervalStep] {
        (0..<Swift.max(1, times)).flatMap { _ in self }
    }
}
