import Foundation
import SwiftData

// SwiftData-modeller — kilden til sandhed lokalt på enheden (jf. arkitektur.md).
// Modellerne holder kun primitive felter og *referencer* til filer (billeder/
// ruter gemmes som filer med Data Protection, ikke i databasen). De mappes til
// og fra Sendable DTO'er (se DTOs.swift), så domæne- og præsentationslag aldrig
// rører persistensen direkte.

/// Brugerens profil og placering i forløbet. Der findes præcis én pr. enhed.
@Model
final class ProfileEntity {
    var hasRunBefore: Bool
    var defaultWeeklySessions: Int
    var currentWeekIndex: Int
    var roleRawValue: String
    var onboardingComplete: Bool
    // Helbredsscreening fra onboarding (afsnit 7.1) — minimal og kun lokalt.
    var hasPainOrInjury: Bool
    var hasHeartOrLungCondition: Bool
    var advisedToConsultDoctor: Bool
    var createdAt: Date

    init(
        hasRunBefore: Bool = false,
        defaultWeeklySessions: Int = 3,
        currentWeekIndex: Int = 0,
        roleRawValue: String = UserRole.runner.rawValue,
        onboardingComplete: Bool = false,
        hasPainOrInjury: Bool = false,
        hasHeartOrLungCondition: Bool = false,
        advisedToConsultDoctor: Bool = false,
        createdAt: Date = Date()
    ) {
        self.hasRunBefore = hasRunBefore
        self.defaultWeeklySessions = defaultWeeklySessions
        self.currentWeekIndex = currentWeekIndex
        self.roleRawValue = roleRawValue
        self.onboardingComplete = onboardingComplete
        self.hasPainOrInjury = hasPainOrInjury
        self.hasHeartOrLungCondition = hasHeartOrLungCondition
        self.advisedToConsultDoctor = advisedToConsultDoctor
        self.createdAt = createdAt
    }
}

/// En gennemført (eller afbrudt) tur i historikken.
@Model
final class CompletedWorkoutEntity {
    @Attribute(.unique) var id: UUID
    var date: Date
    var programWeekId: Int
    var phaseRawValue: String
    var plannedIntervalCount: Int
    var intervalsCompleted: Int
    var runIntervalsCompleted: Int
    var activeSeconds: Double
    var isComplete: Bool
    var starsEarned: Int
    var perceivedEffort: Int?

    @Relationship(deleteRule: .cascade, inverse: \WorkoutPhotoEntity.workout)
    var photos: [WorkoutPhotoEntity]

    init(
        id: UUID = UUID(),
        date: Date,
        programWeekId: Int,
        phaseRawValue: String,
        plannedIntervalCount: Int,
        intervalsCompleted: Int,
        runIntervalsCompleted: Int,
        activeSeconds: Double,
        isComplete: Bool,
        starsEarned: Int,
        perceivedEffort: Int? = nil,
        photos: [WorkoutPhotoEntity] = []
    ) {
        self.id = id
        self.date = date
        self.programWeekId = programWeekId
        self.phaseRawValue = phaseRawValue
        self.plannedIntervalCount = plannedIntervalCount
        self.intervalsCompleted = intervalsCompleted
        self.runIntervalsCompleted = runIntervalsCompleted
        self.activeSeconds = activeSeconds
        self.isComplete = isComplete
        self.starsEarned = starsEarned
        self.perceivedEffort = perceivedEffort
        self.photos = photos
    }
}

/// Reference til et billede knyttet til en tur. Selve billedfilen ligger på
/// disk med Data Protection — her gemmes kun filnavn og metadata (afsnit 14.2).
@Model
final class WorkoutPhotoEntity {
    @Attribute(.unique) var id: UUID
    var fileName: String
    var caption: String?
    var createdAt: Date
    var workout: CompletedWorkoutEntity?

    init(id: UUID = UUID(), fileName: String, caption: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.fileName = fileName
        self.caption = caption
        self.createdAt = createdAt
    }
}

/// Brugerens valgte ugemål for en bestemt uge (afsnit 6.2).
@Model
final class WeeklyGoalEntity {
    var yearForWeekOfYear: Int
    var weekOfYear: Int
    var targetSessions: Int

    init(yearForWeekOfYear: Int, weekOfYear: Int, targetSessions: Int) {
        self.yearForWeekOfYear = yearForWeekOfYear
        self.weekOfYear = weekOfYear
        self.targetSessions = targetSessions
    }
}

/// Frys/pause-status for en uge (tilgivende streak, afsnit 5.3).
@Model
final class WeekStatusEntity {
    var yearForWeekOfYear: Int
    var weekOfYear: Int
    var isFrozen: Bool
    var isPaused: Bool

    init(yearForWeekOfYear: Int, weekOfYear: Int, isFrozen: Bool = false, isPaused: Bool = false) {
        self.yearForWeekOfYear = yearForWeekOfYear
        self.weekOfYear = weekOfYear
        self.isFrozen = isFrozen
        self.isPaused = isPaused
    }
}

/// Et optjent badge (afsnit 5.4).
@Model
final class EarnedBadgeEntity {
    @Attribute(.unique) var rawValue: String
    var earnedAt: Date

    init(rawValue: String, earnedAt: Date = Date()) {
        self.rawValue = rawValue
        self.earnedAt = earnedAt
    }
}
