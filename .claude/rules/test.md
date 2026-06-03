# Test

- **Intervalmotoren (sikkerhedskritisk):** skal have grundige unit-tests for
  korrekt timing og rækkefølge af gå/løb-intervaller, inkl. opvarmning/nedkøling.
  Test for tids-"drift" over en lang tur og adfærd ved afbrydelser (opkald,
  app i baggrund, låst skærm) via simulerede/abstraherede ure.
- **Domænelogik:** unit-test programprogression, ugemål/streak (inkl. tilgivende
  regler og hviledage), point/stjerner.
- **Edge cases:** afbrudt tur, GPS-tab, pause/genoptag/afbryd, gendannelse af
  igangværende tur, uge-/tidszone-grænser, rettelse/sletning af logget tur.
- **UI:** snapshot-/UI-tests af kerneskærme (under-tur, resumé/konfetti,
  hviledag, ugeplanlægger, historik).
- **Datasletning:** test at "slet alle mine data" rydder lokalt + privat DB +
  delt zone.
- Kør test før en opgave meldes færdig. Ny logik kommer med tests.
