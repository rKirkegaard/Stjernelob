import Foundation
import StjernelobCore

/// De tre uafhængige feedback-kanaler (spec afsnit 4.2): stemme, lyd og haptik.
/// Hver kan slås til/fra hver for sig, så appen virker fuldt uden lyd (i skole,
/// med musik skruet op) via haptik og visuelle signaler alene.
struct FeedbackSettings: Equatable, Codable {
    var voiceEnabled: Bool = true
    var soundEnabled: Bool = true
    var hapticsEnabled: Bool = true
    /// Sænk anden lyd (musik) mens coachen taler, frem for at stoppe den.
    var duckMusic: Bool = true
    /// Valgt lyd for "begynd at løbe". Løb og gå har hver sin lyd, så skiftet
    /// kan høres uden at kigge på skærmen (afsnit 4.2). Kan ændres i indstillinger.
    var runStartSound: SignalSound = .energetic
    /// Valgt lyd for "begynd at gå".
    var walkStartSound: SignalSound = .soft

    init(
        voiceEnabled: Bool = true,
        soundEnabled: Bool = true,
        hapticsEnabled: Bool = true,
        duckMusic: Bool = true,
        runStartSound: SignalSound = .energetic,
        walkStartSound: SignalSound = .soft
    ) {
        self.voiceEnabled = voiceEnabled
        self.soundEnabled = soundEnabled
        self.hapticsEnabled = hapticsEnabled
        self.duckMusic = duckMusic
        self.runStartSound = runStartSound
        self.walkStartSound = walkStartSound
    }

    /// Tolerant afkodning: felter, der mangler i ældre gemte indstillinger
    /// (fx før signallyde fandtes), falder tilbage til standardværdien i stedet
    /// for at nulstille hele objektet.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        voiceEnabled = try container.decodeIfPresent(Bool.self, forKey: .voiceEnabled) ?? true
        soundEnabled = try container.decodeIfPresent(Bool.self, forKey: .soundEnabled) ?? true
        hapticsEnabled = try container.decodeIfPresent(Bool.self, forKey: .hapticsEnabled) ?? true
        duckMusic = try container.decodeIfPresent(Bool.self, forKey: .duckMusic) ?? true
        runStartSound = try container
            .decodeIfPresent(SignalSound.self, forKey: .runStartSound) ?? .energetic
        walkStartSound = try container
            .decodeIfPresent(SignalSound.self, forKey: .walkStartSound) ?? .soft
    }
}

/// Et lille katalog af valgbare signallyde for interval-skift. Brugeren kan
/// vælge hver sin lyd til "begynd at løbe" og "begynd at gå", så de er nemme at
/// kende fra hinanden uden at se på skærmen. Konkrete lyde er pladsholdere,
/// indtil designede assets leveres (afsnit 15).
enum SignalSound: String, Equatable, Codable, CaseIterable, Identifiable {
    case energetic
    case soft
    case bell
    case chime
    case whistle
    case marimba

    var id: String { rawValue }

    var displayName: LocalizedStringResource {
        switch self {
        case .energetic: Strings.SignalSounds.energetic
        case .soft: Strings.SignalSounds.soft
        case .bell: Strings.SignalSounds.bell
        case .chime: Strings.SignalSounds.chime
        case .whistle: Strings.SignalSounds.whistle
        case .marimba: Strings.SignalSounds.marimba
        }
    }
}

/// Signallyde for skift og milepæle. Konkrete lyde er pladsholdere, indtil
/// designede assets leveres (afsnit 15).
enum SoundCue: Equatable {
    /// Et interval-skift med den valgte signallyd (løb eller gå).
    case intervalSignal(SignalSound)
    case countdownTick
    case star // stjernepop pr. interval (afsnit 4.3)
    case halfway
    case fanfare // målgang (afsnit 4.4)
}

/// Haptiske mønstre. Løb- og gå-skift har bevidst forskellig følelse, så de kan
/// kendes fra hinanden uden lyd (afsnit 4.2).
enum HapticPattern: Equatable {
    case runStart
    case walkStart
    case countdownTick
    case star
    case finish
}

@MainActor
protocol VoiceCoach: AnyObject {
    func say(_ text: String)
    func stopSpeaking()
}

@MainActor
protocol SoundPlayer: AnyObject {
    func play(_ cue: SoundCue)
    /// Aktivér lydsessionen før en tur (mixer med eller dukker musik).
    func activateSession(duckMusic: Bool)
    /// Luk lydsessionen igen, når turen slutter.
    func deactivateSession()
}

/// Standard-no-op, så fx test-attrapper kun behøver `play(_:)`.
extension SoundPlayer {
    func activateSession(duckMusic _: Bool) {}
    func deactivateSession() {}
}

@MainActor
protocol HapticPlayer: AnyObject {
    func play(_ pattern: HapticPattern)
    /// Forbered motoren (kald før en tur for at undgå forsinkelse på første slag).
    func prepare()
}

/// Oversætter coachens replik til ren tekst, der kan tales. Holdt adskilt, så
/// valget af replik kan genbruges og testes uafhængigt af talesyntesen.
enum CoachScript {
    static func line(forStartOf interval: Interval) -> LocalizedStringResource {
        switch interval.kind {
        case .warmUp: Strings.Coaching.warmUpStart
        case .run: Strings.Coaching.runStart(duration: interval.duration.shortText)
        case .walk: Strings.Coaching.walkStart(duration: interval.duration.shortText)
        case .coolDown: Strings.Coaching.coolDownStart
        }
    }
}
