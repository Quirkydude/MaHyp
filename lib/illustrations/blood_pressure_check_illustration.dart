import 'dart:math' as math;
import 'package:flutter/material.dart';

class BloodPressureCheckIllustration extends StatefulWidget {
  final double size;
  const BloodPressureCheckIllustration({super.key, this.size = 200});

  @override
  State<BloodPressureCheckIllustration> createState() => _BPState();
}

class _BPState extends State<BloodPressureCheckIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _needle;

  @override
  void initState() {
    super.initState();
    _needle = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
  }

  @override
  void dispose() { _needle.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _needle,
        builder: (_, __) => CustomPaint(
          painter: _BPPainter(needleT: _needle.value),
        ),
      ),
    );
  }
}

class _BPPainter extends CustomPainter {
  final double needleT; // 0..1 => -45deg..+45deg
  _BPPainter({required this.needleT});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 300;
    canvas.scale(s, s);
    final p = Paint()..style = PaintingStyle.fill;

    // Background circle
    p.color = const Color(0xFFFFF5F5);
    canvas.drawCircle(const Offset(150, 150), 140, p);

    // Arm
    p.color = const Color(0xFFFFE5CC);
    canvas.drawOval(Rect.fromCenter(center: const Offset(150, 180), width: 90, height: 140), p);

    // BP Cuff
    p.color = const Color(0xFF00C9D6);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(105, 140, 90, 50), const Radius.circular(8)), p);
    p.color = const Color(0xFF5CE1E6);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(105, 145, 90, 8), const Radius.circular(2)), p);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(105, 158, 90, 8), const Radius.circular(2)), p);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(105, 171, 90, 8), const Radius.circular(2)), p);
    p.color = const Color(0xFF00A5B0);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(180, 150, 15, 30), const Radius.circular(3)), p);

    // Tube
    p.style = PaintingStyle.stroke;
    p.color = const Color(0xFF6B7280);
    p.strokeWidth = 4;
    p.strokeCap = StrokeCap.round;
    final tube = Path()..moveTo(105, 165)..quadraticBezierTo(60, 165, 50, 140);
    canvas.drawPath(tube, p);

    // Gauge body (at translate(20,80) => center 50,110)
    p.style = PaintingStyle.fill;
    p.color = Colors.white;
    canvas.drawCircle(const Offset(50, 110), 28, p);
    p.color = const Color(0xFF00C9D6);
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 3;
    canvas.drawCircle(const Offset(50, 110), 28, p);
    p.style = PaintingStyle.fill;
    p.color = const Color(0xFFF0FDFF);
    canvas.drawCircle(const Offset(50, 110), 20, p);

    // Animated gauge needle — rotates from -45 to +45 degrees around center (50,110)
    final angleRad = (-45 + needleT * 90) * math.pi / 180;
    // Needle tip: 15 units up from center in rotated frame
    final tipX = 50 + 15 * math.sin(angleRad);
    final tipY = 110 - 15 * math.cos(angleRad);
    p.style = PaintingStyle.stroke;
    p.color = const Color(0xFFDC2626);
    p.strokeWidth = 2;
    p.strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(50, 110), Offset(tipX, tipY), p);
    p.style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(50, 110), 3, p);

    // Bulb pump
    p.color = const Color(0xFF9CA3AF);
    canvas.drawOval(Rect.fromCenter(center: const Offset(50, 200), width: 44, height: 56), p);
    p.color = const Color(0xFFD1D5DB);
    canvas.drawOval(Rect.fromCenter(center: const Offset(50, 198), width: 36, height: 44), p);

    // Reading display (at translate(160,55))
    p.color = Colors.white;
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(160, 55, 80, 45), const Radius.circular(8)), p);
    p.color = const Color(0xFF00C9D6);
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 2;
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(160, 55, 80, 45), const Radius.circular(8)), p);
    final tp = TextPainter(
      text: const TextSpan(text: '120/80', style: TextStyle(color: Color(0xFFDC2626), fontSize: 20, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(160 + 40 - tp.width / 2, 55 + 22.5 - tp.height / 2));

    // Checkmark circle
    p.style = PaintingStyle.fill;
    p.color = const Color(0xFF10B981);
    canvas.drawCircle(const Offset(230, 240), 18, p);
    p.style = PaintingStyle.stroke;
    p.color = Colors.white;
    p.strokeWidth = 3;
    p.strokeCap = StrokeCap.round;
    p.strokeJoin = StrokeJoin.round;
    final check = Path()..moveTo(222, 240)..lineTo(228, 246)..lineTo(238, 234);
    canvas.drawPath(check, p);
  }

  @override
  bool shouldRepaint(_BPPainter old) => old.needleT != needleT;
}
