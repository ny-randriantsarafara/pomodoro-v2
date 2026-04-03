import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhythm/shared/widgets/anchored_overlay.dart';

void main() {
  testWidgets('AnchoredOverlayTarget builds child', (tester) async {
    final link = LayerLink();
    await tester.pumpWidget(
      MaterialApp(
        home: AnchoredOverlayTarget(
          link: link,
          child: const Text('anchor'),
        ),
      ),
    );
    expect(find.text('anchor'), findsOneWidget);
  });

  testWidgets('buildAnchoredOverlay builds backdrop and child', (tester) async {
    final link = LayerLink();
    bool dismissed = false;

    late OverlayEntry entry;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                entry = buildAnchoredOverlay(
                  context: context,
                  link: link,
                  onDismiss: () => dismissed = true,
                  child: const Text('menu'),
                );
                Overlay.of(context).insert(entry);
              });
              return AnchoredOverlayTarget(
                link: link,
                child: const SizedBox(width: 100, height: 50),
              );
            },
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();
    expect(find.text('menu'), findsOneWidget);

    await tester.tapAt(const Offset(1, 1));
    await tester.pump();
    expect(dismissed, true);

    entry.remove();
  });
}
