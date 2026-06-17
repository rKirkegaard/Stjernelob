# Udrulning til App Store — tjekliste

Rækkefølge fra "koden bygger grønt" til "tingene kører for en rigtig bruger".
Punkterne markeret **[konto]** kræver en Apple Developer-konto; **[device]**
kræver test på en rigtig enhed; **[assets]** kræver leverede filer.

> Status nu: al kode-implementerbar funktionalitet er bygget og CI-verificeret
> (kompilerer + tests). Det resterende er konfiguration, afprøvning og assets —
> ikke ny kodning, på nær forælder-linket (CloudKit Sharing) og swiftformat-hook.

## 1. Apple Developer-konto og App ID — [konto]
- [ ] Meld dig ind i Apple Developer Program.
- [ ] Registrér App ID `com.rkirkegaard.stjernelob` med capabilities:
      **iCloud (CloudKit)**, **App Groups**, **HealthKit**, **Background Modes**,
      **Push Notifications** (til Live Activity + CloudKit-synk).
- [ ] Opret App Group `group.com.rkirkegaard.stjernelob` og knyt den til både
      app- og widget-App ID.
- [ ] Opret iCloud-container `iCloud.com.rkirkegaard.stjernelob`.
- [ ] Bekræft at bundle-id'erne i `App/project.yml` matcher de registrerede
      (app, widget `.widget`, watch `.watchkitapp`, framework `.shared`).

## 2. Signering — [konto]
- [ ] Sæt `DEVELOPMENT_TEAM` i `App/project.yml` (er tom nu).
- [ ] Vælg automatisk signering, og lad Xcode lave provisioning-profiler med
      ovenstående capabilities for hvert target (app, widget, watch).
- [ ] Verificér at de genererede entitlements-filer (laves af XcodeGen ud fra
      `project.yml`) matcher profilerne.

## 3. CloudKit — [konto] [device]
- [ ] Kør appen på en enhed logget ind i iCloud; bekræft at SwiftData opretter
      CloudKit-skemaet i **Development**-miljøet (record types for hver `@Model`).
- [ ] **Deploy schema to Production** i CloudKit Dashboard — uden dette kan
      App Store-brugere ikke synke. (Klassisk overset trin.)
- [ ] Test synk mellem to enheder på samme iCloud-konto.
- [ ] Test "Slet alle mine data": bekræft at sletningen forplanter sig til
      CloudKit (privat database) og ikke kun lokalt.

## 4. Afprøvning på device af det, der ikke kan testes uden hardware — [device]
- [ ] **GPS/distance**: distance måles og fryser ikke ved låst skærm under en tur.
- [ ] **Baggrundslyd/haptik**: intervalskift høres/mærkes med låst skærm.
- [ ] **HealthKit**: ture gemmes som workouts efter samtykke.
- [ ] **Live Activity / Dynamic Island**: vises og opdateres under en tur.
- [ ] **Widget**: viser næste tur + stime fra App Group og opdateres efter en tur.
- [ ] **watch↔telefon**: tur sendt til uret; gennemført tur på uret havner i
      historikken på telefonen (og kun én gang).
- [ ] **Notifikationer**: venlige påmindelser kommer på valgte tidspunkter.
- [ ] **Positionsdeling/SOS** (afsnit 12): opt-in, altid synlig, slukker ved turslut.

## 5. Resterende kode — (kan laves nu, kører på device)
- [ ] **Forælder-link via CloudKit Sharing** bag `SharingService`-protokollen
      (det kuraterede udsnit til en betroet voksen). Ikke skrevet endnu.
- [ ] **swiftformat pre-commit-hook** (udvikler-bekvemmelighed; CI håndhæver det
      allerede). Se [[swift-windows-build]]-noterne for en lokal binær.

## 6. Assets — [assets]
- [ ] Indtalt voiceover (erstatter syntetisk tale, `SpeechVoiceCoach`).
- [ ] Designede signal-/milepælslyde og haptik-mønstre (`FeedbackChannels`).
- [ ] Tegnet maskot (`Components`) og de tegnede badge-SVG'er (filnavn = badge-slug).

## 7. App Store-indsendelse — [konto]
- [ ] **App Privacy**-detaljer udfyldt: helbreds-, lokations- og billeddata for en
      mindreårig — vær præcis (jf. `rules/privatliv-gdpr.md`). Ingen tracking-SDK'er.
- [ ] Aldersvurdering sat; overvej forældresamtykke-flow hvor påkrævet.
- [ ] Screenshots, beskrivelse, support-URL, privatlivspolitik-URL.
- [ ] Vær forberedt på skærpet **App Review** for apps rettet mod børn.
- [ ] TestFlight-runde før offentlig udgivelse.

## Hurtig mental model
Konfigurér konto/capabilities → signér → kør på device og **deploy CloudKit-skema
til produktion** → ret det afprøvningen finder → assets på plads → privacy/review
→ indsend. Punkt 1–4 *skal* igennem, før noget kører i hænderne på en bruger.
