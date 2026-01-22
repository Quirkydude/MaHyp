import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/main_layout.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

/// Patient Education Page - Visual learning for elderly.
/// Includes staggered entrance animations and press feedback for topic cards.
class EducationPage extends StatefulWidget {
  const EducationPage({super.key});

  @override
  State<EducationPage> createState() => _EducationPageState();
}

class _EducationPageState extends State<EducationPage> {
  // Track which card is currently pressed for animation feedback
  EducationType? _pressedCard;

  // Define topics data for building the list with animations
  final List<_TopicData> _topics = const [
    _TopicData(
      icon: Icons.favorite,
      gradient: LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)]),
      title: 'Understanding\nHypertension',
      subtitle: 'Learn about high blood pressure',
      type: EducationType.hypertension,
    ),
    _TopicData(
      icon: Icons.monitor_heart,
      gradient: LinearGradient(colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)]),
      title: 'How to Measure\nBlood Pressure',
      subtitle: 'Step-by-step guide',
      type: EducationType.measurement,
    ),
    _TopicData(
      icon: Icons.restaurant,
      gradient: LinearGradient(colors: [Color(0xFFF093FB), Color(0xFFF5576C)]),
      title: 'Lifestyle Tips',
      subtitle: 'Diet, exercise & stress management',
      type: EducationType.lifestyle,
    ),
    _TopicData(
      icon: Icons.medication,
      gradient: LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
      title: 'Medications Guide',
      subtitle: 'Understanding your medications',
      type: EducationType.medications,
    ),
    _TopicData(
      icon: Icons.healing,
      gradient: LinearGradient(colors: [Color(0xFFFFA751), Color(0xFFFFE259)]),
      title: 'Treatment Procedures',
      subtitle: 'What to expect from treatments',
      type: EducationType.treatment,
    ),
    _TopicData(
      icon: Icons.show_chart,
      gradient: LinearGradient(colors: [Color(0xFF00D2FF), Color(0xFF3A7BD5)]),
      title: 'Reading Your Results',
      subtitle: 'Understanding BP numbers',
      type: EducationType.results,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 3,
      child: Scaffold(
        appBar: const CustomAppBar(
          title: 'Patient Education',
          showBackButton: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.screenPaddingHorizontal),
          child: Column(
            children: [
              const SizedBox(height: AppDimensions.spacing16),

              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search Health Topics',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.primaryTurquoise,
                  ),
                  filled: true,
                  fillColor: AppColors.inputBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMedium,
                    ),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacing24),

              // Education Topics with staggered animations
              ...List.generate(_topics.length, (index) {
                final topic = _topics[index];
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 400 + (index * 80)),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: _buildTopicCard(
                    icon: topic.icon,
                    gradient: topic.gradient,
                    title: topic.title,
                    subtitle: topic.subtitle,
                    type: topic.type,
                  ),
                );
              }),

              const SizedBox(height: AppDimensions.spacing64 + AppDimensions.spacing16),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a topic card with press animation for elderly-friendly touch feedback.
  Widget _buildTopicCard({
    required IconData icon,
    required Gradient gradient,
    required String title,
    required String subtitle,
    required EducationType type,
  }) {
    final isPressed = _pressedCard == type;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressedCard = type),
      onTapUp: (_) {
        setState(() => _pressedCard = null);
        context.push('/education-detail', extra: type);
      },
      onTapCancel: () => setState(() => _pressedCard = null),
      child: AnimatedScale(
        scale: isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppDimensions.spacing16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.spacing20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            ),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMedium,
                    ),
                  ),
                  child: Icon(icon, size: 36, color: AppColors.white),
                ),

                const SizedBox(width: AppDimensions.spacing16),

                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacing4),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Internal data class for topic configuration
class _TopicData {
  final IconData icon;
  final Gradient gradient;
  final String title;
  final String subtitle;
  final EducationType type;

  const _TopicData({
    required this.icon,
    required this.gradient,
    required this.title,
    required this.subtitle,
    required this.type,
  });
}

enum EducationType {
  hypertension,
  measurement,
  lifestyle,
  medications,
  treatment,
  results,
}
