import Foundation
import AVFoundation
import AudioToolbox

/// Pladsholder-lydafspiller. Bruger systemlyde og konfigurerer lydsessionen til
/// at "dukke" (sænke) musik, mens signaler spilles, så appen virker oven på
/// musik (afsnit 4.2/10). Designede lyd-assets indsættes senere bag samme protokol.
@MainActor
final class SystemSoundPlayer: SoundPlayer {
    /// Konfigurér lydsessionen, så signaler kan høres henover musik.
    func activateSession(duckMusic: Bool) {
        let session = AVAudioSession.sharedInstance()
        let options: AVAudioSession.CategoryOptions = duckMusic
            ? [.duckOthers]
            : [.mixWithOthers]
        try? session.setCategory(.playback, mode: .spokenAudio, options: options)
        try? session.setActive(true)
    }

    func deactivateSession() {
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    func play(_ cue: SoundCue) {
        AudioServicesPlaySystemSound(systemSoundID(for: cue))
    }

    /// Pladsholder-tildeling af systemlyde til hvert signal.
    private func systemSoundID(for cue: SoundCue) -> SystemSoundID {
        switch cue {
        case .runStart: return 1113      // begin record (energisk)
        case .walkStart: return 1114     // end record (blødere)
        case .countdownTick: return 1103 // tink
        case .star: return 1057          // tink/positiv
        case .halfway: return 1109
        case .fanfare: return 1025       // fanfare-agtig
        }
    }
}
