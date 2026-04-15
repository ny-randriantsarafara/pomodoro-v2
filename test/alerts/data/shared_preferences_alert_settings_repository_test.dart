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

  test('repository persists and reloads settings', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = SharedPreferencesAlertSettingsRepository(prefs);

    const updated = AlertSettings(
      notificationsEnabled: false,
      soundEnabled: true,
    );
    await repo.save(updated);

    expect(await repo.load(), updated);
  });

  test('repository persists sound toggle independently', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = SharedPreferencesAlertSettingsRepository(prefs);

    const updated = AlertSettings(
      notificationsEnabled: true,
      soundEnabled: false,
    );
    await repo.save(updated);

    expect(await repo.load(), updated);
  });
}
