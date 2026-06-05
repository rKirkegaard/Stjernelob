{
  "meta": {
    "programName": "Løbeprogram — fra sofa til løber",
    "targetAudience": "Teenager, begynder, ringe form",
    "totalWeeks": 20,
    "phases": [
      {
        "name": "Første skridt",
        "weeks": "1–4",
        "focus": "Vane og tilpasning"
      },
      {
        "name": "Bygger op",
        "weeks": "5–8",
        "focus": "Længere løbeblokke"
      },
      {
        "name": "Finder styrken",
        "weeks": "9–12",
        "focus": "5–7 min blokke"
      },
      {
        "name": "Løber med selvtillid",
        "weeks": "13–16",
        "focus": "10–15 min blokke"
      },
      {
        "name": "Kontinuerlig løber",
        "weeks": "17–20",
        "focus": "20–30 min sammenhængende"
      }
    ],
    "sessionStructure": {
      "warmup": "Rolig gang i warmup-minutter",
      "intervals": "Skiftende løb og gang som defineret",
      "cooldown": "Rolig gang i cooldown-minutter",
      "runSignal": "interval_start — 3 stigende bip + 3 korte vibrationer",
      "walkSignal": "interval_slut — 2 faldende bip + 1 lang vibration"
    }
  },
  "adaptiveLogic": {
    "description": "Adaptive planlægning — regler når en session misses",
    "rules": [
      {
        "trigger": "Én session misset i ugen",
        "action": "Flyt den missede session til næste ledige dag. Ugen forlænges med 1 dag. Næste uge starter som planlagt.",
        "swiftHint": "missedCount == 1 → appendSession(to: currentWeek, day: nextAvailableDay)"
      },
      {
        "trigger": "To sessioner misset i samme uge",
        "action": "Gentag den fulde uge. Alle sessioner nulstilles til 'ikke gennemført'. Badgen for ugen kan stadig optjenes.",
        "swiftHint": "missedCount >= 2 → repeatWeek(weekIndex: current)"
      },
      {
        "trigger": "Hele ugen misset (0 sessioner)",
        "action": "Gå én uge tilbage i programmet (repeat forrige uge) for at genopbygge rytmen. Vis en venlig besked: 'Velkommen tilbage — lad os starte blidt.'",
        "swiftHint": "missedCount == totalSessions → stepBack(weeks: 1)"
      },
      {
        "trigger": "To uger i træk helt misset",
        "action": "Gå to uger tilbage. Vis besked: 'Kroppen starter forfra efter en pause — det er klogt at bygge op igen.'",
        "swiftHint": "consecutiveMissedWeeks >= 2 → stepBack(weeks: 2)"
      },
      {
        "trigger": "Tre eller flere uger misset",
        "action": "Genstart fra uge 1 i nuværende fase (ikke fra uge 1 i hele programmet). Vis besked: 'Ingen skam — kroppen er klar til en blød genstart.'",
        "swiftHint": "consecutiveMissedWeeks >= 3 → restartPhase()"
      }
    ],
    "weekCompletionRule": "En uge er gennemført når minimum 2 ud af 3 sessioner er markeret færdige. Bonussessioner tæller ikke med i kravet.",
    "progressionRule": "Avancér kun til næste uge når nuværende uge er markeret gennemført. Aldrig spring en uge over.",
    "streakResetRule": "En streak nulstilles kun hvis der går mere end 10 dage uden en session — ikke ved én misset dag."
  },
  "weeks": [
    {
      "week": 1,
      "phase": "Første skridt",
      "title": "Bare kom ud",
      "difficulty": "nem",
      "tip": "Du behøver ikke løbe en meter mere end det føles okay. Gangen er en del af træningen.",
      "badge": "første-skridt",
      "sessions": [
        {
          "label": "Tur 1",
          "warmup": 3,
          "intervals": [
            {
              "run": 20,
              "walk": 90,
              "reps": 4
            }
          ],
          "cooldown": 3,
          "note": "4 × 20 sek løb / 90 sek gang"
        },
        {
          "label": "Tur 2",
          "warmup": 3,
          "intervals": [
            {
              "run": 20,
              "walk": 90,
              "reps": 4
            }
          ],
          "cooldown": 3,
          "note": "4 × 20 sek løb / 90 sek gang"
        }
      ]
    },
    {
      "week": 2,
      "phase": "Første skridt",
      "title": "Find rytmen",
      "difficulty": "nem",
      "tip": "Hvis du kan snakke undervejs, løber du i det rigtige tempo.",
      "badge": "2-i-en-uge",
      "sessions": [
        {
          "label": "Tur 1",
          "warmup": 3,
          "intervals": [
            {
              "run": 20,
              "walk": 80,
              "reps": 5
            }
          ],
          "cooldown": 3,
          "note": "5 × 20 sek løb / 80 sek gang"
        },
        {
          "label": "Tur 2",
          "warmup": 3,
          "intervals": [
            {
              "run": 25,
              "walk": 80,
              "reps": 5
            }
          ],
          "cooldown": 3,
          "note": "5 × 25 sek løb / 80 sek gang"
        },
        {
          "label": "Tur 3 (bonus)",
          "warmup": 3,
          "intervals": [
            {
              "run": 25,
              "walk": 90,
              "reps": 4
            }
          ],
          "cooldown": 3,
          "note": "4 × 25 sek løb / 90 sek gang"
        }
      ]
    },
    {
      "week": 3,
      "phase": "Første skridt",
      "title": "Længere løb",
      "difficulty": "nem",
      "tip": "Benene begynder at huske det her. Du er ved at blive løber.",
      "badge": "3-ugers-streak",
      "sessions": [
        {
          "label": "Tur 1",
          "warmup": 3,
          "intervals": [
            {
              "run": 30,
              "walk": 75,
              "reps": 5
            }
          ],
          "cooldown": 3,
          "note": "5 × 30 sek løb / 75 sek gang"
        },
        {
          "label": "Tur 2",
          "warmup": 3,
          "intervals": [
            {
              "run": 40,
              "walk": 75,
              "reps": 5
            }
          ],
          "cooldown": 3,
          "note": "5 × 40 sek løb / 75 sek gang"
        },
        {
          "label": "Tur 3 (bonus)",
          "warmup": 3,
          "intervals": [
            {
              "run": 40,
              "walk": 80,
              "reps": 5
            }
          ],
          "cooldown": 3,
          "note": "5 × 40 sek løb / 80 sek gang"
        }
      ]
    },
    {
      "week": 4,
      "phase": "Første skridt",
      "title": "Halvt halvt",
      "difficulty": "nem",
      "tip": "Uge 4 er en milepæl — du har løbet i en hel måned!",
      "badge": "maanedshelt",
      "sessions": [
        {
          "label": "Tur 1",
          "warmup": 3,
          "intervals": [
            {
              "run": 45,
              "walk": 60,
              "reps": 6
            }
          ],
          "cooldown": 3,
          "note": "6 × 45 sek løb / 60 sek gang"
        },
        {
          "label": "Tur 2",
          "warmup": 3,
          "intervals": [
            {
              "run": 60,
              "walk": 60,
              "reps": 5
            }
          ],
          "cooldown": 3,
          "note": "5 × 1 min løb / 1 min gang"
        },
        {
          "label": "Tur 3",
          "warmup": 3,
          "intervals": [
            {
              "run": 60,
              "walk": 75,
              "reps": 6
            }
          ],
          "cooldown": 3,
          "note": "6 × 1 min løb / 75 sek gang"
        }
      ]
    },
    {
      "week": 5,
      "phase": "Bygger op",
      "title": "1-minuts løb",
      "difficulty": "rolig",
      "tip": "Et minut løb føles langt — men du har allerede vist at du kan.",
      "badge": "ubrydelig",
      "sessions": [
        {
          "label": "Tur 1",
          "warmup": 3,
          "intervals": [
            {
              "run": 60,
              "walk": 60,
              "reps": 6
            }
          ],
          "cooldown": 3,
          "note": "6 × 1 min løb / 1 min gang"
        },
        {
          "label": "Tur 2",
          "warmup": 3,
          "intervals": [
            {
              "run": 75,
              "walk": 60,
              "reps": 6
            }
          ],
          "cooldown": 3,
          "note": "6 × 75 sek løb / 60 sek gang"
        },
        {
          "label": "Tur 3",
          "warmup": 3,
          "intervals": [
            {
              "run": 90,
              "walk": 60,
              "reps": 5
            }
          ],
          "cooldown": 3,
          "note": "5 × 90 sek løb / 60 sek gang"
        }
      ]
    },
    {
      "week": 6,
      "phase": "Bygger op",
      "title": "Løb dominerer",
      "difficulty": "rolig",
      "tip": "Gangpauserne er ikke at give op — de er en del af strategien.",
      "badge": "en-uge-i-traek",
      "sessions": [
        {
          "label": "Tur 1",
          "warmup": 3,
          "intervals": [
            {
              "run": 90,
              "walk": 45,
              "reps": 6
            }
          ],
          "cooldown": 3,
          "note": "6 × 90 sek løb / 45 sek gang"
        },
        {
          "label": "Tur 2",
          "warmup": 3,
          "intervals": [
            {
              "run": 120,
              "walk": 45,
              "reps": 5
            }
          ],
          "cooldown": 3,
          "note": "5 × 2 min løb / 45 sek gang"
        },
        {
          "label": "Tur 3",
          "warmup": 3,
          "intervals": [
            {
              "run": 120,
              "walk": 60,
              "reps": 5
            }
          ],
          "cooldown": 3,
          "note": "5 × 2 min løb / 60 sek gang"
        }
      ]
    },
    {
      "week": 7,
      "phase": "Bygger op",
      "title": "Stadig stærkere",
      "difficulty": "rolig",
      "tip": "Kroppen tilpasser sig hurtigere end du tror. Tillid til processen.",
      "badge": "tilbage-igen",
      "sessions": [
        {
          "label": "Tur 1",
          "warmup": 3,
          "intervals": [
            {
              "run": 120,
              "walk": 45,
              "reps": 6
            }
          ],
          "cooldown": 3,
          "note": "6 × 2 min løb / 45 sek gang"
        },
        {
          "label": "Tur 2",
          "warmup": 3,
          "intervals": [
            {
              "run": 150,
              "walk": 45,
              "reps": 5
            }
          ],
          "cooldown": 3,
          "note": "5 × 2,5 min løb / 45 sek gang"
        },
        {
          "label": "Tur 3",
          "warmup": 3,
          "intervals": [
            {
              "run": 150,
              "walk": 60,
              "reps": 5
            }
          ],
          "cooldown": 3,
          "note": "5 × 2,5 min løb / 60 sek gang"
        }
      ]
    },
    {
      "week": 8,
      "phase": "Bygger op",
      "title": "2 måneder løber!",
      "difficulty": "rolig",
      "tip": "To måneder inde. Du er ikke begynder mere — du er løber.",
      "badge": "maanedshelt",
      "sessions": [
        {
          "label": "Tur 1",
          "warmup": 3,
          "intervals": [
            {
              "run": 150,
              "walk": 45,
              "reps": 6
            }
          ],
          "cooldown": 3,
          "note": "6 × 2,5 min løb / 45 sek gang"
        },
        {
          "label": "Tur 2",
          "warmup": 3,
          "intervals": [
            {
              "run": 180,
              "walk": 45,
              "reps": 5
            }
          ],
          "cooldown": 3,
          "note": "5 × 3 min løb / 45 sek gang"
        },
        {
          "label": "Tur 3",
          "warmup": 3,
          "intervals": [
            {
              "run": 180,
              "walk": 60,
              "reps": 5
            }
          ],
          "cooldown": 3,
          "note": "5 × 3 min løb / 60 sek gang"
        }
      ]
    },
    {
      "week": 9,
      "phase": "Finder styrken",
      "title": "3-minutters blokke",
      "difficulty": "medium",
      "tip": "3 minutter løb i træk er et stort skridt. Du klarer det.",
      "badge": "3-i-en-uge",
      "sessions": [
        {
          "label": "Tur 1",
          "warmup": 3,
          "intervals": [
            {
              "run": 180,
              "walk": 45,
              "reps": 6
            }
          ],
          "cooldown": 3,
          "note": "6 × 3 min løb / 45 sek gang"
        },
        {
          "label": "Tur 2",
          "warmup": 3,
          "intervals": [
            {
              "run": 210,
              "walk": 45,
              "reps": 5
            }
          ],
          "cooldown": 3,
          "note": "5 × 3,5 min løb / 45 sek gang"
        },
        {
          "label": "Tur 3",
          "warmup": 3,
          "intervals": [
            {
              "run": 240,
              "walk": 60,
              "reps": 4
            }
          ],
          "cooldown": 3,
          "note": "4 × 4 min løb / 60 sek gang"
        }
      ]
    },
    {
      "week": 10,
      "phase": "Finder styrken",
      "title": "Komfortzone udfordres",
      "difficulty": "medium",
      "tip": "Det er her den mentale styrke trænes. Du ved du kan — selvom det er hårdt.",
      "badge": "podcast-runner",
      "sessions": [
        {
          "label": "Tur 1",
          "warmup": 3,
          "intervals": [
            {
              "run": 240,
              "walk": 45,
              "reps": 5
            }
          ],
          "cooldown": 3,
          "note": "5 × 4 min løb / 45 sek gang"
        },
        {
          "label": "Tur 2",
          "warmup": 3,
          "intervals": [
            {
              "run": 270,
              "walk": 45,
              "reps": 4
            }
          ],
          "cooldown": 3,
          "note": "4 × 4,5 min løb / 45 sek gang"
        },
        {
          "label": "Tur 3",
          "warmup": 3,
          "intervals": [
            {
              "run": 300,
              "walk": 60,
              "reps": 4
            }
          ],
          "cooldown": 3,
          "note": "4 × 5 min løb / 60 sek gang"
        }
      ]
    },
    {
      "week": 11,
      "phase": "Finder styrken",
      "title": "5 minutter!",
      "difficulty": "medium",
      "tip": "5 minutter løb i træk. Det er ikke en lille ting. Det er stort.",
      "badge": "straek-stjerne",
      "sessions": [
        {
          "label": "Tur 1",
          "warmup": 3,
          "intervals": [
            {
              "run": 300,
              "walk": 60,
              "reps": 4
            }
          ],
          "cooldown": 3,
          "note": "4 × 5 min løb / 60 sek gang"
        },
        {
          "label": "Tur 2",
          "warmup": 3,
          "intervals": [
            {
              "run": 300,
              "walk": 45,
              "reps": 5
            }
          ],
          "cooldown": 3,
          "note": "5 × 5 min løb / 45 sek gang"
        },
        {
          "label": "Tur 3",
          "warmup": 3,
          "intervals": [
            {
              "run": 360,
              "walk": 60,
              "reps": 4
            }
          ],
          "cooldown": 3,
          "note": "4 × 6 min løb / 60 sek gang"
        }
      ]
    },
    {
      "week": 12,
      "phase": "Finder styrken",
      "title": "3 måneder løber!",
      "difficulty": "medium",
      "tip": "Tre måneder. Se tilbage på uge 1. Det er ikke den samme krop — eller det samme sind.",
      "badge": "maanedshelt",
      "sessions": [
        {
          "label": "Tur 1",
          "warmup": 3,
          "intervals": [
            {
              "run": 360,
              "walk": 45,
              "reps": 4
            }
          ],
          "cooldown": 3,
          "note": "4 × 6 min løb / 45 sek gang"
        },
        {
          "label": "Tur 2",
          "warmup": 3,
          "intervals": [
            {
              "run": 420,
              "walk": 60,
              "reps": 3
            }
          ],
          "cooldown": 3,
          "note": "3 × 7 min løb / 60 sek gang"
        },
        {
          "label": "Tur 3",
          "warmup": 3,
          "intervals": [
            {
              "run": 420,
              "walk": 45,
              "reps": 4
            }
          ],
          "cooldown": 3,
          "note": "4 × 7 min løb / 45 sek gang"
        }
      ]
    },
    {
      "week": 13,
      "phase": "Løber med selvtillid",
      "title": "Lange blokke",
      "difficulty": "stærk",
      "tip": "Gangpauserne er nu korte. Du løber mere end du går.",
      "badge": "loebemakker",
      "sessions": [
        {
          "label": "Tur 1",
          "warmup": 3,
          "intervals": [
            {
              "run": 480,
              "walk": 60,
              "reps": 3
            }
          ],
          "cooldown": 3,
          "note": "3 × 8 min løb / 60 sek gang"
        },
        {
          "label": "Tur 2",
          "warmup": 3,
          "intervals": [
            {
              "run": 480,
              "walk": 45,
              "reps": 3
            }
          ],
          "cooldown": 3,
          "note": "3 × 8 min løb / 45 sek gang"
        },
        {
          "label": "Tur 3",
          "warmup": 3,
          "intervals": [
            {
              "run": 540,
              "walk": 60,
              "reps": 3
            }
          ],
          "cooldown": 3,
          "note": "3 × 9 min løb / 60 sek gang"
        }
      ]
    },
    {
      "week": 14,
      "phase": "Løber med selvtillid",
      "title": "10 minutter!",
      "difficulty": "stærk",
      "tip": "10 minutter løb i træk. Du husker da du næsten ikke kunne løbe 20 sekunder?",
      "badge": "ny-rute",
      "sessions": [
        {
          "label": "Tur 1",
          "warmup": 3,
          "intervals": [
            {
              "run": 540,
              "walk": 60,
              "reps": 3
            }
          ],
          "cooldown": 3,
          "note": "3 × 9 min løb / 60 sek gang"
        },
        {
          "label": "Tur 2",
          "warmup": 3,
          "intervals": [
            {
              "run": 600,
              "walk": 60,
              "reps": 3
            }
          ],
          "cooldown": 3,
          "note": "3 × 10 min løb / 60 sek gang"
        },
        {
          "label": "Tur 3",
          "warmup": 3,
          "intervals": [
            {
              "run": 600,
              "walk": 45,
              "reps": 3
            }
          ],
          "cooldown": 3,
          "note": "3 × 10 min løb / 45 sek gang"
        }
      ]
    },
    {
      "week": 15,
      "phase": "Løber med selvtillid",
      "title": "Næsten kontinuerligt",
      "difficulty": "stærk",
      "tip": "Gangpauserne er nu næsten symbolske. Du er løber.",
      "badge": "naturpige",
      "sessions": [
        {
          "label": "Tur 1",
          "warmup": 3,
          "intervals": [
            {
              "run": 600,
              "walk": 60,
              "reps": 3
            }
          ],
          "cooldown": 3,
          "note": "3 × 10 min løb / 60 sek gang"
        },
        {
          "label": "Tur 2",
          "warmup": 3,
          "intervals": [
            {
              "run": 720,
              "walk": 60,
              "reps": 2
            },
            {
              "run": 600,
              "walk": 0,
              "reps": 1
            }
          ],
          "cooldown": 3,
          "note": "2 × 12 min løb / 60 sek gang + 1 × 10 min"
        },
        {
          "label": "Tur 3",
          "warmup": 3,
          "intervals": [
            {
              "run": 720,
              "walk": 60,
              "reps": 3
            }
          ],
          "cooldown": 3,
          "note": "3 × 12 min løb / 60 sek gang"
        }
      ]
    },
    {
      "week": 16,
      "phase": "Løber med selvtillid",
      "title": "4 måneder — du flyver!",
      "difficulty": "stærk",
      "tip": "Fra gang/løb-begynder til løber der klarer 15 min i træk. Utroligt.",
      "badge": "maanedshelt",
      "sessions": [
        {
          "label": "Tur 1",
          "warmup": 3,
          "intervals": [
            {
              "run": 720,
              "walk": 60,
              "reps": 3
            }
          ],
          "cooldown": 3,
          "note": "3 × 12 min løb / 60 sek gang"
        },
        {
          "label": "Tur 2",
          "warmup": 3,
          "intervals": [
            {
              "run": 900,
              "walk": 60,
              "reps": 2
            }
          ],
          "cooldown": 3,
          "note": "2 × 15 min løb / 60 sek gang"
        },
        {
          "label": "Tur 3",
          "warmup": 3,
          "intervals": [
            {
              "run": 900,
              "walk": 60,
              "reps": 2
            }
          ],
          "cooldown": 3,
          "note": "2 × 15 min løb / 60 sek gang"
        }
      ]
    },
    {
      "week": 17,
      "phase": "Kontinuerlig løber",
      "title": "20 minutter i sigte",
      "difficulty": "avanceret",
      "tip": "Du nærmer dig 20 min sammenhængende løb. Det er målet for mange voksne løbere.",
      "badge": "loebedagbog",
      "sessions": [
        {
          "label": "Tur 1",
          "warmup": 3,
          "intervals": [
            {
              "run": 900,
              "walk": 60,
              "reps": 2
            }
          ],
          "cooldown": 3,
          "note": "2 × 15 min løb / 60 sek gang"
        },
        {
          "label": "Tur 2",
          "warmup": 3,
          "intervals": [
            {
              "run": 1020,
              "walk": 60,
              "reps": 2
            }
          ],
          "cooldown": 3,
          "note": "2 × 17 min løb / 60 sek gang"
        },
        {
          "label": "Tur 3",
          "warmup": 3,
          "intervals": [
            {
              "run": 1080,
              "walk": 60,
              "reps": 2
            }
          ],
          "cooldown": 3,
          "note": "2 × 18 min løb / 60 sek gang"
        }
      ]
    },
    {
      "week": 18,
      "phase": "Kontinuerlig løber",
      "title": "20 minutter!",
      "difficulty": "avanceret",
      "tip": "20 minutter sammenhængende løb. Det er her mange begynderprogrammer slutter. Du startede fra 20 sekunder.",
      "badge": "aldrig-give-op",
      "sessions": [
        {
          "label": "Tur 1",
          "warmup": 3,
          "intervals": [
            {
              "run": 1080,
              "walk": 60,
              "reps": 2
            }
          ],
          "cooldown": 3,
          "note": "2 × 18 min løb / 60 sek gang"
        },
        {
          "label": "Tur 2",
          "warmup": 3,
          "intervals": [
            {
              "run": 1200,
              "walk": 60,
              "reps": 1
            },
            {
              "run": 900,
              "walk": 0,
              "reps": 1
            }
          ],
          "cooldown": 3,
          "note": "20 min løb / 60 sek gang / 15 min løb"
        },
        {
          "label": "Tur 3",
          "warmup": 3,
          "intervals": [
            {
              "run": 1200,
              "walk": 60,
              "reps": 2
            }
          ],
          "cooldown": 3,
          "note": "2 × 20 min løb / 60 sek gang"
        }
      ]
    },
    {
      "week": 19,
      "phase": "Kontinuerlig løber",
      "title": "Konsoliderer",
      "difficulty": "avanceret",
      "tip": "Denne uge gentager vi for at gøre 20 min til noget normalt — ikke noget ekstraordinært.",
      "badge": "fejer-dig-selv",
      "sessions": [
        {
          "label": "Tur 1",
          "warmup": 3,
          "intervals": [
            {
              "run": 1200,
              "walk": 60,
              "reps": 2
            }
          ],
          "cooldown": 3,
          "note": "2 × 20 min løb / 60 sek gang"
        },
        {
          "label": "Tur 2",
          "warmup": 3,
          "intervals": [
            {
              "run": 1200,
              "walk": 45,
              "reps": 2
            }
          ],
          "cooldown": 3,
          "note": "2 × 20 min løb / 45 sek gang"
        },
        {
          "label": "Tur 3",
          "warmup": 3,
          "intervals": [
            {
              "run": 1500,
              "walk": 60,
              "reps": 1
            },
            {
              "run": 900,
              "walk": 0,
              "reps": 1
            }
          ],
          "cooldown": 3,
          "note": "25 min løb / 60 sek gang / 15 min løb"
        }
      ]
    },
    {
      "week": 20,
      "phase": "Kontinuerlig løber",
      "title": "Du er løber — officielt!",
      "difficulty": "avanceret",
      "tip": "5 måneder siden du tog dine første 20 sekunders løb. Nu løber du 30 minutter. Det er ikke tilfældigt — det er dig.",
      "badge": "ubrydelig",
      "sessions": [
        {
          "label": "Tur 1",
          "warmup": 3,
          "intervals": [
            {
              "run": 1500,
              "walk": 60,
              "reps": 1
            },
            {
              "run": 1200,
              "walk": 0,
              "reps": 1
            }
          ],
          "cooldown": 3,
          "note": "25 min løb / 60 sek gang / 20 min løb"
        },
        {
          "label": "Tur 2",
          "warmup": 3,
          "intervals": [
            {
              "run": 1800,
              "walk": 0,
              "reps": 1
            }
          ],
          "cooldown": 3,
          "note": "30 min sammenhængende løb!"
        },
        {
          "label": "Tur 3 — Festtur!",
          "warmup": 3,
          "intervals": [
            {
              "run": 1800,
              "walk": 0,
              "reps": 1
            }
          ],
          "cooldown": 5,
          "note": "30 min sammenhængende løb — du har klaret det!"
        }
      ]
    }
  ]
}