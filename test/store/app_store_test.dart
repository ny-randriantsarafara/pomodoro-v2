import 'package:flutter_test/flutter_test.dart';
import 'package:rhythm/models/models.dart';
import 'package:rhythm/repositories/repositories.dart';
import 'package:rhythm/store/app_store.dart';

AppStore createStore({
  List<Task>? tasks,
  List<Project>? projects,
  List<Session>? sessions,
}) {
  return AppStore(
    taskRepo: InMemoryTaskRepository(initial: tasks ?? []),
    projectRepo: InMemoryProjectRepository(initial: projects ?? []),
    sessionRepo: InMemorySessionRepository(initial: sessions ?? []),
  );
}

void main() {
  group('AppStore', () {
    test('addTask adds to beginning of list', () {
      final store = createStore();
      store.addTask('First task');
      store.addTask('Second task');
      expect(store.tasks.length, 2);
      expect(store.tasks.first.title, 'Second task');
    });

    test('addTask with projectId', () {
      final store = createStore();
      store.addTask('Task', projectId: 'p1');
      expect(store.tasks.first.projectId, 'p1');
    });

    test('toggleTask flips completed', () {
      final store = createStore(tasks: [
        Task(id: '1', title: 'Test', createdAt: DateTime(2026, 1, 1)),
      ]);
      store.toggleTask('1');
      expect(store.tasks.first.completed, true);
      store.toggleTask('1');
      expect(store.tasks.first.completed, false);
    });

    test('deleteTask removes task', () {
      final store = createStore(tasks: [
        Task(id: '1', title: 'Test', createdAt: DateTime(2026, 1, 1)),
      ]);
      store.deleteTask('1');
      expect(store.tasks, isEmpty);
    });

    test('addProject adds project', () {
      final store = createStore();
      store.addProject('Design', ProjectStyles.blue);
      expect(store.projects.length, 1);
      expect(store.projects.first.name, 'Design');
    });

    test('addSession adds session at beginning', () {
      final store = createStore();
      store.addSession(
        taskId: 't1',
        taskTitle: 'Test',
        preset: 25,
        duration: 1500,
      );
      expect(store.sessions.length, 1);
      expect(store.sessions.first.taskTitle, 'Test');
    });

    test('setLastUsedPreset updates preset', () {
      final store = createStore();
      expect(store.lastUsedPreset, 25);
      store.setLastUsedPreset(50);
      expect(store.lastUsedPreset, 50);
    });

    test('findProject returns null for missing id', () {
      final store = createStore();
      expect(store.findProject('nonexistent'), isNull);
      expect(store.findProject(null), isNull);
    });

    test('findTask returns null for missing id', () {
      final store = createStore();
      expect(store.findTask('nonexistent'), isNull);
    });

    test('notifies listeners on changes', () {
      final store = createStore();
      int notifyCount = 0;
      store.addListener(() => notifyCount++);

      store.addTask('Task');
      expect(notifyCount, 1);

      store.toggleTask(store.tasks.first.id);
      expect(notifyCount, 2);

      store.setLastUsedPreset(90);
      expect(notifyCount, 3);
    });
  });
}
