import StjernelobCore
import SwiftUI

/// Præsentation af badges: emoji, lokaliseret navn/beskrivelse og farvepalet.
/// Alt læses fra `BadgeDefinition` i kataloget — ét sted at vedligeholde, og nye
/// mærker behøver ingen ændringer her. Tonen fejrer fremmøde og små sejre
/// (spec afsnit 5.4) — varmt og opmuntrende, uden fokus på fart/distance.
extension Badge {
    /// Det tegnede mærkes emoji (samme som i SVG-grafikken).
    var emoji: String { definition.emoji }

    /// Den danske kildetekst, pakket som lokaliserbar ressource. (Appen er
    /// dansk-først; teksten ligger i kataloget, ikke hardkodet i views.)
    var displayTitle: LocalizedStringResource {
        LocalizedStringResource(stringLiteral: definition.title)
    }

    var displayDetail: LocalizedStringResource {
        LocalizedStringResource(stringLiteral: definition.detail)
    }

    /// Baggrundsfarve for mærket (matcher SVG-grafikken).
    var paletteBackground: Color { Color(badgeHex: definition.palette.hex.background) }
    /// Tekst-/forgrundsfarve for mærket.
    var paletteInk: Color { Color(badgeHex: definition.palette.hex.ink) }
}

extension BadgePalette {
    /// Konkrete farveværdier for paletten (RGB-hex som "EEEDFE").
    var hex: (background: String, ink: String) {
        switch self {
        case .purple: ("EEEDFE", "26215C")
        case .teal: ("E1F5EE", "085041")
        case .blue: ("E6F1FB", "042C53")
        case .green: ("EAF3DE", "173404")
        case .pink: ("FBEAF0", "4B1528")
        case .sand: ("FAEEDA", "412402")
        }
    }
}

private extension Color {
    /// Laver en farve ud fra en RGB-hex-streng som "EEEDFE".
    init(badgeHex hex: String) {
        let value = UInt64(hex, radix: 16) ?? 0
        self.init(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255
        )
    }
}
