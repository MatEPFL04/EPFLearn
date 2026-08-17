# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

EPFLearn is an iOS SwiftUI app that helps first-year EPFL engineering students learn core concepts through short quizzes paired with interactive visualizations. Subjects covered: Analysis, Linear Algebra, Discrete Maths, Programming Basics, and (advanced) Sorting/Searching Algorithms and Graphs. Each quiz question links to a hand-built, gesture-driven visualization that lets the student manipulate the underlying math/algorithm rather than just read an explanation.

Some source comments and identifiers are in French (an earlier project name was `LearnViz`); question text and UI copy are in English.

## Build & run

This is a plain Xcode project (no SPM package, no CocoaPods) — `EPFLearn.xcodeproj`, single app target `EPFLearn`, bundle id `me.Lazzari.Matteo.EPFLearn`, Swift 5.0, iOS deployment target 26.4, iPhone + iPad.

- Open and run via Xcode: `open EPFLearn.xcodeproj`.
- There is no test target in the project and no `xcodebuild`-based CLI workflow set up — this environment only has Command Line Tools (no full Xcode), so `xcodebuild` is not available here. Verify changes by reading the code carefully; building/running requires Xcode on a machine with a full Xcode install.

## Architecture

### App shell and navigation

`EPFLearnApp.swift` is the `@main` entry point; it attaches a SwiftData `modelContainer` for `QuizResultRecord` and loads `ContentView`. `ContentView` is a `TabView` with three tabs: Quiz (`QuizView`), Progress (`StatisticsView`), Settings (`SettingsView`), and injects a `LocalProfile` into the environment.

On first launch (gated by the `hasCompletedOnboarding` `@AppStorage` flag), `ContentView` presents `OnboardingView.swift` as a `fullScreenCover`. It's a paged intro whose middle two pages embed the real `VisualizationView` (same component a quiz question's Hint uses) directly on-screen — `.complexNumbers` and `.image` — so the app's core differentiator (manipulable visualizations, not just a quiz) is visible, live, before the user ever reaches the quiz picker.

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
