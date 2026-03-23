import 'package:flutter/material.dart';
import 'animated_svg_wrapper.dart';

class HealthDataIllustration extends StatelessWidget {
  final double size;
  const HealthDataIllustration({super.key, this.size = 200});

  @override
  Widget build(BuildContext context) {
    return AnimatedSvgWrapper(
      assetPath: 'assets/illustrations/health_data.svg',
      size: size,
      animationType: SvgAnimationType.pulse,
    );
  }
}
