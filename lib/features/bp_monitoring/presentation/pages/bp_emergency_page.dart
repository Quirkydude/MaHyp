import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../data/models/bp_reading_model.dart';

/// BP Emergency Alert Page - Critical BP warning
class BPEmergencyPage extends StatefulWidget {
  final BPReadingModel reading;

  const BPEmergencyPage({super.key, required this.reading});

  @override
  State<BPEmergencyPage> createState() => _BPEmergencyPageState();
}

class _BPEmergencyPageState extends State<BPEmergencyPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _shakeAnimation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back button
      child: Scaffold(
        backgroundColor: AppColors.error.withOpacity(0.05),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacing24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Animated Alert Icon
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_shakeAnimation.value, 0),
                      child: Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.error.withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.emergency,
                            size: 70,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: AppDimensions.spacing40),

                // Alert Text
                Text(
                  'Your blood pressure is\ncritically high!',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.error,
                    fontSize: 32,
                  ),
                ),

                const SizedBox(height: AppDimensions.spacing24),

                // BP Reading
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spacing24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusLarge,
                    ),
                    border: Border.all(color: AppColors.error, width: 2),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'BP: ${widget.reading.formattedReading}',
                        style: AppTextStyles.h1.copyWith(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                      ),
                      Text(
                        'Recorded today at ${DateFormat('h:mm a').format(widget.reading.recordedAt)}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.spacing32),

                // Warning Message
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spacing20),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMedium,
                    ),
                    border: Border.all(color: AppColors.warning, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.warning,
                        size: 32,
                      ),
                      const SizedBox(width: AppDimensions.spacing12),
                      Expanded(
                        child: Text(
                          'This is a medical emergency. Seek immediate medical attention.',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Emergency Actions
                CustomButton(
                  text: 'Call Emergency Services',
                  onPressed: () {
                    // TODO: Launch phone dialer with emergency number
                    _showCallDialog();
                  },
                  backgroundColor: AppColors.error,
                  icon: const Icon(Icons.phone, color: AppColors.white),
                ),

                const SizedBox(height: AppDimensions.spacing16),

                CustomButton(
                  text: 'Contact Doctor',
                  onPressed: () {
                    // TODO: Contact doctor
                    _showDoctorDialog();
                  },
                  backgroundColor: AppColors.primaryTurquoise,
                  icon: const Icon(
                    Icons.local_hospital,
                    color: AppColors.white,
                  ),
                ),

                const SizedBox(height: AppDimensions.spacing24),

                TextButton(
                  onPressed: () {
                    context.go('/bp-history');
                  },
                  child: Text(
                    'I\'m seeking medical attention',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.spacing24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCallDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.phone, color: AppColors.error),
            const SizedBox(width: AppDimensions.spacing8),
            const Text('Call Emergency'),
          ],
        ),
        content: const Text(
          'You are about to call emergency services. Do you want to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Launch phone with emergency number (e.g., 911, 999, etc.)
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Call Now'),
          ),
        ],
      ),
    );
  }

  void _showDoctorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.local_hospital, color: AppColors.primaryTurquoise),
            const SizedBox(width: AppDimensions.spacing8),
            const Text('Contact Doctor'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose how to contact your doctor:'),
            const SizedBox(height: AppDimensions.spacing16),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Call Doctor'),
              onTap: () {
                // TODO: Call doctor
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Send Message'),
              onTap: () {
                // TODO: Send message
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
