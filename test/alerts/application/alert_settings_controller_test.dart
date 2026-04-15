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

  test('controller updates sound toggle and persists it', () async {
    final repo = InMemoryAlertSettingsRepository(
      const AlertSettings(notificationsEnabled: true, soundEnabled: true),
    );
    final controller = AlertSettingsController(repo);

    await controller.load();
    await controller.setSoundEnabled(false);

    expect(controller.value.soundEnabled, isFalse);
    expect(await repo.load(), controller.value);
  });

  test('controller loads persisted state', () async {
    final repo = InMemoryAlertSettingsRepository(
      const AlertSettings(notificationsEnabled: false, soundEnabled: false),
    );
    final controller = AlertSettingsController(repo);

    await controller.load();

    expect(controller.value.notificationsEnabled, isFalse);
    expect(controller.value.soundEnabled, isFalse);
  });
}
