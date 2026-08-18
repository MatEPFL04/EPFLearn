# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

EPFLearn is an iOS SwiftUI app that helps first-year EPFL engineering students learn core concepts through short quizzes paired with interactive visualizations. Subjects covered: Analysis, Linear Algebra, Discrete Maths, Programming Basics, and (advanced) Sorting/Searching Algorithms and Graphs. Each quiz question links to a hand-built, gesture-driven visualization that lets the student manipulate the underlying math/algorithm rather than just read an explanation.

Some source comments and identifiers are in French (an earlier project name was `LearnViz`); question text and UI copy are in English.

## Build & run

This is a plain Xcode project (no SPM package, no CocoaPods) — `LearnScope.xcodeproj`, single app target `EPFLearn`, bundle id `me.Lazzari.Matteo.EPFLearn`, display name **LearnScope**, Swift 5.0. **iPhone only (`TARGETED_DEVICE_FAMILY = 1`) and portrait-locked**: shipping as Universal put the app in iPad compatibility mode, which is the most likely reason review saw "minimal functionality".

- Open and run via Xcode: `open LearnScope.xcodeproj`.
- There is no test target in the project and no `xcodebuild`-based CLI workflow set up — this environment only has Command Line Tools (no full Xcode), so `xcodebuild` is not available here. Verify changes by reading the code carefully; building/running requires Xcode on a machine with a full Xcode install.

## Architecture

### App shell and navigation

`EPFLearnApp.swift` is the `@main` entry point; it attaches a SwiftData `modelContainer` for `QuizResultRecord` and loads `ContentView`. `ContentView` is a `TabView` with three tabs: Practice (`QuizView`), Progress (`StatisticsView`), Settings (`SettingsView`), and injects a `LocalProfile` into the environment.

`StatisticsView` also surfaces a "focus review" banner (weakest subject with ≥2 attempts and <75% success) and a practice streak (consecutive days with a completed quiz, derived from `QuizResultRecord.date`); tapping the banner sets `ContentView`'s `pendingSubject`, which `QuizView` watches to jump straight into that subject's quiz. `SettingsView` has an opt-in daily reminder toggle backed by `ReminderManager.swift` (local notification, rescheduled after every completed quiz and on launch, never fires on a day already practiced).

On first launch (gated by the `hasCompletedOnboarding` `@AppStorage` flag), `ContentView` presents `OnboardingView.swift` as a `fullScreenCover`. It's a four-page intro whose middle two pages embed the real `VisualizationView` (the same component a quiz question's Hint uses) directly on-screen — `.complexNumbers` and `.image` — so the app's core differentiator is live before the user reaches the picker. Its final page names both study modes: Build mode is the app's differentiator and a new student will not discover it from the picker alone.

### Study modes

`QuizView`'s subject picker carries a `StudyMode` choice with two modes over the same subjects:

- **Quiz** (`QuizViewModel` → `QuestionView`), the original multiple-choice flow described below.
- **Build it** (`ChallengeViewModel` → `ChallengeView`), the inverted flow: the visualization *is* the question. The student drags the figure until it satisfies a stated condition and the manipulation itself is graded.

**Grading is not live, on purpose.** An earlier version showed a warmer/colder proximity meter, which made the fastest route to every answer "wiggle the figure and watch the bar" — nothing was understood. So `ChallengeFeedback` carries only `satisfied` (never surfaced live) and an optional `blocker` for preconditions outside the reasoning (wrong operator selected, wrong space). It deliberately carries **no readout**: every figure already prints its own values, so echoing them under the prompt was duplication that squeezed the picture. The student commits with an explicit **Check**, capped at `ChallengeViewModel.maxAttempts` (3) wrong commits before only the worked example remains. `report(_:)` records the reading and decides nothing; `check()` is the only place a challenge can be solved, and it **re-evaluates from the stored `lastReading`** rather than trusting the cached `feedback` — trusting the cache meant a figure whose reading had not changed since a failed attempt kept replaying that attempt's verdict.

Rules the banks follow, all learned the hard way: a target must not be reachable by opening a preset menu and picking the obviously named entry ("build an injective map" was solved by choosing Identity); it must stay inside the figure's comfortable range (a product of `5i` forces the complex plane to zoom out until both operands are specks); and it must be about a property rather than about operating a control ("refine until the gap is small" is just dragging a slider to its end). Targets are single points rather than regions so a blind commit is a poor bet, and the determinant bank draws its target fresh per run via `Challenge.vectorChallenges()`. Where a figure has a mode or region picker, the challenge requires the *right* one to be selected — a Venn claim only counts once the student shades the region that settles it.

A visualization opts into Build mode by taking an optional `onReading: ((ChallengeReading) -> Void)?` parameter (defaulting to nil, so its use as a plain hint view is unchanged) and firing it from an `.onChange` on its own state. `Models/Challenge.swift` holds the `Challenge` banks, each pairing a prompt with an evaluator closure and an explanation written as a worked numeric example rather than a restatement of the rule.

`ChallengeView`'s private `ChallengeCanvas` is the switch wiring each `VisualizationType` to a figure that reports readings. Twelve figures are instrumented, and Build mode covers four subjects with **six challenges each**, spread so a run never repeats one figure six times:

| Subject | Figures |
|---|---|
| Analysis | `.complexNumbers` 2, `.trigo` 2, `.TAF` 2 (Rolle) |
| Linear Algebra | `.determinant` 2, `.matrixOperations` 2, `.image` 1, `.linearTransformations` 1 |
| Programming Basics | `.bitwiseOperations` 3, `.forLoop` 3 |
| Discrete Maths | `.pigeonholePrinciple` 2, `.setOperations` 2, `.binomialCoefficients` 2 |

`.arrays` and `.graphs` have no bank, and `QuizView.visibleCategories` **drops them from the list entirely** in Build mode rather than showing them greyed out. `Challenge.hasChallenges(for:)` is the cheap predicate for that filter; don't call `challenges(for:)` from a view body, it shuffles and draws a fresh random target each time.

`ChallengeCanvas.scrollsItself` lists the five figures that already scroll internally and skips the wrapper for them: two `ScrollView`s on the same axis fight over a drag, and whichever loses hands it to whatever slider sits underneath.

Build mode is tinted teal (`ChallengeView.tint`). The mode signal lives in **one** place, `QuizView.modeBackdrop`: a strong full-page gradient behind the subject picker, deep indigo for Quiz against vivid teal for Build it. Category cards keep their own subject colour in both modes, and the two `modeCard` buttons replace what used to be a segmented picker, each stating in one line what its mode asks of you.

Wording across the app covers both modes deliberately: a stored `QuizResultRecord` cannot say which mode produced it, so Settings counts "Sessions", Progress counts "runs", and neither says "quiz" where a Build run would also land.

Because these figures are shared with the quiz's Hint screen, their readability work benefits both modes: `GraphicsContext.chip(_:at:size:_:within:)` in `TrigPlotKit.swift` draws a label on a filled, edge-clamped plate, and `ComplexPlaneView` / `VectorSpaceView` use it to print each vector's actual value at its tip, pushed radially outward so two aligned vectors no longer stack their labels.

Both modes finish into the same `ResultQCM` and are persisted identically via `ContentView.record(_:)`, so a Build run feeds the streak, stats and focus review exactly like a quiz.

### Quiz flow

`QuizView` → category picker → `QuizViewModel` (`@Observable`) → `QuestionView`.

- `QuizViewModel.tapped(_:)` swaps in one of six question banks (`Question.sampleQuestions*()`, keyed by `Subject`) and calls `restart()`.
- `QuestionView` renders the current `Question`'s text/options via `OptionButton`, and has a toolbar toggle ("Hint" / "Question") that swaps the question body for a full-screen `VisualizationView` showing the paired interactive visualization plus the question's `hint` text.
- On quiz completion, `QuizViewModel.onComplete` fires with a `ResultQCM`; `ContentView.installQuizCompletionHandler()` wraps that into a `QuizResultRecord` and saves it via SwiftData, scoped to `LocalProfile.id`.

### Question data model

`Models/Questions/Questions.swift` defines the core types:
- `Subject` — the six top-level categories (also used as SwiftData `categoryRaw` and to pick the sample-question function).
- `Question` — `subject`, `text`, `hint`, `options`, `correctIndex`, `explanation`, `visualization: VisualizationType`.
- `VisualizationType` — one case per distinct interactive visualization (grouped by subject in the enum body).
- `Question.sampleQuestions*()` — one function per `Subject`; each picks **one random question per topic bank, then shuffles**, so a quiz always samples across topics rather than clustering on one.

Per-subject question banks live in sibling files (`AnalysisQuestions.swift`, `LinearAlgebraQuestions.swift`, `DiscreteMathsQuestions.swift`, `ProgrammingBasicsQuestions.swift`, `SortingAlgQuestions.swift`, `GraphQuestions.swift`), each as an `extension Question` holding `static let xQuestions: [Question]` banks, one bank per micro-topic (e.g. `complexPlaneQuestions`, `darbouxQuestions`). To add a question to an existing topic, append to the relevant bank; to add a new topic, add a new bank and register it in the matching `sampleQuestions*()` array in `Questions.swift`.

### Visualization dispatch and views

`VisualizationView.swift` holds a single `switch` over `VisualizationType` that maps each case to a concrete view from `HintsViews/`. **This switch is the one place that wires a new `VisualizationType` case to its view** — any new visualization must be added here as well as to the enum in `Questions.swift`.

`HintsViews/` is organized to mirror `Subject`: `Algebra/`, `Algorithms/Graphs/`, `Algorithms/Sorting/`, `Analysis/` (with `Sequences/` and `TrigoNComplex/` subfolders), `Discrete maths/`, `Programming/`. Each view is typically a self-contained, gesture/slider-driven `Canvas`-based SwiftUI view that lets the student manipulate the concept live (e.g. drag a point on a complex plane, step through Gaussian elimination, scrub a sequence index).

Shared plotting infrastructure, reused across views rather than reimplemented per view:
- `MathCoordinateSpace.swift` — converts between math coordinates and screen points (`toScreen`/`toMath`), used by most `Canvas`-drawn plots.
- `HintsViews/Analysis/Adaptiveplot.swift` — defines the `plotWidth` `EnvironmentKey` (set once in `VisualizationView` from a `GeometryReader` keyed to screen size, not content) and the `.adaptivePlot(_:min:max:inset:)` view modifier, which lets a plot's size track the container width without ever measuring its own content (keeps things stable across rotation and avoids feedback loops).
- Per-topic "kit" files provide shared drawing primitives/palettes for their subfolder and should be reused by new views in that area rather than re-derived: `SeqPlotKit.swift` and `TrigPlotKit.swift` (Analysis), `Discretemathkit.swift`, `PBkit.swift` (Programming), `SharedMatrixComponents.swift` (Algebra).

### Persistence and identity

- `LocalProfile.swift` — a per-install anonymous identifier stored in `UserDefaults` (not a real account). It migrates values from legacy keys (`appleUserID`, `guestUserID`) written by older builds so existing users don't lose quiz history when the identity model changes.
- `QuizResultRecord.swift` (SwiftData `@Model`) — the persisted quiz-attempt record, scoped by `userID` (from `LocalProfile`); `asResultQCM` converts back to the in-memory `ResultQCM` used by `StatisticsView`.
- `Models/AuthManager.swift` (Sign in with Apple) and `Models/QuizResult.swift` (an older SwiftData `@Model` with `score`/`total`) are **not referenced anywhere outside their own file** — dead code from an earlier auth-based design, superseded by `LocalProfile` + `QuizResultRecord`. Don't build new features on them without first confirming whether they're meant to be revived or removed.
