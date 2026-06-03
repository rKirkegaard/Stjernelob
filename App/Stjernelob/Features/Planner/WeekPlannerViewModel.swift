import Foundation
import Observation
import StjernelobCore

/// Ugeplanlægger (spec afsnit 6.2/7.3): brugeren vælger antal ture for ugen.
/// Valget styrer ugemålet (og dermed streaken) og fordelingen af dage. Tonen er
/// fleksibel: at vælge 1 tur i en hård uge er et fuldgyldigt valg.
@MainActor
@Observable
final class WeekPlannerViewModel {
    private let environment: AppEnvironment
    private let calendar = Calendar.iso8601Monday
    private static let danishCalendar: Calendar = {
        var calendar = Calendar(identifier: .iso8601)
        calendar.locale = Locale(identifier: "da_DK")
        return calendar
    }()

    var sessionsPerWeek = 3
    private let onSaved: () -> Void

    init(environment: AppEnvironment, onSaved: @escaping () -> Void = {}) {
        self.environment = environment
        self.onSaved = onSaved
    }

    private var currentWeek: WeekIdentifier {
        WeekIdentifier(date: Date(), calendar: calendar)
    }

    func load() {
        if let goal = try? environment.weeklyPlanRepository.goal(for: currentWeek) {
            sessionsPerWeek = goal.targetSessions
        } else if let profile = try? environment.profileRepository.load() {
            sessionsPerWeek = profile.defaultWeeklySessions
        }
    }

    /// Mandag-baserede ugedags-indeks, der foreslås som træningsdage.
    var trainingDays: [Int] {
        WeekScheduler.trainingDays(sessionsPerWeek: sessionsPerWeek)
    }

    /// Lokaliseret, kort ugedagsnavn for et mandag-baseret indeks (0 = mandag).
    func weekdayName(_ mondayBasedIndex: Int) -> String {
        let symbols = Self.danishCalendar.shortWeekdaySymbols // [søn, man, ... lør]
        let gregorianIndex = (mondayBasedIndex + 1) % 7
        return symbols[gregorianIndex].capitalized
    }

    func save() {
        try? environment.weeklyPlanRepository.setGoal(
            WeeklyGoalDTO(week: currentWeek, targetSessions: sessionsPerWeek)
        )
        if var profile = try? environment.profileRepository.load() {
            profile.defaultWeeklySessions = sessionsPerWeek
            try? environment.profileRepository.save(profile)
        }
        onSaved()
    }
}
