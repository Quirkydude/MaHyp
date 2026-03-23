import 'package:flutter/material.dart';
import 'animated_svg_wrapper.dart';

class HeartMonitorIllustration extends StatelessWidget {
  final double size;
  const HeartMonitorIllustration({super.key, this.size = 200});

  @override
  Widget build(BuildContext context) {
    return AnimatedSvgWrapper(
      assetPath: 'assets/illustrations/heart_monitor.svg',
      size: size,
      animationType: SvgAnimationType.pulse,
    );
  }
}
