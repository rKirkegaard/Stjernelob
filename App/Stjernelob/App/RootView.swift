import SwiftUI
import StjernelobCore

/// Midlertidig rod-skærm, der beviser integrationen med domænelaget og det nye
/// fundament (lokalisering + designsystem): den viser den aktuelle uges første
/// tur fra `ProgressionEngine`. Erstattes af det rigtige dashboard (spec
/// afsnit 7.2), efterhånden som skærmene bygges.
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
                        HStack(spacing: Theme.Spacing.medium) {
                            Image(systemName: interval.kind.symbolName)
                                .foregroundStyle(interval.kind.color)
                                .font(.title3)
                                .frame(width: 28)
                            Text(interval.kind.label)
                            Spacer()
                            Text(interval.duration.shortText)
                                .monospacedDigit()
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text(Strings.Dashboard.weeksRun)
                } footer: {
                    Text(Strings.Units.sessionSummary(
                        runCount: plan.runIntervalCount,
                        total: plan.totalDuration.shortText
                    ))
                }
            }
            .navigationTitle(Text(Strings.App.name))
        }
    }
}

#Preview {
    RootView()
        .environment(AppEnvironment())
}
