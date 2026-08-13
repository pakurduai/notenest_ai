import 'package:flutter/material.dart';

/// A single formatting span applied to a range of text
class RichSpan {
  final int start;
  final int end;
  final bool bold;
  final bool italic;
  final bool underline;
  final bool strikethrough;
  final bool highlight;
  final bool code;
  final bool quote;
  final bool superscript;
  final bool subscript;
  final Color? textColor;
  final Color? bgColor;

  const RichSpan({
    required this.start,
    required this.end,
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.strikethrough = false,
    this.highlight = false,
    this.code = false,
    this.quote = false,
    this.superscript = false,
    this.subscript = false,
    this.textColor,
    this.bgColor,
  });

  RichSpan copyWith({
    int? start,
    int? end,
    bool? bold,
    bool? italic,
    bool? underline,
    bool? strikethrough,
    bool? highlight,
    bool? code,
    bool? quote,
    bool? superscript,
    bool? subscript,
    Color? textColor,
    Color? bgColor,
    bool clearTextColor = false,
    bool clearBgColor = false,
  }) {
    return RichSpan(
      start: start ?? this.start,
      end: end ?? this.end,
      bold: bold ?? this.bold,
      italic: italic ?? this.italic,
      underline: underline ?? this.underline,
      strikethrough: strikethrough ?? this.strikethrough,
      highlight: highlight ?? this.highlight,
      code: code ?? this.code,
      quote: quote ?? this.quote,
      superscript: superscript ?? this.superscript,
      subscript: subscript ?? this.subscript,
      textColor: clearTextColor ? null : (textColor ?? this.textColor),
      bgColor: clearBgColor ? null : (bgColor ?? this.bgColor),
    );
  }

  bool get hasNoFormatting =>
      !bold &&
      !italic &&
      !underline &&
      !strikethrough &&
      !highlight &&
      !code &&
      !quote &&
      !superscript &&
      !subscript &&
      textColor == null &&
      bgColor == null;

  /// Merge this span with another span's formatting (OR merge)
  RichSpan mergeFormatting(RichSpan other) {
    return copyWith(
      bold: bold || other.bold,
      italic: italic || other.italic,
      underline: underline || other.underline,
      strikethrough: strikethrough || other.strikethrough,
      highlight: highlight || other.highlight,
      code: code || other.code,
      quote: quote || other.quote,
      superscript: superscript || other.superscript,
      subscript: subscript || other.subscript,
      textColor: other.textColor ?? textColor,
      bgColor: other.bgColor ?? bgColor,
    );
  }
}

/// Custom TextEditingController that renders rich text formatting
/// using a list of RichSpan objects.
class RichNoteController extends TextEditingController {
  // Global / global-fallback style (applies when no span covers a position)
  bool globalBold = false;
  bool globalItalic = false;
  bool globalUnderline = false;
  bool globalStrikethrough = false;
  bool globalHighlight = false;
  bool globalCode = false;
  bool globalQuote = false;
  Color globalTextColor = const Color(0xFF1E1738);
  double globalFontSize = 14.0;
  FontWeight globalFontWeight = FontWeight.w500;
  String globalFontFamily = 'Inter';
  TextAlign globalTextAlign = TextAlign.left;

  final List<RichSpan> _spans = [];

  List<RichSpan> get spans => List.unmodifiable(_spans);

  // ── Apply formatting to selection ──────────────────────────────────────────

  void applyToSelection({
    bool? bold,
    bool? italic,
    bool? underline,
    bool? strikethrough,
    bool? highlight,
    bool? code,
    bool? quote,
    bool? superscript,
    bool? subscript,
    Color? textColor,
    Color? bgColor,
    bool toggle = true,
  }) {
    final sel = selection;
    if (!sel.isValid || sel.isCollapsed) {
      // No selection → apply globally
      if (bold != null) globalBold = toggle ? !globalBold : bold;
      if (italic != null) globalItalic = toggle ? !globalItalic : italic;
      if (underline != null) globalUnderline = toggle ? !globalUnderline : underline;
      if (strikethrough != null) globalStrikethrough = toggle ? !globalStrikethrough : strikethrough;
      if (highlight != null) globalHighlight = toggle ? !globalHighlight : highlight;
      if (code != null) globalCode = toggle ? !globalCode : code;
      if (quote != null) globalQuote = toggle ? !globalQuote : quote;
      if (textColor != null) globalTextColor = textColor;
      notifyListeners();
      return;
    }

    final start = sel.start;
    final end = sel.end;

    // Check if the selection already has all the requested formatting (for toggle)
    bool alreadyApplied = false;
    if (toggle) {
      if (bold != null) alreadyApplied = _selectionHas(start, end, 'bold');
      if (italic != null) alreadyApplied = _selectionHas(start, end, 'italic');
      if (underline != null) alreadyApplied = _selectionHas(start, end, 'underline');
      if (strikethrough != null) alreadyApplied = _selectionHas(start, end, 'strikethrough');
      if (highlight != null) alreadyApplied = _selectionHas(start, end, 'highlight');
      if (code != null) alreadyApplied = _selectionHas(start, end, 'code');
      if (quote != null) alreadyApplied = _selectionHas(start, end, 'quote');
    }

    // Remove any existing spans that overlap this range
    _spans.removeWhere((s) => s.start < end && s.end > start);

    // If not already applied → add span
    if (!alreadyApplied) {
      _spans.add(RichSpan(
        start: start,
        end: end,
        bold: bold ?? false,
        italic: italic ?? false,
        underline: underline ?? false,
        strikethrough: strikethrough ?? false,
        highlight: highlight ?? false,
        code: code ?? false,
        quote: quote ?? false,
        superscript: superscript ?? false,
        subscript: subscript ?? false,
        textColor: textColor,
        bgColor: bgColor,
      ));
    }
    notifyListeners();
  }

  bool _selectionHas(int start, int end, String format) {
    for (final span in _spans) {
      if (span.start <= start && span.end >= end) {
        switch (format) {
          case 'bold':
            return span.bold;
          case 'italic':
            return span.italic;
          case 'underline':
            return span.underline;
          case 'strikethrough':
            return span.strikethrough;
          case 'highlight':
            return span.highlight;
          case 'code':
            return span.code;
          case 'quote':
            return span.quote;
        }
      }
    }
    return false;
  }

  bool isFormatActiveInSelection(String format) {
    final sel = selection;
    if (!sel.isValid || sel.isCollapsed) {
      switch (format) {
        case 'bold':
          return globalBold;
        case 'italic':
          return globalItalic;
        case 'underline':
          return globalUnderline;
        case 'strikethrough':
          return globalStrikethrough;
        case 'highlight':
          return globalHighlight;
        case 'code':
          return globalCode;
        case 'quote':
          return globalQuote;
      }
      return false;
    }
    return _selectionHas(sel.start, sel.end, format);
  }

  /// Clear all formatting in selection
  void clearFormattingInSelection() {
    final sel = selection;
    if (!sel.isValid || sel.isCollapsed) {
      globalBold = false;
      globalItalic = false;
      globalUnderline = false;
      globalStrikethrough = false;
      globalHighlight = false;
      globalCode = false;
      globalQuote = false;
      notifyListeners();
      return;
    }
    _spans.removeWhere((s) => s.start < sel.end && s.end > sel.start);
    notifyListeners();
  }

  /// Update span offsets when text is inserted/deleted
  void _adjustSpansForTextChange(int offset, int delta) {
    final updated = <RichSpan>[];
    for (final span in _spans) {
      if (span.end <= offset) {
        // Before change — unchanged
        updated.add(span);
      } else if (span.start >= offset) {
        // After change — shift
        final newStart = (span.start + delta).clamp(0, text.length);
        final newEnd = (span.end + delta).clamp(0, text.length);
        if (newStart < newEnd) {
          updated.add(span.copyWith(start: newStart, end: newEnd));
        }
      } else {
        // Overlaps change — extend or shrink
        final newEnd = (span.end + delta).clamp(span.start, text.length);
        if (span.start < newEnd) {
          updated.add(span.copyWith(end: newEnd));
        }
      }
    }
    _spans
      ..clear()
      ..addAll(updated);
  }

  @override
  set value(TextEditingValue newValue) {
    final oldText = text;
    final newText = newValue.text;
    if (oldText != newText) {
      // Find first difference
      int diffStart = 0;
      while (diffStart < oldText.length &&
          diffStart < newText.length &&
          oldText[diffStart] == newText[diffStart]) {
        diffStart++;
      }
      final delta = newText.length - oldText.length;
      _adjustSpansForTextChange(diffStart, delta);
    }
    super.value = newValue;
  }

  // ── Build TextSpan tree for rendering ──────────────────────────────────────

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final fullText = text;
    if (fullText.isEmpty) {
      return TextSpan(text: '', style: style);
    }

    // Build a list of char-level formatting by merging spans
    final int len = fullText.length;
    final List<_CharFormat> charFormats = List.generate(len, (_) => _CharFormat(
      bold: globalBold,
      italic: globalItalic,
      underline: globalUnderline,
      strikethrough: globalStrikethrough,
      highlight: globalHighlight,
      code: globalCode,
      quote: globalQuote,
      superscript: false,
      subscript: false,
      textColor: globalTextColor,
      bgColor: null,
    ));

    for (final span in _spans) {
      final s = span.start.clamp(0, len);
      final e = span.end.clamp(0, len);
      for (int i = s; i < e; i++) {
        charFormats[i] = _CharFormat(
          bold: span.bold || charFormats[i].bold,
          italic: span.italic || charFormats[i].italic,
          underline: span.underline || charFormats[i].underline,
          strikethrough: span.strikethrough || charFormats[i].strikethrough,
          highlight: span.highlight || charFormats[i].highlight,
          code: span.code || charFormats[i].code,
          quote: span.quote || charFormats[i].quote,
          superscript: span.superscript,
          subscript: span.subscript,
          textColor: span.textColor ?? charFormats[i].textColor,
          bgColor: span.bgColor ?? charFormats[i].bgColor,
        );
      }
    }

    // Group consecutive chars with same formatting into spans
    final List<InlineSpan> inlineSpans = [];
    int i = 0;
    while (i < len) {
      final fmt = charFormats[i];
      int j = i + 1;
      while (j < len && charFormats[j] == fmt) {
        j++;
      }
      final segText = fullText.substring(i, j);
      final isCode = fmt.code;
      final isHighlight = fmt.highlight;
      final isQuote = fmt.quote;

      TextDecoration decoration = TextDecoration.combine([
        if (fmt.underline) TextDecoration.underline,
        if (fmt.strikethrough) TextDecoration.lineThrough,
      ]);

      final ts = TextStyle(
        fontWeight: fmt.bold ? FontWeight.bold : (style?.fontWeight ?? FontWeight.normal),
        fontStyle: fmt.italic ? FontStyle.italic : FontStyle.normal,
        decoration: decoration,
        color: fmt.textColor ?? style?.color,
        backgroundColor: isHighlight
            ? const Color(0xFFFEF08A)
            : isCode
                ? const Color(0xFFEFF6FF)
                : (fmt.bgColor),
        fontFamily: isCode ? 'monospace' : style?.fontFamily,
        fontSize: fmt.superscript || fmt.subscript
            ? ((style?.fontSize ?? 14) * 0.7)
            : style?.fontSize,
        height: isQuote ? 1.6 : style?.height,
        letterSpacing: isCode ? 0.5 : style?.letterSpacing,
      );

      inlineSpans.add(TextSpan(text: segText, style: ts));
      i = j;
    }

    return TextSpan(children: inlineSpans, style: style);
  }

  void selectAll() {
    selection = TextSelection(baseOffset: 0, extentOffset: text.length);
    notifyListeners();
  }

  void selectCurrentWord() {
    if (text.isEmpty) return;
    final pos = selection.baseOffset.clamp(0, text.length - 1);
    int start = pos;
    int end = pos;
    while (start > 0 && text[start - 1] != ' ' && text[start - 1] != '\n') {
      start--;
    }
    while (end < text.length && text[end] != ' ' && text[end] != '\n') {
      end++;
    }
    selection = TextSelection(baseOffset: start, extentOffset: end);
    notifyListeners();
  }

  void selectCurrentLine() {
    if (text.isEmpty) return;
    final pos = selection.baseOffset.clamp(0, text.length);
    int start = pos;
    int end = pos;
    while (start > 0 && text[start - 1] != '\n') {
      start--;
    }
    while (end < text.length && text[end] != '\n') {
      end++;
    }
    selection = TextSelection(baseOffset: start, extentOffset: end);
    notifyListeners();
  }

  void selectCurrentParagraph() {
    if (text.isEmpty) return;
    final pos = selection.baseOffset.clamp(0, text.length);
    int start = pos;
    int end = pos;
    // Go back to find paragraph start (double newline or start)
    while (start > 1 && !(text[start - 1] == '\n' && text[start - 2] == '\n')) {
      start--;
    }
    if (start > 0 && text[start - 1] == '\n') start = (start - 1).clamp(0, text.length);
    // Go forward to find paragraph end
    while (end < text.length - 1 && !(text[end] == '\n' && text[end + 1] == '\n')) {
      end++;
    }
    selection = TextSelection(baseOffset: start, extentOffset: end);
    notifyListeners();
  }

  void deselect() {
    selection = TextSelection.collapsed(offset: selection.end);
    notifyListeners();
  }
}

class _CharFormat {
  final bool bold;
  final bool italic;
  final bool underline;
  final bool strikethrough;
  final bool highlight;
  final bool code;
  final bool quote;
  final bool superscript;
  final bool subscript;
  final Color? textColor;
  final Color? bgColor;

  const _CharFormat({
    required this.bold,
    required this.italic,
    required this.underline,
    required this.strikethrough,
    required this.highlight,
    required this.code,
    required this.quote,
    required this.superscript,
    required this.subscript,
    required this.textColor,
    required this.bgColor,
  });

  @override
  bool operator ==(Object other) =>
      other is _CharFormat &&
      bold == other.bold &&
      italic == other.italic &&
      underline == other.underline &&
      strikethrough == other.strikethrough &&
      highlight == other.highlight &&
      code == other.code &&
      quote == other.quote &&
      superscript == other.superscript &&
      subscript == other.subscript &&
      textColor == other.textColor &&
      bgColor == other.bgColor;

  @override
  int get hashCode => Object.hash(
        bold,
        italic,
        underline,
        strikethrough,
        highlight,
        code,
        quote,
        superscript,
        subscript,
        textColor,
        bgColor,
      );
}
