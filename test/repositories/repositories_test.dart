import 'package:flutter_test/flutter_test.dart';
import 'package:rhythm/models/models.dart';
import '../helpers/test_repositories.dart';

void main() {
  group('TestTaskRepository', () {
    late TestTaskRepository repo;

    setUp(() {
      repo = TestTaskRepository();
    });

    test('starts empty', () async {
      expect(await repo.getAll(), isEmpty);
    });

    test('add inserts at beginning', () async {
      final t1 = Task(id: '1', title: 'First', createdAt: DateTime(2026, 1, 1));
      final t2 = Task(id: '2', title: 'Second', createdAt: DateTime(2026, 1, 2));
      await repo.add(t1);
      await repo.add(t2);
      expect((await repo.getAll()).first.id, '2');
    });

    test('update replaces task', () async {
      final task = Task(id: '1', title: 'Old', createdAt: DateTime(2026, 1, 1));
      await repo.add(task);
      await repo.update(task.copyWith(title: 'New'));
      expect((await repo.getAll()).first.title, 'New');
    });

    test('delete removes task', () async {
      final task = Task(id: '1', title: 'Test', createdAt: DateTime(2026, 1, 1));
      await repo.add(task);
      await repo.delete('1');
      expect(await repo.getAll(), isEmpty);
    });
  });

  group('TestProjectRepository', () {
    test('add and getAll', () async {
      final repo = TestProjectRepository();
      await repo.add(const Project(id: 'p1', name: 'Test', style: ProjectStyles.blue));
      expect((await repo.getAll()).length, 1);
    });
  });

  group('TestSessionRepository', () {
    test('add inserts at beginning', () async {
      final repo = TestSessionRepository();
      final s1 = Session(
        id: 's1', taskId: 't1', taskTitle: 'A', preset: 25,
        duration: 1500, completedAt: DateTime(2026, 1, 1),
      );
      final s2 = Session(
        id: 's2', taskId: 't2', taskTitle: 'B', preset: 50,
        duration: 3000, completedAt: DateTime(2026, 1, 2),
      );
      await repo.add(s1);
      await repo.add(s2);
      expect((await repo.getAll()).first.id, 's2');
    });
  });
}
