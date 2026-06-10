import SwiftUI

/// Ugeplanlægger-skærm: vælg antal ture og se de foreslåede dage med hviledage
/// imellem (spec afsnit 7.3).
struct WeekPlannerView: View {
    @State var viewModel: WeekPlannerViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Stepper(value: $viewModel.sessionsPerWeek, in: 1...5) {
                        Text(Strings.Planner.sessionsValue(viewModel.sessionsPerWeek))
                            .monospacedDigit()
                    }
                } header: {
                    Text(Strings.Planner.sessionsQuestion)
                }

                Section {
                    HStack(spacing: Theme.Spacing.small) {
                        ForEach(viewModel.trainingDays, id: \.self) { day in
                            Text(viewModel.weekdayName(day))
                                .font(.subheadline.weight(.semibold))
                                .padding(.vertical, Theme.Spacing.small)
                                .frame(maxWidth: .infinity)
                                .background(
                                    Theme.Colors.brand.opacity(0.15),
                                    in: RoundedRectangle(cornerRadius: Theme.Radius.button)
                                )
                        }
                    }
                } header: {
                    Text(Strings.Planner.suggestedDays)
                } footer: {
                    Text(Strings.Planner.restDayNote)
                }
            }
            .navigationTitle(Text(Strings.Planner.title))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        viewModel.save()
                        dismiss()
                    } label: {
                        Text(Strings.Common.save)
                    }
                }
            }
            .onAppear { viewModel.load() }
        }
    }
}

#Preview {
    WeekPlannerView(viewModel: WeekPlannerViewModel(environment: .preview))
}
