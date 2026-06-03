import SwiftUI
import StjernelobCore

/// Samling: niveau-fremgang og badges (optjente fremhævet, resten dæmpede).
struct BadgesView: View {
    @State var viewModel: BadgesViewModel

    private let columns = [GridItem(.adaptive(minimum: 100), spacing: Theme.Spacing.medium)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                levelCard

                if !viewModel.earnedBadges.isEmpty {
                    section(Text(Strings.Badges.earnedSection), badges: viewModel.earnedBadges, earned: true)
                }
                section(Text(Strings.Badges.lockedSection), badges: viewModel.lockedBadges, earned: false)
            }
            .padding(Theme.Spacing.medium)
        }
        .navigationTitle(Text(Strings.Badges.title))
        .onAppear { viewModel.load() }
    }

    private var levelCard: some View {
        let progress = viewModel.levelProgress
        return VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            HStack {
                Image(systemName: "rosette").foregroundStyle(Theme.Colors.brand)
                Text(Strings.Home.level(progress.level)).font(.headline)
            }
            ProgressView(value: progress.fraction)
                .tint(Theme.Colors.brand)
            if let span = progress.pointsForLevel {
                Text(Strings.Badges.levelProgress(into: progress.pointsIntoLevel, span: span))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(Theme.Spacing.medium)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: Theme.Radius.card))
    }

    private func section(_ title: Text, badges: [Badge], earned: Bool) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            title.font(.headline)
            LazyVGrid(columns: columns, spacing: Theme.Spacing.medium) {
                ForEach(badges) { badge in
                    badgeCell(badge, earned: earned)
                }
            }
        }
    }

    private func badgeCell(_ badge: Badge, earned: Bool) -> some View {
        VStack(spacing: Theme.Spacing.small) {
            Image(systemName: badge.symbolName)
                .font(.system(size: 34))
                .foregroundStyle(earned ? Theme.Colors.star : Color.secondary)
            Text(badge.displayTitle)
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.medium)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: Theme.Radius.card))
        .opacity(earned ? 1 : 0.5)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(badge.displayTitle))
        .accessibilityHint(Text(badge.displayDetail))
    }
}

#Preview {
    NavigationStack {
        BadgesView(viewModel: BadgesViewModel(environment: .preview))
    }
}
