import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

/// Home, Health, Medication, Education, More
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
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
            children: [
              _NavBarItem(
                svgPath: 'assets/logos/mahyp_icon.svg',
                label: 'Home',
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavBarItem(
                icon: Icons.favorite_outline,
                activeIcon: Icons.favorite,
                label: 'Health',
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavBarItem(
                icon: Icons.medication_outlined,
                activeIcon: Icons.medication,
                label: 'Medication',
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavBarItem(
                icon: Icons.school_outlined,
                activeIcon: Icons.school,
                label: 'Education',
                isActive: currentIndex == 3,
                onTap: () => onTap(3),
              ),
              _NavBarItem(
                icon: Icons.menu,
                activeIcon: Icons.menu,
                label: 'More',
                isActive: currentIndex == 4,
                onTap: () => onTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual navigation bar item
class _NavBarItem extends StatelessWidget {
  final IconData? icon;
  final IconData? activeIcon;
  final String? svgPath;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    this.icon,
    this.activeIcon,
    this.svgPath,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacing8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              svgPath != null
                  ? SvgPicture.asset(
                      svgPath!,
                      colorFilter: ColorFilter.mode(
                        isActive
                            ? AppColors.primaryTurquoise
                            : AppColors.textSecondary,
                        BlendMode.srcIn,
                      ),
                      width: AppDimensions.iconMedium,
                      height: AppDimensions.iconMedium,
                    )
                  : Icon(
                      isActive ? activeIcon : icon,
                      color: isActive
                          ? AppColors.primaryTurquoise
                          : AppColors.textSecondary,
                      size: AppDimensions.iconMedium,
                    ),
              const SizedBox(height: AppDimensions.spacing4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive
                      ? AppColors.primaryTurquoise
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
