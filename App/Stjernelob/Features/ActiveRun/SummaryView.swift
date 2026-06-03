import SwiftUI
import StjernelobCore

/// Tur-resumé med fejring (spec afsnit 4.4 / 7.5): konfetti, dagens stjerner, en
/// opmuntrende besked og et blidt "Hvordan føltes det?" (1–10) til den adaptive
/// justering. Fejringen gælder for at have *gennemført* turen — ikke fart.
struct SummaryView: View {
    let summary: WorkoutSummary
    /// Lukkes med den valgte oplevede anstrengelse (nil hvis ikke angivet).
    var onClose: (Int?) -> Void

    @State private var effort: Double = 5
    @State private var didRate = false

    private var stars: Int { Stars.earned(for: summary) }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.large) {
                    Text(Strings.Summary.title)
                        .font(.friendlyTitle)
                        .padding(.top, Theme.Spacing.xLarge)

                    HStack(spacing: Theme.Spacing.small) {
                        Image(systemName: "star.fill").foregroundStyle(Theme.Colors.star)
                        Text(Strings.Summary.stars(stars))
                            .font(.title2.weight(.bold))
                            .monospacedDigit()
                    }

                    Text(summary.isComplete ? Strings.Summary.completed : Strings.Summary.partial)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, Theme.Spacing.large)

                    effortPicker

                    Button {
                        onClose(didRate ? Int(effort) : nil)
                    } label: {
                        Text(Strings.Summary.close)
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal, Theme.Spacing.large)
                }
                .frame(maxWidth: .infinity)
            }

            if summary.isComplete {
                ConfettiView()
            }
        }
    }

    private var effortPicker: some View {
        VStack(spacing: Theme.Spacing.small) {
            Text(Strings.Summary.howDidItFeel)
                .font(.headline)
            Slider(value: $effort, in: 1...10, step: 1) {
                Text(Strings.Summary.howDidItFeel)
            } minimumValueLabel: {
                Text(Strings.Summary.effortEasy).font(.caption)
            } maximumValueLabel: {
                Text(Strings.Summary.effortHard).font(.caption)
            } onEditingChanged: { _ in
                didRate = true
            }
            .tint(Theme.Colors.brand)
            Text("\(Int(effort))")
                .font(.title3.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(didRate ? Theme.Colors.brand : .secondary)
        }
        .padding(Theme.Spacing.medium)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: Theme.Radius.card))
        .padding(.horizontal, Theme.Spacing.large)
    }
}
