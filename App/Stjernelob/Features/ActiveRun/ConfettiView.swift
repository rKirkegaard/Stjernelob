import SwiftUI

/// Let konfetti-fejring ved målgang (spec afsnit 4.4). Rent visuelt og
/// dekorativt — skjult for VoiceOver. Respekterer "reducér bevægelse".
struct ConfettiView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animate = false

    private let pieces: [ConfettiPiece] = (0..<60).map { _ in ConfettiPiece() }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(pieces) { piece in
                    Circle()
                        .fill(piece.color)
                        .frame(width: piece.size, height: piece.size)
                        .position(
                            x: piece.startX * geo.size.width,
                            y: animate ? geo.size.height + 40 : -40
                        )
                        .opacity(animate ? 0 : 1)
                        .animation(
                            reduceMotion ? nil :
                                .easeIn(duration: piece.duration).delay(piece.delay),
                            value: animate
                        )
                }
            }
            .onAppear { animate = true }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

private struct ConfettiPiece: Identifiable {
    let id = UUID()
    let startX = Double.random(in: 0...1)
    let size = Double.random(in: 6...12)
    let duration = Double.random(in: 1.4...2.6)
    let delay = Double.random(in: 0...0.5)
    let color: Color = [
        Theme.Colors.brand, Theme.Colors.accent, Theme.Colors.star,
        Theme.Colors.running, Theme.Colors.restful,
    ].randomElement() ?? Theme.Colors.star
}
