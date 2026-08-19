# Repository instructions

## Lesson deliverables

Whenever a new lesson is created, generate all three publication formats in that lesson's directory:

1. Markdown source files (`.md`), including at minimum the slides, student handout, teacher guide, homework, cumulative dictionary, and cumulative flash cards.
2. A formatted, self-contained HTML slide deck named `presentation.html`.
3. A formatted PDF slide deck named `lesson-NN-slides.pdf`, exported from `presentation.html`.

Do not consider a new lesson complete until all three formats exist and the PDF export has been verified as a non-empty file. Keep the Markdown and HTML content synchronized. Use two-digit lesson numbers in file and directory names.

Every slide PDF must contain exactly one slide per PDF page. Slide HTML must define an explicit print page size, zero print margins, a fixed slide width and height, and a forced page break after each slide. If slides contain photographs or other raster assets, verify after export that the images visibly render on the relevant PDF pages; file existence and non-zero size alone are not sufficient.

After every lesson, include `dictionary.md` and `flashcards.md`. The dictionary is cumulative and contains all vocabulary introduced from Lesson 1 through the current lesson. Flash cards are incremental: `flashcards.md` contains only cards newly introduced in that lesson, so each set needs to be printed once. Also generate a printable `vocabulary.html` and `lesson-NN-vocabulary.pdf` containing the cumulative dictionary followed by that lesson's incremental cut-apart flash cards.

Always generate a self-contained, phone-friendly `flashcards.html` whenever a new lesson is created. It must contain only that lesson's incremental cards, start on the English side, flip to Serbian (Latin and Cyrillic) when the card is tapped or clicked, choose a random card with Next, and return through the viewing history with Prev. Next must not select any of the 10 most recently picked cards. It must work locally without network access or external assets.

For every flash card that uses an image, the initial/front face must show the image only—no English, Serbian, Cyrillic, Latin, caption, or other visible answer text. Put all language on the reverse/answer face. Use empty or non-revealing alternative text so accessibility metadata does not expose the answer before the card is flipped. Apply this rule to browser and printable renderings; Markdown source may retain descriptive labels for maintenance.

After any change that can affect flash cards—including creating, revising, renaming, or renumbering a lesson; changing lesson vocabulary; or editing a lesson's `flashcards.html`—publish the flash cards before considering the work complete. Run `scripts/sync-pages-flashcards.ps1`, commit the generated `docs/flashcards/lesson-NN/index.html` files and updated `docs/flashcards/lessons.json`, and verify that each published copy matches its canonical lesson-local `flashcards.html`. This preserves both the working GitHub Pages decks and the browsable source documents.

## Lesson design

## Family language preferences

- Use `деда · deda` for “grandfather/grandpa” in this family. Do not use `дека · deka` in lesson language, examples, readings, dictionaries, or flash cards.

Every lesson must include a short, coherent reading segment followed by open discussion. The reading should recycle language the learner already knows, add no more than a small amount of supported new language, and give the learner something meaningful to react to. Discussion may begin in English or mixed Serbian/English in early lessons, but should invite increasingly more Serbian as the course progresses.

Use completion and sentence-building exercises sparingly. Prefer comprehension, personal response, retelling, role-play, and open-ended conversation; a worksheet should prepare for communication rather than become the main activity.

## Cyrillic progression

Cyrillic must be introduced cumulatively without displacing the language-learning objective. Teach meaning and pronunciation first, normally in speech and Latin script, and then use already-understood words to introduce a small explicit set of Cyrillic letters. Never require the learner to solve substantial new vocabulary, new grammar, and new letter mappings at the same time.

- Lessons 1–2: Latin-led; recognize small letter sets in familiar words (about 90/10 Latin/Cyrillic).
- Lessons 3–4: Latin-led guided decoding; add manageable letter groups and short Cyrillic-only challenges using familiar language (about 75/25).
- Lessons 5–6: controlled independent reading; finish introducing the alphabet and move toward equal script exposure.
- Lesson 7: Cyrillic-led bridge; use Latin to support new or difficult language.
- Lesson 8 onward: primarily Cyrillic for instructional readings and familiar material, while retaining Latin strategically and continuing to build practical fluency in both Serbian scripts.

Treat recognition, decoding, and fluent reading as different stages. Introduce letters before requiring them, connect Cyrillic letters to their sounds, and keep English or Latin available until the learner can attend to meaning rather than spend the whole activity deciphering.
