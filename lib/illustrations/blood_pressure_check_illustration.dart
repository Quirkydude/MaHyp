import 'package:flutter/material.dart';
import 'animated_svg_wrapper.dart';

class BloodPressureCheckIllustration extends StatelessWidget {
  final double size;
  const BloodPressureCheckIllustration({super.key, this.size = 200});

  @override
  Widget build(BuildContext context) {
    return AnimatedSvgWrapper(
      assetPath: 'assets/illustrations/blood_pressure_check.svg',
      size: size,
      animationType: SvgAnimationType.pulse,
    );
  }
}
