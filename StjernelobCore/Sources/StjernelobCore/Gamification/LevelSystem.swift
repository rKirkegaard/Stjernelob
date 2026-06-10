import Foundation

/// Hvor brugeren er i niveau-systemet: niveau, point optjent inde i niveauet og
/// hvor mange point niveauet spænder over. Bruges til en fremgangslinje.
public struct LevelProgress: Sendable, Equatable {
    public let level: Int
    public let pointsIntoLevel: Int
    public let pointsForLevel: Int? // nil på sidste niveau (intet loft)
    public let isMaxLevel: Bool

    public var fraction: Double {
        guard let span = pointsForLevel, span > 0 else { return 1 }
        return min(1, Double(pointsIntoLevel) / Double(span))
    }
}

/// Omsætter samlede point til niveauer (jf. spec afsnit 5.2). Niveauerne
/// afspejler **indsats over tid**, ikke fart — point kommer fra stjerner, som
/// gives for gennemførsel.
public struct LevelSystem: Sendable, Equatable {
    /// Akkumulerede point-tærskler for at *nå* hvert niveau. `thresholds[0]`
    /// skal være 0 (niveau 1 fra start).
    public let thresholds: [Int]

    public init(thresholds: [Int]) {
        precondition(thresholds.first == 0, "Niveau 1 skal starte ved 0 point")
        precondition(thresholds == thresholds.sorted(), "Tærskler skal være stigende")
        self.thresholds = thresholds
    }

    /// Standardforløb fra Niveau 1 ("Første skridt") til Niveau 10 ("Løber").
    /// Blødt stigende, så de første niveauer kommer hurtigt (tidlig motivation).
    public static let standard = LevelSystem(thresholds: [
        0, 25, 60, 110, 180, 280, 420, 620, 900, 1300,
    ])

    public var maxLevel: Int { thresholds.count }

    /// 1-baseret niveau for et givet pointtal.
    public func level(forPoints points: Int) -> Int {
        var level = 1
        for (index, threshold) in thresholds.enumerated() where points >= threshold {
            level = index + 1
        }
        return level
    }

    public func progress(forPoints points: Int) -> LevelProgress {
        let level = level(forPoints: points)
        let lowerThreshold = thresholds[level - 1]
        let isMax = level >= maxLevel
        let span = isMax ? nil : thresholds[level] - lowerThreshold
        return LevelProgress(
            level: level,
            pointsIntoLevel: points - lowerThreshold,
            pointsForLevel: span,
            isMaxLevel: isMax
        )
    }
}

/// Hvordan stjerner omsættes til point (spec afsnit 5.2).
public enum Points {
    /// 1 stjerne = 1 point i udgangspunktet — point er blot den akkumulerede sum.
    public static func fromStars(_ stars: Int) -> Int { stars }
}
