import Foundation
import AVFoundation

/// Pladsholder-stemmecoach baseret på syntetisk tale (`AVSpeechSynthesizer`).
/// Erstattes/suppleres senere af indtalt voiceover (afsnit 15) bag samme
/// protokol, uden ændringer i den øvrige kode.
@MainActor
final class SpeechVoiceCoach: VoiceCoach {
    private let synthesizer = AVSpeechSynthesizer()

    func say(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "da-DK")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.prefersAssistiveTechnologySettings = false
        synthesizer.speak(utterance)
    }

    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}
