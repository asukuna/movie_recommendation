#let grau = rgb("#586870")
#let hell = rgb("#F4F6F7")

#let fragen(zeilen) = [
  #set text(size: 9.5pt)
  #set par(justify: false)
  #table(
    columns: (4.4cm, 1fr),
    inset: 4pt,
    stroke: 0.5pt + grau,
    fill: (x, y) => if x == 0 { hell } else { white },
    ..zeilen.flatten(),
  )
]

= Datenbeschaffung

In unserem Projekt gehören die Daten zum Produkt. Wir haben sie deshalb Schritt für Schritt aufgebaut und nach jedem Schritt geprüft, ob sie unser Produktziel tragen.

== Vorgehen

*Beschaffung.* Wir sind klein gestartet und haben zuerst den IMDb-Katalog „IMDb movies“ genommen, mit 85.855 Filmen. Er enthält Genre, Land, Sprache, Bewertung, Stimmen, Studio und Beschreibung. Als zweite Quelle kam das Kaggle-Dataset „The Movies Dataset“ (TMDB) mit 45.466 Filmen dazu, weil nur dort Originalsprache und Schlagwörter stehen. Beide Kataloge haben wir über die IMDb-ID verbunden. Die MovieLens-Stichprobe mit 100.004 Bewertungen von nur 671 Personen haben wir nicht in den Katalog übernommen, nutzen sie aber in Kapitel 11 als Testdaten.

*Grobanalyse.* Wir haben den zusammengeführten Katalog anhand der zwölf Fragen unten untersucht. Auffällig waren drei Dinge. Originalsprache und Schlagwörter gibt es nur für 40 beziehungsweise 29 Prozent der Filme. Die Stimmen sind sehr ungleich verteilt, denn zwei Drittel der Filme haben weniger als 1.000. Außerdem sinkt der Anteil kulturell neuer Filme mit wachsender Bekanntheit stark.

*Ziel verfolgen.* Wir brauchen einen Katalog, aus dem sich drei vertraute und zwei kulturell neue Filme zusammenstellen lassen, mit genug Merkmalen für Heuristik und Embeddings. Dazu prüfen wir, ob es genügend kulturell neue Filme mit belastbaren Bewertungen gibt und ob die Pflichtfelder aus Z02 gefüllt sind.

*Entscheidung treffen.* Wir behalten alle IMDb-Filme und hängen TMDB nur an (Left Join). Ein Inner Join hätte rund 51.000 Filme verloren, vor allem die weniger bekannten, und die brauchen wir für die Vielfalt. Die Tabelle bleibt mit 16 Spalten schlank. Fehlende Originalsprachen und Schlagwörter verbessern wir nicht aufwändig. Wir halten sie als Grenze fest und arbeiten weiter. Der erste Testlauf (Kapitel 9) hat gezeigt, dass das MVP-Notebook noch die alten IMDb-Titel nutzt. Wir stellen es auf die zusammengeführte Datei um.

== Fragen zum Datensatz

=== Qualität

#fragen((
  ([Wie viele Werte fehlen bei den wichtigen Merkmalen?], [Genre, Bewertung und Stimmen fehlen nie, das Land bei 0,1 Prozent, die Sprache bei 1,0 Prozent, die Beschreibung bei 2,3 Prozent und das Studio bei 4,9 Prozent. Bei einem Film fehlt das Jahr. Originalsprache (60,3 Prozent) und Schlagwörter (71,4 Prozent) fehlen oft, weil sie nur aus TMDB kommen. Die Pflichtfelder Land, Genre und Jahr sind damit praktisch vollständig.]),
  ([Gibt es falsche oder unplausible Werte?], [Die Wertebereiche sind plausibel, Bewertungen von 1,0 bis 9,9, Stimmen ab 99, Jahre von 1894 bis 2020. Alle IMDb-IDs sind gültig. Auffällig sind 133 Sprachangaben wie „None“ oder „Unknown“ und 168 Paare mit gleichem Titel und Jahr. Bei 6,9 Prozent der Filme mit Originalsprache Englisch fehlt Englisch in der Sprachliste. Die Quellen widersprechen sich also manchmal.]),
  ([Sind die Labels nachvollziehbar und schlüssig?], [Als Label dient die IMDb-Bewertung. Sie ist ein Durchschnitt vieler Menschen und deshalb plausibel, aber nicht persönlich. Bei wenigen Stimmen ist sie unsicher, und zwei Drittel der Filme haben unter 1.000. Wir glätten sie deshalb bayessch. Die Markierung „kulturell neu“ aus Sprache und Land stimmt zu 90,6 Prozent mit der Markierung über die Originalsprache überein, Abweichungen sind meist Koproduktionen. Falsche Labels wären gefährlicher als fehlende, darum bleiben wir bei klaren Regeln.]),
  ([Welcher Zeitraum wird abgedeckt?], [Die Filme stammen aus den Jahren 1894 bis 2020, der Median liegt bei 2003. 55 Prozent sind ab 2000 erschienen, 8 Prozent ab 2018, nur 789 Filme sind von 2020. Aktuelle Titel fehlen also, deshalb brauchen wir den wöchentlichen Import (Use Case 1).]),
))

=== Format

#fragen((
  ([Liegen die Spalten im richtigen Datentyp vor?], [Jahr, Bewertung und Stimmen sind Zahlen. In der Rohdatei war das Jahr Text, weil ein Eintrag „TV Movie 2019“ lautete, er wurde bei der Umwandlung leer. Genre, Land und Sprache sind Text mit kommagetrennten Listen.]),
  ([Welches Preprocessing ist noch nötig, und läuft es im Produkt?], [Wir zerlegen die Listen in Mengen, markieren Filme als vertraut oder neu, berechnen die bayessche Bewertung und erzeugen Embeddings aus der Beschreibung (Kapitel 12). Fehlende Beschreibungen ergeben einen Nullvektor. Alles läuft automatisch im wöchentlichen Import.]),
  ([Fehlen wichtige Merkmale?], [Ja. Schlagwörter und Originalsprache gibt es nur für 29 beziehungsweise 40 Prozent der Filme. Subgenres fehlen ganz, es gibt nur 25 Genres mit höchstens 3 je Film. Die Festivalpräsenz aus unserer Ideensammlung fehlt ebenfalls. Die Laufzeit ist in den IMDb-Rohdaten vollständig, steht aber nicht in unserer Tabelle und lässt sich nachladen.]),
  ([Gibt es eindeutige IDs?], [Ja, die IMDb-ID ist bei allen Filmen vorhanden und eindeutig. Die TMDB-ID gibt es nur bei 40 Prozent. Titel sind nicht eindeutig, deshalb verbinden wir alles über die IMDb-ID und nehmen bei der Referenzfilm-Suche den Film mit den meisten Stimmen.]),
))

=== Menge und Verteilung

#fragen((
  ([Wie viele Datenpunkte gibt es?], [Der Katalog umfasst 85.855 Filme mit 16 Spalten. Nutzer-Labels gibt es noch keine, wir erwarten rund 1.000 Rückmeldungen pro Woche. Das Szenario E02 rechnet mit dem ganzen Katalog, die Trainingsdauer prüfen wir also mit allen Filmen.]),
  ([Wie verteilen sich die Genres?], [Es gibt 25 Genres. Drama steckt in 54,9 Prozent der Filme, Comedy in 34,2, Romance in 16,5, Action in 15,1 und Thriller in 13,3 Prozent. Sci-Fi kommt nur in 4,2 Prozent vor. Drama trennt Filme kaum. Eine IDF-Gewichtung seltener Genres haben wir getestet, sie half nicht (Kapitel 11).]),
  ([Wie sieht die Länderverteilung aus?], [Es gibt 195 Länder. Die USA sind an 40,0 Prozent der Filme beteiligt, Frankreich an 9,7, das UK an 8,7, Indien an 7,4 und Italien an 5,9 Prozent. Kulturell neu sind 37.430 Filme aus 163 Ländern (43,6 Prozent). Für mindestens drei Länder pro Liste (B01) reicht das deutlich.]),
  ([Sind Klassen unterrepräsentiert?], [Vertraut und neu sind im Gesamtkatalog mit 56 zu 44 Prozent ausgewogen. Bei bekannteren Filmen kippt es. Bei mindestens 1.000 Stimmen sind nur noch 30 Prozent neu, bei 5.000 sind es 16 und bei 40.000 nur 5 Prozent. Es gibt dennoch 8.793 neue Filme mit mindestens 1.000 Stimmen. Der Pool für die Quote ist also groß genug, gut bewertbare neue Filme sind aber rar.]),
))
