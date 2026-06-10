import Foundation
import StjernelobCore

/// Det kuraterede udsnit, en forælder kan se (spec afsnit 11.3) — bevidst kun
/// indsats og fremmøde, aldrig tempo, vægt eller andet, der inviterer til pres.
/// Felter er `nil`, når barnet ikke deler dem.
struct ParentShareSnapshot: Equatable {
    var streakWeeks: Int?
    var completedCount: Int?
    var milestones: [Badge]?

    var isEmpty: Bool {
        streakWeeks == nil && completedCount == nil && (milestones?.isEmpty ?? true)
    }
}

/// Leverer det kuraterede udsnit. Lokal implementering bygger det fra barnets
/// egne data efter delingsindstillingerne. En CloudKit Sharing-implementering
/// (forælder-link på tværs af enheder) kan lægges bag samme protokol senere.
@MainActor
protocol SharingService {
    func curatedSnapshot() -> ParentShareSnapshot
}

@MainActor
struct LocalSharingService: SharingService {
    let environment: AppEnvironment

    func curatedSnapshot() -> ParentShareSnapshot {
        let settings = environment.settings
        var snapshot = ParentShareSnapshot()

        if settings.shareStreak {
            let service = WeeklyStatusService(
                weeklyPlanRepository: environment.weeklyPlanRepository,
                workoutRepository: environment.workoutRepository
            )
            snapshot.streakWeeks = (try? service.tracker())?
                .currentStreak(asOf: WeekIdentifier(date: Date())) ?? 0
        }

        if settings.shareWorkouts {
            let workouts = (try? environment.workoutRepository.all()) ?? []
            snapshot.completedCount = workouts.filter(\.isComplete).count
        }

        if settings.shareMilestones {
            let earned = (try? environment.badgeRepository.earned()) ?? []
            snapshot.milestones = Badge.allCases.filter { earned.contains($0) }
        }

        return snapshot
    }
}
