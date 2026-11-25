#let rot = rgb("#E00018")
#let grau = rgb("#586870")
#let hell = rgb("#F4F6F7")
#let prio-fill = rgb("#FDECEE")

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

= Pipelines

Wir brauchen zwei Pipelines. Die Inference-Pipeline erzeugt im Betrieb die Liste aus fünf Filmen. Die Trainings-Pipeline bereitet das Modell vor, das später die Heuristik ersetzt. Wir starten mit der Inference-Pipeline und einer einfachen Heuristik, weil sie ohne Labels funktioniert und uns schnell zeigt, wo das System scheitert. Die Trainings-Pipeline folgt danach.

== Inference-Pipeline

#figure(
  pipeline((
    [*1 Eingabe*\ Genres, Referenzfilme],
    [*2 Säubern*\ Titel zu IMDb-ID, Genres prüfen],
    [*3 Vorfilter*\ Pflichtfelder, ≥ 50 Stimmen, vertraut / neu],
    ([*4 Score*\ Ähnlichkeit, Qualität, Nischen-Faktor], true),
    [*5 Re-Ranking*\ 3 + 2, Länder, Subgenres],
    [*6 Ausgabe*\ Begründung, Log, 5 Filme],
  )),
  caption: [Inference-Pipeline des MVP],
) <inference-pipeline>

+ *Eingabe.* Das Frontend schickt den Fragebogen als JSON an die Empfehlungs-API. Pflicht ist ein Genre, dazu kommen fünf bis acht Referenzfilme mit gefallen, nicht gefallen oder ungesehen. Jede Anfrage bekommt eine Request-ID, die wir bis ins Log mitführen (W01).
+ *Säubern.* Die Titel ordnen wir über die Suche einer IMDb-ID zu und prüfen die Genres gegen den Katalog. Fehlen die Referenzfilme, greift die Fallback-Logik aus Z01 und die Liste entsteht allein aus den Genres. Wir speichern kein dauerhaftes Nutzerprofil, das hält die DSGVO ein.
+ *Vorfilter.* Datenbasis ist der Katalog aus dem wöchentlichen Import, derzeit 85.855 Filme aus IMDb movies und dem Kaggle Movies Dataset, verbunden über die IMDb-ID. Wir behalten Filme mit Land, Genre und Jahr (Z02), schließen die Referenzfilme aus und verlangen mindestens 50 Stimmen. Land und Sprache markieren jeden Film als vertraut oder kulturell neu. Originalsprache und Schlagwörter sind keine Pflicht, weil sie nur bei 40 beziehungsweise 29 Prozent der Filme vorliegen.
+ *Score.* Hier arbeitet die Heuristik aus Kapitel 6 mit 0,5 mal Ähnlichkeit, 0,3 mal Qualität und 0,2 mal Nischen-Faktor. Die Features sind Genre-Ähnlichkeit nach Jaccard, bayessche Bewertung und die Stimmenzahl als Maß für Bekanntheit. Später kommen Embeddings der Beschreibung und ein Klassifikator hinzu.
+ *Re-Ranking.* Wir sortieren vertraute und kulturell neue Filme getrennt und nehmen die drei besten vertrauten und die zwei besten neuen. Danach prüfen wir mindestens drei Länder und höchstens zwei Filme je Subgenre (F01, B01) und tauschen bei einem Verstoß den Film mit dem schwächsten Score. Die Einhaltung messen wir als Modellmetrik.
+ *Ausgabe.* Die Begründung entsteht aus einer Vorlage mit Genre und ähnlichstem Referenzfilm und hat 80 bis 250 Zeichen (B02). Request-ID, Eingabe, Laufzeit und Modellversion gehen ins Log, damit wir jede Empfehlung in zehn Sekunden nachvollziehen (W01). Die Antwort soll nach höchstens drei Sekunden da sein (E01).

== Trainings-Pipeline

#figure(
  stack(
    spacing: 0.4cm,
    pipeline((
      [*1 Laden*\ Katalog, Feedback aus UC4],
      [*2 Säubern*\ Pflichtfelder, Dubletten, Fehlerlog],
      [*3 Pre-Processing*\ Features und Embeddings],
      [*4 Daten teilen*\ Training und Validierung],
    ), breite: 3.2cm),
    pipeline((
      ([*5 Training*\ Klassifikator, MLflow], true),
      [*6 Evaluation*\ Precision\@5, Hit-Rate\@5, Log-Loss],
      [*7 Speichern*\ Registry mit Run-ID],
    ), breite: 3.2cm),
  ),
  caption: [Trainings-Pipeline, wöchentlich vom Scheduler gestartet],
) <trainings-pipeline>

+ *Laden.* Wir laden den Katalog aus dem Import und das Feedback aus Use Case 4. Jeder Eintrag enthält Request-ID, Film und die Antwort „Kannte ich noch nicht und klingt spannend“ oder „Schon gesehen“. Der Scheduler startet den Lauf einmal pro Woche (E02).
+ *Säubern.* Wir prüfen die Pflichtfelder, entfernen Dubletten über die IMDb-ID und schreiben Fehler in ein Protokoll (Z02). Fehlt die Beschreibung, wie bei 2,3 Prozent der Filme, bleibt der Film im Katalog und das Textmerkmal bleibt leer. Feedback zu Filmen, die es nicht mehr gibt, verwerfen wir.
+ *Pre-Processing.* Wir bauen die Features nach Kapitel 12, bayessche Bewertung und Stimmenzahl (logarithmisch) standardisiert, Genre als Multi-Hot, die Markierung vertraut oder neu und die Ähnlichkeit zum Profil aus den Referenzfilmen. Die Parameter der Skalierung bestimmen wir nur im Training und speichern sie für die Inference. Embeddings der Beschreibung entstehen einmal pro Import, gehen aber erst ins Modell ein, wenn sie sich lohnen.
+ *Daten teilen.* Wir trennen nach Request-ID, nicht nach einzelnen Zeilen. So landen Filme derselben Person nicht zugleich im Training und in der Validierung, und das Ergebnis wirkt nicht besser, als es ist.
+ *Training.* Wir starten mit Logistic Regression und vergleichen mit einem Random Forest. Beide sind schnell und brauchen wenig Daten. Parameter und Datenstand loggen wir in MLflow. Weil wir erst nach einigen Wochen genug echte Labels haben (Kapitel 5), läuft die Heuristik bis dahin allein.
+ *Evaluation.* Auf der Validierung messen wir Precision\@5, Hit-Rate\@5 und Log-Loss und vergleichen mit der Heuristik. Das Modell geht nur weiter, wenn es die Zielwerte aus Kapitel 7 erreicht und besser als die Heuristik ist.
+ *Speichern.* Das Modell landet mit seiner MLflow-Run-ID als Release-Kandidat in der Registry. Die Inference-Pipeline lädt es beim Start und hält es im Zwischenspeicher.

Aus den Pipelines ergibt sich der Arbeitsplan. Erst steht die Inference mit der Heuristik, dann folgt das Training, sobald Feedback vorliegt.
