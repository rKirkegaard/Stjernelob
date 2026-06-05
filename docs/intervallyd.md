Her er specifikationen omskrevet til Swift/SwiftUI:

Lyd-specifikation: Interval-signaler til løbeapp (iOS/Swift)
Generér lydfilerne med AVAudioEngine + AVAudioPlayerNode — ingen eksterne assets nødvendige.

Lydgenerering — lav en SoundGenerator.swift:
swiftimport AVFoundation

class SoundGenerator {

    static func generateTone(
        frequency: Float,
        duration: Float,
        amplitude: Float = 0.85,
        sampleRate: Double = 44100
    ) -> AVAudioPCMBuffer {
        let frameCount = AVAudioFrameCount(sampleRate * Double(duration))
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount

        let data = buffer.floatChannelData![0]
        let attackFrames = Int(sampleRate * 0.005)   // 5ms attack
        let releaseFrames = Int(sampleRate * 0.01)   // 10ms release

        for frame in 0..<Int(frameCount) {
            // Square wave (skærer bedst igennem stof)
            let sample = sinf(2.0 * .pi * frequency * Float(frame) / Float(sampleRate))
            let squareWave: Float = sample >= 0 ? 1.0 : -1.0

            // Envelope
            var env: Float = amplitude
            if frame < attackFrames {
                env = amplitude * Float(frame) / Float(attackFrames)
            } else if frame > Int(frameCount) - releaseFrames {
                env = amplitude * Float(Int(frameCount) - frame) / Float(releaseFrames)
            }

            data[frame] = squareWave * env
        }
        return buffer
    }
}

IntervalSoundPlayer.swift — samler start og slut:
swiftimport AVFoundation
import UIKit  // til vibration

class IntervalSoundPlayer {

    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()

    init() {
        engine.attach(playerNode)
        engine.connect(playerNode, to: engine.mainMixerNode, format: nil)
        try? engine.start()
        configureAudioSession()
    }

    // Virker med skærm slukket og telefon i bæltetaske
    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(
            .playback,
            mode: .default,
            options: [.mixWithOthers]  // afbryder ikke musik/podcast
        )
        try? session.setActive(true)
    }

    // "Power-up" — 3 stigende toner: C5 → E5 → G5
    func playIntervalStart() {
        let tones: [(freq: Float, dur: Float, pause: Float)] = [
            (523.25, 0.08, 0.06),   // C5
            (659.25, 0.08, 0.06),   // E5
            (783.99, 0.08, 0.0)     // G5
        ]
        playSequence(tones)

        // 3 korte vibrationer
        DispatchQueue.main.async {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            }
        }
    }

    // "Mønt samlet" — 2 faldende toner: G5 → C5, blød release
    func playIntervalSlut() {
        let tones: [(freq: Float, dur: Float, pause: Float)] = [
            (783.99, 0.18, 0.08),   // G5
            (523.25, 0.18, 0.0)     // C5 — blød landing
        ]
        playSequence(tones, releaseMs: 40)

        // 1 lang vibration
        DispatchQueue.main.async {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }

    private func playSequence(
        _ tones: [(freq: Float, dur: Float, pause: Float)],
        releaseMs: Int = 10
    ) {
        playerNode.stop()
        var delay: Double = 0

        for tone in tones {
            let buffer = SoundGenerator.generateTone(
                frequency: tone.freq,
                duration: tone.dur
            )
            let scheduleTime = AVAudioTime(
                hostTime: mach_absolute_time() + UInt64(delay * 1_000_000_000)
            )
            playerNode.scheduleBuffer(buffer, at: scheduleTime)
            delay += Double(tone.dur) + Double(tone.pause)
        }
        playerNode.play()
    }
}

Brug i SwiftUI view:
swiftstruct IntervalView: View {
    let soundPlayer = IntervalSoundPlayer()

    var body: some View {
        VStack {
            Button("Start interval") {
                soundPlayer.playIntervalStart()
            }
            Button("Slut interval") {
                soundPlayer.playIntervalSlut()
            }
        }
    }
}

Info.plist — påkrævet for baggrundslyd:
xml<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
</array>

Vigtige noter til Claude Code:

AVAudioSession.Category.playback er ikke valgfrit — .ambient stopper når skærmen låser
UIBackgroundModes: audio i Info.plist skal sættes manuelt, Xcode gør det ikke automatisk
AudioServicesPlaySystemSound til vibration kræver import AudioToolbox
Test udelukkende på fysisk iPhone — simulator har hverken korrekt lydniveau eller vibration
Soundgeneratoren laver lydene runtime, ingen .wav-filer skal medfølge i app-bundlen