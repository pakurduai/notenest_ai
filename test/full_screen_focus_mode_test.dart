import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notenest_ai/features/notes/presentation/screens/create_note_screen.dart';

void main() {
  testWidgets('CreateNoteScreen toggles toolbar visibility on Hide Tools / Show Tools tap', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CreateNoteScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial state shows 'Hide Tools' trigger button in meta bar
    expect(find.text('Hide Tools'), findsOneWidget);

    // Tap 'Hide Tools' pill to collapse toolbars and maximize writing space
    await tester.tap(find.text('Hide Tools'));
    await tester.pumpAndSettle();

    // Verify toolbars are collapsed and 'Show Tools' option appears
    expect(find.text('Show Tools'), findsOneWidget);

    // Tap 'Show Tools' to expand toolbars back
    await tester.tap(find.text('Show Tools'));
    await tester.pumpAndSettle();

    // Verify toolbars expanded and 'Hide Tools' option is visible again
    expect(find.text('Hide Tools'), findsOneWidget);
  });
}
