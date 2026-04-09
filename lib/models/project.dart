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

  static String colorToHex(Color c) {
    final argb = c.toARGB32();
    return '#${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  static Color colorFromHex(String hex) {
    final value = int.parse(hex.substring(1), radix: 16);
    return Color.fromARGB(
        255, (value >> 16) & 0xFF, (value >> 8) & 0xFF, value & 0xFF);
  }

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

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'bg_color': ProjectStyle.colorToHex(style.background),
        'fg_color': ProjectStyle.colorToHex(style.foreground),
      };

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json['id'] as String,
        name: json['name'] as String,
        style: ProjectStyle(
          background: ProjectStyle.colorFromHex(json['bg_color'] as String),
          foreground: ProjectStyle.colorFromHex(json['fg_color'] as String),
        ),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Project && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
