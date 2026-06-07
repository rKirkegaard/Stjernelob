import Foundation
import Observation
import StjernelobCore

/// Styrer en live-tur (spec afsnit 4): driver intervalmotoren, opdaterer
/// snapshot til skærmen, sender hændelser videre til lyd/stemme/haptik, samler
/// stjernepop undervejs, og gemmer resultatet ved målgang.
///
/// Motoren er drift-fri (beregner tid ud fra et monotont ur), så `tick()` blot
/// skal kaldes jævnligt — præcis frekvens er ligegyldig for korrektheden.
@MainActor
@Observable
final class ActiveRunViewModel {
    enum Phase: Equatable {
        case running
        case paused
        case finished(WorkoutSummary)
    }

    private(set) var snapshot: WorkoutSnapshot
    private(set) var phase: Phase = .running
    /// Tæller op, hver gang et interval gennemføres — driver stjernepop-animationen.
    private(set) var starPops = 0
    private var didSave = false
    /// Næste tidspunkt (sekunder) for en blid talk-test-påmindelse.
    private var nextTalkTestSeconds = 300

    private let engine: IntervalEngine
    private let liveActivity = LiveActivityController()
    private let distanceTracker = DistanceTracker()
    /// Målt distance i meter (vist neutralt; aldrig grundlag for belønning).
    private(set) var distanceMeters: Double = 0
    private let plan: WorkoutPlan
    private let programWeekId: Int
    private let programPhase: ProgramPhase
    private let feedback: WorkoutFeedbackCoordinator
    private let environment: AppEnvironment
    private let now: () -> Date
    private let resumeElapsed: Duration?

    // Vægur-tilstand til persistering, så turen kan genoptages efter app-luk.
    private var recordStartDate = Date(timeIntervalSince1970: 0)
    private var recordPausedAccumulated: Double = 0
    private var recordPauseStart: Date?

    init(
        plan: WorkoutPlan,
        programWeekId: Int,
        programPhase: ProgramPhase,
        environment: AppEnvironment,
        feedback: WorkoutFeedbackCoordinator,
        resumeElapsed: Duration? = nil,
        now: @escaping () -> Date = { Date() }
    ) {
        self.plan = plan
        self.programWeekId = programWeekId
        self.programPhase = programPhase
        self.environment = environment
        self.feedback = feedback
        self.resumeElapsed = resumeElapsed
        self.now = now
        self.engine = IntervalEngine(plan: plan, clock: environment.clock)
        self.snapshot = IntervalEngine(plan: plan, clock: environment.clock).snapshot()
    }

    func start() {
        feedback.begin()
        distanceTracker.start()
        if environment.settings.livePositionEnabled {
            environment.locationService.startSharing()
        }

        if let resumeElapsed {
            dispatch(engine.resume(atElapsed: resumeElapsed))
            recordStartDate = now().addingTimeInterval(-Double(resumeElapsed.components.seconds))
        } else {
            dispatch(engine.start())
            recordStartDate = now()
        }
        recordPausedAccumulated = 0
        recordPauseStart = nil
        persistRecord()

        snapshot = engine.snapshot()
        liveActivity.start(
            planTitle: String(localized: Strings.App.name),
            snapshot: snapshot,
            intervalLabel: String(localized: snapshot.interval.kind.label)
        )
    }

    /// Kaldes jævnligt (fx fra en timer i view'et).
    func tick() {
        guard case .running = phase else { return }
        dispatch(engine.update())
        snapshot = engine.snapshot()
        distanceMeters = distanceTracker.distanceMeters
        liveActivity.update(snapshot: snapshot, intervalLabel: String(localized: snapshot.interval.kind.label))

        // Blid talk-test-påmindelse hvert 5. minut undervejs.
        if snapshot.totalElapsed.wholeSeconds >= nextTalkTestSeconds, snapshot.totalRemaining > .seconds(60) {
            feedback.talkTestReminder()
            nextTalkTestSeconds += 300
        }
    }

    func pause() {
        dispatch(engine.pause())
        if engine.status == .paused {
            phase = .paused
            recordPauseStart = now()
            persistRecord()
        }
        snapshot = engine.snapshot()
    }

    func resume() {
        if let pauseStart = recordPauseStart {
            recordPausedAccumulated += now().timeIntervalSince(pauseStart)
            recordPauseStart = nil
        }
        engine.resume()
        phase = .running
        persistRecord()
        snapshot = engine.snapshot()
    }

    private func persistRecord() {
        environment.runStateStore.save(ActiveRunRecord(
            plan: plan,
            programWeekId: programWeekId,
            programPhase: programPhase,
            startDate: recordStartDate,
            pausedAccumulatedSeconds: recordPausedAccumulated,
            pauseStartDate: recordPauseStart
        ))
    }

    /// Afbryd turen før tid — gemmer det gennemførte (stjerner gives for det,
    /// der nåede at blive lavet; ingen bonus).
    func stop() {
        let summary = engine.stop()
        feedback.end()
        finish(with: summary)
    }

    private func dispatch(_ events: [WorkoutEvent]) {
        for event in events {
            feedback.handle(event)
            switch event {
            case .intervalCompleted:
                starPops += 1
            case let .finished(summary):
                feedback.end()
                finish(with: summary)
            default:
                break
            }
        }
    }

    private func finish(with summary: WorkoutSummary) {
        if case .finished = phase { return }
        // Positionsdeling slukkes automatisk ved turslut (afsnit 12).
        environment.locationService.stopSharing()
        distanceTracker.stop()
        distanceMeters = distanceTracker.distanceMeters
        liveActivity.end()
        environment.runStateStore.clear() // turen er slut — intet at genoptage
        phase = .finished(summary)
    }

    /// Gem resultatet — kaldes når brugeren lukker resuméet (med valgfri
    /// "hvordan føltes det?"). Belønning gives for gennemførsel, ikke fart.
    func saveResult(perceivedEffort: Int?) {
        guard case let .finished(summary) = phase, !didSave else { return }
        didSave = true

        let workout = CompletedWorkoutDTO(
            id: UUID(),
            date: now(),
            programWeekId: programWeekId,
            phase: programPhase,
            plannedIntervalCount: summary.plannedIntervalCount,
            intervalsCompleted: summary.intervalsCompleted,
            runIntervalsCompleted: summary.runIntervalsCompleted,
            activeDuration: summary.activeDuration,
            isComplete: summary.isComplete,
            starsEarned: Stars.earned(for: summary),
            perceivedEffort: perceivedEffort,
            distanceMeters: distanceMeters > 0 ? distanceMeters : nil,
            photos: []
        )
        try? environment.workoutRepository.add(workout)
        awardBadges(for: summary)
        ProgressionCoordinator(environment: environment)
            .registerCompletedWorkout(programWeekId: programWeekId, now: now())

        if environment.settings.healthKitEnabled {
            let end = now()
            let start = end.addingTimeInterval(-TimeInterval(summary.activeDuration.components.seconds))
            Task { await environment.healthKit.saveRun(start: start, duration: summary.activeDuration) }
        }
    }

    private func awardBadges(for summary: WorkoutSummary) {
        // Turen er allerede gemt, så `all()` indeholder den netop afsluttede tur.
        let workouts = (try? environment.workoutRepository.all()) ?? []

        let date = now()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let thisWeek = WeekIdentifier(date: date)
        let monthComponents = calendar.dateComponents([.year, .month], from: date)

        let datesNewestFirst = workouts.map(\.date).sorted(by: >)
        let daysSincePrevious = datesNewestFirst.count >= 2
            ? (calendar.dateComponents([.day], from: datesNewestFirst[1], to: datesNewestFirst[0]).day ?? 0)
            : 0

        let context = BadgeContext(
            totalCompletedWorkouts: workouts.count,
            currentStreakWeeks: streakWeeksNow(),
            sessionsThisWeek: workouts.filter { WeekIdentifier(date: $0.date) == thisWeek }.count,
            workoutsThisMonth: workouts.filter {
                calendar.dateComponents([.year, .month], from: $0.date) == monthComponents
            }.count,
            hasCompletedFullRun: workouts.contains { $0.isComplete },
            hasCompletedHardRun: workouts.contains { $0.isComplete && ($0.perceivedEffort ?? 0) >= 8 },
            startedInMorning: hour < 12,
            startedInEvening: hour >= 18,
            tookPhoto: workouts.contains { !$0.photos.isEmpty },
            isComeback: datesNewestFirst.count >= 2 && daysSincePrevious >= 14,
            month: calendar.component(.month, from: date),
            day: calendar.component(.day, from: date),
            totalRunIntervals: workouts.reduce(0) { $0 + $1.runIntervalsCompleted },
            maxRunIntervalsInOneRun: workouts.map(\.runIntervalsCompleted).max() ?? 0,
            totalActiveWeeks: Set(workouts.map { WeekIdentifier(date: $0.date) }).count,
            totalStars: workouts.reduce(0) { $0 + $1.starsEarned }
        )
        let already = (try? environment.badgeRepository.earned()) ?? []
        for badge in BadgeEvaluator.newlyEarned(context: context, alreadyEarned: already) {
            try? environment.badgeRepository.award(badge)
        }
    }

    private func streakWeeksNow() -> Int {
        let service = WeeklyStatusService(
            weeklyPlanRepository: environment.weeklyPlanRepository,
            workoutRepository: environment.workoutRepository
        )
        guard let tracker = try? service.tracker() else { return 0 }
        return tracker.currentStreak(asOf: WeekIdentifier(date: now()))
    }
}
