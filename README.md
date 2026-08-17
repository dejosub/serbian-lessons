# Serbian Lessons

A practical, speaking-first Serbian course for an English-speaking beginner, designed for one weekly session with a Serbian-speaking family member and short practice between sessions.

## Course principles

- Useful language first; grammar explains patterns after they are familiar.
- Latin script leads in Lessons 1–2, both scripts appear from Lesson 3, and short Cyrillic reading starts by Lesson 5.
- Each lesson adds about 10–15 useful items and reviews older material.
- Family, meals, visits, and real conversations take priority over generic travel phrases.
- During speaking practice, correct the lesson target—not every mistake.

## Start here

1. Record the choices in [course-profile.md](course-profile.md), especially Ekavian or Ijekavian.
2. Read the [curriculum](curriculum.md).
3. Teach [Lesson 1](lessons/01-greetings-and-introductions/teacher-guide.md) using the [student handout](lessons/01-greetings-and-introductions/student-handout.md) and [slides](lessons/01-greetings-and-introductions/slides.md).
4. Afterward, add a dated session note in `notes/`. Use those observations to adapt the remaining lessons and the next three-lesson batch.

## Repository layout

```text
lessons/       One folder per lesson: slides, handout, teacher guide, homework
templates/     Reusable source files for future lessons
reference/     Course conventions and vocabulary decisions
curriculum.md  Initial sequence and outcomes
notes/         Session observations used to adapt later lessons
```

The Markdown files print cleanly from a browser or editor. `slides.md` uses Marp-compatible slide separators and can also be pasted into PowerPoint or Google Slides.

Every new lesson must be delivered in all three formats:

- Markdown source materials (`.md`)
- A formatted, self-contained HTML slide deck (`presentation.html`)
- A formatted PDF slide deck (`lesson-NN-slides.pdf`)
- A cumulative dictionary plus that lesson's incremental flash-card set in Markdown, HTML, and PDF

A lesson is not complete until all three formats exist and the PDF has been successfully exported and verified.

## Suggested rhythm

- One 60-minute lesson each week
- Develop publication-ready lessons in batches of three, then adapt from the uploaded session notes
- Four or five 10-minute practices between lessons
- One learner voice recording and one native-speaker model recording each week
- Five minutes of cumulative review at the start of every lesson

## Published flash cards

GitHub's repository viewer displays HTML source rather than running it. The interactive decks are published through GitHub Pages from `docs/`:

- Lesson chooser: `https://dejosub.github.io/serbian-lessons/`
- Individual deck: `https://dejosub.github.io/serbian-lessons/flashcards/lesson-NN/`
- Canonical editable source: `lessons/NN-topic/flashcards.html`

After adding or changing a lesson deck, run `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\sync-pages-flashcards.ps1` and commit both the canonical source and the generated files under `docs/`. In repository Settings → Pages, publish from the `main` branch and `/docs` folder.

## Recommended external materials

Use a published course as a map, not as the entire lesson. The conversation that started this repository recommended *Beginner's Serbian with Online Audio* (Aida Vidan and Robert Niebuhr) as the primary companion. *Complete Serbian* (Vladislava Ribnikar and David Norris) or *Naučimo srpski 1* can provide additional structure. *Serbian: An Essential Grammar* (Lila Hammond) is a reference, not a beginner course.

Only add material here that you wrote, have permission to distribute, or can link to legally.
