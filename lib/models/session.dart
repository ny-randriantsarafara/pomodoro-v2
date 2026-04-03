import 'project.dart';

class Session {
  final String id;
  final String taskId;
  final String taskTitle;
  final String? projectName;
  final ProjectStyle? projectStyle;
  final int preset;
  final int duration;
  final DateTime completedAt;

  const Session({
    required this.id,
    required this.taskId,
    required this.taskTitle,
    this.projectName,
    this.projectStyle,
    required this.preset,
    required this.duration,
    required this.completedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Session && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
