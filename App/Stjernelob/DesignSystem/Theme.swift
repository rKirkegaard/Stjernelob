import SwiftUI

/// Designsystemets farver, afstande og typografi.
///
/// Tonen er varm og legende (jf. spec afsnit 2). Farver bruges aldrig som
/// eneste signal — tekst og SF Symbols følger med, så appen virker for
/// farveblinde og uden lyd (tilgængelighedskrav i `swift-style.md`). Skriftstil
/// bruger Dynamic Type-tekststile, så alt skalerer med brugerens valg.
enum Theme {
    enum Colors {
        /// Varm primærfarve (stjerne-lilla).
        static let brand = Color(.sRGB, red: 0.45, green: 0.36, blue: 0.86)
        /// Opmuntrende sekundærfarve.
        static let accent = Color(.sRGB, red: 0.20, green: 0.70, blue: 0.62)
        /// Stjernernes guld.
        static let star = Color(.sRGB, red: 0.98, green: 0.76, blue: 0.18)
        /// Rolig farve til hviledage.
        static let restful = Color(.sRGB, red: 0.36, green: 0.62, blue: 0.86)
        /// Løb (bevægelse) vs. gang (ro) — adskilles også af ikon og tekst.
        static let running = Color(.sRGB, red: 0.90, green: 0.45, blue: 0.30)
        static let walking = Color(.sRGB, red: 0.30, green: 0.66, blue: 0.78)
    }

    enum Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let xLarge: CGFloat = 40
    }

    enum Radius {
        static let card: CGFloat = 16
        static let button: CGFloat = 14
    }
}

extension Font {
    /// Det meget store tal under en tur (interval-nedtælling), så det kan ses i
    /// et hurtigt blik. Skalerer stadig med Dynamic Type.
    static var runCountdown: Font {
        .system(size: 88, weight: .bold, design: .rounded).monospacedDigit()
    }

    /// Overskrift med rund, venlig stil.
    static var friendlyTitle: Font {
        .system(.largeTitle, design: .rounded).weight(.bold)
    }
}
