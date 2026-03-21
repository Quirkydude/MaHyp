import 'dart:math' as math;
import 'package:flutter/material.dart';

class EmptyStateIllustration extends StatefulWidget {
  final double size;
  const EmptyStateIllustration({super.key, this.size = 200});

  @override
  State<EmptyStateIllustration> createState() => _EmptyState();
}

class _EmptyState extends State<EmptyStateIllustration> with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
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
          painter: _EmptyPainter(animValue: _anim.value),
        ),
      ),
    );
  }
}

class _EmptyPainter extends CustomPainter {
  final double animValue;
  _EmptyPainter({required this.animValue});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 300;
    canvas.scale(s, s);
    final p = Paint()..style = PaintingStyle.fill;

    // Background
    p.color = const Color(0xFFF9FAFB);
    canvas.drawCircle(const Offset(150, 150), 140, p);

    final floatY = 8 * math.sin(animValue * math.pi);

    // Main Box
    canvas.save();
    canvas.translate(0, floatY);
    
    p.color = Colors.white;
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(80, 100, 140, 120), const Radius.circular(16)), p);
    p.color = const Color(0xFFD1D5DB).withOpacity(0.5);
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 3;
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(80, 100, 140, 120), const Radius.circular(16)), p);

    // Open box flaps
    p.strokeCap = StrokeCap.round;
    p.strokeJoin = StrokeJoin.round;
    final flap1 = Path()..moveTo(80, 100)..lineTo(60, 70)..lineTo(130, 80)..lineTo(150, 100);
    canvas.drawPath(flap1, p);
    
    final flap2 = Path()..moveTo(220, 100)..lineTo(240, 70)..lineTo(170, 80)..lineTo(150, 100);
    canvas.drawPath(flap2, p);
    
    // Magnifying glass inside box
    p.color = const Color(0xFF00C9D6);
    canvas.drawCircle(const Offset(130, 140), 20, p);
    p.color = Colors.white;
    p.style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(130, 140), 14, p);
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 6;
    p.color = const Color(0xFF00C9D6);
    canvas.drawLine(const Offset(145, 155), const Offset(165, 175), p);

    // Small sparkles/accents
    p.style = PaintingStyle.fill;
    p.color = const Color(0xFFFCD34D); // soft yellow
    canvas.drawCircle(const Offset(100, 120), 4, p);
    p.color = const Color(0xFF9CA3AF);
    canvas.drawCircle(const Offset(180, 130), 3, p);
    
    // Zzz / Empty indicator dots
    p.color = const Color(0xFF9CA3AF).withOpacity(0.5 + 0.5 * animValue);
    canvas.drawCircle(const Offset(130, 60), 4, p);
    canvas.drawCircle(const Offset(145, 45), 6, p);
    canvas.drawCircle(const Offset(165, 30), 8, p);
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(_EmptyPainter old) => old.animValue != animValue;
}
