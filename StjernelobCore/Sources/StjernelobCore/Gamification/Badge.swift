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

    // Milepæle (importeret) — tildeles automatisk ud fra historikken.
    // Løbeintervaller i alt — tæt stige, så der altid er et nært næste mål.
    case interval5 = "interval-5"
    case interval10 = "interval-10"
    case interval15 = "interval-15"
    case interval20 = "interval-20"
    case interval25 = "interval-25"
    case interval30 = "interval-30"
    case interval40 = "interval-40"
    case interval50 = "interval-50"
    case interval75 = "interval-75"
    case interval100 = "interval-100"
    case interval150 = "interval-150"
    case interval200 = "interval-200"
    case interval300 = "interval-300"
    case interval500 = "interval-500"
    case interval750 = "interval-750"
    case interval1000 = "interval-1000"
    // Løbeintervaller i én tur.
    case sessionFourIntervals = "session-4-intervaller"
    case sessionSixIntervals = "session-6-intervaller"
    case sessionEightIntervals = "session-8-intervaller"
    // Sammenhængende løb — det længste løb uden gå-pause (tildeles automatisk).
    // Fejrer at kunne løbe i længere tid ad gangen, aldrig fart eller distance.
    case continuousRun5 = "uafbrudt-5"
    case continuousRun10 = "uafbrudt-10"
    case continuousRun20 = "uafbrudt-20"
    case continuousRun30 = "uafbrudt-30"
    // Antal ture i alt.
    case runs1 = "tur-1"
    case runs3 = "tur-3"
    case runs5 = "tur-5"
    case runs10 = "tur-10"
    case runs15 = "tur-15"
    case runs20 = "tur-20"
    case runs25 = "tur-25"
    case runs30 = "tur-30"
    case runs40 = "tur-40"
    case runs50 = "tur-50"
    case runs60 = "tur-60"
    case runs75 = "tur-75"
    case runs80 = "tur-80"
    case runs100 = "tur-100"
    // Aktive uger (uger med mindst én tur).
    case activeWeeks1 = "aktiv-uge-1"
    case activeWeeks2 = "aktiv-uge-2"
    case activeWeeks4 = "aktiv-uge-4"
    case activeWeeks6 = "aktiv-uge-6"
    case activeWeeks8 = "aktiv-uge-8"
    case activeWeeks10 = "aktiv-uge-10"
    case activeWeeks12 = "aktiv-uge-12"
    case activeWeeks16 = "aktiv-uge-16"
    case activeWeeks20 = "aktiv-uge-20"
    case activeWeeks26 = "aktiv-uge-26"
    case activeWeeks52 = "aktiv-uge-52"
    // Samlet antal stjerner.
    case stars10 = "stjerner-10"
    case stars25 = "stjerner-25"
    case stars50 = "stjerner-50"
    case stars100 = "stjerner-100"
    case stars250 = "stjerner-250"
    case stars500 = "stjerner-500"
    case stars1000 = "stjerner-1000"

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
             .runningDiary, .packedAndReady, .sleepCollector:
            true
        default:
            false
        }
    }

    /// Hemmelige mærker er skjult i samlingen, indtil de er låst op — en lille
    /// overraskelse ved de største milepæle.
    public var isSecret: Bool {
        switch self {
        // Kun de allerstørste mål er en skjult overraskelse — resten vises som
        // nære, opnåelige trin (samlingen viser kun det næste trin pr. gruppe).
        case .interval1000, .runs100, .activeWeeks52, .stars1000:
            true
        default: false
        }
    }

    /// Hvilken gruppe mærket hører til — bruges til at inddele samlingen i
    /// overskuelige temaer (jf. Import/Badges-designet).
    public var category: BadgeCategory {
        switch self {
        case .firstStep, .braveStarter, .readyToStart, .earlyBird, .eveningStar, .runs1:
            .firstSteps
        case .oneWeekStreak, .twoInOneWeek, .threeInOneWeek, .threeWeekStreak, .unbreakable,
             .monthHero, .backAgain,
             .interval5, .interval10, .interval15, .interval20, .interval25, .interval30,
             .interval40, .interval50, .interval75, .interval100, .interval150, .interval200,
             .interval300, .interval500, .interval750, .interval1000,
             .sessionFourIntervals, .sessionSixIntervals, .sessionEightIntervals,
             .continuousRun5, .continuousRun10, .continuousRun20, .continuousRun30,
             .runs3, .runs5, .runs10, .runs15, .runs20, .runs25, .runs30, .runs40, .runs50,
             .runs60, .runs75, .runs80, .runs100,
             .activeWeeks1, .activeWeeks2, .activeWeeks4, .activeWeeks6, .activeWeeks8,
             .activeWeeks10, .activeWeeks12, .activeWeeks16, .activeWeeks20,
             .stars10, .stars25, .stars50, .stars100, .stars250, .stars500:
            .consistency
        case .springAir, .autumnRunner, .iceInBelly, .sunshineRunner, .rainRunner,
             .fogRunner, .rainbowRunner:
            .weather
        case .runningDiary, .musicInEars, .stretchStar, .waterQueen, .sleepCollector,
             .packedAndReady:
            .habits
        case .neverGiveUp, .celebrateYourself, .cheerleader, .runningBuddy, .momentPhoto,
             .podcastRunner:
            .social
        case .christmasRunner, .newYearStart, .birthdayRun, .cityRunner, .natureGirl,
             .newRoute, .newPlaylist, .activeWeeks26, .activeWeeks52, .stars1000:
            .special
        }
    }
}

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
    /// Samlede tal til milepæls-mærker (importeret).
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
    /// Det længste sammenhængende løb til dato, i hele minutter — til
    /// "sammenhængende løb"-mærkerne.
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
/// Manuelle mærker (`Badge.isManual`) tildeles aldrig her — de låses op i appen.
public enum BadgeEvaluator {
    private static func isEarned(_ badge: Badge, in context: BadgeContext) -> Bool {
        switch badge {
        case .firstStep: context.totalCompletedWorkouts >= 1
        case .braveStarter: context.hasCompletedFullRun
        case .oneWeekStreak: context.currentStreakWeeks >= 1
        case .twoInOneWeek: context.sessionsThisWeek >= 2
        case .threeInOneWeek: context.sessionsThisWeek >= 3
        case .threeWeekStreak: context.currentStreakWeeks >= 3
        case .unbreakable: context.currentStreakWeeks >= 8
        case .monthHero: context.workoutsThisMonth >= 8
        case .backAgain: context.isComeback
        case .earlyBird: context.startedInMorning
        case .eveningStar: context.startedInEvening
        case .springAir: [3, 4, 5].contains(context.month)
        case .autumnRunner: [9, 10, 11].contains(context.month)
        case .iceInBelly: [12, 1, 2].contains(context.month)
        case .sunshineRunner: [6, 7, 8].contains(context.month)
        case .christmasRunner: context.month == 12 && (20...26).contains(context.day)
        case .newYearStart: (context.month == 12 && context.day == 31)
            || (context.month == 1 && (1...7).contains(context.day))
        case .neverGiveUp: context.hasCompletedHardRun
        case .momentPhoto: context.tookPhoto
        // Milepæle (importeret) — tildeles automatisk ud fra historikken.
        case .interval5: context.totalRunIntervals >= 5
        case .interval10: context.totalRunIntervals >= 10
        case .interval15: context.totalRunIntervals >= 15
        case .interval20: context.totalRunIntervals >= 20
        case .interval25: context.totalRunIntervals >= 25
        case .interval30: context.totalRunIntervals >= 30
        case .interval40: context.totalRunIntervals >= 40
        case .interval50: context.totalRunIntervals >= 50
        case .interval75: context.totalRunIntervals >= 75
        case .interval100: context.totalRunIntervals >= 100
        case .interval150: context.totalRunIntervals >= 150
        case .interval200: context.totalRunIntervals >= 200
        case .interval300: context.totalRunIntervals >= 300
        case .interval500: context.totalRunIntervals >= 500
        case .interval750: context.totalRunIntervals >= 750
        case .interval1000: context.totalRunIntervals >= 1000
        case .sessionFourIntervals: context.maxRunIntervalsInOneRun >= 4
        case .sessionSixIntervals: context.maxRunIntervalsInOneRun >= 6
        case .sessionEightIntervals: context.maxRunIntervalsInOneRun >= 8
        // Sammenhængende løb — længste løb uden gå-pause.
        case .continuousRun5: context.longestContinuousRunMinutes >= 5
        case .continuousRun10: context.longestContinuousRunMinutes >= 10
        case .continuousRun20: context.longestContinuousRunMinutes >= 20
        case .continuousRun30: context.longestContinuousRunMinutes >= 30
        // Vaner — små, valgfrie ja efter turen.
        case .stretchStar: context.didStretchAfterRun
        case .waterQueen: context.didDrinkWaterBeforeAndAfter
        case .runs1: context.totalCompletedWorkouts >= 1
        case .runs3: context.totalCompletedWorkouts >= 3
        case .runs5: context.totalCompletedWorkouts >= 5
        case .runs10: context.totalCompletedWorkouts >= 10
        case .runs15: context.totalCompletedWorkouts >= 15
        case .runs20: context.totalCompletedWorkouts >= 20
        case .runs25: context.totalCompletedWorkouts >= 25
        case .runs30: context.totalCompletedWorkouts >= 30
        case .runs40: context.totalCompletedWorkouts >= 40
        case .runs50: context.totalCompletedWorkouts >= 50
        case .runs60: context.totalCompletedWorkouts >= 60
        case .runs75: context.totalCompletedWorkouts >= 75
        case .runs80: context.totalCompletedWorkouts >= 80
        case .runs100: context.totalCompletedWorkouts >= 100
        case .activeWeeks1: context.totalActiveWeeks >= 1
        case .activeWeeks2: context.totalActiveWeeks >= 2
        case .activeWeeks4: context.totalActiveWeeks >= 4
        case .activeWeeks6: context.totalActiveWeeks >= 6
        case .activeWeeks8: context.totalActiveWeeks >= 8
        case .activeWeeks10: context.totalActiveWeeks >= 10
        case .activeWeeks12: context.totalActiveWeeks >= 12
        case .activeWeeks16: context.totalActiveWeeks >= 16
        case .activeWeeks20: context.totalActiveWeeks >= 20
        case .activeWeeks26: context.totalActiveWeeks >= 26
        case .activeWeeks52: context.totalActiveWeeks >= 52
        case .stars10: context.totalStars >= 10
        case .stars25: context.totalStars >= 25
        case .stars50: context.totalStars >= 50
        case .stars100: context.totalStars >= 100
        case .stars250: context.totalStars >= 250
        case .stars500: context.totalStars >= 500
        case .stars1000: context.totalStars >= 1000
        // Manuelle mærker — låses op af barnet selv i appen.
        case .readyToStart, .rainRunner, .fogRunner, .rainbowRunner, .birthdayRun,
             .cityRunner, .natureGirl, .newRoute, .newPlaylist, .musicInEars,
             .podcastRunner, .celebrateYourself, .cheerleader, .runningBuddy,
             .runningDiary, .packedAndReady, .sleepCollector:
            false
        }
    }

    /// Badges der netop er låst op — opfyldt af fakta og ikke optjent før.
    /// Rækkefølgen er stabil (efter `Badge.allCases`).
    public static func newlyEarned(context: BadgeContext, alreadyEarned: Set<Badge>) -> [Badge] {
        Badge.allCases.filter { isEarned($0, in: context) && !alreadyEarned.contains($0) }
    }
}
