---
description: Swift- og SwiftUI-kodestil for Stjerneløb
globs: "**/*.swift"
---
# Swift / SwiftUI-kodestil

- Følg Swift API Design Guidelines. Klare, fuldskrevne navne; ingen
  forkortelser. Typer i UpperCamelCase, øvrigt i lowerCamelCase.
- Ingen `force unwrap` (`!`) og ingen `try!` i produktionskode. Brug `guard`,
  `if let`, og fejl der håndteres eksplicit.
- Brug `async/await` til asynkront arbejde. Undgå færdiggørelses-callbacks.
- Hold views små og rene. Forretningslogik hører til i ViewModels/domænelag,
  ikke i `View`-structs (se `arkitektur.md`).
- Afhængigheder injiceres (initializer eller Environment) — ingen skjulte
  singletons til logik, så ting kan testes.
- Al brugervendt tekst lokaliseres (`String(localized:)` / kataloger). Ingen
  hardcodede danske strenge i views.
- Tilgængelighed er ikke valgfrit: understøt Dynamic Type, giv VoiceOver-
  labels, og sørg for at alt kan bruges uden lyd (haptik + visuelt).
- Foretræk værdityper (`struct`, `enum`). Brug `final class` når reference
  kræves.
- Formatering håndteres af swiftformat (kører som hook) — slås ikke fra manuelt.
