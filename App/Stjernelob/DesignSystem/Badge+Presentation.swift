import SwiftUI
import StjernelobCore

/// Præsentation af badges: emoji, lokaliseret navn/beskrivelse og farvepalet,
/// så de matcher den tegnede SVG-samling. Tonen fejrer fremmøde og små sejre
/// (spec afsnit 5.4) — varmt og opmuntrende, uden fokus på fart/distance.
extension Badge {
    /// Det tegnede mærkes emoji (samme som i SVG-grafikken).
    var emoji: String {
        switch self {
        case .firstStep: return "👟"
        case .braveStarter: return "💪"
        case .oneWeekStreak: return "📆"
        case .twoInOneWeek: return "🔥"
        case .threeInOneWeek: return "⚡"
        case .threeWeekStreak: return "🌟"
        case .unbreakable: return "🏆"
        case .monthHero: return "💎"
        case .backAgain: return "🔄"
        case .earlyBird: return "🌅"
        case .eveningStar: return "🌙"
        case .springAir: return "🌸"
        case .autumnRunner: return "🍂"
        case .iceInBelly: return "❄️"
        case .sunshineRunner: return "☀️"
        case .rainRunner: return "🌧️"
        case .fogRunner: return "🌫️"
        case .rainbowRunner: return "🌈"
        case .christmasRunner: return "🎄"
        case .newYearStart: return "🎆"
        case .birthdayRun: return "🎂"
        case .cityRunner: return "🌃"
        case .natureGirl: return "🌲"
        case .newRoute: return "🌍"
        case .momentPhoto: return "📸"
        case .newPlaylist: return "🎵"
        case .musicInEars: return "🎧"
        case .podcastRunner: return "🎤"
        case .neverGiveUp: return "🏅"
        case .celebrateYourself: return "🎉"
        case .cheerleader: return "📣"
        case .runningBuddy: return "🤝"
        case .readyToStart: return "🎽"
        case .runningDiary: return "📓"
        case .packedAndReady: return "🎒"
        case .stretchStar: return "🧘"
        case .sleepCollector: return "😴"
        case .waterQueen: return "🌊"
        }
    }

    var displayTitle: LocalizedStringResource {
        switch self {
        case .firstStep: return .init("badge.første-skridt.title", defaultValue: "Første skridt")
        case .braveStarter: return .init("badge.modig-starter.title", defaultValue: "Modig starter")
        case .oneWeekStreak: return .init("badge.en-uge-i-traek.title", defaultValue: "En uge i træk")
        case .twoInOneWeek: return .init("badge.2-i-en-uge.title", defaultValue: "2 i én uge")
        case .threeInOneWeek: return .init("badge.3-i-en-uge.title", defaultValue: "3 i én uge")
        case .threeWeekStreak: return .init("badge.3-ugers-streak.title", defaultValue: "3-ugers streak")
        case .unbreakable: return .init("badge.ubrydelig.title", defaultValue: "Ubrydelig")
        case .monthHero: return .init("badge.maanedshelt.title", defaultValue: "Månedshelt")
        case .backAgain: return .init("badge.tilbage-igen.title", defaultValue: "Tilbage igen")
        case .earlyBird: return .init("badge.tidlig-fugl.title", defaultValue: "Tidlig fugl")
        case .eveningStar: return .init("badge.aftenstjerne.title", defaultValue: "Aftenstjerne")
        case .springAir: return .init("badge.foraarsluft.title", defaultValue: "Forårsluft")
        case .autumnRunner: return .init("badge.efteraarsloeber.title", defaultValue: "Efterårsløber")
        case .iceInBelly: return .init("badge.is-i-maven.title", defaultValue: "Is i maven")
        case .sunshineRunner: return .init("badge.solskinsloeber.title", defaultValue: "Solskinsløber")
        case .rainRunner: return .init("badge.regnvejrsloeber.title", defaultValue: "Regnvejrsløber")
        case .fogRunner: return .init("badge.taagelober.title", defaultValue: "Tågeløber")
        case .rainbowRunner: return .init("badge.regnbue-runner.title", defaultValue: "Regnbue-runner")
        case .christmasRunner: return .init("badge.juleloeber.title", defaultValue: "Juleløber")
        case .newYearStart: return .init("badge.nytaarsstart.title", defaultValue: "Nytårsstart")
        case .birthdayRun: return .init("badge.foedselsdag.title", defaultValue: "Fødselsdagstur")
        case .cityRunner: return .init("badge.byloeber.title", defaultValue: "Byløber")
        case .natureGirl: return .init("badge.naturpige.title", defaultValue: "Naturpige")
        case .newRoute: return .init("badge.ny-rute.title", defaultValue: "Ny rute")
        case .momentPhoto: return .init("badge.tur-foto.title", defaultValue: "Tur-foto")
        case .newPlaylist: return .init("badge.ny-playlist.title", defaultValue: "Ny playlist")
        case .musicInEars: return .init("badge.musik-i-oererne.title", defaultValue: "Musik i ørerne")
        case .podcastRunner: return .init("badge.podcast-runner.title", defaultValue: "Podcast-runner")
        case .neverGiveUp: return .init("badge.aldrig-give-op.title", defaultValue: "Aldrig give op")
        case .celebrateYourself: return .init("badge.fejer-dig-selv.title", defaultValue: "Fejr dig selv")
        case .cheerleader: return .init("badge.hepperen.title", defaultValue: "Hepperen")
        case .runningBuddy: return .init("badge.loebemakker.title", defaultValue: "Løbemakker")
        case .readyToStart: return .init("badge.klar-til-start.title", defaultValue: "Klar til start")
        case .runningDiary: return .init("badge.loebedagbog.title", defaultValue: "Løbedagbog")
        case .packedAndReady: return .init("badge.pakket-og-klar.title", defaultValue: "Pakket og klar")
        case .stretchStar: return .init("badge.straek-stjerne.title", defaultValue: "Stræk-stjerne")
        case .sleepCollector: return .init("badge.soevn-samler.title", defaultValue: "Søvn-samler")
        case .waterQueen: return .init("badge.vand-dronning.title", defaultValue: "Vand-dronning")
        }
    }

    var displayDetail: LocalizedStringResource {
        switch self {
        case .firstStep: return .init("badge.første-skridt.detail", defaultValue: "Du kom afsted på din allerførste tur.")
        case .braveStarter: return .init("badge.modig-starter.detail", defaultValue: "Du gennemførte en hel tur. Modigt gjort!")
        case .oneWeekStreak: return .init("badge.en-uge-i-traek.detail", defaultValue: "En hel uge med dine ture.")
        case .twoInOneWeek: return .init("badge.2-i-en-uge.detail", defaultValue: "To ture på én uge — flot!")
        case .threeInOneWeek: return .init("badge.3-i-en-uge.detail", defaultValue: "Tre ture på én uge. Sejt!")
        case .threeWeekStreak: return .init("badge.3-ugers-streak.detail", defaultValue: "Tre uger i træk med dine ture.")
        case .unbreakable: return .init("badge.ubrydelig.detail", defaultValue: "Otte uger i træk — næsten ikke til at stoppe.")
        case .monthHero: return .init("badge.maanedshelt.detail", defaultValue: "En måned fyldt med ture. Hold da op!")
        case .backAgain: return .init("badge.tilbage-igen.detail", defaultValue: "Du tog fat igen efter en pause. Dejligt at have dig tilbage.")
        case .earlyBird: return .init("badge.tidlig-fugl.detail", defaultValue: "En frisk morgentur.")
        case .eveningStar: return .init("badge.aftenstjerne.detail", defaultValue: "En rolig tur i aftentimerne.")
        case .springAir: return .init("badge.foraarsluft.detail", defaultValue: "En tur i den friske forårsluft.")
        case .autumnRunner: return .init("badge.efteraarsloeber.detail", defaultValue: "En tur blandt efterårets farver.")
        case .iceInBelly: return .init("badge.is-i-maven.detail", defaultValue: "Du kom afsted midt om vinteren.")
        case .sunshineRunner: return .init("badge.solskinsloeber.detail", defaultValue: "En tur i sommervarmen.")
        case .rainRunner: return .init("badge.regnvejrsloeber.detail", defaultValue: "Du tog afsted, selv i regnvejr.")
        case .fogRunner: return .init("badge.taagelober.detail", defaultValue: "En tur i tåget vejr.")
        case .rainbowRunner: return .init("badge.regnbue-runner.detail", defaultValue: "Du så en regnbue undervejs.")
        case .christmasRunner: return .init("badge.juleloeber.detail", defaultValue: "En tur i juletiden.")
        case .newYearStart: return .init("badge.nytaarsstart.detail", defaultValue: "Du startede det nye år med en tur.")
        case .birthdayRun: return .init("badge.foedselsdag.detail", defaultValue: "En tur på din fødselsdag.")
        case .cityRunner: return .init("badge.byloeber.detail", defaultValue: "En tur gennem byen.")
        case .natureGirl: return .init("badge.naturpige.detail", defaultValue: "En tur ude i naturen.")
        case .newRoute: return .init("badge.ny-rute.detail", defaultValue: "Du prøvede en helt ny rute.")
        case .momentPhoto: return .init("badge.tur-foto.detail", defaultValue: "Du fangede et øjeblik undervejs.")
        case .newPlaylist: return .init("badge.ny-playlist.detail", defaultValue: "Du løb til en ny playliste.")
        case .musicInEars: return .init("badge.musik-i-oererne.detail", defaultValue: "Musik i ørerne hele vejen.")
        case .podcastRunner: return .init("badge.podcast-runner.detail", defaultValue: "En tur med en god podcast.")
        case .neverGiveUp: return .init("badge.aldrig-give-op.detail", defaultValue: "En hård tur — og du blev ved til mål.")
        case .celebrateYourself: return .init("badge.fejer-dig-selv.detail", defaultValue: "Husk at fejre dig selv. Du fortjener det.")
        case .cheerleader: return .init("badge.hepperen.detail", defaultValue: "Du heppede på en anden løber.")
        case .runningBuddy: return .init("badge.loebemakker.detail", defaultValue: "En tur sammen med en løbemakker.")
        case .readyToStart: return .init("badge.klar-til-start.detail", defaultValue: "Du er klar til at komme i gang.")
        case .runningDiary: return .init("badge.loebedagbog.detail", defaultValue: "Du skrev lidt om din tur.")
        case .packedAndReady: return .init("badge.pakket-og-klar.detail", defaultValue: "Tasken er pakket og klar til tur.")
        case .stretchStar: return .init("badge.straek-stjerne.detail", defaultValue: "Du huskede at strække ud bagefter.")
        case .sleepCollector: return .init("badge.soevn-samler.detail", defaultValue: "Du fik sovet godt før din tur.")
        case .waterQueen: return .init("badge.vand-dronning.detail", defaultValue: "Du huskede at drikke vand.")
        }
    }

    /// Baggrundsfarve for mærket (matcher SVG-grafikken).
    var paletteBackground: Color { Color(badgeHex: paletteHex.background) }
    /// Tekst-/forgrundsfarve for mærket.
    var paletteInk: Color { Color(badgeHex: paletteHex.ink) }

    private var paletteHex: (background: String, ink: String) {
        switch self {
        // Fremmøde og stime — lilla.
        case .oneWeekStreak, .twoInOneWeek, .threeInOneWeek, .threeWeekStreak,
             .unbreakable, .monthHero, .backAgain:
            return ("EEEDFE", "26215C")
        // Kom-i-gang og tidspunkt — teal.
        case .firstStep, .braveStarter, .readyToStart, .earlyBird, .eveningStar:
            return ("E1F5EE", "085041")
        // Årstid og vejr — blå.
        case .springAir, .autumnRunner, .iceInBelly, .sunshineRunner,
             .rainRunner, .fogRunner, .rainbowRunner:
            return ("E6F1FB", "042C53")
        // Mærkedage, sted og natur — grøn.
        case .christmasRunner, .newYearStart, .birthdayRun, .cityRunner,
             .natureGirl, .newRoute, .newPlaylist:
            return ("EAF3DE", "173404")
        // Socialt, fejring og oplevelse — lyserød.
        case .neverGiveUp, .celebrateYourself, .cheerleader, .runningBuddy,
             .momentPhoto, .podcastRunner:
            return ("FBEAF0", "4B1528")
        // Forberedelse, velvære og lyd — sand.
        case .runningDiary, .musicInEars, .packedAndReady, .stretchStar,
             .sleepCollector, .waterQueen:
            return ("FAEEDA", "412402")
        }
    }
}

private extension Color {
    /// Laver en farve ud fra en RGB-hex-streng som "EEEDFE".
    init(badgeHex hex: String) {
        let value = UInt64(hex, radix: 16) ?? 0
        self.init(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255
        )
    }
}
