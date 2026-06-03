---
name: ny-feature
description: Bygger en ny feature i Stjerneløb konsistent og i tråd med spec, arkitektur og projektets bindende regler.
---
# Ny feature

Følg denne fremgangsmåde, når der skal bygges en ny feature:

1. **Find sandheden.** Læs det relevante afsnit i `docs/specifikation.md`. Er
   noget uklart, så spørg frem for at gætte.
2. **Tjek reglerne.** Gennemgå `rules/arkitektur.md`, `rules/swift-style.md`,
   `rules/privatliv-gdpr.md` og `rules/velbefindende-og-boernesikkerhed.md`.
3. **Design kort.** Beskriv domænemodel, dataflow (lokalt → CloudKit), og
   hvilke skærme der berøres. Hold forretningslogik i domæne-/ViewModel-laget.
4. **Implementér** i lag: domæne (ren Swift) → data/repository → SwiftUI-view.
   Lokalisér al tekst. Tilføj tilgængelighed (Dynamic Type, VoiceOver, virker
   uden lyd).
5. **Test.** Skriv unit-tests for ny logik (se `rules/test.md`); UI-test hvis
   en kerneskærm berøres.
6. **Tjek principperne.** Ingen vægt/kalorie/udseende, ingen pres-mekanik,
   venlig tone. Rører ændringen persondata/billeder/lokation/deling, så kør
   `/gdpr-tjek`.
7. **Kør test** og opsummér ændringen kort.
