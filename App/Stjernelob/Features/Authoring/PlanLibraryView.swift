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
    private(set) var plans: [TrainingPlan] = []
    private(set) var activePlanId: UUID?

    init(environment: AppEnvironment) {
        self.environment = environment
    }

    func load() {
        workouts = (try? environment.planLibraryRepository.savedWorkouts()) ?? []
        plans = (try? environment.planLibraryRepository.savedPlans()) ?? []
        activePlanId = (try? environment.profileRepository.load())?.activePlanId
    }

    func delete(_ workout: Workout) {
        try? environment.planLibraryRepository.deleteWorkout(id: workout.id)
        load()
    }

    func isActive(_ plan: TrainingPlan) -> Bool { plan.id == activePlanId }

    /// Sæt en egen/importeret plan som den aktive (driver hjemmeskærmen).
    func activate(_ plan: TrainingPlan) {
        setActivePlan(plan.id, week: 1)
    }

    /// Gå tilbage til det indbyggede program.
    func useBuiltIn() {
        setActivePlan(nil, week: 1)
    }

    func deletePlan(_ plan: TrainingPlan) {
        try? environment.planLibraryRepository.deletePlan(id: plan.id)
        if activePlanId == plan.id { setActivePlan(nil, week: 1) }
        load()
    }

    private func setActivePlan(_ id: UUID?, week: Int) {
        if var profile = try? environment.profileRepository.load() {
            profile.activePlanId = id
            profile.activePlanWeek = week
            try? environment.profileRepository.save(profile)
            environment.refreshWidget()
            environment.sendCurrentSessionToWatch()
        }
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
                    NavigationLink {
                        ImportPlanView(viewModel: ImportPlanViewModel(environment: viewModel
                                .environment))
                    } label: {
                        Label { Text(Strings.PlanImport.title) } icon: {
                            Image(systemName: "square.and.arrow.down")
                        }
                    }
                }

                if !viewModel.plans.isEmpty || viewModel.activePlanId != nil {
                    Section {
                        ForEach(viewModel.plans) { plan in
                            planRow(plan)
                        }
                        if viewModel.activePlanId != nil {
                            Button { viewModel.useBuiltIn() } label: {
                                Label { Text(Strings.Workout.useBuiltIn) } icon: {
                                    Image(systemName: "star.fill")
                                }
                            }
                        }
                    } header: {
                        Text(Strings.Workout.plansSection)
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

    private func planRow(_ plan: TrainingPlan) -> some View {
        let active = viewModel.isActive(plan)
        return HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(plan.name).font(.headline)
                Text(Strings.Workout.planWeekCount(plan.weekNumbers.count))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if active {
                Text(Strings.Workout.activeTag)
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, Theme.Spacing.small)
                    .padding(.vertical, 2)
                    .background(Theme.Colors.brand.opacity(0.2), in: Capsule())
            } else {
                Button { viewModel.activate(plan) } label: {
                    Text(Strings.Workout.usePlan)
                }
                .buttonStyle(.bordered)
            }
        }
        .swipeActions {
            Button(role: .destructive) { viewModel.deletePlan(plan) } label: {
                Label { Text(Strings.Common.delete) } icon: { Image(systemName: "trash") }
            }
        }
    }

    /// Kør en tur: værten lukker biblioteket og starter turen.
    private func run(_ request: RunRequest) {
        onRun(request)
    }
}
