import Observation
import StjernelobCore
import SwiftUI

/// Byg din egen tur (spec afsnit 4): tilføj løb/gå-blokke, sæt længder i trin på
/// 15 sek, gentag hele mønsteret, se en live-forhåndsvisning, og gem/kør.
@MainActor
@Observable
final class BuildWorkoutViewModel {
    struct EditableStep: Identifiable {
        let id = UUID()
        var kind: IntervalKind
        var seconds: Int
    }

    var name: String
    var steps: [EditableStep]
    var repeats: Int

    private let environment: AppEnvironment
    static let stepSeconds = 15

    init(environment: AppEnvironment) {
        self.environment = environment
        name = String(localized: Strings.Workout.defaultName)
        steps = [
            EditableStep(kind: .run, seconds: 60),
            EditableStep(kind: .walk, seconds: 120),
        ]
        repeats = 6
    }

    func addStep(_ kind: IntervalKind) {
        steps.append(EditableStep(kind: kind, seconds: kind == .run ? 60 : 90))
    }

    func remove(at offsets: IndexSet) {
        steps.remove(atOffsets: offsets)
    }

    func adjust(_ step: EditableStep, bySeconds delta: Int) {
        guard let index = steps.firstIndex(where: { $0.id == step.id }) else { return }
        steps[index].seconds = max(Self.stepSeconds, steps[index].seconds + delta)
    }

    /// Det fulde mønster foldet ud (gentagelser).
    private var expandedSteps: [IntervalStep] {
        let pattern = steps
            .map { IntervalStep(kind: $0.kind, measure: .time(.seconds($0.seconds))) }
        return (0..<max(1, repeats)).flatMap { _ in pattern }
    }

    var workout: Workout { Workout(name: trimmedName, steps: expandedSteps) }
    var previewPlan: WorkoutPlan? { workout.timeBasedPlan() }
    private var trimmedName: String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? String(localized: Strings.Workout.defaultName) : trimmed
    }

    /// Samlet varighed (inkl. auto opvarmning/nedkøling), i sekunder.
    var totalSeconds: Int {
        previewPlan?.intervals.reduce(0) { $0 + Int($1.duration.components.seconds) } ?? 0
    }

    var runIntervalCount: Int { workout.runIntervalCount }
    var canSave: Bool { !steps.isEmpty && previewPlan != nil }

    /// Blid validering — for en enkelt tur er fx en meget lang tur det relevante.
    var validation: PlanValidation {
        PlanValidator.review(plan: TrainingPlan(
            name: trimmedName, source: .custom,
            schedule: [ScheduledWorkout(week: 1, workout: workout)]
        ))
    }

    func save() {
        guard canSave else { return }
        try? environment.planLibraryRepository.saveWorkout(workout)
    }

    /// En kør-nu-anmodning (tæller ikke i det indbyggede forløb).
    func makeRunRequest() -> RunRequest? {
        guard let plan = previewPlan else { return nil }
        return RunRequest(
            plan: plan,
            programWeekId: 0,
            programPhase: .base,
            countsTowardProgression: false
        )
    }
}

struct BuildWorkoutView: View {
    @State var viewModel: BuildWorkoutViewModel
    var onRun: (RunRequest) -> Void = { _ in }
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section {
                TextField(String(localized: Strings.Workout.name), text: $viewModel.name)
            } header: {
                Text(Strings.Workout.name)
            }

            Section {
                ForEach(viewModel.steps) { step in
                    stepRow(step)
                }
                .onDelete { viewModel.remove(at: $0) }

                HStack {
                    Button { viewModel.addStep(.run) } label: {
                        Label { Text(Strings.Interval.run) } icon: {
                            Image(systemName: "figure.run")
                        }
                    }
                    Spacer()
                    Button { viewModel.addStep(.walk) } label: {
                        Label { Text(Strings.Interval.walk) } icon: {
                            Image(systemName: "figure.walk")
                        }
                    }
                }
                .buttonStyle(.bordered)

                Stepper(value: $viewModel.repeats, in: 1...20) {
                    Text(Strings.Workout.repeats(viewModel.repeats))
                }
            } header: {
                Text(Strings.Workout.intervalsSection)
            } footer: {
                Text(Strings.Workout.intervalsNote)
            }

            Section {
                Text(Strings.Workout.summary(
                    time: clock(viewModel.totalSeconds),
                    runs: viewModel.runIntervalCount
                ))
                .font(.headline)
                if !viewModel.validation.isGentle {
                    Label {
                        Text(Strings.Workout.gentleNudge)
                    } icon: {
                        Image(systemName: "heart.text.square")
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
            } header: {
                Text(Strings.Workout.previewSection)
            }
        }
        .navigationTitle(Text(Strings.Workout.buildTitle))
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button { viewModel.save(); dismiss() } label: { Text(Strings.Common.save) }
                    .disabled(!viewModel.canSave)
            }
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    if let request = viewModel.makeRunRequest() { onRun(request) }
                } label: {
                    Label { Text(Strings.Workout.runNow) } icon: { Image(systemName: "play.fill") }
                }
                .disabled(!viewModel.canSave)
            }
        }
    }

    private func stepRow(_ step: BuildWorkoutViewModel.EditableStep) -> some View {
        HStack {
            Image(systemName: step.kind == .run ? "figure.run" : "figure.walk")
                .foregroundStyle(step.kind == .run ? Theme.Colors.running : Theme.Colors.walking)
            Text(step.kind == .run ? Strings.Interval.run : Strings.Interval.walk)
            Spacer()
            Stepper(
                value: Binding(
                    get: { step.seconds },
                    set: { viewModel.adjust(step, bySeconds: $0 - step.seconds) }
                ),
                in: BuildWorkoutViewModel.stepSeconds...3600,
                step: BuildWorkoutViewModel.stepSeconds
            ) {
                Text(clock(step.seconds)).monospacedDigit()
            }
        }
    }

    private func clock(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}
