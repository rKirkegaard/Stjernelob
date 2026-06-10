import StjernelobCore
import XCTest
@testable import Stjernelob

/// Tests for at intervalskift oversættes til den lyd, brugeren har valgt — så
/// "begynd at løbe" og "begynd at gå" kan høres som forskellige signaler.
@MainActor
final class WorkoutFeedbackCoordinatorTests: XCTestCase {
    @MainActor private final class FakeVoiceCoach: VoiceCoach {
        func say(_: String) {}
        func stopSpeaking() {}
    }

    @MainActor private final class FakeHapticPlayer: HapticPlayer {
        func play(_: HapticPattern) {}
        func prepare() {}
    }

    @MainActor private final class RecordingSoundPlayer: SoundPlayer {
        private(set) var played: [SoundCue] = []
        func play(_ cue: SoundCue) { played.append(cue) }
    }

    private func makeCoordinator(
        settings: FeedbackSettings,
        sound: RecordingSoundPlayer
    ) -> WorkoutFeedbackCoordinator {
        WorkoutFeedbackCoordinator(
            settings: settings,
            voice: FakeVoiceCoach(),
            sound: sound,
            haptics: FakeHapticPlayer()
        )
    }

    func testRunIntervalPlaysChosenRunSound() {
        let sound = RecordingSoundPlayer()
        let settings = FeedbackSettings(runStartSound: .whistle, walkStartSound: .marimba)
        let coordinator = makeCoordinator(settings: settings, sound: sound)

        coordinator.handle(.intervalStarted(index: 1, interval: .run(.seconds(60))))

        XCTAssertEqual(sound.played, [.intervalSignal(.whistle)])
    }

    func testWalkIntervalPlaysChosenWalkSound() {
        let sound = RecordingSoundPlayer()
        let settings = FeedbackSettings(runStartSound: .whistle, walkStartSound: .marimba)
        let coordinator = makeCoordinator(settings: settings, sound: sound)

        coordinator.handle(.intervalStarted(index: 2, interval: .walk(.seconds(90))))

        XCTAssertEqual(sound.played, [.intervalSignal(.marimba)])
    }

    func testWarmUpAndCoolDownUseWalkSound() {
        let sound = RecordingSoundPlayer()
        let settings = FeedbackSettings(runStartSound: .energetic, walkStartSound: .bell)
        let coordinator = makeCoordinator(settings: settings, sound: sound)

        coordinator.handle(.intervalStarted(index: 0, interval: .warmUp(.seconds(300))))
        coordinator.handle(.intervalStarted(index: 9, interval: .coolDown(.seconds(300))))

        XCTAssertEqual(sound.played, [.intervalSignal(.bell), .intervalSignal(.bell)])
    }

    func testNoSoundWhenSoundDisabled() {
        let sound = RecordingSoundPlayer()
        let settings = FeedbackSettings(soundEnabled: false, runStartSound: .whistle)
        let coordinator = makeCoordinator(settings: settings, sound: sound)

        coordinator.handle(.intervalStarted(index: 1, interval: .run(.seconds(60))))

        XCTAssertTrue(sound.played.isEmpty)
    }

    /// Ældre gemte indstillinger (uden signallyd-felter) skal afkode til de
    /// blide standardlyde — ikke fejle og nulstille alt.
    func testDecodingLegacySettingsFallsBackToDefaults() throws {
        let legacy = #"{"voiceEnabled":false,"soundEnabled":true,"hapticsEnabled":true,"duckMusic":false}"#
        let data = try XCTUnwrap(legacy.data(using: .utf8))

        let decoded = try JSONDecoder().decode(FeedbackSettings.self, from: data)

        XCTAssertEqual(decoded.voiceEnabled, false)
        XCTAssertEqual(decoded.duckMusic, false)
        XCTAssertEqual(decoded.runStartSound, .energetic)
        XCTAssertEqual(decoded.walkStartSound, .soft)
    }
}
