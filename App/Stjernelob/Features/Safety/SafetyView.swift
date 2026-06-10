import SwiftUI

/// Personlig sikkerhed under løb (spec afsnit 12). Alt er opt-in og altid
/// synligt for barnet: positionsdeling kun under turen, afsted/hjemme-beskeder,
/// og en SOS-knap. Trygheds-råd er blide, aldrig skræmmende.
struct SafetyView: View {
    @Bindable var settings: SettingsStore
    @Environment(AppEnvironment.self) private var environment
    @Environment(\.openURL) private var openURL

    var body: some View {
        Form {
            Section {
                Toggle(isOn: $settings.livePositionEnabled) { Text(Strings.Safety.livePosition) }
                Toggle(isOn: $settings.awayHomeEnabled) { Text(Strings.Safety.awayHome) }
            } footer: {
                Text(Strings.Safety.livePositionNote)
            }

            Section {
                TextField(text: $settings.emergencyContactName) { Text(Strings.Safety.contactName) }
                TextField(text: $settings.emergencyContactPhone) {
                    Text(Strings.Safety.contactPhone)
                }
                .keyboardType(.phonePad)
            }

            Section {
                Button(role: .destructive) {
                    callForHelp()
                } label: {
                    Label { Text(Strings.Safety.sos) } icon: { Image(systemName: "sos") }
                        .frame(maxWidth: .infinity)
                        .fontWeight(.bold)
                }
            } footer: {
                Text(Strings.Safety.sosNote)
            }

            Section {
                Text(Strings.Safety.tips)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(Text(Strings.Safety.title))
        .onChange(of: settings.livePositionEnabled) { _, isOn in
            if isOn { environment.locationService.requestWhenInUseAuthorization() }
        }
    }

    private func callForHelp() {
        let digits = settings.emergencyContactPhone.filter { $0.isNumber || $0 == "+" }
        let number = digits.isEmpty ? "112" : digits
        if let url = URL(string: "tel://\(number)") {
            openURL(url)
        }
    }
}
