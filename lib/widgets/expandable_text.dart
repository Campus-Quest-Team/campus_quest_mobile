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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => expanded = !expanded),
      child: AnimatedCrossFade(
        crossFadeState: expanded
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 200),
        firstChild: LayoutBuilder(
          builder: (context, constraints) {
            return ShaderMask(
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
            );
          },
        ),
        secondChild: LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth),
              child: Text(widget.text, softWrap: true, style: widget.style),
            );
          },
        ),
      ),
    );
  }
}
