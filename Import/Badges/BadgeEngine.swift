import Foundation

// MARK: - Session Context

// Passed to BadgeEngine after each session completes.
// WeatherService, AudioService etc. populate the optional fields.

struct SessionContext {
    let session: CompletedSession
    let userProgress: UserProgress
    let calendar: Calendar

    // Populated by external services
    var weatherCondition: WeatherCondition?
    var audioWasPlaying: Bool = false
    var podcastWasPlaying: Bool = false
    var usedPartnerMode: Bool = false
    var stretchedAfter: Bool = false
    var loggedWaterBeforeAndAfter: Bool = false
    var preparedGearNightBefore: Bool = false
    var sleptWellBefore: Bool = false // HealthKit sleep > 7h
    var isNewRoute: Bool = false
    var locationCategory: LocationCategory = .unknown
    var playlistIsNew: Bool = false
    var journalNoteAdded: Bool = false
    var proudNoteAdded: Bool = false
    var photoShared: Bool = false
    var friendInvited: Bool = false
}

enum WeatherCondition: String, Codable {
    case rain, cold, fog, sunshine, afterRain, unknown
}

enum LocationCategory: String, Codable {
    case city, nature, unknown
}

// MARK: - CompletedSession

struct CompletedSession: Codable, Identifiable {
    let id: UUID
    var planWeekNumber: Int
    var planSessionLabel: String
    var startedAt: Date
    var completedAt: Date
    var starsEarned: Int
}

// MARK: - UserProgress

// The full picture of what a user has done — BadgeEngine reads this to
// evaluate triggers.

struct UserProgress: Codable {
    var completedSessions: [CompletedSession] = []
    var earnedBadges: [EarnedBadge] = []
    var weekStreakCount: Int = 0
    var currentWeekSessionCount: Int = 0
    var birthdayComponents: DateComponents? = nil // Month + day only

    var totalSessionsCompleted: Int { completedSessions.count }

    func hasEarnedBadge(slug: String) -> Bool {
        earnedBadges.contains { $0.badgeSlug == slug }
    }

    /// Sessions completed within the same ISO week as a given date
    func sessions(inSameWeekAs date: Date, calendar: Calendar) -> [CompletedSession] {
        completedSessions.filter {
            calendar.isDate($0.startedAt, equalTo: date, toGranularity: .weekOfYear)
        }
    }

    /// Days since the last completed session (nil if no sessions yet)
    func daysSinceLastSession(from now: Date, calendar: Calendar) -> Int? {
        guard let last = completedSessions.max(by: { $0.completedAt < $1.completedAt }) else {
            return nil
        }
        return calendar.dateComponents([.day], from: last.completedAt, to: now).day
    }
}

// MARK: - BadgeEngine

// Evaluates all badge triggers after each session and returns newly earned badges.
// Stateless — depends entirely on SessionContext and BadgeCatalogue.

final class BadgeEngine {
    private let catalogue: BadgeCatalogue
    private let calendar: Calendar

    init(
        catalogue: BadgeCatalogue = .default,
        calendar: Calendar = Calendar(identifier: .iso8601)
    ) {
        self.catalogue = catalogue
        self.calendar = calendar
    }

    /// Call after every session completes. Returns badges earned for the first time.
    func evaluate(context: SessionContext) -> [Badge] {
        catalogue.badges.compactMap { badge in
            guard !context.userProgress.hasEarnedBadge(slug: badge.slug) else { return nil }
            return isTriggerMet(badge.trigger, context: context) ? badge : nil
        }
    }

    // MARK: - Trigger evaluation

    private func isTriggerMet(_ trigger: BadgeTrigger, context: SessionContext) -> Bool {
        let progress = context.userProgress
        let session = context.session
        let now = session.completedAt

        switch trigger {
        // MARK: Completion

        case .completeFirstSession:
            return progress.totalSessionsCompleted == 1

        case let .completeSessions(count):
            return progress.totalSessionsCompleted >= count

        case let .completeWeek(weekNumber):
            return session.planWeekNumber == weekNumber

        case let .completePhase(phase):
            // Phase ends at the last week of that phase in the 20-week plan
            let phaseLastWeek = phaseLastWeekNumber(phase)
            return session.planWeekNumber == phaseLastWeek

        // MARK: Streaks

        case let .weekStreak(weeks):
            return progress.weekStreakCount >= weeks

        case let .returnAfterBreak(minDays), let .returnedAfterPause(minDays):
            guard let days = progress.daysSinceLastSession(from: now, calendar: calendar) else {
                return false
            }
            // "Returning" means this is the first session after a gap of ≥ minDays
            // daysSinceLastSession is computed *before* this session is appended
            return days >= minDays

        // MARK: Weekly frequency

        case let .sessionsInOneWeek(count):
            let sessionsThisWeek = progress.sessions(inSameWeekAs: now, calendar: calendar)
            return sessionsThisWeek.count >= count

        // MARK: Time of day

        case .morningSession:
            let hour = calendar.component(.hour, from: session.startedAt)
            return hour < 9

        case .eveningSession:
            let hour = calendar.component(.hour, from: session.startedAt)
            return hour >= 19

        case .nightSession:
            let hour = calendar.component(.hour, from: session.startedAt)
            return hour >= 21

        // MARK: Weather

        case .sessionInRain:
            return context.weatherCondition == .rain

        case let .sessionInCold(threshold):
            // WeatherService must provide actual temperature;
            // here we use .cold as a proxy when threshold == 5 (default)
            return context.weatherCondition == .cold && threshold <= 5

        case let .sessionInSunshine(count):
            guard context.weatherCondition == .sunshine else { return false }
            let sunshineCount = progress.completedSessions.filter { _ in
                // In production: check stored weather on each session
                // Here: conservative — check count of sessions tagged sunshine
                // WeatherService stores condition on CompletedSession
                true // placeholder — real implementation queries persisted weather
            }.count
            return sunshineCount >= count

        case .sessionInFog:
            return context.weatherCondition == .fog

        case .sessionAfterRain:
            return context.weatherCondition == .afterRain

        case .sessionInAutumn:
            let month = calendar.component(.month, from: now)
            return (9...11).contains(month)

        case .sessionInSpring:
            let month = calendar.component(.month, from: now)
            return (3...5).contains(month)

        // MARK: Habits

        case .addedJournalNote:
            return context.journalNoteAdded

        case .sessionWithAudio:
            return context.audioWasPlaying

        case let .stretchedAfterSession(count):
            // Count stored stretch events; use context for the current one
            let stretchCount = (context.stretchedAfter ? 1 : 0)
                + progress.completedSessions.count // placeholder: real impl counts stored stretches
            return stretchCount >= count

        case let .drankWaterBeforeAndAfter(count):
            let waterCount = (context.loggedWaterBeforeAndAfter ? 1 : 0)
                + 0 // placeholder: query persisted water logs
            return waterCount >= count

        case .preparedGearNightBefore:
            return context.preparedGearNightBefore

        case .sessionAfterGoodSleep:
            return context.sleptWellBefore

        // MARK: Social

        case .sessionWithPartner:
            return context.usedPartnerMode

        case .sharedPhoto:
            return context.photoShared

        case .invitedFriend:
            return context.friendInvited

        case .sessionWithPodcast:
            return context.podcastWasPlaying

        case .wroteProudNote:
            return context.proudNoteAdded

        // MARK: Special

        case .sessionInDecember:
            return calendar.component(.month, from: now) == 12

        case .sessionFirstWeekOfJanuary:
            let month = calendar.component(.month, from: now)
            let week = calendar.component(.weekOfMonth, from: now)
            return month == 1 && week == 1

        case .sessionOnBirthday:
            guard let bday = progress.birthdayComponents else { return false }
            let sessionMonth = calendar.component(.month, from: now)
            let sessionDay = calendar.component(.day, from: now)
            return sessionMonth == bday.month && sessionDay == bday.day

        case .sessionOnNewRoute:
            return context.isNewRoute

        case .sessionInCity:
            return context.locationCategory == .city

        case .sessionInNature:
            return context.locationCategory == .nature

        case .sessionWithNewPlaylist:
            return context.playlistIsNew

        // MARK: Programme milestones

        case let .firstContinuousRun(minutes):
            // IntervalEngine marks a session as "continuous" if no walk break occurred
            // CompletedSession should carry a longestContinuousRunSeconds field
            // Placeholder: always false until IntervalEngine integration
            return false
        }
    }

    // MARK: - Helpers

    private func phaseLastWeekNumber(_ phase: Phase) -> Int {
        switch phase {
        case .firstSteps: 4
        case .buildingUp: 8
        case .findingStrength: 12
        case .confidentRunner: 16
        case .continuousRunner: 20
        }
    }
}
