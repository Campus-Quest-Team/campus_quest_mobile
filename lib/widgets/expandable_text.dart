import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final int maxLinesCollapsed;

  const ExpandableText(
    this.text, {
    super.key,
    this.style,
    this.maxLinesCollapsed = 2,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText>
    with SingleTickerProviderStateMixin {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(
          text: widget.text,
          style: widget.style ?? DefaultTextStyle.of(context).style,
        );

        final painter = TextPainter(
          text: span,
          maxLines: widget.maxLinesCollapsed,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        final overflows = painter.didExceedMaxLines;

        if (!overflows) {
          return Text(widget.text, style: widget.style);
        }

        return GestureDetector(
          onTap: () => setState(() => expanded = !expanded),
          child: Stack(
            children: [
              // Expanded full text (always laid out but toggled visibility)
              Opacity(
                opacity: expanded ? 1 : 0,
                child: Text(widget.text, softWrap: true, style: widget.style),
              ),
              // Collapsed text with gradient overlay
              AnimatedOpacity(
                opacity: expanded ? 0 : 1,
                duration: const Duration(milliseconds: 200),
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black, Colors.transparent],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstIn,
                  child: Text(
                    widget.text,
                    maxLines: widget.maxLinesCollapsed,
                    overflow: TextOverflow.clip,
                    softWrap: true,
                    style: widget.style,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
