import Combine
import StjernelobCore
import SwiftUI
import WatchKit

/// Enkel tur-styring på uret: stort interval-navn, nedtælling og start/stop.
/// Intervalskift giver haptik på håndleddet, så turen kan følges uden lyd.
/// Bruger den tur, telefonen har sendt (hvis nogen), ellers et standardforløb.
@MainActor
@Observable
final class WatchRunModel {
    private let sync = WatchSyncService()
    private let workout = WatchWorkoutController()
    private let distanceTracker = WatchDistanceTracker()
    private var engine: IntervalEngine?
    private var programWeekId = 1
    private var programPhase: ProgramPhase = .base
    /// Måler uret selv distance på denne tur? Kun når telefonen ikke er med.
    private var measuringDistance = false

    private(set) var snapshot: WorkoutSnapshot?
    private(set) var started = false
    private(set) var finished = false
    /// Vist distance i meter — kun når uret måler selv (telefonen ikke med).
    private(set) var distanceMeters: Double = 0

    /// Om der vises distance på uret (uret kører selvstændigt og måler selv).
    var showsDistance: Bool { measuringDistance }

    /// Forbered sensorer (HealthKit) før turen. Kaldes fra view'ets `.task`.
    func prepare() async {
        await workout.requestAuthorization()
    }

    func start() {
        let plan: WorkoutPlan
        if let session = sync.latestSession {
            plan = session.plan
            programWeekId = session.programWeekId
            programPhase = session.programPhase
        } else {
            let week = ProgressionEngine().currentWeek
            plan = week.plan(forSessionsPerWeek: 3)
            programWeekId = week.id
            programPhase = week.phase
        }

        // Mål kun egen GPS/distance, hvis telefonen ikke er med på turen — så vi
        // ikke dobbeltmåler, og uret sparer batteri når telefonen alligevel måler.
        measuringDistance = !sync.isPhoneReachable
        workout.start()
        if measuringDistance { distanceTracker.start() }

        let engine = IntervalEngine(plan: plan, clock: SystemMonotonicClock())
        self.engine = engine
        started = true
        engine.start()
        snapshot = engine.snapshot()
        WKInterfaceDevice.current().play(.start)
    }

    func tick() {
        guard started, !finished, let engine else { return }
        for event in engine.update() {
            switch event {
            case let .intervalStarted(_, interval):
                WKInterfaceDevice.current().play(interval.kind.isRunning ? .start : .stop)
            case let .finished(summary):
                complete(summary)
            default:
                break
            }
        }
        snapshot = engine.snapshot()
        if measuringDistance { distanceMeters = distanceTracker.distanceMeters }
    }

    func stop() {
        guard let engine else { return }
        complete(engine.stop())
    }

    private func complete(_ summary: WorkoutSummary) {
        guard !finished else { return }
        finished = true
        if measuringDistance {
            distanceMeters = distanceTracker.distanceMeters
            distanceTracker.stop()
        }
        workout.end()
        WKInterfaceDevice.current().play(.success)
        sync.sendCompletion(WatchCompletionPayload(
            programWeekId: programWeekId,
            programPhase: programPhase,
            activeSeconds: Double(summary.activeDuration.components.seconds),
            intervalsCompleted: summary.intervalsCompleted,
            plannedIntervalCount: summary.plannedIntervalCount,
            runIntervalsCompleted: summary.runIntervalsCompleted,
            isComplete: summary.isComplete,
            distanceMeters: (measuringDistance && distanceMeters > 0) ? distanceMeters : nil
        ))
    }

    func label(for kind: IntervalKind) -> LocalizedStringResource {
        switch kind {
        case .warmUp: LocalizedStringResource("watch.warmUp", defaultValue: "Opvarmning")
        case .run: LocalizedStringResource("watch.run", defaultValue: "Løb")
        case .walk: LocalizedStringResource("watch.walk", defaultValue: "Gå")
        case .coolDown: LocalizedStringResource("watch.coolDown", defaultValue: "Nedkøling")
        }
    }
}

struct WatchRunView: View {
    @State private var model = WatchRunModel()
    private let ticker = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 8) {
            if model.finished {
                Image(systemName: "star.fill").font(.largeTitle).foregroundStyle(.yellow)
                Text(LocalizedStringResource("watch.done", defaultValue: "Flot klaret!"))
            } else if model.started, let snapshot = model.snapshot {
                Text(model.label(for: snapshot.interval.kind))
                    .font(.headline)
                Text(timeText(Int(snapshot.remainingInInterval.components.seconds)))
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .monospacedDigit()
                if model.showsDistance {
                    Text(distanceText(model.distanceMeters))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
                Button(role: .destructive) {
                    model.stop()
                } label: {
                    Text(LocalizedStringResource("watch.stop", defaultValue: "Stop"))
                }
            } else {
                Button {
                    model.start()
                } label: {
                    Text(LocalizedStringResource("watch.start", defaultValue: "Start tur"))
                }
            }
        }
        .onReceive(ticker) { _ in model.tick() }
        .task { await model.prepare() }
    }

    private func timeText(_ seconds: Int) -> String {
        String(format: "%d:%02d", max(0, seconds) / 60, max(0, seconds) % 60)
    }

    private func distanceText(_ meters: Double) -> String {
        String(format: "%.2f km", meters / 1000)
    }
}
