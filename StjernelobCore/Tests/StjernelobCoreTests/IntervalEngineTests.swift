import XCTest
@testable import StjernelobCore

/// Tests for den sikkerhedskritiske intervalmotor. Dækker timing, rækkefølge af
/// gå/løb-skift, nedtælling, halvvejs, målgang, pause/genoptag/afbryd og — vigtigst —
/// at motoren ikke "driver" tidsmæssigt selv ved grove, ujævne opdateringer
/// (baggrund/låst skærm). Jf. `.claude/rules/test.md`.
final class IntervalEngineTests: XCTestCase {

    /// Testplan: opvarmning 5s, løb 10s, gå 5s, løb 10s, nedkøling 5s = 35s.
    /// To løbeintervaller (indeks 1 og 3), så `runOrdinal` kan testes.
    private func makePlan() -> WorkoutPlan {
        WorkoutPlan(intervals: [
            .warmUp(.seconds(5)),
            .run(.seconds(10)),
            .walk(.seconds(5)),
            .run(.seconds(10)),
            .coolDown(.seconds(5)),
        ])
    }

    // MARK: - Tidslinje

    func testTotalDurationAndBoundaries() {
        let timeline = WorkoutTimeline(plan: makePlan())
        XCTAssertEqual(timeline.totalDuration, .seconds(35))
        XCTAssertEqual(timeline.start(ofInterval: 0), .seconds(0))
        XCTAssertEqual(timeline.start(ofInterval: 1), .seconds(5))
        XCTAssertEqual(timeline.start(ofInterval: 3), .seconds(20))
    }

    func testIntervalIndexAt() {
        let timeline = WorkoutTimeline(plan: makePlan())
        XCTAssertEqual(timeline.intervalIndex(at: .seconds(0)), 0)
        XCTAssertEqual(timeline.intervalIndex(at: .seconds(4.999)), 0)
        XCTAssertEqual(timeline.intervalIndex(at: .seconds(5)), 1)   // grænse hører til næste
        XCTAssertEqual(timeline.intervalIndex(at: .seconds(14.5)), 1)
        XCTAssertEqual(timeline.intervalIndex(at: .seconds(35)), 4)  // ved/efter slut: sidste
        XCTAssertEqual(timeline.intervalIndex(at: .seconds(99)), 4)
    }

    func testSnapshotCountsDown() {
        let timeline = WorkoutTimeline(plan: makePlan())
        let snap = timeline.snapshot(at: .seconds(8), phase: .active)
        XCTAssertEqual(snap.intervalIndex, 1)
        XCTAssertEqual(snap.interval.kind, .run)
        XCTAssertTrue(snap.isRunning)
        XCTAssertEqual(snap.elapsedInInterval, .seconds(3))
        XCTAssertEqual(snap.remainingInInterval, .seconds(7))
        XCTAssertEqual(snap.totalElapsed, .seconds(8))
        XCTAssertEqual(snap.totalRemaining, .seconds(27))
        XCTAssertEqual(snap.runOrdinal, 1)   // første løbeinterval
        XCTAssertEqual(snap.runCount, 2)
    }

    func testRunOrdinalForSecondRun() {
        let timeline = WorkoutTimeline(plan: makePlan())
        let snap = timeline.snapshot(at: .seconds(22), phase: .active)
        XCTAssertEqual(snap.intervalIndex, 3)
        XCTAssertEqual(snap.runOrdinal, 2)   // andet løbeinterval
    }

    // MARK: - Start

    func testStartEmitsStartedAndFirstInterval() {
        let clock = ManualClock(.seconds(1000))   // vilkårligt nulpunkt
        let engine = IntervalEngine(plan: makePlan(), clock: clock)
        let events = engine.start()
        XCTAssertEqual(events, [
            .started,
            .intervalStarted(index: 0, interval: .warmUp(.seconds(5))),
        ])
        XCTAssertEqual(engine.status, .active)
    }

    func testCannotStartTwice() {
        let clock = ManualClock()
        let engine = IntervalEngine(plan: makePlan(), clock: clock)
        _ = engine.start()
        XCTAssertEqual(engine.start(), [])
    }

    // MARK: - Skift og nedtælling

    func testCountdownBeepsBeforeFirstSwitch() {
        let clock = ManualClock()
        let engine = IntervalEngine(plan: makePlan(), clock: clock)
        engine.start()

        clock.advance(seconds: 2)   // nedtælling 3 ligger på t=2
        XCTAssertEqual(engine.update(), [.countdown(secondsRemaining: 3)])

        clock.advance(seconds: 1)   // t=3
        XCTAssertEqual(engine.update(), [.countdown(secondsRemaining: 2)])

        clock.advance(seconds: 1)   // t=4
        XCTAssertEqual(engine.update(), [.countdown(secondsRemaining: 1)])

        clock.advance(seconds: 1)   // t=5: skift
        XCTAssertEqual(engine.update(), [
            .intervalCompleted(index: 0, interval: .warmUp(.seconds(5))),
            .intervalStarted(index: 1, interval: .run(.seconds(10))),
        ])
    }

    func testHalfwayEmittedOnce() {
        let clock = ManualClock()
        let engine = IntervalEngine(plan: makePlan(), clock: clock)
        engine.start()
        clock.advance(seconds: 17)
        XCTAssertFalse(engine.update().contains(.halfway))
        clock.advance(seconds: 1)   // passerer 17.5
        XCTAssertTrue(engine.update().contains(.halfway))
        clock.advance(seconds: 10)
        XCTAssertFalse(engine.update().contains(.halfway))   // kun én gang
    }

    func testFinishedAtEnd() {
        let clock = ManualClock()
        let engine = IntervalEngine(plan: makePlan(), clock: clock)
        engine.start()
        clock.advance(seconds: 35)
        let events = engine.update()
        guard case .finished(let summary)? = events.last else {
            return XCTFail("Forventede en finished-hændelse til sidst, fik \(events)")
        }
        XCTAssertTrue(summary.isComplete)
        XCTAssertEqual(summary.intervalsCompleted, 5)
        XCTAssertEqual(summary.runIntervalsCompleted, 2)
        XCTAssertEqual(summary.activeDuration, .seconds(35))
        XCTAssertEqual(engine.status, .finished)
    }

    // MARK: - Drift-frihed (baggrund / låst skærm)

    /// Selv hvis motoren først kaldes igen efter at HELE turen er gået (fx skærm
    /// låst i baggrunden), skal alle skift udsendes i korrekt rækkefølge, og
    /// turen skal slutte korrekt. Dette er det centrale drift-krav.
    func testNoDriftWithSingleCoarseJump() {
        let clock = ManualClock()
        let engine = IntervalEngine(plan: makePlan(), clock: clock)
        engine.start()
        clock.advance(seconds: 35)
        let events = engine.update()

        let started = events.compactMap { event -> Int? in
            if case .intervalStarted(let index, _) = event { return index }
            return nil
        }
        XCTAssertEqual(started, [1, 2, 3, 4])   // alle skift, i rækkefølge

        let completed = events.filter {
            if case .intervalCompleted = $0 { return true }
            return false
        }
        XCTAssertEqual(completed.count, 5)

        let countdowns = events.filter {
            if case .countdown = $0 { return true }
            return false
        }
        XCTAssertEqual(countdowns.count, 15)   // 3 pr. interval × 5

        XCTAssertEqual(events.filter { $0 == .halfway }.count, 1)
        XCTAssertEqual(engine.status, .finished)
    }

    /// Finkornede opdateringer skal give nøjagtigt samme hændelsesmængde som ét
    /// stort spring — beviser at resultatet ikke afhænger af kaldsfrekvensen.
    func testFineAndCoarseUpdatesAgree() {
        func run(stepSeconds: Double) -> [WorkoutEvent] {
            let clock = ManualClock()
            let engine = IntervalEngine(plan: makePlan(), clock: clock)
            var all = engine.start()
            let steps = Int((35.0 / stepSeconds).rounded(.up))
            for _ in 0..<steps {
                clock.advance(seconds: stepSeconds)
                all += engine.update()
            }
            return all
        }
        // Sammenlign multimængderne uafhængigt af nøjagtig gruppering pr. kald.
        let fine = run(stepSeconds: 0.25)
        let coarse = run(stepSeconds: 35)
        XCTAssertEqual(fine.count, coarse.count)
        XCTAssertEqual(Set(describe(fine)), Set(describe(coarse)))
    }

    private func describe(_ events: [WorkoutEvent]) -> [String] {
        events.map { String(describing: $0) }
    }

    // MARK: - Pause / genoptag / afbryd

    func testPauseFreezesTime() {
        let clock = ManualClock()
        let engine = IntervalEngine(plan: makePlan(), clock: clock)
        engine.start()

        clock.advance(seconds: 3)
        _ = engine.update()
        engine.pause()
        XCTAssertEqual(engine.status, .paused)

        clock.advance(seconds: 100)         // 100s vægur går under pausen
        XCTAssertEqual(engine.snapshot().totalElapsed, .seconds(3))

        engine.resume()
        XCTAssertEqual(engine.status, .active)

        clock.advance(seconds: 2)           // 2s aktiv tid mere → t=5 aktivt
        let events = engine.update()
        XCTAssertTrue(events.contains(.intervalStarted(index: 1, interval: .run(.seconds(10)))))
        XCTAssertEqual(engine.snapshot().totalElapsed, .seconds(5))
    }

    func testStopBeforeEndSummarisesProgress() {
        let clock = ManualClock()
        let engine = IntervalEngine(plan: makePlan(), clock: clock)
        engine.start()
        clock.advance(seconds: 16)          // midt i andet løbeinterval (idx 1 slut v.15)
        _ = engine.update()
        let summary = engine.stop()
        XCTAssertFalse(summary.isComplete)
        XCTAssertEqual(summary.intervalsCompleted, 2)   // opvarmning + første løb
        XCTAssertEqual(summary.runIntervalsCompleted, 1)
        XCTAssertEqual(summary.activeDuration, .seconds(16))
        XCTAssertEqual(engine.status, .finished)
    }

    // MARK: - Genoptag efter afbrydelse

    func testResumeAnnouncesCurrentIntervalAndSkipsPast() {
        let clock = ManualClock()
        let engine = IntervalEngine(plan: makePlan(), clock: clock)
        // Genoptag 12s inde (midt i første løbeinterval, indeks 1).
        let resumed = engine.resume(atElapsed: .seconds(12))
        XCTAssertEqual(resumed, [.intervalStarted(index: 1, interval: .run(.seconds(10)))])
        XCTAssertEqual(engine.status, .active)

        // Fortsæt 3s frem til grænsen ved 15s — næste skift skal komme,
        // men intet fra de allerede passerede intervaller.
        clock.advance(seconds: 3)
        let events = engine.update()
        XCTAssertTrue(events.contains(.intervalCompleted(index: 1, interval: .run(.seconds(10)))))
        XCTAssertTrue(events.contains(.intervalStarted(index: 2, interval: .walk(.seconds(5)))))
        XCTAssertFalse(events.contains(.intervalStarted(index: 0, interval: .warmUp(.seconds(5)))))
    }

    func testResumeNearEndFinishes() {
        let clock = ManualClock()
        let engine = IntervalEngine(plan: makePlan(), clock: clock)
        XCTAssertEqual(engine.resume(atElapsed: .seconds(35)), [])
        XCTAssertEqual(engine.status, .finished)
    }

    func testResumePreservesRemainingTime() {
        let clock = ManualClock(.seconds(500))
        let engine = IntervalEngine(plan: makePlan(), clock: clock)
        engine.resume(atElapsed: .seconds(8))
        XCTAssertEqual(engine.snapshot().totalElapsed, .seconds(8))
        XCTAssertEqual(engine.snapshot().remainingInInterval, .seconds(7)) // løb 10s, 8-5=3 inde
    }

    func testUpdateAfterFinishIsEmpty() {
        let clock = ManualClock()
        let engine = IntervalEngine(plan: makePlan(), clock: clock)
        engine.start()
        clock.advance(seconds: 40)
        _ = engine.update()
        clock.advance(seconds: 5)
        XCTAssertEqual(engine.update(), [])
    }
}
