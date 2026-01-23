import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/main_layout.dart';
import '../../../auth/providers/user_profile_provider.dart';
import '../../../bp_monitoring/presentation/providers/bp_provider.dart';
import '../../../medication/presentation/providers/medication_provider.dart';
import '../../../medication/data/models/medication_model.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../widgets/greeting_section.dart';
import '../widgets/stat_card.dart';
import '../widgets/action_card.dart';
import '../widgets/calendar_week_view.dart';
import '../widgets/task_item.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    // Watch providers
    final userProfileAsync = ref.watch(userProfileProvider);
    final bpReadingsAsync = ref.watch(bpProvider);
    final medicationsAsync = ref.watch(medicationProvider);

    return MainLayout(
      currentIndex: 0,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: const CustomAppBar(
          title: 'Dashboard',
          showBackButton: false,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Section
              GreetingSection(
                userName: userProfileAsync.value?.fullName ?? 'User',
                avatarUrl: null, // Avatar not yet implemented
                onProfilePressed: () => context.push(AppRouter.profile),
                onSettingsPressed: () => context.push(AppRouter.settings),
              ),
              
              const SizedBox(height: 16),
              
              // Stat Cards Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Blood Pressure Stat Card
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
                            final diff = now.difference(latest.recordedAt);
                            if (diff.inDays == 0) {
                              return 'Today, ${DateFormat('h:mm a').format(latest.recordedAt)}';
                            } else if (diff.inDays == 1) {
                              return 'Yesterday';
                            }
                            return DateFormat('MMM d').format(latest.recordedAt);
                          },
                          loading: () => 'Loading...',
                          error: (_, __) => 'Error',
                        ),
                        onTap: () => context.push(AppRouter.bpHistory),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Medication Adherence Stat Card
                    Expanded(
                      child: StatCard(
                        type: StatCardType.medication,
                        title: 'Adherence',
                        value: medicationsAsync.when(
                          data: (meds) => '${_calculateAdherence(meds)}%',
                          loading: () => '...',
                          error: (_, __) => '--',
                        ),
                        subtitle: 'This Week',
                        onTap: () => context.push(AppRouter.medicationReport),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
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
                              onTap: () => context.push(AppRouter.addMedication),
                            );
                          }
                          return ActionCard(
                            type: ActionCardType.nextMedication,
                            medicationName: next.medicationName,
                            medicationTime: _formatNextTime(next.dose.scheduledTime),
                            onTap: () => context.push(AppRouter.medicationList),
                          );
                        },
                        loading: () => const SizedBox(height: 130),
                        error: (_, __) => const SizedBox(height: 130),
                      )
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
                  setState(() {
                    _selectedDate = date;
                  });
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
                      _isToday(_selectedDate) ? "Today's Tasks" : "Tasks for ${DateFormat('MMM d').format(_selectedDate)}",
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'See all',
                      style: TextStyle(
                        color: AppColors.primaryTurquoise,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
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
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    );
                  }

                  tasks.sort((a, b) => a.dose.scheduledTime.compareTo(b.dose.scheduledTime));

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return TaskItem(
                        time: DateFormat('h:mm a').format(task.dose.scheduledTime),
                        title: 'Take ${task.medicationName} (${task.dosage})',
                        icon: Icons.medication_rounded,
                        iconColor: AppColors.primaryTurquoise,
                        isCompleted: task.dose.status == MedicationStatus.taken,
                        onCheckChanged: (value) async {
                          if (value == true) {
                            await ref.read(medicationProvider.notifier)
                                .markDoseAsTaken(task.medicationId, task.dose.id);
                          } else {
                            await ref.read(medicationProvider.notifier)
                                .undoTaken(task.medicationId, task.dose.id);
                          }
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error loading tasks: $e')),
              ),
              
              const SizedBox(height: 100), // Space for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  // Helpers

  int _calculateAdherence(List<MedicationModel> medications) {
    if (medications.isEmpty) return 0;
    
    // Simple adherence: taken / (taken + missed) across all meds
    int taken = 0;
    int total = 0;
    
    for (final med in medications) {
      if (med.overallStatus == MedicationStatus.taken) taken++;
      if (med.overallStatus != MedicationStatus.upcoming) total++;
    }
    
    // If no past doses, default to 100 or 0? 100 is more encouraging for new users
    if (total == 0) return 100;
    
    return ((taken / total) * 100).round();
  }

  ({String medicationName, String medicationId, MedicationDose dose, String dosage})? _getNextMedication(List<MedicationModel> meds) {
    final now = DateTime.now();
    final allDoses = <({String medicationName, String medicationId, MedicationDose dose, String dosage})>[];

    for (final med in meds) {
      for (final dose in med.doses) {
        // Only look for upcoming doses
        if (dose.scheduledTime.isAfter(now) && dose.status == MedicationStatus.upcoming) {
           allDoses.add((medicationName: med.name, medicationId: med.id, dose: dose, dosage: med.dosage));
        }
      }
    }

    if (allDoses.isEmpty) return null;
    
    // Sort by time
    allDoses.sort((a, b) => a.dose.scheduledTime.compareTo(b.dose.scheduledTime));
    return allDoses.first;
  }

  List<({String medicationName, String medicationId, MedicationDose dose, String dosage})> _getTasksForDate(List<MedicationModel> meds, DateTime date) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    
    final tasks = <({String medicationName, String medicationId, MedicationDose dose, String dosage})>[];

    for (final med in meds) {
      for (final dose in med.doses) {
        if (dose.scheduledTime.isAfter(dayStart.subtract(const Duration(milliseconds: 1))) && 
            dose.scheduledTime.isBefore(dayEnd)) {
             tasks.add((medicationName: med.name, medicationId: med.id, dose: dose, dosage: med.dosage));
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
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}

