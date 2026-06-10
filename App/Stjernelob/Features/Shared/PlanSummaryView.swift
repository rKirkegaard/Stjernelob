import StjernelobCore
import SwiftUI

/// Genbrugelig oversigt over en turs intervaller (opvarmning → gå/løb → nedkøling).
/// Bruges på dashboard, ugeplanlægger og resumé. Hver række viser ikon + farve +
/// tekst, så løb/gå skelnes uden at være afhængig af farve alene.
struct PlanSummaryView: View {
    let plan: WorkoutPlan

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
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
                .accessibilityElement(children: .combine)
            }
            Divider()
            Text(Strings.Units.sessionSummary(
                runCount: plan.runIntervalCount,
                total: plan.totalDuration.shortText
            ))
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
    }
}
