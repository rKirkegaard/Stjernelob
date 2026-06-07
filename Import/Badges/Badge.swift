import Foundation
import SwiftUI

// MARK: - Badge Category

enum BadgeCategory: String, Codable, CaseIterable {
    case firstSteps   = "Første skridt"
    case consistency  = "Konsistens"
    case weather      = "Vejr & omgivelser"
    case habits       = "Vaner & rutiner"
    case social       = "Social & sjov"
    case special      = "Særlige øjeblikke"
}

// MARK: - Badge Trigger

/// Defines what must happen for a badge to be earned.
/// The BadgeEngine evaluates these against UserProgress.
enum BadgeTrigger: Codable {

    // Completion-based
    case completeSessions(count: Int)       // Complete N sessions total
    case completeFirstSession               // Literally the first session ever
    case completeWeek(weekNumber: Int)      // Complete a specific week
    case completePhase(phase: Phase)        // Complete a full phase

    // Streak-based (week streaks, not daily)
    case weekStreak(weeks: Int)             // N consecutive completed weeks
    case returnAfterBreak(minDays: Int)     // Come back after ≥ N days gap

    // Session frequency
    case sessionsInOneWeek(count: Int)      // N sessions within same calendar week

    // Time-of-day
    case morningSession                     // Session started before 09:00
    case eveningSession                     // Session started after 19:00
    case nightSession                       // Session started after 21:00

    // Weather conditions (passed in from WeatherService at session end)
    case sessionInRain
    case sessionInCold(belowCelsius: Int)   // e.g. belowCelsius: 5
    case sessionInFog
    case sessionInSunshine(count: Int)      // N sessions in sunshine
    case sessionAfterRain                   // Within 1 hour after rain stopped
    case sessionInAutumn                    // Sept–Nov
    case sessionInSpring                    // Mar–May

    // Habits
    case addedJournalNote(afterSessions: Int)     // Notes added N times
    case sessionWithAudio                         // Ran with music/podcast
    case stretchedAfterSession(count: Int)        // Stretched after N sessions
    case drankWaterBeforeAndAfter(count: Int)     // Logged water N times
    case preparedGearNightBefore                  // Gear prep logged evening before
    case sessionAfterGoodSleep                    // Sleep >7h logged, then session

    // Social
    case sessionWithPartner                       // Partner mode used
    case sharedPhoto                              // Photo shared from a session
    case invitedFriend                            // Friend invite sent
    case sessionWithPodcast                       // Podcast detected during session
    case wroteProudNote                           // Proud note written after session
    case returnedAfterPause(minDays: Int)         // Same as returnAfterBreak alias

    // Special / calendar
    case sessionInDecember
    case sessionFirstWeekOfJanuary
    case sessionOnBirthday                        // Requires birthday in profile
    case sessionOnNewRoute                        // Route > X meters from all previous routes
    case sessionInCity                            // GPS in urban area
    case sessionInNature                          // GPS outside urban area
    case sessionWithNewPlaylist                   // New playlist detected

    // Programme milestones
    case firstContinuousRun(minutes: Int)         // First session with no walk break ≥ N min
}

// MARK: - Badge

struct Badge: Codable, Identifiable {
    let id: UUID
    var slug: String            // Matches filenames: "første-skridt", "3-ugers-streak" etc.
    var name: String            // Display name: "Første skridt"
    var description: String     // Short unlock description shown to user
    var category: BadgeCategory
    var trigger: BadgeTrigger
    var isSecret: Bool          // If true, badge is hidden until earned

    init(id: UUID = UUID(),
         slug: String,
         name: String,
         description: String,
         category: BadgeCategory,
         trigger: BadgeTrigger,
         isSecret: Bool = false) {
        self.id = id
        self.slug = slug
        self.name = name
        self.description = description
        self.category = category
        self.trigger = trigger
        self.isSecret = isSecret
    }

    /// SVG asset name in the app bundle
    var assetName: String { "\(slug).svg" }
}

// MARK: - EarnedBadge

/// A record of a badge being earned by the user
struct EarnedBadge: Codable, Identifiable {
    let id: UUID
    var badgeSlug: String
    var earnedAt: Date
    var sessionID: UUID?        // The session that triggered it (if applicable)

    init(id: UUID = UUID(),
         badgeSlug: String,
         earnedAt: Date = .now,
         sessionID: UUID? = nil) {
        self.id = id
        self.badgeSlug = badgeSlug
        self.earnedAt = earnedAt
        self.sessionID = sessionID
    }
}

// MARK: - Badge Catalogue

/// The full set of badges available in Stjerneløb.
/// Loaded once at app start and kept in memory.
struct BadgeCatalogue {
    let badges: [Badge]

    func badge(forSlug slug: String) -> Badge? {
        badges.first { $0.slug == slug }
    }

    func badges(in category: BadgeCategory) -> [Badge] {
        badges.filter { $0.category == category }
    }

    static let `default` = BadgeCatalogue(badges: BadgeCatalogue.allBadges)
}

// MARK: - Badge definitions

extension BadgeCatalogue {
    static let allBadges: [Badge] = [

        // MARK: Første skridt
        Badge(slug: "første-skridt",   name: "Første skridt",
              description: "Fuldfør din allerførste løbetur",
              category: .firstSteps,   trigger: .completeFirstSession),

        Badge(slug: "klar-til-start",  name: "Klar til start",
              description: "Sæt dine løbemål i appen",
              category: .firstSteps,   trigger: .completeSessions(count: 1)),

        Badge(slug: "modig-starter",   name: "Modig starter",
              description: "Løb selvom du ikke havde lyst",
              category: .firstSteps,   trigger: .completeSessions(count: 3)),

        Badge(slug: "tidlig-fugl",     name: "Tidlig fugl",
              description: "Din første tur om morgenen",
              category: .firstSteps,   trigger: .morningSession),

        Badge(slug: "aftenstjerne",    name: "Aftenstjerne",
              description: "Din første tur om aftenen",
              category: .firstSteps,   trigger: .eveningSession),

        // MARK: Konsistens
        Badge(slug: "2-i-en-uge",      name: "2 i én uge",
              description: "Løb 2 gange i samme uge",
              category: .consistency,  trigger: .sessionsInOneWeek(count: 2)),

        Badge(slug: "3-i-en-uge",      name: "3 i én uge",
              description: "Løb 3 gange i samme uge",
              category: .consistency,  trigger: .sessionsInOneWeek(count: 3)),

        Badge(slug: "en-uge-i-traek",  name: "En uge i træk",
              description: "Gennemfør ugesmålet 7 dage i træk",
              category: .consistency,  trigger: .weekStreak(weeks: 1)),

        Badge(slug: "3-ugers-streak",  name: "3-ugers streak",
              description: "Gennemfør ugesmålet 3 uger i træk",
              category: .consistency,  trigger: .weekStreak(weeks: 3)),

        Badge(slug: "maanedshelt",     name: "Månedshelt",
              description: "Gennemfør ugesmålet alle uger i en måned",
              category: .consistency,  trigger: .weekStreak(weeks: 4)),

        Badge(slug: "ubrydelig",       name: "Ubrydelig",
              description: "5-ugers streak — du stopper ikke!",
              category: .consistency,  trigger: .weekStreak(weeks: 5)),

        Badge(slug: "tilbage-igen",    name: "Tilbage igen",
              description: "Løb to uger i træk efter en pause",
              category: .consistency,  trigger: .returnAfterBreak(minDays: 10)),

        // MARK: Vejr & omgivelser
        Badge(slug: "regnvejrsloeber",  name: "Regnvejrsløber",
              description: "Løb en tur i regnvejr",
              category: .weather,       trigger: .sessionInRain),

        Badge(slug: "is-i-maven",       name: "Is i maven",
              description: "Løb en tur når det er under 5 grader",
              category: .weather,       trigger: .sessionInCold(belowCelsius: 5)),

        Badge(slug: "solskinsloeber",   name: "Solskinsløber",
              description: "Løb 5 ture i solskin",
              category: .weather,       trigger: .sessionInSunshine(count: 5)),

        Badge(slug: "taagelober",       name: "Tågeløber",
              description: "Løb en tur i tåge",
              category: .weather,       trigger: .sessionInFog),

        Badge(slug: "regnbue-runner",   name: "Regnbue-runner",
              description: "Løb lige efter det har regnet",
              category: .weather,       trigger: .sessionAfterRain),

        Badge(slug: "efteraarsloeber",  name: "Efterårsløber",
              description: "Løb en tur i blade og efterårsvejr",
              category: .weather,       trigger: .sessionInAutumn),

        Badge(slug: "foraarsluft",      name: "Forårsluft",
              description: "Din første tur i forårsvejr",
              category: .weather,       trigger: .sessionInSpring),

        // MARK: Vaner & rutiner
        Badge(slug: "loebedagbog",      name: "Løbedagbog",
              description: "Skriv en note efter din tur",
              category: .habits,        trigger: .addedJournalNote(afterSessions: 1)),

        Badge(slug: "musik-i-oererne",  name: "Musik i ørerne",
              description: "Løb en tur med musik eller podcast",
              category: .habits,        trigger: .sessionWithAudio),

        Badge(slug: "straek-stjerne",   name: "Stræk-stjerne",
              description: "Stræk ud efter din tur 3 gange",
              category: .habits,        trigger: .stretchedAfterSession(count: 3)),

        Badge(slug: "vand-dronning",    name: "Vand-dronning",
              description: "Drik vand før OG efter 5 ture",
              category: .habits,        trigger: .drankWaterBeforeAndAfter(count: 5)),

        Badge(slug: "soevn-samler",     name: "Søvn-samler",
              description: "Løb efter en god nats søvn 3 gange",
              category: .habits,        trigger: .sessionAfterGoodSleep),

        Badge(slug: "pakket-og-klar",   name: "Pakket og klar",
              description: "Læg dit løbetøj frem aftenen før",
              category: .habits,        trigger: .preparedGearNightBefore),

        // MARK: Social & sjov
        Badge(slug: "loebemakker",      name: "Løbemakker",
              description: "Løb en tur med en anden",
              category: .social,        trigger: .sessionWithPartner),

        Badge(slug: "loebs-selfie",     name: "Løbs-selfie",
              description: "Del en løbefoto i appen",
              category: .social,        trigger: .sharedPhoto),

        Badge(slug: "hepperen",         name: "Hepperen",
              description: "Opfordr en ven til at løbe med",
              category: .social,        trigger: .invitedFriend),

        Badge(slug: "podcast-runner",   name: "Podcast-runner",
              description: "Lyt til en episode på en tur",
              category: .social,        trigger: .sessionWithPodcast),

        Badge(slug: "fejer-dig-selv",   name: "Fejr dig selv",
              description: "Skriv hvad du er stolt af efter en tur",
              category: .social,        trigger: .wroteProudNote),

        Badge(slug: "aldrig-give-op",   name: "Aldrig give op",
              description: "Kom tilbage efter 14 dages pause",
              category: .social,        trigger: .returnedAfterPause(minDays: 14)),

        // MARK: Særlige øjeblikke
        Badge(slug: "juleloeber",       name: "Juleløber",
              description: "Løb en tur i december",
              category: .special,       trigger: .sessionInDecember),

        Badge(slug: "nytaarsstart",     name: "Nytårsstart",
              description: "Løb i den første uge af januar",
              category: .special,       trigger: .sessionFirstWeekOfJanuary),

        Badge(slug: "foedselsdag",      name: "Fødselsdagstur",
              description: "Løb en tur på din fødselsdag",
              category: .special,       trigger: .sessionOnBirthday),

        Badge(slug: "ny-rute",          name: "Ny rute",
              description: "Løb et sted du aldrig har løbet før",
              category: .special,       trigger: .sessionOnNewRoute),

        Badge(slug: "byloeber",         name: "Byløber",
              description: "Løb en tur i byen",
              category: .special,       trigger: .sessionInCity),

        Badge(slug: "naturpige",        name: "Naturpige",
              description: "Løb en tur i skoven eller naturen",
              category: .special,       trigger: .sessionInNature),

        Badge(slug: "ny-playlist",      name: "Ny playlist",
              description: "Løb med en helt ny playlist",
              category: .special,       trigger: .sessionWithNewPlaylist),
    ]
}
