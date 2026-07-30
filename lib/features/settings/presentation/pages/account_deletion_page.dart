import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';

class AccountDeletionPage extends ConsumerStatefulWidget {
  const AccountDeletionPage({super.key});

  @override
  ConsumerState<AccountDeletionPage> createState() => _AccountDeletionPageState();
}

class _AccountDeletionPageState extends ConsumerState<AccountDeletionPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _isConfirmed = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleDeleteAccount() async {
    if (!_isConfirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please confirm that you understand this action is irreversible'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Account?'),
          content: const Text(
            'This will permanently delete all your data including:\n\n'
            '• All blood pressure readings\n'
            '• All medication data\n'
            '• Your profile information\n'
            '• All health insights\n\n'
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmed != true) {
        setState(() => _isLoading = false);
        return;
      }

      // Delete user data from Firestore
      // Note: You'll need to implement this in your user_profile_service
      // await ref.read(userProfileServiceProvider).deleteUserData(user.uid);

      // Delete Firebase Auth user
      await user.delete();

      if (mounted) {
        // Show success message
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            icon: Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 64,
            ),
            title: const Text('Account Deleted'),
            content: const Text(
              'Your account and all associated data have been permanently deleted.\n\n'
              'We\'re sorry to see you go.',
            ),
            actions: [
              CustomButton(
                text: 'OK',
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  // Navigate to login or splash
                  context.go('/');
                },
              ),
            ],
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      
      String message = 'Failed to delete account';
      if (e.code == 'requires-recent-login') {
        message = 'Please re-login to delete your account. This is a security measure.';
      } else if (e.code == 'network-request-failed') {
        message = 'Network error. Please check your connection and try again.';
      } else {
        message = e.message ?? 'Failed to delete account';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An unexpected error occurred. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    if (value.length < 10) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Delete Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.screenPaddingHorizontal),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppDimensions.spacing24),

                // Warning Icon
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.warning_rounded,
                      size: 50,
                      color: AppColors.error,
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.spacing24),

                // Warning Title
                Text(
                  'Delete Your Account',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.error,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppDimensions.spacing16),

                // Warning Message
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spacing16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.error,
                            size: 20,
                          ),
                          const SizedBox(width: AppDimensions.spacing8),
                          Text(
                            'This action is permanent and cannot be undone',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spacing12),
                      Text(
                        'When you delete your account, the following will be permanently removed:',
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: AppDimensions.spacing8),
                      Text(
                        '✓ All blood pressure readings and history\n'
                        '✓ All medication data and schedules\n'
                        '✓ Your profile information\n'
                        '✓ Health insights and reports\n'
                        '✓ All reminders and notifications',
                        style: AppTextStyles.bodyMedium.copyWith(
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.spacing24),

                // Confirmation Checkbox
                CheckboxListTile(
                  value: _isConfirmed,
                  onChanged: (value) {
                    setState(() => _isConfirmed = value ?? false);
                  },
                  activeColor: AppColors.error,
                  title: Text(
                    'I understand that this action is irreversible',
                    style: AppTextStyles.bodyMedium,
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),

                const SizedBox(height: AppDimensions.spacing24),

                // Phone Verification
                Text(
                  'Verify your identity',
                  style: AppTextStyles.inputLabel,
                ),
                const SizedBox(height: AppDimensions.spacing8),
                Text(
                  'Enter your phone number to confirm account deletion',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing12),

                CustomTextField(
                  label: 'Phone Number',
                  hint: 'e.g., 0241234567',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: _validatePhone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  prefixIcon: const Icon(
                    Icons.phone_outlined,
                    color: AppColors.error,
                  ),
                ),

                const SizedBox(height: AppDimensions.spacing32),

                // Delete Button
                CustomButton(
                  text: 'Permanently Delete Account',
                  onPressed: _isLoading ? null : _handleDeleteAccount,
                  isLoading: _isLoading,
                  backgroundColor: AppColors.error,
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
    );
  }
}