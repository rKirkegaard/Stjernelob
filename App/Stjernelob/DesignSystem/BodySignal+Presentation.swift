import StjernelobCore
import SwiftUI

/// Præsentation af kropssignalet efter en tur: label og symbol. Tonen er
/// omsorgsfuld — aldrig dømmende (jf. velbefindende-reglerne).
extension BodySignal {
    var displayLabel: LocalizedStringResource {
        switch self {
        case .allGood: Strings.Summary.bodyAllGood
        case .goodSore: Strings.Summary.bodyGoodSore
        case .specificPain: Strings.Summary.bodySpecificPain
        }
    }

    var symbolName: String {
        switch self {
        case .allGood: "checkmark.circle.fill"
        case .goodSore: "figure.cooldown"
        case .specificPain: "bandage.fill"
        }
    }

    var tint: Color {
        switch self {
        case .allGood: Theme.Colors.accent
        case .goodSore: Theme.Colors.restful
        case .specificPain: Theme.Colors.running
        }
    }
}
