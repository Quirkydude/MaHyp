import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../bp_monitoring/presentation/providers/bp_provider.dart';
import '../../../bp_monitoring/data/models/bp_reading_model.dart';
import '../../../medication/presentation/providers/medication_provider.dart';
import '../../../medication/data/models/medication_model.dart';

/// Health Insights Page — statistics, trends, and streak analytics
class HealthInsightsPage extends ConsumerWidget {
  const HealthInsightsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bpAsync = ref.watch(bpProvider);
    final medAsync = ref.watch(medicationProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomAppBar(
        title: 'Health Insights',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.screenPaddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Health Score Card
            bpAsync.when(
              data: (readings) => medAsync.when(
                data: (meds) => _HealthScoreCard(
                    readings: readings, medications: meds),
                loading: () => _HealthScoreCard(readings: readings, medications: const []),
                error: (_, __) => _HealthScoreCard(readings: readings, medications: const []),
              ),
              loading: () => const _LoadingCard(height: 140),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: AppDimensions.spacing24),

            // 30-Day BP Averages
            Text('30-Day Averages', style: AppTextStyles.h3),
            const SizedBox(height: AppDimensions.spacing12),
            bpAsync.when(
              data: (r) => _AverageRow(readings: r),
              loading: () => const _LoadingCard(height: 80),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: AppDimensions.spacing24),

            // BP Category Distribution
            Text('BP Category Breakdown', style: AppTextStyles.h3),
            const SizedBox(height: AppDimensions.spacing12),
            bpAsync.when(
              data: (r) => _CategoryPieChart(readings: r),
              loading: () => const _LoadingCard(height: 220),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: AppDimensions.spacing24),

            // Readings by Time of Day
            Text('Best Measurement Time', style: AppTextStyles.h3),
            const SizedBox(height: AppDimensions.spacing8),
            Text(
              'Average systolic pressure by time of day',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppDimensions.spacing12),
            bpAsync.when(
              data: (r) => _TimeOfDayChart(readings: r),
              loading: () => const _LoadingCard(height: 180),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: AppDimensions.spacing24),

            // Medication streak banner
            medAsync.when(
              data: (meds) => _StreakBanner(medications: meds),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// ── Health Score Card ─────────────────────────────────────────────────────────

class _HealthScoreCard extends StatelessWidget {
  final List<BPReadingModel> readings;
  final List<MedicationModel> medications;

  const _HealthScoreCard(
      {required this.readings, required this.medications});

  int _score() {
    final last30 = readings.where((r) => r.recordedAt.isAfter(
        DateTime.now().subtract(const Duration(days: 30)))).toList();

    double bpScore = 0;
    if (last30.isNotEmpty) {
      final controlledCount =
          last30.where((r) => r.category == BPCategory.controlled).length;
      bpScore = (controlledCount / last30.length) * 50;
    }

    double medScore = 0;
    if (medications.isNotEmpty) {
      int taken = 0, total = 0;
      for (final m in medications) {
        if (m.overallStatus == MedicationStatus.taken) taken++;
        if (m.overallStatus != MedicationStatus.upcoming) total++;
      }
      if (total > 0) medScore = (taken / total) * 50;
    }

    return (bpScore + medScore).round().clamp(0, 100);
  }

  Color _scoreColor(int score) {
    if (score >= 75) return AppColors.success;
    if (score >= 50) return AppColors.warning;
    return AppColors.error;
  }

  String _scoreLabel(int score) {
    if (score >= 75) return 'Great';
    if (score >= 50) return 'Fair';
    return 'Needs Attention';
  }

  @override
  Widget build(BuildContext context) {
    final score = _score();
    final color = _scoreColor(score);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        children: [
          // Score circle
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: score.toDouble()),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOut,
            builder: (context, value, _) => Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 90,
                  height: 90,
                  child: CircularProgressIndicator(
                    value: value / 100,
                    strokeWidth: 8,
                    backgroundColor: color.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text(
                  '${value.toInt()}',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Health Score', style: AppTextStyles.h4),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _scoreLabel(score),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Based on your BP readings and medication adherence over the past 30 days.',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 30-Day Averages ───────────────────────────────────────────────────────────

class _AverageRow extends StatelessWidget {
  final List<BPReadingModel> readings;

  const _AverageRow({required this.readings});

  @override
  Widget build(BuildContext context) {
    final last30 = readings.where((r) => r.recordedAt.isAfter(
        DateTime.now().subtract(const Duration(days: 30)))).toList();

    if (last30.isEmpty) {
      return _emptyCard('No readings in the last 30 days');
    }

    final avgSys =
        last30.map((r) => r.systolic).reduce((a, b) => a + b) / last30.length;
    final avgDia =
        last30.map((r) => r.diastolic).reduce((a, b) => a + b) / last30.length;

    return Row(
      children: [
        Expanded(
          child: _StatTile(
            label: 'Avg Systolic',
            value: avgSys.toStringAsFixed(0),
            unit: 'mmHg',
            color: AppColors.error,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            label: 'Avg Diastolic',
            value: avgDia.toStringAsFixed(0),
            unit: 'mmHg',
            color: AppColors.primaryTurquoise,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            label: 'Total Readings',
            value: '${last30.length}',
            unit: 'entries',
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _emptyCard(String msg) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(msg,
            style: const TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center),
      );
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _StatTile(
      {required this.label,
      required this.value,
      required this.unit,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 22, fontWeight: FontWeight.w800)),
          Text(unit,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 10)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── Category Pie Chart ────────────────────────────────────────────────────────

class _CategoryPieChart extends StatelessWidget {
  final List<BPReadingModel> readings;

  const _CategoryPieChart({required this.readings});

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) {
      return _emptyCard('No readings yet');
    }

    final counts = <BPCategory, int>{};
    for (final r in readings) {
      counts[r.category] = (counts[r.category] ?? 0) + 1;
    }

    final colors = {
      BPCategory.controlled: AppColors.success,
      BPCategory.notControlled: AppColors.warning,
      BPCategory.crisis: const Color(0xFFD32F2F),
    };

    final labels = {
      BPCategory.controlled: 'Controlled',
      BPCategory.notControlled: 'Not Controlled',
      BPCategory.crisis: 'Crisis',
    };

    final sections = counts.entries.map((e) {
      final pct = (e.value / readings.length * 100).toStringAsFixed(0);
      return PieChartSectionData(
        value: e.value.toDouble(),
        color: colors[e.key]!,
        title: '$pct%',
        radius: 60,
        titleStyle: const TextStyle(
          color: AppColors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 3,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: counts.keys.map((cat) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: colors[cat],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${labels[cat]} (${counts[cat]})',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _emptyCard(String msg) => Container(
        height: 100,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(msg,
            style:
                const TextStyle(color: AppColors.textSecondary)),
      );
}

// ── Time of Day Bar Chart ─────────────────────────────────────────────────────

class _TimeOfDayChart extends StatelessWidget {
  final List<BPReadingModel> readings;

  const _TimeOfDayChart({required this.readings});

  @override
  Widget build(BuildContext context) {
    final buckets = <MeasurementTime, List<int>>{
      MeasurementTime.morning: [],
      MeasurementTime.afternoon: [],
      MeasurementTime.evening: [],
      MeasurementTime.night: [],
    };

    for (final r in readings) {
      buckets[r.timeOfDay]!.add(r.systolic);
    }

    final avgs = buckets.map((time, vals) {
      if (vals.isEmpty) return MapEntry(time, 0.0);
      return MapEntry(
          time, vals.reduce((a, b) => a + b) / vals.length);
    });

    final labels = ['Morning', 'Afternoon', 'Evening', 'Night'];
    final times = [
      MeasurementTime.morning,
      MeasurementTime.afternoon,
      MeasurementTime.evening,
      MeasurementTime.night,
    ];

    final allVals = avgs.values.where((v) => v > 0).toList();
    final maxY = allVals.isEmpty
        ? 180.0
        : (allVals.reduce((a, b) => a > b ? a : b) + 20).clamp(100.0, 220.0);

    final barGroups = List.generate(times.length, (i) {
      final val = avgs[times[i]]!;
      final color = val == 0
          ? AppColors.inputBorder
          : val < 120
              ? AppColors.success
              : val < 140
                  ? AppColors.warning
                  : AppColors.error;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: val == 0 ? 2 : val,
            color: color,
            width: 28,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
        ],
      );
    });

    return Container(
      height: 180,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: BarChart(
        BarChartData(
          maxY: maxY,
          barGroups: barGroups,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 20,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: AppColors.inputBorder, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    labels[value.toInt()],
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textSecondary),
                  ),
                ),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 20,
                reservedSize: 32,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textSecondary),
                ),
              ),
            ),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) =>
                  AppColors.textPrimary.withValues(alpha: 0.85),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final val = rod.toY;
                if (val <= 2) return null;
                return BarTooltipItem(
                  '${val.toStringAsFixed(0)} mmHg',
                  const TextStyle(
                    color: AppColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ── Streak Banner ─────────────────────────────────────────────────────────────

class _StreakBanner extends StatelessWidget {
  final List<MedicationModel> medications;

  const _StreakBanner({required this.medications});

  int _streak() {
    if (medications.isEmpty) return 0;
    int streak = 0;
    DateTime day = DateTime.now();
    for (int i = 0; i < 60; i++) {
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      bool hasAny = false;
      bool allTaken = true;
      for (final med in medications) {
        for (final dose in med.doses) {
          if (dose.scheduledTime.isAfter(dayStart) &&
              dose.scheduledTime.isBefore(dayEnd)) {
            hasAny = true;
            if (dose.status != MedicationStatus.taken) allTaken = false;
          }
        }
      }
      if (!hasAny || !allTaken) break;
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  @override
  Widget build(BuildContext context) {
    final streak = _streak();
    if (streak == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFF9F1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streak-Day Streak!',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'You\'ve taken all your medications for $streak days in a row. Keep it up!',
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _LoadingCard extends StatelessWidget {
  final double height;
  const _LoadingCard({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primaryTurquoise),
      ),
    );
  }
}
