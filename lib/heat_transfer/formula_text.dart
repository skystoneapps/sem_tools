import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'symbol_glossary.dart';

/// Renders a formula written in a tiny markup: `_x` / `_{xy}` for subscripts
/// and `^x` / `^{xy}` for superscripts.
///
/// Known symbols (see [describeSymbol]) get a dotted underline and a tooltip
/// explaining them, unless [symbolTooltips] is false.
class FormulaText extends StatelessWidget {
  const FormulaText(
    this.source, {
    super.key,
    this.style,
    this.textAlign,
    this.symbolTooltips = true,
  });

  final String source;
  final TextStyle? style;
  final TextAlign? textAlign;
  final bool symbolTooltips;

  @override
  Widget build(BuildContext context) {
    final base = DefaultTextStyle.of(context).style.merge(style);
    final spans = <InlineSpan>[];
    var last = 0;
    if (symbolTooltips) {
      final l10n = AppLocalizations.of(context);
      for (final match in symbolPattern.allMatches(source)) {
        final symbol = match[0]!;
        final info = describeSymbol(symbol, l10n);
        if (info == null) continue;
        spans
          ..addAll(_parse(source.substring(last, match.start), base))
          ..add(_symbolSpan(symbol, info, base));
        last = match.end;
      }
    }
    spans.addAll(_parse(source.substring(last), base));
    return Text.rich(
      TextSpan(children: spans),
      style: base,
      textAlign: textAlign,
    );
  }

  static InlineSpan _symbolSpan(
    String symbol,
    (String, String?) info,
    TextStyle base,
  ) {
    final (description, unit) = info;
    final underlined = base.copyWith(
      decoration: TextDecoration.underline,
      decorationStyle: TextDecorationStyle.dotted,
      decorationColor: base.color?.withValues(alpha: 0.5),
    );
    return WidgetSpan(
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
      child: Tooltip(
        message: unit == null ? description : '$description  [$unit]',
        waitDuration: const Duration(milliseconds: 250),
        child: MouseRegion(
          cursor: SystemMouseCursors.help,
          child: Text.rich(
            TextSpan(style: underlined, children: _parse(symbol, base)),
            style: base,
          ),
        ),
      ),
    );
  }

  static List<InlineSpan> _parse(String source, TextStyle base) {
    final spans = <InlineSpan>[];
    final buffer = StringBuffer();
    final fontSize = base.fontSize ?? 14;
    final small = base.copyWith(fontSize: fontSize * 0.7);

    void flush() {
      if (buffer.isEmpty) return;
      spans.add(TextSpan(text: buffer.toString()));
      buffer.clear();
    }

    var i = 0;
    while (i < source.length) {
      final c = source[i];
      if ((c == '_' || c == '^') && i + 1 < source.length) {
        flush();
        String group;
        if (source[i + 1] == '{') {
          final end = source.indexOf('}', i + 2);
          group = source.substring(i + 2, end);
          i = end + 1;
        } else {
          group = source[i + 1];
          i += 2;
        }
        final isSub = c == '_';
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: Transform.translate(
              offset: Offset(0, isSub ? fontSize * 0.22 : -fontSize * 0.42),
              child: Text(group, style: small),
            ),
          ),
        );
      } else {
        buffer.write(c);
        i++;
      }
    }
    flush();
    return spans;
  }
}
