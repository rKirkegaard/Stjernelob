import Foundation

// Årstid og vejr (blå). Vejr-mærker appen ikke kan måle er manuelle.

extension BadgeCatalogue {
    static let weatherBadges: [BadgeDefinition] = [
        BadgeDefinition(
            slug: "foraarsluft", category: .weather, palette: .blue, emoji: "🌸",
            title: "Forårsluft", detail: "En tur i den friske forårsluft.",
            rule: .season(.spring)
        ),
        BadgeDefinition(
            slug: "efteraarsloeber", category: .weather, palette: .blue, emoji: "🍂",
            title: "Efterårsløber", detail: "En tur blandt efterårets farver.",
            rule: .season(.autumn)
        ),
        BadgeDefinition(
            slug: "is-i-maven", category: .weather, palette: .blue, emoji: "❄️",
            title: "Is i maven", detail: "Du kom afsted midt om vinteren.",
            rule: .season(.winter)
        ),
        BadgeDefinition(
            slug: "solskinsloeber", category: .weather, palette: .blue, emoji: "☀️",
            title: "Solskinsløber", detail: "En tur i sommervarmen.",
            rule: .season(.summer)
        ),
        BadgeDefinition(
            slug: "regnvejrsloeber", category: .weather, palette: .blue, emoji: "🌧️",
            title: "Regnvejrsløber", detail: "Du tog afsted, selv i regnvejr.",
            rule: .manual
        ),
        BadgeDefinition(
            slug: "taagelober", category: .weather, palette: .blue, emoji: "🌫️",
            title: "Tågeløber", detail: "En tur i tåget vejr.",
            rule: .manual
        ),
        BadgeDefinition(
            slug: "regnbue-runner", category: .weather, palette: .blue, emoji: "🌈",
            title: "Regnbue-runner", detail: "Du så en regnbue undervejs.",
            rule: .manual
        ),
    ]
}
