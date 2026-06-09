import SwiftUI
import StjernelobCore

/// Præsentation af kropssignalet efter en tur: label og symbol. Tonen er
/// omsorgsfuld — aldrig dømmende (jf. velbefindende-reglerne).
extension BodySignal {
    var displayLabel: LocalizedStringResource {
        switch self {
        case .allGood: return Strings.Summary.bodyAllGood
        case .goodSore: return Strings.Summary.bodyGoodSore
        case .specificPain: return Strings.Summary.bodySpecificPain
        }
    }

    var symbolName: String {
        switch self {
        case .allGood: return "checkmark.circle.fill"
        case .goodSore: return "figure.cooldown"
        case .specificPain: return "bandage.fill"
        }
    }

    var tint: Color {
        switch self {
        case .allGood: return Theme.Colors.accent
        case .goodSore: return Theme.Colors.restful
        case .specificPain: return Theme.Colors.running
        }
    }
}
