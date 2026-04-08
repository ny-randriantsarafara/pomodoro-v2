import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rhythm/app.dart';
import 'package:rhythm/store/providers.dart';
import 'helpers/test_repositories.dart';

void main() {
  testWidgets('app renders without errors', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taskRepositoryProvider.overrideWithValue(TestTaskRepository()),
          projectRepositoryProvider.overrideWithValue(TestProjectRepository()),
          sessionRepositoryProvider.overrideWithValue(TestSessionRepository()),
          authRepositoryProvider.overrideWithValue(TestAuthRepository()),
        ],
        child: const RhythmApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Today'), findsOneWidget);
  });
}
