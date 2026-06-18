import Foundation

/// Legende "loading"-replikker, der vises kort ved opstart (jf. docs/qutoes.md).
/// Tonen er varm og opmuntrende — aldrig pres, skyld eller krav om at løbe i
/// dag (jf. `.claude/rules/velbefindende-og-boernesikkerhed.md`).
enum LoadingQuotes {
    static let all: [LocalizedStringResource] = [
        .init(
            "loading.quote.1",
            defaultValue: "Snørebåndene strammes... det er tid til at gøre noget godt for dig selv"
        ),
        .init(
            "loading.quote.2",
            defaultValue: "Badges poleres op og er klar til at blive vundet"
        ),
        .init("loading.quote.3", defaultValue: "Løberuten varmes op — den venter på dig"),
        .init("loading.quote.4", defaultValue: "Dine løbesko savnede dig. De er klar nu"),
        .init(
            "loading.quote.5",
            defaultValue: "Vi loader din motivation... det tog lidt tid, men nu er den klar"
        ),
        .init(
            "loading.quote.6",
            defaultValue: "Appen snørrer løbeskoene — du behøver kun at åbne døren"
        ),
        .init(
            "loading.quote.7",
            defaultValue: "Dagens vigtigste opgave: komme ud. Det ordner vi sammen"
        ),
        .init(
            "loading.quote.8",
            defaultValue: "Vejrudsigten er tjekket. Dine ben er klare. Og du er modigere end du tror"
        ),
        .init(
            "loading.quote.9",
            defaultValue: "Løberuten er varmet op og venter tålmodigt på dig"
        ),
        .init(
            "loading.quote.10",
            defaultValue: "Badges børstes af og gør sig klar til at lande på din profil"
        ),
        .init(
            "loading.quote.11",
            defaultValue: "GPS signal fundet. Motivation fundet. Dig — snart fundet udenfor"
        ),
        .init(
            "loading.quote.12",
            defaultValue: "Vi forbereder din sejrsrunde... (den starter med første skridt)"
        ),
        .init(
            "loading.quote.13",
            defaultValue: "Appen hvisker: du behøver ikke løbe hurtigt — du skal bare løbe"
        ),
        .init(
            "loading.quote.14",
            defaultValue: "Din løbemusik er klar. Dine ben er klar. Vi venter bare på dig"
        ),
        .init(
            "loading.quote.15",
            defaultValue: "Nyheden: du er årets løber. (Der er kun én ansøger, og det er dig)"
        ),
        .init(
            "loading.quote.16",
            defaultValue: "Pusler din rute på plads... spoiler: det bedste er frisk luft i lungerne"
        ),
        .init(
            "loading.quote.17",
            defaultValue: "Vi opdaterer dine fremskridt. Spoiler: de er bedre end du tror"
        ),
        // Blødt omformuleret: ingen skyld over en misset dag, intet dagligt krav.
        .init(
            "loading.quote.18",
            defaultValue: "Din krop elsker en frisk tur. Den er klar, når du er"
        ),
        .init(
            "loading.quote.19",
            defaultValue: "Badges er polerede, ruten er klar, og vejret... kan ikke sige noget imod dig"
        ),
        .init(
            "loading.quote.20",
            defaultValue: "Hvert skridt tæller — og det bedste er, at du allerede er i gang"
        ),
    ]

    /// En tilfældig replik (falder tilbage til den første, hvis listen var tom).
    static func random() -> LocalizedStringResource {
        all.randomElement() ?? all[0]
    }
}
