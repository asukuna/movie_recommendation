#import "metadata.typ": *

#let acr-state = state("acronyms-used", (:))

#let ac(term) = {
  // Der Zustand wird bewusst ausserhalb des context-Blocks gesetzt, sonst
  // loest Typst pro Kompilierlauf nur eine Abkuerzung auf und konvergiert nicht.
  context {
    if term in acr-state.get() {
      term
    } else {
      let long = acronyms.at(term)
      [#long (#term)]
    }
  }
  acr-state.update(used => used + ((term): true))
}

#let front-section(title, body, break-before: true, fill: black, outlined: false) = {
  if break-before {
    pagebreak(weak: true)
  }
  {
    set text(fill: fill)
    heading(level: 1, numbering: none, outlined: outlined)[#title]
  }
  body
}

#let dark-code(body, size: 9pt) = {
  show raw.line: it => {
    box(
      width: 100%,
      grid(
        columns: (2em, 1fr),
        column-gutter: 0.8em,
        align(right + horizon, text(fill: rgb("#6a6a6a"), size: size * 0.95)[#it.number]),
        it.body,
      ),
    )
  }
  show raw.where(block: true): code => {
    set text(fill: rgb("#d4d4d4"), size: size)
    block(
      width: 100%,
      fill: rgb("#1e1e1e"),
      inset: 12pt,
      radius: 4pt,
      code,
    )
  }
  body
}

/// Parenthetical German citation without nested parentheses: (vgl. Author, Year)
/// Optional named argument `supplement` (e.g. `[S. 27]`) is passed through to `cite`.
/// Optional `supplements` is an array of contents, one per label.
#let vgl(..args) = {
  let named = args.named()
  let supplement = named.at("supplement", default: none)
  let supplements = named.at("supplements", default: none)
  let labels = args.pos()

  let entry(i, label) = {
    let sup = if type(supplements) == array {
      supplements.at(i, default: none)
    } else {
      supplement
    }

    show "(": none
    show ")": none

    text(fill: rgb("#5b8db8"))[#cite(label)#if sup != none and sup != [] { [, #sup] }]
  }

  [(vgl. #labels.enumerate().map(((i, label)) => entry(i, label)).join[; ])]
}

#let thesis(doc) = {
  set document(
    title: document-title,
    author: document-authors,
  )
  set text(
    lang: "de",
    size: 12pt,
    font: ("Arial"),
  )
  show ref: set text(fill: color.olive)
  show link: set text(fill: blue)
  set par(justify: true, leading: 0.65em, spacing: 0.65em)
  set page(
    paper: "a4",
    margin: (top: 2.5cm, bottom: 2cm, left: 2.5cm, right: 2.5cm),
  )

  set heading(numbering: "1.1.1")
  show heading.where(level: 1): it => {
    block(breakable: false, width: 100%, spacing: 1.2em)[
      #text(size: 20pt, weight: "bold")[#it]
      #v(0.3em)
      #context[#line(length: 100%, stroke: 0.4pt + text.fill)]
    ]
  }
  show heading.where(level: 2): it => {
    block(breakable: false, width: 100%, spacing: 0.9em)[
      #text(size: 14pt, weight: "bold")[#it]
    ]
  }
  show heading.where(level: 3): it => {
    block(breakable: false, width: 100%, spacing: 0.7em)[
      #text(size: 12pt, weight: "bold")[#it]
    ]
  }

  show figure.caption: set text(size: 10pt)
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: raw): set figure(
    kind: image,
    supplement: [Abbildung],
  )
  show figure.where(kind: "quellcode"): set figure(supplement: [Quellcode])

  set math.equation(numbering: none)

  set bibliography(style: "apa-zugriff.csl")

  doc
}

#let page-footer = context {
  set text(size: 8pt, fill: gray)
  set par(justify: false, leading: 0.5em)
  grid(
    columns: (1fr, auto),
    column-gutter: 1em,
    align: (left + bottom, right + bottom),
    document-title,
    counter(page).display(),
  )
}
