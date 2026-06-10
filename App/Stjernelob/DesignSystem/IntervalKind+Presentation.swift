import StjernelobCore
import SwiftUI

/// Præsentation af intervaltyper: lokaliseret navn, farve og SF Symbol.
/// Samlet ét sted, så løb/gå altid skelnes på både farve, ikon og tekst
/// (aldrig farve alene — tilgængelighed).
extension IntervalKind {
    var label: LocalizedStringResource {
        switch self {
        case .warmUp: Strings.Interval.warmUp
        case .run: Strings.Interval.run
        case .walk: Strings.Interval.walk
        case .coolDown: Strings.Interval.coolDown
        }
    }

    var color: Color {
        switch self {
        case .run: Theme.Colors.running
        case .warmUp, .walk, .coolDown: Theme.Colors.walking
        }
    }

    /// SF Symbol — bærer betydningen sammen med farven.
    var symbolName: String {
        switch self {
        case .warmUp: "figure.walk.motion"
        case .run: "figure.run"
        case .walk: "figure.walk"
        case .coolDown: "figure.cooldown"
        }
    }
}
