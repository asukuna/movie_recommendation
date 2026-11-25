#let grau = rgb("#586870")
#let hell = rgb("#F4F6F7")

= Datenexploration

Wir wollten wissen, ob unsere geplanten Features und Labels mit den vorhandenen Daten tragen. Der Katalog enthält keine persönlichen Urteile, also keine Angabe, ob einer Person ein Film gefällt. Als Stellvertreter nutzen wir die MovieLens-Stichprobe. Sie enthält 97.002 Bewertungen von 671 Personen für 8.094 Filme unseres Katalogs, verbunden über die IMDb-ID. Eine Bewertung ab 4 Sternen zählt als „gefällt“.

Der Test bildet unseren Fragebogen nach. Von jeder Person verstecken wir fünf gemochte Filme als Referenzfilme. Alle anderen bewerteten Filme sortieren wir mit je einem Feature und fragen, ob die gemochten oben stehen. Das messen wir mit der AUC pro Person, wobei 0,5 Zufall bedeutet, und mit Precision\@5.

== Labels

Das Ziel-Label ist „gefällt“. In der Anwendung kommt es aus den Knöpfen von Use Case 4. Bis dahin dient „Bewertung ab 4“ als Ersatz. Die Klassen sind mit 51 zu 49 Prozent ausgewogen. Als schwaches Label haben wir die IMDb-Bewertung geprüft. Sie hängt mit der mittleren MovieLens-Bewertung stark zusammen (Spearman 0,84 bei 1.289 Filmen mit mindestens 20 Bewertungen) und taugt deshalb als Startsignal.

Der Ersatz hat Grenzen. Die MovieLens-Filme sind viel bekannter, ihr Median liegt bei 23.435 Stimmen gegenüber 484 im Katalog. Nur 8,4 Prozent der Filme und 2,9 Prozent der Bewertungen betreffen kulturell neue Filme. Die Personen haben die Filme außerdem gesehen, bevor sie sie bewertet haben.

== Features und Korrelationen

#figure(
  image("../figures/feature-exploration.png", width: 15cm),
  caption: [Aussagekraft der Features (links) und Treffer in den ersten fünf Filmen (rechts)],
)

*Bayessche Bewertung.* Sie ist mit einer AUC von 0,69 das stärkste Signal. Allein erreicht sie bei Precision\@5 73 Prozent, der Zufall liegt bei 53.

*Stimmenzahl.* Allein hat sie eine AUC von 0,61, weil bekannte Filme öfter gefallen. Sie hängt aber eng mit der Bewertung zusammen (Spearman 0,66). Im gemeinsamen Modell kippt ihr Gewicht ins Negative, bei gleicher Bewertung treffen weniger bekannte Filme etwas häufiger. Das stützt unseren Nischen-Faktor.

*Genre-Ähnlichkeit.* Sie ist unser einziges persönliches Merkmal, aber schwach (AUC 0,56, Precision\@5 62 Prozent). Die IDF-Gewichtung aus Kapitel 6 hilft nicht, sie sinkt auf 0,54. Wir starten daher mit der einfachen Jaccard-Ähnlichkeit und vergleichen die IDF-Variante nur noch.

*Text, Regie und Darsteller.* Die Text-Ähnlichkeit (TF-IDF) kommt auf 0,525, Regie auf 0,516 und Darsteller auf 0,521. Sie bringen kaum Signal. TF-IDF vergleicht nur gleiche Wörter. Embeddings prüfen wir in Kapitel 12, sie liegen mit 0,534 nur leicht darüber.

*Kulturell neu und Erscheinungsjahr.* Kulturell neue Filme gefallen in den Daten häufiger (67 gegen 51 Prozent), doch das stammt aus nur 2,9 Prozent der Bewertungen und ist verzerrt, denn wer fremdsprachige Filme sieht, mag sie meist. Die AUC liegt bei 0,52. Das Jahr erreicht 0,47, ältere Filme gefallen etwas öfter.

*Kombination.* Ein einfaches Modell aus Bewertung, Stimmen, Genre und kulturell neu erreicht eine AUC von 0,69 und Precision\@5 von 75 Prozent. Das ist nur zwei Punkte besser als die Bewertung allein. Die persönliche Passung trägt mit den heutigen Daten also wenig, das Modell lebt vom Qualitätssignal. Der Zielwert von 60 Prozent aus Kapitel 7 ist im Test leicht zu erreichen, doch dort sind es nur gesehene Filme. Im Pilot wird er deutlich schwerer.

== Was steht beim Aufruf zur Verfügung

Beim Aufruf kennen wir den Fragebogen mit Genres und Referenzfilmen samt Urteil und alle Merkmale des Katalogs. Wir kennen nicht den Verlauf der Person, denn wir speichern kein Profil, und nicht die Rückmeldung zu den neuen Filmen. Die mittlere MovieLens-Bewertung eines Films dürfen wir nicht als Feature nutzen. Sie ist beim Aufruf nicht verfügbar und würde das Training verfälschen.

== Übersicht

#[
  #set text(size: 8.5pt)
  #set par(justify: false)
  #table(
    columns: (3.4cm, 2.2cm, 6.3cm, 3.9cm),
    inset: 3.5pt,
    stroke: 0.5pt + grau,
    fill: (x, y) => if y == 0 { hell } else { white },
    [*Name*], [*Art*], [*Befund*], [*Entscheidung*],
    [Gefällt (UC4)], [Label], [Echte Rückmeldung, noch nicht vorhanden], [Ziel-Label ab dem Pilot],
    [Gefällt (MovieLens ab 4)], [Ersatz-Label], [51 % positiv, ausgewogen, verzerrt zu bekannten Filmen], [Nur für Tests],
    [Bayessche Bewertung], [Feature, schwaches Label], [AUC 0,69, Spearman 0,84 zur Nutzerbewertung], [Behalten],
    [Stimmenzahl (log)], [Feature], [AUC 0,61, bei gleicher Bewertung negativer Effekt], [Behalten als Nischen-Faktor],
    [Genre-Ähnlichkeit], [Feature], [AUC 0,56, IDF-Variante 0,54], [Behalten mit Jaccard],
    [Kulturell neu], [Regel und Feature], [Nicht prüfbar, nur 2,9 % der Bewertungen], [Quote als Regel, Feature im Modell],
    [Text der Beschreibung], [Feature], [TF-IDF 0,525], [Embedding nur als Zusatz, kein MVP-Merkmal],
    [Regie, Darsteller], [Feature], [AUC 0,52], [Zunächst weglassen],
    [Erscheinungsjahr], [Feature], [AUC 0,47], [Zunächst weglassen],
    [Mittlere Fremdbewertung], [kein Feature], [Beim Aufruf nicht verfügbar], [Nicht verwenden],
  )
]

Wir brauchen mehr Daten, nämlich echte Rückmeldungen aus Use Case 4, vor allem zu kulturell neuen Filmen. Mit den heutigen Daten können wir die persönliche Passung und die Wirkung der neuen Filme nicht belastbar prüfen. Andere Features lohnen sich erst, wenn dieses Feedback vorliegt.
