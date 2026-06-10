import Foundation
import Observation

/// Holder og persisterer brugerens indstillinger (lyd/stemme/haptik,
/// påmindelser, streak-fryser). De mest beskyttende valg er standard, og alt
/// kan slås fra (privacy by default, afsnit 14.1).
@MainActor
@Observable
final class SettingsStore {
    var feedback: FeedbackSettings { didSet { persistFeedback() } }
    var remindersEnabled: Bool { didSet { defaults.set(remindersEnabled, forKey: Keys.reminders) } }
    var reminderHour: Int { didSet { defaults.set(reminderHour, forKey: Keys.reminderHour) } }
    var streakFreezeEnabled: Bool { didSet { defaults.set(
        streakFreezeEnabled,
        forKey: Keys.streakFreeze
    ) } }
    var healthKitEnabled: Bool { didSet { defaults.set(healthKitEnabled, forKey: Keys.healthKit) } }
    // Forælder-deling — alt opt-in (privacy by default, afsnit 11.2/14).
    var shareStreak: Bool { didSet { defaults.set(shareStreak, forKey: Keys.shareStreak) } }
    var shareWorkouts: Bool { didSet { defaults.set(shareWorkouts, forKey: Keys.shareWorkouts) } }
    var shareMilestones: Bool {
        didSet { defaults.set(shareMilestones, forKey: Keys.shareMilestones) }
    }

    /// Personlig sikkerhed (afsnit 12) — alt opt-in og altid synligt for barnet.
    var livePositionEnabled: Bool { didSet { defaults.set(
        livePositionEnabled,
        forKey: Keys.livePosition
    ) } }
    var awayHomeEnabled: Bool { didSet { defaults.set(awayHomeEnabled, forKey: Keys.awayHome) } }
    var emergencyContactName: String { didSet { defaults.set(
        emergencyContactName,
        forKey: Keys.contactName
    ) } }
    var emergencyContactPhone: String { didSet { defaults.set(
        emergencyContactPhone,
        forKey: Keys.contactPhone
    ) } }

    private let defaults: UserDefaults

    private enum Keys {
        static let feedback = "settings.feedback"
        static let reminders = "settings.remindersEnabled"
        static let reminderHour = "settings.reminderHour"
        static let streakFreeze = "settings.streakFreezeEnabled"
        static let healthKit = "settings.healthKitEnabled"
        static let shareStreak = "settings.shareStreak"
        static let shareWorkouts = "settings.shareWorkouts"
        static let shareMilestones = "settings.shareMilestones"
        static let livePosition = "settings.livePosition"
        static let awayHome = "settings.awayHome"
        static let contactName = "settings.contactName"
        static let contactPhone = "settings.contactPhone"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: Keys.feedback),
           let decoded = try? JSONDecoder().decode(FeedbackSettings.self, from: data)
        {
            feedback = decoded
        } else {
            feedback = FeedbackSettings()
        }
        // Påmindelser er som standard fra (opt-in), kl. 17 hvis slået til.
        remindersEnabled = defaults.object(forKey: Keys.reminders) as? Bool ?? false
        reminderHour = defaults.object(forKey: Keys.reminderHour) as? Int ?? 17
        streakFreezeEnabled = defaults.object(forKey: Keys.streakFreeze) as? Bool ?? true
        healthKitEnabled = defaults.object(forKey: Keys.healthKit) as? Bool ?? false
        shareStreak = defaults.object(forKey: Keys.shareStreak) as? Bool ?? false
        shareWorkouts = defaults.object(forKey: Keys.shareWorkouts) as? Bool ?? false
        shareMilestones = defaults.object(forKey: Keys.shareMilestones) as? Bool ?? false
        livePositionEnabled = defaults.object(forKey: Keys.livePosition) as? Bool ?? false
        awayHomeEnabled = defaults.object(forKey: Keys.awayHome) as? Bool ?? false
        emergencyContactName = defaults.string(forKey: Keys.contactName) ?? ""
        emergencyContactPhone = defaults.string(forKey: Keys.contactPhone) ?? ""
    }

    private func persistFeedback() {
        if let data = try? JSONEncoder().encode(feedback) {
            defaults.set(data, forKey: Keys.feedback)
        }
    }
}
