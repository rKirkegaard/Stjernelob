import Foundation

/// Brugerens placering i forløbet — egnet til persistering.
public struct ProgressionState: Sendable, Equatable, Codable {
    /// Indeks i `program.weeks`.
    public var weekIndex: Int

    public init(weekIndex: Int = 0) {
        self.weekIndex = weekIndex
    }
}

/// Holder styr på, hvor i forløbet brugeren er, og flytter hende blidt frem,
/// gentager eller går et trin tilbage ud fra ugens resultater (jf. spec
/// afsnit 6.1–6.2). Et trin tilbage føles aldrig som et nederlag — det er bare
/// vejen til at det passer hende.
public struct ProgressionEngine: Sendable, Equatable {
    public let program: TrainingProgram
    public private(set) var state: ProgressionState

    /// Hvor mange løbeture en uge højst lægger op til for en begynder. Vælger
    /// brugeren flere ture, bliver de ekstra til blide gå-ture, så den sikre
    /// progression ikke overskrides (spec afsnit 6.2).
    public var maxRunningSessionsPerWeek: Int = 4

    public init(
        program: TrainingProgram = StandardProgram.journey,
        state: ProgressionState = ProgressionState()
    ) {
        self.program = program
        self.state = state
    }

    public var currentWeek: ProgramWeek {
        program.week(at: state.weekIndex)
    }

    public var isOnFinalWeek: Bool {
        state.weekIndex >= program.lastWeekIndex
    }

    /// Flyt placeringen efter en beslutning. `advance` på sidste uge bliver
    /// stående (videre-forløbets sidste fase kan gentages).
    public mutating func apply(_ decision: ProgressionDecision) {
        switch decision {
        case .advance:
            state.weekIndex = min(state.weekIndex + 1, program.lastWeekIndex)
        case .repeatWeek:
            break
        case .stepBack:
            state.weekIndex = max(state.weekIndex - 1, program.firstWeekIndex)
        }
    }

    /// Vurdér ugens resultater, anvend beslutningen, og returnér den (så UI kan
    /// forklare blidt, hvad der sker).
    @discardableResult
    public mutating func completeWeek(outcomes: [SessionOutcome]) -> ProgressionDecision {
        let decision = ProgressionPolicy.decide(outcomes: outcomes)
        apply(decision)
        return decision
    }

    /// Ugens konkrete ture for et valgt ugentligt træningsantal. Løbeture
    /// (skaleret efter antallet) plus eventuelle ekstra blide gå-ture.
    public func weeklyPlans(forSessionsPerWeek sessions: Int) -> [WorkoutPlan] {
        let total = clamp(sessions, lower: 1, upper: 7)
        let runningSessions = min(total, maxRunningSessionsPerWeek)
        let week = currentWeek

        var plans = (0..<runningSessions).map { _ in
            week.plan(forSessionsPerWeek: total)
        }
        let extraWalks = total - runningSessions
        if extraWalks > 0 {
            let walk = SessionTemplate.easyWalk(duration: .minutes(20))
                .plan(forSessionsPerWeek: total)
            plans += Array(repeating: walk, count: extraWalks)
        }
        return plans
    }
}
