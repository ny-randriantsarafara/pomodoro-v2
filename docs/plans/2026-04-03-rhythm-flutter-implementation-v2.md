# Rhythm Flutter Rebuild — Implementation Plan v2

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Faithfully rebuild the Rhythm Pomodoro app in Flutter from the React + Tailwind + Motion prototype, preserving all layouts, interactions, timing behavior, and animation feel.

**Architecture:** Feature-based Flutter app with Riverpod for state injection, go_router for route structure, repository interfaces for persistence readiness, and custom animation/controller orchestration for fidelity-sensitive UI sequences.

**Tech Stack:** Flutter, Dart, flutter_riverpod, go_router, lucide_icons, intl, Inter + JetBrains Mono as bundled assets

## Documentation and Artifact Disposition

- **Temporary artifacts:**
  - `docs/plans/2026-04-03-rhythm-flutter-rebuild-design.md`
  - `docs/plans/2026-04-03-rhythm-flutter-implementation.md`
  - `docs/plans/2026-04-03-rhythm-flutter-implementation-v2.md`
- **Promote if validated:**
  - Theme token reference → `README.md`
  - Repository contracts → `README.md`
  - Route structure → `README.md`
  - Timer behavior notes → `README.md`
- **Delete if not durable:**
  - All three docs in `docs/plans/` after implementation if they add no lasting value

---

## Status

This plan **supersedes Tasks 10–17** in `docs/plans/2026-04-03-rhythm-flutter-implementation.md`.

- **Keep Tasks 1–9** from v1 unchanged.
- **Use this v2 plan for Tasks 10–18** below.

Reason: v1 was strong architecturally, but under-specified for blind execution in the UI-heavy areas.

---

## Preflight: Deterministic Font Setup

The v1 plan left font filenames uncertain. Make them deterministic before touching Dart code.

**Files:**
- Create/rename inside: `assets/fonts/`

**Step 1: Ensure exact font filenames exist**

Run:

```bash
cd /Users/nrandriantsarafara/Works/sandbox/pomodoro
mkdir -p assets/fonts

# Inspect downloaded fonts
find assets/fonts -maxdepth 1 -type f | sort

# If files exist under different names, normalize them:
cp "$(find assets/fonts -type f | grep -i 'Inter.*Regular.*\.ttf' | head -n 1)" assets/fonts/Inter-Regular.ttf
cp "$(find assets/fonts -type f | grep -i 'Inter.*Medium.*\.ttf' | head -n 1)" assets/fonts/Inter-Medium.ttf
cp "$(find assets/fonts -type f | grep -i 'Inter.*SemiBold.*\.ttf\|Inter.*Semi Bold.*\.ttf' | head -n 1)" assets/fonts/Inter-SemiBold.ttf
cp "$(find assets/fonts -type f | grep -i 'Inter.*Bold.*\.ttf' | head -n 1)" assets/fonts/Inter-Bold.ttf

cp "$(find assets/fonts -type f | grep -i 'JetBrainsMono.*Light.*\.ttf' | head -n 1)" assets/fonts/JetBrainsMono-Light.ttf
cp "$(find assets/fonts -type f | grep -i 'JetBrainsMono.*Regular.*\.ttf' | head -n 1)" assets/fonts/JetBrainsMono-Regular.ttf
cp "$(find assets/fonts -type f | grep -i 'JetBrainsMono.*Medium.*\.ttf' | head -n 1)" assets/fonts/JetBrainsMono-Medium.ttf

ls -la assets/fonts/
```

**Expected:** exactly these 7 files exist:
- `Inter-Regular.ttf`
- `Inter-Medium.ttf`
- `Inter-SemiBold.ttf`
- `Inter-Bold.ttf`
- `JetBrainsMono-Light.ttf`
- `JetBrainsMono-Regular.ttf`
- `JetBrainsMono-Medium.ttf`

**Step 2: Lock pubspec font paths**

Use the pubspec from v1 unchanged after the filenames above are normalized.

---

## Task 10: Scaffold the Remaining Feature File Tree

**Files:**
- Create all remaining feature/widget files referenced by the design so work can proceed file-by-file without ad hoc structure decisions.

**Step 1: Create folders**

Run:

```bash
cd /Users/nrandriantsarafara/Works/sandbox/pomodoro
mkdir -p \
  lib/features/home/widgets \
  lib/features/focus/widgets \
  lib/features/break_timer/widgets \
  lib/features/history/widgets \
  lib/features/auth/widgets \
  lib/shared/widgets \
  test/features/home \
  test/features/focus \
  test/features/break_timer \
  test/features/history \
  test/features/auth \
  test/shared/widgets
```

**Step 2: Create placeholder files so analyzer failures are localized**

Create these empty or stub files:

```text
lib/features/home/widgets/today_header.dart
lib/features/home/widgets/next_focus_hero.dart
lib/features/home/widgets/task_composer.dart
lib/features/home/widgets/post_create_affordance.dart
lib/features/home/widgets/project_dropdown.dart
lib/features/home/widgets/task_list.dart
lib/features/home/widgets/task_row.dart
lib/features/home/widgets/task_overflow_menu.dart
lib/features/home/widgets/search_filter_bar.dart
lib/features/home/widgets/empty_task_state.dart
lib/features/focus/widgets/focus_background.dart
lib/features/focus/widgets/focus_title_block.dart
lib/features/focus/widgets/focus_timer_ring.dart
lib/features/focus/widgets/focus_controls.dart
lib/features/focus/widgets/phase_label.dart
lib/features/break_timer/widgets/celebration_state.dart
lib/features/break_timer/widgets/recovery_state.dart
lib/features/break_timer/widgets/break_timer_ring.dart
lib/features/break_timer/widgets/break_actions.dart
lib/features/history/widgets/rhythm_bar_chart.dart
lib/features/history/widgets/stat_card.dart
lib/features/history/widgets/top_focus_areas.dart
lib/features/history/widgets/session_log.dart
lib/features/auth/widgets/auth_background_blobs.dart
lib/features/auth/widgets/auth_card.dart
lib/features/auth/widgets/auth_input_field.dart
lib/features/auth/widgets/shimmer_button.dart
lib/features/auth/widgets/floating_sparkles.dart
lib/shared/widgets/anchored_overlay.dart
lib/shared/widgets/fade_blur_transition.dart
lib/shared/widgets/hover_scale_icon.dart
lib/shared/widgets/animated_presence.dart
```

Each stub file can temporarily contain:

```dart
import 'package:flutter/widgets.dart';
class PlaceholderWidget extends StatelessWidget {
  const PlaceholderWidget({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
```

Replace class names appropriately only to keep the analyzer happy.

**Step 3: Commit**

```bash
git add lib/features/ lib/shared/widgets/ test/features/ test/shared/
git commit -m "chore: scaffold remaining feature and test file tree"
```

---

## Task 11: Shared Overlay and Animation Infrastructure

This task closes one of the biggest gaps in v1: anchored overlays and reusable animated presence behavior.

**Files:**
- Create: `lib/shared/widgets/anchored_overlay.dart`
- Create: `lib/shared/widgets/animated_presence.dart`
- Create: `lib/shared/widgets/fade_blur_transition.dart`
- Create: `lib/shared/widgets/hover_scale_icon.dart`
- Test: `test/shared/widgets/anchored_overlay_test.dart`

### File responsibilities

- `anchored_overlay.dart`: reusable `OverlayEntry` controller using `LayerLink`, `CompositedTransformTarget`, `CompositedTransformFollower`, backdrop dismissal, and enter/exit animation hooks.
- `animated_presence.dart`: small wrapper to mimic Motion `AnimatePresence` enter/exit in Flutter using `AnimatedSwitcher` + custom builders.
- `fade_blur_transition.dart`: reusable transition combining opacity and blur for focus/auth/break sequences.
- `hover_scale_icon.dart`: desktop-only hover scale helper for action icons.

### `anchored_overlay.dart`

**Implementation:**

```dart
import 'package:flutter/material.dart';

class AnchoredOverlayController {
  OverlayEntry? _entry;
  bool get isOpen => _entry != null;

  void show({required OverlayEntry entry}) {
    close();
    _entry = entry;
  }

  void close() {
    _entry?.remove();
    _entry = null;
  }
}

class AnchoredOverlayTarget extends StatelessWidget {
  final LayerLink link;
  final Widget child;

  const AnchoredOverlayTarget({
    super.key,
    required this.link,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(link: link, child: child);
  }
}

class AnchoredOverlayFollower extends StatelessWidget {
  final LayerLink link;
  final Offset offset;
  final Widget child;
  final Alignment targetAnchor;
  final Alignment followerAnchor;

  const AnchoredOverlayFollower({
    super.key,
    required this.link,
    required this.offset,
    required this.child,
    this.targetAnchor = Alignment.bottomLeft,
    this.followerAnchor = Alignment.topLeft,
  });

  @override
  Widget build(BuildContext context) {
    return CompositedTransformFollower(
      link: link,
      showWhenUnlinked: false,
      targetAnchor: targetAnchor,
      followerAnchor: followerAnchor,
      offset: offset,
      child: child,
    );
  }
}

OverlayEntry buildAnchoredOverlay({
  required BuildContext context,
  required LayerLink link,
  required Widget child,
  required VoidCallback onDismiss,
  Offset offset = const Offset(0, 8),
  Alignment targetAnchor = Alignment.bottomLeft,
  Alignment followerAnchor = Alignment.topLeft,
}) {
  return OverlayEntry(
    builder: (context) => Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onDismiss,
            child: const SizedBox.expand(),
          ),
        ),
        AnchoredOverlayFollower(
          link: link,
          offset: offset,
          targetAnchor: targetAnchor,
          followerAnchor: followerAnchor,
          child: Material(
            color: Colors.transparent,
            child: child,
          ),
        ),
      ],
    ),
  );
}
```

### `animated_presence.dart`

```dart
import 'package:flutter/material.dart';

class AnimatedPresence extends StatelessWidget {
  final bool visible;
  final Widget child;
  final Duration duration;
  final Widget Function(Widget child, Animation<double> animation)? transitionBuilder;

  const AnimatedPresence({
    super.key,
    required this.visible,
    required this.child,
    this.duration = const Duration(milliseconds: 200),
    this.transitionBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeOut,
      transitionBuilder: transitionBuilder ??
          (child, animation) => FadeTransition(opacity: animation, child: child),
      child: visible ? child : const SizedBox.shrink(key: ValueKey('hidden')),
    );
  }
}
```

### `fade_blur_transition.dart`

```dart
import 'dart:ui';
import 'package:flutter/material.dart';

class FadeBlurTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final double maxBlur;

  const FadeBlurTransition({
    super.key,
    required this.animation,
    required this.child,
    this.maxBlur = 8,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final blur = (1 - animation.value) * maxBlur;
        return Opacity(
          opacity: animation.value,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: child,
          ),
        );
      },
    );
  }
}
```

### `hover_scale_icon.dart`

```dart
import 'package:flutter/material.dart';

class HoverScaleIcon extends StatefulWidget {
  final Widget child;
  final double hoverScale;
  final Duration duration;
  final VoidCallback? onTap;

  const HoverScaleIcon({
    super.key,
    required this.child,
    this.hoverScale = 1.10,
    this.duration = const Duration(milliseconds: 150),
    this.onTap,
  });

  @override
  State<HoverScaleIcon> createState() => _HoverScaleIconState();
}

class _HoverScaleIconState extends State<HoverScaleIcon> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _hovered ? widget.hoverScale : 1,
          duration: widget.duration,
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}
```

### Test file

`test/shared/widgets/anchored_overlay_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhythm/shared/widgets/anchored_overlay.dart';

void main() {
  testWidgets('AnchoredOverlayTarget builds child', (tester) async {
    final link = LayerLink();
    await tester.pumpWidget(
      MaterialApp(
        home: AnchoredOverlayTarget(
          link: link,
          child: const Text('anchor'),
        ),
      ),
    );
    expect(find.text('anchor'), findsOneWidget);
  });

  testWidgets('buildAnchoredOverlay builds backdrop and child', (tester) async {
    final link = LayerLink();
    bool dismissed = false;

    late OverlayEntry entry;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              entry = buildAnchoredOverlay(
                context: context,
                link: link,
                onDismiss: () => dismissed = true,
                child: const Text('menu'),
              );
              Overlay.of(context).insert(entry);
              return AnchoredOverlayTarget(
                link: link,
                child: const SizedBox(width: 100, height: 50),
              );
            },
          ),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('menu'), findsOneWidget);

    await tester.tapAt(const Offset(1, 1));
    await tester.pump();
    expect(dismissed, true);

    entry.remove();
  });
}
```

**Run:**

```bash
flutter test test/shared/widgets/anchored_overlay_test.dart -v
```

**Commit:**

```bash
git add lib/shared/widgets/ test/shared/widgets/
git commit -m "feat: add reusable overlay and animation infrastructure"
```

---

## Task 12: Home Page — Execution-Complete Breakdown

This replaces the broad v1 Home task with deterministic sub-tasks.

### 12A. Home page container and derived state

**Files:**
- Modify: `lib/features/home/home_page.dart`
- Test: `test/features/home/home_page_test.dart`

**Required structure:**
- `HomePage extends ConsumerStatefulWidget`
- local state:
  - `TextEditingController newTaskController`
  - `FocusNode composerFocusNode`
  - `String? selectedProjectId`
  - `bool isProjectDropdownOpen`
  - `bool isAddingProject`
  - `String newProjectName`
  - `String? activePresetTaskId` (`'hero'` allowed)
  - `String? activeMenuTaskId`
  - `String searchQuery`
  - `String filterProjectId = 'all'`
  - `({String id, String title})? postCreate`
  - `Timer? postCreateTimer`
  - `LayerLink composerProjectLink`
  - `Map<String, LayerLink> presetLinks`
  - `Map<String, LayerLink> menuLinks`
- derived values from store:
  - `sortedTasks`
  - `filteredTasks`
  - `todaySessions`
  - `todayFocusTime`
  - `nextFocusTask`

**Exact behavioral rules:**
- Search/filter controls appear only when `tasks.length >= 5`
- Clear completed appears only when `tasks.any((t) => t.completed)`
- `postCreate` auto-hides after 4 seconds
- on task add, navigate start action should target the newest task by ID from `store.tasks.first`
- incomplete tasks sort before completed; within each group newest first

### 12B. TodayHeader widget

**Files:**
- Modify: `lib/features/home/widgets/today_header.dart`

**Implementation contract:**

```dart
class TodayHeader extends StatelessWidget {
  final String summary;
  const TodayHeader({super.key, required this.summary});
}
```

Renders:
- title: `Today`
- subtitle: e.g. `1h 15m focused • 3 sessions completed`

### 12C. NextFocusHero widget

**Files:**
- Modify: `lib/features/home/widgets/next_focus_hero.dart`

**Implementation contract:**

```dart
class NextFocusHero extends StatelessWidget {
  final String title;
  final int lastUsedPreset;
  final VoidCallback onStart;
  final Widget presetButton;
}
```

- use `TweenAnimationBuilder<double>` for entry
- left copy:
  - `NEXT FOCUS`
  - task title
- right controls:
  - start button text `Start {lastUsedPreset} min`
  - adjacent preset button slot

### 12D. TaskComposer widget

**Files:**
- Modify: `lib/features/home/widgets/task_composer.dart`

**Implementation contract:**

```dart
class TaskComposer extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSubmit;
  final VoidCallback onProjectTap;
  final String? selectedProjectName;
  final ProjectStyle? selectedProjectStyle;
  final bool showProjectRow;
  final bool showAddButton;
}
```

- input height 56
- white bg, border neutral-200, rounded-2xl, shadow-sm
- add button appears using `AnimatedSwitcher`
- project row below uses `AnimatedSize` + `AnimatedOpacity`
- project chip text:
  - selected project name if chosen
  - else `Add project`

### 12E. ProjectDropdown widget

**Files:**
- Modify: `lib/features/home/widgets/project_dropdown.dart`

**Implementation contract:**

```dart
class ProjectDropdown extends StatelessWidget {
  final List<Project> projects;
  final bool isAddingProject;
  final String newProjectName;
  final ValueChanged<String> onNameChanged;
  final VoidCallback onStartCreate;
  final VoidCallback onCancelCreate;
  final void Function(String? projectId) onSelectProject;
  final VoidCallback onCommitCreate;
}
```

**Rules:**
- first item: `No Project`
- second block: existing projects list
- footer button: `Create new project`
- create mode:
  - input placeholder `Project name...`
  - buttons: `Cancel` and `Add Project`
- on create: choose random style from `ProjectStyles.all`

### 12F. PostCreateAffordance widget

**Files:**
- Modify: `lib/features/home/widgets/post_create_affordance.dart`

**Implementation contract:**

```dart
class PostCreateAffordance extends StatelessWidget {
  final String title;
  final int lastUsedPreset;
  final VoidCallback onDismiss;
  final VoidCallback onStart;
}
```

- white card, rounded-xl, border, strong shadow
- left text: `"{title}" added`
- right buttons: `Dismiss` and `Start {lastUsedPreset} min`

### 12G. TaskRow widget

**Files:**
- Modify: `lib/features/home/widgets/task_row.dart`

**Implementation contract:**

```dart
class TaskRow extends StatelessWidget {
  final Task task;
  final Project? project;
  final int lastUsedPreset;
  final VoidCallback onToggle;
  final VoidCallback onStart;
  final VoidCallback onPresetTap;
  final VoidCallback onMenuTap;
}
```

**Row layout:**
- leading checkbox button
- middle text column
- trailing action group when incomplete
- completed rows hide action group

### 12H. SearchFilterBar widget

**Files:**
- Modify: `lib/features/home/widgets/search_filter_bar.dart`

**Implementation contract:**

```dart
class SearchFilterBar extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final String activeProjectId;
  final List<Project> projects;
  final ValueChanged<String> onProjectChanged;
}
```

### 12I. TaskOverflowMenu and PresetPicker wiring

**Files:**
- Modify: `lib/features/home/widgets/task_overflow_menu.dart`
- Modify: `lib/shared/widgets/preset_picker.dart`

Use `AnchoredOverlayTarget` + `buildAnchoredOverlay(...)` from Task 11.

**Overlay ownership rules:**
- `HomePage` owns open/close state
- widgets only emit callbacks
- one preset picker open at a time
- one overflow menu open at a time
- opening project dropdown closes preset/menu
- tapping backdrop closes all

### 12J. Home widget tests

`test/features/home/home_page_test.dart`

Add these tests:

```dart
testWidgets('shows seeded tasks and today heading', ...)
testWidgets('composer add button appears only when text is non-empty', ...)
testWidgets('adding task inserts at top and shows post-create affordance', ...)
testWidgets('clear completed button only appears when completed tasks exist', ...)
testWidgets('search/filter controls appear only when task count >= 5', ...)
testWidgets('checking a task marks it completed and hides action buttons', ...)
```

**Verification commands:**

```bash
flutter test test/features/home/home_page_test.dart -v
flutter analyze lib/features/home/
```

**Commit:**

```bash
git add lib/features/home/ lib/shared/widgets/preset_picker.dart test/features/home/
git commit -m "feat: implement Home page with deterministic overlay and interaction behavior"
```

---

## Task 13: Focus Timer — Deterministic State and Motion Wiring

### 13A. Exact state machine

**Files:**
- Modify: `lib/features/focus/focus_timer_page.dart`
- Test: `test/features/focus/focus_timer_page_test.dart`

**State fields:**

```dart
late final int initialTime;
late int timeLeft;
bool isActive = false;
FocusPhase phase = FocusPhase.intro;
Timer? introTimer;
Timer? ticker;
late final AnimationController titleController;
late final AnimationController timerController;
late final AnimationController controlsController;
```

```dart
enum FocusPhase { intro, active }
```

**initState order:**
1. compute `initialTime = widget.preset * 60`
2. `timeLeft = initialTime`
3. create controllers
4. `titleController.forward()` immediately
5. after 1200ms → `timerController.forward()`
6. after 2000ms → `controlsController.forward()`
7. `introTimer = Timer(2500ms, () { phase=active; isActive=true; startTicker(); })`

**Ticker rules:**
- only one ticker at a time
- `startTicker()` cancels existing ticker before creating a new one
- if paused, cancel ticker
- decrement once per second
- if `timeLeft <= 0`, cancel ticker, set to 0, call `handleComplete()` once

**handleComplete guard:**
- add `bool _completed = false;`
- early return if `_completed`
- prevents double navigation / double session save

### 13B. FocusBackground widget contract

**Files:**
- Modify: `lib/features/focus/widgets/focus_background.dart`

```dart
class FocusBackground extends StatelessWidget {
  final double progress;
  final int timeLeft;
}
```

Returns a `TweenAnimationBuilder<Decoration>` or `AnimatedContainer` with `BoxDecoration` using `RadialGradient`:
- if `progress < 0.1`: center `Alignment(0, -1)` with slate glow
- else if `timeLeft < 60`: center `Alignment(0, 1)` with indigo/violet glow
- else: center `Alignment.center` with near-flat dark gradient

### 13C. PhaseLabel widget contract

**Files:**
- Modify: `lib/features/focus/widgets/phase_label.dart`

```dart
class PhaseLabel extends StatelessWidget {
  final String text;
}
```

Use `AnimatedSwitcher` with key based on `text`.

### 13D. FocusTimerRing widget contract

**Files:**
- Modify: `lib/features/focus/widgets/focus_timer_ring.dart`

```dart
class FocusTimerRing extends StatelessWidget {
  final int timeLeft;
  final int initialTime;
  final bool showProgress;
}
```

Derived:
- progress = `(initialTime - timeLeft) / initialTime`
- active color amber if `timeLeft < 60`, else white
- timer text amber + weight medium if final minute, else white + weight light

### 13E. FocusControls widget contract

**Files:**
- Modify: `lib/features/focus/widgets/focus_controls.dart`

```dart
class FocusControls extends StatelessWidget {
  final bool isActive;
  final bool disabled;
  final VoidCallback onPrimary;
  final VoidCallback onAbandon;
  final VoidCallback onSaveEnd;
  final Animation<double> animation;
}
```

Primary label logic:
- active → `Pause`
- inactive but not disabled → `Resume`

### 13F. Focus tests

`test/features/focus/focus_timer_page_test.dart`

Add:

```dart
testWidgets('redirects home when task does not exist', ...)
testWidgets('starts in intro and enables controls after 2500ms', ...)
testWidgets('timer decrements once active', ...)
testWidgets('pause stops decrementing and resume restarts', ...)
testWidgets('save and end records partial session and navigates to break', ...)
```

Use `fakeAsync` or `tester.pump(const Duration(...))` to advance time.

**Run:**

```bash
flutter test test/features/focus/focus_timer_page_test.dart -v
flutter analyze lib/features/focus/
```

**Commit:**

```bash
git add lib/features/focus/ test/features/focus/
git commit -m "feat: implement Focus timer with guarded state machine and timer tests"
```

---

## Task 14: Break Timer — Deterministic State and Transition Wiring

### 14A. Exact state machine

**Files:**
- Modify: `lib/features/break_timer/break_timer_page.dart`
- Test: `test/features/break_timer/break_timer_page_test.dart`

**State fields:**

```dart
late final int initialTime;
late int timeLeft;
late BreakPhase phase;
Timer? celebrationTimer;
Timer? ticker;
late final AnimationController pageController;
late final AnimationController recoveryActionsController;
```

```dart
enum BreakPhase { celebration, recovery }
```

**Rules:**
- if `widget.justCompleted == true`, start in celebration
- celebration auto-switches to recovery after 3500ms
- if `widget.justCompleted == false`, skip celebration entirely
- recovery ticker decrements every second
- timeLeft hitting 0 goes home exactly once

### 14B. CelebrationState contract

**Files:**
- Modify: `lib/features/break_timer/widgets/celebration_state.dart`

```dart
class CelebrationState extends StatelessWidget {
  final int breakMinutes;
}
```

Contains success circle, title, subtitle only.

### 14C. RecoveryState contract

**Files:**
- Modify: `lib/features/break_timer/widgets/recovery_state.dart`

```dart
class RecoveryState extends StatelessWidget {
  final Task? task;
  final int timeLeft;
  final int initialTime;
  final Widget actions;
}
```

### 14D. BreakActions contract

**Files:**
- Modify: `lib/features/break_timer/widgets/break_actions.dart`

```dart
class BreakActions extends StatelessWidget {
  final Task? task;
  final bool hasContinuePrimary;
  final VoidCallback onContinue;
  final VoidCallback onBack;
}
```

### 14E. Break tests

Add:

```dart
testWidgets('starts in celebration when completed=true', ...)
testWidgets('skips celebration when completed=false', ...)
testWidgets('switches to recovery after 3500ms', ...)
testWidgets('recovery timer decrements and returns home at zero', ...)
testWidgets('continue task navigates to focus with lastUsedPreset', ...)
```

**Run:**

```bash
flutter test test/features/break_timer/break_timer_page_test.dart -v
flutter analyze lib/features/break_timer/
```

**Commit:**

```bash
git add lib/features/break_timer/ test/features/break_timer/
git commit -m "feat: implement Break timer with deterministic celebration and recovery flow"
```

---

## Task 15: History Page — Exact Calculation Ownership and Tests

### 15A. Calculation helper extraction

Move all history calculations into pure functions so the page stays dumb and testable.

**Files:**
- Create: `lib/features/history/history_calculations.dart`
- Modify: `lib/features/history/history_page.dart`
- Test: `test/features/history/history_calculations_test.dart`

**Create pure helpers:**
- `buildRhythmData(List<Session>)`
- `buildTopTaskStats(List<Session>, List<Task>, List<Project>)`
- `groupSessionsByDayLabel(List<Session>)`
- `totalFocusSeconds(List<Session>)`

### 15B. Test coverage

`test/features/history/history_calculations_test.dart`

Add:

```dart
test('buildRhythmData returns 7 days with minimum visual height logic source data intact', ...)
test('top task stats prefer current task title when task still exists', ...)
test('top task stats fallback to snapshot when task deleted', ...)
test('groupSessionsByDayLabel uses Today / Yesterday / date labels', ...)
test('totalFocusSeconds sums duration correctly', ...)
```

### 15C. History page widget tests

`test/features/history/history_page_test.dart`

Add:

```dart
testWidgets('renders Your Rhythm heading and stat cards', ...)
testWidgets('renders session log grouped sections', ...)
testWidgets('renders empty state when no sessions exist', ...)
```

**Run:**

```bash
flutter test test/features/history/ -v
flutter analyze lib/features/history/
```

**Commit:**

```bash
git add lib/features/history/ test/features/history/
git commit -m "feat: extract and test History calculations with page widgets"
```

---

## Task 16: Auth Page — Exact Controller Ownership and Test Matrix

### 16A. Auth page state contract

**Files:**
- Modify: `lib/features/auth/auth_page.dart`
- Test: `test/features/auth/auth_page_test.dart`

**State fields:**
- `bool isSignUp`
- `bool isLoading`
- `String focusedField`
- controllers: email, password, name
- animation controllers:
  - `blobAController`
  - `blobBController`
  - `cardController`
  - `sparklePulseController`
  - `shimmerController`
  - `spinnerController`

**Ownership rules:**
- `AuthPage` owns page-level mode and loading state
- `ShimmerButton` may own only hover animation if needed, but loading state stays in parent
- `AuthCard` must not perform navigation directly; parent handles submit result

### 16B. Testable behavior checklist

`test/features/auth/auth_page_test.dart`

Add:

```dart
testWidgets('shows sign in copy by default', ...)
testWidgets('toggle switches to sign up copy and reveals name field', ...)
testWidgets('submit shows loading spinner then returns to normal', ...)
testWidgets('name field absent in sign in mode', ...)
testWidgets('sparkles only render on wide layouts in sign up mode', ...)
```

For wide layout tests, wrap with a custom `MediaQuery` width ≥ 1024.

### 16C. Auth input field contract

**Files:**
- Modify: `lib/features/auth/widgets/auth_input_field.dart`

```dart
class AuthInputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final IconData icon;
  final bool obscureText;
}
```

Focus style must be implemented with `AnimatedContainer` based on `focusNode.hasFocus` listened via `Focus` widget or `ValueListenableBuilder`.

### 16D. ShimmerButton contract

**Files:**
- Modify: `lib/features/auth/widgets/shimmer_button.dart`

```dart
class ShimmerButton extends StatelessWidget {
  final bool isLoading;
  final String label;
  final VoidCallback onPressed;
}
```

If hover shimmer requires controller ownership, convert to StatefulWidget but keep API above.

**Run:**

```bash
flutter test test/features/auth/auth_page_test.dart -v
flutter analyze lib/features/auth/
```

**Commit:**

```bash
git add lib/features/auth/ test/features/auth/
git commit -m "feat: implement Auth page with explicit controller ownership and widget tests"
```

---

## Task 17: Golden-Path Widget Tests for Shell and Navigation

This closes a major verification gap left in v1.

**Files:**
- Create: `test/features/layout/app_shell_test.dart`

Add:

```dart
testWidgets('desktop shell renders header nav and no bottom nav', ...)
testWidgets('mobile shell renders header and bottom nav', ...)
testWidgets('mobile tab indicator switches with route', ...)
```

Use a test harness with configurable `MediaQuery` width and `GoRouter` initial route.

**Run:**

```bash
flutter test test/features/layout/app_shell_test.dart -v
```

**Commit:**

```bash
git add test/features/layout/
git commit -m "test: add app shell navigation tests for desktop and mobile layouts"
```

---

## Task 18: Final Verification — Automated First, Manual Second

This replaces the mostly manual v1 verification.

### 18A. Automated gates

Run these and do not claim completion unless all pass:

```bash
cd /Users/nrandriantsarafara/Works/sandbox/pomodoro
flutter analyze
flutter test
```

Expected:
- `flutter analyze` returns exit code 0
- `flutter test` returns exit code 0

### 18B. Manual fidelity pass

Then verify on at least:
- one desktop/web target
- one mobile-size target

Checklist:
- [ ] Home content enters with fade + slight rise
- [ ] Mobile bottom indicator moves smoothly between tabs
- [ ] Next Focus hero appears only when there is an incomplete task
- [ ] Add button only appears while typing
- [ ] Project row expands under composer only while composing and no post-create card visible
- [ ] Project dropdown anchors below composer and dismisses via backdrop tap
- [ ] Preset picker anchors below trigger and dismisses via backdrop tap
- [ ] Task row overflow menu anchors correctly
- [ ] Completed task rows visually desaturate and line-through title
- [ ] Focus intro title arrives before timer and controls
- [ ] Focus phase switches to active at 2500ms and timer starts automatically
- [ ] Focus label changes: Settling in → Deep focus → Final stretch
- [ ] Focus ring turns amber in final minute
- [ ] Break celebration lasts 3500ms before recovery
- [ ] Continue task uses lastUsedPreset
- [ ] History bars animate upward with stagger
- [ ] Auth blobs pulse continuously and subtly
- [ ] Auth title/description/name-field transitions animate correctly
- [ ] Shimmer button behaves on hover, loading spinner replaces label on submit

### 18C. Completion commit

```bash
git add -A
git commit -m "feat: complete Rhythm Flutter rebuild with verified routes, state, and motion fidelity"
```

---

## Compact Execution Order

1. Keep v1 Tasks 1–9
2. Execute v2 Tasks 10–18
3. Only then claim completion

---

## Why this v2 is tighter

This version closes the main gaps from v1 by adding:
- deterministic font filenames
- explicit overlay ownership and infrastructure
- exact state fields and controller ownership for Focus/Break/Auth
- pure calculation extraction for History
- widget test matrices for Home, Focus, Break, History, Auth, and Shell
- automated completion gates instead of mostly manual signoff
