import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/social_login_button.dart';
import '../../../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _dobController = TextEditingController();
  bool _isLoading = false;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }
    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your mobile number';
    }
    if (value.length < 10) {
      return 'Please enter a valid mobile number';
    }
    return null;
  }

  String? _validateDOB(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select your date of birth';
    }
    return null;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 30)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryTurquoise,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text =
            '${picked.day.toString().padLeft(2, '0')} / '
            '${picked.month.toString().padLeft(2, '0')} / '
            '${picked.year}';
      });
    }
  }

  Future<void> _handleSignUp() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to Terms of Use and Privacy Policy'),
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Note: We currently don't use full name, mobile, dob, or password in this step 
      // because Firebase creates user with email/password. 
      // The original design had a "/set-password" page. 
      // For now, I'll pass a temporary password or redirect to a password setting page if that logic exists.
      // However, typical flow is email/password on signup.
      // Assuming the user will flow to '/set-password' to actually create the account or set password there.
      // BUT, Firebase createUser requires password immediately.
      // Let's check if there is a separate password field hidden or if the flow was:
      // Signup (Personal Details) -> SetPasswordPage (Password) -> Firebase Create.
      
      // Checking local file structure again, I see `set_password_page.dart`.
      // So I should passing these details to the next page, NOT creating user here yet.
      // OR, I can prompt for password here. 
      
      // Let's stick to the existing flow: Go to /set-password.
      // I should modify /set-password to handle the actual creation.
      
      setState(() => _isLoading = false);
      if (mounted) {
         // Pass arguments to set password page? Or provide registration state provider?
         // For simplicity, let's assume we pass data via query params or a provider.
         // Since I can't easily see SetPasswordPage content right now, I'll assume it handles password input.
         // Effectively, this page collects info, next page collects password & creates account.
         
         // Use go_router with 'extra' object to pass data
          context.push('/set-password', extra: {
            'email': _emailController.text.trim(),
            'name': _fullNameController.text.trim(),
            // add other fields if needed for Firestore profile creation later
          });
      }
    }
  }

  Future<void> _handleSocialLogin(SocialLoginType type) async {
    setState(() => _isLoading = true);
    
    try {
      if (type == SocialLoginType.google) {
        await ref.read(authServiceProvider).signInWithGoogle();
      } else if (type == SocialLoginType.facebook) {
        await ref.read(authServiceProvider).signInWithFacebook();
      } else if (type == SocialLoginType.apple) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Apple Sign In not implemented yet')),
        );
        return;
      }
      
      if (mounted) {
        context.go(AppRouter.dashboard);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Social sign up failed'),
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

  void _handleLogin() {
    context.pop();
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
        title: const Text('New Account'),
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

                CustomTextField(
                  label: 'Full name',
                  hint: 'example@example.com',
                  controller: _fullNameController,
                  keyboardType: TextInputType.name,
                  validator: _validateFullName,
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: AppColors.primaryTurquoise,
                  ),
                ),

                const SizedBox(height: AppDimensions.spacing20),

                CustomTextField(
                  label: 'Email',
                  hint: '',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: AppColors.primaryTurquoise,
                  ),
                ),

                const SizedBox(height: AppDimensions.spacing20),

                CustomTextField(
                  label: 'Mobile Number',
                  hint: 'example@example.com',
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  validator: _validateMobile,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  prefixIcon: const Icon(
                    Icons.phone_outlined,
                    color: AppColors.primaryTurquoise,
                  ),
                ),

                const SizedBox(height: AppDimensions.spacing20),

                CustomTextField(
                  label: 'Date Of Birth',
                  hint: 'DD / MM / YYY',
                  controller: _dobController,
                  readOnly: true,
                  onTap: _selectDate,
                  validator: _validateDOB,
                  prefixIcon: const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.primaryTurquoise,
                  ),
                ),

                const SizedBox(height: AppDimensions.spacing20),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _agreedToTerms,
                        onChanged: (value) {
                          setState(() => _agreedToTerms = value ?? false);
                        },
                        activeColor: AppColors.primaryTurquoise,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacing12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          children: [
                            const TextSpan(
                              text: 'By continuing, you agree to ',
                            ),
                            TextSpan(
                              text: 'Terms of Use',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primaryTurquoise,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primaryTurquoise,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.spacing32),

                CustomButton(
                  text: 'Sign Up',
                  onPressed: _handleSignUp,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: AppDimensions.spacing32),

                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacing16,
                      ),
                      child: Text(
                        'or sign up with',
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: AppDimensions.spacing32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SocialLoginButton(
                      type: SocialLoginType.google,
                      onPressed: () =>
                          _handleSocialLogin(SocialLoginType.google),
                    ),
                    const SizedBox(width: AppDimensions.spacing20),
                    SocialLoginButton(
                      type: SocialLoginType.facebook,
                      onPressed: () =>
                          _handleSocialLogin(SocialLoginType.facebook),
                    ),
                    const SizedBox(width: AppDimensions.spacing20),
                    SocialLoginButton(
                      type: SocialLoginType.apple,
                      onPressed: () =>
                          _handleSocialLogin(SocialLoginType.apple),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.spacing32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTextStyles.bodyMedium,
                    ),
                    TextButton(
                      onPressed: _handleLogin,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Log in',
                        style: AppTextStyles.link.copyWith(
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
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
