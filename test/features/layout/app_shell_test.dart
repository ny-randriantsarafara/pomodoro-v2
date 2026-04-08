import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rhythm/app.dart';
import 'package:rhythm/store/providers.dart';
import '../../helpers/test_repositories.dart';

List<Override> get _testOverrides => [
      taskRepositoryProvider.overrideWithValue(TestTaskRepository()),
      projectRepositoryProvider.overrideWithValue(TestProjectRepository()),
      sessionRepositoryProvider.overrideWithValue(TestSessionRepository()),
      authRepositoryProvider.overrideWithValue(TestAuthRepository()),
    ];

void main() {
  testWidgets('desktop shell renders header nav and no bottom nav',
      (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: _testOverrides,
        child: const RhythmApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Rhythm'), findsWidgets);
    expect(find.text('Focus'), findsOneWidget);
    expect(find.text('Sign Out'), findsOneWidget);
  });

  testWidgets('mobile shell renders header and bottom nav', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: _testOverrides,
        child: const RhythmApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Rhythm'), findsWidgets);
    expect(find.text('Sign Out'), findsOneWidget);
    expect(find.text('Focus'), findsOneWidget);
  });

  testWidgets('mobile tab indicator switches with route', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: _testOverrides,
        child: const RhythmApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsOneWidget);

    final rhythmFinder = find.text('Rhythm');
    expect(rhythmFinder, findsWidgets);

    await tester.tap(rhythmFinder.last);
    await tester.pumpAndSettle();

    expect(find.text('Your Rhythm'), findsOneWidget);
  });
}
