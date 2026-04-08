import 'package:rhythm/models/models.dart';
import 'package:rhythm/repositories/repositories.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthState, User;

class TestTaskRepository implements TaskRepository {
  final List<Task> _tasks;
  int _nextTaskKey = 0;

  TestTaskRepository({List<Task>? initial}) : _tasks = List.from(initial ?? []);

  @override
  Future<List<Task>> getAll() async => List.unmodifiable(_tasks);

  @override
  Future<void> add(Task task) async {
    final id =
        task.id.isEmpty ? 'test_task_${_nextTaskKey++}' : task.id;
    _tasks.insert(
      0,
      Task(
        id: id,
        title: task.title,
        projectId: task.projectId,
        completed: task.completed,
        createdAt: task.createdAt,
      ),
    );
  }

  @override
  Future<void> update(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) _tasks[index] = task;
  }

  @override
  Future<void> delete(String id) async => _tasks.removeWhere((t) => t.id == id);
}

/// [TaskRepository] whose [getAll] always throws (for load failure tests).
class ThrowingOnGetAllTaskRepository implements TaskRepository {
  final Object error;

  ThrowingOnGetAllTaskRepository([Object? error])
      : error = error ?? Exception('tasks_failed');

  @override
  Future<List<Task>> getAll() async => throw error;

  @override
  Future<void> add(Task task) async {}

  @override
  Future<void> update(Task task) async {}

  @override
  Future<void> delete(String id) async {}
}

class SynchronouslyThrowingOnGetAllTaskRepository implements TaskRepository {
  final Object error;

  SynchronouslyThrowingOnGetAllTaskRepository([Object? error])
      : error = error ?? Exception('tasks_failed_sync');

  @override
  Future<List<Task>> getAll() => throw error;

  @override
  Future<void> add(Task task) async {}

  @override
  Future<void> update(Task task) async {}

  @override
  Future<void> delete(String id) async {}
}

class TestProjectRepository implements ProjectRepository {
  final List<Project> _projects;
  int _nextProjectKey = 0;

  TestProjectRepository({List<Project>? initial})
      : _projects = List.from(initial ?? []);

  @override
  Future<List<Project>> getAll() async => List.unmodifiable(_projects);

  @override
  Future<void> add(Project project) async {
    final id =
        project.id.isEmpty ? 'test_proj_${_nextProjectKey++}' : project.id;
    _projects.add(
      Project(id: id, name: project.name, style: project.style),
    );
  }
}

class TestSessionRepository implements SessionRepository {
  final List<Session> _sessions;

  TestSessionRepository({List<Session>? initial}) : _sessions = initial ?? [];

  @override
  Future<List<Session>> getAll() async => List.unmodifiable(_sessions);

  @override
  Future<void> add(Session session) async => _sessions.insert(0, session);
}

class TestAuthRepository implements AuthRepository {
  final bool _isAuthenticated;

  TestAuthRepository({bool isAuthenticated = true})
      : _isAuthenticated = isAuthenticated;

  @override
  Future<void> signInWithMagicLink(String email) async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signInWithApple() async {}

  @override
  Future<void> signOut() async {}

  @override
  Stream<AuthState> get onAuthStateChange => const Stream.empty();

  @override
  User? get currentUser => _isAuthenticated
      ? const User(
          id: 'test-user-id',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: '2026-01-01T00:00:00.000Z',
          email: 'test@example.com',
        )
      : null;
}
