
Dialog and Overlay Testing Architecture Brief

This is a planning document. No implementation is included here.

0) Goals / Non-goals
Goals

All dialog and overlay flows are testable without fragile pumpAndSettle() or timing hacks.

Domain and rules emit data-only UI intents and decision requests.

Tests are fully deterministic and validate specs and control flow.

Non-goals

Verifying every animation frame in unit tests
(visual correctness is covered by widget tests).

Principle

Domain / Rules emit data (UiIntent, UiDecisionRequest).

Infrastructure renders UI via Presenter abstractions.

Tests validate specs and flow, not animations.

1) Core Concepts
1.1 UiIntent (pure data, non-blocking)

UiIntent describes a UI action that does not require a result.

Examples:

ShowDialog(spec: GenericAlertSpec(...)) (fire-and-forget)

ShowOverlay(spec: ToastSpec(...))

Navigate(route: ...)

Rule:
UiIntent must never block domain execution.

1.2 UiDecisionRequest (blocking, result required)

UiDecisionRequest<T> describes a user decision that the engine needs to proceed.

Examples:

BreakFoulDecisionRequest(...) -> BreakFoulDecisionResult

ConfirmExitGameRequest(...) -> ConfirmResult

ConfirmResetRequest(...) -> ConfirmResult

Rules:

Every UiDecisionRequest<T> must be completed exactly once.

Completion happens only via UiActionQueue + DialogPresenter.

Domain and adapters must never show dialogs directly.

1.3 DialogSpec / OverlaySpec (strongly typed)

Each dialog or overlay has its own strongly typed Spec.

Specs:

contain no Widgets

contain no BuildContext

contain no closures

store text as L10n keys + arguments, not final strings

Specs are pure value objects and are compared directly in tests.

2) Data Models
2.1 TextRef (L10n key + args)
key:  String                // e.g. "dialog.breakFoul.title"
args: Map<String, Object?>  // e.g. { "count": 2 }


Constraints:

args must be JSON-safe primitives only
(String | int | double | bool | enum-name string)

Keys follow namespace convention:
dialog.<dialogId>.<field>

2.2 DialogSpecs (minimum set)

All dialog specs extend DialogSpec<T> and define their result type explicitly.

A) GenericAlertSpec -> DialogSpec<void>

id: String (stable, e.g. "generic_alert")

title: TextRef?

message: TextRef

primaryButton: TextRef

secondaryButton: TextRef?

severity: enum { info, warning, error }

barrierDismissible: bool

B) BreakFoulDialogSpec -> DialogSpec<BreakFoulDecisionResult>

id: "break_foul"

title: TextRef

message: TextRef

options: { foul: TextRef, noFoul: TextRef }

barrierDismissible: false

C) ConfirmExitGameDialogSpec -> DialogSpec<ConfirmResult>

id: "confirm_exit_game"

title: TextRef

message: TextRef

confirm: TextRef

cancel: TextRef

barrierDismissible: true

D) ConfirmResetDialogSpec -> DialogSpec<ConfirmResult>

id: "confirm_reset"

title: TextRef

message: TextRef

confirm: TextRef

cancel: TextRef

barrierDismissible: product decision

2.3 Results / Decisions
enum ConfirmResult { confirm, cancel }
enum BreakFoulDecisionResult { foul, noFoul }


Dismiss semantics:

If a confirm dialog is dismissed (tap outside / back):
-> ConfirmResult.cancel

Break foul dialogs are not dismissible.

3) Presenter Interfaces
3.1 DialogPresenter (prod / test)

DialogPresenter is the only component allowed to display dialogs.

Future<T?> showDialog<T>(DialogSpec<T> spec)


Rules:

No showDialog() calls outside the presenter.

DialogSpec<T> enforces compile-time correctness of results.

3.2 OverlayPresenter (optional)

If overlays are used:

void showOverlay(OverlaySpec spec)


(Overlays are non-blocking.)

4) Deterministic UI Queue
4.1 UiActionQueue (single post-frame authority)

The queue is the only place that:

schedules post-frame work,

processes UiIntents sequentially,

executes UiDecisionRequests in a blocking way.

Rules:

FIFO order

Never show more than one dialog at a time

No addPostFrameCallback outside this queue

enqueue() is side-effect free

Minimal API:

void enqueue(UiIntent intent)
Future<T> requestDecision<T>(UiDecisionRequest<T> request)
Future<void> drain() // for tests


Guarantees:

Queue is reentrancy-safe

drain() completes only when:

queue is empty

no dialog is pending

5) Mapping / Adapter (GameEvent -> UI)
5.1 GameUiAdapter

Central adapter that:

observes GameEvents / state transitions,

enqueues UiIntents,

triggers UiDecisionRequests.

Rules:

No dialog logic in widgets

No dialog logic scattered in GameState

All UI decisions flow through the adapter

Example:

BreakFoulDecisionNeeded
-> requestDecision(BreakFoulDecisionRequest(...))

6) Production Implementation (Flutter)
6.1 ProdDialogPresenter

Implements showDialog<T>() using Flutter dialogs/sheets

Reads animation durations exclusively from AppDurations

Accesses navigation via one defined strategy
(recommended: injected GlobalKey<NavigatorState>)

6.2 Dialog Widgets

Each Spec has a widget builder

Results are returned via Navigator.pop(result)

Widgets contain no domain logic

7) Durations / TestConfig
7.1 AppDurations

Central DI-provided configuration:

dialogTransition

overlayFade

other animation timings

7.2 TestConfig.fastAnimations

In tests, all durations are Duration.zero

No hardcoded Duration(milliseconds: ...) outside AppDurations

8) Testing (deterministic)
8.1 TestDialogPresenter

Collects all shown DialogSpecs

Returns results from a predefined queue or per-spec mapping

Throws if a required result is missing (test failure)

8.2 Unit tests (spec tests)

Pattern:

Setup Engine + Adapter + Queue + TestPresenter

Trigger event / state

await uiQueue.drain()

Assert: shown specs == expected specs (exact equality)

8.3 Flow tests (decision affects engine)

Pattern:

Predefine decision result

Trigger decision request

Drain queue

Assert: engine state reflects decision

8.4 Widget tests (rendering)

Only for critical dialogs:

Break Foul

Exit Game

Reset Game

Pattern:

Pump TestApp (Theme + L10n + Providers)

Render dialog

Assert text, buttons, semantics

fastAnimations = true

9) Examples
9.1 Break Foul Decision

Engine emits BreakFoulDecisionNeeded

Adapter -> BreakFoulDecisionRequest

Result routed back:

foul -> apply foul

noFoul -> continue normal flow

9.2 Exit Game Confirm

UI button -> adapter.requestExitGame()

Adapter -> ConfirmExitGameRequest

Result decides navigation

10) Policy (mandatory)

Any new dialog or overlay must include:

DialogSpec + unit test for spec mapping

Widget test for critical dialogs or complex layouts

Hard rules:

No showDialog outside DialogPresenter

No addPostFrameCallback outside UiActionQueue

No hardcoded durations outside AppDurations

Unit tests must not use pumpAndSettle()

Implementation Order

TextRef + DialogSpec<T> base + 4 dialog specs

DialogPresenter + ProdDialogPresenter + TestDialogPresenter

UiActionQueue

GameUiAdapter

Unit tests (spec + flow)

Widget tests (critical dialogs only)

Acceptance Criteria

Unit tests run without pumpAndSettle() or time-based delays

Dialog regressions break unit tests via exact spec comparison

Widget tests are few, stable, and use fastAnimations = true
