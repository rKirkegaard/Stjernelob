import Foundation

/// Det indbyggede forløb fra specifikationen (afsnit 6.1).
///
/// Grundforløbet bringer en begynder fra "har aldrig løbet" til 20–30 min
/// sammenhængende løb over 8 uger. Hver tur starter med 5 min rask gang og
/// slutter med 5 min gang. Derefter følger videre-forløb, så brugeren aldrig
/// står uden mål.
///
/// Tallene her er produktets "sandhed" og skal være fagligt gennemgået
/// (afsnit 15). Titlerne er lokaliseringsnøgler — den viste tekst ligger i
/// app-lagets strengkatalog.
public enum StandardProgram {
    private static let warmUp: Duration = .minutes(5)
    private static let coolDown: Duration = .minutes(5)

    /// Hele rejsen som én ordnet række uger (grundforløb + videre-forløb).
    public static let journey = TrainingProgram(weeks: makeWeeks())

    /// Kun grundforløbets 8 uger.
    public static var base: TrainingProgram {
        TrainingProgram(weeks: journey.weeks.filter { $0.phase == .base })
    }

    private static func makeWeeks() -> [ProgramWeek] {
        var weeks: [ProgramWeek] = []
        var id = 1
        func add(_ phase: ProgramPhase, _ session: SessionTemplate) {
            weeks.append(ProgramWeek(
                id: id,
                phase: phase,
                titleKey: "program.week.\(id).title",
                session: session
            ))
            id += 1
        }

        // --- Grundforløb (afsnit 6.1) ---
        add(.base, .intervals(warmUp: warmUp, run: .minutes(1),   walk: .minutes(2),   reps: 6...8, coolDown: coolDown))
        add(.base, .intervals(warmUp: warmUp, run: .minutes(1.5), walk: .minutes(1.5), reps: 6...8, coolDown: coolDown))
        add(.base, .intervals(warmUp: warmUp, run: .minutes(2),   walk: .minutes(1),   reps: 6...6, coolDown: coolDown))
        add(.base, .intervals(warmUp: warmUp, run: .minutes(3),   walk: .minutes(1),   reps: 5...5, coolDown: coolDown))
        add(.base, .intervals(warmUp: warmUp, run: .minutes(5),   walk: .minutes(1),   reps: 4...4, coolDown: coolDown))
        add(.base, .intervals(warmUp: warmUp, run: .minutes(8),   walk: .minutes(1),   reps: 3...3, coolDown: coolDown))
        add(.base, .intervals(warmUp: warmUp, run: .minutes(10),  walk: .minutes(1),   reps: 2...3, coolDown: coolDown))
        add(.base, .continuous(warmUp: warmUp, run: .minutes(20) ... .minutes(30), coolDown: coolDown))

        // --- Videre-forløb (afsnit 6.1) ---
        // Hold ved: faste 20–30 min ture.
        add(.maintain, .continuous(warmUp: warmUp, run: .minutes(20) ... .minutes(30), coolDown: coolDown))
        add(.maintain, .continuous(warmUp: warmUp, run: .minutes(20) ... .minutes(30), coolDown: coolDown))
        // Mod 5 km uden pause (bygger varigheden lidt op).
        add(.towardFiveKilometre, .continuous(warmUp: warmUp, run: .minutes(25) ... .minutes(35), coolDown: coolDown))
        add(.towardFiveKilometre, .continuous(warmUp: warmUp, run: .minutes(30) ... .minutes(40), coolDown: coolDown))
        // Længere distancer — kan gentages som "hold ved / pres lidt videre".
        add(.beyond, .continuous(warmUp: warmUp, run: .minutes(35) ... .minutes(45), coolDown: coolDown))

        return weeks
    }
}
