import os
import re
import glob

wrapper_code = """import 'package:flutter/material.dart';
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
"""

with open('lib/illustrations/animated_svg_wrapper.dart', 'w', encoding='utf-8') as f:
    f.write(wrapper_code)

styles = {
    'heart_monitor_illustration.dart': ('HeartMonitorIllustration', 'heart_monitor.svg', 'pulse'),
    'empty_state_illustration.dart': ('EmptyStateIllustration', 'empty_state.svg', 'float'),
    'doctor_consult_illustration.dart': ('DoctorConsultIllustration', 'doctor_consult.svg', 'float'),
    'health_data_illustration.dart': ('HealthDataIllustration', 'health_data.svg', 'pulse'),
    'medication_reminder_illustration.dart': ('MedicationReminderIllustration', 'medication_reminder.svg', 'wiggle'),
    'blood_pressure_check_illustration.dart': ('BloodPressureCheckIllustration', 'blood_pressure_check.svg', 'pulse'),
    'welcome_illustration.dart': ('WelcomeIllustration', 'onboarding_welcome.svg', 'float')
}

for filename, (classname, svg, anim) in styles.items():
    code = f"""import 'package:flutter/material.dart';
import 'animated_svg_wrapper.dart';

class {classname} extends StatelessWidget {{
  final double size;
  const {classname}({{super.key, this.size = 200}});

  @override
  Widget build(BuildContext context) {{
    return AnimatedSvgWrapper(
      assetPath: 'assets/illustrations/{svg}',
      size: size,
      animationType: SvgAnimationType.{anim},
    );
  }}
}}
"""
    with open(f'lib/illustrations/{filename}', 'w', encoding='utf-8') as f:
        f.write(code)

patterns = {
    'heart_monitor.svg': 'HeartMonitorIllustration',
    'empty_state.svg': 'EmptyStateIllustration',
    'doctor_consult.svg': 'DoctorConsultIllustration',
    'health_data.svg': 'HealthDataIllustration',
    'medication_reminder.svg': 'MedicationReminderIllustration',
    'blood_pressure_check.svg': 'BloodPressureCheckIllustration',
    'onboarding_welcome.svg': 'WelcomeIllustration'
}

def replace_in_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    changed = False
    
    for svg, classname in patterns.items():
        # Match SvgPicture.asset('...', width: 200, height: 200)
        pattern1 = r"SvgPicture\.asset\(\s*'[^']*illustrations/" + svg + r"',\s*width:\s*([\d\.]+),\s*height:\s*([\d\.]+),?\s*\)"
        if re.search(pattern1, content):
            content = re.sub(pattern1, rf"{classname}(size: \1)", content)
            changed = True
            
        # Match SvgPicture.asset('...', height: 260)
        pattern2 = r"SvgPicture\.asset\(\s*'[^']*illustrations/" + svg + r"',\s*height:\s*([\d\.]+),?\s*\)"
        if re.search(pattern2, content):
            content = re.sub(pattern2, rf"{classname}(size: \1)", content)
            changed = True

    if changed:
        if 'Illustration(' in content and 'illustrations.dart' not in content:
            depth = filepath.count('/') - 1
            if depth >= 0:
                dots = '../' * depth
                import_stmt = f"\nimport '{dots}illustrations/illustrations.dart';"
                content = re.sub(r"(import 'package:flutter/material\.dart'[^;]*;)", r"\1" + import_stmt, content)
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)

for path in glob.glob('lib/features/**/*.dart', recursive=True):
    path = path.replace('\\', '/')
    replace_in_file(path)

print("Refactoring done.")
