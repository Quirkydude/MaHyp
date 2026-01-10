import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mahyp_app/features/medication/data/models/medication_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/main_layout.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/tab_selector.dart';
import '../../../../shared/widgets/medication_card.dart';
import '../providers/medication_provider.dart';
import '../../data/models/medication_model.dart' as models;

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
    final medications = ref.watch(medicationProvider);
    final todayMeds = medications
        .where((m) => m.status != models.MedicationStatus.missed)
        .toList();
    final upcomingMeds = medications
        .where((m) => m.status == models.MedicationStatus.upcoming)
        .toList();

    return MainLayout(
      currentIndex: 2,
      child: Scaffold(
        appBar: const CustomAppBar(
          title: 'Medication List',
          showBackButton: false,
        ),
        body: Column(
          children: [
            // Tab Selector
            Padding(
              padding: const EdgeInsets.all(
                AppDimensions.screenPaddingHorizontal,
              ),
              child: TabSelector(
                tabs: const ['Today', 'Upcoming'],
                selectedIndex: _selectedTab,
                onTabSelected: (index) {
                  setState(() => _selectedTab = index);
                },
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
            nextDose: _formatNextDose(med.nextDose),
            status: med.status,
            onTap: () {
              // TODO: Navigate to medication details
            },
            onMarkAsTaken: () {
              ref.read(medicationProvider.notifier).markAsTaken(med.id);
              _showSnackBar('Medication marked as taken');
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
            nextDose: _formatNextDose(med.nextDose),
            status: med.status,
            onTap: () {
              // TODO: Navigate to medication details
            },
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
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.medication_outlined,
                size: 60,
                color: AppColors.textHint,
              ),
            ),
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
