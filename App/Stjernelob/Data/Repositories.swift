import Foundation
import StjernelobCore

/// Ugemål for en bestemt uge.
struct WeeklyGoalDTO: Sendable, Equatable {
    var week: WeekIdentifier
    var targetSessions: Int
}

/// Frys/pause-status for en uge.
struct WeekStatusDTO: Sendable, Equatable {
    var week: WeekIdentifier
    var isFrozen: Bool
    var isPaused: Bool
}

// Repository-protokoller abstraherer lagringen, så domæne- og præsentationslag
// ikke kender til SwiftData eller CloudKit (jf. arkitektur.md). De er
// @MainActor, fordi SwiftDatas hovedkontekst tilgås på hovedtråden.

@MainActor
protocol ProfileRepository {
    func load() throws -> ProfileDTO?
    func save(_ profile: ProfileDTO) throws
}

@MainActor
protocol WorkoutRepository {
    func add(_ workout: CompletedWorkoutDTO) throws
    func all() throws -> [CompletedWorkoutDTO]
    func recent(limit: Int) throws -> [CompletedWorkoutDTO]
    func count() throws -> Int
}

@MainActor
protocol WeeklyPlanRepository {
    func goal(for week: WeekIdentifier) throws -> WeeklyGoalDTO?
    func setGoal(_ goal: WeeklyGoalDTO) throws
    func allGoals() throws -> [WeeklyGoalDTO]
    func status(for week: WeekIdentifier) throws -> WeekStatusDTO?
    func setStatus(_ status: WeekStatusDTO) throws
    func allStatuses() throws -> [WeekStatusDTO]
}

@MainActor
protocol BadgeRepository {
    func earned() throws -> Set<Badge>
    func award(_ badge: Badge) throws
}

/// GDPR: "slet alle mine data" skal kaskadere (afsnit 14, arkitektur.md).
@MainActor
protocol DataEraser {
    func eraseAllData() throws
}
