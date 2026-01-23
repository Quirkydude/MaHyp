import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

enum StatCardType { bp, medication }

class StatCard extends StatefulWidget {
  final StatCardType type;
  final String title;
  final String value;
  final String subtitle;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.type,
    required this.title,
    required this.value,
    required this.subtitle,
    this.onTap,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null
          ? (_) => setState(() => _isPressed = true)
          : null,
      onTapUp: widget.onTap != null
          ? (_) {
              setState(() => _isPressed = false);
              widget.onTap?.call();
            }
          : null,
      onTapCancel: widget.onTap != null
          ? () => setState(() => _isPressed = false)
          : null,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: Container(
          height: 130,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: widget.type == StatCardType.bp
                ? AppColors.bpCardGradient
                : AppColors.medicationCardGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: (widget.type == StatCardType.bp
                        ? AppColors.cardTeal
                        : AppColors.cardBlue)
                    .withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildIcon(),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.95),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                widget.value,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (widget.type == StatCardType.bp)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                    ),
                  Text(
                    widget.subtitle,
                    style: TextStyle(
                      color: AppColors.white.withOpacity(0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        widget.type == StatCardType.bp ? Icons.favorite_rounded : Icons.pie_chart_rounded,
        color: AppColors.white,
        size: 20,
      ),
    );
  }
}

