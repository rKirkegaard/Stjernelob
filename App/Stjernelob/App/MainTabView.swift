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
        }
        .sheet(isPresented: $showPlanner) {
            WeekPlannerView(viewModel: WeekPlannerViewModel(
                environment: environment,
                onSaved: {}
            ))
        }
        .fullScreenCover(item: $runRequest) { request in
            ActiveRunContainer(request: request, onClose: { runRequest = nil })
        }
    }
}
