# Specifikation: "Stjerneløb" — løbe-app for begyndere

*Udarbejdet af løbetræner-agenten. Arbejdstitel "Stjerneløb" er en placeholder.*

## 1. Formål og vision

Stjerneløb er en iPhone-app, der skal motivere en 15-årig pige uden
løbeerfaring og i ringe form til at komme i gang med at løbe — og blive ved.
Appen er ikke en præstationstracker for trænede løbere. Den er en venlig,
legende ledsager, der gør det at gå fra "har aldrig løbet" til "kan løbe 20–30
minutter i træk" overskueligt, sikkert og sjovt.

Den bærende idé: De fleste begyndere stopper på grund af skader eller
demotivation, ikke manglende vilje. Appen er designet til at forhindre begge
dele. Den belønner fremmøde og små fremskridt — ikke fart, distance eller
forbrændte kalorier.

## 2. Målgruppe

- **Primær bruger:** Pige, 15 år, ingen løbeerfaring, dårlig kondition,
  let at miste motivationen hvis det føles hårdt eller pinligt.
- **Konsekvenser for designet:** sproget er ungt og opmuntrende uden at være
  barnligt; træningen starter meget blødt; alt fokus er på "hvad du kan nu"
  frem for sammenligning med andre; intet handler om kropsvægt eller udseende.

## 3. Designprincipper (sundhedsfaglig grundlinje)

Disse principper er ufravigelige og skal afspejles i al funktionalitet:

1. **Start blødere, end brugeren tror, hun kan.** Appens første uger føles
   næsten for lette. Det er bevidst — det forebygger skader og frafald.
2. **Gå/løb-metoden.** Brugeren veksler mellem at gå og løbe, og løbe-
   intervallerne vokser langsomt over uger.
3. **Maks. ca. 10 % mere om ugen.** Programmet øger forsigtigt og springer
   aldrig flere trin over.
4. **Hviledage er en del af træningen.** Appen opfordrer aktivt til hvile og
   tillader aldrig løb hver dag i begyndelsen.
5. **Konsistens slår intensitet.** Belønningssystemet honorerer at møde op
   regelmæssigt, ikke at presse hårdt.
6. **Ingen vægt-, kalorie- eller udseendefokus.** Appen viser, sporer og
   nævner aldrig vægt, kalorier, BMI eller kropsmål. Motivationen handler om
   at kunne mere, føle sig stærk og have det sjovt.

## 4. Kerneoplevelsen: en løbetur

En "tur" består af opvarmning → vekslende gå/løb-intervaller → nedkøling.
Selve turen er appens hjerte, og den skal kunne følges live mens appen er
åben.

### 4.1 Live-tracking (mens appen er åben)
Under turen viser skærmen i realtid:

- **Forløbet tid** (turens samlede tid) og **resterende tid** på det aktuelle
  interval.
- **Distance** (samlet, fx i km), beregnet via GPS når det er tilgængeligt og
  via skridt/bevægelsessensor som backup.
- **Aktuelt tempo** (min/km) — vist neutralt og lavt prioriteret, da tempo
  *ikke* er noget hun bliver bedømt eller belønnet på.
- **Interval-status:** om hun løber eller går lige nu, hvilket interval i
  rækken (fx "Interval 3 af 6"), og en tydelig nedtælling.
- **Stort, enkelt skærmbillede:** de vigtigste tal (interval + nedtælling)
  fyldt stort, så de kan ses i et hurtigt blik under løb. Tempo/distance
  mindre, nedenunder.

Mens appen er åben, opdateres alt løbende. Tracking skal også fortsætte i
baggrunden, så lyd og timer virker når skærmen er låst, eller hun lytter til
musik (se afsnit 10).

### 4.2 Lyd- og signal-feedback (start/stop af interval)
Appen styrer hele turen med tydelige signaler, så hun aldrig selv skal holde
øje med uret:

- **Start af løbe-interval:** en kort, energisk lyd (fx en stigende "klar–nu!"-
  tone) + stemmecoach: "Løb nu i 1 minut" + et fast vibrationsmønster (haptik).
- **Stop af løbe-interval / start på gå-interval:** en blødere, faldende lyd +
  stemmecoach: "Godt klaret — gå roligt i 2 minutter" + et andet, mildere
  vibrationsmønster, så de to skift kan kendes fra hinanden på følelsen alene.
- **Nedtælling før et skift:** tre korte bip de sidste 3 sekunder før hvert
  interval slutter, så skiftet aldrig kommer bag på hende.
- **Halvvejs-/opmuntringssignaler:** en lille positiv lyd og en kort
  opmuntring undervejs ("Du er halvvejs — flot!").
- **Snaketest-påmindelse:** med jævne mellemrum minder coachen blidt om at
  sætte farten ned, hvis hun ikke kan tale i hele sætninger imens.
- Alle signaler findes i **tre kanaler** — lyd, stemme og haptik — og kan
  justeres eller slås fra hver for sig, så appen også virker uden lyd (fx i
  skole eller med musik skruet op).

### 4.3 Stjernepop pr. interval
Når et interval gennemføres, lyder en lille positiv "ding", og en stjerne
"popper" ind på skærmen med en kort animation (se gamification, afsnit 5).
Det giver en belønning hvert par minutter undervejs, ikke kun til sidst.

### 4.4 Fejring ved målgang
Når hun afslutter en hel tur, skal det føles som en sejr:

- **Konfetti-animation** fylder skærmen sammen med en glad fanfare-lyd og en
  fejrende haptisk "buzz".
- Et **resumé "popper" frem** med dagens resultat: gennemført tur, optjente
  stjerner (inkl. bonusstjerne for at gøre turen færdig), tid og distance.
- En **personlig, opmuntrende besked** fra coachen, gerne med en konkret
  fremgangs-sammenligning ("For tre uger siden løb du 1 minut ad gangen — i
  dag holdt du 8 minutter!").
- Hvis turen udløste et **nyt badge, niveau eller en streak-uge**, fejres det
  oven i konfettien med sin egen lille animation.
- Fejringen udløses for at have **gennemført turen** — ikke for fart eller
  distance — så enhver fuldført tur, hurtig eller langsom, får den fulde
  fejring.

### 4.5 Billede fra turen og billedarkiv
For at gøre turene til minder, hun har lyst til at vende tilbage til:

- Under eller efter en tur kan hun **tage et billede** — fx af udsigten,
  vejret, stedet hun nåede til, eller bare øjeblikket — som **knyttes til netop
  den løbetur**.
- Billederne samles i et **billedarkiv**, hvor hver tur har sine egne billeder,
  så hun kan genbesøge dem sammen med turens dato og milepæle ("se hvor du var
  for en måned siden").
- Det kan bruges som blid motivation før en tur ("husk at fange et billede i
  dag"), men er altid frivilligt — en tur uden billede er lige så fuldgyldig.
- I tråd med designprincipperne (afsnit 3) lægger appen op til at fange
  **stedet og oplevelsen** — ikke kroppen. Der er intet pres om selfies eller
  "før/efter"-billeder.
- Billeder er **private som standard**, gemmes sikkert og deles ikke med nogen
  (heller ikke forælderen) medmindre hun selv vælger at dele et konkret billede.
  Behandlingen af billeder er beskrevet i afsnit 14.

## 5. Gamification

Belønningerne skal motivere uden at straffe. Tre lag:

### 5.1 Stjerner pr. interval (mikro-belønning)
- Hvert gennemført løbe- eller gå-interval giver **1 stjerne**.
- En fuldført tur giver en **bonusstjerne** (fx +3) — afslutning belønnes mere
  end enkeltintervaller, så hun altid har grund til at gøre turen færdig.
- Stjerner gives for *gennemførsel*, ikke for tempo eller distance. Selv en
  langsom tur giver fulde stjerner.
- Stjerner kan ikke mistes. Man kan kun samle flere.

### 5.2 Point og niveauer (samlet fremgang)
- Stjerner omsættes til **point**, der bygger en samlet score over tid.
- Point låser **niveauer** op (fx Niveau 1 "Første skridt" → Niveau 10
  "Løber"). Hvert niveau giver en lille fejring og evt. nyt udseende til en
  simpel avatar/maskot.
- Niveauer afspejler indsats over tid, ikke hvor hurtig hun er.

### 5.3 Ugentlig streak (vane-motivation, tilgivende)
- En **uge tæller som gennemført**, når hun har lavet det antal ture, hun selv
  har sat som ugemål for den uge (se afsnit 6.2). Streaken er på **ugeniveau,
  ikke dagsniveau** — det undgår presset om at løbe hver dag, som ville være
  usundt for en begynder.
- Fordi ugemålet sættes ud fra, hvor meget tid hun reelt har den uge, kan
  streaken holdes i live i en travl uge ved at sætte målet lavt (fx 1 tur),
  uden at det føles som at snyde. Mindst én tur tæller altid som en aktiv uge.
- En **streak-fryser** kan bruges, hvis en uge slet ikke når i mål (sygdom,
  eksamen, ferie). Hun kan også bevidst sætte appen på pause uden at miste
  fremgangen.
- Hvis en streak alligevel brydes, er tonen **aldrig** skyldfremkaldende:
  "Velkommen tilbage — vi starter lige, hvor du slap." Ingen røde tal, ingen
  "du har svigtet"-beskeder.

### 5.4 Badges og milepæle
- Mærker for konkrete, sjove milepæle: "Første tur", "3 ugers streak",
  "Første gang du løb 5 minutter i træk", "Tidlig fugl" (morgentur),
  "Regnvejrshelt". Tænkt til at fejre handlinger, hun selv kan se sig stolt af.

### 5.5 Venner
- Mulighed for at dele en milepæl eller løbe "sammen" med en ven via venlige
  opmuntringer — aldrig en konkurrence-rangliste, da sammenligning
  demotiverer begyndere. Skal være privat og frivilligt (se afsnit 9).

## 6. Træningsprogram og ugeplanlægning

### 6.1 Det progressive forløb
Et indbygget gå/løb-forløb, der tilpasser sig hende. Grundforløbet bringer
hende fra "har aldrig løbet" til at kunne løbe 20–30 minutter sammenhængende
over ca. 8 uger med 3 ture om ugen. Hver tur starter med 5 min rask gang og
slutter med 5 min gang.

| Uge | Tur (gentages) |
|-----|----------------|
| 1 | 1 min løb / 2 min gå × 6–8 |
| 2 | 1,5 min løb / 1,5 min gå × 6–8 |
| 3 | 2 min løb / 1 min gå × 6 |
| 4 | 3 min løb / 1 min gå × 5 |
| 5 | 5 min løb / 1 min gå × 4 |
| 6 | 8 min løb / 1 min gå × 3 |
| 7 | 10 min løb / 1 min gå × 2–3 |
| 8 | 20–30 min sammenhængende roligt løb |

Når grundforløbet er gennemført, fortsætter appen med **videre-forløb**, så
hun ikke står uden mål: et "hold ved"-forløb (fast 20–30 min ture), et forløb
mod 5 km uden pause, og derefter et mod længere distancer. Hun kan altid vælge
blot at vedligeholde frem for at presse videre.

**Adaptiv justering:** Hvis hun markerer flere ture i træk som hårde (eller
springer ture over), foreslår appen blidt at gentage ugen i stedet for at gå
videre. Antallet af intervaller i en tur skaleres desuden efter ugens
træningsantal (afsnit 6.2), så hver tur stadig giver en passende dosis.
Programmet kan altid sættes et trin tilbage uden at det føles som nederlag.

### 6.2 Angiv antal træninger for den aktuelle uge
Hun skal selv kunne bestemme, hvor mange ture hun har tid til **i den aktuelle
uge** — for et ungt menneske svinger en uge meget med skole, eksamen, fritid
og energi.

- I starten af hver uge (og når som helst inde i ugen) kan hun vælge sit
  **ugentlige træningsantal**, fx 1–5 ture. Appen foreslår et udgangspunkt
  (typisk 3), men hun har altid det sidste ord.
- Det valgte antal styrer:
  - **Ugemålet for streaken** (afsnit 5.3) — så streaken matcher en realistisk
    uge i stedet for en fast kvote.
  - **Planlægningen:** appen fordeler ugens ture jævnt med mindst én hviledag
    imellem og foreslår konkrete dage/tidspunkter, hun kan justere.
  - **Fremdriften i forløbet:** vælger hun færre ture i en uge, går hun blot
    lidt langsommere frem — aldrig "bagud". Vælger hun flere, må appen ikke
    lade hende overskride den sikre progression (maks. ca. 10 % mere om ugen)
    eller springe hviledage over; den kan i stedet lægge en let gå-tur ind.
- Ændrer hun antallet midt i ugen (blev travlt, eller fik mere overskud),
  tilpasser ugeplanen og ugemålet sig med det samme — uden at det allerede
  optjente går tabt.
- Tonen er fleksibel og ikke-dømmende: at vælge 1 tur i en hård uge er et
  fuldgyldigt, godt valg, ikke en fiasko.

### 6.3 Hviledage
Hvile er en del af træningen, ikke en pause fra den — og det skal mærkes på en
hviledag:

- På en planlagt hviledag viser dashboardet en **sjov, hyggelig animation**,
  der signalerer, at det er helt i orden at slappe af — fx maskotten/avataren
  der strækker sig, lader op, ligger i en hængekøje eller sover med en lille
  "Zzz". Tonen er rar og legende, aldrig skyldfremkaldende.
- En kort, positiv besked bekræfter det: "Hviledag i dag — din krop bliver
  stærkere imens. Vi ses i morgen!"
- Hviledage **bryder aldrig streaken** og koster aldrig point. De hører med til
  ugeplanen (afsnit 6.2) og fejres som en del af det at gøre det rigtigt.
- Vælger hun alligevel en let gå-tur på en hviledag, er det også fint — men
  appen skubber aldrig til det.

### 6.4 Oversigt over gennemførte træninger (historik)
Hun skal kunne se en samlet oversigt over alle tidligere gennemførte træninger
— både for at føle stolthed og for at se sin fremgang sort på hvidt:

- En **liste/tidslinje** med alle gennemførte ture, nyeste øverst, samt en
  **kalendervisning**, hvor trænings- og hviledage er markeret.
- For hver tur kan hun se: **dato**, hvilken uge/trin i forløbet, **hvad hun
  lavede** (intervaller, samlet tid, distance), **hvordan det føltes** (hendes
  egen 1–10), **optjente stjerner**, evt. **badge** der blev låst op, og de
  **billeder**, der er knyttet til turen (afsnit 4.5).
- **Samlede tal** vist på en opmuntrende måde: antal gennemførte ture, aktive
  streak-uger og samlede stjerner — altid om fremmøde og fremgang, aldrig om
  fart, vægt eller sammenligning med andre.
- **Fremgangs-highlights**, der sætter tingene i perspektiv ("for 3 uger siden
  løb du 1 minut ad gangen — i dag 8").
- Hun kan **trykke på en tur** for at se detaljer og genbesøge billederne.
- Oversigten virker offline og følger samme regler for eksport og sletning som
  resten af hendes data (afsnit 14).

## 7. Skærme og flow

1. **Onboarding:** kort, venlig introduktion; spørger om hun har løbet før, hvor
   mange ture om ugen hun har tid til lige nu, og om hun har smerter/skader. Ved
   tegn på helbredsproblemer (fx brystsmerter, svimmelhed, kendt hjerte-/lunge-
   sygdom) anbefaler appen at tale med egen læge først.
2. **Hjem/dashboard:** næste planlagte tur, ugens valgte træningsantal og
   streak-status, samlet stjerne-/pointscore, avatar/niveau. På hviledage vises
   en hyggelig hvile-animation (afsnit 6.3). Herfra kan hun hurtigt justere
   ugens antal træninger (afsnit 6.2).
3. **Ugeplanlægger:** vælg antal ture for ugen og se/justér de foreslåede dage.
4. **Under-tur-skærm:** live intervaltimer og nedtælling, forløbet tid,
   distance og tempo, stemmecoach, lyd-/haptiske start-/stop-signaler,
   stjernepop pr. interval og mulighed for at tage et billede (afsnit 4).
5. **Tur-resumé (med konfetti-fejring):** konfetti og fanfare ved målgang,
   dagens stjerner, tid og distance, opmuntrende besked, mulighed for at tage/
   tilføje et billede, evt. nyt badge/niveau/streak-uge, og et simpelt "Hvordan
   føltes det?" (1–10) til adaptiv justering.
6. **Fremgang og billedarkiv:** oversigt over alle gennemførte træninger som
   liste og kalender, med detaljer, stjerner, milepæle og billeder pr. tur —
   fokus på "se hvor langt du er nået" og minder fra turene (afsnit 6.4 og 4.5).
7. **Samling/badges:** oversigt over optjente mærker, niveauer og avatarens
   udvikling.
8. **Venner:** frivillige, private opmuntringer og deling af milepæle (afsnit 5.5).
9. **Indstillinger:** ugemål-standard, påmindelser, stemme/lyd/haptik (hver for
   sig), musik, streak-fryser, forælder-link, sikkerhed/positionsdeling,
   privatliv og datatilladelser.
10. **Forælder-tilstand (egen rolle):** parring med barnet, forælder-dashboard,
    opmuntrings-/beskedfelt og milepæls-tidslinje (afsnit 11).

## 8. Notifikationer og motivation

- **Venlige, ikke-pressende påmindelser:** "Klar til en lille tur i dag?" frem
  for "Du mangler at løbe!".
- Påmindelser kan justeres eller slås fra. Ingen notifikationer der spiller på
  skyld eller frygt for at miste streak.
- Positiv forstærkning efter ture og ved milepæle.

## 9. Sikkerhed, velbefindende og privatliv (vigtigt — mindreårig bruger)

- **Skadesforebyggelse:** appen forklarer forskel på normal ømhed og
  advarselstegn (skarpe/stikkende smerter, ledsmerter der bliver værre, smerter
  der får hende til at halte) og opfordrer til pause/voksen/læge ved disse —
  aldrig "løb det væk".
- **Hvile indbygget:** ingen daglig streak; aktiv opfordring til hviledage.
- **Intet vægt-/kalorie-/udseendefokus** nogen steder i appen (gentaget her,
  fordi det er en hård regel).
- **Forældreinvolvering:** da brugeren er 15, opfordrer onboarding til, at en
  forælder/voksen er orienteret, og appen tilbyder en frivillig forælder-
  ledsager-funktion (afsnit 11), hvor fremgang kan deles, og en voksen kan
  støtte hende.
- **Privatliv:** Som mindreårig kræver databehandling særlig omhu (GDPR, og i
  praksis samtykke fra forælder afhængigt af jurisdiktion). GPS-/lokationsdata
  og helbredsdata skal behandles minimalt og sikkert; ingen deling med
  tredjepart; ingen offentlig profil; venne-funktioner (afsnit 5.5) skal være
  privat-by-default og frivillige. Dette afsnit bør gennemgås juridisk før
  lancering.

## 10. Tekniske krav

- **Sprog og platform:** Appen udvikles **native i Swift med SwiftUI** til
  iPhone (iOS: nyeste samt to forrige hovedversioner). Native Swift er valgt,
  fordi GPS i baggrunden, en præcis intervaltimer, baggrundslyd, haptik,
  HealthKit og Apple Watch-ledsageren alle er mest pålidelige native — og det
  er kerneting i denne app.
- **Konkrete Apple-frameworks:**
  - **Core Location** — GPS, distance/rute og *løbende positionsopdateringer i
    baggrunden* og ved låst skærm (med "Background Modes: Location updates").
  - **Core Motion** — skridt/bevægelse som backup til distance og til ture uden
    GPS (fx løbebånd).
  - **AVFoundation / AVAudioSession** — stemmecoach og signallyde, der kan
    afspilles "henover" musik (ducking) og virker med låst skærm/baggrund.
  - **Core Haptics** — vibrationsmønstre for interval-start/-stop, nedtælling
    og fejring.
  - **HealthKit** — gem ture som workouts og læs aktivitet (med samtykke).
  - **WidgetKit + ActivityKit** — Home Screen-widget og Live Activity under en
    igangværende tur.
  - **UserNotifications** — lokale, netuafhængige påmindelser.
  - **watchOS-app i Swift** til Apple Watch-ledsageren.
- **Apple Watch-ledsager:** valgfri watchOS-app, så hun kan styre turen og
  mærke intervalskift på håndleddet uden at tage telefonen op.
- **Intervalmotor (kerne):** kører pålideligt i baggrunden og ved låst skærm
  uden at "drive" tidsmæssigt — eksplicit kvalitetskrav, der testes (afsnit 16).
- **Puls** fra Apple Watch eller koblet pulsmåler (valgfrit, vist neutralt —
  aldrig grundlag for belønning).
- **Lyd, stemme og haptik:** kan styres uafhængigt og slås fra hver for sig.
- **Offline-først:** hele træningsoplevelsen fungerer uden netforbindelse;
  data synkroniseres når der igen er forbindelse.
- **Backend/synk:** sikker backend til konto, fremgang og familie-/venne-
  funktioner med beskyttelse af persondata; al deling er opt-in. CloudKit kan
  bruges til privat synk inden for brugerens egen iCloud, hvis man vil holde
  data i Apples økosystem.
- **Tilgængelighed:** store, læsbare tal under løb; Dynamic Type; VoiceOver;
  fuld funktion uden lyd via haptik og visuelle signaler; farveblind-venlige
  signaler.

## 11. Forælder-ledsager (familie-funktion)

En forælder skal kunne følge og støtte sit barn via en ledsager-oplevelse, der
"taler sammen" med barnets app. **Anbefaling: samme app med to roller** frem
for to separate apps — det giver én kodebase, automatisk kompatibilitet mellem
versioner og en enklere udgivelse. (En selvstændig, letvægts forælder-app er
et alternativ, men koster dobbelt vedligehold.)

### 11.1 Konto- og parringsmodel
- Ved login vælges en **rolle**: "Løber" (barnet) eller "Forælder/voksen".
- Forælder og barn knyttes sammen via en **parringskode/invitation**, som
  barnet (og/eller forælderen, afhængigt af samtykkeflowet i afsnit 14)
  godkender. Linket er gensidigt bekræftet — ingen kan tilkoble sig i det
  skjulte.
- Flere voksne kan knyttes til samme barn (fx to forældre). Barnet kan til
  enhver tid se hvem der er linket og **afbryde linket**.

### 11.2 Princip: støtte, ikke overvågning
Funktionen er designet til at opmuntre, ikke kontrollere — ellers virker den
modsat på en teenager:
- Barnet kan **se præcis, hvad forælderen kan se**, og styrer selv hvad der
  deles (fx kun streak og milepæle, eller også turdetaljer).
- Forælderen kan **ikke** ændre barnets program, sætte mål for hende eller
  presse hende. Der er bevidst ingen "rykker"-knap.
- Al deling er **opt-in og kan slås fra** når som helst af barnet.

### 11.3 Hvad forælderen kan (med barnets samtykke)
- Se et venligt **forælder-dashboard**: ugens streak-status, gennemførte ture,
  milepæle/badges og næste planlagte tur.
- Sende **opmuntringer**: hjerter, klap eller en kort besked, der dukker op i
  barnets app — fx et "heppekor", der spilles ved målgang.
- **Fejre milepæle sammen** (notifikation når barnet når et nyt niveau eller en
  streak-uge).
- Valgfrit og kun hvis barnet slår det til: **se live-position under en tur**
  og få besked "afsted"/"hjemme igen sikkert" (kobler til afsnit 12).
- Det forælderen ser, er bevidst fokuseret på indsats og fremmøde — aldrig
  tempo-ranglister, vægt eller andet, der inviterer til pres eller sammenligning.

### 11.4 Forælder-skærme
Forælder-rollen har sit eget dashboard, et opmuntrings-/beskedfelt, en
milepæls-tidslinje og indstillinger for, hvilke notifikationer forælderen vil
modtage. Skift mellem roller (hvis en enhed bruges af både barn og voksen)
kræver login.

## 12. Personlig sikkerhed under løb

For en ung person, der ofte løber alene udenfor, er fysisk sikkerhed en
førsteklasses funktion — ikke en eftertanke:

- **Live-positionsdeling (opt-in):** del position under en igangværende tur med
  en betroet voksen/forælder; slukkes automatisk når turen slutter.
- **Afsted/hjemme-beskeder:** valgfri automatisk besked til en betroet kontakt,
  når en tur starter og afsluttes.
- **SOS-/nødknap:** hurtig adgang til at ringe efter hjælp og dele position med
  en nødkontakt.
- **Trygheds-råd:** blide anbefalinger om dagslys, kendte ruter, og at holde
  lyd-/musiklydstyrken nede nok til at høre trafik og omgivelser.
- **Delt planlagt rute (valgfrit):** mulighed for at lade en voksen se den
  planlagte rute inden afgang.
Alle sikkerhedsfunktioner er opt-in, og barnet ved altid, hvad der deles og med
hvem.

## 13. Arkitektur og datafundament

- **Klient:** native iOS i **Swift + SwiftUI**, watchOS-ledsager i Swift, samt
  widgets/Live Activities (WidgetKit/ActivityKit). GPS via Core Location med
  baggrundsopdateringer. Lokal database (fx SwiftData/Core Data) som kilde til
  sandhed for offline-først.
- **Intervalmotor (sikkerhedskritisk):** turens timing skal være præcis og
  pålidelig i baggrunden, ved låst skærm og under afbrydelser. Den må ikke
  "drive" tidsmæssigt over en lang tur. Dette er et eksplicit kvalitetskrav, der
  skal testes (afsnit 16).
- **Backend:** konti, roller (løber/forælder), parring, fremgangssynk,
  opmuntringer og venne-/familie-relationer. Sikker, krypteret, med dataminimering.
- **Synk og konfliktløsning:** flere enheder pr. konto; veldefineret håndtering
  af, hvad der sker når offline-data fra to enheder mødes.
- **Konto, eksport og sletning:** brugeren (og forælder, hvor relevant) kan
  eksportere og slette alle data (kobler til afsnit 14).

## 14. Compliance og jura (kritisk pga. mindreårig)

Skal være på plads før lancering — appen kan ellers ikke udgives lovligt.

### 14.1 GDPR-compliance (grundkrav)
Appen skal være GDPR-compliant fra bunden:

- **Privacy & security by design og by default:** dataminimering, og de mest
  beskyttende indstillinger slået til som standard (al deling er opt-in).
- **Behandlingsgrundlag (retsgrundlag):** et klart, dokumenteret grundlag for
  hver type behandling (typisk samtykke for valgfrie funktioner som position og
  billeder). Helbreds- og lokationsdata er **følsomme/særlige kategorier** og
  kræver ekstra beskyttelse.
- **Børns data:** overhold særreglerne for mindreåriges samtykke (i Danmark er
  aldersgrænsen for digitalt samtykke 13 år; under det kræves forældresamtykke),
  og indhent forældresamtykke hvor det er påkrævet.
- **DPIA:** en konsekvensanalyse gennemføres, da der behandles følsomme data om
  en mindreårig (helbred, lokation, billeder).
- **De registreredes rettigheder:** indsigt, eksport (dataportabilitet),
  rettelse og **sletning ("retten til at blive glemt")** skal kunne udføres i
  appen — for både løber og forælder, hvor relevant.
- **Opbevaring og placering:** definerede slettefrister; data lagres sikkert og
  krypteret, så vidt muligt inden for EU/EØS; ingen overførsel til usikre
  tredjelande uden gyldigt grundlag.
- **Ingen reklame-/profilbrug:** persondata bruges aldrig til reklame, salg
  eller profilering, og deles ikke med tredjepart uden grundlag.
- **Databehandleraftaler:** med alle underleverandører (backend, kort, evt.
  analyse), og en ajourført fortegnelse over behandlingsaktiviteter.
- **Privatlivspolitik og samtykkeflow** skrevet i et klart, alderssvarende
  sprog, som en ung og en forælder kan forstå — ikke juridisk tågesnak.

### 14.2 Billeder — særlig håndtering
Billeder fra turene (afsnit 4.5) er persondata om en mindreårig og behandles
varsomt:

- **Privat som standard og lokalt:** billeder gemmes som udgangspunkt på
  enheden; sky-synk er valgfrit, krypteret og kun til brugerens eget arkiv.
- **Ingen automatisk deling:** intet billede deles med forælder, venner eller
  andre, medmindre hun aktivt vælger at dele netop det billede.
- **Lokationsmetadata (EXIF):** fjernes eller deles aldrig sammen med et billede,
  medmindre hun udtrykkeligt ønsker det — så et delt billede ikke røber, hvor
  hun bor eller løber.
- **Kun nødvendige tilladelser:** kamera-/fotoadgang anmodes om i kontekst og
  med forklaring; intet skanner eller analyserer billedernes indhold.
- **Sletning:** billeder kan slettes enkeltvis og indgår i fuld datasletning.

### 14.3 Platform og øvrig jura
- **Age-appropriate design:** følg principperne i fx britisk Age Appropriate
  Design Code og EU's tilgang — barnets tarv først.
- **Apple-regler:** HealthKit-, kamera- og lokationsdata behandles efter Apples
  retningslinjer; opfyld App Store-krav for sundhed/fitness og for apps, der
  bruges af børn — herunder forbuddet mod at markedsføre køb direkte til børn.
- **Medicinsk ansvarsfraskrivelse:** appen er ikke medicinsk rådgivning;
  henvis til læge ved tvivl eller symptomer (kobler til afsnit 9).
- **Tilgængelighed:** opfyld krav (fx EU's tilgængelighedsdirektiv) og iOS'
  tilgængelighedsstandarder.

Bemærk: dette er en specifikation, ikke juridisk rådgivning. En jurist/DPO bør
gennemgå løsningen før lancering.

## 15. Indhold, lyd og redaktionel kvalitet

- **Fagligt gennemgået program:** hele gå/løb-forløbet og videre-forløbene
  forfattes og godkendes af en kvalificeret løbetræner/fysioterapeut.
- **Stemme-coaching:** manuskripter til alle signaler og opmuntringer; valg
  mellem indtalt voiceover og syntetisk tale; gerne flere stemmer at vælge imellem.
- **Lyd- og haptik-assets:** designede, gennemtestede lyde og vibrationsmønstre
  for start, stop, nedtælling, stjerne, konfetti m.m.
- **Tone og copy:** alle tekster gennemgås for den varme, ikke-dømmende tone og
  for at undgå vægt-/udseendesprog.
- **Lokalisering:** sprog, enheder (km/mi) og kulturel tilpasning, hvis appen
  skal ud over Danmark.

## 16. Drift, kvalitet, test og analyse

- **Test:** automatiseret test af intervalmotorens nøjagtighed (baggrund, låst
  skærm, afbrydelser), UI-test af kerneflows, og en bred enheds-/iOS-version-matrix.
  Beta via TestFlight med rigtige begyndere.
- **Edge cases:** håndtér afbrudt tur (indgående opkald, app lukket, telefon
  løber tør for strøm, GPS mistet), pause/genoptag/afbryd en tur, gendannelse
  af en igangværende tur, samt rettelse/sletning af en logget tur.
- **Uge- og tidszone-grænser:** klar definition af, hvornår "den aktuelle uge"
  starter og slutter, så streak og ugemål opfører sig forudsigeligt.
- **Observability:** crash-rapportering og privatlivsvenlig, minimal og
  aggregeret analyse (opt-in, ekstra varsomt for mindreårige), så man kan måle
  fastholdelse uden at overvåge barnet.
- **Feature flags / remote config** til at justere indhold og features uden ny
  app-udgivelse.
- **Support og opdatering:** hjælp/kontakt i appen og en proces for løbende at
  opdatere program og indhold.
- **Udgivelse:** CI/CD, versionsstyring og en defineret release-proces.

## 17. Forretningsmodel (overvejelser)

- **Betalingsmodel:** sandsynligvis en gratis kerne plus abonnement, hvor
  **forælderen** betaler (fx en familieplan), da brugeren er mindreårig.
- **App Store-køb:** in-app-køb skal følge Apples regler, og køb må ikke
  markedsføres direkte til barnet.
- **Omkostningsdrivere:** backend/synk, kort/GPS-tjenester, evt. indtalt
  voiceover — skal indgå i en bæredygtig model.
Dette er produktovervejelser, ikke økonomisk rådgivning; en konkret model bør
fastlægges sammen med relevante rådgivere.

## 18. Fuldt funktionsomfang

Den fulde implementering omfatter samtlige funktioner i denne specifikation:

- Onboarding med helbreds-screening og valg af ugentligt træningsantal.
- Komplet gå/løb-forløb (grundforløb + videre-forløb mod 5 km og længere) med
  adaptiv justering.
- Ugeplanlægning, hvor brugeren angiver antal træninger for den aktuelle uge,
  med automatisk fordeling, hviledage og sikker progression (afsnit 6.2).
- Hviledags-oplevelse med sjove, beroligende animationer (afsnit 6.3).
- Live-tur med tracking af tid, distance og tempo, stemmecoach samt lyd- og
  haptiske signaler ved start/stop af hvert interval og nedtælling før skift.
- Konfetti-fejring og resumé ved målgang.
- Billede fra turen og billedarkiv knyttet til hver tur (afsnit 4.5).
- Fuld gamification: stjerner pr. interval, point/niveauer, tilgivende ugentlig
  streak knyttet til ugens valgte antal, badges/milepæle og avatar/maskot.
- Fremgangslog og oversigt over alle gennemførte træninger (liste + kalender,
  afsnit 6.4), badge-samling og venne-/delefunktioner (private, opt-in).
- Apple Watch-ledsager, widget/Live Activity, HealthKit, valgfri puls.
- Forælder-ledsager (samme app, to roller) med samtykkebaseret dashboard,
  opmuntringer og fælles fejring (afsnit 11).
- Personlig sikkerhed under løb: live-positionsdeling, afsted/hjemme-beskeder
  og SOS (afsnit 12).
- Venlige, ikke-pressende notifikationer og påmindelser.
- Indstillinger for lyd/stemme/haptik, musik, påmindelser, streak-fryser,
  forældredeling og privatliv.
- Fuld GDPR-compliance og øvrige compliance-, sikkerheds- og velbefindende-
  foranstaltninger (afsnit 9, 12 og 14).

## 19. Succeskriterier

Appen er en succes, hvis brugeren stadig løber efter det indledende forløb og
oplever, at hun "kan mere end før" — ikke målt på fart eller distance, men på
gennemførte ture, aktive streak-uger (tilpasset hendes egen ugentlige
tilgængelighed) og hendes egen tilbagemelding på, om det føltes sjovt og
overkommeligt.
