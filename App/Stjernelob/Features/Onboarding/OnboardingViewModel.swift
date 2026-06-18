import Foundation
import Observation
import StjernelobCore

/// Onboarding: kort, venlig intro + helbredsscreening + valg af ugentligt
/// træningsantal (spec afsnit 7.1). Gemmer en profil og markerer onboarding
/// som fuldført.
@MainActor
@Observable
final class OnboardingViewModel {
    var hasRunBefore = false
    var weeklySessions = 3
    var hasPainOrInjury = false
    var hasHeartOrLungCondition = false
    /// Valgt startpunkt i forløbet (0-baseret uge-indeks). De fleste starter forfra.
    var startWeekIndex = 0

    private let profileRepository: any ProfileRepository
    private let onCompleted: () -> Void

    init(profileRepository: any ProfileRepository, onCompleted: @escaping () -> Void) {
        self.profileRepository = profileRepository
        self.onCompleted = onCompleted
    }

    var health: HealthScreening {
        HealthScreening(
            hasPainOrInjury: hasPainOrInjury,
            hasHeartOrLungCondition: hasHeartOrLungCondition
        )
    }

    /// Ved tegn på helbredsproblemer anbefales en lægesnak først (afsnit 7.1/9).
    var shouldAdviseDoctor: Bool { health.shouldAdviseDoctor }

    func finish() {
        let profile = ProfileDTO(
            hasRunBefore: hasRunBefore,
            defaultWeeklySessions: weeklySessions,
            currentWeekIndex: startWeekIndex,
            role: .runner,
            onboardingComplete: true,
            health: health
        )
        try? profileRepository.save(profile)
        onCompleted()
    }
}
