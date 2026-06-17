import StjernelobCore
import SwiftUI

/// Præsentation af den selvvalgte sværhedsgrad. Tonen er neutral og fleksibel —
/// det er brugerens eget valg, aldrig pres (jf. velbefindende-reglerne).
extension TrainingIntensity {
    var displayName: LocalizedStringResource {
        switch self {
        case .lighter: Strings.Difficulty.lighter
        case .standard: Strings.Difficulty.standard
        case .harder: Strings.Difficulty.harder
        }
    }
}
