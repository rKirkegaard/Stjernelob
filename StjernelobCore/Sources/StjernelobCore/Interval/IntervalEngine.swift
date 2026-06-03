import Foundation

/// Den sikkerhedskritiske intervalmotor (jf. `arkitektur.md` og `test.md`).
///
/// Motoren "kører" en `WorkoutPlan` ved at aflæse et injiceret `MonotonicClock`.
/// Den er **deterministisk og drift-fri**: forløbet tid udregnes hver gang som
/// forskellen mellem urets nuværende aflæsning og starttidspunktet (minus
/// pauser), aldrig ved at lægge tick oven i tick. Derfor er den korrekt, selv
/// når den kaldes ujævnt — fx i baggrunden, ved låst skærm eller efter en
/// afbrydelse.
///
/// Brug: kald `start()`, og kald derefter `update()` jævnligt (fx fra en timer
/// eller når appen vågner). Hvert kald returnerer de hændelser, der er
/// indtruffet siden sidst, i korrekt rækkefølge. `pause()`, `resume()` og
/// `stop()` styrer turen. Motoren rører ikke selv ved lyd, UI eller sensorer.
public final class IntervalEngine {
    public enum Status: Sendable, Equatable {
        case notStarted
        case active
        case paused
        case finished
    }

    public private(set) var status: Status = .notStarted

    private let timeline: WorkoutTimeline
    private let clock: MonotonicClock
    private let schedule: [WorkoutTimeline.ScheduledEvent]

    /// Urets aflæsning da turen blev startet.
    private var startInstant: Duration = .zero
    /// Samlet varighed af afsluttede pauser.
    private var pausedTotal: Duration = .zero
    /// Urets aflæsning da den aktuelle pause begyndte (hvis paused).
    private var pauseBegan: Duration?
    /// Højeste forløbne tid, vi har udsendt hændelser frem til.
    private var processedElapsed: Duration = .zero

    public init(plan: WorkoutPlan, clock: MonotonicClock) {
        self.timeline = WorkoutTimeline(plan: plan)
        self.clock = clock
        self.schedule = timeline.scheduledEvents()
    }

    public var plan: WorkoutPlan { timeline.plan }

    /// Forløbet aktiv tid lige nu, afgrænset til [0, total].
    private var rawElapsed: Duration {
        guard status != .notStarted else { return .zero }
        let ongoingPause = pauseBegan.map { clock.now() - $0 } ?? .zero
        let elapsed = clock.now() - startInstant - pausedTotal - ongoingPause
        return clamp(elapsed, lower: .zero, upper: timeline.totalDuration)
    }

    /// Start turen. Kan kun kaldes én gang.
    @discardableResult
    public func start() -> [WorkoutEvent] {
        guard status == .notStarted else { return [] }
        startInstant = clock.now()
        processedElapsed = .zero
        status = .active
        let first = timeline.plan.intervals[0]
        return [.started, .intervalStarted(index: 0, interval: first)]
    }

    /// Udsend de hændelser, der er indtruffet siden sidste kald. Kald jævnligt.
    @discardableResult
    public func update() -> [WorkoutEvent] {
        guard status == .active else { return [] }
        let elapsed = rawElapsed
        let due = schedule
            .filter { $0.time > processedElapsed && $0.time <= elapsed }
            .map(\.event)
        processedElapsed = elapsed
        if elapsed >= timeline.totalDuration {
            status = .finished
        }
        return due
    }

    /// Sæt turen på pause. Tiden står stille, indtil `resume()` kaldes.
    @discardableResult
    public func pause() -> [WorkoutEvent] {
        guard status == .active else { return [] }
        let pending = update()
        guard status == .active else { return pending } // turen blev færdig i samme nu
        status = .paused
        pauseBegan = clock.now()
        return pending
    }

    /// Genoptag efter en pause.
    public func resume() {
        guard status == .paused, let began = pauseBegan else { return }
        pausedTotal += clock.now() - began
        pauseBegan = nil
        status = .active
    }

    /// Afbryd turen før tid. Returnerer en opsummering af det gennemførte.
    @discardableResult
    public func stop() -> WorkoutSummary {
        let elapsed = rawElapsed
        let complete = elapsed >= timeline.totalDuration
        status = .finished
        return timeline.summary(at: elapsed, isComplete: complete)
    }

    /// Øjebliksbillede til visning.
    public func snapshot() -> WorkoutSnapshot {
        let phase: WorkoutSnapshot.Phase
        switch status {
        case .notStarted: phase = .notStarted
        case .active: phase = .active
        case .paused: phase = .paused
        case .finished: phase = .finished
        }
        return timeline.snapshot(at: rawElapsed, phase: phase)
    }
}
