import Foundation

/// Samler ugernes fremdrift, fryser og pauser og udleder hver uges `WeekOutcome`
/// — grundlaget for streak-beregningen. Holder ingen brugervendt tekst; den
/// fortæller kun, hvordan ugerne står.
public struct WeeklyTracker: Sendable, Equatable {
    public private(set) var progress: [WeekIdentifier: WeekProgress]
    /// Uger reddet af en streak-fryser.
    public private(set) var frozenWeeks: Set<WeekIdentifier>
    /// Uger, hvor brugeren bevidst satte appen på pause.
    public private(set) var pausedWeeks: Set<WeekIdentifier>
    public var calendar: Calendar

    public init(
        progress: [WeekIdentifier: WeekProgress] = [:],
        frozenWeeks: Set<WeekIdentifier> = [],
        pausedWeeks: Set<WeekIdentifier> = [],
        calendar: Calendar = .iso8601Monday
    ) {
        self.progress = progress
        self.frozenWeeks = frozenWeeks
        self.pausedWeeks = pausedWeeks
        self.calendar = calendar
    }

    // MARK: - Opdatering

    public mutating func record(_ weekProgress: WeekProgress) {
        progress[weekProgress.week] = weekProgress
    }

    /// Brug en streak-fryser på en uge (sygdom, eksamen, ferie).
    public mutating func freeze(_ week: WeekIdentifier) {
        frozenWeeks.insert(week)
    }

    /// Markér en uge som bevidst pause.
    public mutating func pause(_ week: WeekIdentifier) {
        pausedWeeks.insert(week)
    }

    // MARK: - Udledning

    /// Udled en uges status. Pause og fryser vægter højest; derefter faktisk
    /// fremdrift. En ikke-færdig aktuel uge giver `nil` (i gang), så den ikke
    /// fejlagtigt bryder streaken.
    public func outcome(for week: WeekIdentifier, isCurrent: Bool) -> WeekOutcome? {
        if pausedWeeks.contains(week) { return .paused }
        if frozenWeeks.contains(week) { return .frozen }

        guard let weekProgress = progress[week] else {
            return nil
        }
        if weekProgress.isGoalMet { return .goalMet }
        return isCurrent ? nil : .missed
    }

    /// Den aktuelle streak set fra en given uge.
    public func currentStreak(asOf currentWeek: WeekIdentifier) -> Int {
        StreakCalculator.currentStreak(
            asOf: currentWeek,
            outcome: { week, isCurrent in outcome(for: week, isCurrent: isCurrent) },
            calendar: calendar
        )
    }
}
