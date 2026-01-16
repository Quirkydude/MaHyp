import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import 'education_page.dart';

/// Education Detail Page - Visual, icon-based learning
class EducationDetailPage extends StatelessWidget {
  final EducationType type;

  const EducationDetailPage({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: _getTitle()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.screenPaddingHorizontal),
        child: Column(
          children: [
            const SizedBox(height: AppDimensions.spacing20),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  String _getTitle() {
    switch (type) {
      case EducationType.hypertension:
        return 'Understanding Hypertension';
      case EducationType.measurement:
        return 'How to Measure BP';
      case EducationType.lifestyle:
        return 'Lifestyle Tips';
      case EducationType.medications:
        return 'Medications Guide';
      case EducationType.treatment:
        return 'Treatment Procedures';
      case EducationType.results:
        return 'Reading Your Results';
    }
  }

  Widget _buildContent() {
    switch (type) {
      case EducationType.hypertension:
        return _buildHypertensionContent();
      case EducationType.measurement:
        return _buildMeasurementContent();
      case EducationType.lifestyle:
        return _buildLifestyleContent();
      case EducationType.medications:
        return _buildMedicationsContent();
      case EducationType.treatment:
        return _buildTreatmentContent();
      case EducationType.results:
        return _buildResultsContent();
    }
  }

  // Understanding Hypertension Content
  Widget _buildHypertensionContent() {
    return Column(
      children: [
        // IMAGE PLACEHOLDER - Heart with pressure indicators
        _buildImagePlaceholder(
          'Heart illustration showing blood vessels with pressure arrows',
          'assets/images/education/heart_pressure.svg',
          height: 200,
        ),

        const SizedBox(height: AppDimensions.spacing24),

        _buildSectionTitle('What is Hypertension?'),
        _buildInfoCard(
          icon: Icons.info_outline,
          color: AppColors.primaryTurquoise,
          text:
              'High blood pressure when blood pushes too hard against artery walls',
        ),

        const SizedBox(height: AppDimensions.spacing16),

        _buildSectionTitle('Why Blood Pressure Matters'),
        _buildVisualGrid([
          _buildIconPoint(
            Icons.favorite_border,
            'Protects\nHeart',
            AppColors.error,
          ),
          _buildIconPoint(Icons.psychology, 'Protects\nBrain', Colors.purple),
          _buildIconPoint(Icons.visibility, 'Protects\nEyes', Colors.blue),
          _buildIconPoint(Icons.kidney, 'Protects\nKidneys', Colors.orange),
        ]),

        const SizedBox(height: AppDimensions.spacing24),

        _buildSectionTitle('Common Causes'),
        _buildVisualList([
          ('restaurant', 'Unhealthy diet', 'Too much salt & processed food'),
          (
            'sports_esports',
            'Lack of exercise',
            'Not enough physical activity',
          ),
          ('smoking_rooms', 'Smoking', 'Damages blood vessels'),
          ('local_bar', 'Alcohol', 'Too much drinking'),
          ('psychology', 'Stress', 'High stress levels'),
        ]),
      ],
    );
  }

  // How to Measure BP Content
  Widget _buildMeasurementContent() {
    return Column(
      children: [
        _buildSectionTitle('Step-by-Step Guide'),

        // IMAGE PLACEHOLDER - Person measuring BP correctly
        _buildImagePlaceholder(
          'Person sitting correctly with BP cuff on arm',
          'assets/images/education/measuring_bp.svg',
          height: 180,
        ),

        const SizedBox(height: AppDimensions.spacing24),

        _buildStepCard(
          1,
          'Rest Quietly',
          'Sit for 5 minutes before measuring',
          Icons.chair,
        ),
        _buildStepCard(
          2,
          'Sit Properly',
          'Back straight, feet flat on floor',
          Icons.event_seat,
        ),
        _buildStepCard(
          3,
          'Arm Position',
          'Keep arm at heart level',
          Icons.accessibility,
        ),
        _buildStepCard(
          4,
          'Stay Still',
          'Don\'t talk or move during reading',
          Icons.volume_off,
        ),
        _buildStepCard(
          5,
          'Take 2 Readings',
          'Wait 1 minute between readings',
          Icons.repeat,
        ),

        const SizedBox(height: AppDimensions.spacing24),

        // Do's and Don'ts
        Row(
          children: [
            Expanded(
              child: _buildDoCard(
                isPositive: true,
                title: 'DO',
                items: ['Rest first', 'Empty bladder', 'Use correct cuff size'],
              ),
            ),
            const SizedBox(width: AppDimensions.spacing12),
            Expanded(
              child: _buildDoCard(
                isPositive: false,
                title: 'DON\'T',
                items: ['Talk', 'Cross legs', 'Take after exercise'],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Lifestyle Tips Content
  Widget _buildLifestyleContent() {
    return Column(
      children: [
        _buildSectionTitle('Healthy Living Tips'),

        // IMAGE PLACEHOLDER - Healthy lifestyle icons
        _buildImagePlaceholder(
          'Illustration with healthy food, exercise, and relaxation',
          'assets/images/education/healthy_lifestyle.svg',
          height: 180,
        ),

        const SizedBox(height: AppDimensions.spacing24),

        _buildLifestyleCard(
          icon: Icons.restaurant_menu,
          color: Colors.green,
          title: 'Eat Healthy',
          tips: [
            '🥗 More fruits & vegetables',
            '🧂 Less salt',
            '🥛 Low-fat dairy',
          ],
        ),

        _buildLifestyleCard(
          icon: Icons.directions_run,
          color: Colors.blue,
          title: 'Stay Active',
          tips: [
            '🚶 Walk 30 minutes daily',
            '🏊 Swimming',
            '🧘 Gentle exercises',
          ],
        ),

        _buildLifestyleCard(
          icon: Icons.local_drink,
          color: Colors.orange,
          title: 'Limit Alcohol',
          tips: [
            '🍺 Max 2 drinks for men',
            '🍷 Max 1 drink for women',
            '💧 Drink more water',
          ],
        ),

        _buildLifestyleCard(
          icon: Icons.smoke_free,
          color: Colors.red,
          title: 'Don\'t Smoke',
          tips: [
            '🚭 Quit smoking',
            '💨 Avoid secondhand smoke',
            '🌱 Breathe fresh air',
          ],
        ),

        _buildLifestyleCard(
          icon: Icons.spa,
          color: Colors.purple,
          title: 'Reduce Stress',
          tips: [
            '🧘 Meditation',
            '😊 Spend time with loved ones',
            '😴 Get enough sleep',
          ],
        ),
      ],
    );
  }

  // Medications Guide Content
  Widget _buildMedicationsContent() {
    return Column(
      children: [
        _buildSectionTitle('Common BP Medications'),

        _buildMedicationCard(
          name: 'ACE Inhibitors',
          icon: '💊',
          how: 'Relax blood vessels',
          examples: 'Lisinopril, Enalapril',
        ),

        _buildMedicationCard(
          name: 'Beta Blockers',
          icon: '💙',
          how: 'Slow heart rate',
          examples: 'Metoprolol, Atenolol',
        ),

        _buildMedicationCard(
          name: 'Diuretics',
          icon: '💧',
          how: 'Remove extra water',
          examples: 'HCTZ, Furosemide',
        ),

        _buildMedicationCard(
          name: 'Calcium Channel Blockers',
          icon: '⚡',
          how: 'Relax blood vessels',
          examples: 'Amlodipine, Nifedipine',
        ),

        const SizedBox(height: AppDimensions.spacing24),

        _buildImportantBox(
          'Always take medications as prescribed by your doctor. Never stop without consulting them.',
        ),
      ],
    );
  }

  // Treatment Procedures Content
  Widget _buildTreatmentContent() {
    return Column(
      children: [
        _buildSectionTitle('Treatment Journey'),

        // IMAGE PLACEHOLDER - Treatment pathway
        _buildImagePlaceholder(
          'Flow diagram showing treatment steps',
          'assets/images/education/treatment_flow.svg',
          height: 200,
        ),

        const SizedBox(height: AppDimensions.spacing24),

        _buildTimelineItem(
          1,
          'Diagnosis',
          'Doctor confirms high BP',
          Icons.local_hospital,
        ),
        _buildTimelineItem(
          2,
          'Lifestyle Changes',
          'Diet & exercise',
          Icons.restaurant,
        ),
        _buildTimelineItem(3, 'Medication', 'If needed', Icons.medication),
        _buildTimelineItem(
          4,
          'Regular Monitoring',
          'Track progress',
          Icons.show_chart,
        ),
        _buildTimelineItem(5, 'Adjust Treatment', 'As needed', Icons.tune),
      ],
    );
  }

  // Reading Results Content
  Widget _buildResultsContent() {
    return Column(
      children: [
        _buildSectionTitle('BP Number Ranges'),

        _buildBPRangeCard(
          range: '<120 / <80',
          category: 'Normal',
          color: AppColors.success,
          icon: '✅',
          description: 'Keep up the good work!',
        ),

        _buildBPRangeCard(
          range: '120-129 / <80',
          category: 'Elevated',
          color: AppColors.warning,
          icon: '⚠️',
          description: 'Watch your lifestyle',
        ),

        _buildBPRangeCard(
          range: '130-139 / 80-89',
          category: 'High Stage 1',
          color: Colors.orange,
          icon: '📊',
          description: 'Medication may be needed',
        ),

        _buildBPRangeCard(
          range: '≥140 / ≥90',
          category: 'High Stage 2',
          color: AppColors.error,
          icon: '🚨',
          description: 'Take medication regularly',
        ),

        _buildBPRangeCard(
          range: '>180 / >120',
          category: 'Crisis',
          color: const Color(0xFFD32F2F),
          icon: '🆘',
          description: 'Seek emergency care!',
        ),
      ],
    );
  }

  // Helper Widgets

  Widget _buildImagePlaceholder(
    String description,
    String assetPath, {
    double height = 200,
  }) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(
          color: AppColors.inputBorder,
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image, size: 60, color: AppColors.textHint),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '📷 IMAGE NEEDED:\n$description',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: AppTextStyles.h3),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppTextStyles.bodyLarge)),
        ],
      ),
    );
  }

  Widget _buildVisualGrid(List<Widget> items) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: items,
    );
  }

  Widget _buildIconPoint(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: color),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisualList(List<(String, String, String)> items) {
    return Column(
      children: items.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryTurquoise.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 24,
                  color: AppColors.primaryTurquoise,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.$2,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      item.$3,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStepCard(
    int step,
    String title,
    String description,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryTurquoise.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$step',
                style: AppTextStyles.h3.copyWith(color: AppColors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, color: AppColors.primaryTurquoise, size: 28),
        ],
      ),
    );
  }

  Widget _buildDoCard({
    required bool isPositive,
    required String title,
    required List<String> items,
  }) {
    final color = isPositive ? AppColors.success : AppColors.error;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Text(title, style: AppTextStyles.h4.copyWith(color: color)),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    isPositive ? Icons.check_circle : Icons.cancel,
                    color: color,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item, style: AppTextStyles.bodyMedium)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLifestyleCard({
    required IconData icon,
    required Color color,
    required String title,
    required List<String> tips,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 12),
              Text(title, style: AppTextStyles.h4),
            ],
          ),
          const SizedBox(height: 12),
          ...tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(tip, style: AppTextStyles.bodyLarge),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationCard({
    required String name,
    required String icon,
    required String how,
    required String examples,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 48)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text('How: $how', style: AppTextStyles.bodyMedium),
                Text(
                  'Examples: $examples',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportantBox(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: AppColors.warning, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    int step,
    String title,
    String description,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$step',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (step < 5)
                Container(
                  width: 2,
                  height: 40,
                  color: AppColors.primaryTurquoise.withOpacity(0.3),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: Row(
                children: [
                  Icon(icon, color: AppColors.primaryTurquoise, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          description,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBPRangeCard({
    required String range,
    required String category,
    required Color color,
    required String icon,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category, style: AppTextStyles.h4.copyWith(color: color)),
                Text(
                  range,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
