= Datenqualität

== Welche Datenqualität liegt vor

Unser Filmkatalog kommt aus zwei öffentlichen Quellen, dem IMDb-Datensatz und dem Kaggle-Datensatz „The Movies Dataset“. Wir haben beide über die IMDb-ID zusammengeführt und kommen auf 85.855 Filme. Genre und Erscheinungsjahr fehlen nie, das Produktionsland bei 0,1 Prozent und die Beschreibung bei 2,3 Prozent.

Nach den vier Stufen aus der Vorlesung haben wir für unsere Aufgabe *schwach gelabelte Daten*. Die IMDb-Bewertung und die Stimmenzahl zeigen, wie beliebt ein Film insgesamt ist, aber nicht, was eine einzelne Person mag. Echte Labels, also „Kannte ich noch nicht und klingt spannend“, gibt es noch nicht. Sie entstehen erst durch das Feedback aus Use Case 4. Für die Markierung „kulturell neu“ brauchen wir kein Label, denn sie folgt aus Land und Sprache. Danach gelten 43,6 Prozent der Filme als kulturell neu, das sind rund 37.000 Titel.

== Reicht das aus

Für das MVP ja, für ein trainiertes Modell noch nicht. Es gibt vier Probleme.

*Es fehlen echte Labels.* Supervised Learning braucht Beispiele mit Antwort. Das MVP startet deshalb mit festen Regeln und einem einfachen Score. Bei rund 1.000 Rückmeldungen pro Woche (E02) dauert es einige Wochen bis zum Training.

*Die Stimmenzahl bevorzugt Hollywood.* Unter allen Filmen sind 44 Prozent kulturell neu, bei mindestens 1.000 Stimmen noch 30 Prozent und bei mindestens 5.000 nur noch 16 Prozent. Würden wir nach Beliebtheit filtern, fielen genau die Filme heraus, die wir zeigen wollen.

*Texte sind lückenhaft.* Schlagwörter gibt es nur bei 29 Prozent der Filme und die Originalsprache nur bei 40 Prozent, weil beides aus dem Kaggle-Datensatz stammt und der nur etwa 40 Prozent der Filme trifft. Das schwächt die Begründungen aus B02.

*Der Datenstand ist alt.* Er reicht bis 2020. Für den wöchentlichen Import brauchen wir eine laufend gepflegte Quelle.

== Aufwand und Wirtschaftlichkeit

*Feedback sammeln* kostet kaum Geld, weil die Knöpfe ohnehin zu Use Case 4 gehören. Das ist der wichtigste Hebel, denn nur so entstehen echte Labels.

*Lücken füllen* geht über eine Filmdatenbank wie TMDB, die Beschreibungen und Schlagwörter nachliefert. Wir schätzen wenige Personentage, die Lizenz müssen wir noch klären. Das lohnt sich, weil kulturell neue Filme am wenigsten Texte haben.

*Von Hand labeln* wäre bei 85.855 Titeln viel zu teuer und nur für eine kleine Geheimtipp-Liste vertretbar.

Wir investieren also in Feedback und Textlücken und arbeiten mit dem übrigen Stand weiter.
