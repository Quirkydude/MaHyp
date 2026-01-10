import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../features/medication/data/models/medication_model.dart';

/// Medication details modal with actions
class MedicationDetailsModal extends StatelessWidget {
  final MedicationModel medication;
  final MedicationDose? specificDose; // If opened from notification
  final Function(String doseId)? onMarkAsTaken;
  final Function(String doseId)? onSkip;
  final Function(String doseId, int minutes)? onSnooze;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MedicationDetailsModal({
    super.key,
    required this.medication,
    this.specificDose,
    this.onMarkAsTaken,
    this.onSkip,
    this.onSnooze,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Use specific dose or get next dose
    final dose = specificDose ?? medication.nextDose;
    final status = dose?.currentStatus ?? MedicationStatus.upcoming;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.radiusXLarge),
          topRight: Radius.circular(AppDimensions.radiusXLarge),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacing24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textHint,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacing24),

            // Medication Icon and Name
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMedium,
                    ),
                  ),
                  child: const Icon(
                    Icons.medication,
                    color: AppColors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacing16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(medication.name, style: AppTextStyles.h3),
                      Text(
                        '${medication.dosage} • ${medication.frequencyString}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.spacing24),

            // Status Badge
            _buildStatusBadge(status),

            if (dose != null) ...[
              const SizedBox(height: AppDimensions.spacing16),

              // Scheduled Time
              _buildInfoRow(
                icon: Icons.access_time,
                label: 'Scheduled Time',
                value: DateFormat('h:mm a').format(dose.scheduledTime),
              ),

              if (dose.takenTime != null) ...[
                const SizedBox(height: AppDimensions.spacing12),
                _buildInfoRow(
                  icon: Icons.check_circle,
                  label: 'Taken At',
                  value: DateFormat('h:mm a').format(dose.takenTime!),
                ),
              ],
            ],

            if (medication.notes != null) ...[
              const SizedBox(height: AppDimensions.spacing16),
              _buildInfoRow(
                icon: Icons.note_outlined,
                label: 'Notes',
                value: medication.notes!,
              ),
            ],

            const SizedBox(height: AppDimensions.spacing32),

            // Action Buttons based on status
            if (dose != null) _buildActionButtons(context, dose, status),

            const SizedBox(height: AppDimensions.spacing16),

            // Secondary Actions
            Row(
              children: [
                if (onEdit != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryTurquoise,
                        side: const BorderSide(
                          color: AppColors.primaryTurquoise,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                if (onEdit != null && onDelete != null)
                  const SizedBox(width: AppDimensions.spacing12),
                if (onDelete != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, size: 20),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: AppDimensions.spacing16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(MedicationStatus status) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case MedicationStatus.ready:
        color = AppColors.primaryTurquoise;
        label = 'Ready to Take';
        icon = Icons.notifications_active;
        break;
      case MedicationStatus.taken:
        color = AppColors.success;
        label = 'Taken';
        icon = Icons.check_circle;
        break;
      case MedicationStatus.missed:
        color = AppColors.error;
        label = 'Missed';
        icon = Icons.error;
        break;
      case MedicationStatus.skipped:
        color = AppColors.warning;
        label = 'Skipped';
        icon = Icons.cancel;
        break;
      default:
        color = AppColors.textSecondary;
        label = 'Upcoming';
        icon = Icons.schedule;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing16,
        vertical: AppDimensions.spacing12,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppDimensions.spacing8),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 20),
        const SizedBox(width: AppDimensions.spacing12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    MedicationDose dose,
    MedicationStatus status,
  ) {
    // TAKEN - Only show undo option (within 5 min)
    if (status == MedicationStatus.taken) {
      final canUndo =
          dose.takenTime != null &&
          DateTime.now().difference(dose.takenTime!).inMinutes < 5;

      if (canUndo) {
        return CustomButton(
          text: 'Undo',
          onPressed: () {
            // TODO: Implement undo
            Navigator.pop(context);
          },
          isOutlined: true,
        );
      }
      return const SizedBox.shrink();
    }

    // READY - Can mark as taken, snooze, or skip
    if (status == MedicationStatus.ready && dose.canTake) {
      return Column(
        children: [
          // Primary Action: Mark as Taken
          CustomButton(
            text: '✓ Mark as Taken',
            onPressed: () {
              onMarkAsTaken?.call(dose.id);
              Navigator.pop(context);
              _showSuccessSnackBar(context);
            },
            icon: const Icon(Icons.check, color: AppColors.white),
          ),
          const SizedBox(height: AppDimensions.spacing12),

          // Secondary Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _showSnoozeOptions(context, dose.id);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryTurquoise,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Snooze'),
                ),
              ),
              const SizedBox(width: AppDimensions.spacing12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _showSkipConfirmation(context, dose.id);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.warning,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Skip'),
                ),
              ),
            ],
          ),
        ],
      );
    }

    // MISSED - Can mark as taken late or skip
    if (status == MedicationStatus.missed) {
      return Column(
        children: [
          CustomButton(
            text: 'Mark as Taken (Late)',
            onPressed: () {
              onMarkAsTaken?.call(dose.id);
              Navigator.pop(context);
              _showSuccessSnackBar(context);
            },
            backgroundColor: AppColors.warning,
          ),
          const SizedBox(height: AppDimensions.spacing12),
          CustomButton(
            text: 'Skip This Dose',
            onPressed: () {
              _showSkipConfirmation(context, dose.id);
            },
            isOutlined: true,
          ),
        ],
      );
    }

    // UPCOMING - Show countdown
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primaryTurquoise),
          const SizedBox(width: AppDimensions.spacing12),
          Expanded(
            child: Text(
              'You can take this medication 30 minutes before the scheduled time.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnoozeOptions(BuildContext context, String doseId) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppDimensions.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Snooze for', style: AppTextStyles.h3),
            const SizedBox(height: AppDimensions.spacing16),
            _buildSnoozeOption(context, doseId, 5, 'minutes'),
            _buildSnoozeOption(context, doseId, 15, 'minutes'),
            _buildSnoozeOption(context, doseId, 30, 'minutes'),
            _buildSnoozeOption(context, doseId, 60, 'hour'),
          ],
        ),
      ),
    );
  }

  Widget _buildSnoozeOption(
    BuildContext context,
    String doseId,
    int minutes,
    String label,
  ) {
    return ListTile(
      leading: const Icon(Icons.snooze, color: AppColors.primaryTurquoise),
      title: Text('$minutes $label'),
      onTap: () {
        onSnooze?.call(doseId, minutes);
        Navigator.pop(context); // Close snooze sheet
        Navigator.pop(context); // Close details modal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reminder snoozed for $minutes $label'),
            backgroundColor: AppColors.primaryTurquoise,
          ),
        );
      },
    );
  }

  void _showSkipConfirmation(BuildContext context, String doseId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip This Dose?'),
        content: const Text(
          'Are you sure you want to skip this dose? This will be recorded in your medication history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              onSkip?.call(doseId);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close details modal
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Dose skipped'),
                  backgroundColor: AppColors.warning,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Medication marked as taken'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
