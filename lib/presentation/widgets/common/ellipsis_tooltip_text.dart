import 'package:flutter/material.dart';

/// Single-line amount text that ellipsis-trims when it does not fit its
/// available width, and always exposes the full value via a long-press
/// tooltip (FMT-02). The tooltip is attached unconditionally - its message
/// always equals the visible text, which is harmless when nothing is
/// actually truncated (15-CONTEXT.md Claude's Discretion). No truncation
/// measurement, no LayoutBuilder, no TextPainter.
class EllipsisTooltipText extends StatelessWidget {
  const EllipsisTooltipText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.tooltipMessage,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  /// Overrides the tooltip text, e.g. to show the untrimmed value.
  final String? tooltipMessage;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltipMessage ?? text,
    child: Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
    ),
  );
}
