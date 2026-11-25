= Lernparadigma und Aufgabentyp

== Lernparadigma

Wir setzen auf Supervised Learning. Die Feedback-Knöpfe aus Use Case 4 liefern die Labels. „Kannte ich noch nicht und klingt spannend“ ist der Treffer, „Schon gesehen“ zeigt einen bereits bekannten Film. Als Eingabe dienen bayessche Bewertung, Stimmenzahl, die Genre-Ähnlichkeit zu den Referenzfilmen und die Markierung kulturell neu. Daraus lernt das Modell, wie wahrscheinlich einer Person ein Film gefällt.

Am Anfang fehlen diese Labels. Das MVP startet deshalb mit festen Regeln und einem einfachen Score. Das ist nachvollziehbar und braucht kein Training. Mit wachsendem Feedback übernimmt das trainierte Modell. Reinforcement Learning bräuchte sehr viele Interaktionen, und Unsupervised Learning allein findet zwar ähnliche Filme, lernt aber nicht, was Menschen gefällt.

== Aufgabentyp

Unser System ordnet den Katalog. Es stellt aus allen Filmen eine passende Auswahl von fünf zusammen. Wir empfehlen inhaltsbasiert (content-based), also über die Eigenschaften der Filme. Ein kollaborativer Ansatz bräuchte das Verhalten vieler Personen, und genau das fehlt uns zu Beginn. Inhaltsbasiert funktioniert schon mit dem ersten Fragebogen, und jede Empfehlung lässt sich mit konkreten Merkmalen begründen.

Im Kern bewertet das Modell jeden Kandidaten als passend oder unpassend. Die Wahrscheinlichkeit dafür ergibt die Rangfolge, danach setzen wir die Quote von zwei kulturell neuen Filmen als Regel durch. Einen generativen Ansatz brauchen wir nicht, denn auch die Begründungen entstehen aus Vorlagen mit den Metadaten.
