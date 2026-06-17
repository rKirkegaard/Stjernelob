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

    var earnedBadges: [Badge] { Badge.all.filter { earned.contains($0) } }

    /// Milepæls-stigerne, hver i stigende rækkefølge (katalogets orden). Udledt
    /// direkte af kataloget via `BadgeLadder`, så nye trin kræver ingen ændring
    /// her. Bruges til kun at vise det *næste* trin pr. stige, så samlingen ikke
    /// bliver en lang væg af fjerne mål.
    private static let ladders: [[Badge]] = BadgeLadder.allCases.map { ladder in
        Badge.all.filter { $0.ladder == ladder }
    }

    private static let ladderBadges: Set<Badge> = Set(ladders.flatMap { $0 })

    /// Endnu ikke optjente mærker. Hemmelige mærker skjules indtil de er låst op,
    /// og af milepælene vises kun det næste trin i hver stige — så det føles som
    /// et nært, opnåeligt mål frem for en uendelig liste.
    var lockedBadges: [Badge] {
        let base = Badge.all.filter {
            !earned.contains($0) && !$0.isSecret && !Self.ladderBadges.contains($0)
        }
        let nextLadderSteps = Self.ladders.compactMap { ladder in
            ladder.first { !earned.contains($0) && !$0.isSecret }
        }
        return base + nextLadderSteps
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
            let badges = Badge.all.filter { visible.contains($0) && $0.category == category }
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
