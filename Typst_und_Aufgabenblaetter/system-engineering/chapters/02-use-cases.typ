#let hell = rgb("#F1F3F4")

#let use-case(name, kurz, akteure, pre, standard, post, alternativ) = {
  set text(size: 9.5pt)
  set par(justify: false, leading: 0.55em)
  table(
    columns: (3.2cm, 1fr),
    stroke: 0.5pt + luma(190),
    inset: 3.5pt,
    fill: (x, _) => if x == 0 { hell },
    [*Use Case*], [*#name*],
    [Kurzbeschreibung], kurz,
    [Akteure], akteure,
    [Pre-Condition], pre,
    [Standardpfad], standard.join(linebreak()),
    [Post-Condition], post,
    [Alternativer Pfad], alternativ.join(linebreak()),
  )
}

= Use Cases <use-cases>

Vier Use Cases decken den Weg von den Filmdaten bis zum Feedback der Nutzerinnen und Nutzer ab. @uc-diagramm zeigt sie im Überblick als Use-Case-Diagramm.
#v(1em)
#figure(
  image("../figures/uc-diagramm.png", width: 18cm),
  caption: [Use-Case-Diagramm des Empfehlungssystems],
) <uc-diagramm>
#v(01em)
== Use Case 1: Filmdaten importieren

#use-case(
  [Film-Rohdaten importieren und vorverarbeiten],
  [Ein Importjob lädt die Rohdaten, entfernt unvollständige Einträge und trennt vertraute Filme von kulturell neuen.],
  [Pipeline-Scheduler (primär), Datenverarbeitung und Film-Datenquelle (unterstützend)],
  [Der Zugriff auf die Filmdaten ist eingerichtet, Speicher im Data Lake ist vorhanden.],
  (
    [S10: Der Scheduler startet den wöchentlichen Importjob.],
    [S20: Das System lädt Metadaten, Genres, Länder, Sprachen und Bewertungszahlen.],
    [S30: Das System entfernt Filme ohne Genre, Land oder Jahr.],
    [S40: Der Bubble-Breaker-Filter trennt vertraute Filme (USA/UK oder englische Sprache) von kulturell neuen.],
    [S50: Das System berechnet Merkmale und Embeddings.],
    [S60: Der Datensatz wird versioniert im Data Lake gespeichert.],
  ),
  [Referenzfilme und kulturell neue Filme liegen getrennt und versioniert bereit.],
  (
    [A01 (bei S20): Die Datenquelle ist nicht erreichbar.],
    [Das System wiederholt den Abruf bis zu dreimal mit wachsendem Abstand.],
    [Scheitern alle Versuche, bleibt der letzte Datenstand erhalten und der Fehler wird protokolliert.],
  ),
)
#v(0.3em)
#block(breakable: false)[
== Use Case 2: Modell trainieren

#use-case(
  [Modell trainieren und Experiment tracken],
  [Der ML-Engineer trainiert das Modell, prüft Genauigkeit und Diversität und protokolliert den Lauf in MLflow.],
  [ML-Engineer (primär), Trainings-Pipeline und Model-Tracking-System (unterstützend)],
  [Der bereinigte Datensatz aus Use Case 1 liegt geprüft vor.],
  (
    [S10: Der ML-Engineer startet den Trainings- und Evaluierungslauf.],
    [S20: Das System lädt den aktuellen Datensatz und das gespeicherte Feedback.],
    [S30: Das Modell wird mit den Labels aus Use Case 4 trainiert.],
    [S40: Das System misst Precision\@5 und die Vielfaltsregeln.],
    [S50: Hyperparameter, Metriken und Diagramme werden in MLflow protokolliert.],
    [S60: Das Modell wird als Release-Kandidat in der Model Registry gespeichert.],
  ),
  [Das Modell ist mit Parametern, Metriken und Artefakten dokumentiert und registriert.],
  (
    [A01 (bei S40): Die Vielfaltsregeln sind nicht zu 100 Prozent erfüllt.],
    [Das Modell wird nicht freigegeben.],
  ),
)
]
#v(0.3em)
#block(breakable: false)[
== Use Case 3: Empfehlungen erzeugen

#use-case(
  [Fragebogenbasiert Filmempfehlungen erzeugen],
  [Die Person beantwortet einen kurzen Fragebogen und erhält fünf begründete Empfehlungen, davon zwei kulturell neu.],
  [Nutzerin oder Nutzer (primär), Oberfläche, Backend und Inferenzmodell (unterstützend)],
  [Das Modell aus Use Case 2 läuft als Dienst, die Oberfläche ist geladen.],
  (
    [S10: Die Person wählt mindestens ein bevorzugtes Genre.],
    [S20: Sie bewertet 5-8 bekannte Filme als gefallen, nicht gefallen oder ungesehen.],
    [S30: Das Backend übergibt die Präferenzen an das Modell.],
    [S40: Das Modell mischt drei vertraute mit zwei kulturell neuen, thematisch ähnlichen Filmen.],
    [S50: Für jeden Film entsteht eine kurze Begründung aus den Metadaten.],
    [S60: Die Oberfläche zeigt fünf Filme mit Poster, Herkunftsland und Begründung.],
  ),
  [Die Person sieht fünf personalisierte Empfehlungen mit Begründung.],
  (
    [A01 (bei S40): Es gibt keine passenden kulturell neuen Filme.],
    [Das Backend ergänzt kuratierte Geheimtipps („Kuratierter Geheimtipp“).],
    [Das Ereignis wird für das Monitoring protokolliert.],
  ),
)
]
#v(0.3em)
#block(breakable: false)[
== Use Case 4: Feedback erfassen

#use-case(
  [Nutzerfeedback erfassen und Modellgüte loggen],
  [Die Person bewertet die Empfehlungen. Das System speichert das Feedback und eine Kennzahl für das nächste Training.],
  [Nutzerin oder Nutzer (primär), Backend und Monitoring-Datenbank (unterstützend)],
  [Use Case 3 ist abgeschlossen, die Person sieht die Ergebnisseite.],
  (
    [S10: Die Person wählt „Kannte ich noch nicht und klingt spannend“ oder „Schon gesehen“.],
    [S20: Die Oberfläche sendet das Feedback asynchron an das Backend.],
    [S30: Das Backend verknüpft es mit der Request-ID und den Filmdaten.],
    [S40: Ein Treffer gilt als Erfolg, wenn der Film unbekannt und positiv bewertet wurde.],
    [S50: Feedback und Kennzahl gehen in die Monitoring-Datenbank für das nächste Training.],
  ),
  [Das Feedback steht für Drift-Analyse und das Retraining aus Use Case 2 bereit.],
  (
    [A01 (bei S20): Die Verbindung zum Feedback-Dienst schlägt fehl.],
    [Die Oberfläche speichert das Feedback lokal und sendet es später erneut.],
    [Die Person erhält trotzdem die Rückmeldung, dass der Klick angekommen ist.],
  ),
)
]
