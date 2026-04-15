import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../domain/alert_kind.dart';
import 'notification_adapter.dart';

class FlutterLocalNotificationsAdapter implements NotificationAdapter {
  static const _sessionNotificationId = 1;

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  FlutterLocalNotificationsAdapter(this._plugin);

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestSoundPermission: true,
    );
    const macosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: macosSettings,
    );
    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  @override
  Future<void> schedule({
    required AlertKind kind,
    required DateTime scheduledFor,
  }) async {
    await _ensureInitialized();
    final isFocus = kind == AlertKind.focusCompleted;
    final title = isFocus ? 'Focus Complete' : 'Break Complete';
    final body = isFocus
        ? 'Great work! Time for a break.'
        : 'Break is over. Ready to focus again?';
    final channelId = isFocus ? 'focus_complete' : 'break_complete';
    final channelName = isFocus ? 'Focus Alerts' : 'Break Alerts';

    await _plugin.zonedSchedule(
      _sessionNotificationId,
      title,
      body,
      tz.TZDateTime.from(scheduledFor, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  @override
  Future<void> cancelActiveSessionAlert() async {
    await _plugin.cancel(_sessionNotificationId);
  }
}
