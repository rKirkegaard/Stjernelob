import SwiftUI

/// Kort opstartsskærm med en legende, opmuntrende replik (jf. docs/qutoes.md).
/// Sætter en varm tone fra det øjeblik appen åbnes — uden pres.
struct LaunchQuoteView: View {
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

                Text("🌟")
                    .font(.system(size: 72))
                    .scaleEffect(appeared ? 1 : 0.6)
                    .opacity(appeared ? 1 : 0)
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

                ProgressView()
                    .tint(.white)
                    .padding(.top, Theme.Spacing.small)

                Spacer()
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
