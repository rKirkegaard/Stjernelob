import Foundation

/// Hvilken slags interval der er tale om i en gå/løb-tur.
///
/// Bemærk at både opvarmning, gå og nedkøling er gå-faser, men holdes adskilt,
/// fordi de coaches og fejres forskelligt (jf. spec afsnit 4).
public enum IntervalKind: String, Codable, Sendable, CaseIterable {
    /// Rask gang i starten af turen (typisk 5 min).
    case warmUp
    /// Et løbeinterval.
    case run
    /// Et gå-interval mellem løbene.
    case walk
    /// Rolig gang til sidst (typisk 5 min).
    case coolDown

    /// Om brugeren løber i dette interval (modsat at gå).
    public var isRunning: Bool { self == .run }
}

/// Ét interval i en tur: en slags og en varighed.
public struct Interval: Codable, Sendable, Equatable {
    public let kind: IntervalKind
    public let duration: Duration

    public init(kind: IntervalKind, duration: Duration) {
        precondition(duration > .zero, "Et interval skal have en positiv varighed")
        self.kind = kind
        self.duration = duration
    }
}

public extension Interval {
    static func warmUp(_ duration: Duration) -> Interval { .init(kind: .warmUp, duration: duration)
    }

    static func run(_ duration: Duration) -> Interval { .init(kind: .run, duration: duration) }
    static func walk(_ duration: Duration) -> Interval { .init(kind: .walk, duration: duration) }
    static func coolDown(_ duration: Duration) -> Interval { .init(
        kind: .coolDown,
        duration: duration
    ) }
}
