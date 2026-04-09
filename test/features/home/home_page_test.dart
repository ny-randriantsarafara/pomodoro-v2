import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:rhythm/features/home/home_page.dart';
import 'package:rhythm/models/models.dart';
import 'package:rhythm/store/app_store.dart';
import 'package:rhythm/store/providers.dart';

import '../../helpers/test_repositories.dart';

Future<AppStore> _loadedStore({
  required List<Task> tasks,
  List<Project>? projects,
}) async {
  final store = AppStore(
    taskRepo: TestTaskRepository(initial: tasks),
    projectRepo: TestProjectRepository(initial: projects ?? []),
    sessionRepo: TestSessionRepository(),
  );
  await store.loadData();
  return store;
}

void _setDesktopViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1024, 768);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  group('HomePage task editor', () {
    testWidgets('edit flow assigns existing project', (tester) async {
      _setDesktopViewport(tester);

      final store = await _loadedStore(
        tasks: [
          Task(id: 't1', title: 'Buy milk', createdAt: DateTime(2026, 1, 1)),
        ],
        projects: [
          const Project(id: 'p1', name: 'Home', style: ProjectStyles.blue),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appStoreProvider.overrideWith((ref) => store),
          ],
          child: const MaterialApp(
            home: Scaffold(body: HomePage()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(LucideIcons.moreHorizontal));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit task'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Home'));
      await tester.pump();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(store.findTask('t1')?.projectId, 'p1');
    });

    testWidgets('edit flow reassigns project', (tester) async {
      _setDesktopViewport(tester);

      final store = await _loadedStore(
        tasks: [
          Task(
            id: 't1',
            title: 'Task',
            projectId: 'p1',
            createdAt: DateTime(2026, 1, 1),
          ),
        ],
        projects: const [
          Project(id: 'p1', name: 'Alpha', style: ProjectStyles.blue),
          Project(id: 'p2', name: 'Beta', style: ProjectStyles.emerald),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [appStoreProvider.overrideWith((ref) => store)],
          child: const MaterialApp(
            home: Scaffold(body: HomePage()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(LucideIcons.moreHorizontal));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit task'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Beta'));
      await tester.pump();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(store.findTask('t1')?.projectId, 'p2');
    });

    testWidgets('edit flow clears project', (tester) async {
      _setDesktopViewport(tester);

      final store = await _loadedStore(
        tasks: [
          Task(
            id: 't1',
            title: 'Task',
            projectId: 'p1',
            createdAt: DateTime(2026, 1, 1),
          ),
        ],
        projects: const [
          Project(id: 'p1', name: 'Alpha', style: ProjectStyles.blue),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [appStoreProvider.overrideWith((ref) => store)],
          child: const MaterialApp(
            home: Scaffold(body: HomePage()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(LucideIcons.moreHorizontal));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit task'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('No Project'));
      await tester.pump();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(store.findTask('t1')?.projectId, isNull);
    });

    testWidgets('edit flow creates project and attaches', (tester) async {
      _setDesktopViewport(tester);

      final store = await _loadedStore(
        tasks: [
          Task(id: 't1', title: 'Task', createdAt: DateTime(2026, 1, 1)),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [appStoreProvider.overrideWith((ref) => store)],
          child: const MaterialApp(
            home: Scaffold(body: HomePage()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(LucideIcons.moreHorizontal));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit task'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create new project'));
      await tester.pump();
      await tester.enterText(find.byType(TextField).last, 'Inbox');
      await tester.pump();
      await tester.tap(find.text('Add Project'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final task = store.findTask('t1');
      expect(task, isNotNull);
      expect(task!.projectId, isNotNull);
      expect(store.projects.length, 1);
      expect(store.projects.last.name, 'Inbox');
      expect(task.projectId, store.projects.last.id);
    });
  });
}
