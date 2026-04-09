import 'package:flutter_test/flutter_test.dart';
import 'package:rhythm/models/models.dart';
import 'package:rhythm/store/app_store.dart';
import '../helpers/test_repositories.dart';

AppStore createStore({
  List<Task>? tasks,
  List<Project>? projects,
  List<Session>? sessions,
}) {
  return AppStore(
    taskRepo: TestTaskRepository(initial: tasks ?? []),
    projectRepo: TestProjectRepository(initial: projects ?? []),
    sessionRepo: TestSessionRepository(initial: sessions ?? []),
  );
}

void main() {
  group('AppStore', () {
    test('loadData populates lists from repos', () async {
      final store = createStore(
        tasks: [Task(id: '1', title: 'Loaded', createdAt: DateTime(2026, 1, 1))],
        projects: [const Project(id: 'p1', name: 'Test', style: ProjectStyles.blue)],
      );
      await store.loadData();
      expect(store.tasks.length, 1);
      expect(store.tasks.first.title, 'Loaded');
      expect(store.projects.length, 1);
    });

    test('addTask adds to beginning of list', () async {
      final store = createStore();
      await store.loadData();
      await store.addTask('First task');
      await store.addTask('Second task');
      expect(store.tasks.length, 2);
      expect(store.tasks.first.title, 'Second task');
    });

    test('addTask with projectId', () async {
      final store = createStore();
      await store.loadData();
      await store.addTask('Task', projectId: 'p1');
      expect(store.tasks.first.projectId, 'p1');
    });

    test('toggleTask flips completed', () async {
      final store = createStore(tasks: [
        Task(id: '1', title: 'Test', createdAt: DateTime(2026, 1, 1)),
      ]);
      await store.loadData();
      await store.toggleTask('1');
      expect(store.tasks.first.completed, true);
      await store.toggleTask('1');
      expect(store.tasks.first.completed, false);
    });

    test('deleteTask removes task', () async {
      final store = createStore(tasks: [
        Task(id: '1', title: 'Test', createdAt: DateTime(2026, 1, 1)),
      ]);
      await store.loadData();
      await store.deleteTask('1');
      expect(store.tasks, isEmpty);
    });

    test('updateTask changes title only', () async {
      final store = createStore(
        tasks: [
          Task(
            id: '1',
            title: 'Before',
            projectId: 'p1',
            createdAt: DateTime(2026, 1, 1),
          ),
        ],
      );
      await store.loadData();
      await store.updateTask(id: '1', title: 'After');
      expect(store.tasks.first.title, 'After');
      expect(store.tasks.first.projectId, 'p1');
    });

    test('updateTask changes project assignment', () async {
      final store = createStore(
        tasks: [
          Task(id: '1', title: 'Test', createdAt: DateTime(2026, 1, 1)),
        ],
      );
      await store.loadData();
      await store.updateTask(id: '1', title: 'Test', projectId: 'p1');
      expect(store.tasks.first.projectId, 'p1');
    });

    test('updateTask clears project', () async {
      final store = createStore(
        tasks: [
          Task(
            id: '1',
            title: 'Test',
            projectId: 'p1',
            createdAt: DateTime(2026, 1, 1),
          ),
        ],
      );
      await store.loadData();
      await store.updateTask(
        id: '1',
        title: 'Test',
        clearProjectId: true,
      );
      expect(store.tasks.first.projectId, isNull);
    });

    test('addProject then updateTask attaches new project id', () async {
      final store = createStore(
        tasks: [
          Task(id: 't1', title: 'T', createdAt: DateTime(2026, 1, 1)),
        ],
      );
      await store.loadData();
      await store.addProject('Inbox', ProjectStyles.blue);
      final projectId = store.projects.last.id;
      await store.updateTask(id: 't1', title: 'T', projectId: projectId);
      expect(store.findTask('t1')?.projectId, projectId);
    });

    test('updateTask reassigns from one project to another', () async {
      final store = createStore(
        tasks: [
          Task(
            id: 't1',
            title: 'T',
            projectId: 'p1',
            createdAt: DateTime(2026, 1, 1),
          ),
        ],
      );
      await store.loadData();
      await store.updateTask(id: 't1', title: 'T', projectId: 'p2');
      expect(store.findTask('t1')?.projectId, 'p2');
    });

    test('addProject adds project', () async {
      final store = createStore();
      await store.loadData();
      await store.addProject('Design', ProjectStyles.blue);
      expect(store.projects.length, 1);
      expect(store.projects.first.name, 'Design');
    });

    test('addSession adds session at beginning', () async {
      final store = createStore();
      await store.loadData();
      await store.addSession(
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

    test('findProject returns null for missing id', () async {
      final store = createStore();
      await store.loadData();
      expect(store.findProject('nonexistent'), isNull);
      expect(store.findProject(null), isNull);
    });

    test('findTask returns null for missing id', () async {
      final store = createStore();
      await store.loadData();
      expect(store.findTask('nonexistent'), isNull);
    });

    test('notifies listeners on changes', () async {
      final store = createStore();
      await store.loadData();
      int notifyCount = 0;
      store.addListener(() => notifyCount++);

      await store.addTask('Task');
      expect(notifyCount, 1);

      await store.toggleTask(store.tasks.first.id);
      expect(notifyCount, 2);

      store.setLastUsedPreset(90);
      expect(notifyCount, 3);
    });

    test('loadData invokes error reporter and rethrows when tasks fail', () async {
      final reportedStages = <String>[];
      final store = AppStore(
        taskRepo: ThrowingOnGetAllTaskRepository(),
        projectRepo: TestProjectRepository(),
        sessionRepo: TestSessionRepository(),
        onLoadDataError: (stage, error, stackTrace) {
          reportedStages.add(stage);
        },
      );
      Object? caught;
      try {
        await store.loadData();
      } on Object catch (e) {
        caught = e;
      }
      expect(caught, isNotNull);
      expect(reportedStages, ['tasks']);
    });

    test('loadData invokes error reporter and rethrows when tasks throw synchronously', () async {
      final reportedStages = <String>[];
      final store = AppStore(
        taskRepo: SynchronouslyThrowingOnGetAllTaskRepository(),
        projectRepo: TestProjectRepository(),
        sessionRepo: TestSessionRepository(),
        onLoadDataError: (stage, error, stackTrace) {
          reportedStages.add(stage);
        },
      );

      Object? caught;
      try {
        await store.loadData();
      } on Object catch (e) {
        caught = e;
      }

      expect(caught, isNotNull);
      expect(reportedStages, ['tasks']);
    });
  });
}
