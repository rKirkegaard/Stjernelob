import Foundation

/// En blid bekymring ved en egen/importeret plan. Den **blokerer aldrig** — den
/// peger kun mod en blødere vej (spec afsnit 6 + hovedspec afsnit 6). App-laget
/// oversætter til en venlig, ikke-dømmende besked.
public enum PlanConcern: String, Sendable, Equatable, Codable, CaseIterable {
    /// Første uge er et stort spring fra det, hun løber nu.
    case bigJumpFromCurrentLevel
    /// Den ugentlige løbetid stiger hurtigere end den blide ~10 %-regel.
    case fastWeeklyIncrease
    /// Næsten løb hver dag — for få hviledage.
    case tooFewRestDays
    /// En enkelt tur er meget lang for en begynder.
    case veryLongWorkout
}

/// Resultatet af et plan-tjek. `isGentle` betyder ingen bekymringer.
public struct PlanValidation: Sendable, Equatable {
    public let concerns: [PlanConcern]
    public var isGentle: Bool { concerns.isEmpty }

    public init(concerns: [PlanConcern]) {
        self.concerns = concerns
    }
}

/// Tjekker en egen/importeret plan mod de samme blide principper som det
/// indbyggede program: ikke et for stort spring, maks ~10 % mere løbetid om ugen,
/// bevarede hviledage og en rimelig turlængde for en begynder. Rene regler, ingen
/// tilstand — testbare isoleret (jf. rules/test.md).
public enum PlanValidator {
    /// Tilladt ugentlig stigning i løbetid (~10 %, med lidt slip for afrunding).
    static let maxWeeklyGrowth = 1.15
    /// Et "stort spring" fra nuværende niveau: mere end 50 % over på første uge.
    static let bigJumpFactor = 1.5
    /// Flest ture i en uge før det regnes som for få hviledage.
    static let maxSessionsPerWeek = 5
    /// Længste rimelige samlede turvarighed for en begynder.
    static let maxWorkoutSeconds: Double = 75 * 60

    public static func review(
        plan: TrainingPlan,
        currentWeeklyRunSeconds: Double = 0
    ) -> PlanValidation {
        var concerns: [PlanConcern] = []
        let weeks = plan.weekNumbers
        let runByWeek = weeks.map { runSeconds(in: plan, week: $0) }

        // Stort spring fra nuværende niveau (kun når vi kender et niveau).
        if currentWeeklyRunSeconds > 0, let first = runByWeek.first,
           first > currentWeeklyRunSeconds * bigJumpFactor
        {
            concerns.append(.bigJumpFromCurrentLevel)
        }

        // For hurtig ugentlig stigning.
        if zip(runByWeek, runByWeek.dropFirst())
            .contains(where: { previous, next in
                previous > 0 && next > previous * maxWeeklyGrowth
            })
        {
            concerns.append(.fastWeeklyIncrease)
        }

        // For få hviledage (løb næsten hver dag).
        if weeks.contains(where: { plan.workouts(inWeek: $0).count > maxSessionsPerWeek }) {
            concerns.append(.tooFewRestDays)
        }

        // Meget lang enkelt-tur.
        if plan.schedule.contains(where: { totalSeconds(of: $0.workout) > maxWorkoutSeconds }) {
            concerns.append(.veryLongWorkout)
        }

        return PlanValidation(concerns: concerns)
    }

    /// Samlet løbetid (sekunder) i en uge — kun løbeintervaller, kun tids-trin.
    private static func runSeconds(in plan: TrainingPlan, week: Int) -> Double {
        plan.workouts(inWeek: week).reduce(0) { sum, workout in
            sum + workout.steps.reduce(0) { stepSum, step in
                guard step.kind == .run, case let .time(duration) = step.measure else {
                    return stepSum
                }
                return stepSum + Double(duration.components.seconds)
            }
        }
    }

    /// Samlet varighed (sekunder) af en tur — alle tids-trin.
    private static func totalSeconds(of workout: Workout) -> Double {
        workout.steps.reduce(0) { sum, step in
            guard case let .time(duration) = step.measure else { return sum }
            return sum + Double(duration.components.seconds)
        }
    }
}
