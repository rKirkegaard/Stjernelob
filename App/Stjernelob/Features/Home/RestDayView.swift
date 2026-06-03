import SwiftUI

/// Hviledags-oplevelse (spec afsnit 6.3): en hyggelig, beroligende visning, der
/// signalerer, at det er helt i orden at slappe af. Aldrig skyldfremkaldende.
struct RestDayView: View {
    @State private var breathe = false

    var body: some View {
        VStack(spacing: Theme.Spacing.large) {
            Image(systemName: "moon.zzz.fill")
                .font(.system(size: 72))
                .foregroundStyle(Theme.Colors.restful)
                .scaleEffect(breathe ? 1.08 : 0.96)
                .animation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true), value: breathe)
                .accessibilityHidden(true)

            Text(Strings.RestDay.title)
                .font(.friendlyTitle)

            Text(Strings.RestDay.body)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, Theme.Spacing.large)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.xLarge)
        .onAppear { breathe = true }
    }
}

#Preview {
    RestDayView()
}
