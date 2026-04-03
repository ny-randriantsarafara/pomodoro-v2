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
  });
}
