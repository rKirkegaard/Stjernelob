import Foundation
import StjernelobCore

/// De tre uafhængige feedback-kanaler (spec afsnit 4.2): stemme, lyd og haptik.
/// Hver kan slås til/fra hver for sig, så appen virker fuldt uden lyd (i skole,
/// med musik skruet op) via haptik og visuelle signaler alene.
struct FeedbackSettings: Sendable, Equatable, Codable {
    var voiceEnabled: Bool = true
    var soundEnabled: Bool = true
    var hapticsEnabled: Bool = true
    /// Sænk anden lyd (musik) mens coachen taler, frem for at stoppe den.
    var duckMusic: Bool = true
}

/// Signallyde for skift og milepæle. Konkrete lyde er pladsholdere, indtil
/// designede assets leveres (afsnit 15).
enum SoundCue: Sendable, Equatable {
    case runStart
    case walkStart
    case countdownTick
    case star          // stjernepop pr. interval (afsnit 4.3)
    case halfway
    case fanfare       // målgang (afsnit 4.4)
}

/// Haptiske mønstre. Løb- og gå-skift har bevidst forskellig følelse, så de kan
/// kendes fra hinanden uden lyd (afsnit 4.2).
enum HapticPattern: Sendable, Equatable {
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
        case .warmUp: return Strings.Coaching.warmUpStart
        case .run: return Strings.Coaching.runStart(duration: interval.duration.shortText)
        case .walk: return Strings.Coaching.walkStart(duration: interval.duration.shortText)
        case .coolDown: return Strings.Coaching.coolDownStart
        }
    }
}
