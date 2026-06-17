import Combine
import StjernelobCore
import SwiftUI

/// Under-tur-skærmen (spec afsnit 4.1): store, enkle tal der kan ses i et blik,
/// tydelig nedtælling, interval-status og stjernepop pr. interval. Tempo og
/// distance (målt via GPS/Core Motion) vises kun, hvis brugeren selv slår det
/// til i indstillinger — som standard er fokus på tid og gennemførsel, ikke fart.
struct ActiveRunView: View {
    @State var viewModel: ActiveRunViewModel
    var onClose: () -> Void

    @Environment(AppEnvironment.self) private var environment

    @State private var starScale: CGFloat = 0.1
    @State private var starVisible = false

    private let ticker = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()

    var body: some View {
        switch viewModel.phase {
        case let .finished(summary):
            SummaryView(summary: summary) { result in
                viewModel.saveResult(
                    perceivedEffort: result.effort,
                    bodySignal: result.bodySignal,
                    reflection: result.reflection,
                    stretchedAfter: result.stretchedAfter,
                    drankWater: result.drankWater
                )
                onClose()
            }
        default:
            runningBody
        }
    }

    private var runningBody: some View {
        let snapshot = viewModel.snapshot
        return VStack(spacing: Theme.Spacing.large) {
            Spacer()

            if let ordinal = snapshot.runOrdinal {
                Text(Strings.ActiveRun.intervalOfTotal(current: ordinal, total: snapshot.runCount))
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            Image(systemName: snapshot.interval.kind.symbolName)
                .font(.system(size: 56))
                .foregroundStyle(snapshot.interval.kind.color)
            Text(snapshot.interval.kind.label)
                .font(.title.weight(.bold))
                .foregroundStyle(snapshot.interval.kind.color)

            ZStack {
                Circle()
                    .stroke(snapshot.interval.kind.color.opacity(0.15), lineWidth: 14)
                Circle()
                    .trim(from: 0, to: intervalProgress(snapshot))
                    .stroke(
                        snapshot.interval.kind.color.gradient,
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.3), value: intervalProgress(snapshot))
                Text(snapshot.remainingInInterval.minutesSecondsText)
                    .font(.runCountdown)
                    .contentTransition(.numericText())
                    .accessibilityLabel(Text(Strings.ActiveRun.intervalOfTotal(
                        current: snapshot.runOrdinal ?? 0, total: snapshot.runCount
                    )))
            }
            .frame(width: 260, height: 260)
            .padding(.vertical, Theme.Spacing.medium)

            HStack(spacing: Theme.Spacing.large) {
                metric(icon: "clock", value: snapshot.totalElapsed.minutesSecondsText)
                if environment.settings.showPaceAndDistance {
                    metric(
                        icon: "point.topleft.down.curvedto.point.bottomright.up",
                        value: RunFormatting.distance(meters: viewModel.distanceMeters)
                    )
                    metric(
                        icon: "speedometer",
                        value: RunFormatting.pace(
                            elapsedSeconds: Double(snapshot.totalElapsed.wholeSeconds),
                            meters: viewModel.distanceMeters
                        )
                    )
                }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            if let title = MovementGuide.title(for: snapshot.interval.kind) {
                movementGuide(title: title, moves: MovementGuide.moves(for: snapshot.interval.kind))
            } else {
                Label {
                    Text(Strings.ActiveRun.talkTestHint)
                } icon: {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.top, Theme.Spacing.small)
            }

            Spacer()
            controls
        }
        .padding(Theme.Spacing.large)
        .overlay(alignment: .top) { starPop }
        .onAppear { viewModel.start() }
        .onReceive(ticker) { _ in viewModel.tick() }
        .onChange(of: viewModel.starPops) { _, _ in popStar() }
    }

    private func movementGuide(title: LocalizedStringResource, moves: [GuideMove]) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            ForEach(moves) { move in
                Label {
                    Text(move.text)
                } icon: {
                    Image(systemName: move.symbol).foregroundStyle(Theme.Colors.accent)
                }
                .font(.footnote)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Spacing.medium)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: Theme.Radius.card))
        .padding(.horizontal, Theme.Spacing.medium)
        .padding(.top, Theme.Spacing.small)
    }

    private func metric(icon: String, value: String) -> some View {
        Label {
            Text(value).monospacedDigit()
        } icon: {
            Image(systemName: icon)
        }
        .accessibilityElement(children: .combine)
    }

    private var controls: some View {
        HStack(spacing: Theme.Spacing.large) {
            Button(role: .destructive) {
                viewModel.stop()
            } label: {
                Label { Text(Strings.ActiveRun.stop) } icon: { Image(systemName: "stop.fill") }
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            if viewModel.phase == .paused {
                Button {
                    viewModel.resume()
                } label: {
                    Label { Text(Strings.ActiveRun.resume) } icon: { Image(systemName: "play.fill")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button {
                    viewModel.pause()
                } label: {
                    Label { Text(Strings.ActiveRun.pause) } icon: { Image(systemName: "pause.fill")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private var starPop: some View {
        Image(systemName: "star.fill")
            .font(.system(size: 64))
            .foregroundStyle(Theme.Colors.star)
            .scaleEffect(starScale)
            .opacity(starVisible ? 1 : 0)
            .accessibilityHidden(true)
    }

    private func intervalProgress(_ snapshot: WorkoutSnapshot) -> Double {
        let total = Double(snapshot.interval.duration.wholeSeconds)
        guard total > 0 else { return 0 }
        return Double(snapshot.elapsedInInterval.wholeSeconds) / total
    }

    private func popStar() {
        starVisible = true
        starScale = 0.1
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            starScale = 1.4
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.5)) {
            starVisible = false
        }
    }
}
