import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/main_layout.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../providers/bp_provider.dart';
import '../../data/models/bp_reading_model.dart';

/// BP History Page with trend chart
class BPHistoryPage extends ConsumerWidget {
  const BPHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readingsAsync = ref.watch(bpProvider);

    return MainLayout(
      currentIndex: 1,
      child: Scaffold(
        appBar: const CustomAppBar(
          title: 'Blood Pressure History',
          showBackButton: false,
        ),
        body: readingsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryTurquoise,
            ),
          ),
          error: (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: AppDimensions.spacing16),
                Text('Error loading readings', style: AppTextStyles.bodyMedium),
                const SizedBox(height: AppDimensions.spacing8),
                TextButton(
                  onPressed: () => ref.read(bpProvider.notifier).refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (readings) {
            final weekReadings = readings.where((r) {
              return r.recordedAt.isAfter(
                DateTime.now().subtract(const Duration(days: 7)),
              );
            }).toList();

            if (readings.isEmpty) {
              return _buildEmptyState(context);
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(
                AppDimensions.screenPaddingHorizontal,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppDimensions.spacing16),

                  // Trend Chart
                  Text('Blood Pressure Trend', style: AppTextStyles.h3),
                  const SizedBox(height: AppDimensions.spacing16),
                  _buildTrendChart(weekReadings),

                  const SizedBox(height: AppDimensions.spacing32),

                  // Recent Readings
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recent Readings', style: AppTextStyles.h3),
                      TextButton(
                        onPressed: () {
                          // TODO: View all
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacing16),

                  // Readings List
                  ...readings.take(10).map((reading) {
                    return _buildReadingCard(context, ref, reading);
                  }),

                  const SizedBox(height: AppDimensions.spacing80),
                ],
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/record-bp'),
          backgroundColor: AppColors.primaryTurquoise,
          icon: const Icon(Icons.add, color: AppColors.white),
          label: Text(
            'Record BP',
            style: AppTextStyles.button.copyWith(fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              color: AppColors.inputBackground,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_outline,
              size: 60,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing24),
          Text('No readings yet', style: AppTextStyles.h3),
          const SizedBox(height: AppDimensions.spacing8),
          Text(
            'Start tracking your blood pressure\nby recording your first reading',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChart(List<BPReadingModel> readings) {
    if (readings.isEmpty) {
      return Container(
        height: 200,
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: const Center(child: Text('Not enough data to show trend')),
      );
    }

    // Sort by date
    final sorted = [...readings]
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    final maxSystolic = sorted
        .map((r) => r.systolic)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    return Container(
      height: 250,
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        children: [
          // Chart
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(sorted.length > 7 ? 7 : sorted.length, (
                index,
              ) {
                final reading =
                    sorted[sorted.length > 7
                        ? sorted.length - 7 + index
                        : index];
                final systolicHeight = (reading.systolic / maxSystolic) * 150;
                final diastolicHeight = (reading.diastolic / maxSystolic) * 150;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Systolic bar
                    Container(
                      width: 16,
                      height: systolicHeight,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.error,
                            _getCategoryColor(reading.category),
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Diastolic bar
                    Container(
                      width: 16,
                      height: diastolicHeight,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(
                          reading.category,
                        ).withOpacity(0.5),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacing8),
                    Text(
                      DateFormat('E').format(reading.recordedAt),
                      style: AppTextStyles.caption,
                    ),
                  ],
                );
              }),
            ),
          ),

          const SizedBox(height: AppDimensions.spacing16),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend('Systolic', AppColors.error),
              const SizedBox(width: AppDimensions.spacing24),
              _buildLegend('Diastolic', AppColors.primaryTurquoise),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppDimensions.spacing8),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildReadingCard(
    BuildContext context,
    WidgetRef ref,
    BPReadingModel reading,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacing12),
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: _getCategoryColor(reading.category).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getCategoryColor(reading.category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusSmall,
                  ),
                ),
                child: Icon(
                  Icons.favorite,
                  color: _getCategoryColor(reading.category),
                  size: 20,
                ),
              ),
              const SizedBox(width: AppDimensions.spacing12),

              // Reading
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reading.formattedReading, style: AppTextStyles.h4),
                    Text(
                      reading.categoryName,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: _getCategoryColor(reading.category),
                      ),
                    ),
                  ],
                ),
              ),

              // Date/Time
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat('MMM dd').format(reading.recordedAt),
                    style: AppTextStyles.bodySmall,
                  ),
                  Text(
                    DateFormat('h:mm a').format(reading.recordedAt),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              // More icon
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showOptions(context, ref, reading),
              ),
            ],
          ),

          if (reading.notes != null) ...[
            const SizedBox(height: AppDimensions.spacing8),
            Text(
              reading.notes!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showOptions(
    BuildContext context,
    WidgetRef ref,
    BPReadingModel reading,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('View Analysis'),
              onTap: () {
                Navigator.pop(context);
                context.push('/bp-analysis', extra: reading);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text('Delete'),
              onTap: () {
                ref.read(bpProvider.notifier).deleteReading(reading.id);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
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
