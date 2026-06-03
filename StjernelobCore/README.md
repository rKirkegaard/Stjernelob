# StjernelobCore

Rent domænelag for Stjerneløb — **ingen UI og ingen Apple-only frameworks**.
Pakken bruger kun Swift-standardbiblioteket og Foundation, så den kan bygges og
unit-testes på enhver Swift-platform (også Windows og Linux), ikke kun på en Mac.
Det gør den sikkerhedskritiske logik hurtig at teste isoleret.

Se `docs/specifikation.md` og `.claude/rules/arkitektur.md` for kravene.

## Indhold

| Område | Status | Beskrivelse |
|--------|--------|-------------|
| `Time/` | ✅ | `MonotonicClock`-abstraktion + `SystemMonotonicClock` (produktion) og `ManualClock` (test). |
| `Interval/` | ✅ | Den sikkerhedskritiske intervalmotor: `Interval`, `WorkoutPlan`, `WorkoutTimeline`, `IntervalEngine`, hændelser, snapshot og opsummering. |
| Program/progression | ⏳ | 8-ugers grundforløb + videre-forløb, adaptiv justering. |
| Streak/ugemål | ⏳ | Tilgivende ugentlig streak, ugemål, uge-/tidszonegrænser. |
| Point/stjerner/niveauer/badges | ⏳ | Gamification-logik. |

## Designvalg: drift-fri intervalmotor

Motoren er **deterministisk** og **drift-fri**. I stedet for at lægge tick oven
i tick udregner den forløbet tid som forskellen mellem et injiceret monotont urs
nuværende aflæsning og turens starttidspunkt (minus pauser). Alle hændelser
(intervalskift, nedtælling, halvvejs, målgang) er bundet til *absolutte*
tidspunkter på en forudberegnet tidslinje. Derfor er resultatet det samme, uanset
hvor ofte eller ujævnt `update()` kaldes — fx i baggrunden eller ved låst skærm.

Det abstraherede ur (`MonotonicClock`) gør, at hele turen kan testes i hånden med
`ManualClock` uden at vente i realtid.

## Byg og test

### På macOS / Linux
```sh
swift build
swift test
```

### På Windows
Kræver Swift-toolchain (`winget install Swift.Toolchain`) **og** Visual Studios
C++-byggeværktøjer (`VC.Tools.x86.x64`) til linkeren. Brug det medfølgende script,
der sætter `SDKROOT`, runtime-PATH og VS-udviklermiljøet op automatisk:

```powershell
pwsh -File ..\tools\swift.ps1 test --package-path .
```

(eller `build` i stedet for `test`). Scriptet ligger i repoets `tools/`-mappe.
