import Foundation

/// Skabelon for én træningstur i forløbet. En skabelon ved, hvordan den bygger
/// en konkret `WorkoutPlan`, og hvordan antallet af gentagelser (eller løbets
/// længde) skaleres efter, hvor mange ture brugeren har valgt for ugen
/// (jf. spec afsnit 6.1 og 6.2).
public enum SessionTemplate: Sendable, Equatable, Codable {
    /// Vekslende gå/løb: opvarmning → `reps` × (løb + gå) → nedkøling.
    /// `reps` er et interval (fx 6...8); det konkrete antal vælges ud fra ugens
    /// træningsantal.
    case intervals(
        warmUp: Duration,
        run: Duration,
        walk: Duration,
        reps: ClosedRange<Int>,
        coolDown: Duration
    )

    /// Sammenhængende løb: opvarmning → ét løb → nedkøling. Løbets længde vælges
    /// inden for `run`-intervallet ud fra ugens træningsantal.
    case continuous(
        warmUp: Duration,
        run: ClosedRange<Duration>,
        coolDown: Duration
    )

    /// En blid, valgfri gå-tur — bruges som ekstra tur i en uge, hvor brugeren
    /// har valgt flere ture, end forløbet kræver, så den sikre progression ikke
    /// overskrides (jf. spec afsnit 6.2: "den kan i stedet lægge en let gå-tur ind").
    case easyWalk(duration: Duration)

    /// En fast tur defineret som eksplicitte blokke (jf. docs/loebeplan.md) —
    /// opvarmning → blokke af `reps` × (løb + gang) → nedkøling. Bruges af det
    /// indbyggede 20-ugers program, hvor hver uges tur er nøjagtigt fastlagt.
    case blocks(
        warmUp: Duration,
        blocks: [IntervalBlock],
        coolDown: Duration
    )

    /// Byg den konkrete plan for et givet ugentligt træningsantal.
    ///
    /// Færre ture om ugen → flere gentagelser/længere løb pr. tur (mod den øvre
    /// ende), så ugens samlede dosis stadig passer. Flere ture → færre pr. tur
    /// (mod den nedre ende). Resultatet er altid afgrænset af de fagligt
    /// fastsatte intervaller, så progressionen forbliver sikker.
    public func plan(forSessionsPerWeek sessions: Int) -> WorkoutPlan {
        switch self {
        case let .intervals(warmUp, run, walk, reps, coolDown):
            let count = SessionTemplate.scaledInt(in: reps, sessions: sessions)
            var intervals: [Interval] = [.warmUp(warmUp)]
            for _ in 0..<count {
                intervals.append(.run(run))
                intervals.append(.walk(walk))
            }
            intervals.append(.coolDown(coolDown))
            return WorkoutPlan(intervals: intervals)

        case let .continuous(warmUp, run, coolDown):
            let runDuration = SessionTemplate.scaledDuration(in: run, sessions: sessions)
            return WorkoutPlan(intervals: [
                .warmUp(warmUp),
                .run(runDuration),
                .coolDown(coolDown),
            ])

        case let .easyWalk(duration):
            return WorkoutPlan(intervals: [.warmUp(duration)])

        case let .blocks(warmUp, blocks, coolDown):
            var intervals: [Interval] = [.warmUp(warmUp)]
            for block in blocks {
                for _ in 0..<block.reps {
                    intervals.append(.run(block.run))
                    if block.walk > .zero { intervals.append(.walk(block.walk)) }
                }
            }
            intervals.append(.coolDown(coolDown))
            return WorkoutPlan(intervals: intervals)
        }
    }

    // MARK: - Skalering

    /// Afbild ugens træningsantal (1...5) til en værdi i et interval, så færre
    /// ture giver den høje ende og flere ture den lave ende.
    static func scaledInt(in range: ClosedRange<Int>, sessions: Int) -> Int {
        let fraction = sessionFraction(sessions)
        let span = Double(range.upperBound - range.lowerBound)
        let value = Double(range.upperBound) - fraction * span
        return clamp(Int(value.rounded()), lower: range.lowerBound, upper: range.upperBound)
    }

    static func scaledDuration(in range: ClosedRange<Duration>, sessions: Int) -> Duration {
        let fraction = sessionFraction(sessions)
        let lo = Double(range.lowerBound.components.seconds)
        let hi = Double(range.upperBound.components.seconds)
        let value = hi - fraction * (hi - lo)
        return .seconds(value.rounded())
    }

    /// 0.0 ved 1 tur/uge (høj ende) … 1.0 ved ≥5 ture/uge (lav ende).
    private static func sessionFraction(_ sessions: Int) -> Double {
        let clamped = clamp(sessions, lower: 1, upper: 5)
        return Double(clamped - 1) / 4.0
    }
}
