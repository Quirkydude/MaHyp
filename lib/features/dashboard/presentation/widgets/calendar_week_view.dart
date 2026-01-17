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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month selector row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onMonthPressed,
                child: Row(
                  children: [
                    Text(
                      monthName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onCalendarPressed,
                icon: const Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Week days row
        SizedBox(
          height: 70,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: weekDates.length,
            itemBuilder: (context, index) {
              final date = weekDates[index];
              final isSelected = _isSameDay(date, selectedDate);
              return _buildDayItem(date, isSelected);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDayItem(DateTime date, bool isSelected) {
    final dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final dayName = dayNames[date.weekday % 7];

    return GestureDetector(
      onTap: () => onDateSelected?.call(date),
      child: Container(
        width: 48,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.calendarSelected : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.calendarSelected : AppColors.calendarUnselected,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayName,
              style: TextStyle(
                color: isSelected ? AppColors.white : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date.day.toString(),
              style: TextStyle(
                color: isSelected ? AppColors.white : AppColors.textPrimary,
                fontSize: 18,
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
