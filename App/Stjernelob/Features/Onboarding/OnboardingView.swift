import SwiftUI

/// Onboarding-flow som en venlig, overskuelig formular. Tonen er varm og
/// uden pres; helbredsspørgsmål bruges kun til at anbefale en lægesnak.
struct OnboardingView: View {
    @State var viewModel: OnboardingViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(Strings.Onboarding.welcomeBody)
                        .font(.body)
                }

                Section {
                    Label {
                        Text(Strings.Onboarding.methodBody)
                    } icon: {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .foregroundStyle(Theme.Colors.accent)
                    }
                } header: {
                    Text(Strings.Onboarding.methodTitle)
                }

                Section {
                    Picker(selection: $viewModel.hasRunBefore) {
                        Text(Strings.Onboarding.experienceNew).tag(false)
                        Text(Strings.Onboarding.experienceSome).tag(true)
                    } label: {
                        Text(Strings.Onboarding.experienceTitle)
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text(Strings.Onboarding.experienceTitle)
                }

                Section {
                    Stepper(value: $viewModel.weeklySessions, in: 1...5) {
                        Text(Strings.Planner.sessionsValue(viewModel.weeklySessions))
                    }
                } header: {
                    Text(Strings.Onboarding.sessionsTitle)
                } footer: {
                    Text(Strings.Onboarding.sessionsBody)
                }

                Section {
                    Toggle(isOn: $viewModel.hasPainOrInjury) {
                        Text(Strings.Onboarding.healthPain)
                    }
                    Toggle(isOn: $viewModel.hasHeartOrLungCondition) {
                        Text(Strings.Onboarding.healthHeart)
                    }
                    if viewModel.shouldAdviseDoctor {
                        Label {
                            Text(Strings.Onboarding.doctorAdvice)
                        } icon: {
                            Image(systemName: "stethoscope")
                        }
                        .foregroundStyle(Theme.Colors.restful)
                    }
                } header: {
                    Text(Strings.Onboarding.healthTitle)
                }

                Section {
                    Button {
                        viewModel.finish()
                    } label: {
                        Text(Strings.Common.start)
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("onboarding.start")
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle(Text(Strings.Onboarding.welcomeTitle))
        }
    }
}

#Preview {
    OnboardingView(viewModel: OnboardingViewModel(
        profileRepository: AppEnvironment.preview.profileRepository,
        onCompleted: {}
    ))
}
