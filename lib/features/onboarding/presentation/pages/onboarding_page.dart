import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/custom_button.dart';

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
            colors: [AppColors.white, AppColors.white],
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
                const Spacer(flex: 2),

                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryTurquoise.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.favorite,
                        size: 70,
                        color: AppColors.white,
                      ),
                      Positioned(
                        right: 20,
                        bottom: 20,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.access_time,
                            size: 28,
                            color: AppColors.primaryTurquoise,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.spacing40),

                SvgPicture.asset(
                  'assets/images/logo.svg',
                  width: AppDimensions.logoMedium,
                  height: AppDimensions.logoMedium,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primaryTurquoise,
                    BlendMode.srcIn,
                  ),
                ),

                const SizedBox(height: AppDimensions.spacing16),

                Text(
                  'MaHyp',
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.primaryTurquoise,
                    fontSize: 36,
                  ),
                ),

                const SizedBox(height: AppDimensions.spacing8),

                Text(
                  'Take control of your blood pressure,\none day at a time.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                const Spacer(flex: 2),

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
