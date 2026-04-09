import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rhythm/models/models.dart';
import 'package:rhythm/repositories/local_project_repository.dart';

void main() {
  late SharedPreferences prefs;
  late LocalProjectRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repo = LocalProjectRepository(prefs);
  });

  test('starts empty', () async {
    expect(await repo.getAll(), isEmpty);
  });

  test('add generates ID for empty-id project and persists', () async {
    const project = Project(id: '', name: 'Work', style: ProjectStyles.blue);
    await repo.add(project);
    final projects = await repo.getAll();
    expect(projects.length, 1);
    expect(projects.first.name, 'Work');
    expect(projects.first.id, isNotEmpty);
  });

  test('add appends to end (oldest first)', () async {
    const p1 = Project(id: 'p1', name: 'First', style: ProjectStyles.blue);
    const p2 = Project(id: 'p2', name: 'Second', style: ProjectStyles.emerald);
    await repo.add(p1);
    await repo.add(p2);
    final projects = await repo.getAll();
    expect(projects.first.id, 'p1');
    expect(projects.last.id, 'p2');
  });

  test('data persists across instances', () async {
    const project = Project(id: 'p1', name: 'Persist', style: ProjectStyles.purple);
    await repo.add(project);

    final repo2 = LocalProjectRepository(prefs);
    final projects = await repo2.getAll();
    expect(projects.length, 1);
    expect(projects.first.name, 'Persist');
  });
}
