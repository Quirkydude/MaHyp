import 'dart:math' as math;
import 'package:flutter/material.dart';

class HeartMonitorIllustration extends StatefulWidget {
  final double size;
  const HeartMonitorIllustration({super.key, this.size = 200});

  @override
  State<HeartMonitorIllustration> createState() => _HeartMonitorIllustrationState();
}

class _HeartMonitorIllustrationState extends State<HeartMonitorIllustration>
    with TickerProviderStateMixin {
  late final AnimationController _dot1;
  late final AnimationController _dot2;
  late final AnimationController _dot3;

  @override
  void initState() {
    super.initState();
    _dot1 = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
    _dot2 = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
      ..forward(from: 0.3 / 1.5); // begin="0.3s" offset
    _dot2.addStatusListener((s) { if (s == AnimationStatus.completed) _dot2.repeat(reverse: true); });
    _dot3 = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
      ..forward(from: 0.6 / 1.5); // begin="0.6s" offset
    _dot3.addStatusListener((s) { if (s == AnimationStatus.completed) _dot3.repeat(reverse: true); });
  }

  @override
  void dispose() {
    _dot1.dispose();
    _dot2.dispose();
    _dot3.dispose();
    super.dispose();
  }

  double _opacity(AnimationController c) => 0.3 + 0.7 * c.value; // 1 <-> 0.3

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_dot1, _dot2, _dot3]),
        builder: (_, __) => CustomPaint(
          painter: _HeartMonitorPainter(
            dot1Opacity: _opacity(_dot1),
            dot2Opacity: _opacity(_dot2),
            dot3Opacity: _opacity(_dot3),
          ),
        ),
      ),
    );
  }
}

class _HeartMonitorPainter extends CustomPainter {
  final double dot1Opacity, dot2Opacity, dot3Opacity;
  _HeartMonitorPainter({required this.dot1Opacity, required this.dot2Opacity, required this.dot3Opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 300; // scale factor (viewBox 300x300)
    canvas.scale(s, s);

    final p = Paint()..style = PaintingStyle.fill;

    // Background circle
    p.color = const Color(0xFFF0FDFF);
    canvas.drawCircle(const Offset(150, 150), 140, p);

    // Monitor screen
    p.color = Colors.white;
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(60, 80, 180, 120), const Radius.circular(12)), p);
    p.color = const Color(0xFF00C9D6);
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 3;
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(60, 80, 180, 120), const Radius.circular(12)), p);

    // Heartbeat line
    p.style = PaintingStyle.stroke;
    p.color = const Color(0xFFDC2626);
    p.strokeWidth = 4;
    p.strokeCap = StrokeCap.round;
    p.strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(75, 140)..lineTo(100, 140)..lineTo(110, 110)
      ..lineTo(125, 170)..lineTo(140, 130)..lineTo(155, 150)
      ..lineTo(165, 140)..lineTo(225, 140);
    canvas.drawPath(path, p);

    // Heart icon
    p.style = PaintingStyle.fill;
    p.color = const Color(0xFF00C9D6);
    canvas.save();
    canvas.translate(125, 210);
    final heart = Path()
      ..moveTo(25, 45)..cubicTo(25, 45, 10, 32.5, 5, 22.5)
      ..cubicTo(0, 12.5, 0, 5, 5, 0)..cubicTo(10, -5, 17.5, -5, 22.5, 0)
      ..cubicTo(24, 1.5, 24.5, 2.5, 25, 4)..cubicTo(25.5, 2.5, 26, 1.5, 27.5, 0)
      ..cubicTo(32.5, -5, 40, -5, 45, 0)..cubicTo(50, 5, 50, 12.5, 45, 22.5)
      ..cubicTo(40, 32.5, 25, 45, 25, 45)..close();
    canvas.drawPath(heart, p);
    canvas.restore();

    // Animated pulse dots
    p.color = const Color(0xFFDC2626).withOpacity(dot1Opacity);
    canvas.drawCircle(const Offset(90, 140), 4, p);
    p.color = const Color(0xFFDC2626).withOpacity(dot2Opacity);
    canvas.drawCircle(const Offset(140, 130), 4, p);
    p.color = const Color(0xFFDC2626).withOpacity(dot3Opacity);
    canvas.drawCircle(const Offset(190, 140), 4, p);

    // Monitor base
    p.color = const Color(0xFFE5E7EB);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(120, 200, 60, 8), const Radius.circular(4)), p);
    p.color = const Color(0xFF9CA3AF);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(135, 208, 30, 15), const Radius.circular(3)), p);
  }

  @override
  bool shouldRepaint(_HeartMonitorPainter old) =>
      old.dot1Opacity != dot1Opacity || old.dot2Opacity != dot2Opacity || old.dot3Opacity != dot3Opacity;
}
