import StjernelobCore
import SwiftUI

/// Samling: niveau-fremgang og badges (optjente fremhævet, resten dæmpede).
/// Nogle mærker kan appen ikke måle — dem låser barnet selv op ved at trykke.
struct BadgesView: View {
    @State var viewModel: BadgesViewModel
    @State private var badgeToClaim: Badge?

    private let columns = [GridItem(.adaptive(minimum: 100), spacing: Theme.Spacing.medium)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                levelCard

                ForEach(viewModel.sections) { section in
                    categorySection(section)
                }

                Text(Strings.Badges.manualNote)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(Theme.Spacing.medium)
        }
        .navigationTitle(Text(Strings.Badges.title))
        .onAppear { viewModel.load() }
        .confirmationDialog(
            badgeToClaim
                .map { Text(Strings.Badges.claimTitle(String(localized: $0.displayTitle))) } ??
                Text(""),
            isPresented: Binding(
                get: { badgeToClaim != nil },
                set: { if !$0 { badgeToClaim = nil } }
            ),
            titleVisibility: .visible,
            presenting: badgeToClaim
        ) { badge in
            Button { viewModel.claim(badge) } label: { Text(Strings.Badges.unlock) }
            Button(role: .cancel) {} label: { Text(Strings.Badges.cancel) }
        } message: { badge in
            Text(badge.displayDetail)
        }
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

    private func categorySection(_ section: BadgesViewModel.CategorySection) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            Text(section.category.displayName).font(.headline)
            LazyVGrid(columns: columns, spacing: Theme.Spacing.medium) {
                ForEach(section.badges) { badge in
                    let earned = viewModel.isEarned(badge)
                    if !earned, badge.isManual {
                        Button { badgeToClaim = badge } label: { badgeCell(badge, earned: false) }
                            .buttonStyle(.plain)
                    } else {
                        badgeCell(badge, earned: earned)
                    }
                }
            }
        }
    }

    private func badgeCell(_ badge: Badge, earned: Bool) -> some View {
        VStack(spacing: Theme.Spacing.small) {
            ZStack {
                Circle().fill(badge.paletteBackground)
                Text(badge.emoji).font(.system(size: 30))
            }
            .frame(width: 64, height: 64)

            Text(badge.displayTitle)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(earned ? badge.paletteInk : Color.secondary)
                .multilineTextAlignment(.center)

            if !earned, badge.isManual {
                Text(Strings.Badges.tapToUnlock)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
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
