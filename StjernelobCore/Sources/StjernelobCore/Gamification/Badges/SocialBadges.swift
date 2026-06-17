import Foundation

// Socialt, fejring og oplevelse (lyserød).

extension BadgeCatalogue {
    static let socialBadges: [BadgeDefinition] = [
        BadgeDefinition(
            slug: "aldrig-give-op", category: .social, palette: .pink, emoji: "🏅",
            title: "Aldrig give op", detail: "En hård tur — og du blev ved til mål.",
            rule: .completedHardRun
        ),
        BadgeDefinition(
            slug: "fejer-dig-selv", category: .social, palette: .pink, emoji: "🎉",
            title: "Fejr dig selv", detail: "Husk at fejre dig selv. Du fortjener det.",
            rule: .manual
        ),
        BadgeDefinition(
            slug: "hepperen", category: .social, palette: .pink, emoji: "📣",
            title: "Hepperen", detail: "Du heppede på en anden løber.",
            rule: .manual
        ),
        BadgeDefinition(
            slug: "loebemakker", category: .social, palette: .pink, emoji: "🤝",
            title: "Løbemakker", detail: "En tur sammen med en løbemakker.",
            rule: .manual
        ),
        BadgeDefinition(
            slug: "tur-foto", category: .social, palette: .pink, emoji: "📸",
            title: "Tur-foto", detail: "Du fangede et øjeblik undervejs.",
            rule: .tookPhoto
        ),
        BadgeDefinition(
            slug: "podcast-runner", category: .social, palette: .pink, emoji: "🎤",
            title: "Podcast-runner", detail: "En tur med en god podcast.",
            rule: .manual
        ),
    ]
}
