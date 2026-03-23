import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum SvgAnimationType {
  pulse,
  float,
  wiggle,
  bounce 
}

class AnimatedSvgWrapper extends StatefulWidget {
  final String assetPath;
  final double size;
  final SvgAnimationType animationType;

  const AnimatedSvgWrapper({
    super.key,
    required this.assetPath,
    this.size = 200,
    required this.animationType,
  });

  @override
  State<AnimatedSvgWrapper> createState() => _AnimatedSvgWrapperState();
}

class _AnimatedSvgWrapperState extends State<AnimatedSvgWrapper> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    if (widget.animationType == SvgAnimationType.bounce) {
      _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
      _animation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
      _controller.forward();
    } else {
      _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
      _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        Widget svgWidget = SvgPicture.asset(
          widget.assetPath,
          width: widget.size,
          height: widget.size,
        );

        if (widget.animationType == SvgAnimationType.pulse) {
          return Transform.scale(
            scale: 0.95 + (_animation.value * 0.1), 
            child: svgWidget,
          );
        } else if (widget.animationType == SvgAnimationType.float) {
          return Transform.translate(
            offset: Offset(0, -5 + (_animation.value * 10)),
            child: svgWidget,
          );
        } else if (widget.animationType == SvgAnimationType.wiggle) {
          return Transform.rotate(
            angle: -0.05 + (_animation.value * 0.1),
            child: svgWidget,
          );
        } else if (widget.animationType == SvgAnimationType.bounce) {
          return Transform.scale(
            scale: _animation.value,
            child: svgWidget,
          );
        }
        return svgWidget;
      },
    );
  }
}
