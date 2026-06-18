import Foundation
import StjernelobCore
import SwiftData

// SwiftData-modeller — kilden til sandhed lokalt på enheden (jf. arkitektur.md).
// Modellerne holder kun primitive felter og *referencer* til filer (billeder/
// ruter gemmes som filer med Data Protection, ikke i databasen). De mappes til
// og fra Sendable DTO'er (se DTOs.swift), så domæne- og præsentationslag aldrig
// rører persistensen direkte.
//
// CloudKit-kompatibilitet (privat synk): for at SwiftData kan spejle skemaet til
// brugerens private CloudKit-database må der ikke bruges `@Attribute(.unique)`,
// alle attributter skal have en defaultværdi, og relationer skal være optionelle.
// Entydighed (badges, uger) håndhæves derfor i koden i stedet for i skemaet.

/// Brugerens profil og placering i forløbet. Der findes præcis én pr. enhed.
@Model
final class ProfileEntity {
    var hasRunBefore: Bool = false
    var defaultWeeklySessions: Int = 3
    var currentWeekIndex: Int = 0
    /// Antal ture gennemført på den aktuelle programuge — nulstilles, når ugen
    /// vurderes og forløbet rykker (frem/gentag/tilbage).
    var completedSessionsThisProgramWeek: Int = 0
    var roleRawValue: String = UserRole.runner.rawValue
    var onboardingComplete: Bool = false
    // Helbredsscreening fra onboarding (afsnit 7.1) — minimal og kun lokalt.
    var hasPainOrInjury: Bool = false
    var hasHeartOrLungCondition: Bool = false
    var advisedToConsultDoctor: Bool = false
    var createdAt: Date = Date()
    /// Selvvalgte træningsdage (mandag-baseret 0...6). Tom = brug auto-forslag.
    var trainingDays: [Int] = []
    /// Aktiv egen/importeret plan. `nil` = det indbyggede program.
    var activePlanId: UUID?
    /// Aktuel uge i den aktive egen/importerede plan (1-baseret).
    var activePlanWeek: Int = 1

    init(
        hasRunBefore: Bool = false,
        defaultWeeklySessions: Int = 3,
        currentWeekIndex: Int = 0,
        completedSessionsThisProgramWeek: Int = 0,
        roleRawValue: String = UserRole.runner.rawValue,
        onboardingComplete: Bool = false,
        hasPainOrInjury: Bool = false,
        hasHeartOrLungCondition: Bool = false,
        advisedToConsultDoctor: Bool = false,
        createdAt: Date = Date(),
        trainingDays: [Int] = [],
        activePlanId: UUID? = nil,
        activePlanWeek: Int = 1
    ) {
        self.hasRunBefore = hasRunBefore
        self.defaultWeeklySessions = defaultWeeklySessions
        self.currentWeekIndex = currentWeekIndex
        self.completedSessionsThisProgramWeek = completedSessionsThisProgramWeek
        self.roleRawValue = roleRawValue
        self.onboardingComplete = onboardingComplete
        self.hasPainOrInjury = hasPainOrInjury
        self.hasHeartOrLungCondition = hasHeartOrLungCondition
        self.advisedToConsultDoctor = advisedToConsultDoctor
        self.createdAt = createdAt
        self.trainingDays = trainingDays
        self.activePlanId = activePlanId
        self.activePlanWeek = activePlanWeek
    }
}

/// En gemt egen-bygget tur (genbrugelig). Selve turen ligger som JSON (`Workout`
/// er Codable), så datamodellen er enkel og fremtidssikret.
@Model
final class SavedWorkoutEntity {
    var id: UUID = UUID()
    var name: String = ""
    var workoutData: Data = Data()
    var createdAt: Date = Date()

    init(id: UUID = UUID(), name: String, workoutData: Data, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.workoutData = workoutData
        self.createdAt = createdAt
    }
}

/// En gemt egen/importeret træningsplan. `TrainingPlan` gemmes som JSON.
@Model
final class SavedPlanEntity {
    var id: UUID = UUID()
    var name: String = ""
    var sourceRawValue: String = PlanSource.imported.rawValue
    var planData: Data = Data()
    var createdAt: Date = Date()

    init(
        id: UUID = UUID(),
        name: String,
        sourceRawValue: String,
        planData: Data,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.sourceRawValue = sourceRawValue
        self.planData = planData
        self.createdAt = createdAt
    }
}

/// En gennemført (eller afbrudt) tur i historikken.
@Model
final class CompletedWorkoutEntity {
    var id: UUID = UUID()
    var date: Date = Date()
    var programWeekId: Int = 0
    var phaseRawValue: String = ""
    var plannedIntervalCount: Int = 0
    var intervalsCompleted: Int = 0
    var runIntervalsCompleted: Int = 0
    var activeSeconds: Double = 0
    var isComplete: Bool = false
    var starsEarned: Int = 0
    var perceivedEffort: Int?
    /// Målt distance i meter (valgfrit; vist neutralt, aldrig grundlag for belønning).
    var distanceMeters: Double?
    /// Kropssignal efter turen (rå værdi af `BodySignal`). Valgfrit.
    var bodySignalRawValue: String?
    /// Brugerens egen lille note efter turen. Valgfri.
    var reflection: String?
    /// Strakte ud bagefter — et lille, valgfrit ja efter turen. Standard nej, så
    /// et ubesvaret spørgsmål aldrig tæller imod barnet.
    var stretchedAfter: Bool = false
    /// Huskede vand før og efter — et lille, valgfrit ja efter turen.
    var drankWater: Bool = false
    /// Det længste sammenhængende løb på turen, i sekunder (mærke-grundlag).
    var longestRunSeconds: Double?

    @Relationship(deleteRule: .cascade, inverse: \WorkoutPhotoEntity.workout)
    var photos: [WorkoutPhotoEntity]?

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
        distanceMeters: Double? = nil,
        bodySignalRawValue: String? = nil,
        reflection: String? = nil,
        stretchedAfter: Bool = false,
        drankWater: Bool = false,
        longestRunSeconds: Double? = nil,
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
        self.distanceMeters = distanceMeters
        self.bodySignalRawValue = bodySignalRawValue
        self.reflection = reflection
        self.stretchedAfter = stretchedAfter
        self.drankWater = drankWater
        self.longestRunSeconds = longestRunSeconds
        self.photos = photos
    }
}

/// Reference til et billede knyttet til en tur. Selve billedfilen ligger på
/// disk med Data Protection — her gemmes kun filnavn og metadata (afsnit 14.2).
@Model
final class WorkoutPhotoEntity {
    var id: UUID = UUID()
    var fileName: String = ""
    var caption: String?
    var createdAt: Date = Date()
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
    var yearForWeekOfYear: Int = 0
    var weekOfYear: Int = 0
    var targetSessions: Int = 0

    init(yearForWeekOfYear: Int, weekOfYear: Int, targetSessions: Int) {
        self.yearForWeekOfYear = yearForWeekOfYear
        self.weekOfYear = weekOfYear
        self.targetSessions = targetSessions
    }
}

/// Frys/pause-status for en uge (tilgivende streak, afsnit 5.3).
@Model
final class WeekStatusEntity {
    var yearForWeekOfYear: Int = 0
    var weekOfYear: Int = 0
    var isFrozen: Bool = false
    var isPaused: Bool = false

    init(yearForWeekOfYear: Int, weekOfYear: Int, isFrozen: Bool = false, isPaused: Bool = false) {
        self.yearForWeekOfYear = yearForWeekOfYear
        self.weekOfYear = weekOfYear
        self.isFrozen = isFrozen
        self.isPaused = isPaused
    }
}

/// Et optjent badge (afsnit 5.4). Entydighed på `rawValue` håndhæves i koden
/// (se `BadgeRepository.award`), da CloudKit-synk ikke tillader unikke felter.
@Model
final class EarnedBadgeEntity {
    var rawValue: String = ""
    var earnedAt: Date = Date()

    init(rawValue: String, earnedAt: Date = Date()) {
        self.rawValue = rawValue
        self.earnedAt = earnedAt
    }
}
