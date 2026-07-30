import 'package:flutter/material.dart' hide TimeOfDay;
import '../../../../illustrations/illustrations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../providers/bp_provider.dart';
import '../../data/models/bp_reading_model.dart';


/// Record Blood Pressure Page
class RecordBPPage extends ConsumerStatefulWidget {
  const RecordBPPage({super.key});

  @override
  ConsumerState<RecordBPPage> createState() => _RecordBPPageState();
}

class _RecordBPPageState extends ConsumerState<RecordBPPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _heartRateController = TextEditingController();

  MeasurementTime _selectedTime = MeasurementTime.morning;
  final _notesController = TextEditingController();
  bool _feltDizzy = false;
  bool _hadHeadache = false;
  bool _feltNausea = false;
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();

    // Auto-select current time of day
    _selectedTime = _getCurrentTimeOfDay();
  }

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _heartRateController.dispose();
    _notesController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  MeasurementTime _getCurrentTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return MeasurementTime.morning;
    if (hour < 17) return MeasurementTime.afternoon;
    if (hour < 21) return MeasurementTime.evening;
    return MeasurementTime.night;
  }

  String? _validateSystolic(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter systolic pressure';
    }
    final number = int.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    if (number < 70 || number > 250) {
      return 'Value should be between 70-250';
    }
    return null;
  }

  String? _validateDiastolic(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter diastolic pressure';
    }
    final number = int.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    if (number < 40 || number > 150) {
      return 'Value should be between 40-150';
    }

    // Check if diastolic is less than systolic
    final systolic = int.tryParse(_systolicController.text);
    if (systolic != null && number >= systolic) {
      return 'Diastolic must be lower than systolic';
    }

    return null;
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final reading = BPReadingModel(
        id: '', // Will be set by Firestore
        systolic: int.parse(_systolicController.text),
        diastolic: int.parse(_diastolicController.text),
        heartRate: _heartRateController.text.trim().isEmpty
            ? null
            : int.tryParse(_heartRateController.text.trim()),
        recordedAt: DateTime.now(),
        timeOfDay: _selectedTime,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        feltDizzy: _feltDizzy,
        hadHeadache: _hadHeadache,
        feltNausea: _feltNausea,
      );

      try {
        await ref.read(bpProvider.notifier).addReading(reading);

        setState(() => _isLoading = false);

        if (mounted) {
          // Check if emergency
          if (reading.isEmergency) {
            context.go('/bp-emergency', extra: reading);
          } else if (reading.needsAttention) {
            context.go('/bp-analysis', extra: reading);
          } else {
            _showSuccessDialog();
          }
        }
      } catch (e) {
        setState(() => _isLoading = false);
        debugPrint('Error saving reading: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save reading. Please try again.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
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
              child: SvgPicture.asset(
                'assets/illustrations/success_state.svg',
                width: 100,
                height: 100,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing24),
            Text('Reading Saved!', style: AppTextStyles.h3),
            const SizedBox(height: AppDimensions.spacing8),
            Text(
              'Your blood pressure reading has been recorded successfully.',
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
              Navigator.of(context).pop();
              context.go('/bp-history');
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Record Blood Pressure'),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.screenPaddingHorizontal),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppDimensions.spacing16),

                Center(
                  child: BloodPressureCheckIllustration(size: 200),
                ),
                const SizedBox(height: AppDimensions.spacing24),

                // Systolic Input
                CustomTextField(
                  label: 'Systolic (mmHg)',
                  hint: 'e.g., 120',
                  controller: _systolicController,
                  keyboardType: TextInputType.number,
                  validator: _validateSystolic,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  prefixIcon: const Icon(
                    Icons.arrow_upward,
                    color: AppColors.primaryTurquoise,
                  ),
                ),

                const SizedBox(height: AppDimensions.spacing20),

                // Diastolic Input
                CustomTextField(
                  label: 'Diastolic (mmHg)',
                  hint: 'e.g., 80',
                  controller: _diastolicController,
                  keyboardType: TextInputType.number,
                  validator: _validateDiastolic,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  prefixIcon: const Icon(
                    Icons.arrow_downward,
                    color: AppColors.primaryTurquoise,
                  ),
                ),

                const SizedBox(height: AppDimensions.spacing20),

                // Heart Rate (optional)
                CustomTextField(
                  label: 'Heart Rate (bpm) — optional',
                  hint: 'e.g., 72',
                  controller: _heartRateController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  prefixIcon: const Icon(
                    Icons.favorite_border,
                    color: AppColors.primaryTurquoise,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return null;
                    final n = int.tryParse(value);
                    if (n == null || n < 40 || n > 200) {
                      return 'Enter a valid heart rate (40–200 bpm)';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppDimensions.spacing24),

                // Measurement Time with icons for visual recognition
                Text('Measurement Time', style: AppTextStyles.inputLabel),
                const SizedBox(height: AppDimensions.spacing12),
                Wrap(
                  spacing: AppDimensions.spacing8,
                  runSpacing: AppDimensions.spacing8,
                  children: MeasurementTime.values.map((time) {
                    final isSelected = _selectedTime == time;
                    return ChoiceChip(
                      avatar: Icon(
                        _getTimeIcon(time),
                        size: 18,
                        color: isSelected
                            ? AppColors.white
                            : AppColors.primaryTurquoise,
                      ),
                      label: Text(_getTimeLabel(time)),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedTime = time);
                      },
                      selectedColor: AppColors.primaryTurquoise,
                      labelStyle: AppTextStyles.bodyMedium.copyWith(
                        color: isSelected
                            ? AppColors.white
                            : AppColors.textPrimary,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: AppDimensions.spacing24),

                // Symptoms with icon chips for quick visual selection
                Text('Any symptoms?', style: AppTextStyles.inputLabel),
                const SizedBox(height: AppDimensions.spacing12),
                Wrap(
                  spacing: AppDimensions.spacing12,
                  runSpacing: AppDimensions.spacing12,
                  children: [
                    _buildSymptomChip(
                      icon: Icons.rotate_right,
                      label: 'Dizzy',
                      isSelected: _feltDizzy,
                      onSelected: (selected) =>
                          setState(() => _feltDizzy = selected),
                    ),
                    _buildSymptomChip(
                      icon: Icons.sick_outlined,
                      label: 'Headache',
                      isSelected: _hadHeadache,
                      onSelected: (selected) =>
                          setState(() => _hadHeadache = selected),
                    ),
                    _buildSymptomChip(
                      icon: Icons.sentiment_very_dissatisfied,
                      label: 'Nausea',
                      isSelected: _feltNausea,
                      onSelected: (selected) =>
                          setState(() => _feltNausea = selected),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.spacing20),

                // Notes
                CustomTextField(
                  label: 'Notes (optional)',
                  hint: 'e.g., felt dizzy',
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
                  text: 'Save Reading',
                  onPressed: _handleSave,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: AppDimensions.spacing32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a symptom selection chip with icon for visual recognition
  Widget _buildSymptomChip({
    required IconData icon,
    required String label,
    required bool isSelected,
    required ValueChanged<bool> onSelected,
  }) {
    return FilterChip(
      avatar: Icon(
        icon,
        size: 20,
        color: isSelected ? AppColors.white : AppColors.primaryTurquoise,
      ),
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: AppColors.primaryTurquoise,
      backgroundColor: AppColors.inputBackground,
      labelStyle: AppTextStyles.bodyMedium.copyWith(
        color: isSelected ? AppColors.white : AppColors.textPrimary,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing8,
        vertical: AppDimensions.spacing4,
      ),
      showCheckmark: false,
    );
  }

  /// Returns the icon for each time of day
  IconData _getTimeIcon(MeasurementTime time) {
    switch (time) {
      case MeasurementTime.morning:
        return Icons.wb_twilight; // Sunrise icon
      case MeasurementTime.afternoon:
        return Icons.wb_sunny; // Sun icon
      case MeasurementTime.evening:
        return Icons.wb_cloudy; // Sunset/cloudy icon
      case MeasurementTime.night:
        return Icons.nightlight_round; // Moon icon
    }
  }

  String _getTimeLabel(MeasurementTime time) {
    switch (time) {
      case MeasurementTime.morning:
        return 'Morning';
      case MeasurementTime.afternoon:
        return 'Afternoon';
      case MeasurementTime.evening:
        return 'Evening';
      case MeasurementTime.night:
        return 'Night';
    }
  }
}
