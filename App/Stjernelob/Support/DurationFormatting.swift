import Foundation
import StjernelobCore

extension Duration {
    /// Hele sekunder i tidsrummet.
    var wholeSeconds: Int { Int(components.seconds) }

    /// "mm:ss" — til den store nedtælling under en tur.
    var minutesSecondsText: String {
        let total = max(0, wholeSeconds)
        return String(format: "%d:%02d", total / 60, total % 60)
    }

    /// Et kort, menneskeligt udtryk, fx "1 min" eller "1:30 min".
    var shortText: String {
        let total = max(0, wholeSeconds)
        if total % 60 == 0 {
            return "\(total / 60) min"
        }
        return "\(minutesSecondsText) min"
    }
}
