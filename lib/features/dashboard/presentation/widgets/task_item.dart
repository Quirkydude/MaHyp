import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Task item widget with elderly-friendly animations.
/// Features: subtle scale on press, animated checkmark on completion,
/// and smooth background color transition for clear feedback.
class TaskItem extends StatefulWidget {
  final String time;
  final String title;
  final IconData icon;
  final Color iconColor;
  final bool isCompleted;
  final VoidCallback? onTap;
  final ValueChanged<bool?>? onCheckChanged;

  const TaskItem({
    super.key,
    required this.time,
    required this.title,
    required this.icon,
    this.iconColor = AppColors.primaryTurquoise,
    this.isCompleted = false,
    this.onTap,
    this.onCheckChanged,
  });

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _checkAnimationController;
  late Animation<double> _checkScaleAnimation;

  @override
  void initState() {
    super.initState();
    // Animation controller for checkmark completion animation
    _checkAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _checkScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _checkAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Set initial animation state based on completion status
    if (widget.isCompleted) {
      _checkAnimationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(TaskItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Animate when completion status changes
    if (widget.isCompleted && !oldWidget.isCompleted) {
      _checkAnimationController.forward();
    } else if (!widget.isCompleted && oldWidget.isCompleted) {
      _checkAnimationController.reverse();
    }
  }

  @override
  void dispose() {
    _checkAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Time
          SizedBox(
            width: 60,
            child: Text(
              widget.time,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Task card with press animation
          Expanded(
            child: GestureDetector(
              onTapDown: widget.onTap != null
                  ? (_) => setState(() => _isPressed = true)
                  : null,
              onTapUp: widget.onTap != null
                  ? (_) {
                      setState(() => _isPressed = false);
                      widget.onTap?.call();
                    }
                  : null,
              onTapCancel: widget.onTap != null
                  ? () => setState(() => _isPressed = false)
                  : null,
              child: AnimatedScale(
                scale: _isPressed ? 0.97 : 1.0,
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeInOut,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    // Animated background: subtle green tint when completed
                    color: widget.isCompleted
                        ? AppColors.success.withValues(alpha: 0.08)
                        : AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: widget.isCompleted
                          ? AppColors.success.withValues(alpha: 0.3)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: widget.iconColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.iconColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Title
                      Expanded(
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            decoration: widget.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                      // Animated Checkbox with scale animation
                      ScaleTransition(
                        scale: _checkScaleAnimation,
                        child: Checkbox(
                          value: widget.isCompleted,
                          onChanged: widget.onCheckChanged,
                          activeColor: AppColors.success,
                          checkColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
