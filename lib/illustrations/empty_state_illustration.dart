import 'package:flutter/material.dart';
import 'animated_svg_wrapper.dart';

class EmptyStateIllustration extends StatelessWidget {
  final double size;
  const EmptyStateIllustration({super.key, this.size = 200});

  @override
  Widget build(BuildContext context) {
    return AnimatedSvgWrapper(
      assetPath: 'assets/illustrations/empty_state.svg',
      size: size,
      animationType: SvgAnimationType.float,
    );
  }
}
