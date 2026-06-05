import Foundation

/// Mærker for konkrete, sjove milepæle (jf. spec afsnit 5.4). De fejrer
/// **handlinger, brugeren selv kan være stolt af** — fremmøde og små
/// sejre — aldrig fart, distance eller sammenligning med andre.
///
/// Tænkt til en begynder: rigtig mange små, hurtige sejre tidligt — særligt
/// pr. gennemført løbeinterval — så der altid er noget nyt at låse op lige om
/// hjørnet. Ingen mærker for lange løb eller mange timer.
public enum Badge: String, Codable, Sendable, CaseIterable, Identifiable {
    // Løbeintervaller i én tur — hurtige sejre fra allerførste tur.
    case firstRunInterval          // løb dit første interval
    case twoRunIntervalsInOneRun   // to løbestykker i samme tur
    case fiveRunIntervalsInOneRun  // fem løbestykker i samme tur
    case eightRunIntervalsInOneRun // otte løbestykker i samme tur

    // Løbestykker i alt — en blid, voksende samling på tværs af ture.
    case tenRunIntervalsTotal
    case twentyFiveRunIntervalsTotal
    case fiftyRunIntervalsTotal

    // Gode ture — flere ture med en håndfuld løbestykker (brugerens eksempel).
    case twoRunsWithFourIntervals

    // Fremmøde — antal ture (fejrer at man kommer afsted).
    case firstWorkout
    case fiveWorkouts
    case tenWorkouts
    case twentyFiveWorkouts

    // Stime — uger i træk (ugentlig og tilgivende, aldrig dagligt pres).
    case threeWeekStreak
    case fiveWeekStreak

    // Tidspunkt og årstid — sjove, konkrete øjeblikke.
    case earlyBird          // morgentur
    case eveningStar        // aftentur
    case weekendWarrior     // tur i weekenden
    case winterRunner       // tur i vintermåned
    case summerRunner       // tur i sommermåned
    case rainHero           // tur i regnvejr

    // Oplevelse og comeback.
    case photographer       // fangede et øjeblik undervejs
    case comeback           // tilbage efter en pause — varmt og uden bebrejdelse

    // Forløb.
    case completedBaseProgram

    public var id: String { rawValue }

    /// Lokaliseringsnøgler — den viste tekst ligger i app-lagets strengkatalog.
    public var titleKey: String { "badge.\(rawValue).title" }
    public var detailKey: String { "badge.\(rawValue).detail" }
}

/// Fakta om en netop afsluttet tur og brugerens samlede stilling, som badges
/// vurderes ud fra. App-laget udregner fakta (intervaller, tidspunkt, vejr,
/// totaler), og kernen afgør, hvad der er låst op — så reglerne kan testes
/// isoleret. Tæller løbestykker, ikke tid eller distance.
public struct BadgeContext: Sendable, Equatable {
    public let totalCompletedWorkouts: Int
    public let currentStreakWeeks: Int
    /// Flest løbeintervaller gennemført i én enkelt tur til dato.
    public let maxRunIntervalsInOneRun: Int
    /// Løbeintervaller gennemført i alt på tværs af alle ture.
    public let totalRunIntervals: Int
    /// Antal ture med mindst fire gennemførte løbeintervaller.
    public let runsWithFourPlusIntervals: Int
    public let startedInMorning: Bool
    public let startedInEvening: Bool
    public let isWeekendWorkout: Bool
    public let wasRaining: Bool
    /// Tog mindst ét billede undervejs (fanger sted/oplevelse — ikke kroppen).
    public let tookPhoto: Bool
    /// Tilbage efter en pause på en uge eller mere — fejres varmt.
    public let isComeback: Bool
    /// Månedstal (1...12) for turen; bruges til årstids-mærker. 0 = ukendt.
    public let month: Int
    public let finishedBaseProgram: Bool

    public init(
        totalCompletedWorkouts: Int,
        currentStreakWeeks: Int,
        maxRunIntervalsInOneRun: Int = 0,
        totalRunIntervals: Int = 0,
        runsWithFourPlusIntervals: Int = 0,
        startedInMorning: Bool = false,
        startedInEvening: Bool = false,
        isWeekendWorkout: Bool = false,
        wasRaining: Bool = false,
        tookPhoto: Bool = false,
        isComeback: Bool = false,
        month: Int = 0,
        finishedBaseProgram: Bool = false
    ) {
        self.totalCompletedWorkouts = totalCompletedWorkouts
        self.currentStreakWeeks = currentStreakWeeks
        self.maxRunIntervalsInOneRun = maxRunIntervalsInOneRun
        self.totalRunIntervals = totalRunIntervals
        self.runsWithFourPlusIntervals = runsWithFourPlusIntervals
        self.startedInMorning = startedInMorning
        self.startedInEvening = startedInEvening
        self.isWeekendWorkout = isWeekendWorkout
        self.wasRaining = wasRaining
        self.tookPhoto = tookPhoto
        self.isComeback = isComeback
        self.month = month
        self.finishedBaseProgram = finishedBaseProgram
    }
}

/// Afgør, hvilke badges der er optjent ud fra fakta. Rene regler, ingen tilstand.
public enum BadgeEvaluator {
    private static func isEarned(_ badge: Badge, in context: BadgeContext) -> Bool {
        switch badge {
        case .firstRunInterval:          return context.maxRunIntervalsInOneRun >= 1
        case .twoRunIntervalsInOneRun:   return context.maxRunIntervalsInOneRun >= 2
        case .fiveRunIntervalsInOneRun:  return context.maxRunIntervalsInOneRun >= 5
        case .eightRunIntervalsInOneRun: return context.maxRunIntervalsInOneRun >= 8
        case .tenRunIntervalsTotal:      return context.totalRunIntervals >= 10
        case .twentyFiveRunIntervalsTotal: return context.totalRunIntervals >= 25
        case .fiftyRunIntervalsTotal:    return context.totalRunIntervals >= 50
        case .twoRunsWithFourIntervals:  return context.runsWithFourPlusIntervals >= 2
        case .firstWorkout:              return context.totalCompletedWorkouts >= 1
        case .fiveWorkouts:              return context.totalCompletedWorkouts >= 5
        case .tenWorkouts:               return context.totalCompletedWorkouts >= 10
        case .twentyFiveWorkouts:        return context.totalCompletedWorkouts >= 25
        case .threeWeekStreak:           return context.currentStreakWeeks >= 3
        case .fiveWeekStreak:            return context.currentStreakWeeks >= 5
        case .earlyBird:                 return context.startedInMorning
        case .eveningStar:               return context.startedInEvening
        case .weekendWarrior:            return context.isWeekendWorkout
        case .winterRunner:              return [12, 1, 2].contains(context.month)
        case .summerRunner:              return [6, 7, 8].contains(context.month)
        case .rainHero:                  return context.wasRaining
        case .photographer:              return context.tookPhoto
        case .comeback:                  return context.isComeback
        case .completedBaseProgram:      return context.finishedBaseProgram
        }
    }

    /// Badges der netop er låst op — opfyldt af fakta og ikke optjent før.
    /// Rækkefølgen er stabil (efter `Badge.allCases`).
    public static func newlyEarned(context: BadgeContext, alreadyEarned: Set<Badge>) -> [Badge] {
        Badge.allCases.filter { isEarned($0, in: context) && !alreadyEarned.contains($0) }
    }
}
