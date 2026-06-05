import SwiftUI
import StjernelobCore

/// Præsentation af badges: lokaliseret navn, beskrivelse og SF Symbol.
/// Tonen fejrer fremmøde og små sejre (spec afsnit 5.4) — varmt og opmuntrende,
/// uden pres eller fokus på fart/distance.
extension Badge {
    var displayTitle: LocalizedStringResource {
        switch self {
        case .firstRunInterval: return LocalizedStringResource("badge.firstRunInterval.title", defaultValue: "Første løbestykke")
        case .twoRunIntervalsInOneRun: return LocalizedStringResource("badge.twoRunIntervalsInOneRun.title", defaultValue: "To på en tur")
        case .fiveRunIntervalsInOneRun: return LocalizedStringResource("badge.fiveRunIntervalsInOneRun.title", defaultValue: "Fem på en tur")
        case .eightRunIntervalsInOneRun: return LocalizedStringResource("badge.eightRunIntervalsInOneRun.title", defaultValue: "Otte på en tur")
        case .tenRunIntervalsTotal: return LocalizedStringResource("badge.tenRunIntervalsTotal.title", defaultValue: "Ti løbestykker")
        case .twentyFiveRunIntervalsTotal: return LocalizedStringResource("badge.twentyFiveRunIntervalsTotal.title", defaultValue: "Femogtyve løbestykker")
        case .fiftyRunIntervalsTotal: return LocalizedStringResource("badge.fiftyRunIntervalsTotal.title", defaultValue: "Halvtreds løbestykker")
        case .twoRunsWithFourIntervals: return LocalizedStringResource("badge.twoRunsWithFourIntervals.title", defaultValue: "To gode ture")
        case .firstWorkout: return LocalizedStringResource("badge.firstWorkout.title", defaultValue: "Første tur")
        case .fiveWorkouts: return LocalizedStringResource("badge.fiveWorkouts.title", defaultValue: "Fem ture")
        case .tenWorkouts: return LocalizedStringResource("badge.tenWorkouts.title", defaultValue: "Ti ture")
        case .twentyFiveWorkouts: return LocalizedStringResource("badge.twentyFiveWorkouts.title", defaultValue: "Femogtyve ture")
        case .threeWeekStreak: return LocalizedStringResource("badge.threeWeekStreak.title", defaultValue: "Tre ugers stime")
        case .fiveWeekStreak: return LocalizedStringResource("badge.fiveWeekStreak.title", defaultValue: "Fem ugers stime")
        case .earlyBird: return LocalizedStringResource("badge.earlyBird.title", defaultValue: "Morgenfugl")
        case .eveningStar: return LocalizedStringResource("badge.eveningStar.title", defaultValue: "Aftenstjerne")
        case .weekendWarrior: return LocalizedStringResource("badge.weekendWarrior.title", defaultValue: "Weekendløber")
        case .winterRunner: return LocalizedStringResource("badge.winterRunner.title", defaultValue: "Vinterløber")
        case .summerRunner: return LocalizedStringResource("badge.summerRunner.title", defaultValue: "Sommerløber")
        case .rainHero: return LocalizedStringResource("badge.rainHero.title", defaultValue: "Regnvejrshelt")
        case .photographer: return LocalizedStringResource("badge.photographer.title", defaultValue: "Fotograf")
        case .comeback: return LocalizedStringResource("badge.comeback.title", defaultValue: "Velkommen tilbage")
        case .completedBaseProgram: return LocalizedStringResource("badge.completedBaseProgram.title", defaultValue: "Grundforløbet gennemført")
        }
    }

    var displayDetail: LocalizedStringResource {
        switch self {
        case .firstRunInterval: return LocalizedStringResource("badge.firstRunInterval.detail", defaultValue: "Du løb dit allerførste løbestykke. Du er i gang!")
        case .twoRunIntervalsInOneRun: return LocalizedStringResource("badge.twoRunIntervalsInOneRun.detail", defaultValue: "To løbestykker på samme tur — flot!")
        case .fiveRunIntervalsInOneRun: return LocalizedStringResource("badge.fiveRunIntervalsInOneRun.detail", defaultValue: "Fem løbestykker på én tur. Sejt klaret!")
        case .eightRunIntervalsInOneRun: return LocalizedStringResource("badge.eightRunIntervalsInOneRun.detail", defaultValue: "Otte løbestykker på samme tur — hold da op!")
        case .tenRunIntervalsTotal: return LocalizedStringResource("badge.tenRunIntervalsTotal.detail", defaultValue: "Ti løbestykker i alt. Det vokser stille og roligt.")
        case .twentyFiveRunIntervalsTotal: return LocalizedStringResource("badge.twentyFiveRunIntervalsTotal.detail", defaultValue: "Femogtyve løbestykker i alt — du bliver bare ved.")
        case .fiftyRunIntervalsTotal: return LocalizedStringResource("badge.fiftyRunIntervalsTotal.detail", defaultValue: "Halvtreds løbestykker i alt. Det er stærkt!")
        case .twoRunsWithFourIntervals: return LocalizedStringResource("badge.twoRunsWithFourIntervals.detail", defaultValue: "To ture med mindst fire løbestykker i hver.")
        case .firstWorkout: return LocalizedStringResource("badge.firstWorkout.detail", defaultValue: "Du kom afsted på din allerførste tur.")
        case .fiveWorkouts: return LocalizedStringResource("badge.fiveWorkouts.detail", defaultValue: "Fem ture i hus — du er rigtig godt i gang!")
        case .tenWorkouts: return LocalizedStringResource("badge.tenWorkouts.detail", defaultValue: "Ti gennemførte ture — sikke en vane!")
        case .twentyFiveWorkouts: return LocalizedStringResource("badge.twentyFiveWorkouts.detail", defaultValue: "Femogtyve ture — du bliver ved, og det kan ses.")
        case .threeWeekStreak: return LocalizedStringResource("badge.threeWeekStreak.detail", defaultValue: "Tre uger i træk med dine ture.")
        case .fiveWeekStreak: return LocalizedStringResource("badge.fiveWeekStreak.detail", defaultValue: "Fem uger i træk — det er blevet din egen vane.")
        case .earlyBird: return LocalizedStringResource("badge.earlyBird.detail", defaultValue: "En frisk morgentur.")
        case .eveningStar: return LocalizedStringResource("badge.eveningStar.detail", defaultValue: "En rolig tur i aftentimerne.")
        case .weekendWarrior: return LocalizedStringResource("badge.weekendWarrior.detail", defaultValue: "Du tog en tur i weekenden.")
        case .winterRunner: return LocalizedStringResource("badge.winterRunner.detail", defaultValue: "Du kom afsted midt om vinteren.")
        case .summerRunner: return LocalizedStringResource("badge.summerRunner.detail", defaultValue: "En tur i sommervarmen.")
        case .rainHero: return LocalizedStringResource("badge.rainHero.detail", defaultValue: "Du tog afsted, selv i regnvejr.")
        case .photographer: return LocalizedStringResource("badge.photographer.detail", defaultValue: "Du fangede et øjeblik undervejs.")
        case .comeback: return LocalizedStringResource("badge.comeback.detail", defaultValue: "Du tog fat igen efter en pause. Dejligt at have dig tilbage.")
        case .completedBaseProgram: return LocalizedStringResource("badge.completedBaseProgram.detail", defaultValue: "Du gennemførte hele grundforløbet.")
        }
    }

    var symbolName: String {
        switch self {
        case .firstRunInterval: return "figure.run"
        case .twoRunIntervalsInOneRun: return "2.circle.fill"
        case .fiveRunIntervalsInOneRun: return "5.circle.fill"
        case .eightRunIntervalsInOneRun: return "8.circle.fill"
        case .tenRunIntervalsTotal: return "10.circle.fill"
        case .twentyFiveRunIntervalsTotal: return "25.circle.fill"
        case .fiftyRunIntervalsTotal: return "50.circle.fill"
        case .twoRunsWithFourIntervals: return "checkmark.seal.fill"
        case .firstWorkout: return "flag.checkered"
        case .fiveWorkouts: return "star.fill"
        case .tenWorkouts: return "star.circle.fill"
        case .twentyFiveWorkouts: return "trophy.fill"
        case .threeWeekStreak: return "flame.fill"
        case .fiveWeekStreak: return "flame.circle.fill"
        case .earlyBird: return "sunrise.fill"
        case .eveningStar: return "moon.stars.fill"
        case .weekendWarrior: return "calendar"
        case .winterRunner: return "snowflake"
        case .summerRunner: return "sun.max.fill"
        case .rainHero: return "cloud.rain.fill"
        case .photographer: return "camera.fill"
        case .comeback: return "hand.wave.fill"
        case .completedBaseProgram: return "rosette"
        }
    }
}
