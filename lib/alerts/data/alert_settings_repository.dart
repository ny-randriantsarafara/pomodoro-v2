import '../domain/alert_settings.dart';

abstract class AlertSettingsRepository {
  Future<AlertSettings> load();
  Future<void> save(AlertSettings settings);
}

class InMemoryAlertSettingsRepository implements AlertSettingsRepository {
  AlertSettings _settings;

  InMemoryAlertSettingsRepository(this._settings);

  @override
  Future<AlertSettings> load() async => _settings;

  @override
  Future<void> save(AlertSettings settings) async {
    _settings = settings;
  }
}
