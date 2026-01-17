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
    return Expanded(
      child: GestureDetector(
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: widget.type == ActionCardType.nextMedication
                  ? AppColors.nextMedCardGradient
                  : null,
              color: widget.type == ActionCardType.recordBp ? AppColors.white : null,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: widget.type == ActionCardType.nextMedication
                ? _buildMedicationContent()
                : _buildRecordBpContent(),
          ),
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
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.access_time,
                color: AppColors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Next Medication',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
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
            color: AppColors.white.withOpacity(0.9),
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
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.bloodtype,
            color: AppColors.white,
            size: 28,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Record Blood',
          style: TextStyle(
            color: AppColors.primaryTurquoise,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          'Pressure',
          style: TextStyle(
            color: AppColors.primaryTurquoise,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
