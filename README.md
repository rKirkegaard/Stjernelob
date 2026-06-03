# Stjerneløb

iOS-app der motiverer en 15-årig begynder til at komme i gang med at løbe via
gå/løb-program, gamification og en støttende forælder-funktion.

- Produktspecifikation: `docs/specifikation.md` (kilden til sandhed).
- Claude Code-konfiguration: `.claude/` + `CLAUDE.md`.

## Kom i gang
1. Åbn Xcode-projektet (tilføjes i repoet — app-koden lever fx i `Stjernelob/`
   og delt domænelogik i en SPM-pakke som `StjernelobCore/`).
2. Læs `CLAUDE.md` og reglerne i `.claude/rules/` — principperne dér er bindende.
3. Byg og test med kommandoerne i `CLAUDE.md`.

## Struktur (Claude Code)
- `CLAUDE.md` — indlæses hver session; projektets kontekst og principper.
- `.claude/rules/` — bindende, emneopdelte regler (sti-styret via globs).
- `.claude/skills/` — genbrugelige prompts (`/ny-feature`, `/gdpr-tjek`).
- `.claude/commands/` — enkeltprompt-kommandoer.
- `.claude/agents/` — subagenter med egne værktøjer.
- `.claude/output-styles/` — egne system-prompt-sektioner.
