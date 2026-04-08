import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../shared/utils/date_helpers.dart';

class RhythmDay {
  final DateTime date;
  final int totalMinutes;
  final bool isToday;

  const RhythmDay({
    required this.date,
    required this.totalMinutes,
    required this.isToday,
  });
}

class TaskStat {
  final String taskId;
  final String title;
  final String? projectName;
  final ProjectStyle? projectStyle;
  final int sessionCount;
  final int totalSeconds;

  const TaskStat({
    required this.taskId,
    required this.title,
    this.projectName,
    this.projectStyle,
    required this.sessionCount,
    required this.totalSeconds,
  });
}

class SessionGroup {
  final String label;
  final List<Session> sessions;

  const SessionGroup({required this.label, required this.sessions});
}

List<RhythmDay> buildRhythmData(List<Session> sessions) {
  final now = DateTime.now();
  final days = <RhythmDay>[];

  for (int i = 6; i >= 0; i--) {
    final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
    final dayTotal = sessions
        .where((s) => isSameDay(s.completedAt, date))
        .fold<int>(0, (sum, s) => sum + s.duration);
    days.add(RhythmDay(
      date: date,
      totalMinutes: (dayTotal / 60).ceil(),
      isToday: i == 0,
    ));
  }

  return days;
}

List<TaskStat> buildTopTaskStats(
  List<Session> sessions,
  List<Task> tasks,
  List<Project> projects,
) {
  final Map<String, List<Session>> grouped = {};
  for (final s in sessions) {
    final key = s.taskId ?? s.id;
    grouped.putIfAbsent(key, () => []).add(s);
  }

  final stats = grouped.entries.map((entry) {
    final taskSessions = entry.value;
    final existingTask = tasks.where((t) => t.id == entry.key).firstOrNull;
    final title = existingTask?.title ?? taskSessions.first.taskTitle;
    final projectName = taskSessions.first.projectName;
    final projectStyle = taskSessions.first.projectStyle;

    return TaskStat(
      taskId: entry.key,
      title: title,
      projectName: projectName,
      projectStyle: projectStyle,
      sessionCount: taskSessions.length,
      totalSeconds: taskSessions.fold<int>(0, (sum, s) => sum + s.duration),
    );
  }).toList();

  stats.sort((a, b) => b.totalSeconds.compareTo(a.totalSeconds));
  return stats.take(5).toList();
}

List<SessionGroup> groupSessionsByDayLabel(List<Session> sessions) {
  final Map<String, List<Session>> grouped = {};
  final dateFormat = DateFormat('MMM d, yyyy');

  for (final session in sessions) {
    String label;
    if (isToday(session.completedAt)) {
      label = 'Today';
    } else if (isYesterday(session.completedAt)) {
      label = 'Yesterday';
    } else {
      label = dateFormat.format(session.completedAt);
    }
    grouped.putIfAbsent(label, () => []).add(session);
  }

  return grouped.entries
      .map((e) => SessionGroup(label: e.key, sessions: e.value))
      .toList();
}

int totalFocusSeconds(List<Session> sessions) {
  return sessions.fold<int>(0, (sum, s) => sum + s.duration);
}
