import SwiftUI
import Combine
import WatchKit
import StjernelobCore

/// Enkel tur-styring på uret: stort interval-navn, nedtælling og start/stop.
/// Intervalskift giver haptik på håndleddet, så turen kan følges uden lyd.
@MainActor
@Observable
final class WatchRunModel {
    private let engine: IntervalEngine
    private(set) var snapshot: WorkoutSnapshot
    private(set) var started = false
    private(set) var finished = false

    init() {
        let plan = ProgressionEngine().currentWeek.plan(forSessionsPerWeek: 3)
        engine = IntervalEngine(plan: plan, clock: SystemMonotonicClock())
        snapshot = engine.snapshot()
    }

    func start() {
        started = true
        engine.start()
        snapshot = engine.snapshot()
        WKInterfaceDevice.current().play(.start)
    }

    func tick() {
        guard started, !finished else { return }
        for event in engine.update() {
            switch event {
            case let .intervalStarted(_, interval):
                WKInterfaceDevice.current().play(interval.kind.isRunning ? .start : .stop)
            case .finished:
                finished = true
                WKInterfaceDevice.current().play(.success)
            default:
                break
            }
        }
        snapshot = engine.snapshot()
    }

    func stop() {
        _ = engine.stop()
        finished = true
    }

    func label(for kind: IntervalKind) -> LocalizedStringResource {
        switch kind {
        case .warmUp: return LocalizedStringResource("watch.warmUp", defaultValue: "Opvarmning")
        case .run: return LocalizedStringResource("watch.run", defaultValue: "Løb")
        case .walk: return LocalizedStringResource("watch.walk", defaultValue: "Gå")
        case .coolDown: return LocalizedStringResource("watch.coolDown", defaultValue: "Nedkøling")
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
            } else if model.started {
                Text(model.label(for: model.snapshot.interval.kind))
                    .font(.headline)
                Text(timeText(model.snapshot.remainingInInterval.wholeSeconds))
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .monospacedDigit()
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
    }

    private func timeText(_ seconds: Int) -> String {
        String(format: "%d:%02d", max(0, seconds) / 60, max(0, seconds) % 60)
    }
}
