import Foundation
import SwiftUI
import StjernelobCore

/// Én bevægelse i opvarmnings-/nedkølingsguiden.
struct GuideMove: Identifiable {
    let id = UUID()
    let symbol: String
    let text: LocalizedStringResource
}

/// Korte, konkrete bevægelser til de 5 min gang før og efter turen
/// (skadesforebyggelse). Dynamiske bevægelser før, blid udstrækning efter.
enum MovementGuide {
    static let warmUp: [GuideMove] = [
        GuideMove(symbol: "figure.walk", text: Strings.Guide.warmUpBrisk),
        GuideMove(symbol: "figure.highintensity.intervaltraining", text: Strings.Guide.warmUpKnees),
        GuideMove(symbol: "figure.flexibility", text: Strings.Guide.warmUpAnkles),
    ]

    static let coolDown: [GuideMove] = [
        GuideMove(symbol: "figure.walk", text: Strings.Guide.coolDownWalk),
        GuideMove(symbol: "figure.cooldown", text: Strings.Guide.coolDownThighs),
        GuideMove(symbol: "figure.flexibility", text: Strings.Guide.coolDownShake),
    ]

    /// Guiden for et givet interval (kun opvarmning og nedkøling har en).
    static func moves(for kind: IntervalKind) -> [GuideMove] {
        switch kind {
        case .warmUp: return warmUp
        case .coolDown: return coolDown
        case .run, .walk: return []
        }
    }

    static func title(for kind: IntervalKind) -> LocalizedStringResource? {
        switch kind {
        case .warmUp: return Strings.Guide.warmUpTitle
        case .coolDown: return Strings.Guide.coolDownTitle
        case .run, .walk: return nil
        }
    }
}
