class AlertPlan {
  final bool showNotification;
  final bool playSound;
  final String? soundAsset;
  final String notificationChannelId;

  const AlertPlan({
    required this.showNotification,
    required this.playSound,
    required this.soundAsset,
    required this.notificationChannelId,
  });
}
