import Foundation

/// Mærker for konkrete, sjove milepæle (jf. spec afsnit 5.4). De fejrer
/// **handlinger, brugeren selv kan være stolt af** — fremmøde og små
/// sejre — aldrig fart, distance eller sammenligning med andre.
public enum Badge: String, Codable, Sendable, CaseIterable, Identifiable {
    case firstWorkout
    case tenWorkouts
    case threeWeekStreak
    case firstFiveMinuteRun
    case earlyBird          // morgentur
    case rainHero           // tur i regnvejr
    case completedBaseProgram

    public var id: String { rawValue }

    /// Lokaliseringsnøgler — den viste tekst ligger i app-lagets strengkatalog.
    public var titleKey: String { "badge.\(rawValue).title" }
    public var detailKey: String { "badge.\(rawValue).detail" }
}

/// Fakta om en netop afsluttet tur og brugerens samlede stilling, som badges
/// vurderes ud fra. App-laget udregner fakta (tidspunkt, vejr, totaler), og
/// kernen afgør, hvad der er låst op — så reglerne kan testes isoleret.
public struct BadgeContext: Sendable, Equatable {
    public let totalCompletedWorkouts: Int
    public let currentStreakWeeks: Int
    /// Længste sammenhængende løbeinterval, brugeren har gennemført til dato.
    public let longestContinuousRun: Duration
    public let startedInMorning: Bool
    public let wasRaining: Bool
    public let finishedBaseProgram: Bool

    public init(
        totalCompletedWorkouts: Int,
        currentStreakWeeks: Int,
        longestContinuousRun: Duration,
        startedInMorning: Bool = false,
        wasRaining: Bool = false,
        finishedBaseProgram: Bool = false
    ) {
        self.totalCompletedWorkouts = totalCompletedWorkouts
        self.currentStreakWeeks = currentStreakWeeks
        self.longestContinuousRun = longestContinuousRun
        self.startedInMorning = startedInMorning
        self.wasRaining = wasRaining
        self.finishedBaseProgram = finishedBaseProgram
    }
}

/// Afgør, hvilke badges der er optjent ud fra fakta. Rene regler, ingen tilstand.
public enum BadgeEvaluator {
    private static func isEarned(_ badge: Badge, in context: BadgeContext) -> Bool {
        switch badge {
        case .firstWorkout:        return context.totalCompletedWorkouts >= 1
        case .tenWorkouts:         return context.totalCompletedWorkouts >= 10
        case .threeWeekStreak:     return context.currentStreakWeeks >= 3
        case .firstFiveMinuteRun:  return context.longestContinuousRun >= .minutes(5)
        case .earlyBird:           return context.startedInMorning
        case .rainHero:            return context.wasRaining
        case .completedBaseProgram: return context.finishedBaseProgram
        }
    }

    /// Badges der netop er låst op — opfyldt af fakta og ikke optjent før.
    /// Rækkefølgen er stabil (efter `Badge.allCases`).
    public static func newlyEarned(context: BadgeContext, alreadyEarned: Set<Badge>) -> [Badge] {
        Badge.allCases.filter { isEarned($0, in: context) && !alreadyEarned.contains($0) }
    }
}
