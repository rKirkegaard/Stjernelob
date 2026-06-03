import SwiftUI

/// Indstillinger (spec afsnit 7.9): lyd/stemme/haptik hver for sig, påmindelser,
/// streak-fryser og privatliv/data. De mest beskyttende valg er standard.
struct SettingsView: View {
    @Bindable var settings: SettingsStore
    var onErase: () -> Void = {}

    @Environment(AppEnvironment.self) private var environment
    @State private var showDeleteConfirm = false

    var body: some View {
        Form {
            Section {
                Toggle(isOn: $settings.feedback.voiceEnabled) { Text(Strings.Settings.voice) }
                Toggle(isOn: $settings.feedback.soundEnabled) { Text(Strings.Settings.sound) }
                Toggle(isOn: $settings.feedback.hapticsEnabled) { Text(Strings.Settings.haptics) }
                Toggle(isOn: $settings.feedback.duckMusic) { Text(Strings.Settings.duckMusic) }
                    .disabled(!settings.feedback.soundEnabled)
            } header: {
                Text(Strings.Settings.feedbackSection)
            } footer: {
                Text(Strings.Settings.feedbackNote)
            }

            Section {
                Toggle(isOn: $settings.remindersEnabled) { Text(Strings.Settings.remindersEnabled) }
                if settings.remindersEnabled {
                    Stepper(value: $settings.reminderHour, in: 6...22) {
                        Text(Strings.Settings.reminderTime)
                        Spacer()
                        Text("kl. \(settings.reminderHour)").monospacedDigit().foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text(Strings.Settings.remindersSection)
            } footer: {
                Text(Strings.Settings.remindersNote)
            }

            Section {
                Toggle(isOn: $settings.streakFreezeEnabled) { Text(Strings.Settings.streakFreeze) }
            } header: {
                Text(Strings.Settings.streakSection)
            } footer: {
                Text(Strings.Settings.streakNote)
            }

            Section {
                Toggle(isOn: $settings.shareStreak) { Text(Strings.Sharing.shareStreak) }
                Toggle(isOn: $settings.shareWorkouts) { Text(Strings.Sharing.shareWorkouts) }
                Toggle(isOn: $settings.shareMilestones) { Text(Strings.Sharing.shareMilestones) }
                NavigationLink {
                    ParentDashboardView()
                } label: {
                    Label { Text(Strings.Sharing.seeWhatParentSees) } icon: { Image(systemName: "eye") }
                }
            } header: {
                Text(Strings.Sharing.section)
            } footer: {
                Text(Strings.Sharing.note)
            }

            Section {
                NavigationLink {
                    SafetyView(settings: settings)
                } label: {
                    Label { Text(Strings.Safety.openInSettings) } icon: { Image(systemName: "shield.lefthalf.filled") }
                }
            }

            Section {
                Toggle(isOn: $settings.healthKitEnabled) { Text(Strings.Settings.healthKit) }
                    .disabled(!environment.healthKit.isAvailable)
            } header: {
                Text(Strings.Settings.healthSection)
            } footer: {
                Text(Strings.Settings.healthNote)
            }

            Section {
                Button(role: .destructive) {
                    showDeleteConfirm = true
                } label: {
                    Text(Strings.Settings.deleteData)
                }
            } header: {
                Text(Strings.Settings.privacySection)
            } footer: {
                Text(Strings.Settings.privacyNote)
            }
        }
        .navigationTitle(Text(Strings.Settings.title))
        .onChange(of: settings.remindersEnabled) { _, _ in Task { await reschedule() } }
        .onChange(of: settings.reminderHour) { _, _ in Task { await reschedule() } }
        .onChange(of: settings.healthKitEnabled) { _, isOn in
            if isOn { Task { _ = await environment.healthKit.requestAuthorization() } }
        }
        .confirmationDialog(
            Text(Strings.Settings.deleteConfirmTitle),
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button(role: .destructive) { onErase() } label: { Text(Strings.Settings.deleteData) }
            Button(role: .cancel) { } label: { Text(Strings.Settings.cancel) }
        } message: {
            Text(Strings.Settings.deleteConfirmBody)
        }
    }

    private func reschedule() async {
        let sessions = (try? environment.profileRepository.load())?.defaultWeeklySessions ?? 3
        await environment.notificationScheduler.reschedule(
            enabled: settings.remindersEnabled,
            hour: settings.reminderHour,
            mondayBasedDays: WeekScheduler.trainingDays(sessionsPerWeek: sessions)
        )
    }
}
