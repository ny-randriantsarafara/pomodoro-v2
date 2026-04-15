import '../data/alert_settings_repository.dart';
import '../domain/alert_capabilities.dart';
import '../domain/alert_kind.dart';
import '../domain/alert_rules.dart';
import '../platform/notification_adapter.dart';
import '../platform/sound_adapter.dart';

enum SessionType { focus, breakTime }

class SessionAlertCoordinator {
  final AlertSettingsRepository settingsRepository;
  final NotificationAdapter notificationAdapter;
  final SoundAdapter soundAdapter;
  final AlertCapabilities capabilities;

  SessionAlertCoordinator({
    required this.settingsRepository,
    required this.notificationAdapter,
    required this.soundAdapter,
    required this.capabilities,
  });

  AlertKind _alertKindFor(SessionType type) =>
      type == SessionType.focus
          ? AlertKind.focusCompleted
          : AlertKind.breakCompleted;

  Future<void> onSessionStarted(SessionType type, DateTime endsAt) async {
    final settings = await settingsRepository.load();
    if (!settings.notificationsEnabled || !capabilities.canNotify) return;
    await notificationAdapter.schedule(
      kind: _alertKindFor(type),
      scheduledFor: endsAt,
    );
  }

  Future<void> onSessionCancelledOrReset() =>
      notificationAdapter.cancelActiveSessionAlert();

  Future<void> onSessionCompleted(SessionType type) async {
    await notificationAdapter.cancelActiveSessionAlert();
    final settings = await settingsRepository.load();
    final plan = buildCompletionAlertPlan(
      kind: _alertKindFor(type),
      settings: settings,
      capabilities: capabilities,
    );
    if (plan.playSound && plan.soundAsset != null) {
      await soundAdapter.play(plan.soundAsset!);
    }
  }
}
