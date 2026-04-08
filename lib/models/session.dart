import 'project.dart';

class Session {
  final String id;
  final String? taskId;
  final String taskTitle;
  final String? projectName;
  final ProjectStyle? projectStyle;
  final int preset;
  final int duration;
  final DateTime completedAt;

  const Session({
    required this.id,
    this.taskId,
    required this.taskTitle,
    this.projectName,
    this.projectStyle,
    required this.preset,
    required this.duration,
    required this.completedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'task_id': taskId,
        'task_title': taskTitle,
        'project_name': projectName,
        'project_bg': projectStyle != null
            ? ProjectStyle.colorToHex(projectStyle!.background)
            : null,
        'project_fg': projectStyle != null
            ? ProjectStyle.colorToHex(projectStyle!.foreground)
            : null,
        'preset': preset,
        'duration': duration,
        'completed_at': completedAt.toUtc().toIso8601String(),
      };

  factory Session.fromJson(Map<String, dynamic> json) {
    final bg = json['project_bg'] as String?;
    final fg = json['project_fg'] as String?;
    return Session(
      id: json['id'] as String,
      taskId: json['task_id'] as String?,
      taskTitle: json['task_title'] as String,
      projectName: json['project_name'] as String?,
      projectStyle: (bg != null && fg != null)
          ? ProjectStyle(
              background: ProjectStyle.colorFromHex(bg),
              foreground: ProjectStyle.colorFromHex(fg),
            )
          : null,
      preset: json['preset'] as int,
      duration: json['duration'] as int,
      completedAt: DateTime.parse(json['completed_at'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Session && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
