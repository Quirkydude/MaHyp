import 'package:flutter/material.dart';
import 'animated_svg_wrapper.dart';

class MedicationReminderIllustration extends StatelessWidget {
  final double size;
  const MedicationReminderIllustration({super.key, this.size = 200});

  @override
  Widget build(BuildContext context) {
    return AnimatedSvgWrapper(
      assetPath: 'assets/illustrations/medication_reminder.svg',
      size: size,
      animationType: SvgAnimationType.wiggle,
    );
  }
}
