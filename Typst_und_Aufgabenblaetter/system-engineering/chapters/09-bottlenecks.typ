#let grau = rgb("#586870")
#let hell = rgb("#F4F6F7")

= Bottlenecks

Wir haben die erste Inference-Pipeline, also das MVP-Notebook mit der Heuristik aus 0,4 Genre-Match, 0,3 Popularität und 0,2 Keyword-Bonus, mit fünf Testpersonen laufen lassen. Die Arthouse-Person wählt Drama und Thriller mit Parasite, Oldboy und City of God. Dazu kommen eine Komödien-Person mit Titanic, Notting Hill und Pretty Woman, eine Sci-Fi-Person mit Matrix, Inception und Interstellar, eine Person mit nur einem Referenzfilm und eine ganz ohne Referenzfilme. Ein Lauf dauert etwa 1,5 Sekunden einschließlich Laden der Daten und liegt damit klar unter den 3 Sekunden aus E01.

#[
  #set text(size: 9pt)
  #set par(justify: false)
  #figure(
    table(
      columns: (0.8cm, 5.6cm, 3.4cm, 2cm, 1.6cm, 1.8cm),
      inset: 3.5pt,
      stroke: 0.5pt + grau,
      fill: (x, y) => if y == 0 { hell } else { white },
      [*\#*], [*Titel*], [*Land*], [*Stimmen*], [*Score*], [*Typ*],
      [1], [Nella valle di Elah], [USA], [68.025], [0,73], [vertraut],
      [2], [A Scanner Darkly - Un oscuro scrutare], [USA], [105.125], [0,71], [vertraut],
      [3], [Jerry Maguire], [USA], [238.398], [0,70], [vertraut],
      [4], [Kiki - Consegne a domicilio], [Japan], [118.006], [0,68], [neu],
      [5], [La regina dei castelli di carta], [Schweden, Dänemark, Deutschland], [66.839], [0,63], [neu],
    ),
    caption: [Ausgabe der ersten Pipeline für die Arthouse-Person],
  )
]

#figure(
  image("../figures/bottleneck-score.png", width: 11.5cm),
  caption: [Woraus sich der Score dieser Liste zusammensetzt],
)

== Bewertung aus Nutzer- und Produktsicht

Die Quote stimmt, jede Liste enthält drei vertraute und zwei kulturell neue Filme aus mindestens vier Ländern. Das Produktziel verfehlen wir aber, denn die Listen wiederholen sich. Jerry Maguire erscheint in drei der vier Listen, Kiki ebenfalls, selbst bei so unterschiedlichen Personen wie dem Arthouse- und dem Sci-Fi-Fan. Das ist genau das Bore-out, das wir verhindern wollen. Die Begründungen erfüllen mit rund 150 bis 200 Zeichen formal B02, sind aber Metadaten wie „Land: USA. Stimmen: 68.025“ und erklären nicht, warum der Film passt.

== Bewertung der Modell-Performance

Precision\@5 und Hit-Rate\@5 können wir ohne Rückmeldungen noch nicht messen, nach unserer Einschätzung passen nur ein bis zwei Filme je Liste. Der Log-Loss ergibt erst mit einem Klassifikator Sinn und die CTR erst im Pilot. Messbar ist die Vielfalt. F01 gilt in allen Listen, B01 aber nicht. Es gibt zwar mindestens vier Länder, doch ein Genre steckt in allen fünf Filmen, bei der Arthouse-Liste Drama. Die Grenze von zwei Filmen je Subgenre verletzen alle vier Listen. Die Metriken selbst bleiben, nur das Subgenre müssen wir definieren, denn IMDb kennt nur Genres.

== Bottlenecks und Handlungen

#[
  #set text(size: 8.5pt)
  #set par(justify: false)
  #table(
    columns: (0.6cm, 7.2cm, 1.6cm, 6.2cm),
    inset: 3.5pt,
    stroke: 0.5pt + grau,
    fill: (x, y) => if y == 0 { hell } else { white },
    [*\#*], [*Befund*], [*Seite*], [*Handlung*],
    [1], [Die Popularität ist gesättigt. 3.844 Kandidaten und alle Top-50 haben den Wert 1, Jerry Maguire mit 238.398 Stimmen liegt vorn. Das ist das Gegenteil von Nische.], [Modell], [Stimmenzahl nur als Nischen-Faktor nutzen und Filme auf 50 bis 40.000 Stimmen begrenzen (82.008 Filme bleiben).],
    [2], [Der Keyword-Bonus ist fehlerhaft. 283 Kandidaten und 8 der Top-50 profitieren. Warner Independent Pictures ist ein Warner-Label, vier von fünf Filmen der Arthouse-Liste bekommen den Bonus.], [Modell], [Keyword streichen und große Studios ausschließen.],
    [3], [Die Ähnlichkeit kennt nur Genres. Drama steckt in 55 % aller Filme, deshalb führt Drama von Oldboy zu Kiki und Jerry Maguire.], [Modell], [Genres mit IDF gewichten prüfen, danach Embeddings der Beschreibung (Kapitel 6, 11 und 12).],
    [4], [Referenzfilme wirken kaum. Die Bewertungen 1/1/1 und 10/10/10 liefern dieselbe Liste, „nicht gefallen“ stößt nicht ab.], [Modell], [Gefallen zieht an, nicht gefallen stößt ab, ungesehen zählt nicht.],
    [5], [Die Gewichte summieren sich auf 0,9 und sind nicht begründet. Der höchste Score liegt bei 0,73.], [Modell], [Gewichte auf Summe 1 setzen und im Teamtest prüfen.],
    [6], [Ohne Referenzfilme bricht die Pipeline ab, Z01 ist nicht erfüllt.], [Modell], [0 bis 8 Referenzfilme zulassen, Fallback über Genre und Bewertung.],
    [7], [Das Notebook nutzt Titel aus IMDb movies und zeigt italienische Titel. „The Matrix“ wird nicht gefunden.], [Daten], [Auf die zusammengeführte filme.csv mit englischen Titeln umstellen.],
    [8], [Im Pool liegen 6.333 Filme vor 1950, darunter 157 vor 1920.], [Daten], [Mindest-Erscheinungsjahr prüfen.],
    [9], [Die Begründung nennt nur Metadaten.], [Produkt], [Gemeinsames Thema und Referenzfilm nennen, Stimmenzahl weglassen.],
  )
]

== Entscheidung für die nächste Iteration

Wir arbeiten als Nächstes auf der Modellseite. Die Ausgabeform mit fünf Filmen und Begründung ist brauchbar, aber falsche Filme werden durch bessere Darstellung nicht besser. Zuerst beheben wir die Punkte 1 bis 8, sie sind schnell erledigt und gehen direkt auf B01 und Z01 ein. Parallel überarbeiten wir die Begründung. Danach lassen wir dieselben fünf Testpersonen erneut laufen und prüfen, dass kein Film in mehr als zwei Listen auftaucht und die Subgenre-Regel hält. Erst dann prüfen wir, ob Embeddings die thematische Ähnlichkeit verbessern (Kapitel 12).
