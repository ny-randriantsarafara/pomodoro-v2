# Rhythm Flutter Rebuild — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Faithfully rebuild the Rhythm Pomodoro app in Flutter from the React + Tailwind + Motion prototype, preserving all layouts, interactions, and animations.

**Architecture:** Feature-based folder structure. Riverpod for state. go_router for routing. Repository pattern for persistence-readiness. CustomPainter for timer rings. Staggered AnimationControllers for ceremonial sequences.

**Tech Stack:** Flutter, Dart, flutter_riverpod, go_router, lucide_icons, intl, Inter + JetBrains Mono fonts

## Documentation and Artifact Disposition

- **Temporary artifacts:** `docs/plans/2026-04-03-rhythm-flutter-rebuild-design.md`, `docs/plans/2026-04-03-rhythm-flutter-implementation.md`
- **Promote if validated:** Theme token reference → README.md, Repository contracts → README.md, Route structure → README.md
- **Delete if not durable:** Both plan files after successful implementation

---

## Pre-requisites

Before starting, download the fonts:

```bash
cd /Users/nrandriantsarafara/Works/sandbox/pomodoro
mkdir -p assets/fonts

# Download Inter
curl -L "https://github.com/rsms/inter/releases/download/v4.1/Inter-4.1.zip" -o /tmp/inter.zip
unzip -o /tmp/inter.zip -d /tmp/inter
cp /tmp/inter/Inter.ttc assets/fonts/ 2>/dev/null || cp /tmp/inter/InterVariable.ttf assets/fonts/ 2>/dev/null || find /tmp/inter -name "Inter-*.ttf" -exec cp {} assets/fonts/ \;

# Download JetBrains Mono
curl -L "https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip" -o /tmp/jbmono.zip
unzip -o /tmp/jbmono.zip -d /tmp/jbmono
cp /tmp/jbmono/fonts/ttf/JetBrainsMono-Light.ttf assets/fonts/
cp /tmp/jbmono/fonts/ttf/JetBrainsMono-Regular.ttf assets/fonts/
cp /tmp/jbmono/fonts/ttf/JetBrainsMono-Medium.ttf assets/fonts/
```

If exact URLs have changed, find the latest release and download. We need:
- Inter: Regular (400), Medium (500), SemiBold (600), Bold (700)
- JetBrains Mono: Light (300), Regular (400), Medium (500)

---

## Task 1: Project Setup — pubspec.yaml and fonts

**Files:**
- Modify: `pubspec.yaml`

**Step 1: Update pubspec.yaml with dependencies and font declarations**

Replace the entire contents of `pubspec.yaml` with:

```yaml
name: rhythm
description: "A task-centered Pomodoro focus app."
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.10.7

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.6.1
  go_router: ^14.0.0
  lucide_icons: ^0.257.0
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0

flutter:
  uses-material-design: true

  assets:
    - assets/fonts/

  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
          weight: 400
        - asset: assets/fonts/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
    - family: JetBrainsMono
      fonts:
        - asset: assets/fonts/JetBrainsMono-Light.ttf
          weight: 300
        - asset: assets/fonts/JetBrainsMono-Regular.ttf
          weight: 400
        - asset: assets/fonts/JetBrainsMono-Medium.ttf
          weight: 500
```

Note: The exact font file names may differ depending on the downloaded version. Adjust the `asset:` paths to match what's actually in `assets/fonts/`. Use `ls assets/fonts/` to verify. If Inter comes as variable font (InterVariable.ttf or Inter.ttc), you'll need to extract or use static versions. Search for "Inter static" in the zip.

**Step 2: Run flutter pub get**

```bash
cd /Users/nrandriantsarafara/Works/sandbox/pomodoro
flutter pub get
```

Expected: Resolves all dependencies without error.

**Step 3: Commit**

```bash
git add pubspec.yaml pubspec.lock assets/
git commit -m "chore: setup dependencies, fonts, and project config"
```

---

## Task 2: Theme — Design Tokens

**Files:**
- Create: `lib/theme/app_colors.dart`
- Create: `lib/theme/app_typography.dart`
- Create: `lib/theme/app_spacing.dart`
- Create: `lib/theme/app_radii.dart`
- Create: `lib/theme/app_shadows.dart`
- Create: `lib/theme/app_motion.dart`
- Create: `lib/theme/app_theme.dart`

**Step 1: Create app_colors.dart**

```dart
import 'dart:ui';

class AppColors {
  AppColors._();

  // Surfaces
  static const background = Color(0xFFFAFAFA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceBorder = Color(0xFFE5E5E5);
  static const surfaceBorderLight = Color(0xFFF5F5F5);

  // Text
  static const textPrimary = Color(0xFF171717);
  static const textSecondary = Color(0xFF737373);
  static const textTertiary = Color(0xFFA3A3A3);
  static const textMuted = Color(0xFFD4D4D4);

  // Neutral scale
  static const neutral50 = Color(0xFFFAFAFA);
  static const neutral100 = Color(0xFFF5F5F5);
  static const neutral200 = Color(0xFFE5E5E5);
  static const neutral300 = Color(0xFFD4D4D4);
  static const neutral400 = Color(0xFFA3A3A3);
  static const neutral500 = Color(0xFF737373);
  static const neutral600 = Color(0xFF525252);
  static const neutral700 = Color(0xFF404040);
  static const neutral800 = Color(0xFF262626);
  static const neutral900 = Color(0xFF171717);
  static const neutral950 = Color(0xFF0A0A0A);

  // Focus screen
  static const focusBg = Color(0xFF0A0A0A);
  static const focusSurface = Color(0xFF171717);
  static const focusBorder = Color(0xFF262626);
  static const focusRingBg = Color(0xFF171717);
  static const focusAmber = Color(0xFFFBBF24);

  // Break screen
  static const breakBg = Color(0xFFFAFAFA);

  // Success
  static const successBg = Color(0xFFD1FAE5);
  static const successFg = Color(0xFF059669);
  static const successShadow = Color(0x30D1FAE5);

  // Destructive
  static const destructive = Color(0xFFDC2626);
  static const destructiveBg = Color(0xFFFEF2F2);
  static const destructiveBorder = Color(0xFFFECACA);

  // Project palette
  static const blueBg = Color(0xFFDBEAFE);
  static const blueFg = Color(0xFF1D4ED8);
  static const emeraldBg = Color(0xFFD1FAE5);
  static const emeraldFg = Color(0xFF047857);
  static const purpleBg = Color(0xFFF3E8FF);
  static const purpleFg = Color(0xFF7E22CE);
  static const amberBg = Color(0xFFFEF3C7);
  static const amberFg = Color(0xFFB45309);
  static const roseBg = Color(0xFFFFE4E6);
  static const roseFg = Color(0xFFBE123C);
  static const indigoBg = Color(0xFFE0E7FF);
  static const indigoFg = Color(0xFF4338CA);

  // White with opacity
  static const white = Color(0xFFFFFFFF);
  static const white70 = Color(0xB3FFFFFF);
  static const white50 = Color(0x80FFFFFF);
  static const white20 = Color(0x33FFFFFF);
  static const white10 = Color(0x1AFFFFFF);

  // Black with opacity
  static const black = Color(0xFF000000);
  static const black05 = Color(0x0D000000);
  static const black03 = Color(0x08000000);
}
```

**Step 2: Create app_typography.dart**

```dart
import 'dart:ui';
import 'package:flutter/painting.dart';

class AppTypography {
  AppTypography._();

  static const fontFamily = 'Inter';
  static const monoFamily = 'JetBrainsMono';

  // Headings
  static const heading2xl = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    height: 1.3,
  );

  static const headingXl = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static const headingLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const heading3xl = TextStyle(
    fontFamily: fontFamily,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  // Body
  static const bodyLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  static const bodyBase = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  static const bodySm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  static const bodyXs = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  // Caption / Labels
  static const caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const labelUppercase = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    height: 1.4,
  );

  static const labelUppercaseXs = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    height: 1.4,
  );

  // Timer
  static const timerLarge = TextStyle(
    fontFamily: monoFamily,
    fontSize: 72,
    fontWeight: FontWeight.w300,
    letterSpacing: -2,
    height: 1.0,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const timerMedium = TextStyle(
    fontFamily: monoFamily,
    fontSize: 56,
    fontWeight: FontWeight.w300,
    letterSpacing: -1.5,
    height: 1.0,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
```

**Step 3: Create app_spacing.dart**

```dart
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;
}
```

**Step 4: Create app_radii.dart**

```dart
import 'package:flutter/painting.dart';

class AppRadii {
  AppRadii._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double full = 999;

  // BorderRadius shortcuts
  static final borderSm = BorderRadius.circular(sm);
  static final borderMd = BorderRadius.circular(md);
  static final borderLg = BorderRadius.circular(lg);
  static final borderXl = BorderRadius.circular(xl);
  static final borderXxl = BorderRadius.circular(xxl);
  static final borderXxxl = BorderRadius.circular(xxxl);
  static final borderFull = BorderRadius.circular(full);
}
```

**Step 5: Create app_shadows.dart**

```dart
import 'package:flutter/painting.dart';

class AppShadows {
  AppShadows._();

  static const sm = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const md = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  static const lg = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  static const xl = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 32,
      offset: Offset(0, 8),
    ),
  ];

  // Focus screen specific
  static const focusButton = [
    BoxShadow(
      color: Color(0x0DFFFFFF),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];
}
```

**Step 6: Create app_motion.dart**

```dart
import 'package:flutter/animation.dart';

class AppMotion {
  AppMotion._();

  // Curves
  static const smoothCurve = Cubic(0.16, 1, 0.3, 1);
  static const focusIntroCurve = Cubic(0.2, 0.9, 0.4, 1);
  static const standard = Curves.easeOut;
  static const decelerate = Curves.easeOutCubic;

  // Durations
  static const instant = Duration(milliseconds: 100);
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 200);
  static const medium = Duration(milliseconds: 300);
  static const slow = Duration(milliseconds: 500);
  static const slower = Duration(milliseconds: 800);

  // Focus intro
  static const introTitleDuration = Duration(milliseconds: 1200);
  static const introTimerDelay = Duration(milliseconds: 1200);
  static const introTimerDuration = Duration(milliseconds: 1500);
  static const introControlsDelay = Duration(milliseconds: 2000);
  static const introControlsDuration = Duration(milliseconds: 1000);
  static const introProjectBadgeDelay = Duration(milliseconds: 800);
  static const introProjectBadgeDuration = Duration(milliseconds: 1000);
  static const atmospheric = Duration(seconds: 3);

  // Phase delays
  static const introPhaseDelay = Duration(milliseconds: 2500);
  static const celebrationDelay = Duration(milliseconds: 3500);
  static const postCreateAutoHide = Duration(seconds: 4);

  // Page entry
  static const pageEntryDuration = Duration(milliseconds: 500);
  static const pageEntryOffset = 16.0;

  // Bar chart
  static const barGrowDuration = Duration(milliseconds: 800);
  static const barStaggerDelay = Duration(milliseconds: 100);

  // Auth
  static const blobADuration = Duration(seconds: 8);
  static const blobBDuration = Duration(seconds: 10);
  static const blobBDelay = Duration(seconds: 1);
  static const authContainerDuration = Duration(milliseconds: 500);
  static const authStaggerInterval = Duration(milliseconds: 100);
  static const shimmerDuration = Duration(milliseconds: 1500);
}
```

**Step 7: Create app_theme.dart**

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: AppTypography.fontFamily,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      colorScheme: const ColorScheme.light(
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        primary: AppColors.neutral900,
        onPrimary: AppColors.white,
        outline: AppColors.surfaceBorder,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        selectionColor: AppColors.neutral200,
        cursorColor: AppColors.neutral900,
      ),
    );
  }
}
```

**Step 8: Verify all files compile**

```bash
cd /Users/nrandriantsarafara/Works/sandbox/pomodoro
# Quick syntax check — create a minimal main.dart that imports all theme files
cat > lib/main.dart << 'EOF'
import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'theme/app_typography.dart';
import 'theme/app_spacing.dart';
import 'theme/app_radii.dart';
import 'theme/app_shadows.dart';
import 'theme/app_motion.dart';
import 'theme/app_theme.dart';

void main() {
  // Verify imports resolve
  debugPrint('Colors bg: ${AppColors.background}');
  debugPrint('Spacing lg: ${AppSpacing.lg}');
  debugPrint('Radii md: ${AppRadii.md}');
  debugPrint('Shadows: ${AppShadows.sm}');
  debugPrint('Motion: ${AppMotion.slow}');
  debugPrint('Typography: ${AppTypography.fontFamily}');
  runApp(MaterialApp(theme: AppTheme.light, home: const SizedBox()));
}
EOF
flutter analyze lib/theme/
```

Expected: No errors.

**Step 9: Commit**

```bash
git add lib/theme/ lib/main.dart
git commit -m "feat: add design token system (colors, typography, spacing, radii, shadows, motion)"
```

---

## Task 3: Data Models

**Files:**
- Create: `lib/models/project.dart`
- Create: `lib/models/task.dart`
- Create: `lib/models/session.dart`
- Create: `lib/models/models.dart` (barrel export)
- Test: `test/models/models_test.dart`

**Step 1: Create project.dart**

```dart
import 'dart:ui';

class ProjectStyle {
  final Color background;
  final Color foreground;

  const ProjectStyle({required this.background, required this.foreground});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectStyle &&
          other.background == background &&
          other.foreground == foreground;

  @override
  int get hashCode => Object.hash(background, foreground);
}

class ProjectStyles {
  ProjectStyles._();

  static const blue = ProjectStyle(
    background: Color(0xFFDBEAFE),
    foreground: Color(0xFF1D4ED8),
  );
  static const emerald = ProjectStyle(
    background: Color(0xFFD1FAE5),
    foreground: Color(0xFF047857),
  );
  static const purple = ProjectStyle(
    background: Color(0xFFF3E8FF),
    foreground: Color(0xFF7E22CE),
  );
  static const amber = ProjectStyle(
    background: Color(0xFFFEF3C7),
    foreground: Color(0xFFB45309),
  );
  static const rose = ProjectStyle(
    background: Color(0xFFFFE4E6),
    foreground: Color(0xFFBE123C),
  );
  static const indigo = ProjectStyle(
    background: Color(0xFFE0E7FF),
    foreground: Color(0xFF4338CA),
  );

  static const all = [blue, emerald, purple, amber, rose, indigo];
}

class Project {
  final String id;
  final String name;
  final ProjectStyle style;

  const Project({
    required this.id,
    required this.name,
    required this.style,
  });

  Project copyWith({String? id, String? name, ProjectStyle? style}) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      style: style ?? this.style,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Project && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
```

**Step 2: Create task.dart**

```dart
class Task {
  final String id;
  final String title;
  final String? projectId;
  final bool completed;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.title,
    this.projectId,
    this.completed = false,
    required this.createdAt,
  });

  Task copyWith({
    String? id,
    String? title,
    String? projectId,
    bool clearProjectId = false,
    bool? completed,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      projectId: clearProjectId ? null : (projectId ?? this.projectId),
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Task && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
```

**Step 3: Create session.dart**

```dart
import 'project.dart';

class Session {
  final String id;
  final String taskId;
  final String taskTitle;
  final String? projectName;
  final ProjectStyle? projectStyle;
  final int preset; // 25, 50, or 90
  final int duration; // seconds focused
  final DateTime completedAt;

  const Session({
    required this.id,
    required this.taskId,
    required this.taskTitle,
    this.projectName,
    this.projectStyle,
    required this.preset,
    required this.duration,
    required this.completedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Session && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
```

**Step 4: Create barrel export models.dart**

```dart
export 'project.dart';
export 'task.dart';
export 'session.dart';
```

**Step 5: Write model tests**

```dart
// test/models/models_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:rhythm/models/models.dart';

void main() {
  group('Task', () {
    test('copyWith toggles completed', () {
      final task = Task(
        id: '1',
        title: 'Test',
        createdAt: DateTime(2026, 1, 1),
      );
      final toggled = task.copyWith(completed: true);
      expect(toggled.completed, true);
      expect(toggled.title, 'Test');
      expect(toggled.id, '1');
    });

    test('copyWith clears projectId', () {
      final task = Task(
        id: '1',
        title: 'Test',
        projectId: 'p1',
        createdAt: DateTime(2026, 1, 1),
      );
      final cleared = task.copyWith(clearProjectId: true);
      expect(cleared.projectId, isNull);
    });

    test('equality based on id', () {
      final a = Task(id: '1', title: 'A', createdAt: DateTime(2026, 1, 1));
      final b = Task(id: '1', title: 'B', createdAt: DateTime(2026, 1, 2));
      expect(a, equals(b));
    });
  });

  group('Project', () {
    test('ProjectStyles has 6 styles', () {
      expect(ProjectStyles.all.length, 6);
    });

    test('equality based on id', () {
      const a = Project(id: 'p1', name: 'A', style: ProjectStyles.blue);
      const b = Project(id: 'p1', name: 'B', style: ProjectStyles.emerald);
      expect(a, equals(b));
    });
  });

  group('Session', () {
    test('stores snapshot data', () {
      final session = Session(
        id: 's1',
        taskId: 't1',
        taskTitle: 'Snapshot title',
        projectName: 'Design',
        projectStyle: ProjectStyles.blue,
        preset: 25,
        duration: 1500,
        completedAt: DateTime(2026, 1, 1),
      );
      expect(session.taskTitle, 'Snapshot title');
      expect(session.projectName, 'Design');
      expect(session.duration, 1500);
    });
  });
}
```

**Step 6: Run tests**

```bash
flutter test test/models/models_test.dart -v
```

Expected: All tests pass.

**Step 7: Commit**

```bash
git add lib/models/ test/models/
git commit -m "feat: add data models (Project, Task, Session)"
```

---

## Task 4: Repositories

**Files:**
- Create: `lib/repositories/task_repository.dart`
- Create: `lib/repositories/project_repository.dart`
- Create: `lib/repositories/session_repository.dart`
- Create: `lib/repositories/auth_repository.dart`
- Create: `lib/repositories/repositories.dart` (barrel)
- Test: `test/repositories/repositories_test.dart`

**Step 1: Create task_repository.dart**

```dart
import '../models/models.dart';

abstract class TaskRepository {
  List<Task> getAll();
  void add(Task task);
  void update(Task task);
  void delete(String id);
}

class InMemoryTaskRepository implements TaskRepository {
  final List<Task> _tasks;

  InMemoryTaskRepository({List<Task>? initial}) : _tasks = initial ?? [];

  @override
  List<Task> getAll() => List.unmodifiable(_tasks);

  @override
  void add(Task task) => _tasks.insert(0, task);

  @override
  void update(Task task) {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) _tasks[index] = task;
  }

  @override
  void delete(String id) => _tasks.removeWhere((t) => t.id == id);
}
```

**Step 2: Create project_repository.dart**

```dart
import '../models/models.dart';

abstract class ProjectRepository {
  List<Project> getAll();
  void add(Project project);
}

class InMemoryProjectRepository implements ProjectRepository {
  final List<Project> _projects;

  InMemoryProjectRepository({List<Project>? initial})
      : _projects = initial ?? [];

  @override
  List<Project> getAll() => List.unmodifiable(_projects);

  @override
  void add(Project project) => _projects.add(project);
}
```

**Step 3: Create session_repository.dart**

```dart
import '../models/models.dart';

abstract class SessionRepository {
  List<Session> getAll();
  void add(Session session);
}

class InMemorySessionRepository implements SessionRepository {
  final List<Session> _sessions;

  InMemorySessionRepository({List<Session>? initial})
      : _sessions = initial ?? [];

  @override
  List<Session> getAll() => List.unmodifiable(_sessions);

  @override
  void add(Session session) => _sessions.insert(0, session);
}
```

**Step 4: Create auth_repository.dart**

```dart
abstract class AuthRepository {
  Future<bool> signIn({required String email, required String password});
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  });
}

class MockAuthRepository implements AuthRepository {
  @override
  Future<bool> signIn({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    return true;
  }

  @override
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    return true;
  }
}
```

**Step 5: Create barrel export**

```dart
export 'task_repository.dart';
export 'project_repository.dart';
export 'session_repository.dart';
export 'auth_repository.dart';
```

**Step 6: Write repository tests**

```dart
// test/repositories/repositories_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:rhythm/models/models.dart';
import 'package:rhythm/repositories/repositories.dart';

void main() {
  group('InMemoryTaskRepository', () {
    late InMemoryTaskRepository repo;

    setUp(() {
      repo = InMemoryTaskRepository();
    });

    test('starts empty', () {
      expect(repo.getAll(), isEmpty);
    });

    test('add inserts at beginning', () {
      final t1 = Task(id: '1', title: 'First', createdAt: DateTime(2026, 1, 1));
      final t2 = Task(id: '2', title: 'Second', createdAt: DateTime(2026, 1, 2));
      repo.add(t1);
      repo.add(t2);
      expect(repo.getAll().first.id, '2');
    });

    test('update replaces task', () {
      final task = Task(id: '1', title: 'Old', createdAt: DateTime(2026, 1, 1));
      repo.add(task);
      repo.update(task.copyWith(title: 'New'));
      expect(repo.getAll().first.title, 'New');
    });

    test('delete removes task', () {
      final task = Task(id: '1', title: 'Test', createdAt: DateTime(2026, 1, 1));
      repo.add(task);
      repo.delete('1');
      expect(repo.getAll(), isEmpty);
    });

    test('initial seed data', () {
      final seeded = InMemoryTaskRepository(initial: [
        Task(id: '1', title: 'Seeded', createdAt: DateTime(2026, 1, 1)),
      ]);
      expect(seeded.getAll().length, 1);
    });
  });

  group('InMemoryProjectRepository', () {
    test('add and getAll', () {
      final repo = InMemoryProjectRepository();
      repo.add(const Project(id: 'p1', name: 'Test', style: ProjectStyles.blue));
      expect(repo.getAll().length, 1);
    });
  });

  group('InMemorySessionRepository', () {
    test('add inserts at beginning', () {
      final repo = InMemorySessionRepository();
      final s1 = Session(
        id: 's1', taskId: 't1', taskTitle: 'A', preset: 25,
        duration: 1500, completedAt: DateTime(2026, 1, 1),
      );
      final s2 = Session(
        id: 's2', taskId: 't2', taskTitle: 'B', preset: 50,
        duration: 3000, completedAt: DateTime(2026, 1, 2),
      );
      repo.add(s1);
      repo.add(s2);
      expect(repo.getAll().first.id, 's2');
    });
  });
}
```

**Step 7: Run tests**

```bash
flutter test test/repositories/repositories_test.dart -v
```

Expected: All pass.

**Step 8: Commit**

```bash
git add lib/repositories/ test/repositories/
git commit -m "feat: add repository interfaces and in-memory implementations"
```

---

## Task 5: Store and Riverpod Providers

**Files:**
- Create: `lib/store/app_store.dart`
- Create: `lib/store/providers.dart`
- Test: `test/store/app_store_test.dart`

**Step 1: Create app_store.dart**

```dart
import 'dart:math';

import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';

class AppStore extends ChangeNotifier {
  final TaskRepository _taskRepo;
  final ProjectRepository _projectRepo;
  final SessionRepository _sessionRepo;

  int _lastUsedPreset = 25;

  AppStore({
    required TaskRepository taskRepo,
    required ProjectRepository projectRepo,
    required SessionRepository sessionRepo,
  })  : _taskRepo = taskRepo,
        _projectRepo = projectRepo,
        _sessionRepo = sessionRepo;

  // Getters
  List<Task> get tasks => _taskRepo.getAll();
  List<Project> get projects => _projectRepo.getAll();
  List<Session> get sessions => _sessionRepo.getAll();
  int get lastUsedPreset => _lastUsedPreset;

  // Task operations
  void addTask(String title, {String? projectId}) {
    final task = Task(
      id: _generateId(),
      title: title,
      projectId: projectId,
      createdAt: DateTime.now(),
    );
    _taskRepo.add(task);
    notifyListeners();
  }

  void toggleTask(String id) {
    final task = tasks.firstWhere((t) => t.id == id);
    _taskRepo.update(task.copyWith(completed: !task.completed));
    notifyListeners();
  }

  void deleteTask(String id) {
    _taskRepo.delete(id);
    notifyListeners();
  }

  // Project operations
  void addProject(String name, ProjectStyle style) {
    final project = Project(
      id: _generateId(),
      name: name,
      style: style,
    );
    _projectRepo.add(project);
    notifyListeners();
  }

  // Session operations
  void addSession({
    required String taskId,
    required String taskTitle,
    String? projectName,
    ProjectStyle? projectStyle,
    required int preset,
    required int duration,
  }) {
    final session = Session(
      id: _generateId(),
      taskId: taskId,
      taskTitle: taskTitle,
      projectName: projectName,
      projectStyle: projectStyle,
      preset: preset,
      duration: duration,
      completedAt: DateTime.now(),
    );
    _sessionRepo.add(session);
    notifyListeners();
  }

  // Preset
  void setLastUsedPreset(int preset) {
    _lastUsedPreset = preset;
    notifyListeners();
  }

  // Lookup helpers
  Project? findProject(String? id) {
    if (id == null) return null;
    try {
      return projects.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Task? findTask(String id) {
    try {
      return tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  String _generateId() {
    return Random().nextInt(1 << 32).toRadixString(36);
  }
}
```

**Step 2: Create providers.dart**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';
import 'app_store.dart';

// Repository providers — override these to swap persistence
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return InMemoryTaskRepository(initial: [
    Task(
      id: 't1',
      title: 'Wireframe user profile',
      projectId: 'p1',
      createdAt: DateTime.now(),
    ),
    Task(
      id: 't2',
      title: 'Fix navigation bug',
      projectId: 'p2',
      createdAt: DateTime.now(),
    ),
    Task(
      id: 't3',
      title: 'Read email backlog',
      createdAt: DateTime.now(),
    ),
  ]);
});

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return InMemoryProjectRepository(initial: [
    const Project(id: 'p1', name: 'Design', style: ProjectStyles.blue),
    const Project(id: 'p2', name: 'Dev', style: ProjectStyles.emerald),
  ]);
});

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return InMemorySessionRepository(initial: [
    Session(
      id: 's1',
      taskId: 't1',
      taskTitle: 'Wireframe user profile',
      projectName: 'Design',
      projectStyle: ProjectStyles.blue,
      preset: 25,
      duration: 25 * 60,
      completedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    Session(
      id: 's2',
      taskId: 't2',
      taskTitle: 'Fix navigation bug',
      projectName: 'Dev',
      projectStyle: ProjectStyles.emerald,
      preset: 50,
      duration: 50 * 60,
      completedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ]);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository();
});

// App store — single source of truth
final appStoreProvider = ChangeNotifierProvider<AppStore>((ref) {
  return AppStore(
    taskRepo: ref.watch(taskRepositoryProvider),
    projectRepo: ref.watch(projectRepositoryProvider),
    sessionRepo: ref.watch(sessionRepositoryProvider),
  );
});
```

**Step 3: Write store tests**

```dart
// test/store/app_store_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:rhythm/models/models.dart';
import 'package:rhythm/repositories/repositories.dart';
import 'package:rhythm/store/app_store.dart';

AppStore createStore({
  List<Task>? tasks,
  List<Project>? projects,
  List<Session>? sessions,
}) {
  return AppStore(
    taskRepo: InMemoryTaskRepository(initial: tasks ?? []),
    projectRepo: InMemoryProjectRepository(initial: projects ?? []),
    sessionRepo: InMemorySessionRepository(initial: sessions ?? []),
  );
}

void main() {
  group('AppStore', () {
    test('addTask adds to beginning of list', () {
      final store = createStore();
      store.addTask('First task');
      store.addTask('Second task');
      expect(store.tasks.length, 2);
      expect(store.tasks.first.title, 'Second task');
    });

    test('addTask with projectId', () {
      final store = createStore();
      store.addTask('Task', projectId: 'p1');
      expect(store.tasks.first.projectId, 'p1');
    });

    test('toggleTask flips completed', () {
      final store = createStore(tasks: [
        Task(id: '1', title: 'Test', createdAt: DateTime(2026, 1, 1)),
      ]);
      store.toggleTask('1');
      expect(store.tasks.first.completed, true);
      store.toggleTask('1');
      expect(store.tasks.first.completed, false);
    });

    test('deleteTask removes task', () {
      final store = createStore(tasks: [
        Task(id: '1', title: 'Test', createdAt: DateTime(2026, 1, 1)),
      ]);
      store.deleteTask('1');
      expect(store.tasks, isEmpty);
    });

    test('addProject adds project', () {
      final store = createStore();
      store.addProject('Design', ProjectStyles.blue);
      expect(store.projects.length, 1);
      expect(store.projects.first.name, 'Design');
    });

    test('addSession adds session at beginning', () {
      final store = createStore();
      store.addSession(
        taskId: 't1',
        taskTitle: 'Test',
        preset: 25,
        duration: 1500,
      );
      expect(store.sessions.length, 1);
      expect(store.sessions.first.taskTitle, 'Test');
    });

    test('setLastUsedPreset updates preset', () {
      final store = createStore();
      expect(store.lastUsedPreset, 25);
      store.setLastUsedPreset(50);
      expect(store.lastUsedPreset, 50);
    });

    test('findProject returns null for missing id', () {
      final store = createStore();
      expect(store.findProject('nonexistent'), isNull);
      expect(store.findProject(null), isNull);
    });

    test('findTask returns null for missing id', () {
      final store = createStore();
      expect(store.findTask('nonexistent'), isNull);
    });

    test('notifies listeners on changes', () {
      final store = createStore();
      int notifyCount = 0;
      store.addListener(() => notifyCount++);

      store.addTask('Task');
      expect(notifyCount, 1);

      store.toggleTask(store.tasks.first.id);
      expect(notifyCount, 2);

      store.setLastUsedPreset(90);
      expect(notifyCount, 3);
    });
  });
}
```

**Step 4: Run tests**

```bash
flutter test test/store/app_store_test.dart -v
```

Expected: All pass.

**Step 5: Commit**

```bash
git add lib/store/ test/store/
git commit -m "feat: add AppStore and Riverpod providers with seed data"
```

---

## Task 6: Shared Utilities

**Files:**
- Create: `lib/shared/utils/date_helpers.dart`
- Create: `lib/shared/utils/format_helpers.dart`
- Test: `test/shared/utils_test.dart`

**Step 1: Create date_helpers.dart**

```dart
bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

bool isToday(DateTime date) {
  return isSameDay(date, DateTime.now());
}

bool isYesterday(DateTime date) {
  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  return isSameDay(date, yesterday);
}

DateTime startOfDay(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}
```

**Step 2: Create format_helpers.dart**

```dart
String formatDuration(int totalSeconds) {
  final hours = totalSeconds ~/ 3600;
  final mins = (totalSeconds % 3600) ~/ 60;
  if (hours > 0) return '${hours}h ${mins}m';
  return '${mins}m';
}

String formatTimer(int totalSeconds) {
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

String formatTimeOfDay(DateTime date) {
  final hour = date.hour;
  final minute = date.minute;
  final period = hour >= 12 ? 'PM' : 'AM';
  final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
  return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
}

int breakMinutesForPreset(int preset) {
  switch (preset) {
    case 50:
      return 10;
    case 90:
      return 20;
    default:
      return 5;
  }
}
```

**Step 3: Write tests**

```dart
// test/shared/utils_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:rhythm/shared/utils/date_helpers.dart';
import 'package:rhythm/shared/utils/format_helpers.dart';

void main() {
  group('date_helpers', () {
    test('isSameDay returns true for same day', () {
      expect(isSameDay(DateTime(2026, 4, 3, 10), DateTime(2026, 4, 3, 22)), true);
    });

    test('isSameDay returns false for different days', () {
      expect(isSameDay(DateTime(2026, 4, 3), DateTime(2026, 4, 4)), false);
    });

    test('isToday returns true for today', () {
      expect(isToday(DateTime.now()), true);
    });

    test('isYesterday returns true for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(isYesterday(yesterday), true);
    });
  });

  group('format_helpers', () {
    test('formatDuration with hours', () {
      expect(formatDuration(3660), '1h 1m');
    });

    test('formatDuration minutes only', () {
      expect(formatDuration(1500), '25m');
    });

    test('formatDuration zero', () {
      expect(formatDuration(0), '0m');
    });

    test('formatTimer', () {
      expect(formatTimer(1500), '25:00');
      expect(formatTimer(65), '01:05');
      expect(formatTimer(0), '00:00');
    });

    test('breakMinutesForPreset', () {
      expect(breakMinutesForPreset(25), 5);
      expect(breakMinutesForPreset(50), 10);
      expect(breakMinutesForPreset(90), 20);
    });
  });
}
```

**Step 4: Run tests**

```bash
flutter test test/shared/utils_test.dart -v
```

Expected: All pass.

**Step 5: Commit**

```bash
git add lib/shared/utils/ test/shared/
git commit -m "feat: add date and format utility helpers"
```

---

## Task 7: Shared Widgets — Foundation

**Files:**
- Create: `lib/shared/widgets/press_scale_button.dart`
- Create: `lib/shared/widgets/page_entry_animation.dart`
- Create: `lib/shared/widgets/project_badge.dart`
- Create: `lib/shared/widgets/app_icon.dart`
- Create: `lib/shared/widgets/progress_ring.dart`

**Step 1: Create press_scale_button.dart**

```dart
import 'package:flutter/material.dart';

class PressScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double scaleDown;
  final Duration duration;

  const PressScaleButton({
    super.key,
    required this.child,
    this.onPressed,
    this.scaleDown = 0.95,
    this.duration = const Duration(milliseconds: 100),
  });

  @override
  State<PressScaleButton> createState() => _PressScaleButtonState();
}

class _PressScaleButtonState extends State<PressScaleButton> {
  bool _pressing = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressing = true),
      onTapUp: (_) {
        setState(() => _pressing = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _pressing = false),
      child: AnimatedScale(
        scale: _pressing ? widget.scaleDown : 1.0,
        duration: widget.duration,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
```

**Step 2: Create page_entry_animation.dart**

```dart
import 'package:flutter/material.dart';
import '../../theme/app_motion.dart';

class PageEntryAnimation extends StatelessWidget {
  final Widget child;

  const PageEntryAnimation({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: AppMotion.pageEntryDuration,
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, AppMotion.pageEntryOffset * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
```

**Step 3: Create project_badge.dart**

```dart
import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_typography.dart';

class ProjectBadge extends StatelessWidget {
  final String name;
  final ProjectStyle style;
  final bool small;

  const ProjectBadge({
    super.key,
    required this.name,
    required this.style,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 8,
        vertical: small ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: AppRadii.borderSm,
      ),
      child: Text(
        name,
        style: (small ? AppTypography.labelUppercaseXs : AppTypography.bodyXs)
            .copyWith(color: style.foreground),
      ),
    );
  }
}
```

**Step 4: Create app_icon.dart**

```dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';

class AppLogoIcon extends StatelessWidget {
  final double size;

  const AppLogoIcon({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    final iconSize = size * 0.56;
    final radius = size * 0.3125; // ~10/32
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.neutral900,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Center(
        child: CustomPaint(
          size: Size(iconSize, iconSize),
          painter: _ClockIconPainter(),
        ),
      ),
    );
  }
}

class _ClockIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.14 // ~2.5/18
      ..strokeCap = StrokeCap.round;

    // Circle
    canvas.drawCircle(center, radius * 0.83, paint);

    // Hour hand (12 to center)
    canvas.drawLine(
      Offset(center.dx, center.dy - radius * 0.5),
      center,
      paint,
    );

    // Minute hand (center to ~4 o'clock position)
    canvas.drawLine(
      center,
      Offset(center.dx + radius * 0.33, center.dy + radius * 0.17),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

**Step 5: Create progress_ring.dart**

```dart
import 'dart:math';
import 'package:flutter/material.dart';

class ProgressRing extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final double progress; // 0.0 to 1.0
  final Color activeColor;
  final Color backgroundColor;
  final Duration animationDuration;
  final Widget? child;

  const ProgressRing({
    super.key,
    required this.size,
    this.strokeWidth = 3,
    required this.progress,
    required this.activeColor,
    required this.backgroundColor,
    this.animationDuration = const Duration(seconds: 1),
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: animationDuration,
            curve: Curves.linear,
            builder: (context, animatedProgress, _) {
              return CustomPaint(
                size: Size(size, size),
                painter: _ProgressRingPainter(
                  progress: animatedProgress,
                  activeColor: activeColor,
                  backgroundColor: backgroundColor,
                  strokeWidth: strokeWidth,
                ),
              );
            },
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color backgroundColor;
  final double strokeWidth;

  _ProgressRingPainter({
    required this.progress,
    required this.activeColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background ring
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    // Active ring
    if (progress > 0) {
      final activePaint = Paint()
        ..color = activeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2, // Start from top
        sweepAngle,
        false,
        activePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
```

**Step 6: Verify compilation**

```bash
flutter analyze lib/shared/
```

Expected: No errors.

**Step 7: Commit**

```bash
git add lib/shared/widgets/
git commit -m "feat: add shared widgets (PressScaleButton, PageEntryAnimation, ProjectBadge, AppIcon, ProgressRing)"
```

---

## Task 8: Router Setup

**Files:**
- Create: `lib/router/app_router.dart`
- Modify: `lib/main.dart`
- Create: `lib/app.dart`

**Step 1: Create app_router.dart**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/layout/app_shell.dart';
import '../features/home/home_page.dart';
import '../features/history/history_page.dart';
import '../features/auth/auth_page.dart';
import '../features/focus/focus_timer_page.dart';
import '../features/break_timer/break_timer_page.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomePage(),
            ),
          ),
          GoRoute(
            path: '/history',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HistoryPage(),
            ),
          ),
          GoRoute(
            path: '/auth',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AuthPage(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/focus/:taskId',
        pageBuilder: (context, state) {
          final taskId = state.pathParameters['taskId']!;
          final preset = int.tryParse(
                state.uri.queryParameters['preset'] ?? '',
              ) ??
              25;
          return CustomTransitionPage(
            child: FocusTimerPage(taskId: taskId, preset: preset),
            transitionsBuilder: (context, animation, _, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          );
        },
      ),
      GoRoute(
        path: '/break/:taskId',
        pageBuilder: (context, state) {
          final taskId = state.pathParameters['taskId']!;
          final breakMinutes = int.tryParse(
                state.uri.queryParameters['mins'] ?? '',
              ) ??
              5;
          final justCompleted =
              state.uri.queryParameters['completed'] == 'true';
          return CustomTransitionPage(
            child: BreakTimerPage(
              taskId: taskId,
              breakMinutes: breakMinutes,
              justCompleted: justCompleted,
            ),
            transitionsBuilder: (context, animation, _, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          );
        },
      ),
    ],
  );
}
```

**Step 2: Create placeholder pages**

Create stub files for all pages so the router compiles. Each is a minimal placeholder.

`lib/features/layout/app_shell.dart`:
```dart
import 'package:flutter/material.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: child);
  }
}
```

`lib/features/home/home_page.dart`:
```dart
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Home'));
  }
}
```

`lib/features/history/history_page.dart`:
```dart
import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('History'));
  }
}
```

`lib/features/auth/auth_page.dart`:
```dart
import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Auth'));
  }
}
```

`lib/features/focus/focus_timer_page.dart`:
```dart
import 'package:flutter/material.dart';

class FocusTimerPage extends StatelessWidget {
  final String taskId;
  final int preset;

  const FocusTimerPage({
    super.key,
    required this.taskId,
    required this.preset,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Focus'));
  }
}
```

`lib/features/break_timer/break_timer_page.dart`:
```dart
import 'package:flutter/material.dart';

class BreakTimerPage extends StatelessWidget {
  final String taskId;
  final int breakMinutes;
  final bool justCompleted;

  const BreakTimerPage({
    super.key,
    required this.taskId,
    required this.breakMinutes,
    required this.justCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Break'));
  }
}
```

**Step 3: Create app.dart**

```dart
import 'package:flutter/material.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class RhythmApp extends StatelessWidget {
  const RhythmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Rhythm',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
    );
  }
}
```

**Step 4: Update main.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: RhythmApp(),
    ),
  );
}
```

**Step 5: Verify the app runs**

```bash
cd /Users/nrandriantsarafara/Works/sandbox/pomodoro
flutter analyze
```

Expected: No errors. If you can run on a device/emulator: `flutter run` should show "Home" text.

**Step 6: Commit**

```bash
git add lib/
git commit -m "feat: add routing, app shell stubs, and Riverpod bootstrap"
```

---

## Task 9: App Shell — Layout with Desktop Header and Mobile Bottom Nav

**Files:**
- Rewrite: `lib/features/layout/app_shell.dart`
- Create: `lib/features/layout/desktop_header.dart`
- Create: `lib/features/layout/mobile_header.dart`
- Create: `lib/features/layout/mobile_bottom_nav.dart`

**Step 1: Create desktop_header.dart**

```dart
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/app_icon.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DesktopHeader extends StatelessWidget {
  const DesktopHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final isFocus = location == '/';
    final isRhythm = location == '/history';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.8),
        border: const Border(
          bottom: BorderSide(color: AppColors.neutral200, width: 1),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxxl,
              vertical: AppSpacing.lg,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 896),
                child: Row(
                  children: [
                    // Logo
                    const Row(
                      children: [
                        AppLogoIcon(size: 32),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          'Rhythm',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                            color: AppColors.neutral900,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Segmented Nav
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.neutral100,
                        borderRadius: AppRadii.borderXl,
                        border: Border.all(color: AppColors.neutral200),
                        boxShadow: AppShadows.sm,
                      ),
                      child: Row(
                        children: [
                          _NavTab(
                            icon: LucideIcons.listTodo,
                            label: 'Focus',
                            isActive: isFocus,
                            onTap: () => context.go('/'),
                          ),
                          _NavTab(
                            icon: LucideIcons.barChart3,
                            label: 'Rhythm',
                            isActive: isRhythm,
                            onTap: () => context.go('/history'),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Sign In
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => context.go('/auth'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.neutral100,
                            borderRadius: AppRadii.borderLg,
                          ),
                          child: Text(
                            'Sign In',
                            style: AppTypography.bodySm.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.neutral600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavTab({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.white : Colors.transparent,
            borderRadius: AppRadii.borderLg,
            boxShadow: isActive ? AppShadows.sm : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive
                    ? AppColors.neutral900
                    : AppColors.neutral500,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: AppTypography.bodySm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isActive
                      ? AppColors.neutral900
                      : AppColors.neutral500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Step 2: Create mobile_header.dart**

```dart
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/app_icon.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

class MobileHeader extends StatelessWidget {
  const MobileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.9),
        border: const Border(
          bottom: BorderSide(
            color: Color(0x80E5E5E5), // neutral-200/50
            width: 1,
          ),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo
                const Row(
                  children: [
                    AppLogoIcon(size: 28),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Rhythm',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                        color: AppColors.neutral900,
                      ),
                    ),
                  ],
                ),

                // Sign In
                GestureDetector(
                  onTap: () => context.go('/auth'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      borderRadius: AppRadii.borderSm,
                    ),
                    child: Text(
                      'Sign In',
                      style: AppTypography.bodyXs.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

**Step 3: Create mobile_bottom_nav.dart**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class MobileBottomNav extends StatelessWidget {
  const MobileBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final activeIndex = location == '/history' ? 1 : 0;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.neutral200, width: 1),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: SizedBox(
          height: 64,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tabWidth = constraints.maxWidth / 2;
              return Stack(
                children: [
                  // Animated indicator
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 225),
                    curve: Curves.easeInOut,
                    left: activeIndex * tabWidth + (tabWidth - 32) / 2,
                    top: 0,
                    child: Container(
                      width: 32,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.neutral900,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(4),
                          bottomRight: Radius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  // Tabs
                  Row(
                    children: [
                      _BottomTab(
                        icon: LucideIcons.listTodo,
                        label: 'Focus',
                        isActive: activeIndex == 0,
                        onTap: () => context.go('/'),
                      ),
                      _BottomTab(
                        icon: LucideIcons.barChart3,
                        label: 'Rhythm',
                        isActive: activeIndex == 1,
                        onTap: () => context.go('/history'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BottomTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _BottomTab({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? AppColors.neutral900 : AppColors.neutral400,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: isActive ? AppColors.neutral900 : AppColors.neutral400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Step 4: Rewrite app_shell.dart**

```dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import 'desktop_header.dart';
import 'mobile_header.dart';
import 'mobile_bottom_nav.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  static const _breakpoint = 768.0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= _breakpoint;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          if (isDesktop) const DesktopHeader() else const MobileHeader(),

          // Content
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 896),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: isDesktop ? AppSpacing.xxxl : AppSpacing.xl,
                    right: isDesktop ? AppSpacing.xxxl : AppSpacing.xl,
                    top: isDesktop ? AppSpacing.xxxl : AppSpacing.xl,
                    bottom: isDesktop ? AppSpacing.xxxl : 96,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),

      // Mobile bottom nav
      bottomNavigationBar: isDesktop ? null : const MobileBottomNav(),
    );
  }
}
```

**Step 5: Verify compilation and test navigation**

```bash
flutter analyze lib/features/layout/
```

Expected: No errors.

**Step 6: Commit**

```bash
git add lib/features/layout/
git commit -m "feat: implement app shell with responsive desktop header and mobile bottom nav"
```

---

## Task 10: Home Page — Static Layout

This is a large task. Build the full Home page with all widgets. For brevity, I'll provide the complete home_page.dart and each widget file.

**Files:**
- Rewrite: `lib/features/home/home_page.dart`
- Create: `lib/features/home/widgets/today_header.dart`
- Create: `lib/features/home/widgets/next_focus_hero.dart`
- Create: `lib/features/home/widgets/task_composer.dart`
- Create: `lib/features/home/widgets/post_create_affordance.dart`
- Create: `lib/features/home/widgets/project_dropdown.dart`
- Create: `lib/features/home/widgets/task_list.dart`
- Create: `lib/features/home/widgets/task_row.dart`
- Create: `lib/features/home/widgets/task_overflow_menu.dart`
- Create: `lib/features/home/widgets/search_filter_bar.dart`
- Create: `lib/features/home/widgets/empty_task_state.dart`

This is too many files to write inline in the plan. Instead, implement each widget following these specifications:

**home_page.dart:** ConsumerStatefulWidget. Local state: newTaskTitle, selectedProjectId, isProjectDropdownOpen, isAddingProject, newProjectName, activePresetTaskId, activeMenuTaskId, searchQuery, filterProjectId, showPostCreateActions (nullable record of {id, title}). Computes todaySessions, todayFocusTime, sortedTasks, filteredTasks, nextFocusTask from store. Wraps content in PageEntryAnimation. Uses SingleChildScrollView with Column containing TodayHeader, NextFocusHero (conditional), TaskComposer, task list section. Includes GestureDetector backdrop for closing overlays.

**today_header.dart:** Column with "Today" heading (heading2xl, neutral-900) and subtitle showing focus time + session count (bodySm, neutral-500).

**next_focus_hero.dart:** Only renders if nextFocusTask exists. Dark rounded-3xl card (neutral-900). "Next focus" label, task title, primary Start button (white bg, dark text, PressScaleButton scale 0.95), chevron dropdown button. Entry animation: TweenAnimationBuilder opacity 0→1, translateY 10→0, 300ms.

**task_composer.dart:** Form with TextFormField in white container, rounded-2xl, h56, border neutral-200, shadow sm. Focus ring: neutral-900. Placeholder: "What do you want to focus on?". Animated add button (Plus icon) appears when text non-empty using AnimatedOpacity + AnimatedScale. Below input: animated project chip row using AnimatedSize + AnimatedOpacity, visible when typing and no post-create visible. Project chip button opens dropdown.

**post_create_affordance.dart:** Positioned below composer. White card, border, rounded-xl, shadow-lg. Shows "{title} added" + Dismiss + Start buttons. Entry: opacity 0→1, translateY -10→0, scale 0.95→1, 220ms. Exit: opacity→0, scale→0.95, 180ms. Auto-hide timer 4s.

**project_dropdown.dart:** Overlay anchored below composer. White bg, rounded-xl, shadow-xl. Two modes: selection (list of projects + "No Project" + "Create new project") and creation (input + Cancel + Add Project buttons). Entry/exit animated: opacity + scale + translateY, 150ms. Uses CompositedTransformTarget/Follower.

**task_list.dart:** If tasks empty, show EmptyTaskState. If ≥5 tasks, show SearchFilterBar. If any completed, show "Clear completed" button. List of TaskRow widgets wrapped in AnimatedSwitcher/keyed list for enter/exit animations.

**task_row.dart:** White card, rounded-2xl, border, shadow-sm. Contains: checkbox (6×6 rounded-md), title, optional ProjectBadge, split start button (Start + ChevronDown), overflow menu trigger. Completed rows: opacity 0.6, bg neutral-50, line-through text. Incomplete row press: AnimatedScale 0.99. Split button: neutral-100 bg, border, rounded-xl. Start half and chevron half separated by 1px divider.

**task_overflow_menu.dart:** Overlay, 100ms enter/exit. Contains Delete button (red text, Trash2 icon).

**search_filter_bar.dart:** Row with search input (Search icon, rounded-xl, h40) and project filter chips (All + each project). Active chip: neutral-900 bg white text. Inactive: white bg neutral-600 text.

**empty_task_state.dart:** Centered column in dashed border container. ListTodo icon, "No tasks yet." heading, subtitle.

**Implementation approach:** Build each widget file one at a time. After each file, run `flutter analyze` to verify no errors. Wire them together in home_page.dart last. Use the prototype React source as exact reference for layout structure and class names.

**Commit after completing all Home widgets:**

```bash
git add lib/features/home/
git commit -m "feat: implement Home page with all widgets and interactions"
```

---

## Task 11: Home Page — Overlays and Interactions

**Files:** Same home files from Task 10, plus `lib/shared/widgets/preset_picker.dart`

**Step 1: Create preset_picker.dart**

```dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

class PresetOption {
  final int minutes;
  final String label;
  final String description;

  const PresetOption({
    required this.minutes,
    required this.label,
    required this.description,
  });
}

const presetOptions = [
  PresetOption(minutes: 25, label: 'Quick focus', description: '25 / 5'),
  PresetOption(minutes: 50, label: 'Deep work', description: '50 / 10'),
  PresetOption(minutes: 90, label: 'Flow block', description: '90 / 20'),
];

class PresetPicker extends StatelessWidget {
  final int lastUsedPreset;
  final void Function(int minutes) onSelect;

  const PresetPicker({
    super.key,
    required this.lastUsedPreset,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 288,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.borderXl,
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
        border: Border.all(color: AppColors.surfaceBorderLight),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Text(
              'CHOOSE MODE',
              style: AppTypography.labelUppercaseXs.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.neutral50),
          const SizedBox(height: 4),

          // Options
          ...presetOptions.map((preset) {
            final isSelected = preset.minutes == lastUsedPreset;
            return GestureDetector(
              onTap: () => onSelect(preset.minutes),
              child: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.neutral900 : Colors.transparent,
                  borderRadius: AppRadii.borderLg,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          preset.label,
                          style: AppTypography.bodyBase.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.white
                                : AppColors.neutral900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${preset.minutes} min focus',
                          style: AppTypography.bodyXs.copyWith(
                            color: isSelected
                                ? AppColors.neutral300
                                : AppColors.neutral500,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.neutral800
                            : AppColors.white,
                        borderRadius: AppRadii.borderSm,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.neutral700
                              : AppColors.neutral200,
                        ),
                      ),
                      child: Text(
                        preset.description,
                        style: AppTypography.bodyXs.copyWith(
                          color: isSelected
                              ? AppColors.neutral300
                              : AppColors.neutral500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
```

**Step 2:** Wire all overlays into home_page.dart. Use `CompositedTransformTarget` on trigger buttons and `CompositedTransformFollower` in `Overlay` for anchored positioning. Wrap overlay content with animation controllers for enter/exit (150ms opacity + scale + translateY as specified).

**Step 3:** Implement the full backdrop dismiss — a `Positioned.fill` `GestureDetector` in the overlay stack that closes all dropdowns/menus when tapped.

**Step 4: Verify**

```bash
flutter analyze
```

**Step 5: Commit**

```bash
git add lib/features/home/ lib/shared/widgets/preset_picker.dart
git commit -m "feat: add overlays, preset picker, and all home interactions"
```

---

## Task 12: Focus Timer Page

**Files:**
- Rewrite: `lib/features/focus/focus_timer_page.dart`
- Create: `lib/features/focus/widgets/focus_background.dart`
- Create: `lib/features/focus/widgets/focus_title_block.dart`
- Create: `lib/features/focus/widgets/focus_timer_ring.dart`
- Create: `lib/features/focus/widgets/focus_controls.dart`
- Create: `lib/features/focus/widgets/phase_label.dart`

**Implementation spec per widget:**

**focus_timer_page.dart:** ConsumerStatefulWidget with TickerProviderStateMixin. State: timeLeft, isActive, phase (intro/active). AnimationControllers: titleController (1200ms), timerController (1500ms, delay 1200ms), controlsController (1000ms, delay 2000ms). Timer.periodic for countdown. On mount: start intro animations, schedule 2500ms delay to flip phase to active. On dispose: cancel all timers and controllers. handleComplete: addSession to store, compute break time, context.go to break. handleAbandon: context.go('/'). If task not found, redirect to '/'. Full-screen dark Scaffold with Stack: FocusBackground, centered Column with FocusTitleBlock, FocusTimerRing, bottom FocusControls.

**focus_background.dart:** Positioned.fill AnimatedContainer. RadialGradient that changes based on progress/timeLeft: early (<10%) = glow from top-center, normal = flat dark, final minute = bottom-center violet glow. Transition duration: 3s. Opacity 0.20.

**focus_title_block.dart:** Receives title, project, phase, titleAnimation. Uses FadeTransition + SlideTransition (y: 20→0) + TweenAnimationBuilder for blur (8→0). Contains: task title (heading 3xl-ish, white, tight tracking), project badge if exists (FadeTransition with 800ms delay), PhaseLabel below (only when phase == active).

**phase_label.dart:** AnimatedSwitcher with custom transitionBuilder. Key changes on phaseText change. phaseText computed from progress/timeLeft: "Settling in" if <10%, "Deep focus" normally, "Final stretch" if <60s. Style: labelUppercase, neutral-500, tracking-widest. Incoming: opacity 0→1, translateY 5→0. Outgoing: opacity 1→0, translateY 0→-5. Duration: 800ms.

**focus_timer_ring.dart:** Receives timeLeft, initialTime, phase. Uses ProgressRing with size 288 (matches prototype's w-72 h-72 = 288px). Background: neutral-900, 3px. Active ring: white normally, amber-400 when timeLeft < 60. Only renders active ring when phase == active. Child: timer text in timerLarge style, white normally, amber when <60s. Color transitions via TweenAnimationBuilder<Color> over 1s.

**focus_controls.dart:** Receives isActive, isPaused (derived), phase, onPause, onResume, onAbandon, onSaveEnd. FadeTransition + SlideTransition from controlsAnimation. Main button: full-width h64, rounded-2xl. Active = white bg dark text (Pause). Paused = dark bg white text (Resume). PressScaleButton scale 0.98. Disabled when phase == intro. Two secondary buttons in grid: Abandon (X icon, red on hover) and Save & End (Square icon). Icons: AnimatedScale 1.10 on hover via MouseRegion.

**Commit:**

```bash
git add lib/features/focus/
git commit -m "feat: implement Focus timer page with intro ceremony and all animations"
```

---

## Task 13: Break Timer Page

**Files:**
- Rewrite: `lib/features/break_timer/break_timer_page.dart`
- Create: `lib/features/break_timer/widgets/celebration_state.dart`
- Create: `lib/features/break_timer/widgets/recovery_state.dart`
- Create: `lib/features/break_timer/widgets/break_timer_ring.dart`
- Create: `lib/features/break_timer/widgets/break_actions.dart`

**Implementation spec:**

**break_timer_page.dart:** ConsumerStatefulWidget with TickerProviderStateMixin. State: timeLeft, phase (celebration/recovery). If justCompleted, phase starts as celebration, 3500ms timer switches to recovery. Recovery: Timer.periodic 1s decrement. timeLeft 0 → context.go('/'). Overall page fades in over 700ms. Uses AnimatedSwitcher for celebration↔recovery transition.

**celebration_state.dart:** Receives breakMinutes. Entry: translateY 20→0, opacity 0→1, 800ms easeOut. Exit: translateY 0→-20, opacity→0, blur 0→10, 700ms. Contains: success icon circle (emerald-100 bg, check SVG in emerald-600), "Session completed" title, "Nice work. Step away for X min." subtitle. Icon: ScaleTransition 0.8→1 with elasticOut, 300ms delay. Title: FadeTransition + SlideTransition, 600ms delay. Subtitle: FadeTransition, 1200ms delay.

**recovery_state.dart:** Entry: FadeTransition + ScaleTransition 0.95→1 + blur 8→0, 1200ms easeOut. Contains: Coffee icon in neutral circle, "Recovery" heading, "Resting after: {task title}" if task exists, BreakTimerRing, BreakActions.

**break_timer_ring.dart:** ProgressRing with size 256. Background: neutral-200, 4px. Active: neutral-800, 4px. Progress derived from elapsed/initial.

**break_actions.dart:** Entry: SlideTransition translateY 20→0 + FadeTransition, 500ms delay, 800ms duration. Primary CTA: "Continue {task.title}" (dark bg, white text, Play icon) — only shows if task exists and not completed. Secondary CTA: "Back to tasks" (ArrowLeft icon) — text-like if primary exists, dark filled if no primary. PressScaleButton 0.98 on primary.

**Commit:**

```bash
git add lib/features/break_timer/
git commit -m "feat: implement Break timer page with celebration and recovery states"
```

---

## Task 14: History Page

**Files:**
- Rewrite: `lib/features/history/history_page.dart`
- Create: `lib/features/history/widgets/rhythm_bar_chart.dart`
- Create: `lib/features/history/widgets/stat_card.dart`
- Create: `lib/features/history/widgets/top_focus_areas.dart`
- Create: `lib/features/history/widgets/session_log.dart`

**Implementation spec:**

**history_page.dart:** ConsumerWidget. Computes: totalSessions, totalSeconds, timeStr, rhythmData (7 days), maxMins, taskStats, topTasks (top 5), groupedSessions. Wraps in PageEntryAnimation. SingleChildScrollView with Column: heading section, RhythmBarChart, stat cards grid, TopFocusAreas, SessionLog.

**rhythm_bar_chart.dart:** White card, rounded-3xl, border, shadow-sm, p24. "Last 7 Days" label with Activity icon. Row of 7 bar columns, height 128. Each bar: TweenAnimationBuilder from 0→targetHeight%, 800ms, delay index×100ms, easeOutBack curve. Today bar: neutral-900 + shadow. Other bars: neutral-200 (zero=neutral-100). Hover tooltip on desktop: AnimatedOpacity 150ms showing "Xh Ym" in dark pill above bar.

**stat_card.dart:** White card, rounded-2xl, border, shadow-sm, p20. Icon in neutral-100 rounded-xl box. Label (labelUppercase, neutral-500). Value (heading2xl, neutral-900). Entry: TweenAnimationBuilder opacity 0→1, scale 0.95→1, 400ms. Three cards in grid: Total Focus (Timer icon), Sessions (Trophy icon), Active Projects (Layers icon).

**top_focus_areas.dart:** Section with "Top Focus Areas" heading. White card, rounded-2xl, border, shadow-sm. List of rows with dividers. Each row: task title, project badge, session count, duration. Entry: staggered by index×100ms, opacity + translateY. Hover: bg neutral-50.

**session_log.dart:** Section with "Session Log" heading. If empty: dashed border empty state with Clock icon. Otherwise: grouped by date label (Today/Yesterday/formatted). Each group: label (labelUppercase, neutral-400) + white card with session rows. Each row: title + project badge, "Completed X ago", duration, time. Entry: staggered groupIndex×100ms + rowIndex×50ms. Hover: bg neutral-50.

**Commit:**

```bash
git add lib/features/history/
git commit -m "feat: implement History page with rhythm chart, stats, and session log"
```

---

## Task 15: Auth Page

**Files:**
- Rewrite: `lib/features/auth/auth_page.dart`
- Create: `lib/features/auth/widgets/auth_background_blobs.dart`
- Create: `lib/features/auth/widgets/auth_card.dart`
- Create: `lib/features/auth/widgets/auth_input_field.dart`
- Create: `lib/features/auth/widgets/shimmer_button.dart`
- Create: `lib/features/auth/widgets/floating_sparkles.dart`

**Implementation spec:**

**auth_page.dart:** ConsumerStatefulWidget with TickerProviderStateMixin. State: isSignUp, email, password, name, isLoading, focusedField. Main layout: Stack with AuthBackgroundBlobs and centered AuthCard. Min height 85vh equivalent.

**auth_background_blobs.dart:** StatefulWidget with TickerProviderStateMixin. Two AnimationControllers with repeat(reverse: true). Blob A: 600×600, gradient circle, blurred (blur 48+), scale 1↔1.1, opacity 0.3↔0.4, 8s easeInOut. Blob B: 400×400, blurred, scale 1↔1.2, opacity 0.2↔0.3, 10s easeInOut, 1s initial delay. Position: center-ish with offsets. Use AnimatedBuilder driving ScaleTransition + FadeTransition on each Container.

**auth_card.dart:** StatefulWidget with TickerProviderStateMixin. Container entry: FadeTransition + ScaleTransition 0.98→1, 500ms, smoothCurve. Glass effect: white/70 bg, BackdropFilter blur 20, rounded-[32px], shadow xl, border white/50. Inner highlight: gradient line at top. Children staggered by 100ms using Interval curves on a single master controller.

Content from top: Logo (AppLogoIcon with glow, MouseRegion hover increases glow opacity), Title (AnimatedSwitcher 300ms, "Join Rhythm" / "Welcome back"), Description (AnimatedSwitcher 300ms with blur), Form fields (name only in signUp mode via AnimatedSize+AnimatedOpacity+AnimatedScale 350ms, email, password — all AuthInputField), ShimmerButton, mode switch footer ("Already have an account? Sign in" / "Don't have an account? Sign up" with underline hover animation).

**auth_input_field.dart:** Container with AnimatedContainer for border/shadow/bg transitions 300ms. Contains icon (AnimatedDefaultTextStyle for color) + TextField. Focused: dark border, shadow ring, darker icon, whiter bg. Unfocused: light border, muted icon, translucent bg.

**shimmer_button.dart:** StatefulWidget with TickerProviderStateMixin. Dark filled button, rounded-2xl, shadow. ShaderMask with animated LinearGradient for shimmer sweep (1.5s repeat). MouseRegion: hover starts shimmer + shadow increase + translateY(-2). Press: return to rest. Loading state: AnimatedSwitcher swaps label for spinning circle (RotationTransition 1s linear repeat). Label: AnimatedSwitcher for "Continue" ↔ "Create Account" (translateY 5↔-5, 200ms).

**floating_sparkles.dart:** Only visible when isSignUp && screen width ≥ 1024. AnimatedOpacity + AnimatedScale 0.8→1 enter/exit. Sparkles icon with continuous pulse (AnimationController repeat, ScaleTransition).

**Commit:**

```bash
git add lib/features/auth/
git commit -m "feat: implement Auth page with glassmorphism, blobs, shimmer, and all animations"
```

---

## Task 16: Polish — Responsive Tuning and Hover States

**Files:** Various existing files

**Step 1:** Verify all layouts at mobile (<768px) and desktop (≥768px) breakpoints. Fix any overflow or spacing issues.

**Step 2:** Add MouseRegion hover states for desktop:
- Task row: shadow-md on hover
- Nav tabs: text color transition
- Stat cards: subtle bg transition
- Focus area rows: bg neutral-50
- Session log rows: bg neutral-50
- Auth mode switch: underline scaleX 0→1

**Step 3:** Verify that all text truncates correctly (task titles, project names). Use `overflow: TextOverflow.ellipsis` and `maxLines: 1`.

**Step 4:** Test focus ring on all input fields (composer, auth fields, search).

**Step 5:** Verify safe areas: bottom padding on mobile for bottom nav overlap, top safe area for status bar.

**Step 6:** Run full analysis and fix any warnings.

```bash
flutter analyze
flutter test
```

**Step 7: Commit**

```bash
git add -A
git commit -m "polish: responsive tuning, hover states, and final fidelity pass"
```

---

## Task 17: Final Verification

**Step 1:** Run the complete test suite.

```bash
flutter test
```

**Step 2:** Run flutter analyze.

```bash
flutter analyze
```

**Step 3:** Run the app on web, iOS simulator, and/or Android emulator. Manually verify:

- [ ] Home page loads with seed data
- [ ] Today header shows correct summary
- [ ] Next Focus hero appears for first incomplete task
- [ ] Task composer adds tasks
- [ ] Post-create affordance shows and auto-hides at 4s
- [ ] Project dropdown works (select + create new)
- [ ] Preset picker opens and starts session
- [ ] Task checkbox toggles completion
- [ ] Task overflow menu delete works
- [ ] Search and filters appear at ≥5 tasks
- [ ] Clear completed works
- [ ] Focus screen intro ceremony plays correctly (title→timer→controls, 2.5s phase switch)
- [ ] Focus timer counts down, pauses, resumes
- [ ] Abandon returns home, Save & End saves and goes to break
- [ ] Natural completion goes to break with completed=true
- [ ] Break celebration plays for 3.5s then transitions to recovery
- [ ] Break timer counts down, returns home at 0
- [ ] Continue task starts new focus session
- [ ] History shows correct calculations
- [ ] Rhythm bars animate on entry
- [ ] Session log groups correctly
- [ ] Auth page blobs animate
- [ ] Sign in / sign up toggle animates title, description, name field
- [ ] Shimmer button hover works
- [ ] Loading spinner shows on submit
- [ ] Sparkles appear only in sign up mode on large screens
- [ ] Mobile bottom nav indicator slides between tabs
- [ ] Desktop segmented nav highlights active tab

**Step 4: Final commit**

```bash
git add -A
git commit -m "feat: Rhythm Flutter rebuild complete — all pages, interactions, and animations"
```

---

## Summary

| Task | Description | Depends On |
|---|---|---|
| 1 | Project setup, pubspec, fonts | — |
| 2 | Theme design tokens | 1 |
| 3 | Data models | 1 |
| 4 | Repositories | 3 |
| 5 | Store + Riverpod providers | 4 |
| 6 | Shared utilities | 1 |
| 7 | Shared widgets (foundation) | 2 |
| 8 | Router + placeholder pages | 2, 5 |
| 9 | App shell (headers + bottom nav) | 7, 8 |
| 10 | Home page — all widgets | 5, 7, 9 |
| 11 | Home page — overlays and interactions | 10 |
| 12 | Focus timer page | 5, 7 |
| 13 | Break timer page | 5, 7 |
| 14 | History page | 5, 6, 7 |
| 15 | Auth page | 5, 7 |
| 16 | Polish pass | 10–15 |
| 17 | Final verification | 16 |
