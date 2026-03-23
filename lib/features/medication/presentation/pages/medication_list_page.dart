import 'package:flutter/material.dart';
import '../../../../illustrations/illustrations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/main_layout.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/medication_details_modal.dart';
import '../../../../shared/widgets/tab_selector.dart';
import '../../../../shared/widgets/medication_card.dart';
import '../../../../shared/widgets/report_card.dart';

import '../providers/medication_provider.dart';

import '../../data/models/medication_model.dart';

/// Medication List Page with Today and Upcoming tabs
class MedicationListPage extends ConsumerStatefulWidget {
  const MedicationListPage({super.key});

  @override
  ConsumerState<MedicationListPage> createState() => _MedicationListPageState();
}

class _MedicationListPageState extends ConsumerState<MedicationListPage>
    with SingleTickerProviderStateMixin {
  int _selectedTab = 0;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final medicationsAsync = ref.watch(medicationProvider);
    final stats = ref.watch(adherenceStatsProvider);

    return MainLayout(
      currentIndex: 2,
      child: Scaffold(
        appBar: const CustomAppBar(
          title: 'Medication List',
          showBackButton: false,
        ),
        body: medicationsAsync.when(
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
                Text('Error loading medications', style: AppTextStyles.bodyMedium),
                const SizedBox(height: AppDimensions.spacing8),
                TextButton(
                  onPressed: () => ref.read(medicationProvider.notifier).refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (medications) {
            final todayMeds = medications.where((med) => med.todayDoses.isNotEmpty).toList();
            final upcomingMeds = medications.where((med) => med.nextDose != null).toList();

            return Column(
              children: [
                // Tab Selector
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.screenPaddingHorizontal,
                    AppDimensions.spacing16,
                    AppDimensions.screenPaddingHorizontal,
                    0,
                  ),
                  child: Column(
                    children: [
                      TabSelector(
                        tabs: const ['Today', 'Upcoming'],
                        selectedIndex: _selectedTab,
                        onTabSelected: (index) {
                          setState(() => _selectedTab = index);
                        },
                      ),

                      // Report Card (only in Today tab)
                      if (_selectedTab == 0) ...[
                        const SizedBox(height: AppDimensions.spacing16),
                        ReportCard(
                          adherencePercentage: stats['adherence'] ?? 0,
                          dosesTaken: stats['taken'] ?? 0,
                          totalDoses: stats['total'] ?? 0,
                          missedDoses: stats['missed'] ?? 0,
                          onViewReport: () => context.push('/medication-report'),
                        ),
                      ],
                    ],
                  ),
                ),

                // Medication List
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeInOut,
                    switchOutCurve: Curves.easeInOut,
                    child: _selectedTab == 0
                        ? _buildTodayList(todayMeds)
                        : _buildUpcomingList(upcomingMeds),
                  ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: ScaleTransition(
          scale: _fabScaleAnimation,
          child: FloatingActionButton.extended(
            onPressed: () {
              context.push('/add-medication');
            },
            backgroundColor: AppColors.primaryTurquoise,
            icon: const Icon(Icons.add, color: AppColors.white),
            label: Text(
              'Add Medication',
              style: AppTextStyles.button.copyWith(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodayList(List<MedicationModel> medications) {
    if (medications.isEmpty) {
      return _buildEmptyState('No medications for today');
    }

    return ListView.builder(
      key: const ValueKey('today'),
      padding: const EdgeInsets.all(AppDimensions.screenPaddingHorizontal),
      itemCount: medications.length,
      itemBuilder: (context, index) {
        final med = medications[index];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 100)),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(opacity: value, child: child),
            );
          },
          child: MedicationCard(
            name: med.name,
            dosage: med.dosage,
            frequency: med.frequencyString,
            nextDose: _formatNextDose(med.nextDose?.scheduledTime),
            status: med.overallStatus,
            onTap: () => _showMedicationDetails(med),
            onMarkAsTaken: () {
              final nextDose = med.nextDose;
              if (nextDose != null && nextDose.canTake) {
                ref
                    .read(medicationProvider.notifier)
                    .markDoseAsTaken(med.id, nextDose.id);
                _showSnackBar('Medication marked as taken');
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildUpcomingList(List<MedicationModel> medications) {
    if (medications.isEmpty) {
      return _buildEmptyState('No upcoming medications');
    }

    return ListView.builder(
      key: const ValueKey('upcoming'),
      padding: const EdgeInsets.all(AppDimensions.screenPaddingHorizontal),
      itemCount: medications.length,
      itemBuilder: (context, index) {
        final med = medications[index];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 100)),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: MedicationCard(
            name: med.name,
            dosage: med.dosage,
            frequency: med.frequencyString,
            nextDose: _formatNextDose(med.nextDose?.scheduledTime),
            status: med.overallStatus,
            onTap: () => _showMedicationDetails(med),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: EmptyStateIllustration(size: 200),
          ),
          const SizedBox(height: AppDimensions.spacing24),
          Text(
            message,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNextDose(DateTime? nextDose) {
    if (nextDose == null) return 'No scheduled dose';
    final now = DateTime.now();
    final difference = nextDose.difference(now);

    if (difference.inDays > 0) {
      return DateFormat('MMM dd, h:mm a').format(nextDose);
    } else if (difference.inHours > 0) {
      return 'In ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'In ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return DateFormat('h:mm a').format(nextDose);
    }
  }

  void _showMedicationDetails(MedicationModel medication) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: MedicationDetailsModal(
          medication: medication,
          onMarkAsTaken: (doseId) {
            ref
                .read(medicationProvider.notifier)
                .markDoseAsTaken(medication.id, doseId);
          },
          onSkip: (doseId) {
            ref
                .read(medicationProvider.notifier)
                .skipDose(medication.id, doseId);
          },
          onSnooze: (doseId, minutes) {
            ref
                .read(medicationProvider.notifier)
                .snoozeDose(medication.id, doseId, minutes);
          },
          onEdit: () {
            Navigator.pop(context);
            context.push(
              '/edit-medication/${medication.id}',
              extra: medication,
            );
          },
          onDelete: () {
            Navigator.pop(context);
            _showDeleteConfirmation(medication.id);
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(String medicationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Medication?'),
        content: const Text(
          'Are you sure you want to delete this medication? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(medicationProvider.notifier)
                  .deleteMedication(medicationId);
              Navigator.pop(context);
              _showSnackBar('Medication deleted');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
