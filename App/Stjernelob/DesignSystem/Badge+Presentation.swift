import SwiftUI
import StjernelobCore

/// Præsentation af badges: lokaliseret navn, beskrivelse og SF Symbol.
/// Tonen fejrer fremmøde og små sejre (spec afsnit 5.4).
extension Badge {
    var displayTitle: LocalizedStringResource {
        switch self {
        case .firstWorkout: return LocalizedStringResource("badge.firstWorkout.title", defaultValue: "Første tur")
        case .tenWorkouts: return LocalizedStringResource("badge.tenWorkouts.title", defaultValue: "Ti ture")
        case .threeWeekStreak: return LocalizedStringResource("badge.threeWeekStreak.title", defaultValue: "Tre ugers stime")
        case .firstFiveMinuteRun: return LocalizedStringResource("badge.firstFiveMinuteRun.title", defaultValue: "Fem minutter i træk")
        case .earlyBird: return LocalizedStringResource("badge.earlyBird.title", defaultValue: "Morgenfugl")
        case .rainHero: return LocalizedStringResource("badge.rainHero.title", defaultValue: "Regnvejrshelt")
        case .completedBaseProgram: return LocalizedStringResource("badge.completedBaseProgram.title", defaultValue: "Grundforløbet gennemført")
        }
    }

    var displayDetail: LocalizedStringResource {
        switch self {
        case .firstWorkout: return LocalizedStringResource("badge.firstWorkout.detail", defaultValue: "Du kom afsted på din allerførste tur.")
        case .tenWorkouts: return LocalizedStringResource("badge.tenWorkouts.detail", defaultValue: "Ti gennemførte ture — sikke en vane!")
        case .threeWeekStreak: return LocalizedStringResource("badge.threeWeekStreak.detail", defaultValue: "Tre uger i træk med dine ture.")
        case .firstFiveMinuteRun: return LocalizedStringResource("badge.firstFiveMinuteRun.detail", defaultValue: "Du løb fem minutter uden pause.")
        case .earlyBird: return LocalizedStringResource("badge.earlyBird.detail", defaultValue: "En frisk morgentur.")
        case .rainHero: return LocalizedStringResource("badge.rainHero.detail", defaultValue: "Du tog afsted, selv i regnvejr.")
        case .completedBaseProgram: return LocalizedStringResource("badge.completedBaseProgram.detail", defaultValue: "Du gennemførte hele grundforløbet.")
        }
    }

    var symbolName: String {
        switch self {
        case .firstWorkout: return "figure.run"
        case .tenWorkouts: return "10.circle.fill"
        case .threeWeekStreak: return "flame.fill"
        case .firstFiveMinuteRun: return "timer"
        case .earlyBird: return "sunrise.fill"
        case .rainHero: return "cloud.rain.fill"
        case .completedBaseProgram: return "rosette"
        }
    }
}
