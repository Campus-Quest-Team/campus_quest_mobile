import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const ExpandableText(this.text, {super.key, this.style});

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool expanded = false;
  bool _overflows = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkOverflow());
  }

  void _checkOverflow() {
    final textPainter = TextPainter(
      text: TextSpan(
        text: widget.text,
        style: widget.style ?? DefaultTextStyle.of(context).style,
      ),
      maxLines: 2,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: MediaQuery.of(context).size.width);

    if (_overflows != textPainter.didExceedMaxLines) {
      setState(() {
        _overflows = textPainter.didExceedMaxLines;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_overflows) {
      return Text(widget.text, style: widget.style);
    }

    return GestureDetector(
      onTap: () => setState(() => expanded = !expanded),
      child: AnimatedCrossFade(
        crossFadeState: expanded
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 200),
        firstChild: ShaderMask(
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
            maxLines: 2,
            overflow: TextOverflow.clip,
            softWrap: true,
            style: widget.style,
          ),
        ),
        secondChild: Text(widget.text, softWrap: true, style: widget.style),
      ),
    );
  }
}
