import Foundation
import StjernelobCore

/// Oversætter intervalmotorens `WorkoutEvent` til feedback på de tre kanaler
/// (stemme, lyd, haptik), hver gated af brugerens indstillinger. Holder al
/// "hvad skal høres/mærkes hvornår"-logik ét sted, adskilt fra motoren (som
/// kun kender tid) og fra de konkrete afspillere.
@MainActor
final class WorkoutFeedbackCoordinator {
    var settings: FeedbackSettings

    private let voice: any VoiceCoach
    private let sound: any SoundPlayer
    private let haptics: any HapticPlayer

    init(
        settings: FeedbackSettings = FeedbackSettings(),
        voice: any VoiceCoach,
        sound: any SoundPlayer,
        haptics: any HapticPlayer
    ) {
        self.settings = settings
        self.voice = voice
        self.sound = sound
        self.haptics = haptics
    }

    /// Kald før en tur: gør haptik-motoren klar og aktivér lydsessionen.
    func begin() {
        if settings.hapticsEnabled { haptics.prepare() }
        if settings.soundEnabled, let system = sound as? SystemSoundPlayer {
            system.activateSession(duckMusic: settings.duckMusic)
        }
    }

    /// Kald når turen slutter/afbrydes.
    func end() {
        voice.stopSpeaking()
        if let system = sound as? SystemSoundPlayer {
            system.deactivateSession()
        }
    }

    func handle(_ event: WorkoutEvent) {
        switch event {
        case .started:
            break // det første intervalStarted følger straks efter

        case let .intervalStarted(_, interval):
            speak(CoachScript.line(forStartOf: interval))
            let isRun = interval.kind.isRunning
            playSound(isRun ? .runStart : .walkStart)
            playHaptic(isRun ? .runStart : .walkStart)

        case .countdown:
            playSound(.countdownTick)
            playHaptic(.countdownTick)

        case .intervalCompleted:
            // "ding" + stjernepop (afsnit 4.3)
            playSound(.star)
            playHaptic(.star)

        case .halfway:
            speak(Strings.Coaching.halfway)
            playSound(.halfway)

        case .finished:
            speak(Strings.Coaching.finished)
            playSound(.fanfare)
            playHaptic(.finish)
        }
    }

    // MARK: - Kanaler (gated af indstillinger)

    private func speak(_ text: LocalizedStringResource) {
        guard settings.voiceEnabled else { return }
        voice.say(String(localized: text))
    }

    private func playSound(_ cue: SoundCue) {
        guard settings.soundEnabled else { return }
        sound.play(cue)
    }

    private func playHaptic(_ pattern: HapticPattern) {
        guard settings.hapticsEnabled else { return }
        haptics.play(pattern)
    }
}
