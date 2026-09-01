import 'dart:math' as math;
import 'package:flutter/material.dart';

class SuccessIllustration extends StatefulWidget {
  final double size;
  const SuccessIllustration({super.key, this.size = 200});

  @override
  State<SuccessIllustration> createState() => _SuccessState();
}

class _SuccessState extends State<SuccessIllustration>
    with TickerProviderStateMixin {
  late final AnimationController _ring; // pulse ring r+opacity
  late final AnimationController _p1; // particle cy 2s
  late final AnimationController _p2; // particle y  2.5s
  late final AnimationController _p3; // particle cy 2.2s
  late final AnimationController _p4; // particle y  2.8s
  late final AnimationController _p5; // particle cx 2.3s
  late final AnimationController _p6; // particle cx 2.6s
  late final AnimationController _star1; // star opacity 1.5s
  late final AnimationController _star2; // star opacity 1.8s

  AnimationController _ctrl(double secs) => AnimationController(
    vsync: this,
    duration: Duration(milliseconds: (secs * 1000).toInt()),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    _ring = _ctrl(2.0);
    _p1 = _ctrl(2.0);
    _p2 = _ctrl(2.5);
    _p3 = _ctrl(2.2);
    _p4 = _ctrl(2.8);
    _p5 = _ctrl(2.3);
    _p6 = _ctrl(2.6);
    _star1 = _ctrl(1.5);
    _star2 = _ctrl(1.8);
  }

  @override
  void dispose() {
    for (final c in [_ring, _p1, _p2, _p3, _p4, _p5, _p6, _star1, _star2]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _ring,
          _p1,
          _p2,
          _p3,
          _p4,
          _p5,
          _p6,
          _star1,
          _star2,
        ]),
        builder: (_, __) => CustomPaint(
          painter: _SuccessPainter(
            ringT: _ring.value,
            p1T: _p1.value,
            p2T: _p2.value,
            p3T: _p3.value,
            p4T: _p4.value,
            p5T: _p5.value,
            p6T: _p6.value,
            star1T: _star1.value,
            star2T: _star2.value,
          ),
        ),
      ),
    );
  }
}

class _SuccessPainter extends CustomPainter {
  final double ringT, p1T, p2T, p3T, p4T, p5T, p6T, star1T, star2T;
  _SuccessPainter({
    required this.ringT,
    required this.p1T,
    required this.p2T,
    required this.p3T,
    required this.p4T,
    required this.p5T,
    required this.p6T,
    required this.star1T,
    required this.star2T,
  });

  double lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 300;
    canvas.scale(s, s);
    final p = Paint()..style = PaintingStyle.fill;

    // Background
    p.color = const Color(0xFFF0FDF4);
    canvas.drawCircle(const Offset(150, 150), 140, p);

    // Success circle
    p.color = const Color(0xFF10B981);
    canvas.drawCircle(const Offset(150, 150), 80, p);

    // Checkmark
    p.style = PaintingStyle.stroke;
    p.color = Colors.white;
    p.strokeWidth = 12;
    p.strokeCap = StrokeCap.round;
    p.strokeJoin = StrokeJoin.round;
    final check = Path()
      ..moveTo(115, 150)
      ..lineTo(140, 175)
      ..lineTo(190, 125);
    canvas.drawPath(check, p);
    p.style = PaintingStyle.fill;

    // Animated ring — r: 80→100, opacity: 0.3→0
    final ringR = lerp(80, 100, ringT);
    final ringOpacity = lerp(0.3, 0, ringT);
    p.style = PaintingStyle.stroke;
    p.color = const Color(0xFF10B981).withValues(alpha: ringOpacity);
    p.strokeWidth = 3;
    canvas.drawCircle(const Offset(150, 150), ringR, p);
    p.style = PaintingStyle.fill;

    // Confetti particles
    // P1: circle cyan cy 70→90
    p.color = const Color(0xFF00C9D6).withValues(alpha: 0.8);
    canvas.drawCircle(Offset(90, lerp(70, 90, p1T)), 6, p);

    // P2: rect red y 80→100 (rotated 45deg around 204,84)
    p.color = const Color(0xFFDC2626).withValues(alpha: 0.8);
    canvas.save();
    canvas.translate(204, lerp(80, 100, p2T) + 4); // pivot at center of rect
    canvas.rotate(45 * math.pi / 180);
    canvas.drawRect(
      Rect.fromCenter(center: const Offset(0, 0), width: 8, height: 8),
      p,
    );
    canvas.restore();

    // P3: circle teal cy 200→220
    p.color = const Color(0xFF5CE1E6).withValues(alpha: 0.8);
    canvas.drawCircle(Offset(210, lerp(200, 220, p3T)), 5, p);

    // P4: rect amber y 210→230
    p.color = const Color(0xFFF59E0B).withValues(alpha: 0.8);
    canvas.save();
    canvas.translate(80, lerp(210, 230, p4T) + 5);
    canvas.rotate(20 * math.pi / 180);
    canvas.drawRect(
      Rect.fromCenter(center: const Offset(0, 0), width: 10, height: 10),
      p,
    );
    canvas.restore();

    // P5: circle purple cx 200→220
    p.color = const Color(0xFF8B5CF6).withValues(alpha: 0.8);
    canvas.drawCircle(Offset(lerp(200, 220, p5T), 140), 4, p);

    // P6: circle pink cx 100→80
    p.color = const Color(0xFFEC4899).withValues(alpha: 0.8);
    canvas.drawCircle(Offset(lerp(100, 80, p6T), 140), 4, p);

    // Stars
    void drawStar(Canvas c, Offset center, double opacity) {
      final sp = Paint()
        ..color = const Color(0xFFFBBF24).withValues(alpha: opacity);
      // 5-point star via polygon points
      final pts = <Offset>[
        Offset(center.dx, center.dy - 8),
        Offset(center.dx + 2, center.dy - 2),
        Offset(center.dx + 8, center.dy - 2),
        Offset(center.dx + 3, center.dy + 2),
        Offset(center.dx + 5, center.dy + 8),
        Offset(center.dx, center.dy + 4),
        Offset(center.dx - 5, center.dy + 8),
        Offset(center.dx - 3, center.dy + 2),
        Offset(center.dx - 8, center.dy - 2),
        Offset(center.dx - 2, center.dy - 2),
      ];
      final starPath = Path()..moveTo(pts[0].dx, pts[0].dy);
      for (final pt in pts.skip(1)) starPath.lineTo(pt.dx, pt.dy);
      starPath.close();
      c.drawPath(starPath, sp);
    }

    drawStar(canvas, const Offset(230, 60), lerp(0.3, 0.7, star1T));
    drawStar(canvas, const Offset(70, 230), lerp(0.3, 0.7, star2T));
  }

  @override
  bool shouldRepaint(_SuccessPainter old) => true;
}
