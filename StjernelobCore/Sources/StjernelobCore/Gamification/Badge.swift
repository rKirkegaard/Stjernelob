import Foundation

/// Mærker for konkrete, sjove milepæle (jf. spec afsnit 5.4). De fejrer
/// **handlinger, brugeren selv kan være stolt af** — fremmøde og små
/// sejre — aldrig fart, distance eller sammenligning med andre.
///
/// Sættet er den designede samling (38 mærker). Nogle tildeles automatisk ud
/// fra turdata; andre er ting appen ikke kan måle (musik, søvn, en løbemakker
/// …) og kan barnet selv låse op, når hun har gjort det (`isManual`).
/// `rawValue` matcher SVG-filnavnet for det tegnede mærke.
public enum Badge: String, Codable, Sendable, CaseIterable, Identifiable {
    // Fremmøde og stime (lilla).
    case firstStep = "første-skridt"
    case braveStarter = "modig-starter"
    case oneWeekStreak = "en-uge-i-traek"
    case twoInOneWeek = "2-i-en-uge"
    case threeInOneWeek = "3-i-en-uge"
    case threeWeekStreak = "3-ugers-streak"
    case unbreakable = "ubrydelig"
    case monthHero = "maanedshelt"
    case backAgain = "tilbage-igen"

    // Tidspunkt (grøn-blå).
    case earlyBird = "tidlig-fugl"
    case eveningStar = "aftenstjerne"

    // Årstid og vejr (blå).
    case springAir = "foraarsluft"
    case autumnRunner = "efteraarsloeber"
    case iceInBelly = "is-i-maven"
    case sunshineRunner = "solskinsloeber"
    case rainRunner = "regnvejrsloeber"
    case fogRunner = "taagelober"
    case rainbowRunner = "regnbue-runner"

    // Mærkedage (grøn).
    case christmasRunner = "juleloeber"
    case newYearStart = "nytaarsstart"
    case birthdayRun = "foedselsdag"

    // Sted og oplevelse (grøn/lyserød).
    case cityRunner = "byloeber"
    case natureGirl = "naturpige"
    case newRoute = "ny-rute"
    case momentPhoto = "tur-foto"

    // Lyd (sand/lyserød).
    case newPlaylist = "ny-playlist"
    case musicInEars = "musik-i-oererne"
    case podcastRunner = "podcast-runner"

    // Socialt og fejring (lyserød).
    case neverGiveUp = "aldrig-give-op"
    case celebrateYourself = "fejer-dig-selv"
    case cheerleader = "hepperen"
    case runningBuddy = "loebemakker"

    // Forberedelse og velvære (sand).
    case readyToStart = "klar-til-start"
    case runningDiary = "loebedagbog"
    case packedAndReady = "pakket-og-klar"
    case stretchStar = "straek-stjerne"
    case sleepCollector = "soevn-samler"
    case waterQueen = "vand-dronning"

    public var id: String { rawValue }

    /// Lokaliseringsnøgler — den viste tekst ligger i app-lagets strengkatalog.
    public var titleKey: String { "badge.\(rawValue).title" }
    public var detailKey: String { "badge.\(rawValue).detail" }

    /// Mærker appen ikke kan måle automatisk. De låses op af barnet selv, når
    /// hun har gjort tingen — legende og selvbestemt, aldrig som et krav.
    public var isManual: Bool {
        switch self {
        case .readyToStart, .rainRunner, .fogRunner, .rainbowRunner, .birthdayRun,
             .cityRunner, .natureGirl, .newRoute, .newPlaylist, .musicInEars,
             .podcastRunner, .celebrateYourself, .cheerleader, .runningBuddy,
             .runningDiary, .packedAndReady, .stretchStar, .sleepCollector, .waterQueen:
            return true
        default:
            return false
        }
    }
}

/// Fakta om en netop afsluttet tur og brugerens samlede stilling, som badges
/// vurderes ud fra. App-laget udregner fakta (intervaller, tidspunkt, dato,
/// totaler), og kernen afgør, hvad der er låst op — så reglerne kan testes
/// isoleret. Tæller fremmøde og handlinger, aldrig fart eller distance.
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
        day: Int = 0
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
    }
}

/// Afgør, hvilke badges der er optjent ud fra fakta. Rene regler, ingen tilstand.
/// Manuelle mærker (`Badge.isManual`) tildeles aldrig her — de låses op i appen.
public enum BadgeEvaluator {
    private static func isEarned(_ badge: Badge, in context: BadgeContext) -> Bool {
        switch badge {
        case .firstStep:        return context.totalCompletedWorkouts >= 1
        case .braveStarter:     return context.hasCompletedFullRun
        case .oneWeekStreak:    return context.currentStreakWeeks >= 1
        case .twoInOneWeek:     return context.sessionsThisWeek >= 2
        case .threeInOneWeek:   return context.sessionsThisWeek >= 3
        case .threeWeekStreak:  return context.currentStreakWeeks >= 3
        case .unbreakable:      return context.currentStreakWeeks >= 8
        case .monthHero:        return context.workoutsThisMonth >= 8
        case .backAgain:        return context.isComeback
        case .earlyBird:        return context.startedInMorning
        case .eveningStar:      return context.startedInEvening
        case .springAir:        return [3, 4, 5].contains(context.month)
        case .autumnRunner:     return [9, 10, 11].contains(context.month)
        case .iceInBelly:       return [12, 1, 2].contains(context.month)
        case .sunshineRunner:   return [6, 7, 8].contains(context.month)
        case .christmasRunner:  return context.month == 12 && (20...26).contains(context.day)
        case .newYearStart:     return (context.month == 12 && context.day == 31)
                                    || (context.month == 1 && (1...7).contains(context.day))
        case .neverGiveUp:      return context.hasCompletedHardRun
        case .momentPhoto:      return context.tookPhoto

        // Manuelle mærker — låses op af barnet selv i appen.
        case .readyToStart, .rainRunner, .fogRunner, .rainbowRunner, .birthdayRun,
             .cityRunner, .natureGirl, .newRoute, .newPlaylist, .musicInEars,
             .podcastRunner, .celebrateYourself, .cheerleader, .runningBuddy,
             .runningDiary, .packedAndReady, .stretchStar, .sleepCollector, .waterQueen:
            return false
        }
    }

    /// Badges der netop er låst op — opfyldt af fakta og ikke optjent før.
    /// Rækkefølgen er stabil (efter `Badge.allCases`).
    public static func newlyEarned(context: BadgeContext, alreadyEarned: Set<Badge>) -> [Badge] {
        Badge.allCases.filter { isEarned($0, in: context) && !alreadyEarned.contains($0) }
    }
}
