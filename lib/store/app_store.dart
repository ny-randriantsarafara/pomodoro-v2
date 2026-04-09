import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../repositories/repositories.dart';
import '../shared/logging/app_logger.dart';

typedef LoadDataErrorReporter = void Function(
  String stage,
  Object error,
  StackTrace stackTrace,
);

class AppStore extends ChangeNotifier {
  final TaskRepository _taskRepo;
  final ProjectRepository _projectRepo;
  final SessionRepository _sessionRepo;
  final LoadDataErrorReporter _onLoadDataError;

  List<Task> _tasks = [];
  List<Project> _projects = [];
  List<Session> _sessions = [];
  int _lastUsedPreset = 25;

  AppStore({
    required TaskRepository taskRepo,
    required ProjectRepository projectRepo,
    required SessionRepository sessionRepo,
    LoadDataErrorReporter? onLoadDataError,
  })  : _taskRepo = taskRepo,
        _projectRepo = projectRepo,
        _sessionRepo = sessionRepo,
        _onLoadDataError = onLoadDataError ?? _defaultLoadDataErrorReporter;

  static void _defaultLoadDataErrorReporter(
    String stage,
    Object error,
    StackTrace stackTrace,
  ) {
    AppLogger.error(
      domain: 'app_store',
      event: 'load_data_stage_failed',
      context: {'stage': stage},
      error: error,
      stackTrace: stackTrace,
    );
  }

  List<Task> get tasks => _tasks;
  List<Project> get projects => _projects;
  List<Session> get sessions => _sessions;
  int get lastUsedPreset => _lastUsedPreset;

  Future<void> loadData() async {
    _tasks = await _loadStage('tasks', () => _taskRepo.getAll());
    _projects = await _loadStage('projects', () => _projectRepo.getAll());
    _sessions = await _loadStage('sessions', () => _sessionRepo.getAll());
    notifyListeners();
  }

  Future<T> _loadStage<T>(String stage, Future<T> Function() run) async {
    try {
      return await run();
    } on Object catch (error, stackTrace) {
      _onLoadDataError(stage, error, stackTrace);
      rethrow;
    }
  }

  Future<void> addTask(String title, {String? projectId}) async {
    final task = Task(
      id: '',
      title: title,
      projectId: projectId,
      createdAt: DateTime.now(),
    );
    await _taskRepo.add(task);
    _tasks = await _taskRepo.getAll();
    notifyListeners();
  }

  Future<void> toggleTask(String id) async {
    final task = _tasks.firstWhere((t) => t.id == id);
    await _taskRepo.update(task.copyWith(completed: !task.completed));
    _tasks = await _taskRepo.getAll();
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    await _taskRepo.delete(id);
    _tasks = await _taskRepo.getAll();
    notifyListeners();
  }

  /// Updates title and/or project assignment. Pass [clearProjectId]: true to
  /// remove a project from a task that previously had one; omit [projectId]
  /// when only changing title.
  Future<void> updateTask({
    required String id,
    required String title,
    String? projectId,
    bool clearProjectId = false,
  }) async {
    final existing = _tasks.firstWhere((t) => t.id == id);
    final updated = existing.copyWith(
      title: title,
      projectId: projectId,
      clearProjectId: clearProjectId,
    );
    await _taskRepo.update(updated);
    _tasks = await _taskRepo.getAll();
    notifyListeners();
  }

  Future<void> addProject(String name, ProjectStyle style) async {
    final project = Project(
      id: '',
      name: name,
      style: style,
    );
    await _projectRepo.add(project);
    _projects = await _projectRepo.getAll();
    notifyListeners();
  }

  Future<void> addSession({
    required String taskId,
    required String taskTitle,
    String? projectName,
    ProjectStyle? projectStyle,
    required int preset,
    required int duration,
  }) async {
    final session = Session(
      id: '',
      taskId: taskId,
      taskTitle: taskTitle,
      projectName: projectName,
      projectStyle: projectStyle,
      preset: preset,
      duration: duration,
      completedAt: DateTime.now(),
    );
    await _sessionRepo.add(session);
    _sessions = await _sessionRepo.getAll();
    notifyListeners();
  }

  void setLastUsedPreset(int preset) {
    _lastUsedPreset = preset;
    notifyListeners();
  }

  Project? findProject(String? id) {
    if (id == null) return null;
    try {
      return _projects.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Task? findTask(String id) {
    try {
      return _tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }
}
