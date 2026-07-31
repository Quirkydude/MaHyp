import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

class PrivacyPolicyPage extends ConsumerWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Privacy Policy'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.screenPaddingHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimensions.spacing16),

              Text('Privacy Policy', style: AppTextStyles.h2),

              const SizedBox(height: AppDimensions.spacing8),

              Text(
                'Last Updated: January 2025',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: AppDimensions.spacing24),

              _buildSection(
                'Introduction',
                'MaHyp ("we", "our", or "us") is committed to protecting your privacy. '
                    'This Privacy Policy explains how we collect, use, disclose, and safeguard '
                    'your information when you use our mobile application MaHyp.',
              ),

              _buildSection(
                'Information We Collect',
                'Personal Information:\n'
                    '• Name - To personalize your experience\n'
                    '• Email Address - For account creation and support\n'
                    '• Phone Number - For account verification via OTP\n'
                    '• Date of Birth - To provide age-appropriate health insights\n\n'
                    'Health Information:\n'
                    '• Blood Pressure Readings - Systolic and diastolic values, heart rate, timestamps\n'
                    '• Medication Information - Names, dosages, schedules, adherence logs\n'
                    '• Symptoms - Dizziness, headaches, nausea (if you choose to log them)\n'
                    '• Notes - Optional notes about your health\n\n'
                    'Usage Information:\n'
                    '• App features you use\n'
                    '• Time spent in app\n'
                    '• Device type and operating system\n'
                    '• Crash reports and performance data',
              ),

              _buildSection(
                'How We Use Your Information',
                '1. Provide Core Services:\n'
                    '   • Store and display your blood pressure readings\n'
                    '   • Manage your medication schedules and reminders\n'
                    '   • Generate health insights and reports\n\n'
                    '2. Improve Our App:\n'
                    '   • Analyze usage patterns to improve user experience\n'
                    '   • Fix bugs and optimize performance\n'
                    '   • Develop new features\n\n'
                    '3. Communication:\n'
                    '   • Send important account notifications\n'
                    '   • Respond to your support requests\n'
                    '   • Send medication reminders (if enabled)\n\n'
                    '4. Security:\n'
                    '   • Verify your identity via phone OTP\n'
                    '   • Protect against unauthorized access\n'
                    '   • Monitor for suspicious activity',
              ),

              _buildSection(
                'Data Storage and Security',
                'Storage:\n'
                    '• Your data is stored on Google Firebase (Firestore database)\n'
                    '• Data is encrypted in transit (HTTPS/TLS)\n'
                    '• Data is encrypted at rest (Firebase security)\n'
                    '• OTP codes are temporary and expire after 5 minutes\n\n'
                    'Security Measures:\n'
                    '• Secure authentication (phone verification)\n'
                    '• Encrypted data transmission\n'
                    '• Regular security audits\n'
                    '• Access controls and authentication',
              ),

              _buildSection(
                'Data Sharing',
                'We DO NOT sell your data.\n\n'
                    'We MAY share your data with:\n'
                    '1. Service Providers:\n'
                    '   • Firebase (Google) - for database and authentication\n'
                    '   • Arkesel SMS - for OTP verification only\n'
                    '   • Analytics services (anonymized data)\n\n'
                    '2. Legal Requirements:\n'
                    '   • If required by law or legal process\n'
                    '   • To protect our rights or safety\n'
                    '   • To prevent fraud or security issues\n\n'
                    '3. With Your Consent:\n'
                    '   • If you explicitly authorize sharing\n'
                    '   • For specific purposes you approve',
              ),

              _buildSection(
                'Your Rights',
                'Access and Control:\n'
                    '• View all your data in the app\n'
                    '• Edit your profile information\n'
                    '• Export your health data\n'
                    '• Delete your account and all data\n\n'
                    'Account Deletion:\n'
                    'You can delete your account at any time:\n'
                    '• Go to Settings → Account → Delete Account\n'
                    '• Or email us at: your-support@email.com\n'
                    '• All your data will be permanently deleted within 30 days\n\n'
                    'Data Portability:\n'
                    '• Export your blood pressure history as PDF\n'
                    '• Export medication logs\n'
                    '• Download all your data in JSON format',
              ),

              _buildSection(
                'Children\'s Privacy',
                'MaHyp is not intended for users under 18 years of age. '
                    'We do not knowingly collect information from children under 18.',
              ),

              _buildSection(
                'Changes to This Policy',
                'We may update this privacy policy from time to time. We will notify you of any changes by:\n'
                    '• Posting the new policy in the app\n'
                    '• Sending an email notification\n'
                    '• Updating the "Last Updated" date',
              ),

              _buildSection(
                'Contact Us',
                'If you have questions about this Privacy Policy, please contact us:\n\n'
                    'Email: your-support@email.com\n'
                    'Website: https://your-website.com\n'
                    'Address: [Your Business Address]',
              ),

              const SizedBox(height: AppDimensions.spacing32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h3),
          const SizedBox(height: AppDimensions.spacing12),
          Text(
            content,
            style: AppTextStyles.bodyMedium.copyWith(
              height: 1.6,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
