import 'package:flutter/material.dart';
import '../../../../illustrations/illustrations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';

import '../../data/models/bp_reading_model.dart';

/// BP Analysis Page - Shows detailed analysis of reading
class BPAnalysisPage extends StatefulWidget {
  final BPReadingModel reading;

  const BPAnalysisPage({super.key, required this.reading});

  @override
  State<BPAnalysisPage> createState() => _BPAnalysisPageState();
}

class _BPAnalysisPageState extends State<BPAnalysisPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isHigh =
        widget.reading.category == BPCategory.highStage2 ||
        widget.reading.category == BPCategory.highStage1;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Blood Pressure Analysis'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.screenPaddingHorizontal),
        child: Column(
          children: [
            const SizedBox(height: AppDimensions.spacing24),

            // Health Data SVG
            Center(
              child: HealthDataIllustration(size: 200),
            ),
            const SizedBox(height: AppDimensions.spacing24),

            // Alert Card
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacing24),
              decoration: BoxDecoration(
                color: _getCategoryColor(
                  widget.reading.category,
                ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                border: Border.all(
                  color: _getCategoryColor(widget.reading.category),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  // Animated Icon
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(widget.reading.category),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isHigh ? Icons.warning : Icons.info,
                        size: 40,
                        color: AppColors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacing20),

                  Text(
                    isHigh
                        ? 'Your BP is Elevated'
                        : widget.reading.categoryName,
                    style: AppTextStyles.h2.copyWith(
                      color: _getCategoryColor(widget.reading.category),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacing16),

                  // Reading Display
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing32,
                      vertical: AppDimensions.spacing16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMedium,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          widget.reading.formattedReading,
                          style: AppTextStyles.h1.copyWith(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: _getCategoryColor(widget.reading.category),
                          ),
                        ),
                        Text(
                          _formatRecordedDate(widget.reading.recordedAt),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.spacing32),

            // What does this mean?
            Align(
              alignment: Alignment.centerLeft,
              child: Text('What does this mean?', style: AppTextStyles.h3),
            ),
            const SizedBox(height: AppDimensions.spacing12),

            Container(
              padding: const EdgeInsets.all(AppDimensions.spacing16),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.primaryTurquoise,
                    size: 24,
                  ),
                  const SizedBox(width: AppDimensions.spacing12),
                  Expanded(
                    child: Text(
                      _getExplanation(widget.reading.category),
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.spacing24),

            // Recommended Actions
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Recommended Actions', style: AppTextStyles.h3),
            ),
            const SizedBox(height: AppDimensions.spacing12),

            Container(
              padding: const EdgeInsets.all(AppDimensions.spacing16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: Column(
                children: [
                  _buildActionItem(
                    icon: Icons.medication,
                    title: 'Take your prescribed medication',
                    subtitle: 'Follow your doctor\'s instructions regularly',
                  ),
                  const Divider(height: AppDimensions.spacing24),
                  _buildActionItem(
                    icon: Icons.monitor_heart,
                    title: 'Monitor your readings regularly',
                    subtitle: 'Track daily and report irregular readings',
                  ),
                  const Divider(height: AppDimensions.spacing24),
                  _buildActionItem(
                    icon: Icons.phone,
                    title: 'Consult your doctor if readings remain high',
                    subtitle: 'Schedule a follow-up appointment',
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.spacing40),

            // Action Buttons
            if (isHigh) ...[
              CustomButton(
                text: 'Contact Doctor',
                onPressed: _contactDoctor,
                icon: const Icon(Icons.phone, color: AppColors.white),
                backgroundColor: AppColors.primaryTurquoise,
              ),
              const SizedBox(height: AppDimensions.spacing12),
            ],

            CustomButton(
              text: 'View Medication List',
              onPressed: () => context.push(AppRouter.medicationList),
              isOutlined: true,
            ),

            const SizedBox(height: AppDimensions.spacing40),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryTurquoise.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          ),
          child: Icon(icon, color: AppColors.primaryTurquoise, size: 20),
        ),
        const SizedBox(width: AppDimensions.spacing12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppDimensions.spacing4),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getExplanation(BPCategory category) {
    switch (category) {
      case BPCategory.normal:
        return 'Your blood pressure is within the normal range. Continue with your healthy lifestyle and medication routine.';
      case BPCategory.elevated:
        return 'Elevated blood pressure means your reading is higher than normal but not yet at the high blood pressure stage. Following medical advice can help prevent progression.';
      case BPCategory.highStage1:
        return 'Stage 1 hypertension indicates your blood pressure is consistently high. It\'s important to take your medication regularly and monitor your readings daily.';
      case BPCategory.highStage2:
        return 'Stage 2 hypertension requires immediate attention. Please ensure you\'re taking your prescribed medication and consult your doctor if readings remain high.';
      case BPCategory.crisis:
        return 'This is a hypertensive crisis requiring emergency medical attention. Seek immediate care.';
    }
  }

  String _formatRecordedDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(dt.year, dt.month, dt.day);
    final time = DateFormat('h:mm a').format(dt);
    if (date == today) return 'Recorded today at $time';
    if (date == yesterday) return 'Recorded yesterday at $time';
    return 'Recorded on ${DateFormat('MMM d').format(dt)} at $time';
  }

  Future<void> _contactDoctor() async {
    // Open phone dialer — user can enter or select their doctor's number
    final uri = Uri(scheme: 'tel', path: '');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open phone dialler on this device.'),
        ),
      );
    }
  }

  Color _getCategoryColor(BPCategory category) {
    switch (category) {
      case BPCategory.normal:
        return AppColors.success;
      case BPCategory.elevated:
        return AppColors.warning;
      case BPCategory.highStage1:
        return AppColors.warning;
      case BPCategory.highStage2:
        return AppColors.error;
      case BPCategory.crisis:
        return const Color(0xFFD32F2F);
    }
  }
}
