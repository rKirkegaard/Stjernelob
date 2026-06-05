import AVFoundation

/// Genererer korte toner i hukommelsen (ingen lydfiler i app-bundlen, jf.
/// docs/intervallyd.md). En firkantbølge skærer bedst igennem stof, så signalet
/// kan høres, selv når telefonen ligger i en løbetaske eller et armbånd.
enum SoundGenerator {
    static let sampleRate: Double = 44_100

    /// Lav en enkelt tone som en PCM-buffer. Returnerer `nil`, hvis lydformatet
    /// ikke kan oprettes (i stedet for at `force unwrap`'e).
    static func tone(frequency: Float, duration: Float, amplitude: Float = 0.85) -> AVAudioPCMBuffer? {
        guard duration > 0, frequency > 0,
              let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)
        else { return nil }

        let frameCount = AVAudioFrameCount(sampleRate * Double(duration))
        guard frameCount > 0,
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount),
              let channel = buffer.floatChannelData
        else { return nil }

        buffer.frameLength = frameCount
        let samples = channel[0]
        let total = Int(frameCount)
        // Bløde ind-/udtoninger fjerner "klik" i start og slut af tonen.
        let attack = max(1, Int(sampleRate * 0.005))   // 5 ms
        let release = max(1, Int(sampleRate * 0.012))  // 12 ms

        for frame in 0..<total {
            let sine = sinf(2 * .pi * frequency * Float(frame) / Float(sampleRate))
            let square: Float = sine >= 0 ? 1 : -1
            var envelope = amplitude
            if frame < attack {
                envelope = amplitude * Float(frame) / Float(attack)
            } else if frame > total - release {
                envelope = amplitude * Float(total - frame) / Float(release)
            }
            samples[frame] = square * envelope
        }
        return buffer
    }
}
