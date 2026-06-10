// GENERERET fra docs/loebeplan.md — redigér planen i doc'en og regenerér.
import Foundation

/// Sværhedsgrad for en programuge (jf. docs/loebeplan.md).
public enum PlanDifficulty: String, Sendable, Codable, CaseIterable {
    case easy, gentle, medium, strong, advanced
}

/// De fem faser i rejsen fra sofa til løber.
public enum PlanPhase: String, Sendable, Codable, CaseIterable {
    case firstSteps, buildingUp, findingStrength, confidentRunner, continuousRunner
    /// Lokaliseringsnøgle for fasens navn.
    public var titleKey: String { "program.phase.\(rawValue)" }
}

/// Én blok i en tur: et antal gentagelser af løb (+ evt. efterfølgende gang).
public struct IntervalBlock: Sendable, Equatable, Codable {
    public let run: Duration
    public let walk: Duration
    public let reps: Int
    public init(run: Duration, walk: Duration, reps: Int) {
        self.run = run; self.walk = walk; self.reps = reps
    }
}

/// Én planlagt tur i en uge (Tur 1/2/3). Bygger en konkret `WorkoutPlan`.
public struct PlannedSession: Sendable, Equatable, Codable, Identifiable {
    public let id: Int
    public let isBonus: Bool
    public let warmUp: Duration
    public let blocks: [IntervalBlock]
    public let coolDown: Duration
    public init(
        id: Int,
        isBonus: Bool,
        warmUp: Duration,
        blocks: [IntervalBlock],
        coolDown: Duration
    ) {
        self.id = id; self.isBonus = isBonus; self.warmUp = warmUp
        self.blocks = blocks; self.coolDown = coolDown
    }

    /// Den konkrete tur: opvarmning → blokke (løb/gang) → nedkøling.
    public func workoutPlan() -> WorkoutPlan {
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

/// Én uge i programmet med dens ture og blide metadata.
public struct PlannedWeek: Sendable, Equatable, Identifiable {
    public let id: Int
    public let phase: PlanPhase
    public let difficulty: PlanDifficulty
    public let badge: Badge?
    public let sessions: [PlannedSession]
    public var titleKey: String { "program.week.\(id).title" }
    public var tipKey: String { "program.week.\(id).tip" }
    /// Påkrævede ture for at ugen tæller som gennemført (ekskl. bonus).
    public var requiredSessionCount: Int { sessions.filter { !$0.isBonus }.count }
}

/// Det fulde 20-ugers program — produktets sandhed (jf. docs/loebeplan.md).
public enum CouchToRunnerPlan {
    public static let totalWeeks = 20
    public static let weeks: [PlannedWeek] = [
        PlannedWeek(
            id: 1,
            phase: .firstSteps,
            difficulty: .easy,
            badge: Badge(rawValue: "første-skridt"),
            sessions: [
                PlannedSession(
                    id: 1,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(20), walk: .seconds(90), reps: 4)],
                    coolDown: .minutes(3)
                ),
                PlannedSession(
                    id: 2,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(20), walk: .seconds(90), reps: 4)],
                    coolDown: .minutes(3)
                ),
            ]
        ),
        PlannedWeek(
            id: 2,
            phase: .firstSteps,
            difficulty: .easy,
            badge: Badge(rawValue: "2-i-en-uge"),
            sessions: [
                PlannedSession(
                    id: 1,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(20), walk: .seconds(80), reps: 5)],
                    coolDown: .minutes(3)
                ),
                PlannedSession(
                    id: 2,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(25), walk: .seconds(80), reps: 5)],
                    coolDown: .minutes(3)
                ),
                PlannedSession(
                    id: 3,
                    isBonus: true,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(25), walk: .seconds(90), reps: 4)],
                    coolDown: .minutes(3)
                ),
            ]
        ),
        PlannedWeek(
            id: 3,
            phase: .firstSteps,
            difficulty: .easy,
            badge: Badge(rawValue: "3-ugers-streak"),
            sessions: [
                PlannedSession(
                    id: 1,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(30), walk: .seconds(75), reps: 5)],
                    coolDown: .minutes(3)
                ),
                PlannedSession(
                    id: 2,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(40), walk: .seconds(75), reps: 5)],
                    coolDown: .minutes(3)
                ),
                PlannedSession(
                    id: 3,
                    isBonus: true,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(40), walk: .seconds(80), reps: 5)],
                    coolDown: .minutes(3)
                ),
            ]
        ),
        PlannedWeek(
            id: 4,
            phase: .firstSteps,
            difficulty: .easy,
            badge: Badge(rawValue: "maanedshelt"),
            sessions: [
                PlannedSession(
                    id: 1,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(45), walk: .seconds(60), reps: 6)],
                    coolDown: .minutes(3)
                ),
                PlannedSession(
                    id: 2,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(60), walk: .seconds(60), reps: 5)],
                    coolDown: .minutes(3)
                ),
                PlannedSession(
                    id: 3,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(60), walk: .seconds(75), reps: 6)],
                    coolDown: .minutes(3)
                ),
            ]
        ),
        PlannedWeek(
            id: 5,
            phase: .buildingUp,
            difficulty: .gentle,
            badge: Badge(rawValue: "ubrydelig"),
            sessions: [
                PlannedSession(
                    id: 1,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(60), walk: .seconds(60), reps: 6)],
                    coolDown: .minutes(3)
                ),
                PlannedSession(
                    id: 2,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(75), walk: .seconds(60), reps: 6)],
                    coolDown: .minutes(3)
                ),
                PlannedSession(
                    id: 3,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(90), walk: .seconds(60), reps: 5)],
                    coolDown: .minutes(3)
                ),
            ]
        ),
        PlannedWeek(
            id: 6,
            phase: .buildingUp,
            difficulty: .gentle,
            badge: Badge(rawValue: "en-uge-i-traek"),
            sessions: [
                PlannedSession(
                    id: 1,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(90), walk: .seconds(45), reps: 6)],
                    coolDown: .minutes(3)
                ),
                PlannedSession(
                    id: 2,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(120), walk: .seconds(45), reps: 5)],
                    coolDown: .minutes(3)
                ),
                PlannedSession(
                    id: 3,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(120), walk: .seconds(60), reps: 5)],
                    coolDown: .minutes(3)
                ),
            ]
        ),
        PlannedWeek(
            id: 7,
            phase: .buildingUp,
            difficulty: .gentle,
            badge: Badge(rawValue: "tilbage-igen"),
            sessions: [
                PlannedSession(
                    id: 1,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(120), walk: .seconds(45), reps: 6)],
                    coolDown: .minutes(3)
                ),
                PlannedSession(
                    id: 2,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(150), walk: .seconds(45), reps: 5)],
                    coolDown: .minutes(3)
                ),
                PlannedSession(
                    id: 3,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(150), walk: .seconds(60), reps: 5)],
                    coolDown: .minutes(3)
                ),
            ]
        ),
        PlannedWeek(
            id: 8,
            phase: .buildingUp,
            difficulty: .gentle,
            badge: Badge(rawValue: "maanedshelt"),
            sessions: [
                PlannedSession(
                    id: 1,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(150), walk: .seconds(45), reps: 6)],
                    coolDown: .minutes(3)
                ),
                PlannedSession(
                    id: 2,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(180), walk: .seconds(45), reps: 5)],
                    coolDown: .minutes(3)
                ),
                PlannedSession(
                    id: 3,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(180), walk: .seconds(60), reps: 5)],
                    coolDown: .minutes(3)
                ),
            ]
        ),
        PlannedWeek(
            id: 9,
            phase: .findingStrength,
            difficulty: .medium,
            badge: Badge(rawValue: "3-i-en-uge"),
            sessions: [
                PlannedSession(
                    id: 1,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(180), walk: .seconds(45), reps: 6)],
                    coolDown: .minutes(3)
                ),
                PlannedSession(
                    id: 2,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(210), walk: .seconds(45), reps: 5)],
                    coolDown: .minutes(3)
                ),
                PlannedSession(
                    id: 3,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(240), walk: .seconds(60), reps: 4)],
                    coolDown: .minutes(3)
                ),
            ]
        ),
        PlannedWeek(
            id: 10,
            phase: .findingStrength,
            difficulty: .medium,
            badge: Badge(rawValue: "podcast-runner"),
            sessions: [
                PlannedSession(
                    id: 1,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(240), walk: .seconds(45), reps: 5)],
                    coolDown: .minutes(3)
                ),
                PlannedSession(
                    id: 2,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(270), walk: .seconds(45), reps: 4)],
                    coolDown: .minutes(3)
                ),
                PlannedSession(
                    id: 3,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(300), walk: .seconds(60), reps: 4)],
                    coolDown: .minutes(3)
                ),
            ]
        ),
        PlannedWeek(
            id: 11,
            phase: .findingStrength,
            difficulty: .medium,
            badge: Badge(rawValue: "straek-stjerne"),
            sessions: [
                PlannedSession(
                    id: 1,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(300), walk: .seconds(60), reps: 4)],
                    coolDown: .minutes(3)
                ),
                PlannedSession(
                    id: 2,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(300), walk: .seconds(45), reps: 5)],
                    coolDown: .minutes(3)
                ),
                PlannedSession(
                    id: 3,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(360), walk: .seconds(60), reps: 4)],
                    coolDown: .minutes(3)
                ),
            ]
        ),
        PlannedWeek(
            id: 12,
            phase: .findingStrength,
            difficulty: .medium,
            badge: Badge(rawValue: "maanedshelt"),
            sessions: [
                PlannedSession(
                    id: 1,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(360), walk: .seconds(45), reps: 4)],
                    coolDown: .minutes(3)
                ),
                PlannedSession(
                    id: 2,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(420), walk: .seconds(60), reps: 3)],
                    coolDown: .minutes(3)
                ),
                PlannedSession(
                    id: 3,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(420), walk: .seconds(45), reps: 4)],
                    coolDown: .minutes(3)
                ),
            ]
        ),
        PlannedWeek(
            id: 13,
            phase: .confidentRunner,
            difficulty: .strong,
            badge: Badge(rawValue: "loebemakker"),
            sessions: [
                PlannedSession(
                    id: 1,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(480), walk: .seconds(60), reps: 3)],
                    coolDown: .minutes(3)
                ),
                PlannedSession(
                    id: 2,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(480), walk: .seconds(45), reps: 3)],
                    coolDown: .minutes(3)
                ),
                PlannedSession(
                    id: 3,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(540), walk: .seconds(60), reps: 3)],
                    coolDown: .minutes(3)
                ),
            ]
        ),
        PlannedWeek(
            id: 14,
            phase: .confidentRunner,
            difficulty: .strong,
            badge: Badge(rawValue: "ny-rute"),
            sessions: [
                PlannedSession(
                    id: 1,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(540), walk: .seconds(60), reps: 3)],
                    coolDown: .minutes(3)
                ),
                PlannedSession(
                    id: 2,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(600), walk: .seconds(60), reps: 3)],
                    coolDown: .minutes(3)
                ),
                PlannedSession(
                    id: 3,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(600), walk: .seconds(45), reps: 3)],
                    coolDown: .minutes(3)
                ),
            ]
        ),
        PlannedWeek(
            id: 15,
            phase: .confidentRunner,
            difficulty: .strong,
            badge: Badge(rawValue: "naturpige"),
            sessions: [
                PlannedSession(
                    id: 1,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(600), walk: .seconds(60), reps: 3)],
                    coolDown: .minutes(3)
                ),
                PlannedSession(
                    id: 2,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [
                        IntervalBlock(run: .seconds(720), walk: .seconds(60), reps: 2),
                        IntervalBlock(run: .seconds(600), walk: .seconds(0), reps: 1),
                    ],
                    coolDown: .minutes(3)
                ),
                PlannedSession(
                    id: 3,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(720), walk: .seconds(60), reps: 3)],
                    coolDown: .minutes(3)
                ),
            ]
        ),
        PlannedWeek(
            id: 16,
            phase: .confidentRunner,
            difficulty: .strong,
            badge: Badge(rawValue: "maanedshelt"),
            sessions: [
                PlannedSession(
                    id: 1,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(720), walk: .seconds(60), reps: 3)],
                    coolDown: .minutes(3)
                ),
                PlannedSession(
                    id: 2,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(900), walk: .seconds(60), reps: 2)],
                    coolDown: .minutes(3)
                ),
                PlannedSession(
                    id: 3,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(900), walk: .seconds(60), reps: 2)],
                    coolDown: .minutes(3)
                ),
            ]
        ),
        PlannedWeek(
            id: 17,
            phase: .continuousRunner,
            difficulty: .advanced,
            badge: Badge(rawValue: "loebedagbog"),
            sessions: [
                PlannedSession(
                    id: 1,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(900), walk: .seconds(60), reps: 2)],
                    coolDown: .minutes(3)
                ),
                PlannedSession(
                    id: 2,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(1020), walk: .seconds(60), reps: 2)],
                    coolDown: .minutes(3)
                ),
                PlannedSession(
                    id: 3,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(1080), walk: .seconds(60), reps: 2)],
                    coolDown: .minutes(3)
                ),
            ]
        ),
        PlannedWeek(
            id: 18,
            phase: .continuousRunner,
            difficulty: .advanced,
            badge: Badge(rawValue: "aldrig-give-op"),
            sessions: [
                PlannedSession(
                    id: 1,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(1080), walk: .seconds(60), reps: 2)],
                    coolDown: .minutes(3)
                ),
                PlannedSession(
                    id: 2,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [
                        IntervalBlock(run: .seconds(1200), walk: .seconds(60), reps: 1),
                        IntervalBlock(run: .seconds(900), walk: .seconds(0), reps: 1),
                    ],
                    coolDown: .minutes(3)
                ),
                PlannedSession(
                    id: 3,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(1200), walk: .seconds(60), reps: 2)],
                    coolDown: .minutes(3)
                ),
            ]
        ),
        PlannedWeek(
            id: 19,
            phase: .continuousRunner,
            difficulty: .advanced,
            badge: Badge(rawValue: "fejer-dig-selv"),
            sessions: [
                PlannedSession(
                    id: 1,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(1200), walk: .seconds(60), reps: 2)],
                    coolDown: .minutes(3)
                ),
                PlannedSession(
                    id: 2,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(1200), walk: .seconds(45), reps: 2)],
                    coolDown: .minutes(3)
                ),
                PlannedSession(
                    id: 3,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [
                        IntervalBlock(run: .seconds(1500), walk: .seconds(60), reps: 1),
                        IntervalBlock(run: .seconds(900), walk: .seconds(0), reps: 1),
                    ],
                    coolDown: .minutes(3)
                ),
            ]
        ),
        PlannedWeek(
            id: 20,
            phase: .continuousRunner,
            difficulty: .advanced,
            badge: Badge(rawValue: "ubrydelig"),
            sessions: [
                PlannedSession(
                    id: 1,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [
                        IntervalBlock(run: .seconds(1500), walk: .seconds(60), reps: 1),
                        IntervalBlock(run: .seconds(1200), walk: .seconds(0), reps: 1),
                    ],
                    coolDown: .minutes(3)
                ),
                PlannedSession(
                    id: 2,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(1800), walk: .seconds(0), reps: 1)],
                    coolDown: .minutes(3)
                ),
                PlannedSession(
                    id: 3,
                    isBonus: false,
                    warmUp: .minutes(3),
                    blocks: [IntervalBlock(run: .seconds(1800), walk: .seconds(0), reps: 1)],
                    coolDown: .minutes(5)
                ),
            ]
        ),
    ]

    public static func week(id: Int) -> PlannedWeek? { weeks.first { $0.id == id } }
}
