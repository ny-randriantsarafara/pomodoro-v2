import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rhythm/models/models.dart';
import 'package:rhythm/repositories/local_session_repository.dart';

void main() {
  late SharedPreferences prefs;
  late LocalSessionRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repo = LocalSessionRepository(prefs);
  });

  test('starts empty', () async {
    expect(await repo.getAll(), isEmpty);
  });

  test('add inserts at beginning (newest first)', () async {
    final s1 = Session(
      id: 's1', taskId: 't1', taskTitle: 'A', preset: 25,
      duration: 1500, completedAt: DateTime(2026, 1, 1),
    );
    final s2 = Session(
      id: 's2', taskId: 't2', taskTitle: 'B', preset: 50,
      duration: 3000, completedAt: DateTime(2026, 1, 2),
    );
    await repo.add(s1);
    await repo.add(s2);
    final sessions = await repo.getAll();
    expect(sessions.first.id, 's2');
  });

  test('data persists across instances', () async {
    final session = Session(
      id: 's1', taskId: 't1', taskTitle: 'Persist', preset: 25,
      duration: 1500, completedAt: DateTime(2026, 1, 1),
    );
    await repo.add(session);

    final repo2 = LocalSessionRepository(prefs);
    final sessions = await repo2.getAll();
    expect(sessions.length, 1);
    expect(sessions.first.taskTitle, 'Persist');
  });
}
