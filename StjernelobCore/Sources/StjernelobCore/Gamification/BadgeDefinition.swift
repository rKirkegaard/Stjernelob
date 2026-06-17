import Foundation

/// Tema-grupper for samlingen (jf. Import/Badges-designet). Rækkefølgen er den,
/// grupperne vises i.
public enum BadgeCategory: String, Codable, Sendable, CaseIterable, Identifiable {
    case firstSteps
    case consistency
    case weather
    case habits
    case social
    case special

    public var id: String { rawValue }
}

/// Navngivet farvepalet for et mærke (matcher den tegnede SVG-samling).
/// Konkrete farveværdier ligger i præsentationslaget, så domænet er fri for UI.
public enum BadgePalette: String, Codable, Sendable, CaseIterable {
    case purple
    case teal
    case blue
    case green
    case pink
    case sand
}

/// En milepæls-stige, hvor kun det næste uopnåede trin vises i samlingen, så den
/// ikke bliver en lang væg af fjerne mål. `nil` for mærker uden for en stige.
public enum BadgeLadder: String, Codable, Sendable, CaseIterable {
    case intervals
    case sessionIntervals
    case continuousRun
    case runs
    case activeWeeks
    case stars
}

/// Den fulde, deklarative beskrivelse af ét badge: identitet, tema, regel og
/// præsentation samlet ét sted. **Sådan tilføjer du et nyt badge:** læg en ny
/// `BadgeDefinition` i en fil i `Badges/`-mappen — intet andet skal røres.
///
/// `slug` er både persistens-nøgle og filnavn for den tegnede SVG. `title`/
/// `detail` er den danske kildetekst; præsentationslaget gør dem til
/// `LocalizedStringResource` via `titleKey`/`detailKey`, så lokalisering bevares.
public struct BadgeDefinition: Sendable, Identifiable, Equatable {
    public let slug: String
    public let category: BadgeCategory
    public let palette: BadgePalette
    /// Emoji, der matcher den tegnede SVG (vist indtil rigtige assets leveres).
    public let emoji: String
    /// Skjult i samlingen, indtil det er låst op — en lille overraskelse.
    public let isSecret: Bool
    /// Milepæls-stige mærket hører til (kun næste trin vises), eller `nil`.
    public let ladder: BadgeLadder?
    /// Dansk kildetekst (titel/beskrivelse). Bruges som `defaultValue`.
    public let title: String
    public let detail: String
    /// Betingelsen for at optjene mærket.
    public let rule: BadgeRule

    public var id: String { slug }

    /// Mærker appen ikke kan måle — barnet låser selv op i appen.
    public var isManual: Bool { rule == .manual }

    /// Lokaliseringsnøgler — den viste tekst ligger i app-lagets strengkatalog.
    public var titleKey: String { "badge.\(slug).title" }
    public var detailKey: String { "badge.\(slug).detail" }

    public init(
        slug: String,
        category: BadgeCategory,
        palette: BadgePalette,
        emoji: String,
        isSecret: Bool = false,
        ladder: BadgeLadder? = nil,
        title: String,
        detail: String,
        rule: BadgeRule
    ) {
        self.slug = slug
        self.category = category
        self.palette = palette
        self.emoji = emoji
        self.isSecret = isSecret
        self.ladder = ladder
        self.title = title
        self.detail = detail
        self.rule = rule
    }
}
