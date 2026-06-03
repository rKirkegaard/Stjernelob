# CLAUDE.md — Stjerneløb

Stjerneløb er en iOS-app (iPhone), der motiverer en 15-årig begynder uden
løbeerfaring og i ringe form til at komme i gang med at løbe — og blive ved.
Den bygger på gå/løb-metoden, gamification (stjerner, point, tilgivende
ugentlig streak) og en støttende forælder-funktion.

## Læs først
- Produktets sandhed er `docs/specifikation.md`. Læs det relevante afsnit, før
  du bygger eller ændrer en feature. Hvis kode og spec er uenige, vinder spec —
  eller spørg.
- Reglerne i `.claude/rules/` er bindende. De vigtigste er privatliv/GDPR og
  velbefindende/børnesikkerhed.

## Ufravigelige principper (gælder al kode OG al brugervendt tekst)
1. Intet vægt-, kalorie- eller udseendefokus nogen steder. Belønning gives for
   gennemførsel og fremmøde — aldrig for fart, distance eller vægt.
2. Blid, gradvis progression (gå/løb, maks. ~10 % mere om ugen). Hviledage er
   en del af træningen; streaken er på ugeniveau og tilgivende.
3. Tonen er varm og ikke-dømmende. Ingen skyld-baserede beskeder eller pres.
4. Privacy & security by design og by default (GDPR). Dataminimering, opt-in
   deling, og sletning der rydder alt. Se `rules/privatliv-gdpr.md`.
5. Brugeren er mindreårig. Forælder-funktionen er støtte, ikke overvågning.
   Se `rules/velbefindende-og-boernesikkerhed.md`.
6. Tilgængelighed: Dynamic Type, VoiceOver, og fuld funktion uden lyd.

## Teknologi
- Swift + SwiftUI (iPhone), watchOS-ledsager i Swift.
- GPS: Core Location med baggrundsopdateringer. Distance-backup: Core Motion.
- Lyd: AVFoundation/AVAudioSession (ducking over musik). Haptik: Core Haptics.
- HealthKit, WidgetKit + ActivityKit, UserNotifications.
- Data: lokal-først med SwiftData/Core Data som kilde til sandhed; synk via
  CloudKit privat database; forælder-link via CloudKit Sharing. Ingen egen
  backend, medmindre venner-på-tværs eller Android bliver aktuelt.
  Se `rules/arkitektur.md`.

## Sådan arbejder du her
- Følg arkitektur- og kodestil-reglerne. Hold forretningslogik ude af views.
- Skriv tests. Intervalmotorens nøjagtighed er sikkerhedskritisk og SKAL have
  tests (se `rules/test.md`).
- Lokalisér al brugervendt tekst — ingen hardcodede strenge.
- Kør test før en opgave meldes færdig.

## Build og test
- Build: `xcodebuild -scheme Stjernelob -destination 'platform=iOS Simulator,name=iPhone 15' build`
- Test:  `xcodebuild -scheme Stjernelob -destination 'platform=iOS Simulator,name=iPhone 15' test`
- Rene SPM-pakker (fx intervalmotor/domænelogik): `swift build`, `swift test`.

## Ekstra omhu kræves ved
- Ændringer der rører persondata, billeder, lokation eller forælder-deling →
  kør `/gdpr-tjek` og overvej `gdpr-auditor`-agenten.
- Ny eller ændret UI-tekst/feature der kan tippe over i pres, vægt/udseende
  eller børnesikkerhed → brug `velbefindende-reviewer`-agenten.

## Nyttige værktøjer i dette projekt
- Skills:   `/ny-feature`, `/gdpr-tjek`
- Commands: `/tilfoej-skaerm`, `/gennemgaa-aendringer`
- Agents:   `code-reviewer`, `gdpr-auditor`, `velbefindende-reviewer`
