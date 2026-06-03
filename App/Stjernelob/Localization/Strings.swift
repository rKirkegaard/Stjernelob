import Foundation

/// Alle brugervendte tekster ét sted, som `LocalizedStringResource`.
///
/// Views refererer til `Strings.…` i stedet for at indeholde danske strenge
/// direkte (jf. `.claude/rules/swift-style.md`: ingen hardcodede strenge i
/// views). `defaultValue` er den danske kildetekst og bruges, indtil et
/// String Catalog tilføjes for flere sprog. Tonen følger velbefindende-reglerne:
/// varm, opmuntrende, aldrig skyld eller pres.
enum Strings {
    enum App {
        static let name = LocalizedStringResource("app.name", defaultValue: "Stjerneløb")
    }

    enum Common {
        static let next = LocalizedStringResource("common.next", defaultValue: "Videre")
        static let start = LocalizedStringResource("common.start", defaultValue: "Kom i gang")
        static let save = LocalizedStringResource("common.save", defaultValue: "Gem")
        static let done = LocalizedStringResource("common.done", defaultValue: "Færdig")
        static let yes = LocalizedStringResource("common.yes", defaultValue: "Ja")
        static let no = LocalizedStringResource("common.no", defaultValue: "Nej")
    }

    enum Onboarding {
        static let welcomeTitle = LocalizedStringResource(
            "onboarding.welcome.title", defaultValue: "Velkommen til Stjerneløb")
        static let welcomeBody = LocalizedStringResource(
            "onboarding.welcome.body",
            defaultValue: "Vi tager den helt roligt og bygger dig op lidt ad gangen. Det handler om at have det sjovt og kunne mere — ikke om fart eller distance.")
        static let experienceTitle = LocalizedStringResource(
            "onboarding.experience.title", defaultValue: "Har du løbet før?")
        static let experienceNew = LocalizedStringResource(
            "onboarding.experience.new", defaultValue: "Nej, jeg er helt ny")
        static let experienceSome = LocalizedStringResource(
            "onboarding.experience.some", defaultValue: "Lidt")
        static let sessionsTitle = LocalizedStringResource(
            "onboarding.sessions.title", defaultValue: "Hvor mange ture har du tid til om ugen?")
        static let sessionsBody = LocalizedStringResource(
            "onboarding.sessions.body",
            defaultValue: "Du kan altid ændre det. At vælge få ture i en travl uge er et helt fint valg.")
        static let healthTitle = LocalizedStringResource(
            "onboarding.health.title", defaultValue: "Lige et par trygheds-spørgsmål")
        static let healthPain = LocalizedStringResource(
            "onboarding.health.pain", defaultValue: "Har du smerter eller en skade lige nu?")
        static let healthHeart = LocalizedStringResource(
            "onboarding.health.heart", defaultValue: "Har du en kendt hjerte- eller lungesygdom?")
        static let doctorAdvice = LocalizedStringResource(
            "onboarding.health.doctorAdvice",
            defaultValue: "Tal lige med din læge, før du går i gang — så er du på den sikre side. Appen er ikke lægefaglig rådgivning.")
    }

    enum Home {
        static let nextSessionTitle = LocalizedStringResource(
            "home.nextSession.title", defaultValue: "Din næste tur")
        static let startRun = LocalizedStringResource("home.startRun", defaultValue: "Start turen")
        static func streak(weeks: Int) -> LocalizedStringResource {
            LocalizedStringResource("home.streak", defaultValue: "\(weeks) ugers stime")
        }
        static func starsTotal(_ stars: Int) -> LocalizedStringResource {
            LocalizedStringResource("home.starsTotal", defaultValue: "\(stars) stjerner")
        }
        static func level(_ level: Int) -> LocalizedStringResource {
            LocalizedStringResource("home.level", defaultValue: "Niveau \(level)")
        }
        static let adjustWeek = LocalizedStringResource("home.adjustWeek", defaultValue: "Tilpas ugen")
    }

    enum ActiveRun {
        static let pause = LocalizedStringResource("activeRun.pause", defaultValue: "Pause")
        static let resume = LocalizedStringResource("activeRun.resume", defaultValue: "Fortsæt")
        static let stop = LocalizedStringResource("activeRun.stop", defaultValue: "Stop")
        static func intervalOfTotal(current: Int, total: Int) -> LocalizedStringResource {
            LocalizedStringResource("activeRun.intervalOfTotal", defaultValue: "Interval \(current) af \(total)")
        }
        static let elapsed = LocalizedStringResource("activeRun.elapsed", defaultValue: "Forløbet")
        static let distance = LocalizedStringResource("activeRun.distance", defaultValue: "Distance")
        static let pace = LocalizedStringResource("activeRun.pace", defaultValue: "Tempo")
    }

    enum Summary {
        static let title = LocalizedStringResource("summary.title", defaultValue: "Flot klaret!")
        static func stars(_ count: Int) -> LocalizedStringResource {
            LocalizedStringResource("summary.stars", defaultValue: "\(count) stjerner")
        }
        static let completed = LocalizedStringResource(
            "summary.completed", defaultValue: "Du gennemførte hele turen — sådan!")
        static let partial = LocalizedStringResource(
            "summary.partial", defaultValue: "Godt gået — hver tur tæller.")
        static let howDidItFeel = LocalizedStringResource(
            "summary.howDidItFeel", defaultValue: "Hvordan føltes det?")
        static let close = LocalizedStringResource("summary.close", defaultValue: "Luk")
        static let effortEasy = LocalizedStringResource("summary.effort.easy", defaultValue: "Let")
        static let effortHard = LocalizedStringResource("summary.effort.hard", defaultValue: "Hårdt")
    }

    enum RestDay {
        static let title = LocalizedStringResource("restDay.title", defaultValue: "Hviledag")
        static let body = LocalizedStringResource(
            "restDay.body",
            defaultValue: "Hviledag i dag — din krop bliver stærkere imens. Vi ses i morgen!")
    }

    enum Planner {
        static let title = LocalizedStringResource("planner.title", defaultValue: "Ugens plan")
        static let sessionsQuestion = LocalizedStringResource(
            "planner.sessionsQuestion", defaultValue: "Hvor mange ture i denne uge?")
        static func sessionsValue(_ count: Int) -> LocalizedStringResource {
            LocalizedStringResource("planner.sessionsValue", defaultValue: "\(count) ture")
        }
        static let suggestedDays = LocalizedStringResource(
            "planner.suggestedDays", defaultValue: "Forslag til dage")
        static let restDayNote = LocalizedStringResource(
            "planner.restDayNote", defaultValue: "Vi lægger altid en hviledag ind imellem — hvile er en del af træningen.")
    }

    enum Progress {
        static let title = LocalizedStringResource("progress.title", defaultValue: "Fremgang")
        static let listTab = LocalizedStringResource("progress.listTab", defaultValue: "Liste")
        static let calendarTab = LocalizedStringResource("progress.calendarTab", defaultValue: "Kalender")
        static let empty = LocalizedStringResource(
            "progress.empty", defaultValue: "Din første tur venter — den kommer her, når du er kommet afsted.")
        static func totalRuns(_ count: Int) -> LocalizedStringResource {
            LocalizedStringResource("progress.totalRuns", defaultValue: "\(count) gennemførte ture")
        }
        static let completedTag = LocalizedStringResource("progress.completedTag", defaultValue: "Gennemført")
        static let partialTag = LocalizedStringResource("progress.partialTag", defaultValue: "Påbegyndt")
        static func weekLabel(_ id: Int) -> LocalizedStringResource {
            LocalizedStringResource("progress.weekLabel", defaultValue: "Uge \(id) i forløbet")
        }
        static let durationLabel = LocalizedStringResource("progress.duration", defaultValue: "Varighed")
        static let intervalsLabel = LocalizedStringResource("progress.intervals", defaultValue: "Gennemførte intervaller")
        static let starsLabel = LocalizedStringResource("progress.stars", defaultValue: "Stjerner")
        static let effortLabel = LocalizedStringResource("progress.effort", defaultValue: "Sådan føltes det")
        static let photosLabel = LocalizedStringResource("progress.photos", defaultValue: "Billeder fra turen")
        static let noPhotos = LocalizedStringResource("progress.noPhotos", defaultValue: "Ingen billeder fra denne tur endnu.")
    }

    enum Badges {
        static let title = LocalizedStringResource("badges.title", defaultValue: "Samling")
        static let earnedSection = LocalizedStringResource("badges.earned", defaultValue: "Optjente mærker")
        static let lockedSection = LocalizedStringResource("badges.locked", defaultValue: "Endnu ikke låst op")
        static func levelProgress(into: Int, span: Int) -> LocalizedStringResource {
            LocalizedStringResource("badges.levelProgress", defaultValue: "\(into) / \(span) point til næste niveau")
        }
    }

    enum Dashboard {
        static let weeksRun = LocalizedStringResource("dashboard.weeksRun", defaultValue: "Ugens tur")
    }

    enum Interval {
        static let warmUp = LocalizedStringResource("interval.warmUp", defaultValue: "Opvarmning")
        static let run = LocalizedStringResource("interval.run", defaultValue: "Løb")
        static let walk = LocalizedStringResource("interval.walk", defaultValue: "Gå")
        static let coolDown = LocalizedStringResource("interval.coolDown", defaultValue: "Nedkøling")
    }

    /// Stemmecoachens replikker (afsnit 4.2). Varme, korte, opmuntrende — aldrig
    /// pres eller fart-fokus.
    enum Coaching {
        static func runStart(duration: String) -> LocalizedStringResource {
            LocalizedStringResource("coaching.runStart", defaultValue: "Løb nu i \(duration)")
        }
        static func walkStart(duration: String) -> LocalizedStringResource {
            LocalizedStringResource("coaching.walkStart", defaultValue: "Godt klaret — gå roligt i \(duration)")
        }
        static let warmUpStart = LocalizedStringResource(
            "coaching.warmUpStart", defaultValue: "Vi varmer op med en rask gåtur")
        static let coolDownStart = LocalizedStringResource(
            "coaching.coolDownStart", defaultValue: "Flot — så køler vi af med rolig gang")
        static let halfway = LocalizedStringResource(
            "coaching.halfway", defaultValue: "Du er halvvejs — flot!")
        static let finished = LocalizedStringResource(
            "coaching.finished", defaultValue: "Fantastisk — du gennemførte hele turen!")
        static let talkTest = LocalizedStringResource(
            "coaching.talkTest", defaultValue: "Husk: kan du ikke tale imens, så sæt lidt farten ned")
    }

    enum Units {
        /// "3 løbeintervaller · i alt 18 min"
        static func sessionSummary(runCount: Int, total: String) -> LocalizedStringResource {
            LocalizedStringResource(
                "units.sessionSummary",
                defaultValue: "\(runCount) løbeintervaller · i alt \(total)"
            )
        }
    }
}
