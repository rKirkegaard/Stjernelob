import StjernelobCore
import SwiftUI

/// Hovednavigationen. Flere faner (fremgang, samling, indstillinger) kommer til,
/// efterhånden som skærmene bygges.
struct MainTabView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var showPlanner = false
    @State private var runRequest: RunRequest?
    @State private var resumableRecord: ActiveRunRecord?

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
                Label { Text(Strings.Progress.title) } icon: {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                }
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
            environment.refreshWidget()
            if let record = environment.runStateStore.load(), record.isResumable(asOf: Date()) {
                resumableRecord = record
            }
        }
        .confirmationDialog(
            Text(Strings.ActiveRun.resumeTitle),
            isPresented: Binding(
                get: { resumableRecord != nil },
                set: { if !$0 { resumableRecord = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button { resumeSavedRun() } label: { Text(Strings.ActiveRun.resumeYes) }
            Button(role: .destructive) {
                environment.runStateStore.clear()
                resumableRecord = nil
            } label: { Text(Strings.ActiveRun.discard) }
        } message: {
            Text(Strings.ActiveRun.resumeBody)
        }
        .sheet(isPresented: $showPlanner) {
            WeekPlannerView(viewModel: WeekPlannerViewModel(
                environment: environment,
                onSaved: {
                    environment.sendCurrentSessionToWatch()
                    environment.refreshWidget()
                }
            ))
        }
        .fullScreenCover(item: $runRequest) { request in
            ActiveRunContainer(request: request, onClose: { runRequest = nil })
        }
    }

    private func resumeSavedRun() {
        guard let record = resumableRecord else { return }
        runRequest = RunRequest(
            plan: record.plan,
            programWeekId: record.programWeekId,
            programPhase: record.programPhase,
            resumeElapsed: record.elapsed(asOf: Date())
        )
        resumableRecord = nil
    }
}
