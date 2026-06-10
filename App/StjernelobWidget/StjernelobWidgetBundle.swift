import SwiftUI
import WidgetKit

/// Widget-bundtet. Live Activity (under en igangværende tur) tilføjes som et
/// ekstra medlem her, når den delte attribut-type er på plads.
@main
struct StjernelobWidgetBundle: WidgetBundle {
    var body: some Widget {
        NextRunWidget()
        RunLiveActivity()
    }
}
