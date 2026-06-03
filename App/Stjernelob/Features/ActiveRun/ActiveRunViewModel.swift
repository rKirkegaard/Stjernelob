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
    private let plan: WorkoutPlan
    private let programWeekId: Int
    private let programPhase: ProgramPhase
    private let feedback: WorkoutFeedbackCoordinator
    private let environment: AppEnvironment
    private let now: () -> Date

    init(
        plan: WorkoutPlan,
        programWeekId: Int,
        programPhase: ProgramPhase,
        environment: AppEnvironment,
        feedback: WorkoutFeedbackCoordinator,
        now: @escaping () -> Date = { Date() }
    ) {
        self.plan = plan
        self.programWeekId = programWeekId
        self.programPhase = programPhase
        self.environment = environment
        self.feedback = feedback
        self.now = now
        self.engine = IntervalEngine(plan: plan, clock: environment.clock)
        self.snapshot = IntervalEngine(plan: plan, clock: environment.clock).snapshot()
    }

    func start() {
        feedback.begin()
        if environment.settings.livePositionEnabled {
            environment.locationService.startSharing()
        }
        dispatch(engine.start())
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
        liveActivity.update(snapshot: snapshot, intervalLabel: String(localized: snapshot.interval.kind.label))

        // Blid talk-test-påmindelse hvert 5. minut undervejs.
        if snapshot.totalElapsed.wholeSeconds >= nextTalkTestSeconds, snapshot.totalRemaining > .seconds(60) {
            feedback.talkTestReminder()
            nextTalkTestSeconds += 300
        }
    }

    func pause() {
        dispatch(engine.pause())
        if engine.status == .paused { phase = .paused }
        snapshot = engine.snapshot()
    }

    func resume() {
        engine.resume()
        phase = .running
        snapshot = engine.snapshot()
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
        liveActivity.end()
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
        let totalCompleted = (try? environment.workoutRepository.count()) ?? 0
        let streakWeeks = streakWeeksNow()
        let longestRun = summary.isComplete ? longestRunInterval() : .zero
        let finishedBase = programPhase == .base && programWeekId == 8 && summary.isComplete

        let context = BadgeContext(
            totalCompletedWorkouts: totalCompleted,
            currentStreakWeeks: streakWeeks,
            longestContinuousRun: longestRun,
            finishedBaseProgram: finishedBase
        )
        let already = (try? environment.badgeRepository.earned()) ?? []
        for badge in BadgeEvaluator.newlyEarned(context: context, alreadyEarned: already) {
            try? environment.badgeRepository.award(badge)
        }
    }

    private func longestRunInterval() -> Duration {
        plan.intervals.lazy.filter { $0.kind == .run }.map(\.duration).max() ?? .zero
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
