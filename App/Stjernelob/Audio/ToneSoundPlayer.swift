import AVFoundation

/// Afspiller signallyde som runtime-genererede toner via `AVAudioEngine`
/// (jf. docs/intervallyd.md). Sekvenserne er korte melodier — interval-skiftet
/// gentages, så det er nemt at høre med telefonen i en løbetaske. Lyden mixer
/// med (eller dukker) musik, så den virker oven på en playliste/podcast.
@MainActor
final class ToneSoundPlayer: SoundPlayer {
    /// Én tone i en sekvens: frekvens, varighed, pause efter, og styrke.
    private struct Note {
        let frequency: Float
        let duration: Float
        let gap: Float
        let amplitude: Float

        init(_ frequency: Float, duration: Float, gap: Float = 0.05, amplitude: Float = 0.85) {
            self.frequency = frequency
            self.duration = duration
            self.gap = gap
            self.amplitude = amplitude
        }
    }

    // Toner (Hz) i den lille skala vi bygger signalerne af.
    private enum Pitch {
        static let c5: Float = 523.25
        static let e5: Float = 659.25
        static let g5: Float = 783.99
        static let a5: Float = 880.00
        static let c6: Float = 1046.50
        static let e6: Float = 1318.51
        static let a6: Float = 1760.00
    }

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private var isReady = false

    init() {
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: nil)
    }

    // MARK: - Lydsession

    func activateSession(duckMusic: Bool) {
        let session = AVAudioSession.sharedInstance()
        // .playback (ikke .ambient) sikrer lyd, selv når skærmen er låst.
        let options: AVAudioSession.CategoryOptions = duckMusic ? [.duckOthers] : [.mixWithOthers]
        try? session.setCategory(.playback, mode: .default, options: options)
        try? session.setActive(true)
        startEngineIfNeeded()
    }

    func deactivateSession() {
        player.stop()
        engine.stop()
        isReady = false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func startEngineIfNeeded() {
        guard !isReady else { return }
        try? engine.start()
        isReady = engine.isRunning
    }

    // MARK: - Afspilning

    func play(_ cue: SoundCue) {
        startEngineIfNeeded()
        guard isReady else { return }
        playSequence(notes(for: cue))
    }

    private func playSequence(_ notes: [Note]) {
        guard !notes.isEmpty else { return }
        player.stop()
        var sampleTime: AVAudioFramePosition = 0
        for note in notes {
            if let buffer = SoundGenerator.tone(
                frequency: note.frequency, duration: note.duration, amplitude: note.amplitude
            ) {
                let when = AVAudioTime(sampleTime: sampleTime, atRate: SoundGenerator.sampleRate)
                player.scheduleBuffer(buffer, at: when, options: [], completionHandler: nil)
            }
            sampleTime += AVAudioFramePosition(SoundGenerator.sampleRate * Double(note.duration + note.gap))
        }
        player.play()
    }

    // MARK: - Lydmønstre

    private func notes(for cue: SoundCue) -> [Note] {
        switch cue {
        case let .intervalSignal(signal):
            // Gentag motivet to gange, så skiftet høres i en løbetaske.
            let motif = motif(for: signal)
            return motif + [Note(0, duration: 0, gap: 0.18)] + motif
        case .countdownTick:
            return [Note(Pitch.a5, duration: 0.05, gap: 0)]
        case .star:
            return [Note(Pitch.e5, duration: 0.07), Note(Pitch.a5, duration: 0.1, gap: 0)]
        case .halfway:
            return [Note(Pitch.c5, duration: 0.1), Note(Pitch.e5, duration: 0.12, gap: 0)]
        case .fanfare:
            return [
                Note(Pitch.c5, duration: 0.1), Note(Pitch.e5, duration: 0.1),
                Note(Pitch.g5, duration: 0.1), Note(Pitch.c6, duration: 0.26, gap: 0)
            ]
        }
    }

    /// Hver valgbar signallyd som et lille, genkendeligt motiv.
    private func motif(for signal: SignalSound) -> [Note] {
        switch signal {
        case .energetic:
            // Stigende "power-up": C5 → E5 → G5.
            return [Note(Pitch.c5, duration: 0.08), Note(Pitch.e5, duration: 0.08), Note(Pitch.g5, duration: 0.08, gap: 0)]
        case .soft:
            // Faldende, blød "landing": G5 → C5.
            return [Note(Pitch.g5, duration: 0.16, amplitude: 0.6), Note(Pitch.c5, duration: 0.18, gap: 0, amplitude: 0.6)]
        case .bell:
            return [Note(Pitch.e6, duration: 0.45, gap: 0, amplitude: 0.7)]
        case .chime:
            return [Note(Pitch.g5, duration: 0.12), Note(Pitch.c6, duration: 0.18, gap: 0)]
        case .whistle:
            return [Note(Pitch.a6, duration: 0.09), Note(Pitch.a6, duration: 0.12, gap: 0)]
        case .marimba:
            return [Note(Pitch.c5, duration: 0.1, amplitude: 0.7), Note(Pitch.g5, duration: 0.12, gap: 0, amplitude: 0.7)]
        }
    }
}
