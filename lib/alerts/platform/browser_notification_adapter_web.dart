import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import '../domain/alert_kind.dart';
import 'notification_adapter.dart';

NotificationAdapter createBrowserNotificationAdapter() =>
    _WebBrowserNotificationAdapter();

class _WebBrowserNotificationAdapter implements NotificationAdapter {
  Timer? _pendingTimer;
  bool _permissionRequested = false;

  Future<void> _ensurePermissionRequested() async {
    if (_permissionRequested) return;
    _permissionRequested = true;
    if (web.Notification.permission == 'default') {
      await web.Notification.requestPermission().toDart;
    }
  }

  @override
  Future<void> schedule({
    required AlertKind kind,
    required DateTime scheduledFor,
  }) async {
    await _ensurePermissionRequested();
    _pendingTimer?.cancel();
    final delay = scheduledFor.difference(DateTime.now());
    if (delay.isNegative) return;

    final isFocus = kind == AlertKind.focusCompleted;
    final title = isFocus ? 'Focus Complete' : 'Break Complete';
    final body = isFocus
        ? 'Great work! Time for a break.'
        : 'Break is over. Ready to focus again?';

    _pendingTimer = Timer(delay, () {
      if (web.Notification.permission == 'granted') {
        web.Notification(title, web.NotificationOptions(body: body));
      }
    });
  }

  @override
  Future<void> cancelActiveSessionAlert() async {
    _pendingTimer?.cancel();
    _pendingTimer = null;
  }
}
