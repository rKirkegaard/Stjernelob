import Observation
import StjernelobCore
import SwiftUI
import UniformTypeIdentifiers

/// Importér en træningsplan fra en fil (spec afsnit 5): vælg fil → forhåndsvis
/// (uger, ture, tid) → blid validator-nudge → gem og evt. brug som aktiv plan.
@MainActor
@Observable
final class ImportPlanViewModel {
    enum Phase: Equatable {
        case idle
        case preview(TrainingPlan, PlanValidation)
        case failed
    }

    private(set) var phase: Phase = .idle
    private let environment: AppEnvironment

    init(environment: AppEnvironment) {
        self.environment = environment
    }

    func load(from result: Result<[URL], Error>) {
        guard let url = (try? result.get())?.first else { phase = .failed; return }
        let didAccess = url.startAccessingSecurityScopedResource()
        defer { if didAccess { url.stopAccessingSecurityScopedResource() } }
        guard let data = try? Data(contentsOf: url),
              let plan = try? TrainingPlanImporter.decode(data)
        else {
            phase = .failed
            return
        }
        phase = .preview(plan, PlanValidator.review(plan: plan))
    }

    /// Gem den importerede plan; valgfrit sæt den som den aktive plan.
    func save(setActive: Bool) {
        guard case let .preview(plan, _) = phase else { return }
        try? environment.planLibraryRepository.savePlan(plan)
        if setActive, var profile = try? environment.profileRepository.load() {
            profile.activePlanId = plan.id
            profile.activePlanWeek = 1
            try? environment.profileRepository.save(profile)
            environment.refreshWidget()
            environment.sendCurrentSessionToWatch()
        }
    }

    /// Samlet varighed for en uge i minutter (alle ture, inkl. auto opvarmning).
    func weekMinutes(_ plan: TrainingPlan, week: Int) -> Int {
        let seconds = plan.workouts(inWeek: week).reduce(0) { sum, workout in
            sum + (workout.timeBasedPlan()?.intervals.reduce(0) {
                $0 + Int($1.duration.components.seconds)
            } ?? 0)
        }
        return (seconds + 59) / 60
    }
}

struct ImportPlanView: View {
    @State var viewModel: ImportPlanViewModel
    @State private var showFileImporter = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            switch viewModel.phase {
            case .idle: idle
            case let .preview(plan, validation): preview(plan, validation)
            case .failed: failed
            }
        }
        .navigationTitle(Text(Strings.PlanImport.title))
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            viewModel.load(from: result)
        }
    }

    private var idle: some View {
        ContentUnavailableView {
            Label { Text(Strings.PlanImport.title) } icon: {
                Image(systemName: "square.and.arrow.down")
            }
        } description: {
            Text(Strings.PlanImport.intro)
        } actions: {
            Button { showFileImporter = true } label: { Text(Strings.PlanImport.chooseFile) }
                .buttonStyle(.borderedProminent)
        }
    }

    private var failed: some View {
        ContentUnavailableView {
            Label { Text(Strings.PlanImport.errorTitle) } icon: {
                Image(systemName: "exclamationmark.triangle")
            }
        } description: {
            Text(Strings.PlanImport.errorBody)
        } actions: {
            Button { showFileImporter = true } label: { Text(Strings.PlanImport.chooseFile) }
                .buttonStyle(.borderedProminent)
        }
    }

    private func preview(_ plan: TrainingPlan, _ validation: PlanValidation) -> some View {
        Form {
            Section {
                Text(plan.name).font(.headline)
                Text(Strings.PlanImport.weekCount(plan.weekNumbers.count))
                    .foregroundStyle(.secondary)
            }

            if let concern = validation.concerns.first {
                Section {
                    Label {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(Strings.PlanImport.nudgeTitle).font(.subheadline.weight(.semibold))
                            Text(concern.message).font(.footnote).foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "heart.text.square").foregroundStyle(Theme.Colors.restful)
                    }
                }
            }

            Section {
                ForEach(plan.weekNumbers, id: \.self) { week in
                    Text(Strings.PlanImport.weekSummary(
                        week: week,
                        workouts: plan.workouts(inWeek: week).count,
                        minutes: viewModel.weekMinutes(plan, week: week)
                    ))
                }
            } header: {
                Text(Strings.PlanImport.weeksSection)
            }

            Section {
                Button {
                    viewModel.save(setActive: true)
                    dismiss()
                } label: {
                    Text(Strings.PlanImport.saveAndUse).frame(maxWidth: .infinity)
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    viewModel.save(setActive: false)
                    dismiss()
                } label: {
                    Text(Strings.PlanImport.saveOnly).frame(maxWidth: .infinity)
                }
            }
        }
    }
}
