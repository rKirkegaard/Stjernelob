import SwiftUI

/// Indstillinger (spec afsnit 7.9): lyd/stemme/haptik hver for sig, påmindelser,
/// streak-fryser og privatliv/data. De mest beskyttende valg er standard.
struct SettingsView: View {
    @Bindable var settings: SettingsStore
    var onErase: () -> Void = {}

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
}
