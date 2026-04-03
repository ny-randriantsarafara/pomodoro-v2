import '../models/models.dart';

abstract class TaskRepository {
  List<Task> getAll();
  void add(Task task);
  void update(Task task);
  void delete(String id);
}

class InMemoryTaskRepository implements TaskRepository {
  final List<Task> _tasks;

  InMemoryTaskRepository({List<Task>? initial}) : _tasks = initial ?? [];

  @override
  List<Task> getAll() => List.unmodifiable(_tasks);

  @override
  void add(Task task) => _tasks.insert(0, task);

  @override
  void update(Task task) {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) _tasks[index] = task;
  }

  @override
  void delete(String id) => _tasks.removeWhere((t) => t.id == id);
}
