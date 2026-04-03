class Task {
  final String id;
  final String title;
  final String? projectId;
  final bool completed;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.title,
    this.projectId,
    this.completed = false,
    required this.createdAt,
  });

  Task copyWith({
    String? id,
    String? title,
    String? projectId,
    bool clearProjectId = false,
    bool? completed,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      projectId: clearProjectId ? null : (projectId ?? this.projectId),
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Task && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
