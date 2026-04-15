import '../domain/alert_kind.dart';

class ScheduledAlert {
  final AlertKind kind;
  final DateTime scheduledFor;

  const ScheduledAlert({required this.kind, required this.scheduledFor});
}

abstract class NotificationAdapter {
  Future<void> schedule({
    required AlertKind kind,
    required DateTime scheduledFor,
  });

  Future<void> cancelActiveSessionAlert();
}

class RecordingNotificationAdapter implements NotificationAdapter {
  final List<ScheduledAlert> scheduled = [];
  int cancelCount = 0;

  @override
  Future<void> schedule({
    required AlertKind kind,
    required DateTime scheduledFor,
  }) async {
    scheduled.add(ScheduledAlert(kind: kind, scheduledFor: scheduledFor));
  }

  @override
  Future<void> cancelActiveSessionAlert() async {
    cancelCount++;
  }
}
