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
                    HStack(spacing: Theme.Spacing.small) {
                        ForEach(viewModel.allDays, id: \.self) { day in
                            dayToggle(day)
                        }
                    }
                    .padding(.vertical, Theme.Spacing.small)

                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { viewModel.suggestEvenly() }
                    } label: {
                        Label { Text(Strings.Planner.suggestEvenly) } icon: {
                            Image(systemName: "wand.and.stars")
                        }
                    }
                } header: {
                    Text(Strings.Planner.chooseDays)
                } footer: {
                    Text(Strings.Planner.chooseDaysNote)
                }

                Section {
                    Text(viewModel.canSave
                        ? Strings.Planner.daysPerWeek(viewModel.sessionCount)
                        : Strings.Planner.pickAtLeastOne)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(viewModel.canSave ? Theme.Colors.brand : .secondary)
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
                    .disabled(!viewModel.canSave)
                }
            }
            .onAppear { viewModel.load() }
        }
    }

    /// Én ugedag som en knap, man kan slå til/fra som træningsdag.
    private func dayToggle(_ day: Int) -> some View {
        let selected = viewModel.isSelected(day)
        return Button {
            withAnimation(.easeInOut(duration: 0.15)) { viewModel.toggle(day) }
        } label: {
            Text(viewModel.weekdayName(day))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(selected ? Color.white : .primary)
                .padding(.vertical, Theme.Spacing.small)
                .frame(maxWidth: .infinity)
                .background(
                    selected ? Theme.Colors.brand : Theme.Colors.brand.opacity(0.12),
                    in: RoundedRectangle(cornerRadius: Theme.Radius.button)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(viewModel.weekdayName(day)))
        .accessibilityAddTraits(selected ? [.isSelected, .isButton] : .isButton)
    }
}

#Preview {
    WeekPlannerView(viewModel: WeekPlannerViewModel(environment: .preview))
}
