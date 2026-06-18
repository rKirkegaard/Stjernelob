import Foundation

/// Hvordan et interval måles. Tid er standard for begyndere; distance er en
/// valgmulighed (men aldrig grundlag for belønning, jf. hovedspec afsnit 3).
/// Distance er modelleret her for import/forward-kompatibilitet — den
/// tidsbaserede intervalmotor kører kun tids-trin (se `timeBasedPlan`).
public enum IntervalMeasure: Sendable, Equatable, Codable {
    case time(Duration)
    case distance(Double) // meter
}

/// Ét trin i en egen-bygget eller importeret tur.
public struct IntervalStep: Sendable, Equatable, Codable {
    public let kind: IntervalKind
    public let measure: IntervalMeasure

    public init(kind: IntervalKind, measure: IntervalMeasure) {
        self.kind = kind
        self.measure = measure
    }

    /// Bekvem tids-konstruktør.
    public static func run(_ duration: Duration) -> IntervalStep {
        .init(kind: .run, measure: .time(duration))
    }

    public static func walk(_ duration: Duration) -> IntervalStep {
        .init(kind: .walk, measure: .time(duration))
    }
}

/// En gentaget blok ("løb 1 min / gå 2 min × 6"). Authoring- og import-bekvem;
/// foldes ud til flade `IntervalStep`s i en `Workout`.
public struct WorkoutBlock: Sendable, Equatable, Codable {
    public var steps: [IntervalStep]
    public var repeats: Int

    public init(steps: [IntervalStep], repeats: Int) {
        self.steps = steps
        self.repeats = repeats
    }
}

public extension [WorkoutBlock] {
    /// Fold blokkene ud til en flad række trin (gentagelser udfoldet).
    func expandedSteps() -> [IntervalStep] {
        flatMap { block in
            (0..<Swift.max(1, block.repeats)).flatMap { _ in block.steps }
        }
    }
}

/// Én tur — en navngivet liste af intervaller. Intervalmotoren afspiller den ens,
/// uanset om den er indbygget, egen-bygget eller importeret.
public struct Workout: Sendable, Equatable, Codable, Identifiable {
    public var id: UUID
    public var name: String
    public var steps: [IntervalStep]

    public init(id: UUID = UUID(), name: String, steps: [IntervalStep]) {
        self.id = id
        self.name = name
        self.steps = steps
    }

    /// Antal løbeintervaller i turen.
    public var runIntervalCount: Int {
        steps.lazy.filter { $0.kind == .run }.count
    }

    /// Byg en kørbar `WorkoutPlan` af turens **tidsbaserede** trin. Lægger
    /// automatisk en opvarmning/nedkøling på, hvis turen ikke selv har dem
    /// (spec afsnit 3). Returnerer `nil`, hvis der ikke er nogen kørbare tids-
    /// intervaller (fx en tom eller rent distance-baseret tur).
    func timeBasedPlan(
        autoWarmUp: Duration = .minutes(5),
        autoCoolDown: Duration = .minutes(5)
    ) -> WorkoutPlan? {
        var intervals: [Interval] = steps.compactMap { step in
            guard case let .time(duration) = step.measure, duration > .zero else { return nil }
            return Interval(kind: step.kind, duration: duration)
        }
        guard intervals.contains(where: { $0.kind == .run || $0.kind == .walk }) else { return nil }
        if intervals.first?.kind != .warmUp {
            intervals.insert(.warmUp(autoWarmUp), at: 0)
        }
        if intervals.last?.kind != .coolDown {
            intervals.append(.coolDown(autoCoolDown))
        }
        return WorkoutPlan(intervals: intervals)
    }
}

/// Hvor en plan/tur kommer fra — bruges bl.a. til kilde-markering i historikken.
public enum PlanSource: String, Sendable, Equatable, Codable {
    case builtIn
    case custom
    case imported
}

/// En tur placeret i en bestemt uge i en plan.
public struct ScheduledWorkout: Sendable, Equatable, Codable {
    public var week: Int
    public var workout: Workout

    public init(week: Int, workout: Workout) {
        self.week = week
        self.workout = workout
    }
}

/// En hel træningsplan (indbygget, egen eller importeret) som ordnede ture pr. uge.
public struct TrainingPlan: Sendable, Equatable, Codable, Identifiable {
    public var id: UUID
    public var name: String
    public var source: PlanSource
    public var schedule: [ScheduledWorkout]

    public init(
        id: UUID = UUID(),
        name: String,
        source: PlanSource,
        schedule: [ScheduledWorkout]
    ) {
        self.id = id
        self.name = name
        self.source = source
        self.schedule = schedule
    }

    /// Ugenumre i planen, sorteret.
    public var weekNumbers: [Int] {
        Set(schedule.map(\.week)).sorted()
    }

    /// Turene i en bestemt uge.
    public func workouts(inWeek week: Int) -> [Workout] {
        schedule.filter { $0.week == week }.map(\.workout)
    }
}
