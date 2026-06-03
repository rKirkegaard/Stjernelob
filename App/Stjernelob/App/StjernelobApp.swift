import SwiftUI

/// App-indgangen. Holder bevidst ingen logik — den vælger blot den første
/// skærm. Forretningslogik bor i domænelaget (`StjernelobCore`) og i
/// ViewModels (jf. `.claude/rules/arkitektur.md`).
@main
struct StjernelobApp: App {
    @State private var environment = AppEnvironment()

    var body: some Scene {
        WindowGroup {
            AppFlowView()
                .environment(environment)
        }
    }
}
