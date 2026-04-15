class AlertSettings {
  final bool notificationsEnabled;
  final bool soundEnabled;

  const AlertSettings({
    required this.notificationsEnabled,
    required this.soundEnabled,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlertSettings &&
          runtimeType == other.runtimeType &&
          notificationsEnabled == other.notificationsEnabled &&
          soundEnabled == other.soundEnabled;

  @override
  int get hashCode => Object.hash(notificationsEnabled, soundEnabled);
}
