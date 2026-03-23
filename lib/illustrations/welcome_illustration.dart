import 'package:flutter/material.dart';
import 'animated_svg_wrapper.dart';

class WelcomeIllustration extends StatelessWidget {
  final double size;
  const WelcomeIllustration({super.key, this.size = 200});

  @override
  Widget build(BuildContext context) {
    return AnimatedSvgWrapper(
      assetPath: 'assets/illustrations/onboarding_welcome.svg',
      size: size,
      animationType: SvgAnimationType.float,
    );
  }
}
