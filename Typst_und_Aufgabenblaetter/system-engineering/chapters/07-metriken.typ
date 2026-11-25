#let grau = rgb("#586870")
#let hell = rgb("#F4F6F7")

= Metriken

Unser Produktziel ist Kundenbindung durch Listen, die vertraut genug sind und trotzdem Neues zeigen. Wir messen deshalb in vier Kategorien. Weil wir mit neuen Nutzerinnen und Nutzern starten und noch keine Nutzungsdaten haben, sind alle Zielgrößen begründete Annahmen. Wir schärfen sie nach dem ersten Pilot nach.

#[
  #set text(size: 9.5pt)
  #set par(justify: false)
  #table(
    columns: (3.1cm, 4.7cm, 4.3cm, 3.9cm),
    inset: 4pt,
    stroke: 0.5pt + grau,
    fill: (x, y) => if y == 0 { hell } else { white },
    [*Kategorie*], [*Metrik*], [*Zielgröße*], [*Bezug*],
    [Business], [Allgemeine CTR], [30 bis 40 %], [Kundenbindung],
    [], [CTR für kulturelle Entdeckungen], [15 bis 18 %], [F01],
    [Modell], [Precision\@5], [≥ 60 %], [B01, F01],
    [], [Hit-Rate\@5 (statt Recall)], [≥ 90 %], [Produktziel],
    [], [Log-Loss], [< 0,55], [Zuverlässige Scores],
    [], [Einhaltung der Vielfaltsregeln], [100 %], [F01, B01],
    [Freshness], [Alter des Modells, Trainingsdauer], [≤ 7 Tage, ≤ 5 Minuten], [E02],
    [Geschwindigkeit], [Zeit bis zur Liste (95. Perzentil)], [≤ 3 s, maximal 5 s], [E01],
    [], [Suche nach Referenzfilmen], [≤ 0,5 s], [Fragebogen],
  )
]

== Business Performance

Hier fragen wir, ob die Empfehlungen dem Produkt wirklich nützen. Unsere Produktmetrik ist die Click-Through-Rate (CTR). Sie sagt, von wie vielen angezeigten Listen am Ende ein Film angeschaut wird. Sie zeigt direkt, ob Menschen den Empfehlungen folgen, die Voraussetzung für Kundenbindung.

Alle fünf Filme einer Liste zählen zusammen als eine Impression. Mehrere Filme statt nur einem erhöhen die Chance auf einen Treffer. Eine Liste ist erfolgreich, wenn die Person mindestens einen der fünf Filme anklickt und davon mindestens 10 Minuten sieht. Die 10 Minuten sind eine Annahme und sollen bloßes Probeklicken ausschließen.

$ "CTR" = "erfolgreiche Listen" / "ausgespielte Listen" dot 100 % $

*Allgemeine CTR, 30 bis 40 %.* Sie zählt jeden Film, egal aus welcher Filmkultur. Bei 35 erfolgreichen von 100 Listen liegen wir im Ziel. Nach unserer Recherche erreichen übliche Empfehlungen etwa 12 %. Wir setzen deutlich mehr an, weil eine Liste fünf Chancen bietet und drei der Filme nah am Geschmack bleiben.

*CTR für kulturelle Entdeckungen, 15 bis 18 %.* Sie zählt nur Klicks auf die zwei kulturell neuen Filme. Wären alle Plätze gleich attraktiv, läge sie bei 40 % der allgemeinen CTR, also bei 12 bis 16 %. Wir rechnen mit etwas mehr, weil die Begründungen aus B02 die neuen Filme erklären und neugierig machen.

*Leitplanke.* Die allgemeine CTR schützt die Entdeckungen. Steigen sie, während die allgemeine CTR unter 30 % fällt, drängen wir zu viel Neues auf und verlieren die Zufriedenen.

== Modell Performance

Hier prüfen wir das Modell getrennt vom Produkt, schon vor dem Start. Ohne Rückmeldungen verstecken wir in Tests einzelne Referenzfilme und testen im Team. Später zählen die Labels aus Use Case 4, als Treffer gilt „Kannte ich noch nicht und klingt spannend“.

*Precision\@5, mindestens 60 %.* Sie fragt, wie viele der fünf gezeigten Filme Treffer sind. Passen drei Filme, sind es 60 %. Formal ist es $"TP" / ("TP" + "FP")$, richtige Treffer geteilt durch alle gezeigten Filme. Zwei Plätze gehören bewusst unbekannten Filmen und sind riskanter, die anderen drei sollen verlässlich passen.

*Hit-Rate\@5, mindestens 90 %.* Sie fragt, bei wie vielen Listen mindestens ein Film trifft. Wir nehmen sie statt des klassischen Recalls. Recall teilt durch alle Filme, die einer Person gefallen würden, und weil wir nur fünf Plätze haben, bleibt er klein. Gefallen 20 Filme, sind höchstens 25 % möglich. Bei 60 % Precision läge die Hit-Rate rechnerisch bei 99 %. Wir setzen 90 % an, weil die Treffer nicht unabhängig sind.

*Log-Loss, unter 0,55.* Das Modell gibt für jeden Film an, wie wahrscheinlich er passt. Log-Loss bestraft vor allem Fälle, in denen es sich sicher war und falsch lag. Reines Raten ergibt 0,69. Der Wert 0,35 würde im Schnitt 70 % Sicherheit auf der richtigen Antwort verlangen, das ist bei Geschmacksurteilen unrealistisch. Mit unter 0,55 muss das Modell klar besser sein als Raten.

*Einhaltung der Vielfaltsregeln, 100 %.* Sie zählt, wie viele Listen mindestens zwei kulturell neue Filme, drei Länder und höchstens zwei Filme je Subgenre haben. Sie ist ohne Nutzer messbar, und nach F01 und B01 darf keine Liste die Regeln verletzen.

== Freshness

Das Modell lernt aus Daten der Vergangenheit. Ändern sich Katalog, Geschmack oder Jahreszeit, passt es schlechter. Dieses Auseinanderdriften nennt man Distribution Shift. 

Der Katalog wird wöchentlich importiert, und es kommen rund 1.000 Rückmeldungen pro Woche hinzu. Geschmack und Saison ändern sich dagegen eher langsam. Wir trainieren deshalb einmal pro Woche, das Modell ist also höchstens 7 Tage alt, und neue Filme sind spätestens nach einer Woche empfehlbar. Das Training darf höchstens 5 Minuten dauern (E02). Misslingt ein Lauf, bleibt Zeit für einen neuen Start. Fällt die Precision\@5 gegenüber der Vorwoche um mehr als 5 Prozentpunkte, prüfen wir, ob sich die Daten verschoben haben.

== Geschwindigkeit

Nach dem Absenden des Fragebogens wartet die Person bewusst auf ihre Liste. Dafür sind 3 Sekunden ein üblicher Wert, in höchstens 5 Sekunden muss sie da sein (E01). Wir messen am 95. Perzentil, also an den langsamsten fünf Prozent der Anfragen. Die Vektoren der Filme entstehen schon im Import, deshalb ist das machbar.

Die Suche nach Referenzfilmen reagiert dagegen bei jedem getippten Buchstaben. Dort stören schon Bruchteile von Sekunden, deshalb setzen wir 0,5 Sekunden an (Faustregel unter einer Sekunde).
