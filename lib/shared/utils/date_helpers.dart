bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

bool isToday(DateTime date) {
  return isSameDay(date, DateTime.now());
}

bool isYesterday(DateTime date) {
  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  return isSameDay(date, yesterday);
}

DateTime startOfDay(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}
