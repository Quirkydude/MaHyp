import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

enum ActionCardType { nextMedication, recordBp }

/// Action card with elderly-friendly press feedback animation.
/// Provides subtle scale animation (0.97) on press for clear tactile feedback.
class ActionCard extends StatefulWidget {
  final ActionCardType type;
  final String? medicationName;
  final String? medicationTime;
  final VoidCallback? onTap;

  const ActionCard({
    super.key,
    required this.type,
    this.medicationName,
    this.medicationTime,
    this.onTap,
  });

  @override
  State<ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<ActionCard> {
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
            gradient: widget.type == ActionCardType.nextMedication
                ? AppColors.nextMedCardGradient
                : null,
            color: widget.type == ActionCardType.recordBp ? AppColors.white : null,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: widget.type == ActionCardType.nextMedication
                    ? AppColors.cardTeal.withOpacity(0.2)
                    : AppColors.cardShadow,
                blurRadius: 16,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
            ],
          ),
          child: widget.type == ActionCardType.nextMedication
              ? _buildMedicationContent()
              : _buildRecordBpContent(),
        ),
      ),
    );
  }

  Widget _buildMedicationContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.access_time_rounded,
                color: AppColors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Next Medication',
              style: TextStyle(
                color: AppColors.white.withOpacity(0.95),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const Spacer(),
        Text(
          widget.medicationName ?? 'Amlodipine',
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.medicationTime ?? 'Today At 6:00 PM',
          style: TextStyle(
            color: AppColors.white.withOpacity(0.85),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildRecordBpContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryTurquoise.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.bloodtype_rounded,
            color: AppColors.white,
            size: 26,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Record BP',
          style: TextStyle(
            color: AppColors.primaryTurquoiseDark,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

