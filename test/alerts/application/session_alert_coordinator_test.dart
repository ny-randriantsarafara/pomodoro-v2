import 'package:flutter_test/flutter_test.dart';
import 'package:rhythm/alerts/alerts.dart';

void main() {
  SessionAlertCoordinator buildCoordinator({
    RecordingNotificationAdapter? notifications,
    RecordingSoundAdapter? sounds,
    AlertSettings settings = const AlertSettings(
      notificationsEnabled: true,
      soundEnabled: true,
    ),
    AlertCapabilities capabilities = const AlertCapabilities(
      canNotify: true,
      canPlaySound: true,
    ),
  }) {
    return SessionAlertCoordinator(
      settingsRepository: InMemoryAlertSettingsRepository(settings),
      notificationAdapter: notifications ?? RecordingNotificationAdapter(),
      soundAdapter: sounds ?? RecordingSoundAdapter(),
      capabilities: capabilities,
    );
  }

  test('onSessionStarted schedules a focus-complete notification', () async {
    final notifications = RecordingNotificationAdapter();
    final sounds = RecordingSoundAdapter();
    final coordinator = buildCoordinator(
      notifications: notifications,
      sounds: sounds,
    );

    final endsAt = DateTime(2026, 4, 15, 10, 30);
    await coordinator.onSessionStarted(SessionType.focus, endsAt);

    expect(notifications.scheduled.single.kind, AlertKind.focusCompleted);
    expect(notifications.scheduled.single.scheduledFor, endsAt);
    expect(sounds.played, isEmpty);
  });

  test('onSessionStarted schedules a break-complete notification', () async {
    final notifications = RecordingNotificationAdapter();
    final coordinator = buildCoordinator(notifications: notifications);

    final endsAt = DateTime(2026, 4, 15, 10, 35);
    await coordinator.onSessionStarted(SessionType.breakTime, endsAt);

    expect(notifications.scheduled.single.kind, AlertKind.breakCompleted);
    expect(notifications.scheduled.single.scheduledFor, endsAt);
  });

  test('onSessionStarted skips scheduling when notifications disabled',
      () async {
    final notifications = RecordingNotificationAdapter();
    final coordinator = buildCoordinator(
      notifications: notifications,
      settings: const AlertSettings(
        notificationsEnabled: false,
        soundEnabled: true,
      ),
    );

    await coordinator.onSessionStarted(
      SessionType.focus,
      DateTime(2026, 4, 15, 10, 30),
    );

    expect(notifications.scheduled, isEmpty);
  });

  test('onSessionCompleted plays break sound when sound is enabled', () async {
    final sounds = RecordingSoundAdapter();
    final coordinator = buildCoordinator(sounds: sounds);

    await coordinator.onSessionCompleted(SessionType.breakTime);

    expect(sounds.played.single, 'assets/sounds/break-complete.wav');
  });

  test('onSessionCompleted plays focus sound when sound is enabled', () async {
    final sounds = RecordingSoundAdapter();
    final coordinator = buildCoordinator(sounds: sounds);

    await coordinator.onSessionCompleted(SessionType.focus);

    expect(sounds.played.single, 'assets/sounds/focus-complete.wav');
  });

  test('onSessionCompleted skips sound when sound is disabled', () async {
    final sounds = RecordingSoundAdapter();
    final coordinator = buildCoordinator(
      sounds: sounds,
      settings: const AlertSettings(
        notificationsEnabled: true,
        soundEnabled: false,
      ),
    );

    await coordinator.onSessionCompleted(SessionType.focus);

    expect(sounds.played, isEmpty);
  });

  test('onSessionCancelledOrReset cancels active notification', () async {
    final notifications = RecordingNotificationAdapter();
    final coordinator = buildCoordinator(notifications: notifications);

    await coordinator.onSessionStarted(
      SessionType.focus,
      DateTime(2026, 4, 15, 10, 30),
    );
    await coordinator.onSessionCancelledOrReset();

    expect(notifications.cancelCount, 1);
  });

  test('cancel followed by restart only keeps the latest scheduled alert',
      () async {
    final notifications = RecordingNotificationAdapter();
    final coordinator = buildCoordinator(notifications: notifications);

    await coordinator.onSessionStarted(
      SessionType.focus,
      DateTime(2026, 4, 15, 9, 0),
    );
    await coordinator.onSessionCancelledOrReset();
    await coordinator.onSessionStarted(
      SessionType.focus,
      DateTime(2026, 4, 15, 9, 30),
    );

    expect(notifications.cancelCount, 1);
    expect(
      notifications.scheduled.last.scheduledFor,
      DateTime(2026, 4, 15, 9, 30),
    );
  });

  test('onSessionCompleted cancels outstanding notification first', () async {
    final notifications = RecordingNotificationAdapter();
    final coordinator = buildCoordinator(notifications: notifications);

    await coordinator.onSessionStarted(
      SessionType.focus,
      DateTime(2026, 4, 15, 10, 30),
    );
    await coordinator.onSessionCompleted(SessionType.focus);

    expect(notifications.cancelCount, 1);
  });
}
