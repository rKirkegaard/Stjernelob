import Foundation

public extension Calendar {
    /// ISO 8601-kalender: ugen starter mandag, og uge-/årsgrænser er
    /// veldefinerede. Bruges som standard, så "den aktuelle uge" opfører sig
    /// forudsigeligt (jf. spec afsnit 16).
    static var iso8601Monday: Calendar {
        Calendar(identifier: .iso8601)
    }
}

/// Identificerer en bestemt kalenderuge entydigt (ISO-ugeår + ugenummer).
///
/// Streak og ugemål regnes på ugeniveau, ikke dagsniveau (jf. spec afsnit 5.3),
/// så al uge-logik hænger på denne type. To uger sammenlignes via deres
/// startdato, så "ugen før" og "antal uger imellem" er korrekte hen over
/// års- og tidszonegrænser.
public struct WeekIdentifier: Hashable, Codable, Sendable, Comparable {
    public let yearForWeekOfYear: Int
    public let weekOfYear: Int

    public init(yearForWeekOfYear: Int, weekOfYear: Int) {
        self.yearForWeekOfYear = yearForWeekOfYear
        self.weekOfYear = weekOfYear
    }

    /// Ugen som en given dato falder i, i en given kalender/tidszone.
    public init(date: Date, calendar: Calendar = .iso8601Monday) {
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        self.init(
            yearForWeekOfYear: components.yearForWeekOfYear ?? 0,
            weekOfYear: components.weekOfYear ?? 0
        )
    }

    /// Det første øjeblik (mandag 00:00) i ugen, i den givne kalender.
    public func startOfWeek(calendar: Calendar = .iso8601Monday) -> Date? {
        var components = DateComponents()
        components.yearForWeekOfYear = yearForWeekOfYear
        components.weekOfYear = weekOfYear
        components.weekday = calendar.firstWeekday
        return calendar.date(from: components)
    }

    /// Ugen et antal uger før/efter denne (negativt = tidligere).
    public func advanced(
        byWeeks offset: Int,
        calendar: Calendar = .iso8601Monday
    ) -> WeekIdentifier {
        guard let start = startOfWeek(calendar: calendar),
              let shifted = calendar.date(byAdding: .weekOfYear, value: offset, to: start)
        else {
            return self
        }
        return WeekIdentifier(date: shifted, calendar: calendar)
    }

    /// Ugen umiddelbart før denne.
    public func previous(calendar: Calendar = .iso8601Monday) -> WeekIdentifier {
        advanced(byWeeks: -1, calendar: calendar)
    }

    public static func < (lhs: WeekIdentifier, rhs: WeekIdentifier) -> Bool {
        if lhs.yearForWeekOfYear != rhs.yearForWeekOfYear {
            return lhs.yearForWeekOfYear < rhs.yearForWeekOfYear
        }
        return lhs.weekOfYear < rhs.weekOfYear
    }
}
