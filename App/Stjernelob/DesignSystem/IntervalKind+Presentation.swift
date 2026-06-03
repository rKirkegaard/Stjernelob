import SwiftUI
import StjernelobCore

/// Præsentation af intervaltyper: lokaliseret navn, farve og SF Symbol.
/// Samlet ét sted, så løb/gå altid skelnes på både farve, ikon og tekst
/// (aldrig farve alene — tilgængelighed).
extension IntervalKind {
    var label: LocalizedStringResource {
        switch self {
        case .warmUp: return Strings.Interval.warmUp
        case .run: return Strings.Interval.run
        case .walk: return Strings.Interval.walk
        case .coolDown: return Strings.Interval.coolDown
        }
    }

    var color: Color {
        switch self {
        case .run: return Theme.Colors.running
        case .warmUp, .walk, .coolDown: return Theme.Colors.walking
        }
    }

    /// SF Symbol — bærer betydningen sammen med farven.
    var symbolName: String {
        switch self {
        case .warmUp: return "figure.walk.motion"
        case .run: return "figure.run"
        case .walk: return "figure.walk"
        case .coolDown: return "figure.cooldown"
        }
    }
}
