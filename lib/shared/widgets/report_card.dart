import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';

/// Report card widget to show summary stats
class ReportCard extends StatelessWidget {
  final int adherencePercentage;
  final int dosesTaken;
  final int totalDoses;
  final int missedDoses;
  final VoidCallback onViewReport;

  const ReportCard({
    super.key,
    required this.adherencePercentage,
    required this.dosesTaken,
    required this.totalDoses,
    required this.missedDoses,
    required this.onViewReport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacing16),
      padding: const EdgeInsets.all(AppDimensions.spacing20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryTurquoiseLight.withValues(alpha: 0.15),
            AppColors.primaryTurquoise.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: AppColors.primaryTurquoise.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusSmall,
                  ),
                ),
                child: const Icon(
                  Icons.insert_chart,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppDimensions.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Progress',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'This week',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacing20),

          // Stats Row
          Row(
            children: [
              // Adherence
              Expanded(
                child: _buildStat(
                  label: 'Adherence',
                  value: '$adherencePercentage%',
                  color: _getAdherenceColor(adherencePercentage),
                  icon: Icons.favorite,
                ),
              ),
              Container(width: 1, height: 50, color: AppColors.inputBorder),
              // Doses Taken
              Expanded(
                child: _buildStat(
                  label: 'Taken',
                  value: '$dosesTaken/$totalDoses',
                  color: AppColors.success,
                  icon: Icons.check_circle,
                ),
              ),
              Container(width: 1, height: 50, color: AppColors.inputBorder),
              // Missed
              Expanded(
                child: _buildStat(
                  label: 'Missed',
                  value: '$missedDoses',
                  color: AppColors.error,
                  icon: Icons.cancel,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacing20),

          // View Report Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onViewReport,
              icon: const Icon(Icons.bar_chart, size: 20),
              label: const Text('View Full Report'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryTurquoise,
                side: const BorderSide(
                  color: AppColors.primaryTurquoise,
                  width: 1.5,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.spacing12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusSmall,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: AppDimensions.spacing4),
        Text(
          value,
          style: AppTextStyles.h4.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Color _getAdherenceColor(int percentage) {
    if (percentage >= 80) return AppColors.success;
    if (percentage >= 60) return AppColors.warning;
    return AppColors.error;
  }
}
