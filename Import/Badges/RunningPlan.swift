import Foundation

// MARK: - Programme Phase

enum Phase: String, Codable, CaseIterable {
    case firstSteps = "Første skridt" // Uge 1–4
    case buildingUp = "Bygger op" // Uge 5–8
    case findingStrength = "Finder styrken" // Uge 9–12
    case confidentRunner = "Løber med selvtillid" // Uge 13–16
    case continuousRunner = "Kontinuerlig løber" // Uge 17–20
}

enum Difficulty: String, Codable {
    case easy = "nem"
    case steady = "rolig"
    case medium
    case strong = "stærk"
    case advanced = "avanceret"
}

// MARK: - Interval

/// One run/walk block within a session
struct Interval: Codable, Identifiable {
    let id: UUID
    var runSeconds: Int // 0 means walk-only block (e.g. warmup/cooldown)
    var walkSeconds: Int // 0 means run-only (used in late weeks)
    var repetitions: Int
    var displayNote: String // Human-readable, e.g. "5 × 30 sek løb / 75 sek gang"

    init(
        id: UUID = UUID(),
        runSeconds: Int,
        walkSeconds: Int,
        repetitions: Int,
        displayNote: String
    ) {
        self.id = id
        self.runSeconds = runSeconds
        self.walkSeconds = walkSeconds
        self.repetitions = repetitions
        self.displayNote = displayNote
    }

    /// Total active seconds for this interval block
    var totalSeconds: Int {
        (runSeconds + walkSeconds) * repetitions
    }
}

// MARK: - Session

/// One planned training session (a single "tur")
struct Session: Codable, Identifiable {
    let id: UUID
    var label: String // "Tur 1", "Tur 2 (bonus)" etc.
    var warmupMinutes: Int // Always walking
    var intervals: [Interval]
    var cooldownMinutes: Int // Always walking
    var isBonus: Bool // Bonus sessions don't count toward weekly goal

    init(
        id: UUID = UUID(),
        label: String,
        warmupMinutes: Int,
        intervals: [Interval],
        cooldownMinutes: Int,
        isBonus: Bool = false
    ) {
        self.id = id
        self.label = label
        self.warmupMinutes = warmupMinutes
        self.intervals = intervals
        self.cooldownMinutes = cooldownMinutes
        self.isBonus = isBonus
    }

    /// Estimated total session duration in seconds
    var estimatedDurationSeconds: Int {
        let warmup = warmupMinutes * 60
        let cool = cooldownMinutes * 60
        let work = intervals.reduce(0) { $0 + $1.totalSeconds }
        return warmup + work + cool
    }
}

// MARK: - PlanWeek

/// One week in the 20-week programme
struct PlanWeek: Codable, Identifiable {
    let id: UUID
    var weekNumber: Int // 1–20
    var phase: Phase
    var title: String
    var difficulty: Difficulty
    var coachTip: String
    var badgeSlug: String // References Badge.slug
    var plannedSessions: [Session]

    init(
        id: UUID = UUID(),
        weekNumber: Int,
        phase: Phase,
        title: String,
        difficulty: Difficulty,
        coachTip: String,
        badgeSlug: String,
        plannedSessions: [Session]
    ) {
        self.id = id
        self.weekNumber = weekNumber
        self.phase = phase
        self.title = title
        self.difficulty = difficulty
        self.coachTip = coachTip
        self.badgeSlug = badgeSlug
        self.plannedSessions = plannedSessions
    }

    /// Minimum sessions required to mark week as completed (bonus excluded)
    var requiredSessionCount: Int {
        plannedSessions.filter { !$0.isBonus }.count
    }
}

// MARK: - RunningPlan

/// The full 20-week programme as loaded from JSON
struct RunningPlan: Codable {
    var programName: String
    var targetAudience: String
    var totalWeeks: Int
    var weeks: [PlanWeek]

    /// Fetch a specific week by 1-based week number
    func week(_ number: Int) -> PlanWeek? {
        weeks.first { $0.weekNumber == number }
    }

    /// All weeks belonging to a given phase
    func weeks(in phase: Phase) -> [PlanWeek] {
        weeks.filter { $0.phase == phase }
    }

    /// First week of a given phase
    func firstWeek(of phase: Phase) -> PlanWeek? {
        weeks(in: phase).min(by: { $0.weekNumber < $1.weekNumber })
    }
}

// MARK: - JSON Loading

extension RunningPlan {
    /// Load the bundled løbeprogram_20uger.json
    static func loadFromBundle() throws -> RunningPlan {
        guard let url = Bundle.main.url(
            forResource: "løbeprogram_20uger",
            withExtension: "json"
        ) else {
            throw RunningPlanError.fileNotFound
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(RunningPlan.self, from: data)
    }
}

enum RunningPlanError: LocalizedError {
    case fileNotFound
    case decodingFailed(String)

    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            "løbeprogram_20uger.json not found in app bundle."
        case let .decodingFailed(detail):
            "Failed to decode running plan: \(detail)"
        }
    }
}
