import 'package:shared_preferences/shared_preferences.dart';
import '../domain/alert_settings.dart';
import 'alert_settings_repository.dart';

class SharedPreferencesAlertSettingsRepository
    implements AlertSettingsRepository {
  static const _notificationsKey = 'alert_notifications_enabled';
  static const _soundKey = 'alert_sound_enabled';

  final SharedPreferences _prefs;

  SharedPreferencesAlertSettingsRepository(this._prefs);

  @override
  Future<AlertSettings> load() async => AlertSettings(
        notificationsEnabled: _prefs.getBool(_notificationsKey) ?? true,
        soundEnabled: _prefs.getBool(_soundKey) ?? true,
      );

  @override
  Future<void> save(AlertSettings settings) async {
    await _prefs.setBool(_notificationsKey, settings.notificationsEnabled);
    await _prefs.setBool(_soundKey, settings.soundEnabled);
  }
}
