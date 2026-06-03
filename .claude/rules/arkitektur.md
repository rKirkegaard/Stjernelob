# Arkitektur

Lokal-først. Enheden er kilden til sandhed; skyen er backup/synk og deling.

## Lag
- **Domæne (ren Swift, ingen UI):** intervalmotor, programprogression,
  streak-/ugemål-logik, point/stjerner. Ligger helst i en SPM-pakke
  (fx `StjernelobCore`), så det er hurtigt at unit-teste.
- **Data:** modeller i SwiftData/Core Data. Repository-typer abstraherer
  lagring, så domænet ikke kender til persistens eller CloudKit.
- **Synk:** CloudKit **privat database** til personlig synk/backup;
  CloudKit **Sharing** til forælder-linket (kun et kurateret udsnit deles).
  Ingen egen backend uden eksplicit beslutning.
- **Præsentation:** SwiftUI-views + ViewModels (Observation/`@Observable`).
  Views indeholder ikke forretningslogik.

## Hårde regler
- Intervalmotoren er isoleret, deterministisk og testbar. Den må ikke "drive"
  tidsmæssigt og skal virke i baggrunden/ved låst skærm. Den er sikkerheds-
  kritisk (se `test.md`).
- Billeder og GPS-ruter gemmes som filer med iOS Data Protection; databasen
  holder kun en reference.
- "Slet alle mine data" skal kaskadere: lokalt + privat DB + delt zone.
- Distance må aldrig være et krav for belønning; tempo vises neutralt.
