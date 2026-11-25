#import "lib.typ": front-section, page-footer, thesis

#show: thesis

#include "titlepage.typ"

#pagebreak()

#set page(
  numbering: "1",
  footer: page-footer,
)

#front-section("Inhaltsverzeichnis", break-before: false)[
  #show outline.entry.where(level: 1): it => [
    #v(0.8em)
    #strong(it)
  ]
  #outline(title: none, indent: 2em)
]

#pagebreak()
#include "chapters/01-projektbeschreibung.typ"

#pagebreak()
#include "chapters/02-use-cases.typ"

#pagebreak()
#include "chapters/03-qualitaet.typ"

#pagebreak()
#include "chapters/04-lernparadigma.typ"

#pagebreak()
#include "chapters/05-datenqualitaet.typ"

#pagebreak()
#include "chapters/06-loesungsansaetze.typ"

#pagebreak()
#include "chapters/07-metriken.typ"

#pagebreak()
#include "chapters/08-pipelines.typ"

#pagebreak()
#include "chapters/09-bottlenecks.typ"

#pagebreak()
#include "chapters/10-datenbeschaffung.typ"

#pagebreak()
#include "chapters/11-datenexploration.typ"

#pagebreak()
#include "chapters/12-vektorisierung.typ"
