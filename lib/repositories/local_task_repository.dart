import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';
import 'task_repository.dart';

class LocalTaskRepository implements TaskRepository {
  static const storageKey = 'local_tasks';

  final SharedPreferences _prefs;
  int _nextId = 0;

  LocalTaskRepository(this._prefs);

  @override
  Future<List<Task>> getAll() async {
    final raw = _prefs.getString(storageKey);
    if (raw == null) return [];
    final List<dynamic> decoded = json.decode(raw) as List<dynamic>;
    return decoded
        .map((j) => Task.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> add(Task task) async {
    final tasks = await getAll();
    final id = task.id.isEmpty ? 'local_task_${_nextId++}' : task.id;
    tasks.insert(
      0,
      Task(
        id: id,
        title: task.title,
        projectId: task.projectId,
        completed: task.completed,
        createdAt: task.createdAt,
      ),
    );
    await _save(tasks);
  }

  @override
  Future<void> update(Task task) async {
    final tasks = await getAll();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) tasks[index] = task;
    await _save(tasks);
  }

  @override
  Future<void> delete(String id) async {
    final tasks = await getAll();
    tasks.removeWhere((t) => t.id == id);
    await _save(tasks);
  }

  Future<void> _save(List<Task> tasks) async {
    final encoded = json.encode(tasks.map((t) => t.toJson()).toList());
    await _prefs.setString(storageKey, encoded);
  }
}
