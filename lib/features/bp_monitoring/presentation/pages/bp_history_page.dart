import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/main_layout.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../illustrations/illustrations.dart';

import '../providers/bp_provider.dart';
import '../../data/models/bp_reading_model.dart';

enum _TimeRange { week, month, threeMonths }

/// BP History Page with interactive fl_chart trend chart and time range filter
class BPHistoryPage extends ConsumerStatefulWidget {
  const BPHistoryPage({super.key});

  @override
  ConsumerState<BPHistoryPage> createState() => _BPHistoryPageState();
}

class _BPHistoryPageState extends ConsumerState<BPHistoryPage> {
  _TimeRange _range = _TimeRange.week;
  bool _showAll = false;

  List<BPReadingModel> _filterByRange(List<BPReadingModel> all) {
    final now = DateTime.now();
    final days = switch (_range) {
      _TimeRange.week => 7,
      _TimeRange.month => 30,
      _TimeRange.threeMonths => 90,
    };
    return all
        .where((r) => r.recordedAt.isAfter(now.subtract(Duration(days: days))))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
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
                const Icon(Icons.error_outline,
                    size: 48, color: AppColors.error),
                const SizedBox(height: AppDimensions.spacing16),
                Text('Error loading readings',
                    style: AppTextStyles.bodyMedium),
                const SizedBox(height: AppDimensions.spacing8),
                TextButton(
                  onPressed: () => ref.read(bpProvider.notifier).refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (allReadings) {
            if (allReadings.isEmpty) {
              return _buildEmptyState(context);
            }

            final filtered = _filterByRange(allReadings);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(
                AppDimensions.screenPaddingHorizontal,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppDimensions.spacing8),

                  // Time Range Tabs
                  _TimeRangeSelector(
                    selected: _range,
                    onChanged: (r) => setState(() => _range = r),
                  ),

                  const SizedBox(height: AppDimensions.spacing16),

                  // Chart
                  Text('Blood Pressure Trend', style: AppTextStyles.h3),
                  const SizedBox(height: AppDimensions.spacing12),
                  _BPLineChart(readings: filtered),

                  const SizedBox(height: AppDimensions.spacing16),

                  // Stats Row
                  _StatsRow(readings: filtered),

                  const SizedBox(height: AppDimensions.spacing32),

                  // Recent Readings header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Readings', style: AppTextStyles.h3),
                      TextButton(
                        onPressed: () =>
                            setState(() => _showAll = !_showAll),
                        child: Text(_showAll ? 'Show Less' : 'View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacing8),

                  // Readings List
                  ...(_showAll ? allReadings : allReadings.take(10))
                      .map((r) => _buildReadingCard(context, ref, r)),

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
          EmptyStateIllustration(size: 200),
          const SizedBox(height: AppDimensions.spacing24),
          Text('No readings yet', style: AppTextStyles.h3),
          const SizedBox(height: AppDimensions.spacing8),
          Text(
            'Start tracking your blood pressure\nby recording your first reading',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingCard(
    BuildContext context,
    WidgetRef ref,
    BPReadingModel reading,
  ) {
    final catColor = _getCategoryColor(reading.category);
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacing12),
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: catColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusSmall),
                ),
                child: Icon(Icons.favorite, color: catColor, size: 20),
              ),
              const SizedBox(width: AppDimensions.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reading.formattedReading, style: AppTextStyles.h4),
                    Text(
                      reading.categoryName,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: catColor),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat('MMM dd').format(reading.recordedAt),
                    style: AppTextStyles.bodySmall,
                  ),
                  Text(
                    DateFormat('h:mm a').format(reading.recordedAt),
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
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
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary),
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
      case BPCategory.controlled:
        return AppColors.success;
      case BPCategory.notControlled:
        return AppColors.warning;
      case BPCategory.crisis:
        return const Color(0xFFD32F2F);
    }
  }
}

// ── Time Range Selector ────────────────────────────────────────────────────────

class _TimeRangeSelector extends StatelessWidget {
  final _TimeRange selected;
  final ValueChanged<_TimeRange> onChanged;

  const _TimeRangeSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const ranges = [
      (_TimeRange.week, '7D'),
      (_TimeRange.month, '30D'),
      (_TimeRange.threeMonths, '3M'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ranges.map((entry) {
          final (range, label) = entry;
          final isActive = selected == range;
          return GestureDetector(
            onTap: () => onChanged(range),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primaryTurquoise : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: isActive ? AppColors.white : AppColors.textSecondary,
                  fontWeight:
                      isActive ? FontWeight.w700 : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── fl_chart Line Chart ────────────────────────────────────────────────────────

class _BPLineChart extends StatelessWidget {
  final List<BPReadingModel> readings;

  const _BPLineChart({required this.readings});

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: const Center(
          child: Text(
            'No readings in this period',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final sorted = [...readings]
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

    final systolicSpots = sorted.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.systolic.toDouble());
    }).toList();

    final diastolicSpots = sorted.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.diastolic.toDouble());
    }).toList();

    final allValues = sorted
        .expand((r) => [r.systolic.toDouble(), r.diastolic.toDouble()])
        .toList();
    final minY = (allValues.reduce((a, b) => a < b ? a : b) - 10)
        .clamp(40.0, 200.0);
    final maxY = (allValues.reduce((a, b) => a > b ? a : b) + 10)
        .clamp(60.0, 220.0);

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          clipData: const FlClipData.all(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 20,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.inputBorder,
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 20,
                reservedSize: 36,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textSecondary),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: sorted.length > 7 ? (sorted.length / 4).ceilToDouble() : 1,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= sorted.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormat('d/M').format(sorted[idx].recordedAt),
                      style: const TextStyle(
                          fontSize: 9, color: AppColors.textSecondary),
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
          // Reference lines at 120 and 140
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: 120,
                color: AppColors.warning.withValues(alpha: 0.6),
                strokeWidth: 1.5,
                dashArray: [6, 4],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600),
                  labelResolver: (_) => '120',
                ),
              ),
              HorizontalLine(
                y: 140,
                color: AppColors.error.withValues(alpha: 0.6),
                strokeWidth: 1.5,
                dashArray: [6, 4],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.error,
                      fontWeight: FontWeight.w600),
                  labelResolver: (_) => '140',
                ),
              ),
            ],
          ),
          lineBarsData: [
            // Systolic line
            LineChartBarData(
              spots: systolicSpots,
              isCurved: true,
              curveSmoothness: 0.35,
              color: AppColors.error,
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) =>
                    FlDotCirclePainter(
                  radius: 3,
                  color: AppColors.white,
                  strokeWidth: 2,
                  strokeColor: AppColors.error,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.error.withValues(alpha: 0.06),
              ),
            ),
            // Diastolic line
            LineChartBarData(
              spots: diastolicSpots,
              isCurved: true,
              curveSmoothness: 0.35,
              color: AppColors.primaryTurquoise,
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) =>
                    FlDotCirclePainter(
                  radius: 3,
                  color: AppColors.white,
                  strokeWidth: 2,
                  strokeColor: AppColors.primaryTurquoise,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primaryTurquoise.withValues(alpha: 0.06),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppColors.textPrimary.withValues(alpha: 0.9),
              getTooltipItems: (spots) => spots.map((s) {
                final isSystemic = s.barIndex == 0;
                return LineTooltipItem(
                  '${isSystemic ? 'Sys' : 'Dia'}: ${s.y.toInt()}',
                  TextStyle(
                    color: isSystemic
                        ? AppColors.error
                        : AppColors.primaryTurquoise,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Stats Summary Row ──────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final List<BPReadingModel> readings;

  const _StatsRow({required this.readings});

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) return const SizedBox.shrink();

    final avgSys = readings.map((r) => r.systolic).reduce((a, b) => a + b) /
        readings.length;
    final avgDia =
        readings.map((r) => r.diastolic).reduce((a, b) => a + b) /
            readings.length;

    return Row(
      children: [
        Expanded(
          child: _StatChip(
            label: 'Avg Systolic',
            value: avgSys.toStringAsFixed(0),
            color: AppColors.error,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatChip(
            label: 'Avg Diastolic',
            value: avgDia.toStringAsFixed(0),
            color: AppColors.primaryTurquoise,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatChip(
            label: 'Readings',
            value: '${readings.length}',
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
