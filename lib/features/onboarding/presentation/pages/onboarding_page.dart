import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../illustrations/illustrations.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0FDFF),
              AppColors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.screenPaddingHorizontal,
              vertical: AppDimensions.screenPaddingVertical,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),

                const WelcomeIllustration(size: 260),
                
                const Spacer(flex: 2),

                SvgPicture.asset(
                  'assets/logos/mahyp_full_logo.svg',
                  height: 60,
                ),

                const SizedBox(height: AppDimensions.spacing24),

                Text(
                  'Take control of your blood pressure,\none day at a time.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),

                const Spacer(flex: 3),

                CustomButton(
                  text: 'Log In',
                  onPressed: () => context.push('/login'),
                ),

                const SizedBox(height: AppDimensions.spacing16),

                CustomButton(
                  text: 'Sign Up',
                  onPressed: () => context.push('/signup'),
                  isOutlined: true,
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

