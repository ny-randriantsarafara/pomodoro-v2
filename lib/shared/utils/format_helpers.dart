String formatDuration(int totalSeconds) {
  final hours = totalSeconds ~/ 3600;
  final mins = (totalSeconds % 3600) ~/ 60;
  if (hours > 0) return '${hours}h ${mins}m';
  return '${mins}m';
}

String formatTimer(int totalSeconds) {
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

String formatTimeOfDay(DateTime date) {
  final hour = date.hour;
  final minute = date.minute;
  final period = hour >= 12 ? 'PM' : 'AM';
  final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
  return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
}

int breakMinutesForPreset(int preset) {
  switch (preset) {
    case 50:
      return 10;
    case 90:
      return 20;
    default:
      return 5;
  }
}
