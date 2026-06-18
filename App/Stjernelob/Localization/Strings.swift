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
            "onboarding.welcome.title", defaultValue: "Velkommen til Stjerneløb"
        )
        static let welcomeBody = LocalizedStringResource(
            "onboarding.welcome.body",
            defaultValue: "Vi tager den helt roligt og bygger dig op lidt ad gangen. Det handler om at have det sjovt og kunne mere — ikke om fart eller distance."
        )
        static let experienceTitle = LocalizedStringResource(
            "onboarding.experience.title", defaultValue: "Har du løbet før?"
        )
        static let experienceNew = LocalizedStringResource(
            "onboarding.experience.new", defaultValue: "Nej, jeg er helt ny"
        )
        static let experienceSome = LocalizedStringResource(
            "onboarding.experience.some", defaultValue: "Lidt"
        )
        static let sessionsTitle = LocalizedStringResource(
            "onboarding.sessions.title", defaultValue: "Hvor mange ture har du tid til om ugen?"
        )
        static let sessionsBody = LocalizedStringResource(
            "onboarding.sessions.body",
            defaultValue: "Du kan altid ændre det. At vælge få ture i en travl uge er et helt fint valg."
        )
        static let healthTitle = LocalizedStringResource(
            "onboarding.health.title", defaultValue: "Lige et par trygheds-spørgsmål"
        )
        static let healthPain = LocalizedStringResource(
            "onboarding.health.pain", defaultValue: "Har du smerter eller en skade lige nu?"
        )
        static let healthHeart = LocalizedStringResource(
            "onboarding.health.heart", defaultValue: "Har du en kendt hjerte- eller lungesygdom?"
        )
        static let doctorAdvice = LocalizedStringResource(
            "onboarding.health.doctorAdvice",
            defaultValue: "Tal lige med din læge, før du går i gang — så er du på den sikre side. Appen er ikke lægefaglig rådgivning."
        )
        static let methodTitle = LocalizedStringResource(
            "onboarding.method.title", defaultValue: "Hvor stærkt skal jeg løbe?"
        )
        static let methodBody = LocalizedStringResource(
            "onboarding.method.body",
            defaultValue: "Du løber efter tid — ikke fart. Vælg et roligt tempo, du kan holde hele intervallet ud; løb aldrig hurtigere, end du kan klare tiden. Et godt tjek: kan du stadig tale i hele sætninger imens?"
        )
    }

    enum Home {
        static let nextSessionTitle = LocalizedStringResource(
            "home.nextSession.title", defaultValue: "Din næste tur"
        )
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

        static let adjustWeek = LocalizedStringResource(
            "home.adjustWeek",
            defaultValue: "Tilpas ugen"
        )
    }

    enum ActiveRun {
        static let pause = LocalizedStringResource("activeRun.pause", defaultValue: "Pause")
        static let resume = LocalizedStringResource("activeRun.resume", defaultValue: "Fortsæt")
        static let stop = LocalizedStringResource("activeRun.stop", defaultValue: "Stop")
        static func intervalOfTotal(current: Int, total: Int) -> LocalizedStringResource {
            LocalizedStringResource(
                "activeRun.intervalOfTotal",
                defaultValue: "Interval \(current) af \(total)"
            )
        }

        static let elapsed = LocalizedStringResource("activeRun.elapsed", defaultValue: "Forløbet")
        static let talkTestHint = LocalizedStringResource(
            "activeRun.talkTestHint", defaultValue: "Hold et tempo, du kan klare hele intervallet"
        )
        static let resumeTitle = LocalizedStringResource(
            "activeRun.resumeTitle",
            defaultValue: "Genoptag din tur?"
        )
        static let resumeBody = LocalizedStringResource(
            "activeRun.resumeBody",
            defaultValue: "Du har en tur i gang. Vil du fortsætte, hvor du slap?"
        )
        static let resumeYes = LocalizedStringResource(
            "activeRun.resumeYes",
            defaultValue: "Genoptag"
        )
        static let discard = LocalizedStringResource(
            "activeRun.discard",
            defaultValue: "Afslut turen"
        )
        static let distance = LocalizedStringResource(
            "activeRun.distance",
            defaultValue: "Distance"
        )
        static let pace = LocalizedStringResource("activeRun.pace", defaultValue: "Tempo")

        /// Justering af det aktuelle interval ved at trække på timeren.
        static let adjustHint = LocalizedStringResource(
            "activeRun.adjustHint",
            defaultValue: "Træk på uret for at gøre intervallet længere eller kortere"
        )
        static func longerBy(seconds: Int) -> LocalizedStringResource {
            LocalizedStringResource("activeRun.longerBy", defaultValue: "+\(seconds) sek")
        }

        static func shorterBy(seconds: Int) -> LocalizedStringResource {
            LocalizedStringResource("activeRun.shorterBy", defaultValue: "−\(seconds) sek")
        }
    }

    /// Selvvalgt sværhedsgrad (skalerer turen).
    enum Difficulty {
        static let section = LocalizedStringResource(
            "difficulty.section", defaultValue: "Sværhedsgrad"
        )
        static let lighter = LocalizedStringResource(
            "difficulty.lighter", defaultValue: "Roligere"
        )
        static let standard = LocalizedStringResource(
            "difficulty.standard", defaultValue: "Normal"
        )
        static let harder = LocalizedStringResource(
            "difficulty.harder", defaultValue: "Udfordrende"
        )
        static let note = LocalizedStringResource(
            "difficulty.note",
            defaultValue: "Tilpas turen til, hvordan du har det i dag — roligere er lige så godt et valg som mere udfordrende, og du kan altid skrue ned igen. Det handler om tid, aldrig om fart, og opvarmning og hvile røres aldrig."
        )
    }

    /// Valg af startpunkt i forløbet (onboarding + indstillinger).
    enum StartingPoint {
        static let title = LocalizedStringResource(
            "startingPoint.title", defaultValue: "Startpunkt"
        )
        static let onboardingQuestion = LocalizedStringResource(
            "startingPoint.onboardingQuestion", defaultValue: "Hvor vil du starte?"
        )
        static let note = LocalizedStringResource(
            "startingPoint.note",
            defaultValue: "De fleste starter forfra. Har du løbet lidt før, kan du starte længere inde — vælg det niveau, der føles rigtigt. Du kan altid ændre det igen."
        )
        static func week(_ number: Int) -> LocalizedStringResource {
            LocalizedStringResource("startingPoint.week", defaultValue: "Uge \(number)")
        }

        static func runWalk(run: String, walk: String) -> LocalizedStringResource {
            LocalizedStringResource(
                "startingPoint.runWalk", defaultValue: "Løb \(run) · gå \(walk)"
            )
        }

        static let settingsRow = LocalizedStringResource(
            "startingPoint.settingsRow", defaultValue: "Skift startpunkt i forløbet"
        )
    }

    enum Launch {
        static let go = LocalizedStringResource("launch.go", defaultValue: "GO")
        static let tagline = LocalizedStringResource(
            "launch.tagline", defaultValue: "Klar, parat …"
        )
    }

    enum Summary {
        static let title = LocalizedStringResource("summary.title", defaultValue: "Flot klaret!")
        static func stars(_ count: Int) -> LocalizedStringResource {
            LocalizedStringResource("summary.stars", defaultValue: "\(count) stjerner")
        }

        static let completed = LocalizedStringResource(
            "summary.completed", defaultValue: "Du gennemførte hele turen — sådan!"
        )
        static let partial = LocalizedStringResource(
            "summary.partial", defaultValue: "Godt gået — hver tur tæller."
        )
        static let howDidItFeel = LocalizedStringResource(
            "summary.howDidItFeel", defaultValue: "Hvordan føltes det?"
        )
        static let close = LocalizedStringResource("summary.close", defaultValue: "Luk")
        static let effortEasy = LocalizedStringResource("summary.effort.easy", defaultValue: "Let")
        static let effortHard = LocalizedStringResource(
            "summary.effort.hard",
            defaultValue: "Hårdt"
        )

        /// Kropssignal efter turen (skadesforebyggelse).
        static let bodyQuestion = LocalizedStringResource(
            "summary.bodyQuestion", defaultValue: "Mærker du noget særligt i kroppen?"
        )
        static let bodyAllGood = LocalizedStringResource(
            "summary.body.allGood", defaultValue: "Alt føles godt"
        )
        static let bodyGoodSore = LocalizedStringResource(
            "summary.body.goodSore", defaultValue: "Lidt øm — på den gode måde"
        )
        static let bodySpecificPain = LocalizedStringResource(
            "summary.body.specificPain", defaultValue: "En specifik smerte et sted"
        )
        static let careTitle = LocalizedStringResource(
            "summary.careTitle", defaultValue: "Pas godt på dig selv"
        )
        static let careBody = LocalizedStringResource(
            "summary.careBody",
            defaultValue: "Hold øje med smerten, og tag gerne en ekstra hviledag. Hvis den bliver ved eller gør ondt, mens du løber, så tal med en voksen eller din læge — det er aldrig dumt at spørge."
        )

        /// Lille refleksion efter turen (valgfri, motiverende).
        static let reflectionPrompt = LocalizedStringResource(
            "summary.reflectionPrompt", defaultValue: "Hvad gik bedre end sidst? (valgfrit)"
        )
        static let reflectionPlaceholder = LocalizedStringResource(
            "summary.reflectionPlaceholder", defaultValue: "En lille ting, du er glad for …"
        )

        /// Små, valgfrie gode vaner efter turen (grundlag for vane-mærker).
        /// Helt frivilligt — et ubesvaret spørgsmål tæller aldrig imod dig.
        static let habitsTitle = LocalizedStringResource(
            "summary.habitsTitle", defaultValue: "Små gode vaner (valgfrit)"
        )
        static let stretchedToggle = LocalizedStringResource(
            "summary.stretchedToggle", defaultValue: "Jeg strakte ud bagefter"
        )
        static let waterToggle = LocalizedStringResource(
            "summary.waterToggle", defaultValue: "Jeg huskede vand før og efter"
        )
    }

    enum RestDay {
        static let title = LocalizedStringResource("restDay.title", defaultValue: "Hviledag")
        static let body = LocalizedStringResource(
            "restDay.body",
            defaultValue: "Hviledag i dag — din krop bliver stærkere imens. Vi ses i morgen!"
        )
        static let activeRecoveryTitle = LocalizedStringResource(
            "restDay.activeRecoveryTitle", defaultValue: "Har du lyst til lidt let bevægelse?"
        )
        static let activeRecoveryNote = LocalizedStringResource(
            "restDay.activeRecoveryNote",
            defaultValue: "Helt frivilligt — at slappe helt af er også perfekt."
        )
        static let recoveryWalk = LocalizedStringResource(
            "restDay.recovery.walk",
            defaultValue: "En rolig gåtur"
        )
        static let recoveryStretch = LocalizedStringResource(
            "restDay.recovery.stretch",
            defaultValue: "Lidt blid udstrækning"
        )
        static let recoverySwim = LocalizedStringResource(
            "restDay.recovery.swim",
            defaultValue: "En tur i svømmehallen"
        )
        static let recoveryDance = LocalizedStringResource(
            "restDay.recovery.dance",
            defaultValue: "Dans til din yndlingsmusik"
        )
        static let recoveryBike = LocalizedStringResource(
            "restDay.recovery.bike",
            defaultValue: "En afslappet cykeltur"
        )
        static let recoveryPlay = LocalizedStringResource(
            "restDay.recovery.play",
            defaultValue: "Leg eller boldspil med en ven"
        )
    }

    /// Opvarmnings- og nedkølingsguide under turen (skadesforebyggelse).
    enum Guide {
        static let warmUpTitle = LocalizedStringResource(
            "guide.warmUpTitle",
            defaultValue: "Varm op imens"
        )
        static let coolDownTitle = LocalizedStringResource(
            "guide.coolDownTitle",
            defaultValue: "Køl af imens"
        )
        static let warmUpBrisk = LocalizedStringResource(
            "guide.warmUp.brisk",
            defaultValue: "Gå rask til"
        )
        static let warmUpKnees = LocalizedStringResource(
            "guide.warmUp.knees",
            defaultValue: "Løft knæene lidt højt nogle gange"
        )
        static let warmUpAnkles = LocalizedStringResource(
            "guide.warmUp.ankles",
            defaultValue: "Rul med anklerne og svaj med armene"
        )
        static let coolDownWalk = LocalizedStringResource(
            "guide.coolDown.walk",
            defaultValue: "Gå roligt og træk vejret dybt"
        )
        static let coolDownThighs = LocalizedStringResource(
            "guide.coolDown.thighs",
            defaultValue: "Stræk forsigtigt lår og læg"
        )
        static let coolDownShake = LocalizedStringResource(
            "guide.coolDown.shake",
            defaultValue: "Ryst benene løse og slap af i skuldrene"
        )
    }

    enum Planner {
        static let title = LocalizedStringResource("planner.title", defaultValue: "Ugens plan")
        static let sessionsQuestion = LocalizedStringResource(
            "planner.sessionsQuestion", defaultValue: "Hvor mange ture i denne uge?"
        )
        static func sessionsValue(_ count: Int) -> LocalizedStringResource {
            LocalizedStringResource("planner.sessionsValue", defaultValue: "\(count) ture")
        }

        static let suggestedDays = LocalizedStringResource(
            "planner.suggestedDays", defaultValue: "Forslag til dage"
        )
        static let restDayNote = LocalizedStringResource(
            "planner.restDayNote",
            defaultValue: "Vi lægger altid en hviledag ind imellem — hvile er en del af træningen."
        )

        static let chooseDays = LocalizedStringResource(
            "planner.chooseDays", defaultValue: "Vælg dine træningsdage"
        )
        static func daysPerWeek(_ count: Int) -> LocalizedStringResource {
            LocalizedStringResource(
                "planner.daysPerWeek",
                defaultValue: "Du træner \(count) dage om ugen"
            )
        }

        static let chooseDaysNote = LocalizedStringResource(
            "planner.chooseDaysNote",
            defaultValue: "Tryk på de dage, du vil løbe. Du bestemmer selv — og hviledage imellem gør dig stærkere."
        )
        static let suggestEvenly = LocalizedStringResource(
            "planner.suggestEvenly", defaultValue: "Foreslå jævnt fordelt"
        )
        static let pickAtLeastOne = LocalizedStringResource(
            "planner.pickAtLeastOne", defaultValue: "Vælg mindst én dag"
        )
    }

    enum Progress {
        static let title = LocalizedStringResource("progress.title", defaultValue: "Fremgang")
        static let listTab = LocalizedStringResource("progress.listTab", defaultValue: "Liste")
        static let calendarTab = LocalizedStringResource(
            "progress.calendarTab",
            defaultValue: "Kalender"
        )
        static let empty = LocalizedStringResource(
            "progress.empty",
            defaultValue: "Din første tur venter — den kommer her, når du er kommet afsted."
        )
        static func totalRuns(_ count: Int) -> LocalizedStringResource {
            LocalizedStringResource("progress.totalRuns", defaultValue: "\(count) gennemførte ture")
        }

        static let completedTag = LocalizedStringResource(
            "progress.completedTag",
            defaultValue: "Gennemført"
        )
        static let partialTag = LocalizedStringResource(
            "progress.partialTag",
            defaultValue: "Påbegyndt"
        )
        static func weekLabel(_ id: Int) -> LocalizedStringResource {
            LocalizedStringResource("progress.weekLabel", defaultValue: "Uge \(id) i forløbet")
        }

        static let durationLabel = LocalizedStringResource(
            "progress.duration",
            defaultValue: "Varighed"
        )
        static let distanceLabel = LocalizedStringResource(
            "progress.distance",
            defaultValue: "Distance"
        )
        static let intervalsLabel = LocalizedStringResource(
            "progress.intervals",
            defaultValue: "Gennemførte intervaller"
        )
        static let starsLabel = LocalizedStringResource("progress.stars", defaultValue: "Stjerner")
        static let effortLabel = LocalizedStringResource(
            "progress.effort",
            defaultValue: "Sådan føltes det"
        )
        static let bodyLabel = LocalizedStringResource(
            "progress.body",
            defaultValue: "Kroppen bagefter"
        )
        static let reflectionLabel = LocalizedStringResource(
            "progress.reflection",
            defaultValue: "Min note"
        )
        static let photosLabel = LocalizedStringResource(
            "progress.photos",
            defaultValue: "Billeder fra turen"
        )
        static let noPhotos = LocalizedStringResource(
            "progress.noPhotos",
            defaultValue: "Ingen billeder fra denne tur endnu."
        )
        static let addPhoto = LocalizedStringResource(
            "progress.addPhoto",
            defaultValue: "Tilføj et billede"
        )
        static let sharePhoto = LocalizedStringResource(
            "progress.sharePhoto",
            defaultValue: "Del billede"
        )
        static let photoHint = LocalizedStringResource(
            "progress.photoHint",
            defaultValue: "Fang stedet eller øjeblikket — det er helt frivilligt."
        )
    }

    enum Badges {
        static let title = LocalizedStringResource("badges.title", defaultValue: "Samling")
        static let earnedSection = LocalizedStringResource(
            "badges.earned",
            defaultValue: "Optjente mærker"
        )
        static let lockedSection = LocalizedStringResource(
            "badges.locked",
            defaultValue: "Endnu ikke låst op"
        )
        static func levelProgress(into: Int, span: Int) -> LocalizedStringResource {
            LocalizedStringResource(
                "badges.levelProgress",
                defaultValue: "\(into) / \(span) point til næste niveau"
            )
        }

        static let tapToUnlock = LocalizedStringResource(
            "badges.tapToUnlock",
            defaultValue: "Tryk for at låse op"
        )
        static let unlock = LocalizedStringResource("badges.unlock", defaultValue: "Lås op")
        static let cancel = LocalizedStringResource("badges.cancel", defaultValue: "Ikke endnu")
        static func claimTitle(_ name: String) -> LocalizedStringResource {
            LocalizedStringResource("badges.claimTitle", defaultValue: "Lås '\(name)' op?")
        }

        static let manualNote = LocalizedStringResource(
            "badges.manualNote",
            defaultValue: "Nogle mærker giver du dig selv, når du har gjort tingen."
        )

        /// Tema-grupper i samlingen.
        static let categoryFirstSteps = LocalizedStringResource(
            "badges.category.firstSteps", defaultValue: "Første skridt"
        )
        static let categoryConsistency = LocalizedStringResource(
            "badges.category.consistency", defaultValue: "Vedholdenhed"
        )
        static let categoryWeather = LocalizedStringResource(
            "badges.category.weather", defaultValue: "Vejr & omgivelser"
        )
        static let categoryHabits = LocalizedStringResource(
            "badges.category.habits", defaultValue: "Vaner & rutiner"
        )
        static let categorySocial = LocalizedStringResource(
            "badges.category.social", defaultValue: "Socialt & sjov"
        )
        static let categorySpecial = LocalizedStringResource(
            "badges.category.special", defaultValue: "Særlige øjeblikke"
        )
    }

    /// Venlige, ikke-pressende påmindelser (spec afsnit 8). Aldrig skyld eller
    /// frygt for at miste streak.
    enum Notifications {
        static let reminderTitle = LocalizedStringResource(
            "notifications.reminderTitle", defaultValue: "Klar til en lille tur?"
        )
        static let reminderBody = LocalizedStringResource(
            "notifications.reminderBody",
            defaultValue: "Det skal ikke være hårdt — bare en rolig tur, når det passer dig."
        )
    }

    enum Settings {
        static let title = LocalizedStringResource("settings.title", defaultValue: "Indstillinger")
        static let feedbackSection = LocalizedStringResource(
            "settings.feedback",
            defaultValue: "Lyd, stemme og haptik"
        )
        static let voice = LocalizedStringResource("settings.voice", defaultValue: "Stemmecoach")
        static let sound = LocalizedStringResource("settings.sound", defaultValue: "Lyde")
        static let haptics = LocalizedStringResource("settings.haptics", defaultValue: "Vibration")
        static let duckMusic = LocalizedStringResource(
            "settings.duckMusic",
            defaultValue: "Sænk musik under signaler"
        )
        static let feedbackNote = LocalizedStringResource(
            "settings.feedbackNote",
            defaultValue: "Alt kan slås fra hver for sig — appen virker fuldt uden lyd."
        )

        static let signalSoundsSection = LocalizedStringResource(
            "settings.signalSounds", defaultValue: "Signallyde"
        )
        static let runStartSound = LocalizedStringResource(
            "settings.runStartSound", defaultValue: "Når du skal løbe"
        )
        static let walkStartSound = LocalizedStringResource(
            "settings.walkStartSound", defaultValue: "Når du skal gå"
        )
        static let signalSoundsNote = LocalizedStringResource(
            "settings.signalSoundsNote",
            defaultValue: "Vælg hver sin lyd til løb og gå, så du kan høre skiftet uden at kigge på skærmen."
        )

        static let remindersSection = LocalizedStringResource(
            "settings.reminders",
            defaultValue: "Påmindelser"
        )
        static let remindersEnabled = LocalizedStringResource(
            "settings.remindersEnabled",
            defaultValue: "Venlige påmindelser"
        )
        static let reminderTime = LocalizedStringResource(
            "settings.reminderTime",
            defaultValue: "Tidspunkt"
        )
        static let remindersNote = LocalizedStringResource(
            "settings.remindersNote", defaultValue: "Blide opfordringer — aldrig pres eller skyld."
        )

        static let duringRunSection = LocalizedStringResource(
            "settings.duringRun", defaultValue: "Under turen"
        )
        static let showPaceAndDistance = LocalizedStringResource(
            "settings.showPaceAndDistance", defaultValue: "Vis tempo og distance"
        )
        static let showPaceAndDistanceNote = LocalizedStringResource(
            "settings.showPaceAndDistanceNote",
            defaultValue: "Som standard viser vi kun tiden — det handler om at komme afsted og have det sjovt, ikke om fart. Slå til, hvis du selv gerne vil følge tempo og distance undervejs."
        )

        static let streakSection = LocalizedStringResource("settings.streak", defaultValue: "Stime")
        static let streakFreeze = LocalizedStringResource(
            "settings.streakFreeze",
            defaultValue: "Tillad streak-fryser"
        )
        static let streakNote = LocalizedStringResource(
            "settings.streakNote",
            defaultValue: "En travl uge bryder aldrig din stime. Hvile tæller med."
        )

        static let healthSection = LocalizedStringResource(
            "settings.health",
            defaultValue: "Helbred"
        )
        static let healthKit = LocalizedStringResource(
            "settings.healthKit",
            defaultValue: "Gem ture i Helbred"
        )
        static let healthNote = LocalizedStringResource(
            "settings.healthNote",
            defaultValue: "Valgfrit. Dine ture gemmes som workouts i Apples Helbred — kun med dit samtykke."
        )

        static let roleSection = LocalizedStringResource("settings.role", defaultValue: "Rolle")
        static let roleRunner = LocalizedStringResource(
            "settings.role.runner",
            defaultValue: "Løber"
        )
        static let roleParent = LocalizedStringResource(
            "settings.role.parent",
            defaultValue: "Forælder/voksen"
        )
        static let roleNote = LocalizedStringResource(
            "settings.roleNote",
            defaultValue: "Forælder-rollen er støtte, ikke overvågning. Du kan altid skifte tilbage."
        )

        static let privacySection = LocalizedStringResource(
            "settings.privacy",
            defaultValue: "Privatliv og data"
        )
        static let exportData = LocalizedStringResource(
            "settings.exportData",
            defaultValue: "Eksportér mine data"
        )
        static let deleteData = LocalizedStringResource(
            "settings.deleteData",
            defaultValue: "Slet alle mine data"
        )
        static let deleteConfirmTitle = LocalizedStringResource(
            "settings.deleteConfirmTitle", defaultValue: "Slet alle dine data?"
        )
        static let deleteConfirmBody = LocalizedStringResource(
            "settings.deleteConfirmBody",
            defaultValue: "Alt — ture, billeder og fremgang — slettes for altid. Det kan ikke fortrydes."
        )
        static let cancel = LocalizedStringResource("settings.cancel", defaultValue: "Annullér")
        static let privacyNote = LocalizedStringResource(
            "settings.privacyNote",
            defaultValue: "Dine data er dine. De bliver på din enhed og i din egen iCloud — og deles aldrig uden dit valg."
        )
    }

    enum SignalSounds {
        static let energetic = LocalizedStringResource(
            "signalSound.energetic",
            defaultValue: "Energisk"
        )
        static let soft = LocalizedStringResource("signalSound.soft", defaultValue: "Blød")
        static let bell = LocalizedStringResource("signalSound.bell", defaultValue: "Klokke")
        static let chime = LocalizedStringResource("signalSound.chime", defaultValue: "Klang")
        static let whistle = LocalizedStringResource("signalSound.whistle", defaultValue: "Fløjt")
        static let marimba = LocalizedStringResource("signalSound.marimba", defaultValue: "Marimba")
    }

    enum Sharing {
        static let section = LocalizedStringResource(
            "sharing.section",
            defaultValue: "Forælder-deling"
        )
        static let shareStreak = LocalizedStringResource(
            "sharing.shareStreak",
            defaultValue: "Del min stime"
        )
        static let shareWorkouts = LocalizedStringResource(
            "sharing.shareWorkouts",
            defaultValue: "Del mine ture"
        )
        static let shareMilestones = LocalizedStringResource(
            "sharing.shareMilestones",
            defaultValue: "Del mine milepæle"
        )
        static let note = LocalizedStringResource(
            "sharing.note",
            defaultValue: "Du bestemmer selv, hvad en voksen kan se — og kan slå det fra når som helst. Ingen kan følge dig i det skjulte."
        )
        static let seeWhatParentSees = LocalizedStringResource(
            "sharing.seeWhatParentSees", defaultValue: "Se præcis, hvad din forælder ser"
        )
    }

    enum Safety {
        static let title = LocalizedStringResource("safety.title", defaultValue: "Tryghed udenfor")
        static let livePosition = LocalizedStringResource(
            "safety.livePosition",
            defaultValue: "Del min position under turen"
        )
        static let livePositionNote = LocalizedStringResource(
            "safety.livePositionNote",
            defaultValue: "Kun mens du løber. Slukkes automatisk, når turen slutter. Du ser altid, at den er tændt."
        )
        static let awayHome = LocalizedStringResource(
            "safety.awayHome",
            defaultValue: "Send 'afsted' og 'hjemme igen'"
        )
        static let contactName = LocalizedStringResource(
            "safety.contactName",
            defaultValue: "Betroet kontakt"
        )
        static let contactPhone = LocalizedStringResource(
            "safety.contactPhone",
            defaultValue: "Telefonnummer"
        )
        static let sos = LocalizedStringResource(
            "safety.sos",
            defaultValue: "SOS – ring efter hjælp"
        )
        static let sosNote = LocalizedStringResource(
            "safety.sosNote",
            defaultValue: "Ringer til din betroede kontakt, eller 112 hvis ingen er valgt."
        )
        static let tips = LocalizedStringResource(
            "safety.tips",
            defaultValue: "Løb helst i dagslys og på kendte ruter, og hold lyden nede nok til at høre trafik og omgivelser."
        )
        static let openInSettings = LocalizedStringResource(
            "safety.title.link",
            defaultValue: "Tryghed og sikkerhed"
        )
    }

    enum Parent {
        static let title = LocalizedStringResource(
            "parent.title",
            defaultValue: "Hvad din forælder ser"
        )
        static let nothingShared = LocalizedStringResource(
            "parent.nothingShared",
            defaultValue: "Lige nu deler du ikke noget. Det er helt op til dig."
        )
        static func streak(_ weeks: Int) -> LocalizedStringResource {
            LocalizedStringResource("parent.streak", defaultValue: "\(weeks) ugers stime")
        }

        static func completed(_ count: Int) -> LocalizedStringResource {
            LocalizedStringResource("parent.completed", defaultValue: "\(count) gennemførte ture")
        }

        static let milestonesTitle = LocalizedStringResource(
            "parent.milestones",
            defaultValue: "Milepæle"
        )
        static let supportNote = LocalizedStringResource(
            "parent.supportNote",
            defaultValue: "Forælderen kan heppe og fejre med dig — men kan aldrig ændre dit program eller presse dig."
        )
    }

    enum Dashboard {
        static let weeksRun = LocalizedStringResource(
            "dashboard.weeksRun",
            defaultValue: "Ugens tur"
        )
    }

    enum Interval {
        static let warmUp = LocalizedStringResource("interval.warmUp", defaultValue: "Opvarmning")
        static let run = LocalizedStringResource("interval.run", defaultValue: "Løb")
        static let walk = LocalizedStringResource("interval.walk", defaultValue: "Gå")
        static let coolDown = LocalizedStringResource(
            "interval.coolDown",
            defaultValue: "Nedkøling"
        )
    }

    /// Stemmecoachens replikker (afsnit 4.2). Varme, korte, opmuntrende — aldrig
    /// pres eller fart-fokus.
    enum Coaching {
        static func runStart(duration: String) -> LocalizedStringResource {
            LocalizedStringResource("coaching.runStart", defaultValue: "Løb nu i \(duration)")
        }

        static func walkStart(duration: String) -> LocalizedStringResource {
            LocalizedStringResource(
                "coaching.walkStart",
                defaultValue: "Godt klaret — gå roligt i \(duration)"
            )
        }

        static let warmUpStart = LocalizedStringResource(
            "coaching.warmUpStart",
            defaultValue: "Vi varmer op med rask gang og nogle bløde bevægelser"
        )
        static let coolDownStart = LocalizedStringResource(
            "coaching.coolDownStart",
            defaultValue: "Flot — vi køler af med rolig gang og lidt udstrækning"
        )
        static let halfway = LocalizedStringResource(
            "coaching.halfway", defaultValue: "Du er halvvejs — flot!"
        )
        static let finished = LocalizedStringResource(
            "coaching.finished", defaultValue: "Fantastisk — du gennemførte hele turen!"
        )
        static let talkTest = LocalizedStringResource(
            "coaching.talkTest",
            defaultValue: "Husk: kan du ikke tale imens, så sæt lidt farten ned"
        )
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
