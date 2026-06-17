import Foundation

/// De fire årstider, som årstids-mærker knyttes til. Holdt som data (måneder),
/// så reglen kan udtrykkes deklarativt i kataloget uden kode.
public enum Season: String, Codable, Sendable, CaseIterable {
    case spring, summer, autumn, winter

    /// Månederne (1-12), årstiden dækker på den nordlige halvkugle.
    public var months: [Int] {
        switch self {
        case .spring: [3, 4, 5]
        case .summer: [6, 7, 8]
        case .autumn: [9, 10, 11]
        case .winter: [12, 1, 2]
        }
    }
}

/// Betingelsen for at optjene et badge, udtrykt som ren data.
///
/// En udvikler tilføjer et nyt badge ved at vælge en regel her (ingen
/// `switch`-redigering andre steder). Reglerne vurderes generisk mod en
/// `BadgeContext` i `isSatisfied(by:)`. Tæller altid fremmøde og handlinger —
/// aldrig fart, distance eller vægt (jf. velbefindende-reglerne).
public enum BadgeRule: Sendable, Equatable, Hashable {
    /// Tildeles aldrig automatisk — barnet låser selv op i appen.
    case manual
    /// Mindst N gennemførte (eller påbegyndte) ture i alt.
    case totalWorkouts(Int)
    /// Aktuel ugentlig stime på mindst N uger.
    case streakWeeks(Int)
    /// Mindst N ture i indeværende træningsuge.
    case sessionsThisWeek(Int)
    /// Mindst N ture i indeværende kalendermåned.
    case workoutsThisMonth(Int)
    /// Har gennemført mindst én hel tur (ikke afbrudt).
    case completedFullRun
    /// Har gennemført en tur, hun selv markerede som hård — og blev ved.
    case completedHardRun
    /// Turen blev startet om morgenen / aftenen.
    case startedInMorning
    case startedInEvening
    /// Tog mindst ét billede undervejs.
    case tookPhoto
    /// Tilbage efter en pause på en uge eller mere.
    case comeback
    /// Turen faldt i en bestemt årstid.
    case season(Season)
    /// Turen faldt i en bestemt måned inden for et dag-interval (fx jul).
    case dateInMonth(month: Int, days: ClosedRange<Int>)
    /// Mindst N gennemførte løbeintervaller i alt på tværs af alle ture.
    case totalRunIntervals(Int)
    /// Mindst N løbeintervaller i én og samme tur.
    case runIntervalsInOneRun(Int)
    /// Det længste sammenhængende løb (uden gå-pause) på mindst N minutter.
    case longestContinuousRunMinutes(Int)
    /// Mindst N kalenderuger med mindst én tur.
    case totalActiveWeeks(Int)
    /// Mindst N optjente stjerner i alt.
    case totalStars(Int)
    /// Strakte ud efter mindst én tur (et lille, valgfrit ja).
    case didStretch
    /// Huskede vand før og efter mindst én tur (et lille, valgfrit ja).
    case didDrinkWater
    /// Opfyldt, hvis mindst én af de angivne regler er opfyldt.
    indirect case anyOf([BadgeRule])

    /// Afgør, om reglen er opfyldt for en given kontekst. Ren funktion uden
    /// tilstand, så den kan testes isoleret.
    public func isSatisfied(by context: BadgeContext) -> Bool {
        switch self {
        case .manual: false
        case let .totalWorkouts(n): context.totalCompletedWorkouts >= n
        case let .streakWeeks(n): context.currentStreakWeeks >= n
        case let .sessionsThisWeek(n): context.sessionsThisWeek >= n
        case let .workoutsThisMonth(n): context.workoutsThisMonth >= n
        case .completedFullRun: context.hasCompletedFullRun
        case .completedHardRun: context.hasCompletedHardRun
        case .startedInMorning: context.startedInMorning
        case .startedInEvening: context.startedInEvening
        case .tookPhoto: context.tookPhoto
        case .comeback: context.isComeback
        case let .season(season): season.months.contains(context.month)
        case let .dateInMonth(month, days): context.month == month && days.contains(context.day)
        case let .totalRunIntervals(n): context.totalRunIntervals >= n
        case let .runIntervalsInOneRun(n): context.maxRunIntervalsInOneRun >= n
        case let .longestContinuousRunMinutes(n): context.longestContinuousRunMinutes >= n
        case let .totalActiveWeeks(n): context.totalActiveWeeks >= n
        case let .totalStars(n): context.totalStars >= n
        case .didStretch: context.didStretchAfterRun
        case .didDrinkWater: context.didDrinkWaterBeforeAndAfter
        case let .anyOf(rules): rules.contains { $0.isSatisfied(by: context) }
        }
    }
}
