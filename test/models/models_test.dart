import 'package:flutter_test/flutter_test.dart';
import 'package:rhythm/models/models.dart';

void main() {
  group('Task', () {
    test('copyWith toggles completed', () {
      final task = Task(
        id: '1',
        title: 'Test',
        createdAt: DateTime(2026, 1, 1),
      );
      final toggled = task.copyWith(completed: true);
      expect(toggled.completed, true);
      expect(toggled.title, 'Test');
      expect(toggled.id, '1');
    });

    test('copyWith clears projectId', () {
      final task = Task(
        id: '1',
        title: 'Test',
        projectId: 'p1',
        createdAt: DateTime(2026, 1, 1),
      );
      final cleared = task.copyWith(clearProjectId: true);
      expect(cleared.projectId, isNull);
    });

    test('equality based on id', () {
      final a = Task(id: '1', title: 'A', createdAt: DateTime(2026, 1, 1));
      final b = Task(id: '1', title: 'B', createdAt: DateTime(2026, 1, 2));
      expect(a, equals(b));
    });

    test('toJson produces expected map', () {
      final task = Task(
        id: 'abc',
        title: 'Test task',
        projectId: 'p1',
        completed: true,
        createdAt: DateTime.utc(2026, 1, 15, 10, 30),
      );
      final json = task.toJson();
      expect(json['id'], 'abc');
      expect(json['title'], 'Test task');
      expect(json['project_id'], 'p1');
      expect(json['completed'], true);
      expect(json['created_at'], '2026-01-15T10:30:00.000Z');
    });

    test('fromJson round-trips', () {
      final original = Task(
        id: 'abc',
        title: 'Test task',
        projectId: 'p1',
        completed: true,
        createdAt: DateTime.utc(2026, 1, 15, 10, 30),
      );
      final restored = Task.fromJson(original.toJson());
      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.projectId, original.projectId);
      expect(restored.completed, original.completed);
      expect(restored.createdAt, original.createdAt);
    });

    test('fromJson handles null projectId', () {
      final task = Task(
        id: 'abc',
        title: 'No project',
        createdAt: DateTime.utc(2026, 1, 1),
      );
      final restored = Task.fromJson(task.toJson());
      expect(restored.projectId, isNull);
    });
  });

  group('Project', () {
    test('ProjectStyles has 6 styles', () {
      expect(ProjectStyles.all.length, 6);
    });

    test('equality based on id', () {
      const a = Project(id: 'p1', name: 'A', style: ProjectStyles.blue);
      const b = Project(id: 'p1', name: 'B', style: ProjectStyles.emerald);
      expect(a, equals(b));
    });

    test('ProjectStyle toJson/fromJson round-trips', () {
      const style = ProjectStyles.blue;
      final json = {
        'bg_color': ProjectStyle.colorToHex(style.background),
        'fg_color': ProjectStyle.colorToHex(style.foreground),
      };
      final restored = ProjectStyle(
        background: ProjectStyle.colorFromHex(json['bg_color']!),
        foreground: ProjectStyle.colorFromHex(json['fg_color']!),
      );
      expect(restored, equals(style));
    });

    test('Project.toJson produces expected map', () {
      const project = Project(id: 'p1', name: 'Design', style: ProjectStyles.blue);
      final json = project.toJson();
      expect(json['id'], 'p1');
      expect(json['name'], 'Design');
      expect(json['bg_color'], isA<String>());
      expect(json['fg_color'], isA<String>());
    });

    test('Project.fromJson round-trips', () {
      const original = Project(id: 'p1', name: 'Design', style: ProjectStyles.blue);
      final restored = Project.fromJson(original.toJson());
      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.style, original.style);
    });
  });

  group('Session', () {
    test('stores snapshot data', () {
      final session = Session(
        id: 's1',
        taskId: 't1',
        taskTitle: 'Snapshot title',
        projectName: 'Design',
        projectStyle: ProjectStyles.blue,
        preset: 25,
        duration: 1500,
        completedAt: DateTime(2026, 1, 1),
      );
      expect(session.taskTitle, 'Snapshot title');
      expect(session.projectName, 'Design');
      expect(session.duration, 1500);
    });

    test('toJson produces expected map', () {
      final session = Session(
        id: 's1',
        taskId: 't1',
        taskTitle: 'Test',
        projectName: 'Design',
        projectStyle: ProjectStyles.blue,
        preset: 25,
        duration: 1500,
        completedAt: DateTime.utc(2026, 1, 15, 12, 0),
      );
      final json = session.toJson();
      expect(json['id'], 's1');
      expect(json['task_id'], 't1');
      expect(json['task_title'], 'Test');
      expect(json['project_name'], 'Design');
      expect(json['project_bg'], isA<String>());
      expect(json['project_fg'], isA<String>());
      expect(json['preset'], 25);
      expect(json['duration'], 1500);
      expect(json['completed_at'], '2026-01-15T12:00:00.000Z');
    });

    test('fromJson round-trips', () {
      final original = Session(
        id: 's1',
        taskId: 't1',
        taskTitle: 'Test',
        projectName: 'Design',
        projectStyle: ProjectStyles.blue,
        preset: 25,
        duration: 1500,
        completedAt: DateTime.utc(2026, 1, 15, 12, 0),
      );
      final restored = Session.fromJson(original.toJson());
      expect(restored.id, original.id);
      expect(restored.taskId, original.taskId);
      expect(restored.taskTitle, original.taskTitle);
      expect(restored.projectName, original.projectName);
      expect(restored.projectStyle, original.projectStyle);
      expect(restored.preset, original.preset);
      expect(restored.duration, original.duration);
      expect(restored.completedAt, original.completedAt);
    });

    test('fromJson handles null project and taskId', () {
      final session = Session(
        id: 's2',
        taskTitle: 'Orphaned',
        preset: 50,
        duration: 3000,
        completedAt: DateTime.utc(2026, 2, 1),
      );
      final restored = Session.fromJson(session.toJson());
      expect(restored.taskId, isNull);
      expect(restored.projectName, isNull);
      expect(restored.projectStyle, isNull);
    });
  });
}
