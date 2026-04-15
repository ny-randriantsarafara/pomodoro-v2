import 'alert_capabilities.dart';
import 'alert_kind.dart';
import 'alert_plan.dart';
import 'alert_settings.dart';

AlertPlan buildCompletionAlertPlan({
  required AlertKind kind,
  required AlertSettings settings,
  required AlertCapabilities capabilities,
}) {
  final isFocus = kind == AlertKind.focusCompleted;
  return AlertPlan(
    showNotification: settings.notificationsEnabled && capabilities.canNotify,
    playSound: settings.soundEnabled && capabilities.canPlaySound,
    soundAsset: isFocus
        ? 'assets/sounds/focus-complete.mp3'
        : 'assets/sounds/break-complete.mp3',
    notificationChannelId: isFocus ? 'focus_complete' : 'break_complete',
  );
}
