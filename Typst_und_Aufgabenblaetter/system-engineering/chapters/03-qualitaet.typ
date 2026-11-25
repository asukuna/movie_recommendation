#let rot = rgb("#E00018")
#let grau = rgb("#586870")
#let hell = rgb("#F4F6F7")
#let prio-fill = rgb("#FDECEE")

= Qualitätsanforderungen

Unser Produktziel ist Kundenbindung. Die Listen sollen Vertrautes enthalten, damit sich niemand verloren fühlt, und zugleich internationale Filme zeigen, damit das Angebot nicht langweilig wird und Menschen nicht abspringen. Die Merkmale stammen aus ISO 25010. @quality-tree zeigt, wie unsere Szenarien darin einsortiert sind. Rot markiert sind die priorisierten Szenarien B01, E01 und W01.
#v(0.5em)
== Quality Tree

#figure(
  {
    let strich(a, b) = place(
      top + left,
      line(start: a, end: b, stroke: 0.7pt + grau),
    )
    let merkmal(x, y, h, body) = place(top + left, dx: x, dy: y, box(
      width: 3.3cm,
      height: h,
      inset: 4pt,
      radius: 3pt,
      fill: white,
      stroke: 0.8pt + grau,
    )[
      #set align(center + horizon)
      #set par(justify: false, leading: 0.2em)
      #set text(size: 9.5pt)
      #body
    ])
    let karte(y, priorisiert, body) = place(top + left, dx: 8.4cm, dy: y, box(
      width: 7.6cm,
      height: 1.58cm,
      inset: (x: 6pt, y: 3pt),
      radius: 3pt,
      fill: if priorisiert { prio-fill } else { hell },
      stroke: 0.8pt + if priorisiert { rot } else { grau },
    )[
      #set align(left + horizon)
      #set par(justify: false, leading: 0.25em)
      #set text(size: 9pt)
      #body
    ])

    box(width: 16cm, height: 15.4cm)[
      #strich((3.15cm, 7.67cm), (3.65cm, 7.67cm))
      #strich((3.65cm, 0.79cm), (3.65cm, 14.55cm))
      #strich((3.65cm, 0.79cm), (4.1cm, 0.79cm))
      #strich((3.65cm, 3.37cm), (4.1cm, 3.37cm))
      #strich((3.65cm, 6.81cm), (4.1cm, 6.81cm))
      #strich((3.65cm, 11.11cm), (4.1cm, 11.11cm))
      #strich((3.65cm, 14.55cm), (4.1cm, 14.55cm))
      #strich((7.4cm, 0.79cm), (8.4cm, 0.79cm))
      #strich((7.4cm, 2.51cm), (8.4cm, 2.51cm))
      #strich((7.4cm, 4.23cm), (8.4cm, 4.23cm))
      #strich((7.4cm, 5.95cm), (8.4cm, 5.95cm))
      #strich((7.4cm, 7.67cm), (8.4cm, 7.67cm))
      #strich((7.4cm, 9.39cm), (8.4cm, 9.39cm))
      #strich((7.4cm, 11.11cm), (8.4cm, 11.11cm))
      #strich((7.4cm, 12.83cm), (8.4cm, 12.83cm))
      #strich((7.4cm, 14.55cm), (8.4cm, 14.55cm))

      #place(top + left, dx: 0cm, dy: 6.42cm, box(
        width: 3.15cm,
        height: 2.5cm,
        inset: 5pt,
        radius: 4pt,
        fill: rot,
        stroke: 0.8pt + rot,
      )[
        #align(center + horizon)[
          #set par(justify: false, leading: 0.25em)
          #text(fill: white, weight: "bold", size: 8pt)[Qualität des Empfehlungssystems]
        ]
      ])

      #merkmal(4.1cm, 0.16cm, 1.25cm)[Funktionale Eignung #linebreak() #text(fill: grau, size: 7.5pt)[Korrektheit]]
      #merkmal(4.1cm, 2.2cm, 2.35cm)[Benutzbarkeit #linebreak() #text(fill: grau, size: 7.5pt)[Attraktivität, Erklärbarkeit]]
      #merkmal(4.1cm, 5.64cm, 2.35cm)[Leistungseffizienz #linebreak() #text(fill: grau, size: 7.5pt)[Zeitverhalten]]
      #merkmal(4.1cm, 9.04cm, 4.15cm)[Zuverlässigkeit #linebreak() #text(fill: grau, size: 7.5pt)[Fehlertoleranz #linebreak() Datenintegrität #linebreak() Verfügbarkeit]]
      #merkmal(4.1cm, 13.92cm, 1.25cm)[Wartbarkeit #linebreak() #text(fill: grau, size: 7.5pt)[Analysierbarkeit]]

      #karte(0cm, false)[*F01* #linebreak() Mindestens zwei der fünf Filme sind kulturell neu.]
      #karte(1.72cm, true)[*B01* #h(0.3em) #text(fill: rot, size: 7pt)[priorisiert] #linebreak() Mindestens drei Länder, kein Subgenre öfter als zweimal.]
      #karte(3.44cm, false)[*B02* #linebreak() Zu jedem Film eine Begründung mit 80 bis 250 Zeichen.]
      #karte(5.16cm, true)[*E01* #h(0.3em) #text(fill: rot, size: 7pt)[priorisiert] #linebreak() Die fünf Empfehlungen in höchstens fünf Sekunden.]
      #karte(6.88cm, false)[*E02* #linebreak() Wöchentliches Training in höchstens fünf Minuten.]
      #karte(8.6cm, false)[*Z01* #linebreak() Ohne Referenzfilm trotzdem fünf gültige Filme.]
      #karte(10.32cm, false)[*Z02* #linebreak() Einträge ohne Land, Genre oder Jahr kommen ins Fehlerprotokoll.]
      #karte(12.04cm, false)[*V01* #linebreak() In 99 % der Anfragen kommt eine Empfehlung zurück.]
      #karte(13.76cm, true)[*W01* #h(0.3em) #text(fill: rot, size: 7pt)[priorisiert] #linebreak() Die Request-ID führt in höchstens zehn Sekunden zum Logeintrag.]
    ]
  },
  caption: [Quality Tree nach ISO 25010. Rot markierte Szenarien sind priorisiert.],
) <quality-tree>

#pagebreak()

== Qualitätsszenarien

Jedes Szenario beschreibt einen Auslöser und das erwartete Verhalten des Systems. Das Maß sagt, woran wir es prüfen. Der Aufbau folgt Dokchess, die Reihenfolge entspricht @quality-tree.

#v(0.4em)

#[
#set text(size: 11.5pt)
#set par(justify: false, leading: 0.35em)
#table(
  columns: (1.35cm, 3.6cm, 1fr, 4.3cm),
  stroke: 0.5pt + luma(190),
  inset: 4pt,
  fill: (x, y) => if y == 0 { hell },
  [*ID*], [*Merkmal*], [*Szenario*], [*Maß*],

  [*F01*],
  [Funktionale Eignung, Korrektheit],
  [Die Person schickt den Fragebogen ab. Jede Liste enthält mindestens zwei kulturell neue Filme.],
  [2 von 5 Filmen (40 %), in 100 % der Listen. Land nicht USA/UK, Sprache nicht Englisch.],

  [*B01* #linebreak() #text(fill: rot, size: 7pt)[hoch]],
  [Benutzbarkeit, Attraktivität],
  [Die Liste wird angezeigt. Die fünf Filme streuen über Länder und Subgenres.],
  [Mindestens 3 Produktionsländer. Jedes Subgenre höchstens 2-mal (40 %).],

  [*B02*],
  [Benutzbarkeit, Erklärbarkeit],
  [Die Liste wird angezeigt. Zu jedem Film gibt es eine Begründung.],
  [100 % der fünf Filme, 80 bis 250 Zeichen, mit Bezug zum gewählten Genre oder Referenzfilm.],

  [*E01* #linebreak() #text(fill: rot, size: 7pt)[hoch]],
  [Leistungseffizienz, Zeitverhalten],
  [Die Person hat den Fragebogen abgeschickt und wartet auf die Liste.],
  [Höchstens 5 Sekunden bis zur Anzeige der fünf Filme.],

  [*E02*],
  [Leistungseffizienz, Zeitverhalten],
  [Der Scheduler startet das wöchentliche Training mit dem neuen Feedback.],
  [Höchstens 5 Minuten bei rund 86.000 Titeln und 1.000 Rückmeldungen, einschließlich Abruf und Prüfung.],

  [*Z01*],
  [Zuverlässigkeit, Fehlertoleranz],
  [Die Person wählt nur ein Genre und bewertet keinen Referenzfilm.],
  [In 100 % der Fälle exakt 5 Filme, die F01 und B01 einhalten.],

  [*Z02*],
  [Zuverlässigkeit, Datenintegrität],
  [Der wöchentliche Import liest die Filmdaten.],
  [100 % der Einträge ohne Land, Genre oder Jahr landen im Fehlerprotokoll. Danach 0 % leere Werte bei diesen Feldern.],

  [*V01*],
  [Zuverlässigkeit, Verfügbarkeit],
  [Eine Person fordert Empfehlungen an.],
  [In 99 % der Anfragen kommt eine Liste zurück.],

  [*W01* #linebreak() #text(fill: rot, size: 7pt)[hoch]],
  [Wartbarkeit, Analysierbarkeit],
  [Eine konkrete Empfehlung soll nachvollzogen werden.],
  [Für 100 % der Empfehlungen liegen Eingabe, Dauer und MLflow-Run-ID über die Request-ID in höchstens 10 Sekunden vor.],
)
]

#pagebreak()

== Begründungen

#[
#set par(leading: 0.5em, spacing: 0.55em)

Drei Szenarien tragen das Produkt. B01 hält die Liste vielfältig, sonst wirkt sie trotz internationaler Filme eng. E01 hält die Antwort unter fünf Sekunden, sonst probiert niemand die Funktion aus. W01 macht jede Empfehlung nachvollziehbar, sonst finden wir eine falsche Entscheidung nicht wieder. Die übrigen Szenarien sichern die Quote, den Einstieg, die Daten, die Erklärung, das Training und die Erreichbarkeit.
#v(0.7em)
*F01, Korrektheit.* Wir versprechen internationale Filme in jeder Liste, ohne das vertraute Angebot zu streichen. Zwei von fünf Plätzen sind 40 Prozent, die übrigen drei bleiben für bekannte Titel. Die Quote muss in jeder Liste stimmen. Schon eine einzige Liste ohne kulturell neuen Film bricht das Versprechen an diese Person.
#v(0.7em)
*B01, Attraktivität.* Zwei internationale Filme können aus demselben Land und demselben Subgenre stammen. Dann wirkt die Liste trotz Quote eng. Wenn auf ein Subgenre höchstens zwei Plätze entfallen, braucht es bei fünf Plätzen mindestens drei Subgenres. Dieselbe Grenze je Land ergibt mindestens drei Produktionsländer.
#v(0.7em)
*B02, Erklärbarkeit.* Ein Film aus einem anderen Land wirkt schnell zufällig. Die Begründung zeigt den Bezug zum gewählten Genre oder zu einem Referenzfilm, und zwar bei allen fünf Filmen. 80 Zeichen reichen für diesen Bezug. Bei 250 Zeichen bleibt der Text neben dem Film noch gut lesbar.
#v(0.7em)
*E01, Zeitverhalten.* Die Liste hilft nur, solange die Person noch auswählt. Nach etwa fünf Sekunden wird die Geduld knapp, und sie greift zum gewohnten Katalog. Fünf Sekunden sind deshalb die Grenze, bis zu der die Antwort noch zum Erlebnis gehört.
#v(0.7em)
*E02, Training.* Neue Titel und Rückmeldungen sollen noch in derselben Woche in den Listen landen. Das Training läuft wöchentlich über den Katalog von rund 86.000 Titeln und rund 1.000 Rückmeldungen und ist samt Abruf und Prüfung in fünf Minuten fertig. Ein fehlgeschlagener Lauf kann deshalb noch in derselben Nacht neu starten.
#v(0.7em)
*Z01, Fehlertoleranz.* Referenzfilme sind freiwillig, und Nutzungsdaten fehlen zu Beginn. Der häufigste Fall ist ein Genre ohne Beispielfilm. Auch dann sollen fünf Filme erscheinen, die F01 und B01 einhalten. Sonst verlieren wir genau die neuen Zuschauerinnen und Zuschauer.
#v(0.7em)
*Z02, Datenintegrität.* Kulturell neu erkennen wir am Land. Fehlt es, wird die Quote aus F01 beliebig. Der Import schreibt jeden Eintrag ohne Land, Genre oder Erscheinungsjahr ins Fehlerprotokoll. Die Empfehlungsdaten enthalten diese Felder deshalb vollständig.
#v(0.7em)
*V01, Verfügbarkeit.* Quote und Antwortzeit nützen nichts, wenn die Empfehlung im entscheidenden Moment ausfällt. Die Schnittstelle beantwortet deshalb 99 Prozent der Anfragen. Rund 72 Stunden im Jahr sind knapp ein Prozent der Zeit, länger soll der Dienst nicht ausfallen.
#v(0.7em) 
*W01, Analysierbarkeit.* Wirkt ein Land falsch oder fehlt die Quote, muss das Team genau diese Empfehlung finden. Sonst lässt sich das System nicht verteidigen. Über die Request-ID holen wir in höchstens zehn Sekunden die Eingabe, die Inferenzdauer und die MLflow-Run-ID, und zwar für jede Empfehlung.
]
