import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../domain/alert_kind.dart';
import 'notification_adapter.dart';

class FlutterLocalNotificationsAdapter implements NotificationAdapter {
  static const _sessionNotificationId = 1;

  final FlutterLocalNotificationsPlugin _plugin;

  FlutterLocalNotificationsAdapter(this._plugin);

  @override
  Future<void> schedule({
    required AlertKind kind,
    required DateTime scheduledFor,
  }) async {
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
