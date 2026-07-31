import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

/// Home, Health, Medication, Education, Support
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    _NavItemData(
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
    ),
    _NavItemData(
      label: 'Health',
      icon: Icons.favorite_outline,
      activeIcon: Icons.favorite,
    ),
    _NavItemData(
      label: 'Medication',
      icon: Icons.medication_outlined,
      activeIcon: Icons.medication,
    ),
    _NavItemData(
      label: 'Education',
      icon: Icons.school_outlined,
      activeIcon: Icons.school,
    ),
    _NavItemData(
      label: 'Support',
      icon: Icons.help_outline,
      activeIcon: Icons.help,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E1E1E)
            : AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacing8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final isActive = currentIndex == index;

              if (index == 0) {
                // Home tab uses SVG logo
                return Expanded(
                  child: _PillNavItem(
                    label: item.label,
                    isActive: isActive,
                    onTap: () => onTap(index),
                    child: SvgPicture.asset(
                      'assets/logos/mahyp_icon.svg',
                      colorFilter: ColorFilter.mode(
                        isActive
                            ? AppColors.primaryTurquoise
                            : AppColors.textSecondary,
                        BlendMode.srcIn,
                      ),
                      width: AppDimensions.iconMedium,
                      height: AppDimensions.iconMedium,
                    ),
                  ),
                );
              }

              return Expanded(
                child: _PillNavItem(
                  label: item.label,
                  isActive: isActive,
                  onTap: () => onTap(index),
                  child: Icon(
                    isActive ? item.activeIcon : item.icon,
                    color: isActive
                        ? AppColors.primaryTurquoise
                        : AppColors.textSecondary,
                    size: AppDimensions.iconMedium,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  const _NavItemData({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}

/// A nav item that shows an animated teal pill behind it when active.
class _PillNavItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Widget child;

  const _PillNavItem({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spacing8,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryTurquoise.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            child,
            const SizedBox(height: AppDimensions.spacing4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.normal,
                color: isActive
                    ? AppColors.primaryTurquoise
                    : AppColors.textSecondary,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
