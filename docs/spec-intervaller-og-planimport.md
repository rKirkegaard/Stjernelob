# Spec: Egne intervaller og import af træningsplan

*Feature-specifikation til Stjerneløb. Læses sammen med hovedspecifikationen
(`specifikation.md`); henvisninger til "afsnit X" gælder hovedspecifikationen.*

## 1. Formål og omfang

To brugerønsker dækkes af samme underliggende greb:

- **Egne intervaller:** brugeren kan selv bygge og justere længden af gå/løb-
  intervaller i en tur.
- **Import af træningsplan:** brugeren (eller en træner/forælder) kan importere
  en hel træningsplan udefra i stedet for kun at bruge det indbyggede program.

Begge dele bygger på det samme princip: en træning er **data**, ikke kode. Det
indbyggede program, en egen-bygget tur og en importeret plan er blot tre kilder
til den samme datatype, som intervalmotoren afspiller ens.

## 2. Princip: en træning er data

En tur modelleres som en liste af intervaller. Intervalmotoren (afsnit 13,
sikkerhedskritisk) tager én tur og spiller den — uden at vide, om den er
indbygget, egen-bygget eller importeret. Det holder motoren uændret og gør
features additive.

## 3. Datamodel (domænelag, ren Swift)

```swift
enum IntervalKind { case warmup, run, walk, cooldown }

// En blok kan måles i tid eller distance (tid er standard for begyndere).
enum IntervalMeasure { case time(Duration); case distance(Double) }

struct IntervalStep {
    let kind: IntervalKind
    let measure: IntervalMeasure
}

struct Workout {            // én tur
    var name: String
    var steps: [IntervalStep]
}

enum PlanSource { case builtIn, custom, imported }

struct ScheduledWorkout {   // en tur placeret i en uge
    var week: Int
    var workout: Workout
}

struct TrainingPlan {
    var name: String
    var source: PlanSource
    var schedule: [ScheduledWorkout]
}
```

- Egne ture og planer gemmes i SwiftData og synkes til brugerens egen iCloud
  som resten af hendes data (afsnit 13).
- Opvarmning og nedkøling lægges på automatisk, hvis en bygget tur ikke selv
  indeholder dem.

## 4. Egne intervaller (byg din egen tur)

En "byg din egen tur"-skærm, hvor brugeren selv styrer længderne:

- Tilføj blokke ("løb i …", "gå i …") og sæt varigheden med stepper/slider i
  trin på fx 15 sekunder; et samlet blok-mønster kan **gentages** N gange
  ("løb 1 min / gå 2 min × 6").
- **Live-forhåndsvisning:** samlet tid, antal løbeintervaller og en simpel
  tidslinje, mens hun bygger.
- Opvarmning (5 min gang) og nedkøling (5 min gang) foreslås automatisk og kan
  justeres.
- Turen kan navngives, gemmes og genbruges, og kan lægges ind i ugeplanen
  (afsnit 6.2).
- Tid er standardenheden; distance er en valgmulighed for den, der vil — men
  distance bruges aldrig som belønning (afsnit 3 i hovedspec).
- Bygget tur sendes gennem validatoren (afsnit 6), før den aktiveres.

## 5. Import af træningsplan

### 5.1 Kilder
En plan kan komme fra:

- en **fil** via systemets fil-vælger eller share-sheet (`fileImporter`),
- et **link eller en QR-kode**, der peger på en planfil,
- en **træner eller forælder** gennem companion-funktionen (CloudKit Sharing,
  afsnit 11).

### 5.2 Filformat (jordnært, læsbart JSON)
Start med appens eget, enkle format. Varigheder i sekunder; type er
`opvarmning`, `loeb`, `gaa` eller `nedkoeling`.

```json
{
  "navn": "8-ugers begynder",
  "version": 1,
  "uger": [
    {
      "uge": 1,
      "ture": [
        {
          "blokke": [
            { "type": "loeb", "sek": 60 },
            { "type": "gaa",  "sek": 120 }
          ],
          "gentag": 6
        }
      ]
    }
  ]
}
```

- Appen afkoder filen til `TrainingPlan` og viser en **forhåndsvisning** (uger,
  ture, samlet tid pr. tur, antal hviledage), som brugeren godkender, før planen
  aktiveres.
- Ukendte felter ignoreres robust; ugyldige filer afvises med en venlig fejl
  (afsnit 10).
- Senere kan der bygges **mappere** fra eksterne formater (fx eksport fra andre
  løbe-apps) til dette format — men det interne format er kilden til sandhed.

## 6. Validator (sikkerhed) — nudge, ikke bloker

Fordi brugeren er en 15-årig begynder, kan en egen-bygget eller importeret plan
let blive for hård. Både egne ture og importerede planer køres gennem en
`PlanValidator` i domænelaget, der tjekker mod de samme principper som det
indbyggede program (afsnit 3 og 6 i hovedspec):

- ikke et for stort spring fra hendes nuværende niveau,
- maks. ca. **10 % mere** samlet løbetid om ugen,
- bevarede **hviledage** (ikke løb hver dag),
- rimelig samlet varighed for en begynder.

Validatoren **blokerer ikke** — den foreslår blidt en blødere vej, i tråd med
den ikke-dømmende tone:

> "Den her plan er et stort hop fra det, du løber nu. Vil du tage den lidt
> blødere — fx starte et par uger inde?"

Brugeren bevarer kontrollen, men standardvalget peger mod det sikre. Resultatet
fordeles ind i ugeplanen (afsnit 6.2), så hviledage bevares.

## 7. Integration med resten af appen

- **Ugeplanlægning (afsnit 6.2):** egne/importerede ture fordeles efter ugens
  valgte træningsantal, med hviledage imellem.
- **Forælder/træner (afsnit 11):** en voksen kan dele/sende en plan, og — hvis
  barnet ønsker det — godkende den. Stadig støtte, ikke styring: forælderen kan
  ikke påtvinge en plan.
- **Gamification (afsnit 5):** stjerner, point og streak fungerer ens, uanset om
  turen er indbygget, egen eller importeret — belønning for gennemførsel.
- **Historik (afsnit 6.4):** gennemførte egne/importerede ture logges som alle
  andre, med kilde-markering (indbygget/egen/importeret).

## 8. Tilgængelighed

Bygge- og import-skærme følger samme krav som resten: Dynamic Type, VoiceOver-
labels på alle kontroller (steppere, slidere), og fuld betjening uden lyd.
Forhåndsvisningen skal kunne læses op meningsfuldt.

## 9. Privatliv og GDPR

- Egne ture og planer er **personlige data** og behandles som resten:
  lokalt/privat iCloud, ikke på en server vi ejer (afsnit 13, 14).
- Importerede filer behandles kun til at oprette planen; intet sendes videre.
- En delt/importeret plan fra en træner/forælder følger samtykke- og
  delingsreglerne i afsnit 11 og 14. Sletning af brugerens data fjerner også
  egne og importerede planer.

## 10. Edge cases og fejlhåndtering

- **Ugyldig/ufuldstændig importfil:** venlig fejl ("Vi kunne ikke læse den her
  plan"), uden teknisk støj; ingen halvt-importeret tilstand.
- **Tom eller meningsløs egen tur** (fx 0 intervaller): kan ikke gemmes; blid
  vejledning i stedet.
- **Versionsforskelle i formatet:** `version`-feltet bruges til at håndtere
  fremtidige ændringer; nyere felter ignoreres robust i ældre app-versioner.
- **Skift midt i et forløb:** at skifte til en egen/importeret plan nulstiller
  ikke historik eller stjerner; den nye plan lægges oven på den nuværende uge.

## 11. Afgrænsning og fremtid

**Med i denne feature:** datamodel for ture/planer, "byg din egen tur"-skærm med
intervalstyring, import af plan (eget JSON-format) med forhåndsvisning,
sikkerheds-validator (nudge), samt integration med ugeplan, forælder/træner,
gamification og historik.

**Senere:** mappere fra tredjeparts-eksportformater, deling af egne planer
mellem venner, og et bibliotek af færdige, fagligt gennemgåede planer at vælge
fra.
