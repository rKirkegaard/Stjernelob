import Foundation

// Milepæls-mærker — tildeles automatisk ud fra historikken. De ligger i stiger,
// så samlingen kun viser det næste nære mål. Tilføj et trin ved at indsætte én
// linje i den relevante liste herunder.

extension BadgeCatalogue {
    static let milestoneBadges: [BadgeDefinition] =
        intervalBadges + sessionIntervalBadges + continuousRunBadges
            + runBadges + activeWeekBadges + starBadges

    // MARK: Løbeintervaller i alt (tæt stige, så der altid er et nært næste mål)

    private static let intervalBadges: [BadgeDefinition] = [
        interval(5, "5 intervaller", "Gennemfør 5 løbeintervaller i alt"),
        interval(10, "10 intervaller", "Gennemfør 10 løbeintervaller i alt"),
        interval(15, "15 intervaller", "15 løbeintervaller i alt — flot fremgang"),
        interval(20, "20 intervaller", "20 løbeintervaller gennemført"),
        interval(25, "25 intervaller", "Gennemfør 25 løbeintervaller i alt"),
        interval(30, "30 intervaller", "30 løbeintervaller i alt — det vokser støt"),
        interval(40, "40 intervaller", "40 løbeintervaller gennemført"),
        interval(50, "50 intervaller", "Halvtredseren — 50 løbeintervaller gennemført!"),
        interval(75, "75 intervaller", "75 løbeintervaller i alt"),
        interval(100, "100 intervaller", "Tre cifre! 100 løbeintervaller i alt 🎉"),
        interval(150, "150 intervaller", "150 løbeintervaller gennemført"),
        interval(200, "200 intervaller", "200 gange har du sagt ja til at løbe"),
        interval(300, "300 intervaller", "300 løbeintervaller i alt — sejt!"),
        interval(500, "500 intervaller", "500 intervaller. Det er ikke tilfældigt — det er dig."),
        interval(750, "750 intervaller", "750 løbeintervaller i alt"),
        interval(
            1000, "1000 intervaller",
            "Et helt tusinde! Du er officielt en interval-legende", secret: true
        ),
    ]

    // MARK: Løbeintervaller i én tur

    private static let sessionIntervalBadges: [BadgeDefinition] = [
        session(4, "4 i træk", "Gennemfør 4 løbeintervaller i samme tur"),
        session(6, "6 i træk", "Gennemfør 6 løbeintervaller i samme tur"),
        session(8, "8 i træk", "8 løbeintervaller i én og samme tur — kæmpe!"),
    ]

    // MARK: Sammenhængende løb (længste løb uden gå-pause)

    private static let continuousRunBadges: [BadgeDefinition] = [
        continuous(
            5,
            "🏃‍♀️",
            "5 minutter i træk",
            "Du løb 5 minutter uden en gå-pause. Stor milepæl!"
        ),
        continuous(
            10, "🏃‍♀️", "10 minutter i træk",
            "10 minutters sammenhængende løb — hold da op, godt gået!"
        ),
        continuous(
            20,
            "🔥",
            "20 minutter i træk",
            "20 minutter i ét stræk — et kæmpe spring fra dag ét!"
        ),
        continuous(
            30,
            "🌟",
            "30 minutter i træk",
            "En halv time i ét stræk. Det er stort, og det er dit."
        ),
    ]

    // MARK: Antal ture i alt

    private static let runBadges: [BadgeDefinition] = [
        runs(
            1,
            "1 tur",
            "Din allerførste løbetur — den sværeste af dem alle",
            category: .firstSteps
        ),
        runs(3, "3 ture", "3 ture i alt — vanen er ved at tage form"),
        runs(5, "5 ture", "5 ture klaret. High five!"),
        runs(10, "10 ture", "10 ture i alt. Du er løber nu."),
        runs(15, "15 ture", "15 gange er du kommet ud af døren"),
        runs(20, "20 ture", "20 ture — to fulde ugers indsats samlet op"),
        runs(25, "25 ture", "Et kvart hundrede ture. Ikke småting."),
        runs(30, "30 ture", "30 ture gennemført. Det er noget at fejre."),
        runs(40, "40 ture", "40 ture! Dine ben husker det her i søvne."),
        runs(50, "50 ture", "50 løbeture. Det er virkelig mange — og alle gennemført af dig."),
        runs(60, "60 ture", "60 løbeture gennemført"),
        runs(75, "75 ture", "75 ture — det er ikke en hobby, det er en del af dig"),
        runs(80, "80 ture", "80 løbeture — næsten ved hundrede"),
        runs(100, "100 ture", "100 løbeture. Tre cifre. Helt vildt.", secret: true),
    ]

    // MARK: Aktive uger (uger med mindst én tur)

    private static let activeWeekBadges: [BadgeDefinition] = [
        activeWeeks(1, "Første aktive uge", "Gennemfør mindst 1 tur i din første uge"),
        activeWeeks(2, "2 aktive uger", "To uger i træk med mindst én tur"),
        activeWeeks(4, "4 aktive uger", "En hel måneds aktive uger — du klarer det!"),
        activeWeeks(6, "6 aktive uger", "6 uger med løb. Det begynder at føles naturligt."),
        activeWeeks(8, "8 aktive uger", "2 måneders aktive uger — grundforløbet i hus!"),
        activeWeeks(10, "10 aktive uger", "10 uger med løb. Du har fundet en god rytme."),
        activeWeeks(12, "12 aktive uger", "3 måneder. Det er ikke en tilfældighed."),
        activeWeeks(16, "16 aktive uger", "4 måneder med aktive løbeuger. Imponerende."),
        activeWeeks(20, "20 aktive uger", "Hele programmet i aktive uger. Du gennemførte det!"),
        activeWeeks(
            26,
            "Et halvt år",
            "26 aktive uger — et halvt år som løber",
            category: .special
        ),
        activeWeeks(
            52, "Et helt år", "52 aktive uger. Et helt år som løber. Legendarisk.",
            category: .special, secret: true
        ),
    ]

    // MARK: Samlet antal stjerner

    private static let starBadges: [BadgeDefinition] = [
        stars(10, "⭐️", "10 stjerner", "Optjen 10 stjerner i alt"),
        stars(25, "⭐️", "25 stjerner", "25 stjerner på kontoen"),
        stars(50, "⭐️", "50 stjerner", "50 stjerner — du funkler!"),
        stars(100, "⭐️", "100 stjerner", "Et hundrede stjerner. Himlen er fuld af dem."),
        stars(250, "🌠", "250 stjerner", "250 stjerner optjent — du er et stjerneskud"),
        stars(500, "💫", "500 stjerner", "500 stjerner. Der er ikke ord for det."),
        stars(
            1000, "🌟", "1000 stjerner", "Et tusinde stjerner. Du ER Stjerneløb.",
            category: .special, secret: true
        ),
    ]

    // MARK: - Stige-konstruktører (hold definitionerne korte og ensartede)

    private static func interval(
        _ count: Int, _ title: String, _ detail: String, secret: Bool = false
    ) -> BadgeDefinition {
        BadgeDefinition(
            slug: "interval-\(count)", category: .consistency, palette: .teal,
            emoji: count >= 100 ? "🏅" : "👟", isSecret: secret, ladder: .intervals,
            title: title, detail: detail, rule: .totalRunIntervals(count)
        )
    }

    private static func session(
        _ count: Int,
        _ title: String,
        _ detail: String
    ) -> BadgeDefinition {
        BadgeDefinition(
            slug: "session-\(count)-intervaller", category: .consistency, palette: .teal,
            emoji: "⚡", ladder: .sessionIntervals,
            title: title, detail: detail, rule: .runIntervalsInOneRun(count)
        )
    }

    private static func continuous(
        _ minutes: Int, _ emoji: String, _ title: String, _ detail: String
    ) -> BadgeDefinition {
        BadgeDefinition(
            slug: "uafbrudt-\(minutes)", category: .consistency, palette: .teal,
            emoji: emoji, ladder: .continuousRun,
            title: title, detail: detail, rule: .longestContinuousRunMinutes(minutes)
        )
    }

    private static func runs(
        _ count: Int, _ title: String, _ detail: String,
        category: BadgeCategory = .consistency, secret: Bool = false
    ) -> BadgeDefinition {
        BadgeDefinition(
            slug: "tur-\(count)", category: category, palette: .purple,
            emoji: count >= 100 ? "🏆" : "🏃", isSecret: secret, ladder: .runs,
            title: title, detail: detail, rule: .totalWorkouts(count)
        )
    }

    private static func activeWeeks(
        _ count: Int, _ title: String, _ detail: String,
        category: BadgeCategory = .consistency, secret: Bool = false
    ) -> BadgeDefinition {
        let emoji = count >= 52 ? "🥇" : (count >= 20 ? "🌟" : "📆")
        return BadgeDefinition(
            slug: "aktiv-uge-\(count)", category: category, palette: .blue,
            emoji: emoji, isSecret: secret, ladder: .activeWeeks,
            title: title, detail: detail, rule: .totalActiveWeeks(count)
        )
    }

    private static func stars(
        _ count: Int, _ emoji: String, _ title: String, _ detail: String,
        category: BadgeCategory = .consistency, secret: Bool = false
    ) -> BadgeDefinition {
        BadgeDefinition(
            slug: "stjerner-\(count)", category: category, palette: .sand,
            emoji: emoji, isSecret: secret, ladder: .stars,
            title: title, detail: detail, rule: .totalStars(count)
        )
    }
}
