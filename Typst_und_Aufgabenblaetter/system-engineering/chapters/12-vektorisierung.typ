#let grau = rgb("#586870")
#let hell = rgb("#F4F6F7")

= Vektorisierung

Wir vektorisieren den Katalog mit 85.855 Filmen, jede Zeile ist ein Film. Die Person bilden wir später als Mittelwert ihrer fünf Referenzfilme. Alle Parameter bestimmen wir nur auf 80 Prozent der Filme (68.684 Training) und wenden sie auf die übrigen 20 Prozent (17.171 Validierung) und später auf jeden Aufruf an. Geplant sind Logistic Regression, Random Forest und für den Kaltstart ein Ähnlichkeitsvergleich.

== Statistische Vorprüfung

#figure(
  image("../figures/vektorisierung.png", width: 10cm),
  caption: [Verteilung der kontinuierlichen Merkmale im Katalog],
)

*Stimmenzahl.* Sie ist extrem schief (Schiefe 14,6, Median 484, Maximum 2,3 Millionen). Ohne Umformung würde eine Normierung 99 Prozent der Filme auf Werte unter 0,1 drücken, und bei einer Standardisierung würden wenige Ausreißer (1,3 Prozent mit |z| > 3) die Skala bestimmen. Wir nehmen deshalb den Logarithmus zur Basis 10, danach liegt die Schiefe bei 1,3.

*Bayessche Bewertung.* Sie ist fast symmetrisch (Schiefe 0,19), die rohe IMDb-Bewertung hingegen links schief (−0,76), weil sie bei wenigen Stimmen stark schwankt. Das Erscheinungsjahr ist links schief (−1,06). Wir führen es mit, nutzen es laut Kapitel 11 aber zunächst nicht. Sie hängt im Katalog nur mäßig mit der Stimmenzahl zusammen (Spearman 0,34), bei den bekannteren MovieLens-Filmen enger (0,66). Beide können im selben Modell stehen.

*Kategorische Merkmale.* Genre hat nur 25 Werte mit im Mittel 2,05 pro Film, Land (194 Werte) und Sprache (267) haben einen langen Schwanz. Bei Regie (34.707 Personen) und Darstellern (417.320) haben 87 Prozent weniger als fünf Filme, keine Person hat 500. One-hot wäre dort fast leer, wir vergleichen stattdessen Namensmengen per Jaccard.

== Vorgehen je Merkmal

#[
  #set text(size: 8.5pt)
  #set par(justify: false)
  #table(
    columns: (3.2cm, 6.4cm, 1.7cm, 2.5cm),
    inset: 3.5pt,
    stroke: 0.5pt + grau,
    fill: (x, y) => if y == 0 { hell } else { white },
    [*Merkmal*], [*Verfahren und Begründung*], [*Spalten*], [*Dichte*],
    [Bewertung, Stimmen (log), Jahr], [Standardisierung für Logistic Regression, Min-Max-Normierung für Abstände, fehlendes Jahr durch Median], [3], [dicht],
    [Genre], [Multi-Hot, ein Film kann mehrere Genres haben], [25], [8,2 %],
    [Land, Sprache], [One-Hot nur für Werte ab 400 Filmen im Training, das entspricht den 500 aus der Fallstudie], [31 + 28], [3,7 % und 4,2 %],
    [Kulturell neu], [Flag nach der Regel aus Kapitel 5], [1], [43,6 %],
    [Beschreibung (TF-IDF)], [Wortvektor, Vokabular nur aus dem Training, Stoppwörter entfernt], [20.474], [0,09 %],
    [Beschreibung (Embedding)], [Satzvektor mit MiniLM, normiert, fehlender Text ergibt Nullvektor], [384], [dicht],
  )
]

Die tabellarischen Merkmale ergeben 88 Spalten bei 8,9 Prozent Dichte, mit Embedding 472. Filme mit nur seltenen Ländern oder Sprachen (je rund 5 Prozent) bekommen eine Nullzeile, das Flag „kulturell neu“ trägt die Information weiter.

== Text

Die Beschreibungen sind englisch und kurz (Median 33 Wörter, 15 nach Entfernung der Stoppwörter). TF-IDF hat dadurch 20.474 Spalten bei nur 0,09 Prozent Dichte, zwei Filme teilen kaum gemeinsame Wörter. Wir haben deshalb auch ein vortrainiertes Satzmodell (all-MiniLM-L6-v2) geprüft, das Bedeutung statt Wortgleichheit vergleicht. Es braucht keine Anpassung an unsere Daten, also auch keinen Leckage-Effekt.

Verglichen haben wir im Test aus Kapitel 11.

#[
  #set text(size: 8.5pt)
  #set par(justify: false)
  #figure(
    table(
      columns: (6cm, 3cm, 3cm),
      inset: 3.5pt,
      stroke: 0.5pt + grau,
      fill: (x, y) => if y == 0 { hell } else { white },
      [*Ähnlichkeit zu den Referenzfilmen*], [*AUC pro Person*], [*Precision\@5*],
      [Zufall], [0,500], [53,0 %],
      [TF-IDF], [0,525], [58,1 %],
      [Embedding (384 Dimensionen)], [0,534], [57,7 %],
      [Genre (Jaccard)], [0,557], [59,9 %],
    ),
    caption: [Text-Vektorisierungen im Vergleich, über alle 652 Personen],
  )
]

Das Embedding ist das beste Textverfahren, der Abstand zu TF-IDF ist aber klein, und im gemeinsamen Modell mit Bewertung, Stimmen, Genre und neu bleibt die AUC bei 0,691. Die Ähnlichkeit hängt nur schwach mit dem Genre zusammen (Spearman 0,18), enthält also eigene Information. Die nächsten Nachbarn wirken teils zufällig, bei „Parasite“ liegen „Red Dragon“ und „Dr. No“ vorn.

*Entscheidung.* Der MVP nutzt Genre als Ähnlichkeit und keinen Text. TF-IDF streichen wir. Das Embedding berechnen wir als Zusatz für den Kaltstart und eine spätere Version, sobald Rückmeldungen aus Use Case 4 vorliegen.

== Parameter und Anwendung

Wir speichern alle Parameter im Ordner `artefakte/vektorisierung` und lesen sie in der Inference-Pipeline wieder ein. Das sind die beiden Skalierer, das TF-IDF-Vokabular und `vokabular.json` mit den Listen für Genre, Land und Sprache, den Werten C und m der Bayesschen Bewertung, dem Jahres-Median und dem Modellnamen des Embeddings.

Auf der Validierung liegen die standardisierten Werte bei Mittel −0,02 bis −0,01 und Standardabweichung 0,98 bis 1,01, die Parameter übertragen sich also gut. Min-Max-Werte begrenzen wir beim Aufruf auf 0 bis 1.

== Welche Modelle passen

#[
  #set text(size: 8.5pt)
  #set par(justify: false)
  #table(
    columns: (3.6cm, 8.4cm, 3.6cm),
    inset: 3.5pt,
    stroke: 0.5pt + grau,
    fill: (x, y) => if y == 0 { hell } else { white },
    [*Modell*], [*Befund*], [*Entscheidung*],
    [Logistic Regression], [Verteilungsempfindlich, nach Log und Standardisierung passend], [Hauptmodell],
    [Random Forest], [Braucht keine Skalierung, verträgt 0/1-Spalten und Zahlen gemischt], [Vergleichsmodell],
    [k-NN, Kosinus], [Braucht gleiche Skala, Embeddings sind schon normiert], [Nur Ähnlichkeit, Kaltstart],
    [Naive Bayes, neuronale Netze], [Nicht gaußsch (Schiefe 1,3 und −1,1), kaum Labels], [Erst mit Daten aus Use Case 4],
  )
]
