import StjernelobCore
import SwiftUI

/// Præsentation af badges: emoji, lokaliseret navn/beskrivelse og farvepalet.
/// Alt læses fra `BadgeDefinition` i kataloget — ét sted at vedligeholde, og nye
/// mærker behøver ingen ændringer her. Tonen fejrer fremmøde og små sejre
/// (spec afsnit 5.4) — varmt og opmuntrende, uden fokus på fart/distance.
extension Badge {
    /// Det tegnede mærkes emoji (samme som i SVG-grafikken).
    var emoji: String { definition.emoji }

    /// SF Symbol til mærket — et skarpt vektor-ikon, der altid kan tegnes (modsat
    /// emoji, der bokser på simulatoren og slet ikke kan rasteriseres i en SVG).
    /// Milepæls-trin uden eget motiv falder tilbage på deres stige-ikon.
    var symbolName: String {
        switch slug {
        case "første-skridt": "figure.walk"
        case "modig-starter": "figure.run"
        case "klar-til-start": "flag.checkered"
        case "tidlig-fugl": "sunrise.fill"
        case "aftenstjerne": "moon.stars.fill"
        case "en-uge-i-traek": "calendar"
        case "2-i-en-uge", "3-i-en-uge", "3-ugers-streak": "flame.fill"
        case "ubrydelig": "trophy.fill"
        case "maanedshelt": "crown.fill"
        case "tilbage-igen": "arrow.uturn.left.circle.fill"
        case "foraarsluft": "leaf.fill"
        case "efteraarsloeber": "wind"
        case "is-i-maven": "snowflake"
        case "solskinsloeber": "sun.max.fill"
        case "regnvejrsloeber": "cloud.rain.fill"
        case "taagelober": "cloud.fog.fill"
        case "regnbue-runner": "rainbow"
        case "juleloeber": "gift.fill"
        case "nytaarsstart": "sparkles"
        case "foedselsdag": "balloon.fill"
        case "byloeber": "building.2.fill"
        case "naturpige": "tree.fill"
        case "ny-rute": "map.fill"
        case "tur-foto": "camera.fill"
        case "ny-playlist": "music.note.list"
        case "musik-i-oererne": "headphones"
        case "podcast-runner": "mic.fill"
        case "aldrig-give-op": "medal.fill"
        case "fejer-dig-selv": "party.popper.fill"
        case "hepperen": "megaphone.fill"
        case "loebemakker": "person.2.fill"
        case "loebedagbog": "book.fill"
        case "pakket-og-klar": "bag.fill"
        case "straek-stjerne": "figure.cooldown"
        case "soevn-samler": "moon.zzz.fill"
        case "vand-dronning": "drop.fill"
        default:
            switch ladder {
            case .runs, .intervals: "figure.run"
            case .sessionIntervals: "bolt.fill"
            case .continuousRun: "flame.fill"
            case .activeWeeks: "calendar"
            case .stars: "star.fill"
            case .none: "rosette"
            }
        }
    }

    /// Den danske kildetekst, pakket som lokaliserbar ressource. (Appen er
    /// dansk-først; teksten ligger i kataloget, ikke hardkodet i views.)
    var displayTitle: LocalizedStringResource {
        LocalizedStringResource(stringLiteral: definition.title)
    }

    var displayDetail: LocalizedStringResource {
        LocalizedStringResource(stringLiteral: definition.detail)
    }

    /// Bleg baggrundsfarve (bruges fx i forhåndsvisninger).
    var paletteBackground: Color { Color(badgeHex: definition.palette.hex.background) }
    /// Tekst-/forgrundsfarve for mærket.
    var paletteInk: Color { Color(badgeHex: definition.palette.hex.ink) }

    /// Livlig tema-gradient (top → bund) — bruges af de tematiske mærker.
    var gradientTop: Color { Color(badgeHex: definition.palette.vivid.top) }
    var gradientBottom: Color { Color(badgeHex: definition.palette.vivid.bottom) }

    /// Medaljens gradient-farver (top, bund). Milepæls-mærker (en stige) får et
    /// eskalerende metal-look à la Strava — bronze → sølv → guld → platin — så de
    /// ikke længere ligner hinanden. Tematiske mærker beholder deres tema-farve.
    var medalColors: [Color] {
        if let tier = milestoneTier {
            [Color(badgeHex: tier.top), Color(badgeHex: tier.bottom)]
        } else {
            [gradientTop, gradientBottom]
        }
    }

    /// Metal-trinnet for et milepæls-mærke ud fra dets tærskel, ellers `nil`.
    private var milestoneTier: (top: String, bottom: String)? {
        guard definition.ladder != nil, let threshold = milestoneThreshold else { return nil }
        return switch threshold {
        case ..<5: ("E8A86B", "B26A28") // bronze
        case 5..<15: ("DCE3EC", "97A2B2") // sølv
        case 15..<40: ("FFD964", "E0A018") // guld
        default: ("BDEBFF", "5FAAD8") // platin / diamant
        }
    }

    /// Tal-tærsklen bag en milepælsregel (fx 5 ture), ellers `nil`.
    private var milestoneThreshold: Int? {
        switch definition.rule {
        case let .totalWorkouts(n),
             let .streakWeeks(n),
             let .sessionsThisWeek(n),
             let .workoutsThisMonth(n),
             let .totalRunIntervals(n),
             let .runIntervalsInOneRun(n),
             let .longestContinuousRunMinutes(n),
             let .totalActiveWeeks(n),
             let .totalStars(n):
            n
        default:
            nil
        }
    }
}

extension BadgePalette {
    /// Konkrete farveværdier for paletten (RGB-hex som "EEEDFE").
    var hex: (background: String, ink: String) {
        switch self {
        case .purple: ("EEEDFE", "26215C")
        case .teal: ("E1F5EE", "085041")
        case .blue: ("E6F1FB", "042C53")
        case .green: ("EAF3DE", "173404")
        case .pink: ("FBEAF0", "4B1528")
        case .sand: ("FAEEDA", "412402")
        }
    }

    /// Mættede gradient-farver til de "rigtige" medaljer (top, bund).
    var vivid: (top: String, bottom: String) {
        switch self {
        case .purple: ("9B7BFF", "5B34D8")
        case .teal: ("2BD4B6", "0A8E78")
        case .blue: ("5AB4FF", "1E63DA")
        case .green: ("8FD94A", "3F9B2E")
        case .pink: ("FF7FB0", "E23B73")
        case .sand: ("FFC04A", "E8870F")
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
