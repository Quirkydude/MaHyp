import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/main_layout.dart';
import '../../../auth/providers/user_profile_provider.dart';
import '../../../bp_monitoring/presentation/providers/bp_provider.dart';
import '../../../bp_monitoring/data/models/bp_reading_model.dart';
import '../../../medication/presentation/providers/medication_provider.dart';
import '../../../medication/data/models/medication_model.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../widgets/greeting_section.dart';
import '../widgets/stat_card.dart';
import '../widgets/action_card.dart';
import '../widgets/calendar_week_view.dart';
import '../widgets/task_item.dart';
import '../../../notification/presentation/providers/notification_provider.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final bpReadingsAsync = ref.watch(bpProvider);
    final medicationsAsync = ref.watch(medicationProvider);
    final unreadNotificationCount = ref.watch(unreadNotificationCountProvider);

    return MainLayout(
      currentIndex: 0,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: const CustomAppBar(title: 'Dashboard', showBackButton: false),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sticky Greeting Section
            GreetingSection(
              userName: userProfileAsync.value?.fullName ?? 'User',
              avatarUrl: userProfileAsync.value?.avatarUrl,
              onProfilePressed: () => context.push(AppRouter.profile),
              onSettingsPressed: () => context.push(AppRouter.settings),
              onNotificationPressed: () =>
                  context.push(AppRouter.notifications),
              unreadNotificationCount: unreadNotificationCount,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Health Summary Strip
                    _HealthSummaryStrip(
                      bpReadingsAsync: bpReadingsAsync,
                      medicationsAsync: medicationsAsync,
                    ),

                    const SizedBox(height: 16),

                    // Stat Cards Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              type: StatCardType.bp,
                              title: 'Latest BP',
                              value: bpReadingsAsync.when(
                                data: (readings) {
                                  if (readings.isEmpty) return 'No Data';
                                  final latest = readings.first;
                                  return '${latest.systolic}/${latest.diastolic}';
                                },
                                loading: () => '...',
                                error: (_, __) => '--/--',
                              ),
                              subtitle: bpReadingsAsync.when(
                                data: (readings) {
                                  if (readings.isEmpty) return 'Tap to measure';
                                  final latest = readings.first;
                                  final now = DateTime.now();
                                  final diff =
                                      now.difference(latest.recordedAt);
                                  if (diff.inDays == 0) {
                                    return 'Today, ${DateFormat('h:mm a').format(latest.recordedAt)}';
                                  } else if (diff.inDays == 1) {
                                    return 'Yesterday';
                                  }
                                  return DateFormat('MMM d')
                                      .format(latest.recordedAt);
                                },
                                loading: () => 'Loading...',
                                error: (_, __) => 'Error',
                              ),
                              onTap: () => context.push(AppRouter.bpHistory),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatCard(
                              type: StatCardType.medication,
                              title: 'Adherence',
                              value: medicationsAsync.when(
                                data: (meds) =>
                                    '${_calculateAdherence(meds)}%',
                                loading: () => '...',
                                error: (_, __) => '--',
                              ),
                              subtitle: 'This Week',
                              onTap: () =>
                                  context.push(AppRouter.medicationReport),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // View Insights link
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => context.push('/health-insights'),
                          icon: const Icon(Icons.insights,
                              size: 16, color: AppColors.primaryTurquoise),
                          label: Text(
                            'View Insights',
                            style: TextStyle(
                              color: AppColors.primaryTurquoise,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Action Cards Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: medicationsAsync.when(
                              data: (meds) {
                                final next = _getNextMedication(meds);
                                if (next == null) {
                                  return ActionCard(
                                    type: ActionCardType.nextMedication,
                                    medicationName: 'No upcoming',
                                    medicationTime: 'medications',
                                    onTap: () => context
                                        .push(AppRouter.addMedication),
                                  );
                                }
                                return ActionCard(
                                  type: ActionCardType.nextMedication,
                                  medicationName: next.medicationName,
                                  medicationTime: _formatNextTime(
                                    next.dose.scheduledTime,
                                  ),
                                  onTap: () =>
                                      context.push(AppRouter.medicationList),
                                );
                              },
                              loading: () => const SizedBox(height: 130),
                              error: (_, __) => const SizedBox(height: 130),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ActionCard(
                              type: ActionCardType.recordBp,
                              onTap: () => context.push(AppRouter.recordBP),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Calendar Week View
                    CalendarWeekView(
                      selectedDate: _selectedDate,
                      monthName: DateFormat('MMMM').format(_selectedDate),
                      onDateSelected: (date) {
                        setState(() => _selectedDate = date);
                      },
                    ),

                    const SizedBox(height: 20),

                    // Tasks section header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _isToday(_selectedDate)
                                ? "Today's Tasks"
                                : "Tasks for ${DateFormat('MMM d').format(_selectedDate)}",
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          GestureDetector(
                            onTap: () =>
                                context.push(AppRouter.medicationList),
                            child: Text(
                              'See all',
                              style: TextStyle(
                                color: AppColors.primaryTurquoise,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Task Items List
                    medicationsAsync.when(
                      data: (meds) {
                        final tasks = _getTasksForDate(meds, _selectedDate);

                        if (tasks.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Center(
                              child: Text(
                                'No tasks for this day',
                                style:
                                    TextStyle(color: AppColors.textSecondary),
                              ),
                            ),
                          );
                        }

                        tasks.sort(
                          (a, b) => a.dose.scheduledTime
                              .compareTo(b.dose.scheduledTime),
                        );

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return TaskItem(
                              time: DateFormat(
                                'h:mm a',
                              ).format(task.dose.scheduledTime),
                              title:
                                  'Take ${task.medicationName} (${task.dosage})',
                              icon: Icons.medication_rounded,
                              iconColor: AppColors.primaryTurquoise,
                              isCompleted:
                                  task.dose.status == MedicationStatus.taken,
                              onCheckChanged: (value) async {
                                HapticFeedback.mediumImpact();
                                if (value == true) {
                                  await ref
                                      .read(medicationProvider.notifier)
                                      .markDoseAsTaken(
                                        task.medicationId,
                                        task.dose.id,
                                      );
                                } else {
                                  await ref
                                      .read(medicationProvider.notifier)
                                      .undoTaken(
                                          task.medicationId, task.dose.id);
                                }
                              },
                            );
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (_, __) => Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: AppColors.error, size: 40),
                              const SizedBox(height: 8),
                              const Text(
                                'Unable to load tasks',
                                style:
                                    TextStyle(color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () =>
                                    ref.invalidate(medicationProvider),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helpers

  int _calculateAdherence(List<MedicationModel> medications) {
    if (medications.isEmpty) return 0;
    int taken = 0;
    int total = 0;
    for (final med in medications) {
      if (med.overallStatus == MedicationStatus.taken) taken++;
      if (med.overallStatus != MedicationStatus.upcoming) total++;
    }
    if (total == 0) return 100;
    return ((taken / total) * 100).round();
  }

  ({
    String medicationName,
    String medicationId,
    MedicationDose dose,
    String dosage,
  })?
      _getNextMedication(List<MedicationModel> meds) {
    final now = DateTime.now();
    final allDoses = <
        ({
          String medicationName,
          String medicationId,
          MedicationDose dose,
          String dosage,
        })>[];

    for (final med in meds) {
      for (final dose in med.doses) {
        if (dose.scheduledTime.isAfter(now) &&
            dose.status == MedicationStatus.upcoming) {
          allDoses.add((
            medicationName: med.name,
            medicationId: med.id,
            dose: dose,
            dosage: med.dosage,
          ));
        }
      }
    }

    if (allDoses.isEmpty) return null;
    allDoses.sort(
        (a, b) => a.dose.scheduledTime.compareTo(b.dose.scheduledTime));
    return allDoses.first;
  }

  List<
      ({
        String medicationName,
        String medicationId,
        MedicationDose dose,
        String dosage,
      })> _getTasksForDate(List<MedicationModel> meds, DateTime date) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final tasks = <
        ({
          String medicationName,
          String medicationId,
          MedicationDose dose,
          String dosage,
        })>[];

    for (final med in meds) {
      for (final dose in med.doses) {
        if (dose.scheduledTime
                .isAfter(dayStart.subtract(const Duration(milliseconds: 1))) &&
            dose.scheduledTime.isBefore(dayEnd)) {
          tasks.add((
            medicationName: med.name,
            medicationId: med.id,
            dose: dose,
            dosage: med.dosage,
          ));
        }
      }
    }

    return tasks;
  }

  String _formatNextTime(DateTime time) {
    final now = DateTime.now();
    final diff = time.difference(now);

    if (diff.inHours < 12 && time.day == now.day) {
      return 'Today at ${DateFormat('h:mm a').format(time)}';
    } else if (time.day == now.day + 1) {
      return 'Tomorrow at ${DateFormat('h:mm a').format(time)}';
    }
    return DateFormat('MMM d, h:mm a').format(time);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

/// Compact health summary strip shown below the greeting.
/// Displays today's BP status, medication adherence, and streak in one row.
class _HealthSummaryStrip extends StatelessWidget {
  final AsyncValue<List<BPReadingModel>> bpReadingsAsync;
  final AsyncValue<List<MedicationModel>> medicationsAsync;

  const _HealthSummaryStrip({
    required this.bpReadingsAsync,
    required this.medicationsAsync,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Row(
          children: [
            // BP Status badge
            Expanded(
              child: bpReadingsAsync.when(
                data: (readings) {
                  if (readings.isEmpty) {
                    return _SummaryItem(
                      icon: Icons.favorite_outline,
                      color: AppColors.textSecondary,
                      label: 'No BP yet',
                      value: '--',
                    );
                  }
                  final latest = readings.first;
                  final color = _bpColor(latest.category);
                  return _SummaryItem(
                    icon: Icons.favorite,
                    color: color,
                    label: latest.categoryName,
                    value: '${latest.systolic}/${latest.diastolic}',
                  );
                },
                loading: () => const _SummaryItem(
                  icon: Icons.favorite_outline,
                  color: AppColors.textSecondary,
                  label: 'BP',
                  value: '...',
                ),
                error: (_, __) => const _SummaryItem(
                  icon: Icons.favorite_outline,
                  color: AppColors.error,
                  label: 'BP Error',
                  value: '--',
                ),
              ),
            ),

            _Divider(),

            // Adherence ring
            Expanded(
              child: medicationsAsync.when(
                data: (meds) {
                  final adherence = _calcAdherence(meds);
                  final color = adherence >= 80
                      ? AppColors.success
                      : adherence >= 50
                          ? AppColors.warning
                          : AppColors.error;
                  return _SummaryItem(
                    icon: Icons.medication,
                    color: color,
                    label: 'Adherence',
                    value: '$adherence%',
                  );
                },
                loading: () => const _SummaryItem(
                  icon: Icons.medication_outlined,
                  color: AppColors.textSecondary,
                  label: 'Adherence',
                  value: '...',
                ),
                error: (_, __) => const _SummaryItem(
                  icon: Icons.medication_outlined,
                  color: AppColors.textSecondary,
                  label: 'Adherence',
                  value: '--',
                ),
              ),
            ),

            _Divider(),

            // Streak
            Expanded(
              child: medicationsAsync.when(
                data: (meds) {
                  final streak = _calcStreak(meds);
                  return _SummaryItem(
                    icon: Icons.local_fire_department,
                    color: streak > 0 ? const Color(0xFFFF6B35) : AppColors.textSecondary,
                    label: 'Day Streak',
                    value: '$streak',
                  );
                },
                loading: () => const _SummaryItem(
                  icon: Icons.local_fire_department,
                  color: AppColors.textSecondary,
                  label: 'Streak',
                  value: '...',
                ),
                error: (_, __) => const _SummaryItem(
                  icon: Icons.local_fire_department,
                  color: AppColors.textSecondary,
                  label: 'Streak',
                  value: '--',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _bpColor(BPCategory cat) {
    switch (cat) {
      case BPCategory.controlled:
        return AppColors.success;
      case BPCategory.notControlled:
        return AppColors.warning;
      case BPCategory.crisis:
        return AppColors.error;
    }
  }

  int _calcAdherence(List<MedicationModel> meds) {
    if (meds.isEmpty) return 0;
    int taken = 0, total = 0;
    for (final m in meds) {
      if (m.overallStatus == MedicationStatus.taken) taken++;
      if (m.overallStatus != MedicationStatus.upcoming) total++;
    }
    if (total == 0) return 100;
    return ((taken / total) * 100).round();
  }

  int _calcStreak(List<MedicationModel> meds) {
    if (meds.isEmpty) return 0;
    int streak = 0;
    DateTime day = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      bool hasAny = false;
      bool allTaken = true;
      for (final med in meds) {
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
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _SummaryItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 48,
      color: AppColors.inputBorder,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
