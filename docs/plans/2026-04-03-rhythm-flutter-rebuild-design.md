# Rhythm — Flutter Rebuild Design

**Date:** 2026-04-03
**Status:** Approved
**Source:** React + Tailwind + Motion prototype at ~/Downloads/pomodoro.zip

---

## 1. Product Understanding

Rhythm is a task-centered Pomodoro focus app. Tasks are the primary object. Projects are optional metadata for grouping. Focus sessions attach to tasks. The core loop: capture task → enter immersive focus → exit gently into break → reflect on progress.

What it is NOT: not a project manager, not a habit tracker, not gamified, not collaborative.

Focus and Break are immersive full-screen states because they mark a psychological transition — the user is "in" now.

---

## 2. Architecture

### Folder Structure

```
lib/
├── main.dart
├── app.dart
├── router/
│   └── app_router.dart
├── theme/
│   ├── app_theme.dart
│   ├── app_colors.dart
│   ├── app_typography.dart
│   ├── app_spacing.dart
│   ├── app_radii.dart
│   ├── app_shadows.dart
│   └── app_motion.dart
├── models/
│   ├── project.dart
│   ├── task.dart
│   └── session.dart
├── repositories/
│   ├── task_repository.dart
│   ├── project_repository.dart
│   ├── session_repository.dart
│   └── auth_repository.dart
├── store/
│   ├── app_store.dart
│   └── providers.dart
├── shared/
│   ├── widgets/
│   │   ├── app_icon.dart
│   │   ├── progress_ring.dart
│   │   ├── preset_picker.dart
│   │   ├── project_badge.dart
│   │   ├── animated_dropdown.dart
│   │   ├── press_scale_button.dart
│   │   └── page_entry_animation.dart
│   └── utils/
│       ├── date_helpers.dart
│       └── format_helpers.dart
├── features/
│   ├── layout/
│   │   ├── app_shell.dart
│   │   ├── desktop_header.dart
│   │   ├── mobile_header.dart
│   │   └── mobile_bottom_nav.dart
│   ├── home/
│   │   ├── home_page.dart
│   │   └── widgets/
│   │       ├── today_header.dart
│   │       ├── next_focus_hero.dart
│   │       ├── task_composer.dart
│   │       ├── post_create_affordance.dart
│   │       ├── project_dropdown.dart
│   │       ├── task_list.dart
│   │       ├── task_row.dart
│   │       ├── task_overflow_menu.dart
│   │       ├── search_filter_bar.dart
│   │       └── empty_task_state.dart
│   ├── focus/
│   │   ├── focus_timer_page.dart
│   │   └── widgets/
│   │       ├── focus_background.dart
│   │       ├── focus_title_block.dart
│   │       ├── focus_timer_ring.dart
│   │       ├── focus_controls.dart
│   │       └── phase_label.dart
│   ├── break_timer/
│   │   ├── break_timer_page.dart
│   │   └── widgets/
│   │       ├── celebration_state.dart
│   │       ├── recovery_state.dart
│   │       ├── break_timer_ring.dart
│   │       └── break_actions.dart
│   ├── history/
│   │   ├── history_page.dart
│   │   └── widgets/
│   │       ├── rhythm_bar_chart.dart
│   │       ├── stat_card.dart
│   │       ├── top_focus_areas.dart
│   │       └── session_log.dart
│   └── auth/
│       ├── auth_page.dart
│       └── widgets/
│           ├── auth_background_blobs.dart
│           ├── auth_card.dart
│           ├── auth_input_field.dart
│           ├── shimmer_button.dart
│           └── floating_sparkles.dart
```

### Chunk Boundaries

| Chunk | Purpose | Dependencies | Independent |
|---|---|---|---|
| Theme tokens | Colors, typography, spacing, radii, shadows, motion curves | None | Yes |
| Models | Project, Task, Session data classes | None | Yes |
| Repositories | Abstract interfaces + InMemory implementations | Models | Yes |
| Store + Providers | AppStore ChangeNotifier, Riverpod providers | Repositories | After repos |
| Router | go_router config, ShellRoute, standalone routes | Theme, store | After store |
| App Shell | Desktop header, mobile header, mobile bottom nav | Theme, router | After router |
| Shared widgets | ProgressRing, PresetPicker, ProjectBadge, PressScaleButton, PageEntryAnimation | Theme | After theme |
| Home | Task list page, composer, hero, all overlays | Store, shared | After store + shared |
| Focus Timer | Immersive dark screen, intro ceremony, timer ring | Store, shared | After store + shared |
| Break Timer | Light immersive screen, celebration/recovery | Store, shared | After store + shared |
| History | Bar chart, stats, session log | Store, theme | After store |
| Auth | Glass card, blobs, field animations, shimmer | Store, theme | After store + theme |

---

## 3. Routes and Navigation

```dart
GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (_, __) => const HomePage()),
        GoRoute(path: '/history', builder: (_, __) => const HistoryPage()),
        GoRoute(path: '/auth', builder: (_, __) => const AuthPage()),
      ],
    ),
    GoRoute(
      path: '/focus/:taskId',
      builder: (_, state) => FocusTimerPage(
        taskId: state.pathParameters['taskId']!,
        preset: int.parse(state.uri.queryParameters['preset'] ?? '25'),
      ),
    ),
    GoRoute(
      path: '/break/:taskId',
      builder: (_, state) => BreakTimerPage(
        taskId: state.pathParameters['taskId']!,
        breakMinutes: int.parse(state.uri.queryParameters['mins'] ?? '5'),
        justCompleted: state.uri.queryParameters['completed'] == 'true',
      ),
    ),
  ],
)
```

- Home, History, Auth inside AppShell (header + optional bottom nav)
- Focus and Break are top-level — no shell, full-screen immersive
- No page transition animation for shell tab switches
- Focus/Break use fade transition

---

## 4. Data Model

```dart
class ProjectStyle {
  final Color background;
  final Color foreground;
}

class Project {
  final String id;
  final String name;
  final ProjectStyle style;
}

class Task {
  final String id;
  final String title;
  final String? projectId;
  final bool completed;
  final DateTime createdAt;
}

class Session {
  final String id;
  final String taskId;
  final String taskTitle;          // snapshot
  final String? projectName;       // snapshot
  final ProjectStyle? projectStyle; // snapshot
  final int preset;                // 25 | 50 | 90
  final int duration;              // seconds
  final DateTime completedAt;
}
```

### Predefined Project Styles

| Name | Background | Foreground |
|---|---|---|
| Blue | #DBEAFE | #1D4ED8 |
| Emerald | #D1FAE5 | #047857 |
| Purple | #F3E8FF | #7E22CE |
| Amber | #FEF3C7 | #B45309 |
| Rose | #FFE4E6 | #BE123C |
| Indigo | #E0E7FF | #4338CA |

### Initial Seed Data

Projects: Design (blue), Dev (emerald)
Tasks: "Wireframe user profile" (Design), "Fix navigation bug" (Dev), "Read email backlog" (no project)
Sessions: 2 seeded sessions matching prototype

---

## 5. State Management — Riverpod

```dart
// Repository providers — overridable for persistence swap
final taskRepositoryProvider = Provider<TaskRepository>(
  (ref) => InMemoryTaskRepository(),
);
final projectRepositoryProvider = Provider<ProjectRepository>(
  (ref) => InMemoryProjectRepository(),
);
final sessionRepositoryProvider = Provider<SessionRepository>(
  (ref) => InMemorySessionRepository(),
);
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => MockAuthRepository(),
);

// App store
final appStoreProvider = ChangeNotifierProvider<AppStore>((ref) {
  return AppStore(
    taskRepo: ref.watch(taskRepositoryProvider),
    projectRepo: ref.watch(projectRepositoryProvider),
    sessionRepo: ref.watch(sessionRepositoryProvider),
  );
});
```

### App-Level State (AppStore)
- projects, tasks, sessions, lastUsedPreset
- Methods: addTask, toggleTask, deleteTask, addProject, addSession, setLastUsedPreset

### Screen-Local State
- Home: composer text, dropdown states, search/filter, post-create affordance
- Focus: timeLeft, isActive, phase, AnimationControllers
- Break: timeLeft, phase, AnimationControllers
- Auth: isSignUp, fields, isLoading, focusedField

### Timer Safety
- Timer.periodic + Timer for delays — all cancelled in dispose()
- All AnimationControllers created in initState(), disposed in dispose()
- TickerProviderStateMixin on StatefulWidget for multiple controllers
- Navigation away → dispose() fires → cleanup guaranteed

### Persistence Swap
```dart
ProviderScope(
  overrides: [
    taskRepositoryProvider.overrideWithValue(SqliteTaskRepository()),
    sessionRepositoryProvider.overrideWithValue(SqliteSessionRepository()),
    authRepositoryProvider.overrideWithValue(FirebaseAuthRepository()),
  ],
  child: App(),
)
```

---

## 6. Visual Design Tokens

### Colors
```
background:       #FAFAFA
surface:          #FFFFFF
surfaceBorder:    #E5E5E5
textPrimary:      #171717   (neutral-900)
textSecondary:    #737373   (neutral-500)
textTertiary:     #A3A3A3   (neutral-400)
textMuted:        #D4D4D4   (neutral-300)
focusBg:          #0A0A0A   (neutral-950)
focusSurface:     #171717   (neutral-900)
focusBorder:      #262626   (neutral-800)
focusAmber:       #FBBF24   (amber-400)
breakBg:          #FAFAFA   (neutral-50)
successBg:        #D1FAE5   (emerald-100)
successFg:        #059669   (emerald-600)
destructive:      #DC2626   (red-600)
destructiveBg:    #FEF2F2   (red-50)
```

### Typography
- Font: Inter (all UI text)
- Mono: JetBrains Mono (timer numerals)
- Heading 2xl: 24px, w600, -0.5 tracking
- Body base: 15px, w500
- Body sm: 14px, w500
- Body xs: 12px, w600
- Label uppercase: 11px, w600, 1.2px tracking
- Timer large: 72px mono, w300, -2 tracking, tabular figures
- Timer medium: 56px mono, w300

### Spacing
xs=4, sm=8, md=12, lg=16, xl=20, xxl=24, xxxl=32, huge=48

### Radii
sm=8, md=12, lg=16, xl=20, xxl=24, xxxl=32, full=999

### Shadows
- sm: black 5%, blur 4, offset (0,1)
- md: black 6%, blur 8, offset (0,4)
- lg: black 8%, blur 16, offset (0,8)
- xl: black 6%, blur 32, offset (0,8)

### Motion
- smoothCurve: Cubic(0.16, 1, 0.3, 1)
- focusIntroCurve: Cubic(0.2, 0.9, 0.4, 1)
- Durations: instant=100ms, fast=150ms, normal=200ms, medium=300ms, slow=500ms, slower=800ms
- Intro: titleDuration=1200ms, timerDuration=1500ms, controlsDuration=1000ms
- Delays: introPhase=2500ms, celebration=3500ms, postCreateAutoHide=4000ms

---

## 7. Layout and Responsive Behavior

Breakpoint: 768px

### Desktop (≥768px)
- Sticky header: white/80 + backdrop blur + border-b
- Left: 32px dark rounded icon + "Rhythm" semibold
- Center: segmented nav pill (neutral-100 bg, rounded-2xl), active = white + shadow
- Right: "Sign In" button
- Content: max-width 896px, centered, 32px horizontal padding

### Mobile (<768px)
- Compact header: fafafa/90 + backdrop blur
- Left: 28px icon + "Rhythm"
- Right: compact "Sign In"
- Bottom tab bar: white, top border, 64px + safe area, 2 tabs (Focus + Rhythm)
- Active tab: animated black pill indicator at top, AnimatedPositioned ~225ms
- Content: 20px padding, 96px bottom padding

---

## 8. Animation Specification

### Global Page Entry (Home, History)
- TweenAnimationBuilder: opacity 0→1, translateY 16→0, 500ms, easeOut

### Mobile Tab Indicator
- AnimatedPositioned inside Stack, 225ms, easeInOut

### Home — Next Focus Hero
- TweenAnimationBuilder: opacity 0→1, translateY 10→0, 300ms

### Home — Composer Add Button
- AnimatedScale + AnimatedOpacity via AnimatedSwitcher
- Enter: 0.8→1 scale, 0→1 opacity, 200ms
- Exit: 1→0.8, 1→0, 170ms

### Home — Project Row Under Input
- AnimatedSize + AnimatedOpacity, 225ms, ClipRect

### Home — Post-Create Affordance
- AnimationController: opacity 0→1, translateY -10→0, scale 0.95→1, 220ms
- Exit: opacity→0, scale→0.95, 180ms. Auto-hide after 4s.

### Home — Project Dropdown
- AnimationController: opacity 0→1, translateY 10→0, scale 0.95→1, 150ms
- Exit: opacity→0, scale→0.95, translateY→5, 150ms
- Anchored via CompositedTransformTarget/Follower + OverlayEntry

### Home — Preset Picker
- Same as project dropdown. Origin top-right.
- Enter/exit 150ms.

### Home — Task List Items
- Enter: opacity 0→1, translateY 10→0, 225ms
- Exit: opacity→0, scale→0.95, 200ms
- Press: AnimatedScale to 0.99

### Home — Overflow Menu
- AnimationController: opacity/scale, 100ms enter/exit
- OverlayEntry anchored top-right

### Focus — Atmospheric Background
- AnimatedContainer with RadialGradient, 3s transitions
- Gradient changes based on progress and timeLeft

### Focus — Title Block
- AnimationController 1200ms, focusIntroCurve
- FadeTransition + SlideTransition + blur 8→0 via TweenAnimationBuilder

### Focus — Project Badge
- FadeTransition, 800ms delay, 1000ms duration

### Focus — Phase Label
- AnimatedSwitcher: incoming translateY 5→0 + fade, outgoing translateY 0→-5 + fade, 800ms

### Focus — Timer Block
- AnimationController 1200ms delay, 1500ms duration
- ScaleTransition 0.95→1 + FadeTransition + blur 4→0, easeOut

### Focus — Progress Ring
- CustomPainter: drawArc with sweep angle from progress
- Background ring: full circle, neutral-900, 3px
- Active ring: animated sweep, white→amber at final minute, rounded cap
- Animated via AnimatedBuilder + Tween, 1s linear per update
- Ring rotated -90° (start at top)

### Focus — Controls Block
- 2000ms delay, 1000ms duration. FadeTransition + SlideTransition translateY 20→0.

### Focus — Pause/Resume
- AnimatedContainer for color. AnimatedScale 0.98 on press. AnimatedSwitcher for icon swap.

### Break — Screen Entry
- FadeTransition 700ms

### Break — Celebration Container
- Enter: translateY 20→0, opacity 0→1, 800ms easeOut
- Exit: translateY 0→-20, opacity→0, blur 0→10, 700ms

### Break — Success Icon
- 300ms delay, ScaleTransition 0.8→1 with elasticOut, FadeTransition

### Break — Title/Subtitle
- Staggered FadeTransition + SlideTransition at 600ms, 1200ms

### Break — Recovery Container
- FadeTransition + ScaleTransition 0.95→1 + blur 8→0, 1200ms easeOut

### Break — Recovery Ring
- CustomPainter, same pattern as focus. neutral-200 bg, neutral-800 active, 4px stroke.

### Break — Bottom Actions
- SlideTransition translateY 20→0 + FadeTransition, 500ms delay, 800ms duration

### History — Rhythm Bars
- Per bar: TweenAnimationBuilder 0→targetHeight, 800ms, delay index×100ms
- Curve: easeOutBack (mild). Today bar darker fill. Zero bars: 4% min height.
- Tooltip: MouseRegion + AnimatedOpacity 150ms

### History — Stat Cards
- TweenAnimationBuilder: opacity 0→1, scale 0.95→1, 400ms

### History — Top Focus Areas / Session Log
- Per row: opacity 0→1, translateY 10→0
- Delay: index×100ms (areas), groupIndex×100ms + rowIndex×50ms (log)

### Auth — Background Blobs
- Two AnimationControllers with repeat(reverse: true)
- Blob A: scale 1↔1.1, opacity 0.3↔0.4, 8s, easeInOut
- Blob B: scale 1↔1.2, opacity 0.2↔0.3, 10s, easeInOut, 1s delay
- Large circular Container + ImageFiltered blur

### Auth — Main Container
- AnimationController 500ms, smoothCurve. FadeTransition + ScaleTransition 0.98→1.
- Children staggered 100ms apart using Interval curves.

### Auth — Title Switch
- AnimatedSwitcher 300ms: outgoing translateY 0→-10 + fade, incoming translateY 10→0 + fade

### Auth — Description Switch
- AnimatedSwitcher 300ms: outgoing fade + blur 0→4, incoming fade + blur 4→0

### Auth — Name Field Reveal
- AnimatedSize + AnimatedOpacity + AnimatedScale, 350ms, smoothCurve, ClipRect

### Auth — Input Focus
- AnimatedContainer for border/shadow/background, 300ms

### Auth — Shimmer Button
- ShaderMask + animated LinearGradient, 1.5s repeat while hovered
- Hover: shadow increase + translate(0, -2). Press: return to rest.

### Auth — Loading Spinner
- RotationTransition + AnimationController repeat, 1s, linear

### Auth — Submit Label Switch
- AnimatedSwitcher: translateY 5↔-5 + fade, 200ms

### Auth — Mode Switch Underline
- MouseRegion + AnimatedScale scaleX 0→1, 300ms easeOut

### Auth — Floating Sparkles
- AnimatedOpacity + AnimatedScale 0.8→1. Pulse via AnimationController repeat.
- Visible only when isSignUp && isLargeScreen.

---

## 9. Timer Behavior

### Focus
1. Read taskId from path, preset from query (default 25)
2. initialTime = preset × 60, timeLeft = initialTime
3. phase = intro, isActive = false
4. After 2500ms: phase = active, isActive = true, timer starts
5. Timer.periodic(1s): if active && timeLeft > 0, decrement
6. timeLeft == 0: save session (duration = initialTime), derive break (25→5, 50→10, 90→20), navigate to break with completed=true
7. Pause: isActive = false. Resume: isActive = true.
8. Abandon: navigate home, no session saved.
9. Save & End: save session with actual focused duration (initialTime - timeLeft), navigate to break.

### Break
1. Read taskId, mins, completed from route
2. initialTime = mins × 60, timeLeft = initialTime
3. phase = completed ? celebration : recovery
4. Celebration: after 3500ms → phase = recovery
5. Recovery: Timer.periodic(1s), decrement. timeLeft == 0 → navigate home.
6. Continue task: navigate /focus/$taskId?preset=$lastUsedPreset
7. Back to tasks: navigate home

---

## 10. History Calculations

- totalSessions = sessions.length
- totalSeconds = sum of all session durations
- 7-day rhythm: last 7 calendar days, sum duration per day, max(mins, 1)
- Top tasks: group sessions by taskId, use current title if task exists else snapshot, sort by duration desc, take 5
- Session log: group by date label (Today / Yesterday / formatted date)

---

## 11. Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.6.1
  go_router: ^14.0.0
  lucide_icons: ^0.257.0
  intl: ^0.19.0
```

Fonts: Inter + JetBrains Mono bundled as assets.

---

## 12. Implementation Order

| Phase | Chunk |
|---|---|
| 1 | Theme tokens, fonts, app shell, routing |
| 2 | Models, repositories, AppStore, Riverpod providers |
| 3 | Home page static layout |
| 4 | Home task interactions and overlays |
| 5 | Focus timer screen + intro ceremony |
| 6 | Break timer screen + celebration/recovery |
| 7 | History page + chart + log animations |
| 8 | Auth page + glass card + advanced motion |
| 9 | Responsive tuning, hover states, final fidelity pass |

---

## 13. Risks and Mitigations

| Risk | Mitigation |
|---|---|
| Blur animation perf (intro, auth) | TweenAnimationBuilder for blur sigma; test on web; fallback to opacity-only |
| Anchored overlay positioning | CompositedTransformFollower with Offset tuning |
| Mobile tab shared indicator | AnimatedPositioned calculating offset from index × tab width |
| AnimatedList reflow on filter | Rebuild with keys; fallback to ListView + TweenAnimationBuilder per item |
| Auth shimmer on web | ShaderMask with gradient; verify perf on mobile web |
| Timer drift over 90min | Timer.periodic sufficient for UI; compare against DateTime if needed |
| Route param validation | Fallback defaults, redirect to / if taskId not found |

---

## 14. Documentation Intent

- This design doc is a **temporary working artifact** in docs/plans/
- If the build completes successfully, the following should become permanent docs:
  - Theme token reference (AppColors, AppTypography, AppMotion values)
  - Repository interface contracts
  - Route structure
- The rest of this doc can be deleted after implementation
