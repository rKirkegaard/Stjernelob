import SwiftUI
import StjernelobCore

/// Fremgang/historik (spec afsnit 6.4): liste og kalender over gennemførte ture.
struct HistoryView: View {
    @State var viewModel: HistoryViewModel
    @State private var showCalendar = false

    var body: some View {
        Group {
            if viewModel.workouts.isEmpty {
                ContentUnavailableView {
                    Label { Text(Strings.Progress.title) } icon: { Image(systemName: "figure.run") }
                } description: {
                    Text(Strings.Progress.empty)
                }
            } else {
                content
            }
        }
        .navigationTitle(Text(Strings.Progress.title))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Picker(selection: $showCalendar) {
                    Text(Strings.Progress.listTab).tag(false)
                    Text(Strings.Progress.calendarTab).tag(true)
                } label: {
                    Text(Strings.Progress.title)
                }
                .pickerStyle(.segmented)
            }
        }
        .onAppear { viewModel.load() }
    }

    @ViewBuilder
    private var content: some View {
        if showCalendar {
            ScrollView {
                CalendarGridView(weeks: viewModel.recentWeeks(), trainingDays: viewModel.trainingDays)
                    .padding(Theme.Spacing.medium)
            }
        } else {
            List {
                Section {
                    Text(Strings.Progress.totalRuns(viewModel.completedCount))
                        .font(.headline)
                }
                ForEach(viewModel.workouts) { workout in
                    NavigationLink {
                        WorkoutDetailView(workout: workout)
                    } label: {
                        row(workout)
                    }
                }
            }
        }
    }

    private func row(_ workout: CompletedWorkoutDTO) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(workout.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.headline)
                Spacer()
                Label {
                    Text("\(workout.starsEarned)")
                } icon: {
                    Image(systemName: "star.fill")
                }
                .foregroundStyle(Theme.Colors.star)
                .font(.subheadline)
            }
            HStack(spacing: Theme.Spacing.small) {
                Text(Strings.Progress.weekLabel(workout.programWeekId))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(workout.isComplete ? Strings.Progress.completedTag : Strings.Progress.partialTag)
                    .font(.caption2.weight(.semibold))
                    .padding(.horizontal, Theme.Spacing.small)
                    .padding(.vertical, 2)
                    .background(
                        (workout.isComplete ? Theme.Colors.accent : Theme.Colors.walking).opacity(0.2),
                        in: Capsule()
                    )
            }
        }
    }
}

/// Kompakt kalender: seneste uger med markering på dage med en gennemført tur.
private struct CalendarGridView: View {
    let weeks: [[Date]]
    let trainingDays: Set<Date>
    private let calendar = Calendar.iso8601Monday

    var body: some View {
        VStack(spacing: Theme.Spacing.small) {
            ForEach(Array(weeks.enumerated()), id: \.offset) { _, week in
                HStack(spacing: Theme.Spacing.small) {
                    ForEach(week, id: \.self) { day in
                        dayCell(day)
                    }
                }
            }
        }
    }

    private func dayCell(_ day: Date) -> some View {
        let isTraining = trainingDays.contains(calendar.startOfDay(for: day))
        return Text("\(calendar.component(.day, from: day))")
            .font(.caption)
            .monospacedDigit()
            .frame(maxWidth: .infinity, minHeight: 36)
            .background(
                isTraining ? Theme.Colors.brand.opacity(0.25) : Color.secondary.opacity(0.08),
                in: RoundedRectangle(cornerRadius: 8)
            )
            .overlay(alignment: .bottom) {
                if isTraining {
                    Circle().fill(Theme.Colors.star).frame(width: 5, height: 5).padding(.bottom, 3)
                }
            }
    }
}

#Preview {
    NavigationStack {
        HistoryView(viewModel: HistoryViewModel(environment: .preview))
    }
}
