import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';

class CalendarWeekView extends StatefulWidget {
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
  State<CalendarWeekView> createState() => _CalendarWeekViewState();
}

class _CalendarWeekViewState extends State<CalendarWeekView> {
  @override
  Widget build(BuildContext context) {
    // Generate dates for the week
    final weekDates = _getWeekDates(widget.selectedDate);
    // Get month from selected date dynamically
    final currentMonthName = DateFormat('MMMM').format(widget.selectedDate);

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
                onTap: () => _showMonthPicker(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentMonthName,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: AppColors.primaryTurquoise,
                      ),
                    ],
                  ),
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
                    final isSelected = _isSameDay(date, widget.selectedDate);
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

  void _showMonthPicker(BuildContext context) {
    final now = DateTime.now();
    final months = <String>[];
    final monthDates = <DateTime>[];
    
    // Generate 12 months (6 past + current + 5 future)
    for (int i = -6; i <= 5; i++) {
      final date = DateTime(now.year, now.month + i, 1);
      months.add(DateFormat('MMMM yyyy').format(date));
      monthDates.add(date);
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.inputBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select Month',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: months.length,
                itemBuilder: (context, index) {
                  final isSelected = widget.selectedDate.month == monthDates[index].month &&
                      widget.selectedDate.year == monthDates[index].year;
                  return ListTile(
                    title: Text(
                      months[index],
                      style: TextStyle(
                        color: isSelected ? AppColors.primaryTurquoise : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: AppColors.primaryTurquoise)
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to the 1st of the selected month
                      widget.onDateSelected?.call(monthDates[index]);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _navigateWeek(int days) {
    final newDate = widget.selectedDate.add(Duration(days: days));
    widget.onDateSelected?.call(newDate);
  }

  Widget _buildDayItem(DateTime date, bool isSelected, bool isToday) {
    final dayNames = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    final dayName = dayNames[date.weekday % 7];

    return GestureDetector(
      onTap: () => widget.onDateSelected?.call(date),
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
