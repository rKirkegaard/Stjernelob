import SwiftUI
import StjernelobCore

/// Hovednavigationen. Flere faner (fremgang, samling, indstillinger) kommer til,
/// efterhånden som skærmene bygges.
struct MainTabView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var showPlanner = false
    @State private var runRequest: RunRequest?

    var body: some View {
        TabView {
            NavigationStack {
                HomeView(
                    viewModel: HomeViewModel(environment: environment),
                    onStartRun: { runRequest = $0 },
                    onAdjustWeek: { showPlanner = true }
                )
            }
            .tabItem {
                Label {
                    Text(Strings.App.name)
                } icon: {
                    Image(systemName: "house.fill")
                }
            }

            NavigationStack {
                HistoryView(viewModel: HistoryViewModel(environment: environment))
            }
            .tabItem {
                Label { Text(Strings.Progress.title) } icon: { Image(systemName: "chart.line.uptrend.xyaxis") }
            }

            NavigationStack {
                BadgesView(viewModel: BadgesViewModel(environment: environment))
            }
            .tabItem {
                Label { Text(Strings.Badges.title) } icon: { Image(systemName: "rosette") }
            }

            NavigationStack {
                SettingsView(
                    settings: environment.settings,
                    onErase: { environment.eraseAllData() }
                )
            }
            .tabItem {
                Label { Text(Strings.Settings.title) } icon: { Image(systemName: "gearshape.fill") }
            }
        }
        .task {
            environment.activateWatchSync()
            environment.sendCurrentSessionToWatch()
        }
        .sheet(isPresented: $showPlanner) {
            WeekPlannerView(viewModel: WeekPlannerViewModel(
                environment: environment,
                onSaved: { environment.sendCurrentSessionToWatch() }
            ))
        }
        .fullScreenCover(item: $runRequest) { request in
            ActiveRunContainer(request: request, onClose: { runRequest = nil })
        }
    }
}
