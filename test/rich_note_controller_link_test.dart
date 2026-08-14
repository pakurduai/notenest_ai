import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notenest_ai/core/controllers/rich_note_controller.dart';

void main() {
  test('RichNoteController auto detects email links (pakurduai@gmail.com) and web URLs', () {
    final controller = RichNoteController();
    controller.text = 'Contact us at pakurduai@gmail.com or visit www.google.com for info.';

    final BuildContext context = _DummyContext();
    final TextSpan span = controller.buildTextSpan(
      context: context,
      style: const TextStyle(fontSize: 14.0, color: Colors.black),
      withComposing: false,
    );

    expect(span.children, isNotNull);
    final children = span.children!;
    expect(children.length, greaterThan(0));

    // Verify email link is present with blue color and recognizer
    bool foundEmailLink = false;
    bool foundUrlLink = false;

    for (final child in children) {
      if (child is TextSpan) {
        if (child.text == 'pakurduai@gmail.com') {
          foundEmailLink = true;
          expect(child.style?.color, equals(const Color(0xFF2563EB)));
          expect(child.recognizer, isNotNull);
        }
        if (child.text == 'www.google.com') {
          foundUrlLink = true;
          expect(child.style?.color, equals(const Color(0xFF2563EB)));
          expect(child.recognizer, isNotNull);
        }
      }
    }

    expect(foundEmailLink, isTrue);
    expect(foundUrlLink, isTrue);
  });
}

class _DummyContext implements BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
