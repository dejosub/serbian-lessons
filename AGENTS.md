# Repository instructions

## Lesson deliverables

Whenever a new lesson is created, generate all three publication formats in that lesson's directory:

1. Markdown source files (`.md`), including at minimum the slides, student handout, teacher guide, homework, cumulative dictionary, and cumulative flash cards.
2. A formatted, self-contained HTML slide deck named `presentation.html`.
3. A formatted PDF slide deck named `lesson-NN-slides.pdf`, exported from `presentation.html`.

Do not consider a new lesson complete until all three formats exist and the PDF export has been verified as a non-empty file. Keep the Markdown and HTML content synchronized. Use two-digit lesson numbers in file and directory names.

After every lesson, include `dictionary.md` and `flashcards.md`. The dictionary is cumulative and contains all vocabulary introduced from Lesson 1 through the current lesson. Flash cards are incremental: `flashcards.md` contains only cards newly introduced in that lesson, so each set needs to be printed once. Also generate a printable `vocabulary.html` and `lesson-NN-vocabulary.pdf` containing the cumulative dictionary followed by that lesson's incremental cut-apart flash cards.
