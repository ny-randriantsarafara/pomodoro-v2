import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhythm/features/home/widgets/task_editor.dart';
import 'package:rhythm/models/models.dart';

Future<void> _unusedSaveHandler(String title, String? projectId) async {}

void main() {
  group('TaskEditor', () {
    testWidgets('prefills title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskEditor(
              initialTitle: 'Hello Task',
              initialProjectId: null,
              projects: const [],
              onSave: _unusedSaveHandler,
              onCancel: () {},
              onCreateProject: (_) async => 'p_new',
            ),
          ),
        ),
      );

      final field = tester.widget<TextField>(find.byKey(const Key('task_editor_title')));
      expect(field.controller?.text, 'Hello Task');
    });

    testWidgets('shows selected project label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskEditor(
              initialTitle: 'T',
              initialProjectId: 'p1',
              projects: const [
                Project(id: 'p1', name: 'Work project', style: ProjectStyles.blue),
              ],
              onSave: _unusedSaveHandler,
              onCancel: () {},
              onCreateProject: (_) async => 'p_new',
            ),
          ),
        ),
      );

      expect(find.text('Work project'), findsOneWidget);
    });

    testWidgets('Save is disabled when title is blank', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskEditor(
              initialTitle: 'x',
              initialProjectId: null,
              projects: const [],
              onSave: _unusedSaveHandler,
              onCancel: () {},
              onCreateProject: (_) async => 'p_new',
            ),
          ),
        ),
      );

      await tester.enterText(find.byKey(const Key('task_editor_title')), '');
      await tester.pump();

      final button = tester.widget<FilledButton>(find.byKey(const Key('task_editor_save')));
      expect(button.onPressed, isNull);
    });

    testWidgets('selecting another project passes its id on save', (tester) async {
      String? savedProjectId;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskEditor(
              initialTitle: 'T',
              initialProjectId: 'p1',
              projects: const [
                Project(id: 'p1', name: 'Alpha', style: ProjectStyles.blue),
                Project(id: 'p2', name: 'Beta', style: ProjectStyles.emerald),
              ],
              onSave: (title, projectId) async {
                assert(title.isNotEmpty);
                savedProjectId = projectId;
              },
              onCancel: () {},
              onCreateProject: (_) async => 'p_new',
            ),
          ),
        ),
      );

      await tester.tap(find.text('Beta'));
      await tester.pump();
      await tester.tap(find.byKey(const Key('task_editor_save')));
      await tester.pump();

      expect(savedProjectId, 'p2');
    });

    testWidgets('No Project then Save passes null project id', (tester) async {
      String? capturedTitle;
      String? capturedProjectId;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskEditor(
              initialTitle: 'Keep me',
              initialProjectId: 'p1',
              projects: const [
                Project(id: 'p1', name: 'Work', style: ProjectStyles.blue),
              ],
              onSave: (title, projectId) async {
                capturedTitle = title;
                capturedProjectId = projectId;
              },
              onCancel: () {},
              onCreateProject: (_) async => 'p_new',
            ),
          ),
        ),
      );

      await tester.tap(find.text('No Project'));
      await tester.pump();
      await tester.tap(find.byKey(const Key('task_editor_save')));
      await tester.pump();

      expect(capturedTitle, 'Keep me');
      expect(capturedProjectId, isNull);
    });

    testWidgets('inline create calls onCreateProject and save uses new id',
        (tester) async {
      String? createdName;
      String? savedProjectId;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskEditor(
              initialTitle: 'Task',
              initialProjectId: null,
              projects: const [],
              onSave: (title, projectId) async {
                assert(title.isNotEmpty);
                savedProjectId = projectId;
              },
              onCancel: () {},
              onCreateProject: (name) async {
                createdName = name;
                return 'new_proj_id';
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Create new project'));
      await tester.pump();
      await tester.enterText(find.byType(TextField).last, 'Fresh');
      await tester.pump();
      await tester.tap(find.text('Add Project'));
      await tester.pump();
      await tester.tap(find.byKey(const Key('task_editor_save')));
      await tester.pump();

      expect(createdName, 'Fresh');
      expect(savedProjectId, 'new_proj_id');
    });
  });
}
