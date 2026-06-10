import StjernelobCore
import SwiftUI

extension Theme.Colors {
    /// Blød baggrunds-gradient til skærme — varm og rolig.
    static var screenGradient: LinearGradient {
        LinearGradient(
            colors: [brand.opacity(0.16), accent.opacity(0.06)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension View {
    /// Standard kort-baggrund: blødt materiale, afrundet, med en fin kant.
    func card(padding: CGFloat = Theme.Spacing.medium) -> some View {
        self
            .padding(padding)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: Theme.Radius.card))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.card)
                    .strokeBorder(Color.primary.opacity(0.06))
            )
    }
}

/// Maskotten, der vokser med niveauet (spec afsnit 5.2). Bruger SF Symbols som
/// pladsholder, indtil en tegnet figur leveres — skiftes ud ét sted.
struct MascotView: View {
    let level: Int
    var size: CGFloat = 64

    @State private var animate = false

    private var symbolName: String {
        switch level {
        case ...2: "figure.walk"
        case 3...4: "figure.walk.motion"
        case 5...6: "figure.run"
        case 7...8: "hare.fill"
        default: "crown.fill"
        }
    }

    private var tint: Color {
        switch level {
        case ...2: Theme.Colors.walking
        case 3...4: Theme.Colors.accent
        case 5...6: Theme.Colors.running
        case 7...8: Theme.Colors.brand
        default: Theme.Colors.star
        }
    }

    var body: some View {
        Image(systemName: symbolName)
            .font(.system(size: size, weight: .semibold))
            .foregroundStyle(tint.gradient)
            .symbolEffect(.bounce, options: .nonRepeating, value: animate)
            .padding(size * 0.35)
            .background(tint.opacity(0.15), in: Circle())
            .onAppear { animate.toggle() }
            .accessibilityHidden(true)
    }
}
