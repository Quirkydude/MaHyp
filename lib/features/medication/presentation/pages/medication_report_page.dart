import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/main_layout.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../providers/medication_provider.dart';
import '../../data/models/medication_model.dart';

/// Medication Report Page with statistics and charts
class MedicationReportPage extends ConsumerStatefulWidget {
  const MedicationReportPage({super.key});

  @override
  ConsumerState<MedicationReportPage> createState() =>
      _MedicationReportPageState();
}

class _MedicationReportPageState extends ConsumerState<MedicationReportPage>
    with SingleTickerProviderStateMixin {
  String _selectedPeriod = 'Past Week';
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final medicationsAsync = ref.watch(medicationProvider);

    return MainLayout(
      currentIndex: 2,
      child: Scaffold(
        appBar: const CustomAppBar(
          title: 'Medication Report',
          showBackButton: true,
        ),
        body: medicationsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryTurquoise),
          ),
          error: (error, _) =>
              Center(child: Text('Error: $error', style: AppTextStyles.error)),
          data: (medications) {
            final stats = _calculateStats(medications);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(
                AppDimensions.screenPaddingHorizontal,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppDimensions.spacing20),

                  // Summary Statistics
                  Text('Summary Statistics', style: AppTextStyles.h3),
                  const SizedBox(height: AppDimensions.spacing16),

                  // Stats Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          label: 'Adherence',
                          value: '${stats['adherence']}%',
                          color: AppColors.success,
                          delay: 0,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacing16),
                      Expanded(
                        child: _buildStatCard(
                          label: 'Doses Taken',
                          value: '${stats['taken']}/${stats['total']}',
                          color: AppColors.primaryTurquoise,
                          delay: 100,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacing16),
                  _buildStatCard(
                    label: 'Missed',
                    value: '${stats['missed']}',
                    color: AppColors.error,
                    delay: 200,
                    isFullWidth: true,
                  ),

                  const SizedBox(height: AppDimensions.spacing32),

                  // Medication Adherence Overview
                  Text(
                    'Medication Adherence Overview',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing12),

                  // Period Selector
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.spacing4),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSmall,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: _buildPeriodButton('Past Week')),
                        Expanded(child: _buildPeriodButton('Past Month')),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacing24),

                  // Chart
                  _buildChart(stats),

                  const SizedBox(height: AppDimensions.spacing32),

                  // View Medication List Button
                  CustomButton(
                    text: 'View Medication List',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.list_alt, color: AppColors.white),
                  ),

                  const SizedBox(height: AppDimensions.spacing32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color color,
    required int delay,
    bool isFullWidth = false,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.elasticOut,
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: animValue,
          child: Opacity(opacity: animValue, child: child),
        );
      },
      child: Container(
        width: isFullWidth ? double.infinity : null,
        padding: const EdgeInsets.all(AppDimensions.spacing20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.h1.copyWith(
                color: color,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing4),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String period) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = period),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacing8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            period,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSelected
                  ? AppColors.primaryTurquoise
                  : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChart(Map<String, int> stats) {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final data = [2500, 3000, 1800, 2400, 3200, 2800, 3500]; // Dummy data

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Container(
          height: 250,
          padding: const EdgeInsets.all(AppDimensions.spacing16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            border: Border.all(color: AppColors.inputBorder, width: 1),
          ),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(days.length, (index) {
                    final height = (data[index] / 3500) * 180 * value;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 32,
                          height: height,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.primaryTurquoiseLight,
                                AppColors.primaryTurquoise,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusSmall,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacing8),
                        Text(
                          days[index],
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Map<String, int> _calculateStats(List<MedicationModel> medications) {
    final taken = medications
        .where((m) => m.overallStatus == MedicationStatus.taken)
        .length;
    final missed = medications
        .where((m) => m.overallStatus == MedicationStatus.missed)
        .length;
    final total = medications.length;
    final adherence = total > 0 ? ((taken / total) * 100).round() : 0;

    return {
      'taken': taken,
      'missed': missed,
      'total': total,
      'adherence': adherence,
    };
  }
}
