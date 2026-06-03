import Foundation
import CoreHaptics

/// Haptik via Core Haptics. Løb- og gå-skift har forskellig "følelse", så de kan
/// kendes fra hinanden uden lyd (afsnit 4.2). Falder pænt tilbage til ingenting
/// på enheder uden haptik (fx simulator), så resten af appen er upåvirket.
@MainActor
final class CoreHapticsPlayer: HapticPlayer {
    private var engine: CHHapticEngine?
    private var isSupported: Bool { CHHapticEngine.capabilitiesForHardware().supportsHaptics }

    func prepare() {
        guard isSupported, engine == nil else {
            try? engine?.start()
            return
        }
        engine = try? CHHapticEngine()
        engine?.isAutoShutdownEnabled = true
        try? engine?.start()
    }

    func play(_ pattern: HapticPattern) {
        guard isSupported else { return }
        if engine == nil { prepare() }
        guard let engine else { return }
        do {
            let chPattern = try makePattern(pattern)
            let player = try engine.makePlayer(with: chPattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            // Haptik er aldrig kritisk — fejl ignoreres, så turen kører videre.
        }
    }

    private func makePattern(_ pattern: HapticPattern) throws -> CHHapticPattern {
        func event(intensity: Float, sharpness: Float, at relativeTime: TimeInterval) -> CHHapticEvent {
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness),
                ],
                relativeTime: relativeTime
            )
        }

        let events: [CHHapticEvent]
        switch pattern {
        case .runStart:
            // To skarpe slag — "klar, nu!"
            events = [event(intensity: 1.0, sharpness: 0.9, at: 0),
                      event(intensity: 1.0, sharpness: 0.9, at: 0.12)]
        case .walkStart:
            // Ét blødt slag — ro.
            events = [event(intensity: 0.6, sharpness: 0.3, at: 0)]
        case .countdownTick:
            events = [event(intensity: 0.5, sharpness: 0.7, at: 0)]
        case .star:
            events = [event(intensity: 0.7, sharpness: 0.6, at: 0)]
        case .finish:
            // Fejrende lille serie.
            events = [event(intensity: 1.0, sharpness: 0.5, at: 0),
                      event(intensity: 0.8, sharpness: 0.5, at: 0.1),
                      event(intensity: 1.0, sharpness: 0.7, at: 0.2)]
        }
        return try CHHapticPattern(events: events, parameters: [])
    }
}
