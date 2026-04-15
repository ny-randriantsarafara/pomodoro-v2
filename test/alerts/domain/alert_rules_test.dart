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

  test('focus completion skips sound when sound is disabled', () {
    final plan = buildCompletionAlertPlan(
      kind: AlertKind.focusCompleted,
      settings: const AlertSettings(
        notificationsEnabled: true,
        soundEnabled: false,
      ),
      capabilities: const AlertCapabilities(
        canNotify: true,
        canPlaySound: true,
      ),
    );

    expect(plan.showNotification, isTrue);
    expect(plan.playSound, isFalse);
  });

  test('both skipped when capabilities are unavailable', () {
    final plan = buildCompletionAlertPlan(
      kind: AlertKind.focusCompleted,
      settings: const AlertSettings(
        notificationsEnabled: true,
        soundEnabled: true,
      ),
      capabilities: const AlertCapabilities(
        canNotify: false,
        canPlaySound: false,
      ),
    );

    expect(plan.showNotification, isFalse);
    expect(plan.playSound, isFalse);
  });
}
