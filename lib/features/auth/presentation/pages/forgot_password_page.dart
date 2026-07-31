import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/email_validator.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../providers/auth_provider.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) => EmailValidator.validate(value);

  Future<void> _handleSendResetLink() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await ref.read(authServiceProvider).sendPasswordResetEmail(
          _emailController.text.trim(),
        );

        if (mounted) {
          setState(() {
            _emailSent = true;
            _isLoading = false;
          });
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          String message = 'Failed to send reset email';
          if (e.code == 'user-not-found') {
            message = 'No account found with that email address.';
          } else if (e.code == 'invalid-email') {
            message = 'The email address is not valid.';
          } else {
            message = e.message ?? 'An error occurred';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppColors.error,
            ),
          );
          setState(() => _isLoading = false);
        }
      } catch (e) {
        debugPrint('Forgot password unexpected error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('An unexpected error occurred. Please try again.'),
              backgroundColor: AppColors.error,
            ),
          );
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryTurquoise,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Forgot Password'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.screenPaddingHorizontal),
          child: _emailSent ? _buildSuccessState() : _buildFormState(),
        ),
      ),
    );
  }

  Widget _buildFormState() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppDimensions.spacing32),

          // Logo
          Center(
            child: SvgPicture.asset(
              'assets/logos/mahyp_full_logo.svg',
              height: 80,
            ),
          ),

          const SizedBox(height: AppDimensions.spacing32),

          Text('Reset Your Password', style: AppTextStyles.h2),
          const SizedBox(height: AppDimensions.spacing12),
          Text(
            'Enter your email address and we\'ll send you a link to reset your password.',
            style: AppTextStyles.bodySmall,
          ),

          const SizedBox(height: AppDimensions.spacing40),

          CustomTextField(
            label: 'Email Address',
            hint: 'example@example.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
            prefixIcon: const Icon(
              Icons.email_outlined,
              color: AppColors.primaryTurquoise,
            ),
          ),

          const SizedBox(height: AppDimensions.spacing32),

          CustomButton(
            text: 'Send Reset Link',
            onPressed: _handleSendResetLink,
            isLoading: _isLoading,
          ),

          const SizedBox(height: AppDimensions.spacing24),

          // Back to login
          Center(
            child: TextButton(
              onPressed: () => context.pop(),
              child: Text(
                'Back to Login',
                style: AppTextStyles.link.copyWith(
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: AppDimensions.spacing40),

        // Success icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            size: 50,
            color: AppColors.success,
          ),
        ),

        const SizedBox(height: AppDimensions.spacing32),

        Text(
          'Check Your Email',
          style: AppTextStyles.h2,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.spacing16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing16),
          child: Text(
            'We\'ve sent a password reset link to:',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppDimensions.spacing8),
        Text(
          _emailController.text.trim(),
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryTurquoise,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.spacing16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing16),
          child: Text(
            'Please check your inbox and follow the instructions in the email to reset your password.',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: AppDimensions.spacing40),

        CustomButton(
          text: 'Back to Login',
          onPressed: () => context.go('/login'),
        ),

        const SizedBox(height: AppDimensions.spacing16),

        // Resend option
        TextButton(
          onPressed: () {
            setState(() => _emailSent = false);
          },
          child: Text(
            'Didn\'t receive the email? Try again',
            style: AppTextStyles.link.copyWith(
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }
}
