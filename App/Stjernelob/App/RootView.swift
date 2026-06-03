import SwiftUI
import StjernelobCore

/// Midlertidig rod-skærm, der beviser integrationen med domænelaget: den viser
/// den aktuelle uges første tur fra `ProgressionEngine`. Erstattes af det
/// rigtige dashboard (spec afsnit 7.2), efterhånden som skærmene bygges.
struct RootView: View {
    private let engine = ProgressionEngine()
    private let sessionsPerWeek = 3

    private var plan: WorkoutPlan {
        engine.currentWeek.plan(forSessionsPerWeek: sessionsPerWeek)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(Array(plan.intervals.enumerated()), id: \.offset) { _, interval in
                        HStack {
                            Text(label(for: interval.kind))
                            Spacer()
                            Text(interval.duration.shortText)
                                .monospacedDigit()
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Ugens tur")
                } footer: {
                    Text("\(plan.runIntervalCount) løbeintervaller · i alt \(plan.totalDuration.shortText)")
                }
            }
            .navigationTitle("Stjerneløb")
        }
    }

    private func label(for kind: IntervalKind) -> String {
        switch kind {
        case .warmUp: return "Opvarmning"
        case .run: return "Løb"
        case .walk: return "Gå"
        case .coolDown: return "Nedkøling"
        }
    }
}

#Preview {
    RootView()
}
