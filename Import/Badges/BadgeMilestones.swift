import Foundation

// MARK: - Extended BadgeTrigger cases

// Add these to the existing BadgeTrigger enum in Badge.swift

/*
 New trigger cases to append to BadgeTrigger:

 // Interval milestones (total intervals completed across all sessions)
 case totalIntervals(count: Int)

 // Session (tur) milestones
 case totalSessions(count: Int)

 // Active week milestones (weeks where ≥1 session was completed)
 case totalActiveWeeks(count: Int)

 // Total stars earned
 case totalStars(count: Int)

 // Consecutive intervals in a single session without stopping
 case intervalsInOneSession(count: Int)
 */

// MARK: - Milestone Badge Definitions (40 new badges)

extension BadgeCatalogue {
    static let milestoneBadges: [Badge] = [
        // ─────────────────────────────────────────
        // MARK: Interval-milepæle (total intervaller på tværs af alle ture)

        // ─────────────────────────────────────────

        Badge(
            slug: "interval-5",
            name: "5 intervaller",
            description: "Gennemfør 5 løbeintervaller i alt",
            category: .consistency,
            trigger: .totalIntervals(count: 5)
        ),

        Badge(
            slug: "interval-10",
            name: "10 intervaller",
            description: "Gennemfør 10 løbeintervaller i alt",
            category: .consistency,
            trigger: .totalIntervals(count: 10)
        ),

        Badge(
            slug: "interval-25",
            name: "25 intervaller",
            description: "Gennemfør 25 løbeintervaller i alt",
            category: .consistency,
            trigger: .totalIntervals(count: 25)
        ),

        Badge(
            slug: "interval-50",
            name: "50 intervaller",
            description: "Halvtredseren — 50 løbeintervaller gennemført!",
            category: .consistency,
            trigger: .totalIntervals(count: 50)
        ),

        Badge(
            slug: "interval-100",
            name: "100 intervaller",
            description: "Tre cifre! 100 løbeintervaller i alt 🎉",
            category: .consistency,
            trigger: .totalIntervals(count: 100)
        ),

        Badge(
            slug: "interval-200",
            name: "200 intervaller",
            description: "200 gange har du sagt ja til at løbe",
            category: .consistency,
            trigger: .totalIntervals(count: 200)
        ),

        Badge(
            slug: "interval-500",
            name: "500 intervaller",
            description: "500 intervaller. Det er ikke tilfældigt — det er dig.",
            category: .consistency,
            trigger: .totalIntervals(count: 500)
        ),

        Badge(
            slug: "interval-1000",
            name: "1000 intervaller",
            description: "Et helt tusinde! Du er officielt en interval-legende",
            category: .consistency,
            trigger: .totalIntervals(count: 1000)
        ),

        // Intervaller i én session
        Badge(
            slug: "session-4-intervaller",
            name: "4 i træk",
            description: "Gennemfør 4 løbeintervaller i samme tur",
            category: .consistency,
            trigger: .intervalsInOneSession(count: 4)
        ),

        Badge(
            slug: "session-6-intervaller",
            name: "6 i træk",
            description: "Gennemfør 6 løbeintervaller i samme tur",
            category: .consistency,
            trigger: .intervalsInOneSession(count: 6)
        ),

        Badge(
            slug: "session-8-intervaller",
            name: "8 i træk",
            description: "8 løbeintervaller i én og samme tur — kæmpe!",
            category: .consistency,
            trigger: .intervalsInOneSession(count: 8)
        ),

        // ─────────────────────────────────────────
        // MARK: Løbeture-milepæle (antal ture i alt)

        // ─────────────────────────────────────────

        Badge(
            slug: "tur-1",
            name: "1 tur",
            description: "Din allerførste løbetur — den sværeste af dem alle",
            category: .firstSteps,
            trigger: .totalSessions(count: 1)
        ),

        Badge(
            slug: "tur-3",
            name: "3 ture",
            description: "3 ture i alt — vanen er ved at tage form",
            category: .consistency,
            trigger: .totalSessions(count: 3)
        ),

        Badge(
            slug: "tur-5",
            name: "5 ture",
            description: "5 ture klaret. High five! 🖐️",
            category: .consistency,
            trigger: .totalSessions(count: 5)
        ),

        Badge(
            slug: "tur-10",
            name: "10 ture",
            description: "10 ture i alt. Du er løber nu.",
            category: .consistency,
            trigger: .totalSessions(count: 10)
        ),

        Badge(
            slug: "tur-15",
            name: "15 ture",
            description: "15 gange er du kommet ud af døren",
            category: .consistency,
            trigger: .totalSessions(count: 15)
        ),

        Badge(
            slug: "tur-20",
            name: "20 ture",
            description: "20 ture — to fulde ugers indsats samlet op",
            category: .consistency,
            trigger: .totalSessions(count: 20)
        ),

        Badge(
            slug: "tur-25",
            name: "25 ture",
            description: "Et kvart hundrede ture. Ikke småting.",
            category: .consistency,
            trigger: .totalSessions(count: 25)
        ),

        Badge(
            slug: "tur-30",
            name: "30 ture",
            description: "30 ture gennemført. Du ved hvad du er lavet af.",
            category: .consistency,
            trigger: .totalSessions(count: 30)
        ),

        Badge(
            slug: "tur-40",
            name: "40 ture",
            description: "40 ture! Dine ben husker det her i søvne.",
            category: .consistency,
            trigger: .totalSessions(count: 40)
        ),

        Badge(
            slug: "tur-50",
            name: "50 ture",
            description: "50 løbeture. Halvtreds gange har du valgt dig selv.",
            category: .consistency,
            trigger: .totalSessions(count: 50)
        ),

        Badge(
            slug: "tur-75",
            name: "75 ture",
            description: "75 ture — det er ikke en hobby, det er en del af dig",
            category: .consistency,
            trigger: .totalSessions(count: 75)
        ),

        Badge(
            slug: "tur-100",
            name: "100 ture",
            description: "100 løbeture. Tre cifre. Helt vildt. 🏆",
            category: .consistency,
            trigger: .totalSessions(count: 100)
        ),

        // ─────────────────────────────────────────
        // MARK: Aktive uger (uger med mindst 1 tur)

        // ─────────────────────────────────────────

        Badge(
            slug: "aktiv-uge-1",
            name: "Første aktive uge",
            description: "Gennemfør mindst 1 tur i din første uge",
            category: .consistency,
            trigger: .totalActiveWeeks(count: 1)
        ),

        Badge(
            slug: "aktiv-uge-2",
            name: "2 aktive uger",
            description: "To uger i træk med mindst én tur",
            category: .consistency,
            trigger: .totalActiveWeeks(count: 2)
        ),

        Badge(
            slug: "aktiv-uge-4",
            name: "4 aktive uger",
            description: "En hel måneds aktive uger — du klarer det!",
            category: .consistency,
            trigger: .totalActiveWeeks(count: 4)
        ),

        Badge(
            slug: "aktiv-uge-6",
            name: "6 aktive uger",
            description: "6 uger. Kroppen er begyndt at forvente det her.",
            category: .consistency,
            trigger: .totalActiveWeeks(count: 6)
        ),

        Badge(
            slug: "aktiv-uge-8",
            name: "8 aktive uger",
            description: "2 måneders aktive uger — grundforløbet i hus!",
            category: .consistency,
            trigger: .totalActiveWeeks(count: 8)
        ),

        Badge(
            slug: "aktiv-uge-10",
            name: "10 aktive uger",
            description: "10 uger med løb. Du er langt fra den sofa nu.",
            category: .consistency,
            trigger: .totalActiveWeeks(count: 10)
        ),

        Badge(
            slug: "aktiv-uge-12",
            name: "12 aktive uger",
            description: "3 måneder. Det er ikke en tilfældighed.",
            category: .consistency,
            trigger: .totalActiveWeeks(count: 12)
        ),

        Badge(
            slug: "aktiv-uge-16",
            name: "16 aktive uger",
            description: "4 måneder med aktive løbeuger. Imponerende.",
            category: .consistency,
            trigger: .totalActiveWeeks(count: 16)
        ),

        Badge(
            slug: "aktiv-uge-20",
            name: "20 aktive uger",
            description: "Hele programmet i aktive uger. Du gennemførte det! 🌟",
            category: .consistency,
            trigger: .totalActiveWeeks(count: 20)
        ),

        Badge(
            slug: "aktiv-uge-26",
            name: "Et halvt år",
            description: "26 aktive uger — et halvt år som løber",
            category: .special,
            trigger: .totalActiveWeeks(count: 26)
        ),

        Badge(
            slug: "aktiv-uge-52",
            name: "Et helt år",
            description: "52 aktive uger. Et helt år som løber. Legendarisk. 🥇",
            category: .special,
            trigger: .totalActiveWeeks(count: 52),
            isSecret: true
        ),

        // ─────────────────────────────────────────
        // MARK: Stjerne-milepæle (samlet antal stjerner)

        // ─────────────────────────────────────────

        Badge(
            slug: "stjerner-10",
            name: "10 stjerner",
            description: "Optjen 10 stjerner i alt",
            category: .consistency,
            trigger: .totalStars(count: 10)
        ),

        Badge(
            slug: "stjerner-25",
            name: "25 stjerner",
            description: "25 stjerner på kontoen",
            category: .consistency,
            trigger: .totalStars(count: 25)
        ),

        Badge(
            slug: "stjerner-50",
            name: "50 stjerner",
            description: "50 stjerner — du funkler! ✨",
            category: .consistency,
            trigger: .totalStars(count: 50)
        ),

        Badge(
            slug: "stjerner-100",
            name: "100 stjerner",
            description: "Et hundrede stjerner. Himlen er fuld af dem.",
            category: .consistency,
            trigger: .totalStars(count: 100)
        ),

        Badge(
            slug: "stjerner-250",
            name: "250 stjerner",
            description: "250 stjerner optjent — du er et stjerneskud 🌠",
            category: .consistency,
            trigger: .totalStars(count: 250)
        ),

        Badge(
            slug: "stjerner-500",
            name: "500 stjerner",
            description: "500 stjerner. Der er ikke ord for det.",
            category: .consistency,
            trigger: .totalStars(count: 500),
            isSecret: true
        ),

        Badge(
            slug: "stjerner-1000",
            name: "1000 stjerner",
            description: "Et tusinde stjerner. Du ER Stjerneløb. 🌟",
            category: .special,
            trigger: .totalStars(count: 1000),
            isSecret: true
        ),
    ]
}

// MARK: - Updated BadgeTrigger (full enum inkl. nye cases)

// Tilføj disse cases til den eksisterende BadgeTrigger enum i Badge.swift:

/*

 // I BadgeTrigger enum — tilføj:

 case totalIntervals(count: Int)
 // Samlet antal løbeintervaller gennemført på tværs af alle ture

 case totalSessions(count: Int)
 // Samlet antal ture (sessions) gennemført

 case totalActiveWeeks(count: Int)
 // Antal uger med mindst 1 gennemført tur

 case totalStars(count: Int)
 // Samlet antal stjerner optjent

 case intervalsInOneSession(count: Int)
 // Antal løbeintervaller gennemført i én og samme tur

 */

// MARK: - BadgeEngine udvidelse (nye trigger cases)

// Tilføj disse cases til isTriggerMet() i BadgeEngine.swift:

/*

 case .totalIntervals(let count):
     return progress.totalIntervalsCompleted >= count

 case .totalSessions(let count):
     return progress.totalSessionsCompleted >= count

 case .totalActiveWeeks(let count):
     return progress.totalActiveWeeks >= count

 case .totalStars(let count):
     return progress.totalStarsEarned >= count

 case .intervalsInOneSession(let count):
     return session.intervalsCompleted >= count

 */

// MARK: - UserProgress udvidelse

// Tilføj disse computed properties til UserProgress i BadgeEngine.swift:

/*

 /// Samlet antal løbeintervaller på tværs af alle ture
 var totalIntervalsCompleted: Int {
     completedSessions.reduce(0) { $0 + $1.intervalsCompleted }
 }

 /// Antal uger med mindst 1 gennemført tur
 var totalActiveWeeks: Int {
     let weekSet = Set(completedSessions.map { session -> String in
         let cal = Calendar(identifier: .iso8601)
         let week = cal.component(.weekOfYear, from: session.startedAt)
         let year = cal.component(.yearForWeekOfYear, from: session.startedAt)
         return "\(year)-W\(week)"
     })
     return weekSet.count
 }

 /// Samlet antal stjerner optjent
 var totalStarsEarned: Int {
     completedSessions.reduce(0) { $0 + $1.starsEarned }
 }

 */

// MARK: - CompletedSession udvidelse

// Tilføj dette felt til CompletedSession:

/*

 var intervalsCompleted: Int
 // Antal løbeintervaller der faktisk blev gennemført i denne tur
 // (kan være færre end planlagt hvis turen blev afbrudt)

 */
