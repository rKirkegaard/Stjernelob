import Foundation

/// En komplet plan for én tur: en ordnet række intervaller fra opvarmning til
/// nedkøling. Planen er ren data; den ved intet om tid, ure eller afspilning.
/// Det er `IntervalEngine`, der "kører" en plan.
public struct WorkoutPlan: Codable, Sendable, Equatable {
    public let intervals: [Interval]

    public init(intervals: [Interval]) {
        precondition(!intervals.isEmpty, "En tur skal have mindst ét interval")
        self.intervals = intervals
    }

    /// Samlet planlagt varighed for hele turen.
    public var totalDuration: Duration {
        intervals.reduce(.zero) { $0 + $1.duration }
    }

    /// Antal løbeintervaller i planen — bruges bl.a. til visningen
    /// "Interval 3 af 6" (jf. spec afsnit 4.1).
    public var runIntervalCount: Int {
        intervals.lazy.filter { $0.kind == .run }.count
    }
}
