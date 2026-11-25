#import "metadata.typ": *

#set par(justify: false)

#let rot = rgb("#E00018")
#let grau = rgb("#586870")

// Große Faltung in den Logo-Farben, oben rechts über den Rand hinaus
#place(top + right, dx: 2.4cm, dy: -3.1cm)[
  #polygon(
    fill: grau,
    (0pt, 46pt),
    (150pt, 0pt),
    (250pt, 52pt),
    (100pt, 98pt),
  )
]
#place(top + right, dx: 0.6cm, dy: -1.5cm)[
  #polygon(
    fill: rot,
    (0pt, 34pt),
    (120pt, 0pt),
    (196pt, 58pt),
    (76pt, 92pt),
  )
]

#image("figures/logo-dhbw.png", height: 1.7cm)

#v(1fr)

#text(size: 13pt, fill: rot, weight: "bold")[Ausarbeitung · #module-name]

#v(0.45cm)

#text(size: 40pt, weight: "bold")[#document-title]

#v(0.35cm)

#text(size: 16pt, fill: grau)[#document-subtitle]

#v(1fr)

#text(size: 11pt, fill: grau)[von]
#v(0.25cm)

#for name in document-authors [
  #grid(
    columns: (16pt, 1fr),
    column-gutter: 0.45em,
    align: (horizon, horizon),
    rotate(45deg, reflow: true)[#square(size: 7pt, fill: rot)],
    text(size: 13pt)[#name],
  )
  #v(0.15cm)
]

#v(0.7cm)

#text(size: 12pt, fill: grau)[#document-date]
