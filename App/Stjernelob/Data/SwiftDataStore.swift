import Foundation
import SwiftData
import StjernelobCore

/// SwiftData-baseret implementering af alle repositories. Bruger
/// hovedkonteksten og er derfor @MainActor. Den lokale database er kilden til
/// sandhed (offline-først); CloudKit-synk kan lægges ovenpå senere uden at
/// ændre repository-grænsefladerne.
@MainActor
final class SwiftDataStore {
    let container: ModelContainer
    private var context: ModelContext { container.mainContext }

    init(container: ModelContainer) {
        self.container = container
    }

    /// Alle modeltyper i skemaet ét sted.
    static let schema = Schema([
        ProfileEntity.self,
        CompletedWorkoutEntity.self,
        WorkoutPhotoEntity.self,
        WeeklyGoalEntity.self,
        WeekStatusEntity.self,
        EarnedBadgeEntity.self,
    ])

    /// Standard-container. Forsøger vedvarende lagring; falder tilbage til
    /// hukommelse, så appen altid kan starte (og en tom database er bedre end
    /// et crash).
    static func makeDefault() -> SwiftDataStore {
        if let persistent = try? ModelContainer(
            for: schema,
            configurations: ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        ) {
            return SwiftDataStore(container: persistent)
        }
        return makeInMemory()
    }

    static func makeInMemory() -> SwiftDataStore {
        // En in-memory container bør altid kunne oprettes; hvis ikke, er der
        // ingen meningsfuld fallback, og det er korrekt at fejle tydeligt.
        do {
            let container = try ModelContainer(
                for: schema,
                configurations: ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            )
            return SwiftDataStore(container: container)
        } catch {
            fatalError("Kunne ikke oprette in-memory ModelContainer: \(error)")
        }
    }
}

// MARK: - ProfileRepository

extension SwiftDataStore: ProfileRepository {
    func load() throws -> ProfileDTO? {
        try context.fetch(FetchDescriptor<ProfileEntity>()).first.map(ProfileDTO.init(entity:))
    }

    func save(_ profile: ProfileDTO) throws {
        let existing = try context.fetch(FetchDescriptor<ProfileEntity>()).first
        let entity: ProfileEntity
        if let existing {
            entity = existing
        } else {
            entity = ProfileEntity()
            context.insert(entity)
        }
        profile.apply(to: entity)
        try context.save()
    }
}

// MARK: - WorkoutRepository

extension SwiftDataStore: WorkoutRepository {
    func add(_ workout: CompletedWorkoutDTO) throws {
        let entity = CompletedWorkoutEntity(
            id: workout.id,
            date: workout.date,
            programWeekId: workout.programWeekId,
            phaseRawValue: workout.phase.rawValue,
            plannedIntervalCount: workout.plannedIntervalCount,
            intervalsCompleted: workout.intervalsCompleted,
            runIntervalsCompleted: workout.runIntervalsCompleted,
            activeSeconds: Double(workout.activeDuration.components.seconds),
            isComplete: workout.isComplete,
            starsEarned: workout.starsEarned,
            perceivedEffort: workout.perceivedEffort,
            distanceMeters: workout.distanceMeters
        )
        context.insert(entity)
        for photo in workout.photos {
            let photoEntity = WorkoutPhotoEntity(
                id: photo.id, fileName: photo.fileName,
                caption: photo.caption, createdAt: photo.createdAt
            )
            photoEntity.workout = entity
            context.insert(photoEntity)
        }
        try context.save()
    }

    func all() throws -> [CompletedWorkoutDTO] {
        let descriptor = FetchDescriptor<CompletedWorkoutEntity>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try context.fetch(descriptor).map(CompletedWorkoutDTO.init(entity:))
    }

    func recent(limit: Int) throws -> [CompletedWorkoutDTO] {
        var descriptor = FetchDescriptor<CompletedWorkoutEntity>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return try context.fetch(descriptor).map(CompletedWorkoutDTO.init(entity:))
    }

    func count() throws -> Int {
        try context.fetchCount(FetchDescriptor<CompletedWorkoutEntity>())
    }

    func addPhoto(_ photo: WorkoutPhotoDTO, toWorkoutWithId id: UUID) throws {
        let descriptor = FetchDescriptor<CompletedWorkoutEntity>(
            predicate: #Predicate { $0.id == id }
        )
        guard let workout = try context.fetch(descriptor).first else { return }
        let entity = WorkoutPhotoEntity(
            id: photo.id, fileName: photo.fileName,
            caption: photo.caption, createdAt: photo.createdAt
        )
        entity.workout = workout
        context.insert(entity)
        try context.save()
    }
}

// MARK: - WeeklyPlanRepository

extension SwiftDataStore: WeeklyPlanRepository {
    func goal(for week: WeekIdentifier) throws -> WeeklyGoalDTO? {
        let year = week.yearForWeekOfYear
        let weekNo = week.weekOfYear
        let descriptor = FetchDescriptor<WeeklyGoalEntity>(
            predicate: #Predicate { $0.yearForWeekOfYear == year && $0.weekOfYear == weekNo }
        )
        return try context.fetch(descriptor).first.map {
            WeeklyGoalDTO(week: week, targetSessions: $0.targetSessions)
        }
    }

    func setGoal(_ goal: WeeklyGoalDTO) throws {
        let year = goal.week.yearForWeekOfYear
        let weekNo = goal.week.weekOfYear
        let descriptor = FetchDescriptor<WeeklyGoalEntity>(
            predicate: #Predicate { $0.yearForWeekOfYear == year && $0.weekOfYear == weekNo }
        )
        if let existing = try context.fetch(descriptor).first {
            existing.targetSessions = goal.targetSessions
        } else {
            context.insert(WeeklyGoalEntity(
                yearForWeekOfYear: year, weekOfYear: weekNo, targetSessions: goal.targetSessions
            ))
        }
        try context.save()
    }

    func allGoals() throws -> [WeeklyGoalDTO] {
        try context.fetch(FetchDescriptor<WeeklyGoalEntity>()).map {
            WeeklyGoalDTO(
                week: WeekIdentifier(yearForWeekOfYear: $0.yearForWeekOfYear, weekOfYear: $0.weekOfYear),
                targetSessions: $0.targetSessions
            )
        }
    }

    func status(for week: WeekIdentifier) throws -> WeekStatusDTO? {
        let year = week.yearForWeekOfYear
        let weekNo = week.weekOfYear
        let descriptor = FetchDescriptor<WeekStatusEntity>(
            predicate: #Predicate { $0.yearForWeekOfYear == year && $0.weekOfYear == weekNo }
        )
        return try context.fetch(descriptor).first.map {
            WeekStatusDTO(week: week, isFrozen: $0.isFrozen, isPaused: $0.isPaused)
        }
    }

    func setStatus(_ status: WeekStatusDTO) throws {
        let year = status.week.yearForWeekOfYear
        let weekNo = status.week.weekOfYear
        let descriptor = FetchDescriptor<WeekStatusEntity>(
            predicate: #Predicate { $0.yearForWeekOfYear == year && $0.weekOfYear == weekNo }
        )
        if let existing = try context.fetch(descriptor).first {
            existing.isFrozen = status.isFrozen
            existing.isPaused = status.isPaused
        } else {
            context.insert(WeekStatusEntity(
                yearForWeekOfYear: year, weekOfYear: weekNo,
                isFrozen: status.isFrozen, isPaused: status.isPaused
            ))
        }
        try context.save()
    }

    func allStatuses() throws -> [WeekStatusDTO] {
        try context.fetch(FetchDescriptor<WeekStatusEntity>()).map {
            WeekStatusDTO(
                week: WeekIdentifier(yearForWeekOfYear: $0.yearForWeekOfYear, weekOfYear: $0.weekOfYear),
                isFrozen: $0.isFrozen, isPaused: $0.isPaused
            )
        }
    }
}

// MARK: - BadgeRepository

extension SwiftDataStore: BadgeRepository {
    func earned() throws -> Set<Badge> {
        let entities = try context.fetch(FetchDescriptor<EarnedBadgeEntity>())
        return Set(entities.compactMap { Badge(rawValue: $0.rawValue) })
    }

    func award(_ badge: Badge) throws {
        let raw = badge.rawValue
        let descriptor = FetchDescriptor<EarnedBadgeEntity>(
            predicate: #Predicate { $0.rawValue == raw }
        )
        if try context.fetch(descriptor).isEmpty {
            context.insert(EarnedBadgeEntity(rawValue: raw))
            try context.save()
        }
    }
}

// MARK: - DataEraser

extension SwiftDataStore: DataEraser {
    func eraseAllData() throws {
        try context.delete(model: WorkoutPhotoEntity.self)
        try context.delete(model: CompletedWorkoutEntity.self)
        try context.delete(model: WeeklyGoalEntity.self)
        try context.delete(model: WeekStatusEntity.self)
        try context.delete(model: EarnedBadgeEntity.self)
        try context.delete(model: ProfileEntity.self)
        try context.save()
        // Billedfiler på disk slettes af et separat fil-lag (kommer med foto-UI).
    }
}
