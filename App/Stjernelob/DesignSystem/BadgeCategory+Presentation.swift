import Foundation
import StjernelobCore

/// Lokaliserede navne for badge-tema-grupperne i samlingen.
extension BadgeCategory {
    var displayName: LocalizedStringResource {
        switch self {
        case .firstSteps: Strings.Badges.categoryFirstSteps
        case .consistency: Strings.Badges.categoryConsistency
        case .weather: Strings.Badges.categoryWeather
        case .habits: Strings.Badges.categoryHabits
        case .social: Strings.Badges.categorySocial
        case .special: Strings.Badges.categorySpecial
        }
    }
}
