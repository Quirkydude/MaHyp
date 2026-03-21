import 'dart:math' as math;
import 'package:flutter/material.dart';

class WelcomeIllustration extends StatefulWidget {
  final double size;
  const WelcomeIllustration({super.key, this.size = 200});

  @override
  State<WelcomeIllustration> createState() => _WelcomeState();
}

class _WelcomeState extends State<WelcomeIllustration> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (_, __) => CustomPaint(
          painter: _WelcomePainter(pulse: _pulse.value),
        ),
      ),
    );
  }
}

class _WelcomePainter extends CustomPainter {
  final double pulse;
  _WelcomePainter({required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 300;
    canvas.scale(s, s);
    final p = Paint()..style = PaintingStyle.fill;

    // Outer glowing rings
    for (int i = 0; i < 3; i++) {
        final ringPulse = (pulse + i * 0.33) % 1.0;
        p.color = const Color(0xFF00C9D6).withOpacity(0.15 * (1 - ringPulse));
        canvas.drawCircle(const Offset(150, 150), 100 + 40 * ringPulse, p);
    }

    // Main circle background
    p.color = Colors.white;
    canvas.drawCircle(const Offset(150, 150), 100, p);
    
    p.style = PaintingStyle.stroke;
    p.color = const Color(0xFF00C9D6).withOpacity(0.2);
    p.strokeWidth = 2;
    canvas.drawCircle(const Offset(150, 150), 100, p);

    // Heart Shape
    p.style = PaintingStyle.fill;
    p.color = const Color(0xFF00C9D6);
    final heartPath = Path();
    heartPath.moveTo(150, 195);
    heartPath.cubicTo(150, 195, 115, 170, 105, 150);
    heartPath.cubicTo(95, 130, 95, 115, 105, 105);
    heartPath.cubicTo(115, 95, 130, 95, 140, 105);
    heartPath.cubicTo(145, 110, 147, 113, 150, 117);
    heartPath.cubicTo(153, 113, 155, 110, 160, 105);
    heartPath.cubicTo(170, 95, 185, 95, 195, 105);
    heartPath.cubicTo(205, 115, 205, 130, 195, 150);
    heartPath.cubicTo(185, 170, 150, 195, 150, 195);
    heartPath.close();
    canvas.drawPath(heartPath, p);

    // ECG line
    p.style = PaintingStyle.stroke;
    p.color = Colors.white;
    p.strokeWidth = 5;
    p.strokeCap = StrokeCap.round;
    p.strokeJoin = StrokeJoin.round;
    
    final ecg = Path()
      ..moveTo(100, 150)
      ..lineTo(125, 150)
      ..lineTo(135, 130)
      ..lineTo(145, 170)
      ..lineTo(155, 140)
      ..lineTo(165, 160)
      ..lineTo(175, 150)
      ..lineTo(200, 150);
      
    // Animate drawing by clipping or just fade
    canvas.drawPath(ecg, p);

    // Badge / Shield icon in corner
    p.style = PaintingStyle.fill;
    p.color = const Color(0xFF10B981);
    canvas.drawCircle(const Offset(210, 100), 25, p);
    p.color = Colors.white;
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 3;
    final check = Path()
      ..moveTo(202, 100)
      ..lineTo(208, 106)
      ..lineTo(218, 94);
    canvas.drawPath(check, p);
  }

  @override
  bool shouldRepaint(_WelcomePainter old) => old.pulse != pulse;
}
