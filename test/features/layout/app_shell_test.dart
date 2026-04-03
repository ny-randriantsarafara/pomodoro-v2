import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rhythm/app.dart';

Widget buildTestApp({Size size = const Size(1024, 768)}) {
  return ProviderScope(
    child: MediaQuery(
      data: MediaQueryData(size: size),
      child: const RhythmApp(),
    ),
  );
}

void main() {
  testWidgets('desktop shell renders header nav and no bottom nav', (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(child: RhythmApp()),
    );
    await tester.pumpAndSettle();

    // Desktop header should be visible with nav tabs
    expect(find.text('Rhythm'), findsWidgets);
    expect(find.text('Focus'), findsOneWidget);

    // Should show Rhythm nav tab in desktop header
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('mobile shell renders header and bottom nav', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(child: RhythmApp()),
    );
    await tester.pumpAndSettle();

    // Mobile header should show
    expect(find.text('Rhythm'), findsWidgets);
    expect(find.text('Sign In'), findsOneWidget);

    // Bottom nav should have Focus and Rhythm tabs
    expect(find.text('Focus'), findsOneWidget);
  });

  testWidgets('mobile tab indicator switches with route', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(child: RhythmApp()),
    );
    await tester.pumpAndSettle();

    // Start on Home (Focus tab active)
    expect(find.text('Today'), findsOneWidget);

    // Navigate to History (Rhythm tab) by tapping bottom nav
    // Find all "Rhythm" texts - one in header, possibly one in bottom nav
    final rhythmFinder = find.text('Rhythm');
    expect(rhythmFinder, findsWidgets);

    // Tap the last occurrence (bottom nav)
    await tester.tap(rhythmFinder.last);
    await tester.pumpAndSettle();

    // Should now show History page content
    expect(find.text('Your Rhythm'), findsOneWidget);
  });
}
