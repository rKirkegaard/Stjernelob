import Foundation

@inline(__always)
func clamp<T: Comparable>(_ value: T, lower: T, upper: T) -> T {
    min(max(value, lower), upper)
}

/// En ren, deterministisk model af en turs tidslinje.
///
/// `WorkoutTimeline` indeholder ingen tilstand og intet ur. Den kan svare på to
/// slags spørgsmål for et hvilket som helst tidspunkt:
///
/// 1. **Hvad er tilstanden?** — `snapshot(at:phase:)` og `summary(at:isComplete:)`.
/// 2. **Hvilke hændelser ligger hvornår?** — `scheduledEvents()` udregner én gang
///    for alle, hvornår hvert intervalskift, hver nedtælling, halvvejs-punktet og
///    målgang indtræffer.
///
/// Fordi hændelser er bundet til *absolutte* tidspunkter på tidslinjen (ikke
/// akkumuleret tick for tick), kan motoren ikke "drive" tidsmæssigt: uanset hvor
/// ujævnt den bliver kaldt, udløses hvert skift på det rigtige sekund.
public struct WorkoutTimeline: Sendable, Equatable {
    public let plan: WorkoutPlan
    /// Sluttidspunktet (akkumuleret) for hvert interval.
    private let cumulativeEnd: [Duration]

    public init(plan: WorkoutPlan) {
        self.plan = plan
        var running: Duration = .zero
        var ends: [Duration] = []
        ends.reserveCapacity(plan.intervals.count)
        for interval in plan.intervals {
            running += interval.duration
            ends.append(running)
        }
        cumulativeEnd = ends
    }

    public var totalDuration: Duration { cumulativeEnd.last ?? .zero }

    /// Starttidspunktet for et interval på tidslinjen.
    public func start(ofInterval index: Int) -> Duration {
        index == 0 ? .zero : cumulativeEnd[index - 1]
    }

    /// Indekset for det interval, der er aktivt på et givet tidspunkt. Ved eller
    /// efter målgang returneres det sidste interval.
    public func intervalIndex(at elapsed: Duration) -> Int {
        for (index, end) in cumulativeEnd.enumerated() where end > elapsed {
            return index
        }
        return plan.intervals.count - 1
    }

    /// Hvilket løbeinterval i rækken (1-baseret) et givet indeks er, eller `nil`
    /// hvis det ikke er et løbeinterval.
    private func runOrdinal(forIntervalAt index: Int) -> Int? {
        guard plan.intervals[index].kind == .run else { return nil }
        var count = 0
        for i in 0...index where plan.intervals[i].kind == .run {
            count += 1
        }
        return count
    }

    public func snapshot(at rawElapsed: Duration, phase: WorkoutSnapshot.Phase) -> WorkoutSnapshot {
        let total = totalDuration
        let elapsed = clamp(rawElapsed, lower: .zero, upper: total)
        let index = intervalIndex(at: elapsed)
        let interval = plan.intervals[index]
        let intervalStart = start(ofInterval: index)
        let elapsedIn = clamp(elapsed - intervalStart, lower: .zero, upper: interval.duration)
        let remainingIn = interval.duration - elapsedIn
        return WorkoutSnapshot(
            phase: phase,
            intervalIndex: index,
            interval: interval,
            elapsedInInterval: elapsedIn,
            remainingInInterval: remainingIn,
            totalElapsed: elapsed,
            totalRemaining: total - elapsed,
            runOrdinal: runOrdinal(forIntervalAt: index),
            runCount: plan.runIntervalCount
        )
    }

    /// Antal intervaller, der er fuldt gennemført ved et givet tidspunkt.
    public func intervalsCompleted(at elapsed: Duration) -> Int {
        cumulativeEnd.lazy.filter { $0 <= elapsed }.count
    }

    public func summary(at rawElapsed: Duration, isComplete: Bool) -> WorkoutSummary {
        let total = totalDuration
        let elapsed = clamp(rawElapsed, lower: .zero, upper: total)
        let completed = intervalsCompleted(at: elapsed)
        let completedRunDurations = zip(plan.intervals, cumulativeEnd)
            .filter { $0.0.kind == .run && $0.1 <= elapsed }
            .map(\.0.duration)
        let runsCompleted = completedRunDurations.count
        // Det længste fuldt gennemførte løbeinterval = det længste sammenhængende
        // løb (løb adskilles altid af gå-intervaller i en gå/løb-tur).
        let longestRun = completedRunDurations.max() ?? .zero
        return WorkoutSummary(
            plannedDuration: total,
            activeDuration: elapsed,
            intervalsCompleted: completed,
            plannedIntervalCount: plan.intervals.count,
            runIntervalsCompleted: runsCompleted,
            isComplete: isComplete,
            longestRunInterval: longestRun
        )
    }

    // MARK: - Hændelsesplan

    /// En hændelse bundet til et absolut tidspunkt på tidslinjen. `order`
    /// bryder uafgjorte ved sammenfaldende tidspunkter, så rækkefølgen er
    /// veldefineret (fx "interval gennemført" før "næste interval startet").
    struct ScheduledEvent: Equatable {
        let time: Duration
        let order: Int
        let event: WorkoutEvent
    }

    /// Udregn alle tidsbestemte hændelser for turen, sorteret efter tidspunkt.
    /// `started`/`intervalStarted(0)` ved t=0 udsendes af motoren ved `start()`
    /// og indgår derfor ikke her.
    func scheduledEvents() -> [ScheduledEvent] {
        var events: [ScheduledEvent] = []
        let total = totalDuration
        let lastIndex = plan.intervals.count - 1

        for index in plan.intervals.indices {
            let boundary = cumulativeEnd[index]
            let intervalStart = start(ofInterval: index)

            // Nedtælling: 3, 2, 1 sekunder før dette interval slutter.
            for secondsRemaining in [3, 2, 1] {
                let tickTime = boundary - .seconds(secondsRemaining)
                if tickTime > intervalStart {
                    events.append(.init(
                        time: tickTime,
                        order: 0,
                        event: .countdown(secondsRemaining: secondsRemaining)
                    ))
                }
            }

            // Interval gennemført.
            events.append(.init(
                time: boundary,
                order: 1,
                event: .intervalCompleted(
                    index: index,
                    interval: plan.intervals[index]
                )
            ))

            if index < lastIndex {
                // Næste interval starter.
                let next = plan.intervals[index + 1]
                events.append(.init(
                    time: boundary,
                    order: 2,
                    event: .intervalStarted(index: index + 1, interval: next)
                ))
            } else {
                // Sidste interval slut = målgang.
                events.append(.init(
                    time: boundary,
                    order: 3,
                    event: .finished(summary: summary(
                        at: total,
                        isComplete: true
                    ))
                ))
            }
        }

        // Halvvejs i turen.
        let half = total / 2
        if half > .zero, half < total {
            events.append(.init(time: half, order: 1, event: .halfway))
        }

        return events.sorted { lhs, rhs in
            lhs.time == rhs.time ? lhs.order < rhs.order : lhs.time < rhs.time
        }
    }
}
