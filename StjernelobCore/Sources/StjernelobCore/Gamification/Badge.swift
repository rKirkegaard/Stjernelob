import Foundation

/// Et badge — en tynd, slug-baseret identitet, hvis metadata og regel slås op i
/// `BadgeCatalogue` (den eneste sandhedskilde). Det fejrer **handlinger, brugeren
/// selv kan være stolt af** — fremmøde og små sejre — aldrig fart, distance eller
/// sammenligning med andre (jf. spec afsnit 5.4).
///
/// `slug`/`rawValue` matcher SVG-filnavnet og bruges som persistens-nøgle.
public struct Badge: Sendable, Identifiable {
    /// Hele definitionen fra kataloget (metadata + optjenings-regel).
    public let definition: BadgeDefinition

    public var slug: String { definition.slug }
    public var id: String { definition.slug }
    /// Persistens-API: rawValue er slug'en (uændret fra den tidligere enum).
    public var rawValue: String { definition.slug }

    public var category: BadgeCategory { definition.category }
    public var isManual: Bool { definition.isManual }
    public var isSecret: Bool { definition.isSecret }
    public var ladder: BadgeLadder? { definition.ladder }

    private init(definition: BadgeDefinition) {
        self.definition = definition
    }

    /// Opretter et badge fra en slug, hvis den findes i kataloget.
    public init?(slug: String) {
        guard let definition = BadgeCatalogue.definition(slug: slug) else { return nil }
        self.definition = definition
    }

    /// Persistens-init: tolker en gemt rawValue. `nil`, hvis slug'en er ukendt
    /// (fx et fjernet mærke) — så gammelt data aldrig kan crashe appen.
    public init?(rawValue: String) {
        self.init(slug: rawValue)
    }

    /// Alle badges i kataloget, i stabil rækkefølge.
    public static let all: [Badge] = BadgeCatalogue.all.map(Badge.init(definition:))
}

extension Badge: Hashable {
    public static func == (lhs: Badge, rhs: Badge) -> Bool { lhs.slug == rhs.slug }
    public func hash(into hasher: inout Hasher) { hasher.combine(slug) }
}

/// Badge kodes/afkodes som sin slug (en enkelt streng), så persistens og eksport
/// er uændret. Ukendte slugs afvises i stedet for at crashe.
extension Badge: Codable {
    public init(from decoder: Decoder) throws {
        let slug = try decoder.singleValueContainer().decode(String.self)
        guard let badge = Badge(slug: slug) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Ukendt badge-slug: \(slug)"
            ))
        }
        self = badge
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(slug)
    }
}

/// Fakta om en netop afsluttet tur og brugerens samlede stilling, som badges
/// vurderes ud fra. App-laget udregner fakta (intervaller, tidspunkt, dato,
/// totaler), og kernen afgør via reglerne, hvad der er låst op — så reglerne kan
/// testes isoleret. Tæller fremmøde og handlinger, aldrig fart eller distance.
public struct BadgeContext: Sendable, Equatable {
    public let totalCompletedWorkouts: Int
    public let currentStreakWeeks: Int
    /// Ture gennemført i indeværende (ugentlige) trænings­uge.
    public let sessionsThisWeek: Int
    /// Ture gennemført i indeværende kalendermåned.
    public let workoutsThisMonth: Int
    /// Har gennemført mindst én hel tur (ikke afbrudt).
    public let hasCompletedFullRun: Bool
    /// Har gennemført en tur, hun selv markerede som hård — og blev ved.
    public let hasCompletedHardRun: Bool
    public let startedInMorning: Bool
    public let startedInEvening: Bool
    /// Tog mindst ét billede undervejs (fanger sted/oplevelse — ikke kroppen).
    public let tookPhoto: Bool
    /// Tilbage efter en pause på en uge eller mere — fejres varmt.
    public let isComeback: Bool
    /// Dato for turen, brugt til årstids- og mærkedags-mærker. 0 = ukendt.
    public let month: Int
    public let day: Int
    /// Gennemførte løbeintervaller i alt på tværs af alle ture.
    public let totalRunIntervals: Int
    /// Flest løbeintervaller i én enkelt tur til dato.
    public let maxRunIntervalsInOneRun: Int
    /// Antal kalenderuger med mindst én tur.
    public let totalActiveWeeks: Int
    /// Samlet antal optjente stjerner.
    public let totalStars: Int
    /// Strakte ud efter mindst én tur (et lille, valgfrit ja efter turen).
    public let didStretchAfterRun: Bool
    /// Huskede vand før og efter mindst én tur (et lille, valgfrit ja).
    public let didDrinkWaterBeforeAndAfter: Bool
    /// Det længste sammenhængende løb til dato, i hele minutter.
    public let longestContinuousRunMinutes: Int

    public init(
        totalCompletedWorkouts: Int,
        currentStreakWeeks: Int,
        sessionsThisWeek: Int = 0,
        workoutsThisMonth: Int = 0,
        hasCompletedFullRun: Bool = false,
        hasCompletedHardRun: Bool = false,
        startedInMorning: Bool = false,
        startedInEvening: Bool = false,
        tookPhoto: Bool = false,
        isComeback: Bool = false,
        month: Int = 0,
        day: Int = 0,
        totalRunIntervals: Int = 0,
        maxRunIntervalsInOneRun: Int = 0,
        totalActiveWeeks: Int = 0,
        totalStars: Int = 0,
        didStretchAfterRun: Bool = false,
        didDrinkWaterBeforeAndAfter: Bool = false,
        longestContinuousRunMinutes: Int = 0
    ) {
        self.totalCompletedWorkouts = totalCompletedWorkouts
        self.currentStreakWeeks = currentStreakWeeks
        self.sessionsThisWeek = sessionsThisWeek
        self.workoutsThisMonth = workoutsThisMonth
        self.hasCompletedFullRun = hasCompletedFullRun
        self.hasCompletedHardRun = hasCompletedHardRun
        self.startedInMorning = startedInMorning
        self.startedInEvening = startedInEvening
        self.tookPhoto = tookPhoto
        self.isComeback = isComeback
        self.month = month
        self.day = day
        self.totalRunIntervals = totalRunIntervals
        self.maxRunIntervalsInOneRun = maxRunIntervalsInOneRun
        self.totalActiveWeeks = totalActiveWeeks
        self.totalStars = totalStars
        self.didStretchAfterRun = didStretchAfterRun
        self.didDrinkWaterBeforeAndAfter = didDrinkWaterBeforeAndAfter
        self.longestContinuousRunMinutes = longestContinuousRunMinutes
    }
}

/// Afgør, hvilke badges der er optjent ud fra fakta. Rene regler, ingen tilstand.
/// Manuelle mærker (`.manual`) tildeles aldrig her — de låses op i appen.
public enum BadgeEvaluator {
    /// Badges der netop er låst op — opfyldt af fakta og ikke optjent før.
    /// Rækkefølgen er stabil (efter katalogets rækkefølge).
    public static func newlyEarned(context: BadgeContext, alreadyEarned: Set<Badge>) -> [Badge] {
        Badge.all.filter { badge in
            !badge.isManual
                && badge.definition.rule.isSatisfied(by: context)
                && !alreadyEarned.contains(badge)
        }
    }
}
