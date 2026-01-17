import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/main_layout.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

/// Patient Education Page - Visual learning for elderly
class EducationPage extends StatelessWidget {
  const EducationPage({super.key});

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

              // Education Topics Grid
              _buildTopicCard(
                context: context,
                icon: Icons.favorite,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
                ),
                title: 'Understanding\nHypertension',
                subtitle: 'Learn about high blood pressure',
                route: '/education-detail',
                type: EducationType.hypertension,
              ),

              _buildTopicCard(
                context: context,
                icon: Icons.monitor_heart,
                gradient: const LinearGradient(
                  colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                ),
                title: 'How to Measure\nBlood Pressure',
                subtitle: 'Step-by-step guide',
                route: '/education-detail',
                type: EducationType.measurement,
              ),

              _buildTopicCard(
                context: context,
                icon: Icons.restaurant,
                gradient: const LinearGradient(
                  colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
                ),
                title: 'Lifestyle Tips',
                subtitle: 'Diet, exercise & stress management',
                route: '/education-detail',
                type: EducationType.lifestyle,
              ),

              _buildTopicCard(
                context: context,
                icon: Icons.medication,
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                title: 'Medications Guide',
                subtitle: 'Understanding your medications',
                route: '/education-detail',
                type: EducationType.medications,
              ),

              _buildTopicCard(
                context: context,
                icon: Icons.healing,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFA751), Color(0xFFFFE259)],
                ),
                title: 'Treatment Procedures',
                subtitle: 'What to expect from treatments',
                route: '/education-detail',
                type: EducationType.treatment,
              ),

              _buildTopicCard(
                context: context,
                icon: Icons.show_chart,
                gradient: const LinearGradient(
                  colors: [Color(0xFF00D2FF), Color(0xFF3A7BD5)],
                ),
                title: 'Reading Your Results',
                subtitle: 'Understanding BP numbers',
                route: '/education-detail',
                type: EducationType.results,
              ),

              const SizedBox(height: AppDimensions.spacing64 + AppDimensions.spacing16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopicCard({
    required BuildContext context,
    required IconData icon,
    required Gradient gradient,
    required String title,
    required String subtitle,
    required String route,
    required EducationType type,
  }) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(route, extra: type),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
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

enum EducationType {
  hypertension,
  measurement,
  lifestyle,
  medications,
  treatment,
  results,
}
