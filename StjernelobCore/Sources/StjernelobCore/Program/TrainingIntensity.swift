import Foundation

/// Brugerens selvvalgte sværhedsgrad, der skalerer hver tur op eller ned.
/// Tid — aldrig fart eller distance (jf. velbefindende-reglerne): "hårdere" =
/// lidt længere løb og kortere gå-pauser, "lettere" = omvendt. Det er et frit,
/// vedvarende valg, og den blide auto-progression i forløbet gælder stadig
/// ovenpå. Standard er `.standard` (planen som den er).
public enum TrainingIntensity: String, Codable, Sendable, CaseIterable, Identifiable {
    case lighter
    case standard
    case harder

    public var id: String { rawValue }

    /// Faktor for løbeintervaller (mere løb = hårdere). "Hårdere" holdes bevidst
    /// inden for ~10 % (jf. "blid, gradvis progression, maks ~10 % mere om ugen"),
    /// så den ikke lægger for meget oven på forløbets egen ugentlige progression.
    /// "Lettere" må gerne lette mere generøst.
    private var runFactor: Double {
        switch self {
        case .lighter: 0.8
        case .standard: 1
        case .harder: 1.1
        }
    }

    /// Faktor for gå-pauser (kortere pause = hårdere). "Hårdere" forkorter højst
    /// ~10 % af restitutionspausen.
    private var walkFactor: Double {
        switch self {
        case .lighter: 1.2
        case .standard: 1
        case .harder: 0.9
        }
    }

    /// Skalér en plans løb og gå-pauser efter sværhedsgraden. Opvarmning og
    /// nedkøling røres aldrig (de er tryghed/restitution), og der er gulve, så et
    /// løb eller en pause aldrig bliver for kort. Ren funktion — testbar isoleret.
    public func scaled(_ plan: WorkoutPlan) -> WorkoutPlan {
        guard self != .standard else { return plan }
        let intervals = plan.intervals.map { interval -> Interval in
            switch interval.kind {
            case .run:
                Interval(kind: .run, duration: Self.scale(
                    interval.duration, by: runFactor, floorSeconds: 10
                ))
            case .walk:
                Interval(kind: .walk, duration: Self.scale(
                    interval.duration, by: walkFactor, floorSeconds: 15
                ))
            case .warmUp, .coolDown:
                interval
            }
        }
        return WorkoutPlan(intervals: intervals)
    }

    private static func scale(
        _ duration: Duration,
        by factor: Double,
        floorSeconds: Int
    ) -> Duration {
        let scaled = Int((Double(duration.components.seconds) * factor).rounded())
        return .seconds(max(floorSeconds, scaled))
    }
}
