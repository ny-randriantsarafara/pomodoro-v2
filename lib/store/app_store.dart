import 'dart:math';

import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';

class AppStore extends ChangeNotifier {
  final TaskRepository _taskRepo;
  final ProjectRepository _projectRepo;
  final SessionRepository _sessionRepo;

  int _lastUsedPreset = 25;

  AppStore({
    required TaskRepository taskRepo,
    required ProjectRepository projectRepo,
    required SessionRepository sessionRepo,
  })  : _taskRepo = taskRepo,
        _projectRepo = projectRepo,
        _sessionRepo = sessionRepo;

  List<Task> get tasks => _taskRepo.getAll();
  List<Project> get projects => _projectRepo.getAll();
  List<Session> get sessions => _sessionRepo.getAll();
  int get lastUsedPreset => _lastUsedPreset;

  void addTask(String title, {String? projectId}) {
    final task = Task(
      id: _generateId(),
      title: title,
      projectId: projectId,
      createdAt: DateTime.now(),
    );
    _taskRepo.add(task);
    notifyListeners();
  }

  void toggleTask(String id) {
    final task = tasks.firstWhere((t) => t.id == id);
    _taskRepo.update(task.copyWith(completed: !task.completed));
    notifyListeners();
  }

  void deleteTask(String id) {
    _taskRepo.delete(id);
    notifyListeners();
  }

  void addProject(String name, ProjectStyle style) {
    final project = Project(
      id: _generateId(),
      name: name,
      style: style,
    );
    _projectRepo.add(project);
    notifyListeners();
  }

  void addSession({
    required String taskId,
    required String taskTitle,
    String? projectName,
    ProjectStyle? projectStyle,
    required int preset,
    required int duration,
  }) {
    final session = Session(
      id: _generateId(),
      taskId: taskId,
      taskTitle: taskTitle,
      projectName: projectName,
      projectStyle: projectStyle,
      preset: preset,
      duration: duration,
      completedAt: DateTime.now(),
    );
    _sessionRepo.add(session);
    notifyListeners();
  }

  void setLastUsedPreset(int preset) {
    _lastUsedPreset = preset;
    notifyListeners();
  }

  Project? findProject(String? id) {
    if (id == null) return null;
    try {
      return projects.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Task? findTask(String id) {
    try {
      return tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  String _generateId() {
    return Random().nextInt(1 << 32).toRadixString(36);
  }
}
