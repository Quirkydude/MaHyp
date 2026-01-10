import 'package:flutter/material.dart' hide TimeOfDay;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/frequency_chip.dart';
import '../providers/medication_provider.dart';
import '../../data/models/medication_model.dart';

/// Add Medication Page with form
class AddMedicationPage extends ConsumerStatefulWidget {
  const AddMedicationPage({super.key});

  @override
  ConsumerState<AddMedicationPage> createState() => _AddMedicationPageState();
}

class _AddMedicationPageState extends ConsumerState<AddMedicationPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _notesController = TextEditingController();

  MedicationFrequency _selectedFrequency = MedicationFrequency.onceDaily;
  TimeOfDay _selectedTimeOfDay = TimeOfDay.morning;
  bool _reminderEnabled = true;
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter medication name';
    }
    return null;
  }

  String? _validateDosage(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter dosage';
    }
    return null;
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Create medication
      final medication = MedicationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        frequency: _selectedFrequency,
        timesOfDay: [_selectedTimeOfDay],
        scheduledTimes: _generateScheduledTimes(),
        reminderEnabled: _reminderEnabled,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: DateTime.now(),
      );

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      // Add to provider
      ref.read(medicationProvider.notifier).addMedication(medication);

      setState(() => _isLoading = false);

      if (mounted) {
        // Show success animation and navigate back
        _showSuccessDialog();
      }
    }
  }

  List<DateTime> _generateScheduledTimes() {
    final now = DateTime.now();
    final times = <DateTime>[];

    // Generate next 7 days of scheduled times
    for (int day = 0; day < 7; day++) {
      final date = now.add(Duration(days: day));
      int hour = 8; // Default morning time

      switch (_selectedTimeOfDay) {
        case TimeOfDay.morning:
          hour = 8;
          break;
        case TimeOfDay.afternoon:
          hour = 14;
          break;
        case TimeOfDay.evening:
          hour = 18;
          break;
        case TimeOfDay.night:
          hour = 21;
          break;
      }

      times.add(DateTime(date.year, date.month, date.day, hour, 0));
    }

    return times;
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 50,
                  color: AppColors.white,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacing24),
            Text('Medication Added!', style: AppTextStyles.h3),
            const SizedBox(height: AppDimensions.spacing8),
            Text(
              'Your medication has been successfully added to the list.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          CustomButton(
            text: 'Done',
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to list
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Add Medication'),
      body: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _animationController,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(
              AppDimensions.screenPaddingHorizontal,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppDimensions.spacing16),

                  // Name Field
                  CustomTextField(
                    label: 'Name',
                    hint: 'e.g., amlodipine',
                    controller: _nameController,
                    validator: _validateName,
                    prefixIcon: const Icon(
                      Icons.medication,
                      color: AppColors.primaryTurquoise,
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacing20),

                  // Dosage Field
                  CustomTextField(
                    label: 'Dosage',
                    hint: 'e.g., 10 mg',
                    controller: _dosageController,
                    validator: _validateDosage,
                    prefixIcon: const Icon(
                      Icons.science_outlined,
                      color: AppColors.primaryTurquoise,
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacing24),

                  // Frequency Section
                  Text('Frequency', style: AppTextStyles.inputLabel),
                  const SizedBox(height: AppDimensions.spacing12),
                  Wrap(
                    spacing: AppDimensions.spacing12,
                    runSpacing: AppDimensions.spacing12,
                    children: [
                      FrequencyChip(
                        label: 'Once daily',
                        isSelected:
                            _selectedFrequency == MedicationFrequency.onceDaily,
                        onTap: () => setState(
                          () => _selectedFrequency =
                              MedicationFrequency.onceDaily,
                        ),
                      ),
                      FrequencyChip(
                        label: 'Twice daily',
                        isSelected:
                            _selectedFrequency ==
                            MedicationFrequency.twiceDaily,
                        onTap: () => setState(
                          () => _selectedFrequency =
                              MedicationFrequency.twiceDaily,
                        ),
                      ),
                      FrequencyChip(
                        label: 'Thrice daily',
                        isSelected:
                            _selectedFrequency ==
                            MedicationFrequency.thriceDaily,
                        onTap: () => setState(
                          () => _selectedFrequency =
                              MedicationFrequency.thriceDaily,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.spacing24),

                  // Time of Day Section
                  Text('Time of the day', style: AppTextStyles.inputLabel),
                  const SizedBox(height: AppDimensions.spacing12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMedium,
                      ),
                      border: Border.all(
                        color: AppColors.inputBorder,
                        width: 1.5,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<TimeOfDay>(
                        value: _selectedTimeOfDay,
                        isExpanded: true,
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.primaryTurquoise,
                        ),
                        style: AppTextStyles.input,
                        items: TimeOfDay.values.map((time) {
                          return DropdownMenuItem(
                            value: time,
                            child: Text(_getTimeOfDayLabel(time)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedTimeOfDay = value);
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacing24),

                  // Reminder Toggle
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.spacing16),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMedium,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Enable Medication Reminders',
                          style: AppTextStyles.bodyMedium,
                        ),
                        Switch(
                          value: _reminderEnabled,
                          onChanged: (value) {
                            setState(() => _reminderEnabled = value);
                          },
                          activeColor: AppColors.primaryTurquoise,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacing20),

                  // Notes Field
                  CustomTextField(
                    label: 'Notes (optional)',
                    hint: 'e.g., take after food',
                    controller: _notesController,
                    maxLines: 3,
                    prefixIcon: const Icon(
                      Icons.note_outlined,
                      color: AppColors.primaryTurquoise,
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacing40),

                  // Save Button
                  CustomButton(
                    text: 'Save Medication',
                    onPressed: _handleSave,
                    isLoading: _isLoading,
                  ),

                  const SizedBox(height: AppDimensions.spacing16),

                  // Cancel Button
                  CustomButton(
                    text: 'Cancel',
                    onPressed: () => Navigator.of(context).pop(),
                    isOutlined: true,
                  ),

                  const SizedBox(height: AppDimensions.spacing32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getTimeOfDayLabel(TimeOfDay time) {
    switch (time) {
      case TimeOfDay.morning:
        return 'Morning';
      case TimeOfDay.afternoon:
        return 'Afternoon';
      case TimeOfDay.evening:
        return 'Evening';
      case TimeOfDay.night:
        return 'Night';
    }
  }
}
