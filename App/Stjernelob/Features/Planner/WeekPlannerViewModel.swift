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

    /// Brugerens valgte træningsdage (mandag-baseret 0...6). Antallet af valgte
    /// dage er samtidig ugens antal ture — man vælger selv hvilke dage.
    private(set) var selectedDays: Set<Int> = []
    private let onSaved: () -> Void

    /// Alle ugedage i visningsrækkefølge (mandag først).
    let allDays = Array(0...6)

    init(environment: AppEnvironment, onSaved: @escaping () -> Void = {}) {
        self.environment = environment
        self.onSaved = onSaved
    }

    private var currentWeek: WeekIdentifier {
        WeekIdentifier(date: Date(), calendar: calendar)
    }

    func load() {
        let profile = try? environment.profileRepository.load()
        let sessions = (try? environment.weeklyPlanRepository.goal(for: currentWeek))?
            .targetSessions ?? profile?.defaultWeeklySessions ?? 3
        if let chosen = profile?.trainingDays, !chosen.isEmpty {
            selectedDays = Set(chosen.filter { (0...6).contains($0) })
        } else {
            // Ingen valgt endnu: start fra det jævne forslag, så man bare kan justere.
            selectedDays = Set(WeekScheduler.trainingDays(sessionsPerWeek: sessions))
        }
    }

    /// Slå en dag til/fra som træningsdag.
    func toggle(_ day: Int) {
        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }
    }

    func isSelected(_ day: Int) -> Bool { selectedDays.contains(day) }

    /// Fyld med et jævnt fordelt forslag ud fra det aktuelle antal valgte dage
    /// (mindst 3, hvis intet er valgt) — en hurtig genvej man stadig kan justere.
    func suggestEvenly() {
        let count = max(3, selectedDays.count)
        selectedDays = Set(WeekScheduler.trainingDays(sessionsPerWeek: count))
    }

    /// Antal valgte dage = ugens antal ture.
    var sessionCount: Int { selectedDays.count }
    /// Mindst én dag skal være valgt, før man kan gemme.
    var canSave: Bool { !selectedDays.isEmpty }

    /// Lokaliseret, kort ugedagsnavn for et mandag-baseret indeks (0 = mandag).
    func weekdayName(_ mondayBasedIndex: Int) -> String {
        let symbols = Self.danishCalendar.shortWeekdaySymbols // [søn, man, ... lør]
        let gregorianIndex = (mondayBasedIndex + 1) % 7
        return symbols[gregorianIndex].capitalized
    }

    func save() {
        let days = selectedDays.sorted()
        guard !days.isEmpty else { return }
        let sessions = days.count
        try? environment.weeklyPlanRepository.setGoal(
            WeeklyGoalDTO(week: currentWeek, targetSessions: sessions)
        )
        if var profile = try? environment.profileRepository.load() {
            profile.defaultWeeklySessions = sessions
            profile.trainingDays = days
            try? environment.profileRepository.save(profile)
        }
        onSaved()
    }
}
