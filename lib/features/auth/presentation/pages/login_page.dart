import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/social_login_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      await Future.delayed(const Duration(seconds: 2));

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login successful!')));
        context.go(AppRouter.dashboard);
      }
    }
  }

  void _handleForgotPassword() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Forgot password clicked')));
  }

  void _handleSocialLogin(SocialLoginType type) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${type.name} login clicked')));
  }

  void _handleSignUp() {
    context.push('/signup');
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
        title: const Text('Log In'),
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

                Text('Welcome', style: AppTextStyles.h2),
                const SizedBox(height: AppDimensions.spacing8),
                Text(
                  'Welcome Back! Sign back in to your account and take control of your blood pressure.',
                  style: AppTextStyles.bodySmall,
                ),

                const SizedBox(height: AppDimensions.spacing40),

                CustomTextField(
                  label: 'Email or Mobile Number',
                  hint: 'example@example.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: AppColors.primaryTurquoise,
                  ),
                ),

                const SizedBox(height: AppDimensions.spacing24),

                CustomTextField(
                  label: 'Password',
                  hint: '••••••••••••',
                  controller: _passwordController,
                  obscureText: true,
                  showPasswordToggle: true,
                  validator: _validatePassword,
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: AppColors.primaryTurquoise,
                  ),
                ),

                const SizedBox(height: AppDimensions.spacing12),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _handleForgotPassword,
                    child: Text(
                      'Forgot Password?',
                      style: AppTextStyles.link.copyWith(
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.spacing32),

                CustomButton(
                  text: 'Log In',
                  onPressed: _handleLogin,
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
                        'or sign in with',
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
                      "Don't have an account? ",
                      style: AppTextStyles.bodyMedium,
                    ),
                    TextButton(
                      onPressed: _handleSignUp,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Sign Up',
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
