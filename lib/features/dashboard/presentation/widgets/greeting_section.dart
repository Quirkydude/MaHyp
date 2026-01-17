import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class GreetingSection extends StatelessWidget {
  final String userName;
  final String? avatarUrl;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onProfilePressed;

  const GreetingSection({
    super.key,
    required this.userName,
    this.avatarUrl,
    this.onNotificationPressed,
    this.onSettingsPressed,
    this.onProfilePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Notification Icon
          _buildIconButton(
            icon: Icons.notifications_outlined,
            onPressed: onNotificationPressed,
          ),
          const SizedBox(width: 8),
          // Settings Icon
          _buildIconButton(
            icon: Icons.settings_outlined,
            onPressed: onSettingsPressed,
          ),
          const Spacer(),
          // Greeting Text
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Hi, WelcomeBack',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              Text(
                userName,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Avatar
          GestureDetector(
            onTap: onProfilePressed,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primaryTurquoise.withOpacity(0.2),
                  backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                  child: avatarUrl == null
                      ? const Icon(Icons.person, color: AppColors.primaryTurquoise)
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: AppColors.textSecondary, size: 22),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
