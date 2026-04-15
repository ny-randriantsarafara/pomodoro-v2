import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:rhythm/alerts/alerts.dart';
import 'package:rhythm/app.dart';
import 'package:rhythm/store/providers.dart';
import '../../helpers/test_repositories.dart';

AlertSettingsController _buildController() {
  final repo = InMemoryAlertSettingsRepository(
    const AlertSettings(notificationsEnabled: true, soundEnabled: true),
  );
  final controller = AlertSettingsController(repo);
  controller.load();
  return controller;
}

List<Override> get _baseOverrides => [
      taskRepositoryProvider.overrideWithValue(TestTaskRepository()),
      projectRepositoryProvider.overrideWithValue(TestProjectRepository()),
      sessionRepositoryProvider.overrideWithValue(TestSessionRepository()),
    ];

void main() {
  testWidgets('privacy page shows expected policy content via settings',
      (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ..._baseOverrides,
          authRepositoryProvider.overrideWithValue(TestAuthRepository()),
          alertSettingsControllerProvider
              .overrideWith((ref) => _buildController()),
        ],
        child: const RhythmApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(LucideIcons.settings));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Privacy Policy'));
    await tester.pumpAndSettle();

    expect(find.text('Privacy Policy'), findsWidgets);
    expect(find.text('What Rhythm Collects'), findsOneWidget);
    expect(find.textContaining('tasks, projects, and sessions'), findsWidgets);
  });
}
