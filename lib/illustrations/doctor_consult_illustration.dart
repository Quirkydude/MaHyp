import 'dart:math' as math;
import 'package:flutter/material.dart';

class DoctorConsultIllustration extends StatefulWidget {
  final double size;
  const DoctorConsultIllustration({super.key, this.size = 200});

  @override
  State<DoctorConsultIllustration> createState() => _DoctorState();
}

class _DoctorState extends State<DoctorConsultIllustration> with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(seconds: 2))
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
          painter: _DoctorPainter(animValue: _anim.value),
        ),
      ),
    );
  }
}

class _DoctorPainter extends CustomPainter {
  final double animValue;
  _DoctorPainter({required this.animValue});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 300;
    canvas.scale(s, s);
    final p = Paint()..style = PaintingStyle.fill;

    // Background
    p.color = const Color(0xFFF0FDFF);
    canvas.drawCircle(const Offset(150, 150), 140, p);

    // Floating UI elements (animated)
    final floatY = 5 * math.sin(animValue * math.pi);
    
    // Tablet/Screen
    p.color = const Color(0xFFE5E7EB);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(60, 80, 180, 140), const Radius.circular(16)), p);
    p.color = Colors.white;
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(70, 90, 160, 120), const Radius.circular(8)), p);

    // Doctor profile inside screen
    p.color = const Color(0xFF00C9D6).withOpacity(0.1);
    canvas.drawCircle(const Offset(150, 140), 40, p);
    p.color = const Color(0xFF00A5B0); // torso
    canvas.drawArc(Rect.fromCenter(center: const Offset(150, 170), width: 60, height: 60), math.pi, math.pi, true, p);
    p.color = const Color(0xFFFFCCB3); // face
    canvas.drawCircle(const Offset(150, 130), 18, p);
    p.color = Colors.white; // stethoscope neck
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 3;
    canvas.drawArc(Rect.fromCenter(center: const Offset(150, 165), width: 26, height: 30), math.pi, math.pi, false, p);
    p.style = PaintingStyle.fill;
    
    // Video Call "ringing" pulse
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 3;
    p.color = const Color(0xFF10B981).withOpacity(1 - animValue);
    canvas.drawCircle(const Offset(150, 140), 50 + 20 * animValue, p);
    
    // Chat bubble 1
    canvas.save();
    canvas.translate(0, floatY);
    p.style = PaintingStyle.fill;
    p.color = Colors.white;
    final b1 = Path()..moveTo(60, 100)..lineTo(110, 100)..lineTo(110, 130)..lineTo(80, 130)..lineTo(60, 145)..lineTo(60, 130)..close();
    canvas.drawPath(b1, p);
    p.color = const Color(0xFF00C9D6);
    p.strokeWidth = 2;
    p.style = PaintingStyle.stroke;
    canvas.drawPath(b1, p);
    p.style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(70, 110, 30, 4), const Radius.circular(2)), p);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(70, 120, 20, 4), const Radius.circular(2)), p);
    canvas.restore();
    
    // Chat bubble 2
    canvas.save();
    canvas.translate(0, -floatY);
    p.style = PaintingStyle.fill;
    p.color = const Color(0xFF00C9D6);
    final b2 = Path()..moveTo(190, 140)..lineTo(240, 140)..lineTo(240, 170)..lineTo(240, 185)..lineTo(220, 170)..lineTo(190, 170)..close();
    canvas.drawPath(b2, p);
    p.color = Colors.white;
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(200, 150, 30, 4), const Radius.circular(2)), p);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(200, 160, 20, 4), const Radius.circular(2)), p);
    canvas.restore();
    
    // Mic/Camera toggles
    p.color = const Color(0xFFEF4444); // red hangup
    canvas.drawCircle(const Offset(150, 230), 16, p);
    p.color = Colors.white;
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 3;
    p.strokeCap = StrokeCap.round;
    final phone = Path()..moveTo(140, 235)..quadraticBezierTo(150, 220, 160, 235);
    canvas.drawPath(phone, p);
    p.style = PaintingStyle.fill;
  }

  @override
  bool shouldRepaint(_DoctorPainter old) => old.animValue != animValue;
}
