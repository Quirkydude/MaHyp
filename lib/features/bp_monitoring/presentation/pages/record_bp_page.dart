import 'package:flutter/material.dart';
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
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        systolic: int.parse(_systolicController.text),
        diastolic: int.parse(_diastolicController.text),
        recordedAt: DateTime.now(),
        timeOfDay: _selectedTime,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        feltDizzy: _feltDizzy,
        hadHeadache: _hadHeadache,
        feltNausea: _feltNausea,
      );

      await Future.delayed(const Duration(milliseconds: 800));

      ref.read(bpProvider.notifier).addReading(reading);

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
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
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

                const SizedBox(height: AppDimensions.spacing24),

                // Measurement Time
                Text('Measurement Time', style: AppTextStyles.inputLabel),
                const SizedBox(height: AppDimensions.spacing12),
                Wrap(
                  spacing: AppDimensions.spacing8,
                  runSpacing: AppDimensions.spacing8,
                  children: MeasurementTime.values.map((time) {
                    final isSelected = _selectedTime == time;
                    return ChoiceChip(
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

                // Symptoms Check
                Text('Any symptoms?', style: AppTextStyles.inputLabel),
                const SizedBox(height: AppDimensions.spacing8),
                Text(
                  'all apply for 5 minutes before measuring',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing12),

                CheckboxListTile(
                  title: const Text('Felt dizzy'),
                  value: _feltDizzy,
                  onChanged: (value) =>
                      setState(() => _feltDizzy = value ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppColors.primaryTurquoise,
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  title: const Text('Had headache'),
                  value: _hadHeadache,
                  onChanged: (value) =>
                      setState(() => _hadHeadache = value ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppColors.primaryTurquoise,
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  title: const Text('Felt nausea'),
                  value: _feltNausea,
                  onChanged: (value) =>
                      setState(() => _feltNausea = value ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppColors.primaryTurquoise,
                  contentPadding: EdgeInsets.zero,
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
