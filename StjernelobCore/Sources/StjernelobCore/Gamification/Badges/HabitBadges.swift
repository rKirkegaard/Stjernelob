import Foundation

// Vaner og velvære (sand). Stræk og vand tildeles ud fra et lille, valgfrit ja
// efter turen; resten låser barnet selv op.

extension BadgeCatalogue {
    static let habitBadges: [BadgeDefinition] = [
        BadgeDefinition(
            slug: "loebedagbog", category: .habits, palette: .sand, emoji: "📓",
            title: "Løbedagbog", detail: "Du skrev lidt om din tur.",
            rule: .manual
        ),
        BadgeDefinition(
            slug: "musik-i-oererne", category: .habits, palette: .sand, emoji: "🎧",
            title: "Musik i ørerne", detail: "Musik i ørerne hele vejen.",
            rule: .manual
        ),
        BadgeDefinition(
            slug: "straek-stjerne", category: .habits, palette: .sand, emoji: "🧘",
            title: "Stræk-stjerne", detail: "Du huskede at strække ud bagefter.",
            rule: .didStretch
        ),
        BadgeDefinition(
            slug: "vand-dronning", category: .habits, palette: .sand, emoji: "🌊",
            title: "Vand-dronning", detail: "Du huskede at drikke vand.",
            rule: .didDrinkWater
        ),
        BadgeDefinition(
            slug: "soevn-samler", category: .habits, palette: .sand, emoji: "😴",
            title: "Søvn-samler", detail: "Du fik sovet godt før din tur.",
            rule: .manual
        ),
        BadgeDefinition(
            slug: "pakket-og-klar", category: .habits, palette: .sand, emoji: "🎒",
            title: "Pakket og klar", detail: "Tasken er pakket og klar til tur.",
            rule: .manual
        ),
    ]
}
