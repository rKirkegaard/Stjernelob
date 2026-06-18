import Foundation
import StjernelobCore

/// Ugemål for en bestemt uge.
struct WeeklyGoalDTO: Equatable {
    var week: WeekIdentifier
    var targetSessions: Int
}

/// Frys/pause-status for en uge.
struct WeekStatusDTO: Equatable {
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
    /// Knyt et billede (allerede gemt som fil) til en eksisterende tur.
    func addPhoto(_ photo: WorkoutPhotoDTO, toWorkoutWithId id: UUID) throws
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

/// Bibliotek af egne ture og egne/importerede planer (spec: egne intervaller og
/// planimport). Personlige data — lokalt/privat iCloud som resten.
@MainActor
protocol PlanLibraryRepository {
    func savedWorkouts() throws -> [Workout]
    func saveWorkout(_ workout: Workout) throws
    func deleteWorkout(id: UUID) throws
    func savedPlans() throws -> [TrainingPlan]
    func plan(id: UUID) throws -> TrainingPlan?
    func savePlan(_ plan: TrainingPlan) throws
    func deletePlan(id: UUID) throws
}

/// GDPR: "slet alle mine data" skal kaskadere (afsnit 14, arkitektur.md).
@MainActor
protocol DataEraser {
    func eraseAllData() throws
}
