import '../domain/alert_kind.dart';
import 'notification_adapter.dart';

NotificationAdapter createBrowserNotificationAdapter() =>
    _StubBrowserNotificationAdapter();

class _StubBrowserNotificationAdapter implements NotificationAdapter {
  @override
  Future<void> schedule({
    required AlertKind kind,
    required DateTime scheduledFor,
  }) async {}

  @override
  Future<void> cancelActiveSessionAlert() async {}
}
