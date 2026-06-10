import Foundation
import StjernelobCore
import SwiftUI

/// Tur-resumé med fejring (spec afsnit 4.4 / 7.5): konfetti, dagens stjerner, en
/// opmuntrende besked, et blidt "Hvordan føltes det?", et kropssignal-tjek
/// (skadesforebyggelse) og en lille valgfri refleksion. Fejringen gælder for at
/// have *gennemført* turen — ikke fart.
struct SummaryView: View {
    let summary: WorkoutSummary
    var onClose: (SummaryResult) -> Void

    /// Hvad brugeren angav i resuméet.
    struct SummaryResult {
        var effort: Int?
        var bodySignal: BodySignal?
        var reflection: String?
    }

    @State private var effort: Double = 5
    @State private var didRate = false
    @State private var bodySignal: BodySignal? = nil
    @State private var reflection: String = ""

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
                    bodyCheckIn
                    if bodySignal == .specificPain { careCard }
                    reflectionField

                    Button {
                        onClose(result)
                    } label: {
                        Text(Strings.Summary.close)
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal, Theme.Spacing.large)
                    .padding(.bottom, Theme.Spacing.large)
                }
                .frame(maxWidth: .infinity)
            }

            if summary.isComplete {
                ConfettiView()
            }
        }
    }

    private var result: SummaryResult {
        SummaryResult(
            effort: didRate ? Int(effort) : nil,
            bodySignal: bodySignal,
            reflection: reflection.trimmingCharacters(in: .whitespacesAndNewlines)
        )
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

    private var bodyCheckIn: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            Text(Strings.Summary.bodyQuestion)
                .font(.headline)
            ForEach(BodySignal.allCases) { signal in
                Button {
                    withAnimation(.easeOut(duration: 0.2)) {
                        bodySignal = (bodySignal == signal) ? nil : signal
                    }
                } label: {
                    HStack(spacing: Theme.Spacing.small) {
                        Image(systemName: signal.symbolName)
                            .foregroundStyle(signal.tint)
                        Text(signal.displayLabel)
                            .foregroundStyle(.primary)
                        Spacer()
                        if bodySignal == signal {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Theme.Colors.brand)
                        }
                    }
                    .padding(Theme.Spacing.small)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.Radius.button)
                            .stroke(
                                bodySignal == signal ? Theme.Colors.brand : Color.secondary
                                    .opacity(0.25),
                                lineWidth: bodySignal == signal ? 2 : 1
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(Theme.Spacing.medium)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: Theme.Radius.card))
        .padding(.horizontal, Theme.Spacing.large)
    }

    private var careCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            Label { Text(Strings.Summary.careTitle) } icon: {
                Image(systemName: "heart.text.square.fill").foregroundStyle(Theme.Colors.running)
            }
            .font(.headline)
            Text(Strings.Summary.careBody)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Spacing.medium)
        .background(
            Theme.Colors.running.opacity(0.10),
            in: RoundedRectangle(cornerRadius: Theme.Radius.card)
        )
        .padding(.horizontal, Theme.Spacing.large)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    private var reflectionField: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            Text(Strings.Summary.reflectionPrompt)
                .font(.headline)
            TextField(
                String(localized: Strings.Summary.reflectionPlaceholder),
                text: $reflection,
                axis: .vertical
            )
            .textFieldStyle(.roundedBorder)
            .lineLimit(2...4)
        }
        .padding(Theme.Spacing.medium)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: Theme.Radius.card))
        .padding(.horizontal, Theme.Spacing.large)
    }
}
