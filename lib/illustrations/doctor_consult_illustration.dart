import 'package:flutter/material.dart';
import 'animated_svg_wrapper.dart';

class DoctorConsultIllustration extends StatelessWidget {
  final double size;
  const DoctorConsultIllustration({super.key, this.size = 200});

  @override
  Widget build(BuildContext context) {
    return AnimatedSvgWrapper(
      assetPath: 'assets/illustrations/doctor_consult.svg',
      size: size,
      animationType: SvgAnimationType.float,
    );
  }
}
