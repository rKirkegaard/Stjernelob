import Observation
import StjernelobCore
import SwiftUI

/// "Mine ture & planer": byg en egen tur, importér en plan, og kør/administrér
/// dem du har gemt. (Import-flowet kobles på i næste lag.)
@MainActor
@Observable
final class PlanLibraryViewModel {
    let environment: AppEnvironment
    private(set) var workouts: [Workout] = []

    init(environment: AppEnvironment) {
        self.environment = environment
    }

    func load() {
        workouts = (try? environment.planLibraryRepository.savedWorkouts()) ?? []
    }

    func delete(_ workout: Workout) {
        try? environment.planLibraryRepository.deleteWorkout(id: workout.id)
        load()
    }

    /// En kør-anmodning for en gemt tur (tæller ikke i det indbyggede forløb).
    func runRequest(for workout: Workout) -> RunRequest? {
        guard let plan = workout.timeBasedPlan() else { return nil }
        return RunRequest(
            plan: plan,
            programWeekId: 0,
            programPhase: .base,
            countsTowardProgression: false
        )
    }
}

struct PlanLibraryView: View {
    @State var viewModel: PlanLibraryViewModel
    var onRun: (RunRequest) -> Void = { _ in }
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        BuildWorkoutView(
                            viewModel: BuildWorkoutViewModel(environment: viewModel.environment),
                            onRun: run
                        )
                    } label: {
                        Label { Text(Strings.Workout.buildTitle) } icon: {
                            Image(systemName: "slider.horizontal.3")
                        }
                    }
                }

                Section {
                    if viewModel.workouts.isEmpty {
                        Text(Strings.Workout.noneSaved)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(viewModel.workouts) { workout in
                            workoutRow(workout)
                        }
                    }
                } header: {
                    Text(Strings.Workout.mySection)
                }
            }
            .navigationTitle(Text(Strings.Workout.libraryTitle))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button { dismiss() } label: { Text(Strings.Common.done) }
                }
            }
            .onAppear { viewModel.load() }
        }
    }

    private func workoutRow(_ workout: Workout) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(workout.name).font(.headline)
                Text(Strings.Workout.runCount(workout.runIntervalCount))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                if let request = viewModel.runRequest(for: workout) { run(request) }
            } label: {
                Image(systemName: "play.circle.fill").font(.title2)
            }
            .buttonStyle(.plain)
            .foregroundStyle(Theme.Colors.brand)
            .accessibilityLabel(Text(Strings.Workout.runNow))
        }
        .swipeActions {
            Button(role: .destructive) { viewModel.delete(workout) } label: {
                Label { Text(Strings.Common.delete) } icon: { Image(systemName: "trash") }
            }
        }
    }

    /// Kør en tur: værten lukker biblioteket og starter turen.
    private func run(_ request: RunRequest) {
        onRun(request)
    }
}
