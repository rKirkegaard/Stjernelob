import Foundation
import UserNotifications

/// Planlægger venlige, lokale (netuafhængige) påmindelser på ugens trænings-
/// dage (spec afsnit 8). Opt-in, kan slås fra, og teksten spiller aldrig på
/// skyld eller frygt for at miste en streak.
@MainActor
final class NotificationScheduler {
    private let center = UNUserNotificationCenter.current()

    func requestAuthorization() async -> Bool {
        (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
    }

    /// Genplanlæg alle påmindelser. Fjerner altid de gamle først.
    func reschedule(enabled: Bool, hour: Int, mondayBasedDays: [Int]) async {
        center.removeAllPendingNotificationRequests()
        guard enabled else { return }
        guard await requestAuthorization() else { return }

        for day in mondayBasedDays {
            var components = DateComponents()
            components.hour = hour
            components.minute = 0
            // Mandag-baseret (0=mandag) → gregoriansk weekday (1=søndag ... 7=lørdag).
            components.weekday = ((day + 1) % 7) + 1

            let content = UNMutableNotificationContent()
            content.title = String(localized: Strings.Notifications.reminderTitle)
            content.body = String(localized: Strings.Notifications.reminderBody)
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(
                identifier: "stjernelob.reminder.\(day)",
                content: content,
                trigger: trigger
            )
            try? await center.add(request)
        }
    }
}
