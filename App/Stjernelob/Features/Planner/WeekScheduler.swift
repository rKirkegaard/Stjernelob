import Foundation

/// Fordeler ugens ture jævnt over ugen med hviledage imellem (spec afsnit 6.2).
/// Ugedage er 0-baserede med mandag = 0.
enum WeekScheduler {
    /// Forslag til træningsdage for et givet antal ture. Spredes jævnt, så der
    /// så vidt muligt er mindst én hviledag imellem.
    static func trainingDays(sessionsPerWeek sessions: Int) -> [Int] {
        let count = max(1, min(7, sessions))
        var days: [Int] = []
        for index in 0..<count {
            let day = Int((Double(index) * 7.0 / Double(count)).rounded(.toNearestOrAwayFromZero))
            days.append(min(6, day))
        }
        return days
    }

    /// Mandag-baseret ugedag (0...6) for en dato.
    static func weekdayMondayBased(_ date: Date, calendar: Calendar = .iso8601Monday) -> Int {
        let gregorianWeekday = calendar.component(.weekday, from: date) // 1=søndag ... 7=lørdag
        return (gregorianWeekday + 5) % 7
    }

    /// Er en given dag en planlagt træningsdag for ugens antal ture?
    static func isTrainingDay(_ date: Date, sessionsPerWeek: Int, calendar: Calendar = .iso8601Monday) -> Bool {
        trainingDays(sessionsPerWeek: sessionsPerWeek)
            .contains(weekdayMondayBased(date, calendar: calendar))
    }
}
