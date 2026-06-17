import Foundation

/// Et lille, delt øjebliksbillede til Home Screen-widget'en. Appen skriver det,
/// widget'en læser det — via en App Group, så de to processer deler data.
///
/// Bevidst kun blide, ikke-pressende data (spec afsnit 10): en venlig beskrivelse
/// af næste tur og en varm stime, hvis der er en. Aldrig fart, distance eller
/// "du mangler"-tal.
public struct WidgetSnapshot: Codable, Sendable, Equatable {
    /// Kort, allerede lokaliseret beskrivelse af næste tur (fx "3 løb · 20 min").
    public let nextRunDetail: String
    /// Antal ugers stime — 0 betyder "vis ingen stime". Vises varmt, ikke som krav.
    public let streakWeeks: Int
    public let updatedAt: Date

    public init(nextRunDetail: String, streakWeeks: Int, updatedAt: Date) {
        self.nextRunDetail = nextRunDetail
        self.streakWeeks = streakWeeks
        self.updatedAt = updatedAt
    }
}

/// Læser/skriver widget-øjebliksbilledet i den delte App Group. Holder ingen
/// følsomme persondata (kun en kort tekst og et ugetal), jf. dataminimering.
public enum WidgetSharedStore {
    /// App Group-id'et — skal matche entitlements på både app og widget.
    public static let appGroupIdentifier = "group.com.rkirkegaard.stjernelob"
    private static let snapshotKey = "widget.snapshot"

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: appGroupIdentifier)
    }

    public static func save(_ snapshot: WidgetSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults?.set(data, forKey: snapshotKey)
    }

    public static func load() -> WidgetSnapshot? {
        guard let data = defaults?.data(forKey: snapshotKey) else { return nil }
        return try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
    }

    /// Ryd det delte øjebliksbillede (fx ved fuld datasletning, GDPR afsnit 14).
    public static func clear() {
        defaults?.removeObject(forKey: snapshotKey)
    }
}
