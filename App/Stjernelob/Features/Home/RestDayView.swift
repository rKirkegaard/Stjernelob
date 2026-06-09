/// Et blidt forslag til let bevægelse på en hviledag (aktiv restitution).
private struct RecoveryIdea: Identifiable {
    let id = UUID()
    let symbol: String
    let text: LocalizedStringResource
}

/// Hviledags-oplevelse (spec afsnit 6.3): en hyggelig, beroligende visning, der
/// signalerer, at det er helt i orden at slappe af. Aldrig skyldfremkaldende.
/// Tilbyder også et par blide forslag til aktiv restitution — helt frivilligt.
struct RestDayView: View {
    @State private var breathe = false

    private let ideas: [RecoveryIdea] = [
        RecoveryIdea(symbol: "figure.walk", text: Strings.RestDay.recoveryWalk),
        RecoveryIdea(symbol: "figure.flexibility", text: Strings.RestDay.recoveryStretch),
        RecoveryIdea(symbol: "figure.pool.swim", text: Strings.RestDay.recoverySwim),
        RecoveryIdea(symbol: "figure.dance", text: Strings.RestDay.recoveryDance),
        RecoveryIdea(symbol: "figure.outdoor.cycle", text: Strings.RestDay.recoveryBike),
        RecoveryIdea(symbol: "figure.play", text: Strings.RestDay.recoveryPlay),
    ]

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

            recoveryCard
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.xLarge)
        .onAppear { breathe = true }
    }

    private var recoveryCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            Text(Strings.RestDay.activeRecoveryTitle)
                .font(.headline)
            // Vis tre forslag — varieret, men stabilt på dagen (efter ugedag).
            ForEach(suggestionsForToday) { idea in
                Label {
                    Text(idea.text)
                } icon: {
                    Image(systemName: idea.symbol).foregroundStyle(Theme.Colors.accent)
                }
            }
            Text(Strings.RestDay.activeRecoveryNote)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.top, Theme.Spacing.small)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Spacing.medium)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: Theme.Radius.card))
        .padding(.horizontal, Theme.Spacing.large)
    }

    /// Tre forslag, der varierer dag for dag (men er stabile inden for samme dag,
    /// så visningen ikke "hopper").
    private var suggestionsForToday: [RecoveryIdea] {
        let day = Calendar.current.ordinality(of: .day, in: .era, for: Date()) ?? 0
        let start = day % ideas.count
        return (0..<3).map { ideas[(start + $0) % ideas.count] }
    }
}

#Preview {
    RestDayView()
}
