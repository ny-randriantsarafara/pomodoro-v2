import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';
import 'app_store.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return InMemoryTaskRepository(initial: [
    Task(
      id: 't1',
      title: 'Wireframe user profile',
      projectId: 'p1',
      createdAt: DateTime.now(),
    ),
    Task(
      id: 't2',
      title: 'Fix navigation bug',
      projectId: 'p2',
      createdAt: DateTime.now(),
    ),
    Task(
      id: 't3',
      title: 'Read email backlog',
      createdAt: DateTime.now(),
    ),
  ]);
});

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return InMemoryProjectRepository(initial: [
    const Project(id: 'p1', name: 'Design', style: ProjectStyles.blue),
    const Project(id: 'p2', name: 'Dev', style: ProjectStyles.emerald),
  ]);
});

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return InMemorySessionRepository(initial: [
    Session(
      id: 's1',
      taskId: 't1',
      taskTitle: 'Wireframe user profile',
      projectName: 'Design',
      projectStyle: ProjectStyles.blue,
      preset: 25,
      duration: 25 * 60,
      completedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    Session(
      id: 's2',
      taskId: 't2',
      taskTitle: 'Fix navigation bug',
      projectName: 'Dev',
      projectStyle: ProjectStyles.emerald,
      preset: 50,
      duration: 50 * 60,
      completedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ]);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository();
});

final appStoreProvider = ChangeNotifierProvider<AppStore>((ref) {
  return AppStore(
    taskRepo: ref.watch(taskRepositoryProvider),
    projectRepo: ref.watch(projectRepositoryProvider),
    sessionRepo: ref.watch(sessionRepositoryProvider),
  );
});
