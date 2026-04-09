import '../models/models.dart';

abstract class ProjectRepository {
  Future<List<Project>> getAll();
  Future<void> add(Project project);
}
