import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/main_layout.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';

/// Support & Help Page with FAQs and contact options
class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  int? _expandedIndex;

  final List<FAQ> _faqs = [
    FAQ(
      question: 'How do I measure blood pressure correctly?',
      answer:
          'Sit quietly for at least 5 minutes, keep your arm supported at heart level, and avoid talking during measurement.',
      icon: Icons.favorite,
    ),
    FAQ(
      question: 'What do the blood pressure numbers mean?',
      answer:
          'The top number (systolic) measures pressure when your heart beats. The bottom number (diastolic) measures pressure between beats.',
      icon: Icons.info_outline,
    ),
    FAQ(
      question: 'How do I add medications?',
      answer:
          'Go to Medication tab, tap the + button, fill in medication name, dosage, and frequency, then save.',
      icon: Icons.medication,
    ),
    FAQ(
      question: 'What should I do if I miss a dose?',
      answer:
          'Take it as soon as you remember, unless it\'s close to your next dose. Never double up doses. Contact your doctor if unsure.',
      icon: Icons.help_outline,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 4,
      child: Scaffold(
        appBar: const CustomAppBar(
          title: 'Support & Help',
          showBackButton: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.screenPaddingHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimensions.spacing16),

              // FAQs Section
              Text('Frequently Asked Questions', style: AppTextStyles.h3),
              const SizedBox(height: AppDimensions.spacing16),

              // FAQ Items
              ...List.generate(_faqs.length, (index) {
                return _buildFAQItem(_faqs[index], index);
              }),

              const SizedBox(height: AppDimensions.spacing32),

              // Contact Support Section
              Text('Contact Support', style: AppTextStyles.h3),
              const SizedBox(height: AppDimensions.spacing16),

              // Contact Options
              _buildContactCard(
                icon: Icons.message,
                iconColor: AppColors.primaryTurquoise,
                title: 'Message Your Clinician',
                subtitle: 'Send a secure message',
                onTap: _handleMessageClinician,
              ),

              const SizedBox(height: AppDimensions.spacing12),

              _buildContactCard(
                icon: Icons.phone,
                iconColor: AppColors.success,
                title: 'Call Healthcare Provider',
                subtitle: '+233 xxx xxx xxx',
                onTap: _handleCallProvider,
              ),

              const SizedBox(height: AppDimensions.spacing12),

              _buildContactCard(
                icon: Icons.email,
                iconColor: AppColors.warning,
                title: 'Email Support',
                subtitle: 'support@mahyp.com',
                onTap: _handleEmailSupport,
              ),

              const SizedBox(height: AppDimensions.spacing32),

              // Connect to Pharmacist Button
              CustomButton(
                text: 'Connect to Pharmacist',
                onPressed: _handleConnectPharmacist,
                icon: const Icon(Icons.local_pharmacy, color: AppColors.white),
              ),

              const SizedBox(height: AppDimensions.spacing40),

              // App Version
              Center(
                child: Text(
                  'App Version 1.0.0',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacing8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem(FAQ faq, int index) {
    final isExpanded = _expandedIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacing12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: isExpanded
              ? AppColors.primaryTurquoise
              : AppColors.inputBorder,
          width: isExpanded ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedIndex = isExpanded ? null : index;
              });
            },
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacing16),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryTurquoise.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSmall,
                      ),
                    ),
                    child: Icon(
                      faq.icon,
                      color: AppColors.primaryTurquoise,
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: AppDimensions.spacing12),

                  // Question
                  Expanded(
                    child: Text(
                      faq.question,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Expand Icon
                  Icon(
                    isExpanded ? Icons.remove : Icons.add,
                    color: AppColors.primaryTurquoise,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),

          // Answer
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.spacing16,
                0,
                AppDimensions.spacing16,
                AppDimensions.spacing16,
              ),
              child: Text(
                faq.answer,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing16,
          vertical: AppDimensions.spacing8,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }

  void _handleMessageClinician() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.message, color: AppColors.primaryTurquoise),
            const SizedBox(width: AppDimensions.spacing8),
            const Text('Message Clinician'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Type your message here...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessDialog('Message Sent!', 'Your clinician will respond soon.');
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _handleCallProvider() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+233xxxxxxxxx');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      _showErrorMessage('Could not launch phone dialer');
    }
  }

  void _handleEmailSupport() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@mahyp.com',
      query: 'subject=Support Request&body=',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      _showErrorMessage('Could not launch email client');
    }
  }

  void _handleConnectPharmacist() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_pharmacy,
                size: 40,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing20),
            Text('Connect to Pharmacist', style: AppTextStyles.h3),
            const SizedBox(height: AppDimensions.spacing8),
            Text(
              'Get your medications delivered or consult with a pharmacist about your prescriptions.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessDialog('Request Sent!', 'A pharmacist will contact you shortly.');
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }

  /// Shows an animated success dialog with bouncing checkmark.
  /// Provides clear visual confirmation for elderly users.
  void _showSuccessDialog(String title, String message) {
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
            Text(title, style: AppTextStyles.h3),
            const SizedBox(height: AppDimensions.spacing8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTurquoise,
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacing16),
              ),
              child: const Text('Done', style: TextStyle(color: AppColors.white)),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// FAQ Model
class FAQ {
  final String question;
  final String answer;
  final IconData icon;

  FAQ({required this.question, required this.answer, required this.icon});
}
