\version "2.22.0"

\header {
  title = "Compiler Symphony"
  subtitle = "MES → GCC → LLVM → Rustc"
  composer = "Bootstrap Chain"
}

\score {
  \new Staff {
    \clef bass
    \time 4/4
    {
      % mes
      <c, d, e, f, g,>1
      % gcc
      <c, d, e,>1
      % llvm
      <c, d, e, f, g, a, b, c d e f g a>1
      % rustc
      <c, d, e,>1
    }
  }
  \layout { }
  \midi { \tempo 4 = 60 }
}
