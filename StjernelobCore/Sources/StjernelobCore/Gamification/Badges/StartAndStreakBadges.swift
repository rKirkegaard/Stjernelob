import Foundation

// Kom-i-gang og stime. Tilføj et nyt mærke ved at indsætte én BadgeDefinition.

extension BadgeCatalogue {
    static let startAndStreakBadges: [BadgeDefinition] = [
        // MARK: Første skridt (teal)

        BadgeDefinition(
            slug: "første-skridt", category: .firstSteps, palette: .teal, emoji: "👟",
            title: "Første skridt", detail: "Du kom afsted på din allerførste tur.",
            rule: .totalWorkouts(1)
        ),
        BadgeDefinition(
            slug: "modig-starter", category: .firstSteps, palette: .teal, emoji: "💪",
            title: "Modig starter", detail: "Du gennemførte en hel tur. Modigt gjort!",
            rule: .completedFullRun
        ),
        BadgeDefinition(
            slug: "klar-til-start", category: .firstSteps, palette: .teal, emoji: "🎽",
            title: "Klar til start", detail: "Du er klar til at komme i gang.",
            rule: .manual
        ),
        BadgeDefinition(
            slug: "tidlig-fugl", category: .firstSteps, palette: .teal, emoji: "🌅",
            title: "Tidlig fugl", detail: "En frisk morgentur.",
            rule: .startedInMorning
        ),
        BadgeDefinition(
            slug: "aftenstjerne", category: .firstSteps, palette: .teal, emoji: "🌙",
            title: "Aftenstjerne", detail: "En rolig tur i aftentimerne.",
            rule: .startedInEvening
        ),

        // MARK: Stime (lilla)

        BadgeDefinition(
            slug: "en-uge-i-traek", category: .consistency, palette: .purple, emoji: "📆",
            title: "En uge i træk", detail: "En hel uge med dine ture.",
            rule: .streakWeeks(1)
        ),
        BadgeDefinition(
            slug: "2-i-en-uge", category: .consistency, palette: .purple, emoji: "🔥",
            title: "2 i én uge", detail: "To ture på én uge — flot!",
            rule: .sessionsThisWeek(2)
        ),
        BadgeDefinition(
            slug: "3-i-en-uge", category: .consistency, palette: .purple, emoji: "⚡",
            title: "3 i én uge", detail: "Tre ture på én uge. Sejt!",
            rule: .sessionsThisWeek(3)
        ),
        BadgeDefinition(
            slug: "3-ugers-streak", category: .consistency, palette: .purple, emoji: "🌟",
            title: "3-ugers streak", detail: "Tre uger i træk med dine ture.",
            rule: .streakWeeks(3)
        ),
        BadgeDefinition(
            slug: "ubrydelig", category: .consistency, palette: .purple, emoji: "🏆",
            title: "Ubrydelig", detail: "Otte uger i træk — næsten ikke til at stoppe.",
            rule: .streakWeeks(8)
        ),
        BadgeDefinition(
            slug: "maanedshelt", category: .consistency, palette: .purple, emoji: "💎",
            title: "Månedshelt", detail: "En måned fyldt med ture. Hold da op!",
            rule: .workoutsThisMonth(8)
        ),
        BadgeDefinition(
            slug: "tilbage-igen", category: .consistency, palette: .purple, emoji: "🔄",
            title: "Tilbage igen",
            detail: "Du tog fat igen efter en pause. Dejligt at have dig tilbage.",
            rule: .comeback
        ),
    ]
}
