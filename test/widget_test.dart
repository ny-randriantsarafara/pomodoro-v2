import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rhythm/app.dart';

void main() {
  testWidgets('app renders without errors', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: RhythmApp()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Today'), findsOneWidget);
  });
}
