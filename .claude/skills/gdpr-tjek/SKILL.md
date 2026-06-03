---
name: gdpr-tjek
description: Gennemgår en ændring for privatliv/GDPR i Stjerneløb (mindreårig brugers helbreds-, lokations- og billeddata).
---
# GDPR-tjek

Gennemgå de aktuelle ændringer mod `rules/privatliv-gdpr.md` og svar punkt for
punkt:

1. **Dataminimering:** indsamles/gemmes kun det nødvendige? Kan noget blive
   lokalt frem for i skyen?
2. **Standardindstilling:** er deling/sporing opt-in og slået fra som standard?
3. **Følsomme data:** håndteres helbred, lokation og billeder med ekstra
   beskyttelse? EXIF/lokation fjernet før evt. deling af billeder?
4. **Samtykke:** er der et alderssvarende samtykke for ny dataindsamling?
   Kræves forældresamtykke?
5. **Sletning/eksport:** kan de nye data eksporteres og slettes, og rydder
   sletning lokalt + privat DB + delt zone?
6. **Lækager:** ingen persondata i logs; ingen tredjeparts-SDK der "ringer hjem".

Afslut med: en liste over fund (blokerende vs. anbefalinger) og forslag til
rettelser. Mind om, at endelig vurdering bør gennemgås af en DPO/jurist.
