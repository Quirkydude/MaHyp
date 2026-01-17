import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../features/medication/data/models/medication_model.dart'
    show MedicationStatus;

/// Medication card widget for displaying medication information
class MedicationCard extends StatelessWidget {
  final String name;
  final String dosage;
  final String frequency;
  final String nextDose;
  final MedicationStatus status;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsTaken;

  const MedicationCard({
    super.key,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.nextDose,
    required this.status,
    this.onTap,
    this.onMarkAsTaken,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacing12),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.inputBorder, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacing16),
          child: Row(
            children: [
              // Medication Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryTurquoise.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusSmall,
                  ),
                ),
                child: const Icon(
                  Icons.medication,
                  color: AppColors.primaryTurquoise,
                  size: AppDimensions.iconMedium,
                ),
              ),

              const SizedBox(width: AppDimensions.spacing16),

              // Medication Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      name,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacing4),

                    // Dosage and Frequency
                    Text(
                      '$dosage • $frequency',
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: AppDimensions.spacing4),

                    // Next Dose
                    Text(
                      'Next dose: $nextDose',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppDimensions.spacing12),

              // Status Badge or Action Button
              _buildStatusWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (status) {
      case MedicationStatus.upcoming:
        return AppColors.white;
      case MedicationStatus.taken:
        return AppColors.success.withOpacity(0.05);
      case MedicationStatus.ready:
        return AppColors.info.withOpacity(0.05);
      case MedicationStatus.skipped:
        return AppColors.textSecondary.withOpacity(0.05);
      case MedicationStatus.missed:
        return AppColors.error.withOpacity(0.05);
    }
  }

  Widget _buildStatusWidget() {
    switch (status) {
      case MedicationStatus.upcoming:
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing12,
            vertical: AppDimensions.spacing8,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryTurquoise,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          ),
          child: Text(
            'Upcoming',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        );

      case MedicationStatus.taken:
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing12,
            vertical: AppDimensions.spacing8,
          ),
          decoration: BoxDecoration(
            color: AppColors.success,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          ),
          child: Text(
            'Taken',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        );

      case MedicationStatus.missed:
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing12,
            vertical: AppDimensions.spacing8,
          ),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          ),
          child: Text(
            'Missed',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      case MedicationStatus.ready:
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing12,
            vertical: AppDimensions.spacing8,
          ),
          decoration: BoxDecoration(
            color: AppColors.info,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          ),
          child: Text(
            'Ready',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      case MedicationStatus.skipped:
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing12,
            vertical: AppDimensions.spacing8,
          ),
          decoration: BoxDecoration(
            color: AppColors.textSecondary,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          ),
          child: Text(
            'Skipped',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
    }
  }
}
