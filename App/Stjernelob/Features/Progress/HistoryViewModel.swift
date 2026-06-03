import Foundation
import Observation
import StjernelobCore

/// Oversigt over gennemførte træninger (spec afsnit 6.4): liste og kalender,
/// med fokus på "se hvor langt du er nået" — fremmøde og fremgang, aldrig fart
/// eller sammenligning.
@MainActor
@Observable
final class HistoryViewModel {
    private let environment: AppEnvironment
    private let calendar = Calendar.iso8601Monday

    private(set) var workouts: [CompletedWorkoutDTO] = []

    init(environment: AppEnvironment) {
        self.environment = environment
    }

    func load() {
        workouts = (try? environment.workoutRepository.all()) ?? []
    }

    var completedCount: Int { workouts.filter(\.isComplete).count }

    /// Dage (kl. 00:00) hvor der er gennemført mindst én tur — til kalender-markering.
    var trainingDays: Set<Date> {
        Set(workouts.map { calendar.startOfDay(for: $0.date) })
    }

    /// De seneste 6 ugers dage (mandag-først), til en kompakt kalender.
    func recentWeeks(endingOn today: Date = Date(), weeks: Int = 6) -> [[Date]] {
        guard let thisMonday = calendar.dateInterval(of: .weekOfYear, for: today)?.start else { return [] }
        var grid: [[Date]] = []
        for weekOffset in stride(from: weeks - 1, through: 0, by: -1) {
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: thisMonday) else { continue }
            let days = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
            grid.append(days)
        }
        return grid
    }
}
