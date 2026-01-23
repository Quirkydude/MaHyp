import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CalendarWeekView extends StatelessWidget {
  final DateTime selectedDate;
  final String monthName;
  final ValueChanged<DateTime>? onDateSelected;
  final VoidCallback? onMonthPressed;
  final VoidCallback? onCalendarPressed;

  const CalendarWeekView({
    super.key,
    required this.selectedDate,
    required this.monthName,
    this.onDateSelected,
    this.onMonthPressed,
    this.onCalendarPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Generate dates for the week
    final weekDates = _getWeekDates(selectedDate);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.calendarBackground,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with "Upcoming Schedule" and Month
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Upcoming Schedule',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: onMonthPressed,
                child: Row(
                  children: [
                    Text(
                      monthName,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Week days row with navigation
          Row(
            children: [
              // Left arrow
              GestureDetector(
                onTap: () => _navigateWeek(-7),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Week dates
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: weekDates.map((date) {
                    final isSelected = _isSameDay(date, selectedDate);
                    final isToday = _isSameDay(date, DateTime.now());
                    return _buildDayItem(date, isSelected, isToday);
                  }).toList(),
                ),
              ),
              const SizedBox(width: 8),
              // Right arrow
              GestureDetector(
                onTap: () => _navigateWeek(7),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateWeek(int days) {
    final newDate = selectedDate.add(Duration(days: days));
    onDateSelected?.call(newDate);
  }

  Widget _buildDayItem(DateTime date, bool isSelected, bool isToday) {
    final dayNames = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    final dayName = dayNames[date.weekday % 7];

    return GestureDetector(
      onTap: () => onDateSelected?.call(date),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 42,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.calendarSelected : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: isToday && !isSelected
              ? Border.all(color: AppColors.calendarSelected, width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayName,
              style: TextStyle(
                color: isSelected ? AppColors.white : AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              date.day.toString(),
              style: TextStyle(
                color: isSelected
                    ? AppColors.white
                    : (isToday ? AppColors.calendarSelected : AppColors.textPrimary),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DateTime> _getWeekDates(DateTime date) {
    // Get the Sunday of the current week
    final sunday = date.subtract(Duration(days: date.weekday % 7));
    return List.generate(7, (index) => sunday.add(Duration(days: index)));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

