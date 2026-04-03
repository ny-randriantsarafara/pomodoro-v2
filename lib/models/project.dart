import 'dart:ui';

class ProjectStyle {
  final Color background;
  final Color foreground;

  const ProjectStyle({required this.background, required this.foreground});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectStyle &&
          other.background == background &&
          other.foreground == foreground;

  @override
  int get hashCode => Object.hash(background, foreground);
}

class ProjectStyles {
  ProjectStyles._();

  static const blue = ProjectStyle(
    background: Color(0xFFDBEAFE),
    foreground: Color(0xFF1D4ED8),
  );
  static const emerald = ProjectStyle(
    background: Color(0xFFD1FAE5),
    foreground: Color(0xFF047857),
  );
  static const purple = ProjectStyle(
    background: Color(0xFFF3E8FF),
    foreground: Color(0xFF7E22CE),
  );
  static const amber = ProjectStyle(
    background: Color(0xFFFEF3C7),
    foreground: Color(0xFFB45309),
  );
  static const rose = ProjectStyle(
    background: Color(0xFFFFE4E6),
    foreground: Color(0xFFBE123C),
  );
  static const indigo = ProjectStyle(
    background: Color(0xFFE0E7FF),
    foreground: Color(0xFF4338CA),
  );

  static const all = [blue, emerald, purple, amber, rose, indigo];
}

class Project {
  final String id;
  final String name;
  final ProjectStyle style;

  const Project({
    required this.id,
    required this.name,
    required this.style,
  });

  Project copyWith({String? id, String? name, ProjectStyle? style}) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      style: style ?? this.style,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Project && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
