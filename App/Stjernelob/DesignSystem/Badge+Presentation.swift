import StjernelobCore
import SwiftUI

/// Præsentation af badges: emoji, lokaliseret navn/beskrivelse og farvepalet,
/// så de matcher den tegnede SVG-samling. Tonen fejrer fremmøde og små sejre
/// (spec afsnit 5.4) — varmt og opmuntrende, uden fokus på fart/distance.
extension Badge {
    /// Det tegnede mærkes emoji (samme som i SVG-grafikken).
    var emoji: String {
        switch self {
        case .firstStep: "👟"
        case .braveStarter: "💪"
        case .oneWeekStreak: "📆"
        case .twoInOneWeek: "🔥"
        case .threeInOneWeek: "⚡"
        case .threeWeekStreak: "🌟"
        case .unbreakable: "🏆"
        case .monthHero: "💎"
        case .backAgain: "🔄"
        case .earlyBird: "🌅"
        case .eveningStar: "🌙"
        case .springAir: "🌸"
        case .autumnRunner: "🍂"
        case .iceInBelly: "❄️"
        case .sunshineRunner: "☀️"
        case .rainRunner: "🌧️"
        case .fogRunner: "🌫️"
        case .rainbowRunner: "🌈"
        case .christmasRunner: "🎄"
        case .newYearStart: "🎆"
        case .birthdayRun: "🎂"
        case .cityRunner: "🌃"
        case .natureGirl: "🌲"
        case .newRoute: "🌍"
        case .momentPhoto: "📸"
        case .newPlaylist: "🎵"
        case .musicInEars: "🎧"
        case .podcastRunner: "🎤"
        case .neverGiveUp: "🏅"
        case .celebrateYourself: "🎉"
        case .cheerleader: "📣"
        case .runningBuddy: "🤝"
        case .readyToStart: "🎽"
        case .runningDiary: "📓"
        case .packedAndReady: "🎒"
        case .stretchStar: "🧘"
        case .sleepCollector: "😴"
        case .waterQueen: "🌊"
        case .interval5: "👟"
        case .interval10: "👟"
        case .interval25: "👟"
        case .interval50: "👟"
        case .interval100: "🏅"
        case .interval200: "🏅"
        case .interval15: "👟"
        case .interval20: "👟"
        case .interval30: "👟"
        case .interval40: "👟"
        case .interval75: "👟"
        case .interval150: "🏅"
        case .interval300: "🏅"
        case .interval500: "🏅"
        case .interval750: "🏅"
        case .interval1000: "🏅"
        case .sessionFourIntervals: "⚡"
        case .sessionSixIntervals: "⚡"
        case .sessionEightIntervals: "⚡"
        case .continuousRun5: "🏃‍♀️"
        case .continuousRun10: "🏃‍♀️"
        case .continuousRun20: "🔥"
        case .continuousRun30: "🌟"
        case .runs1: "🏃"
        case .runs3: "🏃"
        case .runs5: "🏃"
        case .runs10: "🏃"
        case .runs15: "🏃"
        case .runs20: "🏃"
        case .runs25: "🏃"
        case .runs30: "🏃"
        case .runs40: "🏃"
        case .runs50: "🏃"
        case .runs60: "🏃"
        case .runs75: "🏃"
        case .runs80: "🏃"
        case .runs100: "🏆"
        case .activeWeeks1: "📆"
        case .activeWeeks2: "📆"
        case .activeWeeks4: "📆"
        case .activeWeeks6: "📆"
        case .activeWeeks8: "📆"
        case .activeWeeks10: "📆"
        case .activeWeeks12: "📆"
        case .activeWeeks16: "📆"
        case .activeWeeks20: "🌟"
        case .activeWeeks26: "🌟"
        case .activeWeeks52: "🥇"
        case .stars10: "⭐️"
        case .stars25: "⭐️"
        case .stars50: "⭐️"
        case .stars100: "⭐️"
        case .stars250: "🌠"
        case .stars500: "💫"
        case .stars1000: "🌟"
        }
    }

    var displayTitle: LocalizedStringResource {
        switch self {
        case .firstStep: .init("badge.første-skridt.title", defaultValue: "Første skridt")
        case .braveStarter: .init("badge.modig-starter.title", defaultValue: "Modig starter")
        case .oneWeekStreak: .init("badge.en-uge-i-traek.title", defaultValue: "En uge i træk")
        case .twoInOneWeek: .init("badge.2-i-en-uge.title", defaultValue: "2 i én uge")
        case .threeInOneWeek: .init("badge.3-i-en-uge.title", defaultValue: "3 i én uge")
        case .threeWeekStreak: .init("badge.3-ugers-streak.title", defaultValue: "3-ugers streak")
        case .unbreakable: .init("badge.ubrydelig.title", defaultValue: "Ubrydelig")
        case .monthHero: .init("badge.maanedshelt.title", defaultValue: "Månedshelt")
        case .backAgain: .init("badge.tilbage-igen.title", defaultValue: "Tilbage igen")
        case .earlyBird: .init("badge.tidlig-fugl.title", defaultValue: "Tidlig fugl")
        case .eveningStar: .init("badge.aftenstjerne.title", defaultValue: "Aftenstjerne")
        case .springAir: .init("badge.foraarsluft.title", defaultValue: "Forårsluft")
        case .autumnRunner: .init("badge.efteraarsloeber.title", defaultValue: "Efterårsløber")
        case .iceInBelly: .init("badge.is-i-maven.title", defaultValue: "Is i maven")
        case .sunshineRunner: .init("badge.solskinsloeber.title", defaultValue: "Solskinsløber")
        case .rainRunner: .init("badge.regnvejrsloeber.title", defaultValue: "Regnvejrsløber")
        case .fogRunner: .init("badge.taagelober.title", defaultValue: "Tågeløber")
        case .rainbowRunner: .init("badge.regnbue-runner.title", defaultValue: "Regnbue-runner")
        case .christmasRunner: .init("badge.juleloeber.title", defaultValue: "Juleløber")
        case .newYearStart: .init("badge.nytaarsstart.title", defaultValue: "Nytårsstart")
        case .birthdayRun: .init("badge.foedselsdag.title", defaultValue: "Fødselsdagstur")
        case .cityRunner: .init("badge.byloeber.title", defaultValue: "Byløber")
        case .natureGirl: .init("badge.naturpige.title", defaultValue: "Naturpige")
        case .newRoute: .init("badge.ny-rute.title", defaultValue: "Ny rute")
        case .momentPhoto: .init("badge.tur-foto.title", defaultValue: "Tur-foto")
        case .newPlaylist: .init("badge.ny-playlist.title", defaultValue: "Ny playlist")
        case .musicInEars: .init("badge.musik-i-oererne.title", defaultValue: "Musik i ørerne")
        case .podcastRunner: .init("badge.podcast-runner.title", defaultValue: "Podcast-runner")
        case .neverGiveUp: .init("badge.aldrig-give-op.title", defaultValue: "Aldrig give op")
        case .celebrateYourself: .init("badge.fejer-dig-selv.title", defaultValue: "Fejr dig selv")
        case .cheerleader: .init("badge.hepperen.title", defaultValue: "Hepperen")
        case .runningBuddy: .init("badge.loebemakker.title", defaultValue: "Løbemakker")
        case .readyToStart: .init("badge.klar-til-start.title", defaultValue: "Klar til start")
        case .runningDiary: .init("badge.loebedagbog.title", defaultValue: "Løbedagbog")
        case .packedAndReady: .init("badge.pakket-og-klar.title", defaultValue: "Pakket og klar")
        case .stretchStar: .init("badge.straek-stjerne.title", defaultValue: "Stræk-stjerne")
        case .sleepCollector: .init("badge.soevn-samler.title", defaultValue: "Søvn-samler")
        case .waterQueen: .init("badge.vand-dronning.title", defaultValue: "Vand-dronning")
        case .interval5: .init("badge.interval-5.title", defaultValue: "5 intervaller")
        case .interval10: .init("badge.interval-10.title", defaultValue: "10 intervaller")
        case .interval25: .init("badge.interval-25.title", defaultValue: "25 intervaller")
        case .interval50: .init("badge.interval-50.title", defaultValue: "50 intervaller")
        case .interval100: .init("badge.interval-100.title", defaultValue: "100 intervaller")
        case .interval200: .init("badge.interval-200.title", defaultValue: "200 intervaller")
        case .interval15: .init("badge.interval-15.title", defaultValue: "15 intervaller")
        case .interval20: .init("badge.interval-20.title", defaultValue: "20 intervaller")
        case .interval30: .init("badge.interval-30.title", defaultValue: "30 intervaller")
        case .interval40: .init("badge.interval-40.title", defaultValue: "40 intervaller")
        case .interval75: .init("badge.interval-75.title", defaultValue: "75 intervaller")
        case .interval150: .init("badge.interval-150.title", defaultValue: "150 intervaller")
        case .interval300: .init("badge.interval-300.title", defaultValue: "300 intervaller")
        case .interval500: .init("badge.interval-500.title", defaultValue: "500 intervaller")
        case .interval750: .init("badge.interval-750.title", defaultValue: "750 intervaller")
        case .interval1000: .init("badge.interval-1000.title", defaultValue: "1000 intervaller")
        case .sessionFourIntervals: .init(
                "badge.session-4-intervaller.title",
                defaultValue: "4 i træk"
            )
        case .sessionSixIntervals: .init(
                "badge.session-6-intervaller.title",
                defaultValue: "6 i træk"
            )
        case .sessionEightIntervals: .init(
                "badge.session-8-intervaller.title",
                defaultValue: "8 i træk"
            )
        case .continuousRun5: .init(
                "badge.uafbrudt-5.title",
                defaultValue: "5 minutter i træk"
            )
        case .continuousRun10: .init(
                "badge.uafbrudt-10.title",
                defaultValue: "10 minutter i træk"
            )
        case .continuousRun20: .init(
                "badge.uafbrudt-20.title",
                defaultValue: "20 minutter i træk"
            )
        case .continuousRun30: .init(
                "badge.uafbrudt-30.title",
                defaultValue: "30 minutter i træk"
            )
        case .runs1: .init("badge.tur-1.title", defaultValue: "1 tur")
        case .runs3: .init("badge.tur-3.title", defaultValue: "3 ture")
        case .runs5: .init("badge.tur-5.title", defaultValue: "5 ture")
        case .runs10: .init("badge.tur-10.title", defaultValue: "10 ture")
        case .runs15: .init("badge.tur-15.title", defaultValue: "15 ture")
        case .runs20: .init("badge.tur-20.title", defaultValue: "20 ture")
        case .runs25: .init("badge.tur-25.title", defaultValue: "25 ture")
        case .runs30: .init("badge.tur-30.title", defaultValue: "30 ture")
        case .runs40: .init("badge.tur-40.title", defaultValue: "40 ture")
        case .runs50: .init("badge.tur-50.title", defaultValue: "50 ture")
        case .runs60: .init("badge.tur-60.title", defaultValue: "60 ture")
        case .runs75: .init("badge.tur-75.title", defaultValue: "75 ture")
        case .runs80: .init("badge.tur-80.title", defaultValue: "80 ture")
        case .runs100: .init("badge.tur-100.title", defaultValue: "100 ture")
        case .activeWeeks1: .init("badge.aktiv-uge-1.title", defaultValue: "Første aktive uge")
        case .activeWeeks2: .init("badge.aktiv-uge-2.title", defaultValue: "2 aktive uger")
        case .activeWeeks4: .init("badge.aktiv-uge-4.title", defaultValue: "4 aktive uger")
        case .activeWeeks6: .init("badge.aktiv-uge-6.title", defaultValue: "6 aktive uger")
        case .activeWeeks8: .init("badge.aktiv-uge-8.title", defaultValue: "8 aktive uger")
        case .activeWeeks10: .init("badge.aktiv-uge-10.title", defaultValue: "10 aktive uger")
        case .activeWeeks12: .init("badge.aktiv-uge-12.title", defaultValue: "12 aktive uger")
        case .activeWeeks16: .init("badge.aktiv-uge-16.title", defaultValue: "16 aktive uger")
        case .activeWeeks20: .init("badge.aktiv-uge-20.title", defaultValue: "20 aktive uger")
        case .activeWeeks26: .init("badge.aktiv-uge-26.title", defaultValue: "Et halvt år")
        case .activeWeeks52: .init("badge.aktiv-uge-52.title", defaultValue: "Et helt år")
        case .stars10: .init("badge.stjerner-10.title", defaultValue: "10 stjerner")
        case .stars25: .init("badge.stjerner-25.title", defaultValue: "25 stjerner")
        case .stars50: .init("badge.stjerner-50.title", defaultValue: "50 stjerner")
        case .stars100: .init("badge.stjerner-100.title", defaultValue: "100 stjerner")
        case .stars250: .init("badge.stjerner-250.title", defaultValue: "250 stjerner")
        case .stars500: .init("badge.stjerner-500.title", defaultValue: "500 stjerner")
        case .stars1000: .init("badge.stjerner-1000.title", defaultValue: "1000 stjerner")
        }
    }

    var displayDetail: LocalizedStringResource {
        switch self {
        case .firstStep: .init(
                "badge.første-skridt.detail",
                defaultValue: "Du kom afsted på din allerførste tur."
            )
        case .braveStarter: .init(
                "badge.modig-starter.detail",
                defaultValue: "Du gennemførte en hel tur. Modigt gjort!"
            )
        case .oneWeekStreak: .init(
                "badge.en-uge-i-traek.detail",
                defaultValue: "En hel uge med dine ture."
            )
        case .twoInOneWeek: .init(
                "badge.2-i-en-uge.detail",
                defaultValue: "To ture på én uge — flot!"
            )
        case .threeInOneWeek: .init(
                "badge.3-i-en-uge.detail",
                defaultValue: "Tre ture på én uge. Sejt!"
            )
        case .threeWeekStreak: .init(
                "badge.3-ugers-streak.detail",
                defaultValue: "Tre uger i træk med dine ture."
            )
        case .unbreakable: .init(
                "badge.ubrydelig.detail",
                defaultValue: "Otte uger i træk — næsten ikke til at stoppe."
            )
        case .monthHero: .init(
                "badge.maanedshelt.detail",
                defaultValue: "En måned fyldt med ture. Hold da op!"
            )
        case .backAgain: .init(
                "badge.tilbage-igen.detail",
                defaultValue: "Du tog fat igen efter en pause. Dejligt at have dig tilbage."
            )
        case .earlyBird: .init("badge.tidlig-fugl.detail", defaultValue: "En frisk morgentur.")
        case .eveningStar: .init(
                "badge.aftenstjerne.detail",
                defaultValue: "En rolig tur i aftentimerne."
            )
        case .springAir: .init(
                "badge.foraarsluft.detail",
                defaultValue: "En tur i den friske forårsluft."
            )
        case .autumnRunner: .init(
                "badge.efteraarsloeber.detail",
                defaultValue: "En tur blandt efterårets farver."
            )
        case .iceInBelly: .init(
                "badge.is-i-maven.detail",
                defaultValue: "Du kom afsted midt om vinteren."
            )
        case .sunshineRunner: .init(
                "badge.solskinsloeber.detail",
                defaultValue: "En tur i sommervarmen."
            )
        case .rainRunner: .init(
                "badge.regnvejrsloeber.detail",
                defaultValue: "Du tog afsted, selv i regnvejr."
            )
        case .fogRunner: .init("badge.taagelober.detail", defaultValue: "En tur i tåget vejr.")
        case .rainbowRunner: .init(
                "badge.regnbue-runner.detail",
                defaultValue: "Du så en regnbue undervejs."
            )
        case .christmasRunner: .init("badge.juleloeber.detail", defaultValue: "En tur i juletiden.")
        case .newYearStart: .init(
                "badge.nytaarsstart.detail",
                defaultValue: "Du startede det nye år med en tur."
            )
        case .birthdayRun: .init(
                "badge.foedselsdag.detail",
                defaultValue: "En tur på din fødselsdag."
            )
        case .cityRunner: .init("badge.byloeber.detail", defaultValue: "En tur gennem byen.")
        case .natureGirl: .init("badge.naturpige.detail", defaultValue: "En tur ude i naturen.")
        case .newRoute: .init("badge.ny-rute.detail", defaultValue: "Du prøvede en helt ny rute.")
        case .momentPhoto: .init(
                "badge.tur-foto.detail",
                defaultValue: "Du fangede et øjeblik undervejs."
            )
        case .newPlaylist: .init(
                "badge.ny-playlist.detail",
                defaultValue: "Du løb til en ny playliste."
            )
        case .musicInEars: .init(
                "badge.musik-i-oererne.detail",
                defaultValue: "Musik i ørerne hele vejen."
            )
        case .podcastRunner: .init(
                "badge.podcast-runner.detail",
                defaultValue: "En tur med en god podcast."
            )
        case .neverGiveUp: .init(
                "badge.aldrig-give-op.detail",
                defaultValue: "En hård tur — og du blev ved til mål."
            )
        case .celebrateYourself: .init(
                "badge.fejer-dig-selv.detail",
                defaultValue: "Husk at fejre dig selv. Du fortjener det."
            )
        case .cheerleader: .init(
                "badge.hepperen.detail",
                defaultValue: "Du heppede på en anden løber."
            )
        case .runningBuddy: .init(
                "badge.loebemakker.detail",
                defaultValue: "En tur sammen med en løbemakker."
            )
        case .readyToStart: .init(
                "badge.klar-til-start.detail",
                defaultValue: "Du er klar til at komme i gang."
            )
        case .runningDiary: .init(
                "badge.loebedagbog.detail",
                defaultValue: "Du skrev lidt om din tur."
            )
        case .packedAndReady: .init(
                "badge.pakket-og-klar.detail",
                defaultValue: "Tasken er pakket og klar til tur."
            )
        case .stretchStar: .init(
                "badge.straek-stjerne.detail",
                defaultValue: "Du huskede at strække ud bagefter."
            )
        case .sleepCollector: .init(
                "badge.soevn-samler.detail",
                defaultValue: "Du fik sovet godt før din tur."
            )
        case .waterQueen: .init(
                "badge.vand-dronning.detail",
                defaultValue: "Du huskede at drikke vand."
            )
        case .interval5: .init(
                "badge.interval-5.detail",
                defaultValue: "Gennemfør 5 løbeintervaller i alt"
            )
        case .interval10: .init(
                "badge.interval-10.detail",
                defaultValue: "Gennemfør 10 løbeintervaller i alt"
            )
        case .interval25: .init(
                "badge.interval-25.detail",
                defaultValue: "Gennemfør 25 løbeintervaller i alt"
            )
        case .interval50: .init(
                "badge.interval-50.detail",
                defaultValue: "Halvtredseren — 50 løbeintervaller gennemført!"
            )
        case .interval100: .init(
                "badge.interval-100.detail",
                defaultValue: "Tre cifre! 100 løbeintervaller i alt 🎉"
            )
        case .interval200: .init(
                "badge.interval-200.detail",
                defaultValue: "200 gange har du sagt ja til at løbe"
            )
        case .interval15: .init(
                "badge.interval-15.detail",
                defaultValue: "15 løbeintervaller i alt — flot fremgang"
            )
        case .interval20: .init(
                "badge.interval-20.detail",
                defaultValue: "20 løbeintervaller gennemført"
            )
        case .interval30: .init(
                "badge.interval-30.detail",
                defaultValue: "30 løbeintervaller i alt — det vokser støt"
            )
        case .interval40: .init(
                "badge.interval-40.detail",
                defaultValue: "40 løbeintervaller gennemført"
            )
        case .interval75: .init(
                "badge.interval-75.detail",
                defaultValue: "75 løbeintervaller i alt"
            )
        case .interval150: .init(
                "badge.interval-150.detail",
                defaultValue: "150 løbeintervaller gennemført"
            )
        case .interval300: .init(
                "badge.interval-300.detail",
                defaultValue: "300 løbeintervaller i alt — sejt!"
            )
        case .interval500: .init(
                "badge.interval-500.detail",
                defaultValue: "500 intervaller. Det er ikke tilfældigt — det er dig."
            )
        case .interval750: .init(
                "badge.interval-750.detail",
                defaultValue: "750 løbeintervaller i alt"
            )
        case .interval1000: .init(
                "badge.interval-1000.detail",
                defaultValue: "Et helt tusinde! Du er officielt en interval-legende"
            )
        case .sessionFourIntervals: .init(
                "badge.session-4-intervaller.detail",
                defaultValue: "Gennemfør 4 løbeintervaller i samme tur"
            )
        case .sessionSixIntervals: .init(
                "badge.session-6-intervaller.detail",
                defaultValue: "Gennemfør 6 løbeintervaller i samme tur"
            )
        case .sessionEightIntervals: .init(
                "badge.session-8-intervaller.detail",
                defaultValue: "8 løbeintervaller i én og samme tur — kæmpe!"
            )
        case .continuousRun5: .init(
                "badge.uafbrudt-5.detail",
                defaultValue: "Du løb 5 minutter uden en gå-pause. Stor milepæl!"
            )
        case .continuousRun10: .init(
                "badge.uafbrudt-10.detail",
                defaultValue: "10 minutters sammenhængende løb — hold da op, godt gået!"
            )
        case .continuousRun20: .init(
                "badge.uafbrudt-20.detail",
                defaultValue: "20 minutter i ét stræk — et kæmpe spring fra dag ét!"
            )
        case .continuousRun30: .init(
                "badge.uafbrudt-30.detail",
                defaultValue: "En halv time i ét stræk. Det er stort, og det er dit."
            )
        case .runs1: .init(
                "badge.tur-1.detail",
                defaultValue: "Din allerførste løbetur — den sværeste af dem alle"
            )
        case .runs3: .init(
                "badge.tur-3.detail",
                defaultValue: "3 ture i alt — vanen er ved at tage form"
            )
        case .runs5: .init("badge.tur-5.detail", defaultValue: "5 ture klaret. High five!")
        case .runs10: .init("badge.tur-10.detail", defaultValue: "10 ture i alt. Du er løber nu.")
        case .runs15: .init(
                "badge.tur-15.detail",
                defaultValue: "15 gange er du kommet ud af døren"
            )
        case .runs20: .init(
                "badge.tur-20.detail",
                defaultValue: "20 ture — to fulde ugers indsats samlet op"
            )
        case .runs25: .init(
                "badge.tur-25.detail",
                defaultValue: "Et kvart hundrede ture. Ikke småting."
            )
        case .runs30: .init(
                "badge.tur-30.detail",
                defaultValue: "30 ture gennemført. Det er noget at fejre."
            )
        case .runs40: .init(
                "badge.tur-40.detail",
                defaultValue: "40 ture! Dine ben husker det her i søvne."
            )
        case .runs50: .init(
                "badge.tur-50.detail",
                defaultValue: "50 løbeture. Det er virkelig mange — og alle gennemført af dig."
            )
        case .runs60: .init("badge.tur-60.detail", defaultValue: "60 løbeture gennemført")
        case .runs75: .init(
                "badge.tur-75.detail",
                defaultValue: "75 ture — det er ikke en hobby, det er en del af dig"
            )
        case .runs80: .init(
                "badge.tur-80.detail",
                defaultValue: "80 løbeture — næsten ved hundrede"
            )
        case .runs100: .init(
                "badge.tur-100.detail",
                defaultValue: "100 løbeture. Tre cifre. Helt vildt."
            )
        case .activeWeeks1: .init(
                "badge.aktiv-uge-1.detail",
                defaultValue: "Gennemfør mindst 1 tur i din første uge"
            )
        case .activeWeeks2: .init(
                "badge.aktiv-uge-2.detail",
                defaultValue: "To uger i træk med mindst én tur"
            )
        case .activeWeeks4: .init(
                "badge.aktiv-uge-4.detail",
                defaultValue: "En hel måneds aktive uger — du klarer det!"
            )
        case .activeWeeks6: .init(
                "badge.aktiv-uge-6.detail",
                defaultValue: "6 uger med løb. Det begynder at føles naturligt."
            )
        case .activeWeeks8: .init(
                "badge.aktiv-uge-8.detail",
                defaultValue: "2 måneders aktive uger — grundforløbet i hus!"
            )
        case .activeWeeks10: .init(
                "badge.aktiv-uge-10.detail",
                defaultValue: "10 uger med løb. Du har fundet en god rytme."
            )
        case .activeWeeks12: .init(
                "badge.aktiv-uge-12.detail",
                defaultValue: "3 måneder. Det er ikke en tilfældighed."
            )
        case .activeWeeks16: .init(
                "badge.aktiv-uge-16.detail",
                defaultValue: "4 måneder med aktive løbeuger. Imponerende."
            )
        case .activeWeeks20: .init(
                "badge.aktiv-uge-20.detail",
                defaultValue: "Hele programmet i aktive uger. Du gennemførte det!"
            )
        case .activeWeeks26: .init(
                "badge.aktiv-uge-26.detail",
                defaultValue: "26 aktive uger — et halvt år som løber"
            )
        case .activeWeeks52: .init(
                "badge.aktiv-uge-52.detail",
                defaultValue: "52 aktive uger. Et helt år som løber. Legendarisk."
            )
        case .stars10: .init("badge.stjerner-10.detail", defaultValue: "Optjen 10 stjerner i alt")
        case .stars25: .init("badge.stjerner-25.detail", defaultValue: "25 stjerner på kontoen")
        case .stars50: .init("badge.stjerner-50.detail", defaultValue: "50 stjerner — du funkler!")
        case .stars100: .init(
                "badge.stjerner-100.detail",
                defaultValue: "Et hundrede stjerner. Himlen er fuld af dem."
            )
        case .stars250: .init(
                "badge.stjerner-250.detail",
                defaultValue: "250 stjerner optjent — du er et stjerneskud"
            )
        case .stars500: .init(
                "badge.stjerner-500.detail",
                defaultValue: "500 stjerner. Der er ikke ord for det."
            )
        case .stars1000: .init(
                "badge.stjerner-1000.detail",
                defaultValue: "Et tusinde stjerner. Du ER Stjerneløb."
            )
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
            ("EEEDFE", "26215C")
        // Kom-i-gang og tidspunkt — teal.
        case .firstStep, .braveStarter, .readyToStart, .earlyBird, .eveningStar:
            ("E1F5EE", "085041")
        // Årstid og vejr — blå.
        case .springAir, .autumnRunner, .iceInBelly, .sunshineRunner,
             .rainRunner, .fogRunner, .rainbowRunner:
            ("E6F1FB", "042C53")
        // Mærkedage, sted og natur — grøn.
        case .christmasRunner, .newYearStart, .birthdayRun, .cityRunner,
             .natureGirl, .newRoute, .newPlaylist:
            ("EAF3DE", "173404")
        // Socialt, fejring og oplevelse — lyserød.
        case .neverGiveUp, .celebrateYourself, .cheerleader, .runningBuddy,
             .momentPhoto, .podcastRunner:
            ("FBEAF0", "4B1528")
        // Forberedelse, velvære og lyd — sand.
        case .runningDiary, .musicInEars, .packedAndReady, .stretchStar,
             .sleepCollector, .waterQueen:
            ("FAEEDA", "412402")
        // Milepæle (importeret).
        case .interval5, .interval10, .interval15, .interval20, .interval25,
             .interval30, .interval40, .interval50, .interval75, .interval100,
             .interval150, .interval200, .interval300, .interval500, .interval750, .interval1000,
             .sessionFourIntervals, .sessionSixIntervals, .sessionEightIntervals,
             .continuousRun5, .continuousRun10, .continuousRun20, .continuousRun30:
            ("E1F5EE", "085041")
        case .runs1, .runs3, .runs5, .runs10, .runs15, .runs20, .runs25,
             .runs30, .runs40, .runs50, .runs60, .runs75, .runs80, .runs100:
            ("EEEDFE", "26215C")
        case .activeWeeks1, .activeWeeks2, .activeWeeks4, .activeWeeks6, .activeWeeks8,
             .activeWeeks10, .activeWeeks12, .activeWeeks16, .activeWeeks20,
             .activeWeeks26, .activeWeeks52:
            ("E6F1FB", "042C53")
        case .stars10, .stars25, .stars50, .stars100, .stars250, .stars500, .stars1000:
            ("FAEEDA", "412402")
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
