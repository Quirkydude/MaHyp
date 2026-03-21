import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_profile_provider.dart';

class SetPasswordPage extends ConsumerStatefulWidget {
  final String? email;
  final String? fullName;
  final String? mobile;
  final DateTime? dob;

  const SetPasswordPage({
    super.key, 
    this.email,
    this.fullName,
    this.mobile,
    this.dob,
  });

  @override
  ConsumerState<SetPasswordPage> createState() => _SetPasswordPageState();
}

class _SetPasswordPageState extends ConsumerState<SetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain an uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain a lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain a number';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain a special character';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _handleCreatePassword() async {
    if (_formKey.currentState!.validate()) {
      // Validate that we received the necessary info from previous page
      if (widget.email == null || widget.email!.isEmpty) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Missing email address. Please sign up again.')),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        // Create user with email and password
        final userCredential = await ref.read(authServiceProvider).createUserWithEmailAndPassword(
          widget.email!,
          _passwordController.text,
        );
        
        // Save user profile to Firestore
        if (userCredential.user != null) {
          await ref.read(userProfileServiceProvider).createUserProfile(
            uid: userCredential.user!.uid,
            fullName: widget.fullName ?? '',
            email: widget.email!,
            mobile: widget.mobile,
            dob: widget.dob,
          );
          
          // Update display name on Firebase Auth user
          if (widget.fullName != null) {
            await userCredential.user!.updateDisplayName(widget.fullName);
          }

          // Send email verification
          await ref.read(authServiceProvider).sendEmailVerification();
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created! Please verify your email.')),
          );
          // Navigate to email verification
          context.go(AppRouter.emailVerification);
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          String message = 'Registration failed';
          if (e.code == 'weak-password') {
            message = 'The password provided is too weak.';
          } else if (e.code == 'email-already-in-use') {
            message = 'The account already exists for that email.';
          } else {
             message = e.message ?? 'Registration error';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An unexpected error occurred: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Widget _buildPasswordRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.cancel,
            size: 18,
            color: isMet ? AppColors.success : AppColors.textHint,
          ),
          const SizedBox(width: AppDimensions.spacing8),
          Text(
            text,
            style: AppTextStyles.caption.copyWith(
              color: isMet ? AppColors.success : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final password = _passwordController.text;
    final hasMinLength = password.length >= 8;
    final hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    final hasLowerCase = password.contains(RegExp(r'[a-z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryTurquoise,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Set Password'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.screenPaddingHorizontal),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppDimensions.spacing16),

                Center(
                  child: SvgPicture.asset(
                    'assets/logos/mahyp_full_logo.svg',
                    height: 80,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing24),

                Text(
                  'Please create a secure password for your account linked to ${widget.email ?? "your email"}.',
                  style: AppTextStyles.bodySmall,
                ),

                const SizedBox(height: AppDimensions.spacing40),

                CustomTextField(
                  label: 'Password',
                  hint: '••••••••••••',
                  controller: _passwordController,
                  obscureText: true,
                  showPasswordToggle: true,
                  validator: _validatePassword,
                  onChanged: (_) => setState(() {}),
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: AppColors.primaryTurquoise,
                  ),
                ),

                const SizedBox(height: AppDimensions.spacing16),

                Container(
                  padding: const EdgeInsets.all(AppDimensions.spacing16),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMedium,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password must contain:',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacing8),
                      _buildPasswordRequirement(
                        'At least 8 characters',
                        hasMinLength,
                      ),
                      _buildPasswordRequirement(
                        'One uppercase letter',
                        hasUpperCase,
                      ),
                      _buildPasswordRequirement(
                        'One lowercase letter',
                        hasLowerCase,
                      ),
                      _buildPasswordRequirement('One number', hasNumber),
                      _buildPasswordRequirement(
                        'One special character (!@#\$%^&*)',
                        hasSpecialChar,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.spacing24),

                CustomTextField(
                  label: 'Confirm Password',
                  hint: '••••••••••••',
                  controller: _confirmPasswordController,
                  obscureText: true,
                  showPasswordToggle: true,
                  validator: _validateConfirmPassword,
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: AppColors.primaryTurquoise,
                  ),
                ),

                const SizedBox(height: AppDimensions.spacing40),

                CustomButton(
                  text: 'Create New Account',
                  onPressed: _handleCreatePassword,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: AppDimensions.spacing24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
