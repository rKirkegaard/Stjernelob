import SwiftUI
import StjernelobCore

/// Hjem/dashboard (spec afsnit 7.2). Viser status og enten dagens tur eller en
/// hyggelig hviledags-visning. Knapper fører videre til tur og ugeplanlægger.
struct HomeView: View {
    @State var viewModel: HomeViewModel
    var onStartRun: (RunRequest) -> Void = { _ in }
    var onAdjustWeek: () -> Void = {}

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.large) {
                heroCard
                statsRow

                if viewModel.isRestDay {
                    RestDayView()
                } else if let plan = viewModel.todaysPlan {
                    nextSessionCard(plan)
                }

                Button {
                    onAdjustWeek()
                } label: {
                    Label {
                        Text(Strings.Home.adjustWeek)
                    } icon: {
                        Image(systemName: "calendar")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .padding(Theme.Spacing.medium)
        }
        .background(Theme.Colors.screenGradient.ignoresSafeArea())
        .navigationTitle(Text(Strings.App.name))
        .onAppear { viewModel.load() }
    }

    private var heroCard: some View {
        HStack(spacing: Theme.Spacing.large) {
            MascotView(level: viewModel.level)
            VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                Text(Strings.Home.level(viewModel.level))
                    .font(.title3.weight(.bold))
                ProgressView(value: viewModel.levelProgress.fraction)
                    .tint(Theme.Colors.brand)
                if let span = viewModel.levelProgress.pointsForLevel {
                    Text(Strings.Badges.levelProgress(into: viewModel.levelProgress.pointsIntoLevel, span: span))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer(minLength: 0)
        }
        .card()
    }

    private var statsRow: some View {
        HStack(spacing: Theme.Spacing.medium) {
            stat(systemImage: "star.fill", tint: Theme.Colors.star, text: Text(Strings.Home.starsTotal(viewModel.totalStars)))
            stat(systemImage: "flame.fill", tint: Theme.Colors.running, text: Text(Strings.Home.streak(weeks: viewModel.streakWeeks)))
        }
    }

    private func stat(systemImage: String, tint: Color, text: Text) -> some View {
        VStack(spacing: Theme.Spacing.small) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(tint)
            text
                .font(.subheadline)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.medium)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: Theme.Radius.card))
        .accessibilityElement(children: .combine)
    }

    private func nextSessionCard(_ plan: WorkoutPlan) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            Text(Strings.Home.nextSessionTitle)
                .font(.headline)

            PlanSummaryView(plan: plan)

            Button {
                if let week = viewModel.currentWeek {
                    onStartRun(RunRequest(
                        plan: plan,
                        programWeekId: week.id,
                        programPhase: week.phase
                    ))
                }
            } label: {
                Text(Strings.Home.startRun)
                    .frame(maxWidth: .infinity)
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(Theme.Spacing.medium)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: Theme.Radius.card))
    }
}

#Preview {
    NavigationStack {
        HomeView(viewModel: HomeViewModel(environment: .preview))
    }
}
