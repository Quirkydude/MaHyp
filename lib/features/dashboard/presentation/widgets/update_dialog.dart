import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';

class UpdateDialog extends StatelessWidget {
  final String latestVersion;
  final String downloadUrl;

  const UpdateDialog({
    super.key,
    required this.latestVersion,
    required this.downloadUrl,
  });

  Future<void> _launchDownloadUrl(BuildContext context) async {
    final uri = Uri.parse(downloadUrl);
    try {
      bool launched = false;
      if (await canLaunchUrl(uri)) {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      if (!launched) {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      if (!launched) {
        launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      }

      if (launched && context.mounted) {
        Navigator.of(context).pop();
      } else if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open the download link.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening link: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      title: Row(
        children: [
          const Icon(
            Icons.system_update_rounded,
            color: AppColors.primaryTurquoise,
            size: 28,
          ),
          const SizedBox(width: AppDimensions.spacing12),
          Expanded(child: Text('Update Available!', style: AppTextStyles.h4)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'A new version ($latestVersion) of MaHyp is available.',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: AppDimensions.spacing12),
          Text(
            'Would you like to download and install the latest update now?',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Later',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => _launchDownloadUrl(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryTurquoise,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing20,
              vertical: AppDimensions.spacing12,
            ),
          ),
          child: Text(
            'Download Now',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
