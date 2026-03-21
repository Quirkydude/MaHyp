import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Wraps the static SVG and overlays animated bell rings using Flutter.
class MedicationReminderIllustration extends StatefulWidget {
  final double size;
  const MedicationReminderIllustration({super.key, this.size = 200});

  @override
  State<MedicationReminderIllustration> createState() => _MedState();
}

class _MedState extends State<MedicationReminderIllustration>
    with TickerProviderStateMixin {
  late final AnimationController _bell1;
  late final AnimationController _bell2;

  @override
  void initState() {
    super.initState();
    _bell1 = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
    _bell2 = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..forward(from: 0.5)..addStatusListener((s) {
        if (s == AnimationStatus.completed) _bell2.repeat(reverse: true);
      });
  }

  @override
  void dispose() { _bell1.dispose(); _bell2.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_bell1, _bell2]),
        builder: (_, __) => CustomPaint(
          painter: _MedPainter(bell1: _bell1.value, bell2: _bell2.value),
        ),
      ),
    );
  }
}

class _MedPainter extends CustomPainter {
  final double bell1, bell2;
  _MedPainter({required this.bell1, required this.bell2});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 300;
    canvas.scale(s, s);
    final p = Paint()..style = PaintingStyle.fill;

    // Background
    p.color = const Color(0xFFFFF5F5);
    canvas.drawCircle(const Offset(150, 150), 140, p);

    // Pill bottle body
    p.color = Colors.white;
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(100, 110, 100, 120), const Radius.circular(8)), p);
    p.color = const Color(0xFF00C9D6);
    p.style = PaintingStyle.stroke; p.strokeWidth = 3;
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(100, 110, 100, 120), const Radius.circular(8)), p);
    p.style = PaintingStyle.fill;
    p.color = const Color(0xFF5CE1E6);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(100, 110, 100, 40), const Radius.circular(8)), p);

    // Label lines
    p.color = const Color(0xFFF0FDFF);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(110, 160, 80, 50), const Radius.circular(4)), p);
    p.color = const Color(0xFF00C9D6); p.style = PaintingStyle.stroke; p.strokeWidth = 2; p.strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(120, 175), const Offset(180, 175), p);
    canvas.drawLine(const Offset(120, 185), const Offset(170, 185), p);
    canvas.drawLine(const Offset(120, 195), const Offset(160, 195), p);

    // Cap
    p.style = PaintingStyle.fill;
    p.color = const Color(0xFF00A5B0);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(110, 85, 80, 30), const Radius.circular(6)), p);
    p.color = const Color(0xFF5CE1E6);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(115, 90, 70, 5), const Radius.circular(2)), p);

    // Pills
    canvas.save();
    canvas.translate(220, 170);
    canvas.rotate(30 * 3.14159 / 180);
    p.color = const Color(0xFFDC2626);
    canvas.drawOval(const Rect.fromCenter(center: Offset(0, 0), width: 36, height: 20), p);
    p.color = Colors.white; p.style = PaintingStyle.stroke; p.strokeWidth = 2;
    canvas.drawLine(const Offset(-12, 0), const Offset(12, 0), p);
    canvas.restore();

    canvas.save();
    canvas.translate(230, 210);
    canvas.rotate(-20 * 3.14159 / 180);
    p.style = PaintingStyle.fill;
    p.color = const Color(0xFF00C9D6);
    canvas.drawOval(const Rect.fromCenter(center: Offset(0, 0), width: 36, height: 20), p);
    p.color = Colors.white; p.style = PaintingStyle.stroke; p.strokeWidth = 2;
    canvas.drawLine(const Offset(-12, 0), const Offset(12, 0), p);
    canvas.restore();

    p.style = PaintingStyle.fill;
    p.color = const Color(0xFF10B981);
    canvas.drawCircle(const Offset(80, 190), 12, p);
    p.color = Colors.white;
    canvas.drawCircle(const Offset(80, 190), 6, p);

    // Alarm clock (at translate(50,95) => center 80,125)
    p.color = const Color(0xFFDC2626);
    canvas.drawCircle(const Offset(80, 125), 25, p);
    p.color = Colors.white;
    canvas.drawCircle(const Offset(80, 125), 20, p);
    p.color = const Color(0xFFDC2626); p.style = PaintingStyle.stroke; p.strokeWidth = 2.5; p.strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(80, 125), const Offset(80, 113), p); // minute hand
    canvas.drawLine(const Offset(80, 125), const Offset(88, 125), p); // hour hand
    p.style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(80, 125), 2, p);

    // Animated bell dots
    p.color = const Color(0xFFDC2626).withOpacity(0.3 + 0.7 * bell1);
    canvas.drawCircle(const Offset(72, 107), 3, p);
    p.color = const Color(0xFFDC2626).withOpacity(0.3 + 0.7 * bell2);
    canvas.drawCircle(const Offset(88, 107), 3, p);

    // Notification badge
    p.color = const Color(0xFFDC2626);
    canvas.drawCircle(const Offset(185, 95), 12, p);
    final tp = TextPainter(
      text: const TextSpan(text: '3', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(185 - tp.width / 2, 95 - tp.height / 2));
  }

  @override
  bool shouldRepaint(_MedPainter old) => old.bell1 != bell1 || old.bell2 != bell2;
}
