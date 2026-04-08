import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rhythm/models/models.dart';
import 'package:rhythm/repositories/local_task_repository.dart';

void main() {
  late SharedPreferences prefs;
  late LocalTaskRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repo = LocalTaskRepository(prefs);
  });

  test('starts empty', () async {
    expect(await repo.getAll(), isEmpty);
  });

  test('add generates ID for empty-id task and persists', () async {
    final task = Task(id: '', title: 'Test', createdAt: DateTime(2026, 1, 1));
    await repo.add(task);
    final tasks = await repo.getAll();
    expect(tasks.length, 1);
    expect(tasks.first.title, 'Test');
    expect(tasks.first.id, isNotEmpty);
  });

  test('add inserts at beginning (newest first)', () async {
    final t1 = Task(id: '1', title: 'First', createdAt: DateTime(2026, 1, 1));
    final t2 = Task(id: '2', title: 'Second', createdAt: DateTime(2026, 1, 2));
    await repo.add(t1);
    await repo.add(t2);
    final tasks = await repo.getAll();
    expect(tasks.first.id, '2');
  });

  test('update replaces matching task', () async {
    final task = Task(id: '1', title: 'Old', createdAt: DateTime(2026, 1, 1));
    await repo.add(task);
    await repo.update(task.copyWith(title: 'New'));
    final tasks = await repo.getAll();
    expect(tasks.first.title, 'New');
  });

  test('delete removes matching task', () async {
    final task = Task(id: '1', title: 'Test', createdAt: DateTime(2026, 1, 1));
    await repo.add(task);
    await repo.delete('1');
    expect(await repo.getAll(), isEmpty);
  });

  test('data persists across instances', () async {
    final task = Task(id: '1', title: 'Persist', createdAt: DateTime(2026, 1, 1));
    await repo.add(task);

    final repo2 = LocalTaskRepository(prefs);
    final tasks = await repo2.getAll();
    expect(tasks.length, 1);
    expect(tasks.first.title, 'Persist');
  });
}
