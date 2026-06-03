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
    var lockedBadges: [Badge] { Badge.allCases.filter { !earned.contains($0) } }
}
