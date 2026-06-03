import WidgetKit
import SwiftUI
import ActivityKit
import StjernelobShared

/// Live Activity under en igangværende tur (spec afsnit 10): låseskærm og
/// Dynamic Island viser aktuelt interval og nedtælling — neutralt, intet pres.
struct RunLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RunActivityAttributes.self) { context in
            HStack {
                Image(systemName: context.state.isRunning ? "figure.run" : "figure.walk")
                    .font(.title2)
                VStack(alignment: .leading) {
                    Text(context.state.intervalLabel).font(.headline)
                    Text(timeText(context.state.remainingSeconds)).font(.title3).monospacedDigit()
                }
                Spacer()
            }
            .padding()
            .activityBackgroundTint(Color.black.opacity(0.4))
            .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: context.state.isRunning ? "figure.run" : "figure.walk")
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.intervalLabel).font(.headline)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(timeText(context.state.remainingSeconds)).monospacedDigit()
                }
            } compactLeading: {
                Image(systemName: context.state.isRunning ? "figure.run" : "figure.walk")
            } compactTrailing: {
                Text(timeText(context.state.remainingSeconds)).monospacedDigit()
            } minimal: {
                Image(systemName: context.state.isRunning ? "figure.run" : "figure.walk")
            }
        }
    }

    private func timeText(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}
