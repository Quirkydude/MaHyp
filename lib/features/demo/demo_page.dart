import 'package:flutter/material.dart';
import '../../shared/widgets/main_layout.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/tab_selector.dart';
import '../../shared/widgets/medication_card.dart';
import '../../shared/widgets/frequency_chip.dart';
import '../../core/constants/app_dimensions.dart';

/// Demo page to test shared components
class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  int _selectedTab = 0;
  int _selectedFrequency = 0;

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 2, // Medication tab
      child: Scaffold(
        appBar: const CustomAppBar(
          title: 'Shared Components Demo',
          showBackButton: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.screenPaddingHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimensions.spacing20),

              // Tab Selector Demo
              const Text(
                'Tab Selector:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppDimensions.spacing12),
              TabSelector(
                tabs: const ['Today', 'Upcoming'],
                selectedIndex: _selectedTab,
                onTabSelected: (index) {
                  setState(() => _selectedTab = index);
                },
              ),

              const SizedBox(height: AppDimensions.spacing32),

              // Medication Cards Demo
              const Text(
                'Medication Cards:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppDimensions.spacing12),

              MedicationCard(
                name: 'Amlodipine',
                dosage: '10mg',
                frequency: 'Once daily',
                nextDose: '8:00 AM',
                status: MedicationStatus.upcoming,
                onTap: () {},
              ),

              MedicationCard(
                name: 'Lisinopril',
                dosage: '10mg',
                frequency: 'Once daily',
                nextDose: '4:00 PM',
                status: MedicationStatus.taken,
                onTap: () {},
              ),

              MedicationCard(
                name: 'HCTZ',
                dosage: '10mg',
                frequency: 'Once daily',
                nextDose: '8:00 AM',
                status: MedicationStatus.missed,
                onTap: () {},
              ),

              const SizedBox(height: AppDimensions.spacing32),

              // Frequency Chips Demo
              const Text(
                'Frequency Chips:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppDimensions.spacing12),

              Wrap(
                spacing: AppDimensions.spacing12,
                runSpacing: AppDimensions.spacing12,
                children: [
                  FrequencyChip(
                    label: 'Once daily',
                    isSelected: _selectedFrequency == 0,
                    onTap: () => setState(() => _selectedFrequency = 0),
                  ),
                  FrequencyChip(
                    label: 'Twice daily',
                    isSelected: _selectedFrequency == 1,
                    onTap: () => setState(() => _selectedFrequency = 1),
                  ),
                  FrequencyChip(
                    label: 'Thrice daily',
                    isSelected: _selectedFrequency == 2,
                    onTap: () => setState(() => _selectedFrequency = 2),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.spacing40),
            ],
          ),
        ),
      ),
    );
  }
}
