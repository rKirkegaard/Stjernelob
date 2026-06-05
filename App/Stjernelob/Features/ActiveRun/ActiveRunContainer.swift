import SwiftUI

/// Bygger en tur op med dens afhængigheder (intervalmotor + feedback-kanaler)
/// og viser under-tur-skærmen. Holdt adskilt, så afhængighederne kan injiceres
/// og udskiftes (fx pladsholder-lyd nu, rigtige assets senere).
struct ActiveRunContainer: View {
    let request: RunRequest
    var onClose: () -> Void

    @Environment(AppEnvironment.self) private var environment
    @State private var viewModel: ActiveRunViewModel?

    var body: some View {
        Group {
            if let viewModel {
                ActiveRunView(viewModel: viewModel, onClose: onClose)
            } else {
                ProgressView()
                    .onAppear(perform: build)
            }
        }
    }

    private func build() {
        let feedback = WorkoutFeedbackCoordinator(
            settings: environment.settings.feedback,
            voice: SpeechVoiceCoach(),
            sound: ToneSoundPlayer(),
            haptics: CoreHapticsPlayer()
        )
        viewModel = ActiveRunViewModel(
            plan: request.plan,
            programWeekId: request.programWeekId,
            programPhase: request.programPhase,
            environment: environment,
            feedback: feedback,
            resumeElapsed: request.resumeElapsed
        )
    }
}
