import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../illustrations/illustrations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/custom_button.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _slides = [
    _SlideData(
      title: 'Track Your Blood Pressure',
      subtitle:
          'Record your readings daily and get instant feedback on your heart health — all in one place.',
    ),
    _SlideData(
      title: 'Manage Your Medications',
      subtitle:
          'Never miss a dose. Set reminders, track your schedule, and stay on top of your treatment.',
    ),
    _SlideData(
      title: 'Learn & Stay Informed',
      subtitle:
          'Understand hypertension, learn healthy habits, and connect with your healthcare team.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _slides.length - 1;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF0FDFF), AppColors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button row
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.screenPaddingHorizontal,
                    vertical: AppDimensions.spacing8,
                  ),
                  child: AnimatedOpacity(
                    opacity: isLast ? 0 : 1,
                    duration: const Duration(milliseconds: 200),
                    child: TextButton(
                      onPressed: isLast ? null : () => context.push('/login'),
                      child: Text(
                        'Skip',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Slides
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemCount: _slides.length,
                  itemBuilder: (context, index) =>
                      _OnboardingSlide(index: index, data: _slides[index]),
                ),
              ),

              // Page indicator
              SmoothPageIndicator(
                controller: _pageController,
                count: _slides.length,
                effect: ExpandingDotsEffect(
                  activeDotColor: AppColors.primaryTurquoise,
                  dotColor: AppColors.inputBorder,
                  dotHeight: 8,
                  dotWidth: 8,
                  expansionFactor: 3,
                ),
              ),

              const SizedBox(height: AppDimensions.spacing32),

              // Buttons
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.screenPaddingHorizontal,
                ),
                child: Column(
                  children: [
                    if (isLast) ...[
                      CustomButton(
                        text: 'Get Started',
                        onPressed: () => context.push('/login'),
                      ),
                      const SizedBox(height: AppDimensions.spacing16),
                      CustomButton(
                        text: 'Sign Up',
                        onPressed: () => context.push('/signup'),
                        isOutlined: true,
                      ),
                    ] else ...[
                      CustomButton(text: 'Next', onPressed: _next),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.spacing32),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlideData {
  final String title;
  final String subtitle;
  const _SlideData({required this.title, required this.subtitle});
}

class _OnboardingSlide extends StatelessWidget {
  final int index;
  final _SlideData data;

  const _OnboardingSlide({required this.index, required this.data});

  Widget _illustration() {
    const size = 260.0;
    switch (index) {
      case 0:
        return BloodPressureCheckIllustration(size: size);
      case 1:
        return MedicationReminderIllustration(size: size);
      default:
        return DoctorConsultIllustration(size: size);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingHorizontal,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _illustration(),
          const SizedBox(height: AppDimensions.spacing32),
          SvgPicture.asset('assets/logos/mahyp_full_logo.svg', height: 48),
          const SizedBox(height: AppDimensions.spacing24),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppDimensions.spacing12),
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
