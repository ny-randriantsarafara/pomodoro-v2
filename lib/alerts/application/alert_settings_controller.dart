import 'package:flutter/foundation.dart';
import '../data/alert_settings_repository.dart';
import '../domain/alert_settings.dart';

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

  Future<void> setSoundEnabled(bool enabled) async {
    _value = AlertSettings(
      notificationsEnabled: _value.notificationsEnabled,
      soundEnabled: enabled,
    );
    await _repo.save(_value);
    notifyListeners();
  }
}
