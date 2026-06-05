import SwiftUI
import StjernelobCore

/// Forælder-dashboardet — vist her som "se præcis, hvad din forælder ser", så
/// barnet altid kan kontrollere delingen (spec afsnit 11.2). Samme visning kan
/// genbruges i forælder-rollen, når CloudKit-linket kobles på.
struct ParentDashboardView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var snapshot = ParentShareSnapshot()

    var body: some View {
        List {
            if snapshot.isEmpty {
                Section {
                    Text(Strings.Parent.nothingShared)
                        .foregroundStyle(.secondary)
                }
            } else {
                if let streak = snapshot.streakWeeks {
                    stat(systemImage: "flame.fill", tint: Theme.Colors.running, text: Text(Strings.Parent.streak(streak)))
                }
                if let completed = snapshot.completedCount {
                    stat(systemImage: "figure.run", tint: Theme.Colors.accent, text: Text(Strings.Parent.completed(completed)))
                }
                if let milestones = snapshot.milestones, !milestones.isEmpty {
                    Section(header: Text(Strings.Parent.milestonesTitle)) {
                        ForEach(milestones) { badge in
                            Label {
                                Text(badge.displayTitle)
                            } icon: {
                                Text(badge.emoji)
                            }
                        }
                    }
                }
            }

            Section {
                Text(Strings.Parent.supportNote)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(Text(Strings.Parent.title))
        .onAppear {
            snapshot = LocalSharingService(environment: environment).curatedSnapshot()
        }
    }

    private func stat(systemImage: String, tint: Color, text: Text) -> some View {
        Label {
            text.font(.headline)
        } icon: {
            Image(systemName: systemImage).foregroundStyle(tint)
        }
    }
}
