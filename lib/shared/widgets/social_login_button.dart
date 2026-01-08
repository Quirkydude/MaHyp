import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

enum SocialLoginType { google, facebook, apple }

/// Social login button widget
class SocialLoginButton extends StatelessWidget {
  final SocialLoginType type;
  final VoidCallback onPressed;

  const SocialLoginButton({
    super.key,
    required this.type,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimensions.socialButtonSize,
      height: AppDimensions.socialButtonSize,
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
          child: Center(child: _getIcon()),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (type) {
      case SocialLoginType.google:
        return AppColors.white;
      case SocialLoginType.facebook:
        return AppColors.facebook;
      case SocialLoginType.apple:
        return AppColors.black;
    }
  }

  Widget _getIcon() {
    final iconSize = AppDimensions.iconMedium;

    switch (type) {
      case SocialLoginType.google:
        return Icon(
          Icons.g_mobiledata_rounded,
          size: iconSize + 8,
          color: AppColors.google,
        );
      case SocialLoginType.facebook:
        return Icon(Icons.facebook, size: iconSize, color: AppColors.white);
      case SocialLoginType.apple:
        return Icon(Icons.apple, size: iconSize, color: AppColors.white);
    }
  }
}
