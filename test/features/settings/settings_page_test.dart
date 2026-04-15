import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:rhythm/alerts/alerts.dart';
import 'package:rhythm/app.dart';
import 'package:rhythm/store/providers.dart';
import '../../helpers/test_repositories.dart';

AlertSettingsController _buildController({
  bool notifications = true,
  bool sound = true,
}) {
  final repo = InMemoryAlertSettingsRepository(
    AlertSettings(notificationsEnabled: notifications, soundEnabled: sound),
  );
  final controller = AlertSettingsController(repo);
  controller.load();
  return controller;
}

void main() {
  testWidgets('settings page shows alert toggles and account actions',
      (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taskRepositoryProvider.overrideWithValue(TestTaskRepository()),
          projectRepositoryProvider.overrideWithValue(TestProjectRepository()),
          sessionRepositoryProvider
              .overrideWithValue(TestSessionRepository()),
          authRepositoryProvider
              .overrideWithValue(TestAuthRepository()),
          alertSettingsControllerProvider
              .overrideWith((ref) => _buildController()),
        ],
        child: const RhythmApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(LucideIcons.settings));
    await tester.pumpAndSettle();

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Sound'), findsOneWidget);
    expect(find.text('Sign Out'), findsOneWidget);
    expect(find.text('Delete Account'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
  });

  testWidgets('settings page toggles notification preference', (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = _buildController();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taskRepositoryProvider.overrideWithValue(TestTaskRepository()),
          projectRepositoryProvider.overrideWithValue(TestProjectRepository()),
          sessionRepositoryProvider
              .overrideWithValue(TestSessionRepository()),
          authRepositoryProvider
              .overrideWithValue(TestAuthRepository()),
          alertSettingsControllerProvider.overrideWith((ref) => controller),
        ],
        child: const RhythmApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(LucideIcons.settings));
    await tester.pumpAndSettle();

    final notificationsSwitch = find.byType(Switch).first;
    await tester.tap(notificationsSwitch);
    await tester.pumpAndSettle();

    expect(controller.value.notificationsEnabled, isFalse);
  });
}
