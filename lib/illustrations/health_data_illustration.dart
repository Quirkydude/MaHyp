import 'dart:math' as math;
import 'package:flutter/material.dart';

class HealthDataIllustration extends StatefulWidget {
  final double size;
  const HealthDataIllustration({super.key, this.size = 200});

  @override
  State<HealthDataIllustration> createState() => _HealthState();
}

class _HealthState extends State<HealthDataIllustration> with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
  }

  @override
  void dispose() { _anim.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => CustomPaint(
          painter: _HealthPainter(animValue: _anim.value),
        ),
      ),
    );
  }
}

class _HealthPainter extends CustomPainter {
  final double animValue;
  _HealthPainter({required this.animValue});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 300;
    canvas.scale(s, s);
    final p = Paint()..style = PaintingStyle.fill;

    // Background
    p.color = const Color(0xFFF5FFFF);
    canvas.drawCircle(const Offset(150, 150), 140, p);

    // Main Chart Board
    p.color = Colors.white;
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(70, 70, 160, 160), const Radius.circular(16)), p);
    p.color = const Color(0xFF00C9D6).withOpacity(0.2);
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 2;
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(70, 70, 160, 160), const Radius.circular(16)), p);
    
    // Grid lines
    p.color = const Color(0xFFF3F4F6);
    p.strokeWidth = 2;
    for (int i=1; i<=4; i++) {
        canvas.drawLine(Offset(80, 70.0 + i * 30), Offset(220, 70.0 + i * 30), p);
    }

    // Bar charts (animated heights)
    p.style = PaintingStyle.fill;
    final bars = [40, 80, 60, 100, 70];
    for (int i = 0; i < bars.length; i++) {
      final targetH = bars[i].toDouble();
      // Animate them growing up and down gently
      final float = math.sin(animValue * math.pi * 2 + i) * 10;
      final h = targetH + float;
      
      p.color = (i == 3) ? const Color(0xFF10B981) : const Color(0xFF00C9D6).withOpacity(0.6);
      canvas.drawRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(85.0 + i * 28, 210 - h, 18, h), 
          const Radius.circular(4)), p);
    }

    // Trend line
    p.style = PaintingStyle.stroke;
    p.color = const Color(0xFFDC2626);
    p.strokeWidth = 4;
    p.strokeCap = StrokeCap.round;
    p.strokeJoin = StrokeJoin.round;
    
    final trend = Path();
    for (int i = 0; i < bars.length; i++) {
      final float = math.sin(animValue * math.pi * 2 + i) * 10;
      final h = bars[i] + float + 20; // 20 units above bar
      final x = 94.0 + i * 28;
      final y = 210 - h;
      if (i == 0) trend.moveTo(x, y);
      else trend.lineTo(x, y);
    }
    canvas.drawPath(trend, p);

    // Floating dot on trend
    p.style = PaintingStyle.fill;
    final dotIdx = ((animValue * bars.length) % bars.length).floor();
    final floatDot = math.sin(animValue * math.pi * 2 + dotIdx) * 10;
    canvas.drawCircle(Offset(94.0 + dotIdx * 28, 210 - (bars[dotIdx] + floatDot + 20)), 6, p);
    p.color = Colors.white;
    canvas.drawCircle(Offset(94.0 + dotIdx * 28, 210 - (bars[dotIdx] + floatDot + 20)), 3, p);
  }

  @override
  bool shouldRepaint(_HealthPainter old) => old.animValue != animValue;
}
