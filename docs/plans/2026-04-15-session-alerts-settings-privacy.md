# Session Alerts, Settings, and Privacy Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add reliable cross-platform session-complete alerts for focus and break timers, a dedicated Settings page for alert preferences and account actions, and a public Privacy Policy page for web/App Store review.

**Architecture:** Keep the current timer pages intact, but introduce a small alert domain, a `SharedPreferences`-backed settings repository, a lifecycle-oriented `SessionAlertCoordinator`, and thin platform adapters for notifications and sound. Native reliability comes from scheduling/cancelling notifications at session start/stop, while completion-time code handles in-app sound, cleanup, and foreground fallback.

**Tech Stack:** Flutter, Riverpod providers, SharedPreferences, `flutter_local_notifications`, `audioplayers` (or equivalent lightweight asset-audio package) behind an adapter, browser Notification API for web, widget/unit tests with `flutter_test`

## Documentation and Artifact Disposition

- **Temporary artifacts:**
  - `docs/plans/2026-04-15-session-alerts-settings-privacy-design.md`
  - `docs/plans/2026-04-15-session-alerts-settings-privacy.md`
- **Promote if validated:**
  - `README.md` (new Settings route + privacy availability)
  - durable platform-notes doc only if notification caveats become long-lived maintenance knowledge
- **Delete if not durable:**
  - both `docs/plans/2026-04-15-*.md` files once implementation knowledge is promoted elsewhere and the working artifacts no longer add value

---

### Task 1: Build the pure alert domain

**Files:**
- Create: `lib/alerts/domain/alert_kind.dart`
- Create: `lib/alerts/domain/alert_settings.dart`
- Create: `lib/alerts/domain/alert_capabilities.dart`
- Create: `lib/alerts/domain/alert_plan.dart`
- Create: `lib/alerts/domain/alert_rules.dart`
- Create: `lib/alerts/alerts.dart`
- Test: `test/alerts/domain/alert_rules_test.dart`

**Step 1: Write the failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:rhythm/alerts/alerts.dart';

void main() {
  test('focus completion schedules notification and sound when both toggles are on', () {
    final plan = buildCompletionAlertPlan(
      kind: AlertKind.focusCompleted,
      settings: const AlertSettings(
        notificationsEnabled: true,
        soundEnabled: true,
      ),
      capabilities: const AlertCapabilities(
        canNotify: true,
        canPlaySound: true,
      ),
    );

    expect(plan.showNotification, isTrue);
    expect(plan.playSound, isTrue);
    expect(plan.soundAsset, 'assets/sounds/focus-complete.wav');
    expect(plan.notificationChannelId, 'focus_complete');
  });

  test('break completion skips notification when notifications are disabled', () {
    final plan = buildCompletionAlertPlan(
      kind: AlertKind.breakCompleted,
      settings: const AlertSettings(
        notificationsEnabled: false,
        soundEnabled: true,
      ),
      capabilities: const AlertCapabilities(
        canNotify: true,
        canPlaySound: true,
      ),
    );

    expect(plan.showNotification, isFalse);
    expect(plan.playSound, isTrue);
    expect(plan.soundAsset, 'assets/sounds/break-complete.wav');
  });
}
```

**Step 2: Run test to verify it fails**

Run:
```bash
flutter test test/alerts/domain/alert_rules_test.dart -r compact
```

Expected: FAIL with missing `rhythm/alerts/alerts.dart` imports and undefined alert types/functions.

**Step 3: Write minimal implementation**

```dart
enum AlertKind { focusCompleted, breakCompleted }

class AlertSettings {
  final bool notificationsEnabled;
  final bool soundEnabled;
  const AlertSettings({
    required this.notificationsEnabled,
    required this.soundEnabled,
  });
}

class AlertCapabilities {
  final bool canNotify;
  final bool canPlaySound;
  const AlertCapabilities({required this.canNotify, required this.canPlaySound});
}

class AlertPlan {
  final bool showNotification;
  final bool playSound;
  final String? soundAsset;
  final String notificationChannelId;
  const AlertPlan({
    required this.showNotification,
    required this.playSound,
    required this.soundAsset,
    required this.notificationChannelId,
  });
}

AlertPlan buildCompletionAlertPlan({
  required AlertKind kind,
  required AlertSettings settings,
  required AlertCapabilities capabilities,
}) {
  final isFocus = kind == AlertKind.focusCompleted;
  return AlertPlan(
    showNotification: settings.notificationsEnabled && capabilities.canNotify,
    playSound: settings.soundEnabled && capabilities.canPlaySound,
    soundAsset: isFocus
        ? 'assets/sounds/focus-complete.wav'
        : 'assets/sounds/break-complete.wav',
    notificationChannelId: isFocus ? 'focus_complete' : 'break_complete',
  );
}
```

**Step 4: Run test to verify it passes**

Run:
```bash
flutter test test/alerts/domain/alert_rules_test.dart -r compact
```

Expected: PASS

**Step 5: Commit**

```bash
git add lib/alerts test/alerts/domain/alert_rules_test.dart
git commit -m "feat: add alert domain rules"
```

### Task 2: Persist alert settings and expose them via providers

**Files:**
- Create: `lib/alerts/data/alert_settings_repository.dart`
- Create: `lib/alerts/data/shared_preferences_alert_settings_repository.dart`
- Create: `lib/alerts/application/alert_settings_controller.dart`
- Modify: `lib/store/providers.dart`
- Test: `test/alerts/data/shared_preferences_alert_settings_repository_test.dart`
- Test: `test/alerts/application/alert_settings_controller_test.dart`

**Step 1: Write the failing tests**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:rhythm/alerts/alerts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('repository returns defaults when prefs are empty', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = SharedPreferencesAlertSettingsRepository(prefs);

    expect(
      await repo.load(),
      const AlertSettings(notificationsEnabled: true, soundEnabled: true),
    );
  });
}
```

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:rhythm/alerts/alerts.dart';

void main() {
  test('controller updates notifications toggle and persists it', () async {
    final repo = InMemoryAlertSettingsRepository(
      const AlertSettings(notificationsEnabled: true, soundEnabled: true),
    );
    final controller = AlertSettingsController(repo);

    await controller.load();
    await controller.setNotificationsEnabled(false);

    expect(controller.value.notificationsEnabled, isFalse);
    expect(await repo.load(), controller.value);
  });
}
```

**Step 2: Run tests to verify they fail**

Run:
```bash
flutter test test/alerts/data/shared_preferences_alert_settings_repository_test.dart test/alerts/application/alert_settings_controller_test.dart -r compact
```

Expected: FAIL with missing repository/controller classes.

**Step 3: Write minimal implementation**

```dart
abstract class AlertSettingsRepository {
  Future<AlertSettings> load();
  Future<void> save(AlertSettings settings);
}

class SharedPreferencesAlertSettingsRepository implements AlertSettingsRepository {
  static const notificationsKey = 'alert_notifications_enabled';
  static const soundKey = 'alert_sound_enabled';

  final SharedPreferences _prefs;
  SharedPreferencesAlertSettingsRepository(this._prefs);

  @override
  Future<AlertSettings> load() async => AlertSettings(
        notificationsEnabled: _prefs.getBool(notificationsKey) ?? true,
        soundEnabled: _prefs.getBool(soundKey) ?? true,
      );

  @override
  Future<void> save(AlertSettings settings) async {
    await _prefs.setBool(notificationsKey, settings.notificationsEnabled);
    await _prefs.setBool(soundKey, settings.soundEnabled);
  }
}
```

```dart
class AlertSettingsController extends ChangeNotifier {
  final AlertSettingsRepository _repo;
  AlertSettings _value = const AlertSettings(
    notificationsEnabled: true,
    soundEnabled: true,
  );

  AlertSettingsController(this._repo);

  AlertSettings get value => _value;

  Future<void> load() async {
    _value = await _repo.load();
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _value = AlertSettings(
      notificationsEnabled: enabled,
      soundEnabled: _value.soundEnabled,
    );
    await _repo.save(_value);
    notifyListeners();
  }
}
```

Also add Riverpod providers in `lib/store/providers.dart`:

```dart
final alertSettingsRepositoryProvider = Provider<AlertSettingsRepository>((ref) {
  return SharedPreferencesAlertSettingsRepository(
    ref.watch(sharedPreferencesProvider),
  );
});

final alertSettingsControllerProvider = ChangeNotifierProvider<AlertSettingsController>((ref) {
  final controller = AlertSettingsController(ref.watch(alertSettingsRepositoryProvider));
  controller.load();
  return controller;
});
```

**Step 4: Run tests to verify they pass**

Run:
```bash
flutter test test/alerts/data/shared_preferences_alert_settings_repository_test.dart test/alerts/application/alert_settings_controller_test.dart -r compact
```

Expected: PASS

**Step 5: Commit**

```bash
git add lib/store/providers.dart lib/alerts test/alerts/data test/alerts/application
git commit -m "feat: persist alert settings"
```

### Task 3: Add the session alert coordinator and platform adapter seams

**Files:**
- Create: `lib/alerts/platform/notification_adapter.dart`
- Create: `lib/alerts/platform/sound_adapter.dart`
- Create: `lib/alerts/platform/flutter_local_notifications_adapter.dart`
- Create: `lib/alerts/platform/browser_notification_adapter_stub.dart`
- Create: `lib/alerts/platform/browser_notification_adapter_web.dart`
- Create: `lib/alerts/platform/browser_notification_adapter.dart`
- Create: `lib/alerts/platform/audioplayers_sound_adapter.dart`
- Create: `lib/alerts/application/session_alert_coordinator.dart`
- Modify: `lib/alerts/alerts.dart`
- Modify: `lib/store/providers.dart`
- Modify: `pubspec.yaml`
- Test: `test/alerts/application/session_alert_coordinator_test.dart`

**Step 1: Write the failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:rhythm/alerts/alerts.dart';

void main() {
  test('onSessionStarted schedules a focus-complete notification', () async {
    final notifications = RecordingNotificationAdapter();
    final sounds = RecordingSoundAdapter();
    final repo = InMemoryAlertSettingsRepository(
      const AlertSettings(notificationsEnabled: true, soundEnabled: true),
    );
    final coordinator = SessionAlertCoordinator(
      settingsRepository: repo,
      notificationAdapter: notifications,
      soundAdapter: sounds,
      capabilities: const AlertCapabilities(canNotify: true, canPlaySound: true),
    );

    final endsAt = DateTime(2026, 4, 15, 10, 30);
    await coordinator.onSessionStarted(SessionType.focus, endsAt);

    expect(notifications.scheduled.single.kind, AlertKind.focusCompleted);
    expect(notifications.scheduled.single.scheduledFor, endsAt);
    expect(sounds.played, isEmpty);
  });

  test('onSessionCompleted plays break sound when sound is enabled', () async {
    final notifications = RecordingNotificationAdapter();
    final sounds = RecordingSoundAdapter();
    final repo = InMemoryAlertSettingsRepository(
      const AlertSettings(notificationsEnabled: true, soundEnabled: true),
    );
    final coordinator = SessionAlertCoordinator(
      settingsRepository: repo,
      notificationAdapter: notifications,
      soundAdapter: sounds,
      capabilities: const AlertCapabilities(canNotify: true, canPlaySound: true),
    );

    await coordinator.onSessionCompleted(SessionType.breakTime);

    expect(sounds.played.single, 'assets/sounds/break-complete.wav');
  });
}
```

**Step 2: Run test to verify it fails**

Run:
```bash
flutter test test/alerts/application/session_alert_coordinator_test.dart -r compact
```

Expected: FAIL with missing coordinator, adapters, or session type definitions.

**Step 3: Write minimal implementation**

Add interfaces:

```dart
abstract class NotificationAdapter {
  Future<void> schedule({
    required AlertKind kind,
    required DateTime scheduledFor,
  });

  Future<void> cancelActiveSessionAlert();
}

abstract class SoundAdapter {
  Future<void> play(String assetPath);
}
```

Add coordinator:

```dart
enum SessionType { focus, breakTime }

class SessionAlertCoordinator {
  final AlertSettingsRepository settingsRepository;
  final NotificationAdapter notificationAdapter;
  final SoundAdapter soundAdapter;
  final AlertCapabilities capabilities;

  SessionAlertCoordinator({
    required this.settingsRepository,
    required this.notificationAdapter,
    required this.soundAdapter,
    required this.capabilities,
  });

  Future<void> onSessionStarted(SessionType type, DateTime endsAt) async {
    final settings = await settingsRepository.load();
    if (!settings.notificationsEnabled || !capabilities.canNotify) return;
    await notificationAdapter.schedule(
      kind: type == SessionType.focus
          ? AlertKind.focusCompleted
          : AlertKind.breakCompleted,
      scheduledFor: endsAt,
    );
  }

  Future<void> onSessionCancelledOrReset() =>
      notificationAdapter.cancelActiveSessionAlert();

  Future<void> onSessionCompleted(SessionType type) async {
    await notificationAdapter.cancelActiveSessionAlert();
    final settings = await settingsRepository.load();
    final plan = buildCompletionAlertPlan(
      kind: type == SessionType.focus
          ? AlertKind.focusCompleted
          : AlertKind.breakCompleted,
      settings: settings,
      capabilities: capabilities,
    );
    if (plan.playSound && plan.soundAsset != null) {
      await soundAdapter.play(plan.soundAsset!);
    }
  }
}
```

Add providers that choose:
- `FlutterLocalNotificationsAdapter` on native platforms
- `BrowserNotificationAdapter` on web
- `AudioplayersSoundAdapter` for asset playback

Update `pubspec.yaml`:

```yaml
dependencies:
  flutter_local_notifications: ^17.2.0
  audioplayers: ^6.0.0

flutter:
  assets:
    - assets/sounds/
```

Create the two sound files:
- `assets/sounds/focus-complete.wav`
- `assets/sounds/break-complete.wav`

**Step 4: Run tests to verify they pass**

Run:
```bash
flutter test test/alerts/application/session_alert_coordinator_test.dart -r compact
flutter analyze
```

Expected: PASS and no analyzer errors from new alert adapter/provider files.

**Step 5: Commit**

```bash
git add pubspec.yaml lib/alerts lib/store/providers.dart assets/sounds test/alerts/application/session_alert_coordinator_test.dart
git commit -m "feat: add session alert coordinator"
```

### Task 4: Add the dedicated Settings page and route account entry there

**Files:**
- Create: `lib/features/settings/settings_page.dart`
- Modify: `lib/router/app_router.dart`
- Modify: `lib/features/layout/desktop_header.dart`
- Modify: `lib/features/layout/mobile_header.dart`
- Test: `test/features/settings/settings_page_test.dart`
- Modify: `test/features/layout/app_shell_test.dart`

**Step 1: Write the failing tests**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rhythm/app.dart';
import '../helpers/test_repositories.dart';

void main() {
  testWidgets('settings page shows alert toggles and account actions', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taskRepositoryProvider.overrideWithValue(TestTaskRepository()),
          projectRepositoryProvider.overrideWithValue(TestProjectRepository()),
          sessionRepositoryProvider.overrideWithValue(TestSessionRepository()),
          authRepositoryProvider.overrideWithValue(TestAuthRepository()),
          alertSettingsControllerProvider.overrideWith((ref) => FakeAlertSettingsController()),
        ],
        child: const RhythmApp(),
      ),
    );

    // Navigate to /settings in the test app setup or tap the account entry.
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Sound'), findsOneWidget);
    expect(find.text('Sign Out'), findsOneWidget);
    expect(find.text('Delete Account'), findsOneWidget);
  });
}
```

In `test/features/layout/app_shell_test.dart`, replace the inline popup expectation with a route expectation after tapping the header action.

**Step 2: Run tests to verify they fail**

Run:
```bash
flutter test test/features/settings/settings_page_test.dart test/features/layout/app_shell_test.dart -r compact
```

Expected: FAIL because `/settings` and `SettingsPage` do not exist yet.

**Step 3: Write minimal implementation**

Add route:

```dart
GoRoute(
  path: '/settings',
  pageBuilder: (context, state) => const NoTransitionPage(
    child: SettingsPage(),
  ),
),
```

Add Settings page sections:

```dart
SwitchListTile(
  title: const Text('Notifications'),
  value: settings.notificationsEnabled,
  onChanged: controller.setNotificationsEnabled,
),
SwitchListTile(
  title: const Text('Sound'),
  value: settings.soundEnabled,
  onChanged: controller.setSoundEnabled,
),
ListTile(
  title: const Text('Privacy Policy'),
  onTap: () => context.go('/privacy'),
),
FilledButton(
  onPressed: authRepo.signOut,
  child: const Text('Sign Out'),
),
TextButton(
  onPressed: () => _showDeleteConfirmation(context, authRepo),
  child: const Text('Delete Account'),
),
```

Update header actions to route to `/settings` instead of showing inline account menus.

**Step 4: Run tests to verify they pass**

Run:
```bash
flutter test test/features/settings/settings_page_test.dart test/features/layout/app_shell_test.dart -r compact
```

Expected: PASS

**Step 5: Commit**

```bash
git add lib/features/settings lib/router/app_router.dart lib/features/layout/desktop_header.dart lib/features/layout/mobile_header.dart test/features/settings/settings_page_test.dart test/features/layout/app_shell_test.dart
git commit -m "feat: add settings page"
```

### Task 5: Add the public Privacy Policy page and link it from Settings

**Files:**
- Create: `lib/features/privacy/privacy_policy_page.dart`
- Modify: `lib/router/app_router.dart`
- Modify: `test/widget_test.dart`
- Test: `test/features/privacy/privacy_policy_page_test.dart`
- Modify: `README.md`

**Step 1: Write the failing tests**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rhythm/app.dart';
import '../helpers/test_repositories.dart';

void main() {
  testWidgets('privacy page is reachable without authentication', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taskRepositoryProvider.overrideWithValue(TestTaskRepository()),
          projectRepositoryProvider.overrideWithValue(TestProjectRepository()),
          sessionRepositoryProvider.overrideWithValue(TestSessionRepository()),
          authRepositoryProvider.overrideWithValue(TestAuthRepository(isAuthenticated: false)),
        ],
        child: const RhythmApp(),
      ),
    );

    // Start the router at /privacy in the test setup.
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.textContaining('tasks, projects, and sessions'), findsOneWidget);
    expect(find.textContaining('Delete Account'), findsOneWidget);
  });
}
```

**Step 2: Run tests to verify they fail**

Run:
```bash
flutter test test/features/privacy/privacy_policy_page_test.dart test/widget_test.dart -r compact
```

Expected: FAIL because `PrivacyPolicyPage` and `/privacy` do not exist.

**Step 3: Write minimal implementation**

Add public route:

```dart
GoRoute(
  path: '/privacy',
  pageBuilder: (context, state) => const NoTransitionPage(
    child: PrivacyPolicyPage(),
  ),
),
```

Add page copy that truthfully covers:
- authentication providers used
- signed-in cloud data: tasks, projects, sessions
- local preferences for app settings
- local notifications if enabled
- account deletion availability
- policy update language

Update `README.md` route table with `/settings` and `/privacy`.

**Step 4: Run tests to verify they pass**

Run:
```bash
flutter test test/features/privacy/privacy_policy_page_test.dart test/widget_test.dart -r compact
```

Expected: PASS

**Step 5: Commit**

```bash
git add lib/features/privacy lib/router/app_router.dart README.md test/features/privacy/privacy_policy_page_test.dart test/widget_test.dart
git commit -m "feat: add public privacy policy page"
```

### Task 6: Wire timer lifecycle into the coordinator and verify end-to-end behavior

**Files:**
- Modify: `lib/features/focus/focus_timer_page.dart`
- Modify: `lib/features/break_timer/break_timer_page.dart`
- Modify: `test/alerts/application/session_alert_coordinator_test.dart`
- Modify: `docs/plans/2026-04-15-session-alerts-settings-privacy-design.md` (only if implementation reality meaningfully diverges)

**Step 1: Extend the failing coordinator test for lifecycle order**

```dart
test('cancel followed by restart only keeps the latest scheduled alert', () async {
  final notifications = RecordingNotificationAdapter();
  final coordinator = buildCoordinator(notifications: notifications);

  await coordinator.onSessionStarted(SessionType.focus, DateTime(2026, 4, 15, 9, 0));
  await coordinator.onSessionCancelledOrReset();
  await coordinator.onSessionStarted(SessionType.focus, DateTime(2026, 4, 15, 9, 30));

  expect(notifications.cancelCount, 1);
  expect(notifications.scheduled.single.scheduledFor, DateTime(2026, 4, 15, 9, 30));
});
```

**Step 2: Run the test to verify it fails if restart/cancel semantics are incomplete**

Run:
```bash
flutter test test/alerts/application/session_alert_coordinator_test.dart -r compact
```

Expected: FAIL if the coordinator does not cancel stale alerts before rescheduling.

**Step 3: Write minimal implementation in the timer pages**

In `FocusTimerPage`:
- on the transition into active focus, call `coordinator.onSessionStarted(SessionType.focus, endTime)`
- on pause/resume that changes the effective end time, cancel and reschedule
- on abandon/save-end, call `onSessionCancelledOrReset()` before navigation
- on complete, persist the session, call `onSessionCompleted(SessionType.focus)`, then navigate to break

In `BreakTimerPage`:
- when break countdown becomes active, call `onSessionStarted(SessionType.breakTime, endTime)`
- if the page exits early, call `onSessionCancelledOrReset()`
- on completion, call `onSessionCompleted(SessionType.breakTime)` before navigating home

Use `ref.read(sessionAlertCoordinatorProvider)` so the widgets stay thin.

**Step 4: Run verification**

Run:
```bash
flutter test test/alerts/application/session_alert_coordinator_test.dart -r compact
flutter test -r compact
flutter analyze
```

Expected: PASS

Then do manual verification:
- Start a focus session, background the app, confirm a focus-complete notification arrives
- Complete a focus session in foreground, confirm focus sound plays once and no duplicate stale alert appears later
- Let break finish, confirm break sound differs from focus sound
- Toggle notifications off in Settings, start a new session, confirm no notification is scheduled
- Toggle sound off in Settings, complete a session in foreground, confirm silence
- Open `/privacy` on web without auth and confirm content loads

**Step 5: Commit**

```bash
git add lib/features/focus/focus_timer_page.dart lib/features/break_timer/break_timer_page.dart test/alerts/application/session_alert_coordinator_test.dart README.md
git commit -m "feat: wire timer lifecycle into alerts"
```

### Task 7: Final verification and artifact review

**Files:**
- Review: `docs/plans/2026-04-15-session-alerts-settings-privacy-design.md`
- Review: `docs/plans/2026-04-15-session-alerts-settings-privacy.md`
- Modify if needed: `README.md`

**Step 1: Run the full verification suite**

Run:
```bash
flutter test -r compact
flutter analyze
```

Expected: PASS

**Step 2: Confirm documentation disposition**

Checklist:
- If `README.md` now fully documents Settings and Privacy, leave the plan docs as temporary artifacts only
- If notification caveats became durable knowledge, promote them to a permanent doc and trim the temporary plan docs later

**Step 3: Review working tree before merge/PR**

Run:
```bash
git status --short
```

Expected: only intentional feature files remain modified.

**Step 4: Commit any final doc touch-ups**

```bash
git add README.md docs/plans/2026-04-15-session-alerts-settings-privacy-design.md docs/plans/2026-04-15-session-alerts-settings-privacy.md
git commit -m "docs: finalize alerts and privacy implementation notes"
```
