import '../models/models.dart';

abstract class ProjectRepository {
  List<Project> getAll();
  void add(Project project);
}

class InMemoryProjectRepository implements ProjectRepository {
  final List<Project> _projects;

  InMemoryProjectRepository({List<Project>? initial})
      : _projects = initial ?? [];

  @override
  List<Project> getAll() => List.unmodifiable(_projects);

  @override
  void add(Project project) => _projects.add(project);
}
