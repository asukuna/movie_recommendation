#let rot = rgb("#E00018")
#let grau = rgb("#586870")
#let hell = rgb("#F4F6F7")
#let prio-fill = rgb("#FDECEE")

// Ein Kasten der Pipeline
#let schritt(body, breite: 2.3cm, hervor: false) = box(
  width: breite,
  height: 1.5cm,
  inset: 3pt,
  radius: 3pt,
  fill: if hervor { prio-fill } else { hell },
  stroke: 0.8pt + if hervor { rot } else { grau },
  align(center + horizon, text(size: 8pt, par(justify: false, leading: 0.25em, body))),
)

#let pfeil = box(width: 0.4cm, align(center + horizon, text(fill: grau, size: 13pt)[→]))

// Eine Pipeline aus mehreren Kästen, hervorgehoben sind Kästen mit (text, true)
#let pipeline(schritte, breite: 2.3cm) = {
  let teile = ()
  for (i, s) in schritte.enumerate() {
    if i > 0 { teile.push(pfeil) }
    if type(s) == array {
      teile.push(schritt(s.at(0), breite: breite, hervor: s.at(1)))
    } else {
      teile.push(schritt(s, breite: breite))
    }
  }
  align(center, stack(dir: ltr, ..teile))
}

= Lösungsansätze für den ML-Teil

Für den Machine-Learning-Teil haben wir drei Lösungsansätze entworfen, die beiden Extreme „simpel“ und „komplex“ sowie einen Mittelweg. So sehen wir, wie viel Aufwand sich für unser Produktziel wirklich lohnt.

== Simple Lösung: Heuristik

Hier arbeiten feste Regeln statt eines Modells. Wir haben uns gefragt, wie wir die Liste von Hand zusammenstellen würden („Being the algorithm“), und die Regeln danach an der Fachliteratur geschärft.

*Ähnlichkeit.* Genres vergleichen wir als Mengen (Jaccard). Eine IDF-Gewichtung seltener Genres ist üblich (Lops et al. 2011), war im Test aus Kapitel 11 aber nicht besser. Die Referenzfilme gehen mit ihrer eigenen Bewertung ein.

*Qualität.* Statt der Rohbewertung nehmen wir den bayesschen Mittelwert wie die IMDb Top 250, $"WR" = v/(v+m) dot R + m/(v+m) dot C$ mit Stimmen $v$, Bewertung $R$, Mindeststimmen $m$ und Durchschnitt $C$ aller Filme. Ein Film mit 99 Stimmen und einer 9,5 wird so nicht überschätzt.

*Nischen-Faktor.* Bekannte Hits kennt die Person meist schon. Neuheit zählt in der Literatur als eigenes Ziel neben der Treffsicherheit (Kaminskas und Bridge 2016). Wir verlangen mindestens 50 Stimmen und belohnen weniger Stimmen bis zur Mainstream-Grenze von 40.000.

*Vielfalt.* Beim Re-Ranking setzen wir die Quote von drei vertrauten und zwei kulturell neuen Filmen durch. Dazu kommen mindestens drei Länder und höchstens zwei Filme pro Subgenre, wie es auch Maximal-Marginal-Relevance vorsieht (Carbonell und Goldstein 1998).

Der Score ist 0,5 × Ähnlichkeit + 0,3 × Qualität + 0,2 × Nischen-Faktor. Die Gewichte sind Startwerte und nicht gelernt.

#figure(
  pipeline((
    [Fragebogen\ Genres, Referenzfilme],
    [Vorfilter\ Pflichtfelder, ≥ 50 Stimmen],
    [Score\ Ähnlichkeit, Qualität, Nischen-Faktor],
    [Re-Ranking\ 3 vertraut + 2 neu, Länder],
    [5 Filme\ Begründung aus Vorlage],
  ), breite: 2.9cm),
  caption: [Pipeline der Heuristik],
)

Der Ansatz braucht kein ML, ist schnell gebaut und dient als Baseline für den Vergleich. Seine Merkmale sind außerdem Features für das spätere Modell. Schwach ist er beim Thema, denn zwei Dramen können inhaltlich weit auseinanderliegen.
#v(0.5em)
== Komplexe Lösung: End-to-End

Ein einziges großes Modell, etwa ein Sprachmodell oder ein Deep-Learning-Recommender, bekommt Fragebogen und Filmtexte und liefert direkt die fertige Liste samt Begründung.
Das bringt vier Hürden mit sich. 

*Daten:* Wir bräuchten Millionen Nutzer-Film-Interaktionen und haben keine einzige (Kaltstart).

 *Modell:* Training und Feinabstimmung sind aufwändig, und die Quote von zwei kulturell neuen Filmen wäre nicht garantiert. *Latenz:* Das Erzeugen dauert und braucht viele Ressourcen, die fünf Sekunden aus E01 wären bei vielen Anfragen kaum zu halten. *Implementierung:* Der Aufwand ist hoch, und die Begründungen wären schwer zu prüfen.
#v(0.5em)
#figure(
  pipeline((
    [Fragebogen\ Genres, Referenzfilme],
    ([Ein großes Modell\ z. B. LLM oder Deep Recommender], true),
    [5 Filme\ Begründung generiert],
  ), breite: 4.6cm),
  caption: [Pipeline der End-to-End-Lösung],
)
#v(0.5em)
== Mittelweg: Embeddings und einfacher Klassifikator

Wir übernehmen die Idee aus der Heuristik und ersetzen nur die Teile, die Regeln nicht können. Ein vortrainiertes Modell macht aus den Beschreibungen Vektoren, und das Nutzerprofil ist der mit den Bewertungen gewichtete Mittelwert der Referenzfilme. Ihr Gewinn war in Kapitel 12 klein. Aus den ähnlichsten Kandidaten bewertet ein einfacher Klassifikator, etwa Logistic Regression oder ein Random Forest, jeden Film als passend oder unpassend. Seine Eingaben sind Ähnlichkeit, Qualität, Nischen-Faktor und die Markierung vertraut oder neu. Trainiert wird er mit den Labels aus Use Case 4.
#v(0.5em)
#figure(
  stack(
    spacing: 0.4cm,
    pipeline((
      [Fragebogen\ Genres, Referenzfilme],
      [Nutzerprofil\ Mittelwert der Vektoren],
      [Kandidaten\ Top 200 nach Ähnlichkeit],
      ([Klassifikator\ passt / passt nicht], true),
      [Re-Ranking\ 3 vertraut + 2 neu],
      [5 Filme\ Begründung aus Vorlage],
    ), breite: 2.3cm),
    pipeline((
      [Feedback UC4\ Knöpfe als Labels],
      [Training\ wöchentlich],
      [Modell\ im Registry],
    ), breite: 2.3cm),
  ),
  caption: [Pipeline des Mittelwegs, oben die Empfehlung, unten das Training],
)
#v(0.5em)
Die Hürden sind deutlich kleiner. Wir brauchen nur bewertete Filme statt Millionen Paare, die Klassifikatoren sind schnell und mit wenig Ressourcen trainierbar, und die Implementierung ist gut dokumentiert. Die Vektoren für den Katalog entstehen einmal pro Woche im Import. Auch die Begründung bleibt prüfbar, weil sie auf dem ähnlichsten Referenzfilm beruht.
== Entscheidung
#v(0.5em)
#[
  #set text(size: 9.5pt)
  #set par(justify: false)
  #table(
    columns: (3.2cm, 1fr, 1fr, 1fr),
    inset: 4pt,
    stroke: 0.5pt + grau,
    fill: (x, y) => if y == 0 { hell } else { white },
    [*Kriterium*], [*Heuristik*], [*Mittelweg*], [*End-to-End*],
    [Labels], [keine], [Feedback aus UC4], [Millionen Interaktionen],
    [Thematische Ähnlichkeit], [schwach], [gut], [gut],
    [Latenz (E01)], [sehr schnell], [schnell], [langsam],
    [Begründbarkeit (B02)], [sehr gut], [gut], [schwach],
    [Aufwand], [gering], [mittel], [hoch],
  )
]

Wir starten mit der Heuristik, denn sie braucht keine Labels und liefert die Baseline. Sobald genug Feedback vorliegt, wechseln wir zum Mittelweg. Die komplexe Lösung bleibt eine Option für später, falls das Produkt stark wächst.
