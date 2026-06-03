import Foundation
import ActivityKit

/// Delt mellem app og widget, så Live Activity'en (under en igangværende tur,
/// spec afsnit 10) refererer til præcis samme type i begge moduler.
///
/// Indholdet er bevidst neutralt: aktuelt interval og nedtælling — aldrig fart
/// eller pres.
public struct RunActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        /// Lokaliseret navn på det aktuelle interval (fx "Løb"). Appen leverer
        /// den færdige tekst, så widget-laget ikke skal lokalisere.
        public var intervalLabel: String
        public var isRunning: Bool
        public var remainingSeconds: Int
        public var totalRemainingSeconds: Int

        public init(intervalLabel: String, isRunning: Bool, remainingSeconds: Int, totalRemainingSeconds: Int) {
            self.intervalLabel = intervalLabel
            self.isRunning = isRunning
            self.remainingSeconds = remainingSeconds
            self.totalRemainingSeconds = totalRemainingSeconds
        }
    }

    public var planTitle: String

    public init(planTitle: String) {
        self.planTitle = planTitle
    }
}
