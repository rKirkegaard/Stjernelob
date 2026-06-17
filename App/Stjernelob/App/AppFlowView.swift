import SwiftUI

/// Beslutter den øverste rute: onboarding, indtil profilen er sat op — derefter
/// hovedoplevelsen. Holder ingen forretningslogik ud over dette valg.
struct AppFlowView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var onboardingComplete: Bool?
    @State private var launching = true

    var body: some View {
        ZStack {
            content
            if launching {
                LaunchQuoteView(
                    isReady: onboardingComplete != nil,
                    onGo: { withAnimation(.easeOut(duration: 0.45)) { launching = false } }
                )
                .transition(.opacity)
            }
        }
        .task {
            // Forsiden bliver stående, indtil brugeren selv trykker GO.
            let profile = try? environment.profileRepository.load()
            onboardingComplete = profile?.onboardingComplete ?? false
        }
    }

    @ViewBuilder
    private var content: some View {
        switch onboardingComplete {
        case .some(true):
            MainTabView()
        case .some(false):
            OnboardingView(viewModel: OnboardingViewModel(
                profileRepository: environment.profileRepository,
                onCompleted: { onboardingComplete = true }
            ))
        case nil:
            Color(.systemBackground).ignoresSafeArea()
        }
    }
}
