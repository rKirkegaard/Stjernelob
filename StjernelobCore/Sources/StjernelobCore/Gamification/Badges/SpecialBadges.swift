import Foundation

// Mærkedage, sted og natur (grøn). Sted-mærker appen ikke kan måle er manuelle.

extension BadgeCatalogue {
    static let specialBadges: [BadgeDefinition] = [
        BadgeDefinition(
            slug: "juleloeber", category: .special, palette: .green, emoji: "🎄",
            title: "Juleløber", detail: "En tur i juletiden.",
            rule: .dateInMonth(month: 12, days: 20...26)
        ),
        BadgeDefinition(
            slug: "nytaarsstart", category: .special, palette: .green, emoji: "🎆",
            title: "Nytårsstart", detail: "Du startede det nye år med en tur.",
            rule: .anyOf([
                .dateInMonth(month: 12, days: 31...31),
                .dateInMonth(month: 1, days: 1...7),
            ])
        ),
        BadgeDefinition(
            slug: "foedselsdag", category: .special, palette: .green, emoji: "🎂",
            title: "Fødselsdagstur", detail: "En tur på din fødselsdag.",
            rule: .manual
        ),
        BadgeDefinition(
            slug: "byloeber", category: .special, palette: .green, emoji: "🌃",
            title: "Byløber", detail: "En tur gennem byen.",
            rule: .manual
        ),
        BadgeDefinition(
            slug: "naturpige", category: .special, palette: .green, emoji: "🌲",
            title: "Naturpige", detail: "En tur ude i naturen.",
            rule: .manual
        ),
        BadgeDefinition(
            slug: "ny-rute", category: .special, palette: .green, emoji: "🌍",
            title: "Ny rute", detail: "Du prøvede en helt ny rute.",
            rule: .manual
        ),
        BadgeDefinition(
            slug: "ny-playlist", category: .special, palette: .green, emoji: "🎵",
            title: "Ny playlist", detail: "Du løb til en ny playliste.",
            rule: .manual
        ),
    ]
}
