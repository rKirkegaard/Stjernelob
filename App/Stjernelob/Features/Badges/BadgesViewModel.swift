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
        [
            .interval5,
            .interval10,
            .interval15,
            .interval20,
            .interval25,
            .interval30,
            .interval40,
            .interval50,
            .interval75,
            .interval100,
            .interval150,
            .interval200,
            .interval300,
            .interval500,
            .interval750,
            .interval1000,
        ],
        [.sessionFourIntervals, .sessionSixIntervals, .sessionEightIntervals],
        [.continuousRun5, .continuousRun10, .continuousRun20, .continuousRun30],
        [
            .runs1,
            .runs3,
            .runs5,
            .runs10,
            .runs15,
            .runs20,
            .runs25,
            .runs30,
            .runs40,
            .runs50,
            .runs60,
            .runs75,
            .runs80,
            .runs100,
        ],
        [
            .activeWeeks1,
            .activeWeeks2,
            .activeWeeks4,
            .activeWeeks6,
            .activeWeeks8,
            .activeWeeks10,
            .activeWeeks12,
            .activeWeeks16,
            .activeWeeks20,
            .activeWeeks26,
            .activeWeeks52,
        ],
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

    /// En tema-gruppe i samlingen med de mærker, der skal vises.
    struct CategorySection: Identifiable {
        let category: BadgeCategory
        let badges: [Badge]
        var id: String { category.rawValue }
    }

    /// Samlingen inddelt i tema-grupper (optjente + synlige låste), i stabil
    /// rækkefølge. Tomme grupper udelades.
    var sections: [CategorySection] {
        let visible = Set(earnedBadges).union(lockedBadges)
        return BadgeCategory.allCases.compactMap { category in
            let badges = Badge.allCases.filter { visible.contains($0) && $0.category == category }
            return badges.isEmpty ? nil : CategorySection(category: category, badges: badges)
        }
    }

    func isEarned(_ badge: Badge) -> Bool { earned.contains(badge) }

    /// Barnet låser selv et manuelt mærke op, når hun har gjort tingen
    /// (fx løbet med en makker). Selvbestemt og legende — aldrig et krav.
    func claim(_ badge: Badge) {
        guard badge.isManual else { return }
        try? environment.badgeRepository.award(badge)
        load()
    }
}
