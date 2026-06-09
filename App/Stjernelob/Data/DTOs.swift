import Foundation
import StjernelobCore

/// Rolle ved login (afsnit 11.1). Forælder-rollen er støtte, ikke overvågning.
enum UserRole: String, Sendable, Codable, CaseIterable {
    case runner
    case parent
}

/// Minimal helbredsscreening fra onboarding (afsnit 7.1). Bruges kun til at
/// anbefale en lægesnak ved advarselstegn — aldrig til vurdering eller pres.
struct HealthScreening: Sendable, Equatable, Codable {
    var hasPainOrInjury: Bool = false
    var hasHeartOrLungCondition: Bool = false

    /// Om appen bør anbefale at tale med egen læge først.
    var shouldAdviseDoctor: Bool { hasPainOrInjury || hasHeartOrLungCondition }
}

/// Sendable øjebliksbillede af profilen, som ViewModels og views bruger.
struct ProfileDTO: Sendable, Equatable {
    var hasRunBefore: Bool
    var defaultWeeklySessions: Int
    var currentWeekIndex: Int
    var completedSessionsThisProgramWeek: Int = 0
    var role: UserRole
    var onboardingComplete: Bool
    var health: HealthScreening
}

/// Sendable repræsentation af en gennemført tur.
struct CompletedWorkoutDTO: Sendable, Equatable, Identifiable {
    var id: UUID
    var date: Date
    var programWeekId: Int
    var phase: ProgramPhase
    var plannedIntervalCount: Int
    var intervalsCompleted: Int
    var runIntervalsCompleted: Int
    var activeDuration: Duration
    var isComplete: Bool
    var starsEarned: Int
    var perceivedEffort: Int?
    var distanceMeters: Double? = nil
    /// Hvordan kroppen føltes bagefter (skadesforebyggelse). Valgfrit.
    var bodySignal: BodySignal? = nil
    /// Brugerens egen lille note efter turen ("hvad gik bedre end sidst?"). Valgfri.
    var reflection: String? = nil
    var photos: [WorkoutPhotoDTO]
}

struct WorkoutPhotoDTO: Sendable, Equatable, Identifiable {
    var id: UUID
    var fileName: String
    var caption: String?
    var createdAt: Date
}

// MARK: - Mapping mellem DTO og SwiftData-entitet

extension ProfileDTO {
    init(entity: ProfileEntity) {
        self.init(
            hasRunBefore: entity.hasRunBefore,
            defaultWeeklySessions: entity.defaultWeeklySessions,
            currentWeekIndex: entity.currentWeekIndex,
            completedSessionsThisProgramWeek: entity.completedSessionsThisProgramWeek,
            role: UserRole(rawValue: entity.roleRawValue) ?? .runner,
            onboardingComplete: entity.onboardingComplete,
            health: HealthScreening(
                hasPainOrInjury: entity.hasPainOrInjury,
                hasHeartOrLungCondition: entity.hasHeartOrLungCondition
            )
        )
    }

    func apply(to entity: ProfileEntity) {
        entity.hasRunBefore = hasRunBefore
        entity.defaultWeeklySessions = defaultWeeklySessions
        entity.currentWeekIndex = currentWeekIndex
        entity.completedSessionsThisProgramWeek = completedSessionsThisProgramWeek
        entity.roleRawValue = role.rawValue
        entity.onboardingComplete = onboardingComplete
        entity.hasPainOrInjury = health.hasPainOrInjury
        entity.hasHeartOrLungCondition = health.hasHeartOrLungCondition
        entity.advisedToConsultDoctor = health.shouldAdviseDoctor
    }
}

extension WorkoutPhotoDTO {
    init(entity: WorkoutPhotoEntity) {
        self.init(id: entity.id, fileName: entity.fileName,
                  caption: entity.caption, createdAt: entity.createdAt)
    }
}

extension CompletedWorkoutDTO {
    init(entity: CompletedWorkoutEntity) {
        self.init(
            id: entity.id,
            date: entity.date,
            programWeekId: entity.programWeekId,
            phase: ProgramPhase(rawValue: entity.phaseRawValue) ?? .base,
            plannedIntervalCount: entity.plannedIntervalCount,
            intervalsCompleted: entity.intervalsCompleted,
            runIntervalsCompleted: entity.runIntervalsCompleted,
            activeDuration: .seconds(entity.activeSeconds),
            isComplete: entity.isComplete,
            starsEarned: entity.starsEarned,
            perceivedEffort: entity.perceivedEffort,
            distanceMeters: entity.distanceMeters,
            bodySignal: entity.bodySignalRawValue.flatMap(BodySignal.init(rawValue:)),
            reflection: entity.reflection,
            photos: entity.photos
                .sorted { $0.createdAt < $1.createdAt }
                .map(WorkoutPhotoDTO.init(entity:))
        )
    }
}
