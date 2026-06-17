import Foundation

/// Det samlede katalog over alle badges — den eneste sandhedskilde for både
/// metadata og regler. Definitionerne ligger i temafiler i `Badges/`-mappen;
/// her samles de i visnings- og evalueringsrækkefølge.
///
/// **Tilføj et nyt badge** ved at lægge en `BadgeDefinition` i den relevante fil
/// i `Badges/`. Intet andet skal røres — hverken evaluator, præsentation eller
/// `Badge`-typen kender til konkrete mærker.
public enum BadgeCatalogue {
    /// Alle definitioner i stabil rækkefølge (kom-i-gang/stime → vejr → vaner →
    /// socialt → særlige → milepæle). Rækkefølgen bestemmer både visning og den
    /// stabile rækkefølge nye mærker tildeles i.
    public static let all: [BadgeDefinition] =
        startAndStreakBadges
            + weatherBadges
            + habitBadges
            + socialBadges
            + specialBadges
            + milestoneBadges

    private static let bySlug: [String: BadgeDefinition] =
        Dictionary(uniqueKeysWithValues: all.map { ($0.slug, $0) })

    /// Definitionen for en slug, eller `nil` hvis den ikke findes i kataloget.
    public static func definition(slug: String) -> BadgeDefinition? { bySlug[slug] }

    /// Om kataloget indeholder en given slug.
    public static func contains(_ slug: String) -> Bool { bySlug[slug] != nil }
}
