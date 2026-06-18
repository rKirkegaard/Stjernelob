import StjernelobCore
import SwiftUI

/// Blid, ikke-dømmende formulering af en validator-bekymring (spec afsnit 6).
extension PlanConcern {
    var message: LocalizedStringResource {
        switch self {
        case .bigJumpFromCurrentLevel: Strings.PlanCheck.bigJump
        case .fastWeeklyIncrease: Strings.PlanCheck.fastIncrease
        case .tooFewRestDays: Strings.PlanCheck.tooFewRestDays
        case .veryLongWorkout: Strings.PlanCheck.veryLong
        }
    }
}
