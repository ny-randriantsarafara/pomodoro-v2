import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhythm/features/home/widgets/task_overflow_menu.dart';

void main() {
  testWidgets('overflow menu shows Edit task and Delete', (tester) async {
    var editTapped = false;
    var deleteTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TaskOverflowMenu(
            onEdit: () => editTapped = true,
            onDelete: () => deleteTapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Edit task'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);

    await tester.tap(find.text('Edit task'));
    expect(editTapped, true);
    expect(deleteTapped, false);

    await tester.tap(find.text('Delete'));
    expect(deleteTapped, true);
  });
}
