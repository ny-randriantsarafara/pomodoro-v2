import 'package:flutter_test/flutter_test.dart';
import 'package:rhythm/models/models.dart';
import 'package:rhythm/repositories/repositories.dart';

void main() {
  group('InMemoryTaskRepository', () {
    late InMemoryTaskRepository repo;

    setUp(() {
      repo = InMemoryTaskRepository();
    });

    test('starts empty', () {
      expect(repo.getAll(), isEmpty);
    });

    test('add inserts at beginning', () {
      final t1 = Task(id: '1', title: 'First', createdAt: DateTime(2026, 1, 1));
      final t2 = Task(id: '2', title: 'Second', createdAt: DateTime(2026, 1, 2));
      repo.add(t1);
      repo.add(t2);
      expect(repo.getAll().first.id, '2');
    });

    test('update replaces task', () {
      final task = Task(id: '1', title: 'Old', createdAt: DateTime(2026, 1, 1));
      repo.add(task);
      repo.update(task.copyWith(title: 'New'));
      expect(repo.getAll().first.title, 'New');
    });

    test('delete removes task', () {
      final task = Task(id: '1', title: 'Test', createdAt: DateTime(2026, 1, 1));
      repo.add(task);
      repo.delete('1');
      expect(repo.getAll(), isEmpty);
    });

    test('initial seed data', () {
      final seeded = InMemoryTaskRepository(initial: [
        Task(id: '1', title: 'Seeded', createdAt: DateTime(2026, 1, 1)),
      ]);
      expect(seeded.getAll().length, 1);
    });
  });

  group('InMemoryProjectRepository', () {
    test('add and getAll', () {
      final repo = InMemoryProjectRepository();
      repo.add(const Project(id: 'p1', name: 'Test', style: ProjectStyles.blue));
      expect(repo.getAll().length, 1);
    });
  });

  group('InMemorySessionRepository', () {
    test('add inserts at beginning', () {
      final repo = InMemorySessionRepository();
      final s1 = Session(
        id: 's1', taskId: 't1', taskTitle: 'A', preset: 25,
        duration: 1500, completedAt: DateTime(2026, 1, 1),
      );
      final s2 = Session(
        id: 's2', taskId: 't2', taskTitle: 'B', preset: 50,
        duration: 3000, completedAt: DateTime(2026, 1, 2),
      );
      repo.add(s1);
      repo.add(s2);
      expect(repo.getAll().first.id, 's2');
    });
  });
}
