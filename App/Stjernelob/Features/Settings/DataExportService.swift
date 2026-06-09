import Foundation
import StjernelobCore

/// Bygger en menneske- og maskinlæsbar eksport af alle brugerens data
/// (dataportabilitet, GDPR afsnit 14.1). Billeder eksporteres som filreferencer;
/// rå billedfiler kan tilføjes en zip senere. Ingen tredjepart involveret.
@MainActor
struct DataExportService {
    let environment: AppEnvironment
    let exportedAt: () -> Date

    init(environment: AppEnvironment, exportedAt: @escaping () -> Date = { Date() }) {
        self.environment = environment
        self.exportedAt = exportedAt
    }

    struct Export: Codable {
        struct Profile: Codable {
            var hasRunBefore: Bool
            var defaultWeeklySessions: Int
            var currentWeekIndex: Int
            var role: String
            var onboardingComplete: Bool
        }
        struct Workout: Codable {
            var id: UUID
            var date: Date
            var programWeekId: Int
            var phase: String
            var intervalsCompleted: Int
            var plannedIntervalCount: Int
            var runIntervalsCompleted: Int
            var activeSeconds: Double
            var isComplete: Bool
            var starsEarned: Int
            var perceivedEffort: Int?
            var bodySignal: String?
            var reflection: String?
            var photoFileNames: [String]
        }
        struct Goal: Codable {
            var yearForWeekOfYear: Int
            var weekOfYear: Int
            var targetSessions: Int
        }
        var exportedAt: Date
        var profile: Profile?
        var workouts: [Workout]
        var goals: [Goal]
        var badges: [String]
    }

    func makeExport() -> Export {
        let profileDTO = try? environment.profileRepository.load()
        let profile = profileDTO.map {
            Export.Profile(
                hasRunBefore: $0.hasRunBefore,
                defaultWeeklySessions: $0.defaultWeeklySessions,
                currentWeekIndex: $0.currentWeekIndex,
                role: $0.role.rawValue,
                onboardingComplete: $0.onboardingComplete
            )
        }
        let workouts = ((try? environment.workoutRepository.all()) ?? []).map { workout in
            Export.Workout(
                id: workout.id,
                date: workout.date,
                programWeekId: workout.programWeekId,
                phase: workout.phase.rawValue,
                intervalsCompleted: workout.intervalsCompleted,
                plannedIntervalCount: workout.plannedIntervalCount,
                runIntervalsCompleted: workout.runIntervalsCompleted,
                activeSeconds: Double(workout.activeDuration.components.seconds),
                isComplete: workout.isComplete,
                starsEarned: workout.starsEarned,
                perceivedEffort: workout.perceivedEffort,
                bodySignal: workout.bodySignal?.rawValue,
                reflection: workout.reflection,
                photoFileNames: workout.photos.map(\.fileName)
            )
        }
        let goals = ((try? environment.weeklyPlanRepository.allGoals()) ?? []).map {
            Export.Goal(
                yearForWeekOfYear: $0.week.yearForWeekOfYear,
                weekOfYear: $0.week.weekOfYear,
                targetSessions: $0.targetSessions
            )
        }
        let badges = ((try? environment.badgeRepository.earned()) ?? []).map(\.rawValue).sorted()

        return Export(exportedAt: exportedAt(), profile: profile, workouts: workouts, goals: goals, badges: badges)
    }

    /// Skriv eksporten til en midlertidig .json-fil og returnér URL'en (til deling).
    func writeTemporaryFile() -> URL? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(makeExport()) else { return nil }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("stjernelob-data.json")
        do {
            try data.write(to: url, options: .atomic)
            return url
        } catch {
            return nil
        }
    }
}
