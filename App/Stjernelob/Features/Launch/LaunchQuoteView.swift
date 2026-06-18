import SwiftUI

/// Kort opstartsskærm med en legende, opmuntrende replik (jf. docs/qutoes.md).
/// Sætter en varm tone fra det øjeblik appen åbnes — uden pres.
struct LaunchQuoteView: View {
    /// Om appen er klar bag forsiden (profil indlæst). Først da er GO aktiv.
    var isReady: Bool = true
    /// Kaldes når brugeren trykker GO og vil videre ind i appen.
    var onGo: () -> Void = {}

    @State private var quote = LoadingQuotes.random()
    @State private var appeared = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.Colors.brand, Theme.Colors.accent],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: Theme.Spacing.large) {
                Spacer()

                Image(systemName: "sparkles")
                    .font(.system(size: 72, weight: .semibold))
                    .foregroundStyle(.white)
                    .scaleEffect(appeared ? 1 : 0.6)
                    .opacity(appeared ? 1 : 0)
                    .accessibilityHidden(true)
                Text(LocalizedStringResource("app.name", defaultValue: "Stjerneløb"))
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.white)

                Spacer()

                Text(quote)
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .padding(.horizontal, Theme.Spacing.large)
                    .opacity(appeared ? 1 : 0)

                Spacer()

                if isReady {
                    Button(action: onGo) {
                        Text(Strings.Launch.go)
                            .font(.title2.weight(.bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Theme.Spacing.medium)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.white)
                    .foregroundStyle(Theme.Colors.brand)
                    .padding(.horizontal, Theme.Spacing.xLarge)
                    .padding(.bottom, Theme.Spacing.large)
                    .accessibilityLabel(Text(Strings.Launch.go))
                    .accessibilityHint(Text(Strings.Launch.tagline))
                } else {
                    ProgressView()
                        .tint(.white)
                        .padding(.bottom, Theme.Spacing.large)
                }
            }
            .padding(Theme.Spacing.large)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { appeared = true }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(quote))
    }
}

#Preview {
    LaunchQuoteView()
}
