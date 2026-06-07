import Foundation
import Observation
import StjernelobCore

/// Samlingen (spec afsnit 7.7): optjente mærker, dem der mangler, og niveau-
/// fremgang. Alt handler om indsats og fremmøde — aldrig fart.
@MainActor
@Observable
final class BadgesViewModel {
    private let environment: AppEnvironment

    private(set) var earned: Set<Badge> = []
    private(set) var levelProgress = LevelSystem.standard.progress(forPoints: 0)

    init(environment: AppEnvironment) {
        self.environment = environment
    }

    func load() {
        earned = (try? environment.badgeRepository.earned()) ?? []
        let workouts = (try? environment.workoutRepository.all()) ?? []
        let stars = workouts.reduce(0) { $0 + $1.starsEarned }
        levelProgress = LevelSystem.standard.progress(forPoints: Points.fromStars(stars))
    }

    var earnedBadges: [Badge] { Badge.allCases.filter { earned.contains($0) } }

    /// Milepæls-mærker grupperet i stigende trin (intervaller, ture, aktive uger,
    /// stjerner). Bruges til kun at vise det *næste* trin pr. gruppe, så samlingen
    /// ikke bliver en lang væg af fjerne mål.
    private static let milestoneGroups: [[Badge]] = [
        [.interval5, .interval10, .interval25, .interval50, .interval100, .interval200, .interval500, .interval1000],
        [.sessionFourIntervals, .sessionSixIntervals, .sessionEightIntervals],
        [.runs1, .runs3, .runs5, .runs10, .runs15, .runs20, .runs25, .runs30, .runs40, .runs50, .runs75, .runs100],
        [.activeWeeks1, .activeWeeks2, .activeWeeks4, .activeWeeks6, .activeWeeks8, .activeWeeks10, .activeWeeks12, .activeWeeks16, .activeWeeks20, .activeWeeks26, .activeWeeks52],
        [.stars10, .stars25, .stars50, .stars100, .stars250, .stars500, .stars1000],
    ]
    private static let milestoneSet: Set<Badge> = Set(milestoneGroups.flatMap { $0 })

    /// Endnu ikke optjente mærker. Hemmelige mærker skjules indtil de er låst op,
    /// og af milepælene vises kun det næste trin i hver gruppe — så det føles som
    /// et nært, opnåeligt mål frem for en uendelig liste.
    var lockedBadges: [Badge] {
        let base = Badge.allCases.filter {
            !earned.contains($0) && !$0.isSecret && !Self.milestoneSet.contains($0)
        }
        let nextMilestones = Self.milestoneGroups.compactMap { group in
            group.first { !earned.contains($0) && !$0.isSecret }
        }
        return base + nextMilestones
    }

    /// Barnet låser selv et manuelt mærke op, når hun har gjort tingen
    /// (fx løbet med en makker). Selvbestemt og legende — aldrig et krav.
    func claim(_ badge: Badge) {
        guard badge.isManual else { return }
        try? environment.badgeRepository.award(badge)
        load()
    }
}
