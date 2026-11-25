= Projektbeschreibung

Wir bauen das Empfehlungssystem eines Streaming-Anbieters, der ein breites Publikum erreichen will. Heute landen die meisten Menschen bei Hollywood und bei Filmen, die sie schon kennen. Daraus wird schnell Langeweile, und irgendwann kündigen sie.

Wir wollen, dass internationale Geschichten für alle erreichbar sind. Wer Thriller mag, soll Thriller wiederfinden, nur eben auch einen aus Südkorea statt immer den nächsten US-Blockbuster. Jede Liste mischt deshalb vertraute Filme mit kulturell neuen.

== Allgemeine Anforderungen

+ Einmal pro Woche lädt der Scheduler die Filmdaten. Filme ohne Genre, Land oder Erscheinungsjahr fallen heraus und landen im Fehlerprotokoll. Die übrigen markiert das System als vertraut oder kulturell neu.
+ Die Person wählt mindestens ein Genre und bewertet fünf bis acht bekannte Filme als gefallen, nicht gefallen oder ungesehen.
+ Das Modell liefert fünf Filme. Mindestens zwei davon sind kulturell neu, also weder aus den USA oder dem Vereinigten Königreich noch mit englischer Originalsprache. Mindestens drei Länder kommen vor, und kein Subgenre steht öfter als zweimal in der Liste.
+ Zu jedem Film gibt es eine kurze Begründung von 80 bis 250 Zeichen, mit Bezug zum gewählten Genre oder zu einem Referenzfilm. Die Liste erscheint in höchstens fünf Sekunden.
+ Findet das Modell keine passenden kulturell neuen Filme, ergänzt das Backend kuratierte Geheimtipps und kennzeichnet sie auch so.
+ Die Person kann jede Empfehlung bewerten. Das Backend speichert das Feedback mit einer Request-ID, damit die Entscheidung nachvollziehbar bleibt und ins nächste Training eingeht.

== Szenario und Rahmenbedingungen

Marie-Juliette Krause, Emily Schell und Niklas Skopinski sind das Data- und ML-Team eines europäischen Streaming-Anbieters mit rund 250 Mitarbeitenden. Wir kümmern uns um Daten und Modell, Oberfläche und Backend baut ein anderes Team. Wir arbeiten agil mit Git und Miro.

Zu Beginn fehlen Nutzungsdaten, die öffentlichen Filmdaten haben Lücken, und Fragebogen sowie Feedback halten die DSGVO ein. Fest steht die Mischung aus drei vertrauten und zwei kulturell neuen Filmen.

== Minimal Viable Product

In der Präsentationsprüfung zeigen wir eine Notebook-Pipeline. Die Eingabe sind Genres und Referenzfilme. Danach folgen eine Vorfilterung, ein einfacher Score und fünf begründete Empfehlungen. Oberfläche, Import, Training und Monitoring kommen in späteren Schritten.
