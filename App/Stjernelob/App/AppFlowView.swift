import SwiftUI

/// Beslutter den øverste rute: onboarding, indtil profilen er sat op — derefter
/// hovedoplevelsen. Holder ingen forretningslogik ud over dette valg.
struct AppFlowView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var onboardingComplete: Bool?

    var body: some View {
        Group {
            switch onboardingComplete {
            case .some(true):
                MainTabView()
            case .some(false):
                OnboardingView(viewModel: OnboardingViewModel(
                    profileRepository: environment.profileRepository,
                    onCompleted: { onboardingComplete = true }
                ))
            case nil:
                ProgressView()
            }
        }
        .onAppear {
            let profile = try? environment.profileRepository.load()
            onboardingComplete = profile?.onboardingComplete ?? false
        }
    }
}
