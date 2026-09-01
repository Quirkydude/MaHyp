import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// For illustrations whose only animations are opacity pulses,
/// this widget renders the static SVG and overlays pulsing elements
/// drawn by the provided [overlayBuilder].
class AnimatedSvgIllustration extends StatefulWidget {
  final String assetPath;
  final double size;
  final Widget Function(BuildContext context, List<double> pulseValues)
  overlayBuilder;
  final List<double> pulseDurations; // seconds per animation

  const AnimatedSvgIllustration({
    super.key,
    required this.assetPath,
    required this.overlayBuilder,
    required this.pulseDurations,
    this.size = 200,
  });

  @override
  State<AnimatedSvgIllustration> createState() => _AnimatedSvgState();
}

class _AnimatedSvgState extends State<AnimatedSvgIllustration>
    with TickerProviderStateMixin {
  final List<AnimationController> _controllers = [];

  @override
  void initState() {
    super.initState();
    for (final dur in widget.pulseDurations) {
      _controllers.add(
        AnimationController(
          vsync: this,
          duration: Duration(milliseconds: (dur * 1000).toInt()),
        )..repeat(reverse: true),
      );
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge(_controllers),
        builder: (ctx, __) {
          final values = _controllers.map((c) => c.value).toList();
          return Stack(
            children: [
              SvgPicture.asset(
                widget.assetPath,
                width: widget.size,
                height: widget.size,
              ),
              widget.overlayBuilder(ctx, values),
            ],
          );
        },
      ),
    );
  }
}
