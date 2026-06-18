import StjernelobCore
import SwiftUI

/// Hjem/dashboard (spec afsnit 7.2). Viser status og enten dagens tur eller en
/// hyggelig hviledags-visning. Knapper fører videre til tur og ugeplanlægger.
struct HomeView: View {
    @State var viewModel: HomeViewModel
    var onStartRun: (RunRequest) -> Void = { _ in }
    var onAdjustWeek: () -> Void = {}
    var onOpenLibrary: () -> Void = {}

    @Environment(AppEnvironment.self) private var environment

    /// Sværhedsgrad bundet til de delte indstillinger. Når den ændres, genberegnes
    /// dagens (skalerede) plan, og ur + widget opdateres.
    private var intensityBinding: Binding<TrainingIntensity> {
        Binding(
            get: { environment.settings.trainingIntensity },
            set: { newValue in
                environment.settings.trainingIntensity = newValue
                viewModel.load()
                environment.refreshWidget()
                environment.sendCurrentSessionToWatch()
            }
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.large) {
                heroCard
                statsRow

                if let activePlan = viewModel.activePlan {
                    activePlanCard(activePlan)
                } else if viewModel.isRestDay {
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

                Button {
                    onOpenLibrary()
                } label: {
                    Label {
                        Text(Strings.Workout.libraryTitle)
                    } icon: {
                        Image(systemName: "square.stack.3d.up")
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
                    Text(Strings.Badges.levelProgress(
                        into: viewModel.levelProgress.pointsIntoLevel,
                        span: span
                    ))
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
            stat(
                systemImage: "star.fill",
                tint: Theme.Colors.star,
                text: Text(Strings.Home.starsTotal(viewModel.totalStars))
            )
            stat(
                systemImage: "flame.fill",
                tint: Theme.Colors.running,
                text: Text(Strings.Home.streak(weeks: viewModel.streakWeeks))
            )
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

            VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                Text(Strings.Difficulty.section)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                Picker(selection: intensityBinding) {
                    ForEach(TrainingIntensity.allCases) { intensity in
                        Text(intensity.displayName).tag(intensity)
                    }
                } label: {
                    Text(Strings.Difficulty.section)
                }
                .pickerStyle(.segmented)
                Text(Strings.Difficulty.note)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

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

    /// Kort for en aktiv egen/importeret plan: ugenavigation + ugens ture.
    private func activePlanCard(_ plan: TrainingPlan) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            Text(plan.name).font(.headline)

            HStack {
                Button { viewModel.goToPreviousPlanWeek() } label: {
                    Image(systemName: "chevron.left")
                }
                .disabled(!viewModel.canGoToPreviousPlanWeek)
                .accessibilityLabel(Text(Strings.Home.previousWeek))
                Spacer()
                Text(Strings.Home.planWeek(
                    week: viewModel.activePlanWeek,
                    of: viewModel.activePlanWeekCount
                ))
                .font(.subheadline.weight(.semibold))
                Spacer()
                Button { viewModel.advancePlanWeek() } label: {
                    Image(systemName: "chevron.right")
                }
                .disabled(!viewModel.canAdvancePlanWeek)
                .accessibilityLabel(Text(Strings.Home.nextWeek))
            }
            .buttonStyle(.bordered)

            if viewModel.activePlanWorkouts.isEmpty {
                Text(Strings.Home.planRestDay)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.activePlanWorkouts) { workout in
                    planWorkoutRow(workout)
                }
            }
        }
        .padding(Theme.Spacing.medium)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: Theme.Radius.card))
    }

    private func planWorkoutRow(_ workout: Workout) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(workout.name).font(.subheadline.weight(.semibold))
                Text(Strings.Workout.runCount(workout.runIntervalCount))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                if let request = viewModel.runRequest(for: workout) { onStartRun(request) }
            } label: {
                Image(systemName: "play.circle.fill").font(.title2)
            }
            .buttonStyle(.plain)
            .foregroundStyle(Theme.Colors.brand)
            .accessibilityLabel(Text(Strings.Workout.runNow))
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    NavigationStack {
        HomeView(viewModel: HomeViewModel(environment: .preview))
    }
}
