import SwiftUI

/// watchOS-ledsageren (spec afsnit 10): styr turen og mærk intervalskift på
/// håndleddet uden at tage telefonen op. Kører på den platform-uafhængige
/// `StjernelobCore`, så intervalmotoren er den samme som på telefonen.
@main
struct StjernelobWatchApp: App {
    var body: some Scene {
        WindowGroup {
            WatchRunView()
        }
    }
}
