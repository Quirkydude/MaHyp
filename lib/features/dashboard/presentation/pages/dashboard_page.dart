import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/main_layout.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/greeting_section.dart';
import '../widgets/stat_card.dart';
import '../widgets/action_card.dart';
import '../widgets/calendar_week_view.dart';
import '../widgets/task_item.dart';
import '../widgets/task_item.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DateTime _selectedDate = DateTime.now();
  bool _task1Completed = true;
  bool _task2Completed = false;

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 0,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            // Header
            const DashboardHeader(title: 'Dashboard'),
            
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting Section
                    const GreetingSection(
                      userName: 'Jane Doe',
                      avatarUrl: null,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Stat Cards Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          StatCard(
                            type: StatCardType.bp,
                            title: 'Latest BP',
                            value: '120/80 MHG',
                            subtitle: 'Today, 8:30 AM',
                            onTap: () {},
                          ),
                          const SizedBox(width: 12),
                          StatCard(
                            type: StatCardType.medication,
                            title: 'Medication\nAdherance',
                            value: '85%',
                            subtitle: 'This Week',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Action Cards Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          ActionCard(
                            type: ActionCardType.nextMedication,
                            medicationName: 'Amlodipine',
                            medicationTime: 'Today At 6:00 PM',
                            onTap: () {},
                          ),
                          const SizedBox(width: 12),
                          ActionCard(
                            type: ActionCardType.recordBp,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Today's Task Section
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Today's Task",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Calendar Week View
                    CalendarWeekView(
                      selectedDate: _selectedDate,
                      monthName: _getMonthName(_selectedDate),
                      onDateSelected: (date) {
                        setState(() {
                          _selectedDate = date;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Task Items
                    TaskItem(
                      time: '8:00 AM',
                      title: 'Take Amlodipine (100mg)',
                      icon: Icons.medication,
                      iconColor: AppColors.primaryTurquoise,
                      isCompleted: _task1Completed,
                      onCheckChanged: (value) {
                        setState(() {
                          _task1Completed = value ?? false;
                        });
                      },
                    ),
                    TaskItem(
                      time: '9:30 AM',
                      title: 'Record Blood Pressure',
                      icon: Icons.favorite,
                      iconColor: AppColors.primaryTurquoise,
                      isCompleted: _task2Completed,
                      onCheckChanged: (value) {
                        setState(() {
                          _task2Completed = value ?? false;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[date.month - 1];
  }
}
