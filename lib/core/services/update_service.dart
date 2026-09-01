import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Provider for UpdateService
final updateServiceProvider = Provider<UpdateService>((ref) {
  return UpdateService(Dio());
});

class UpdateInfo {
  final bool isUpdateAvailable;
  final String latestVersion;
  final String downloadUrl;

  UpdateInfo({
    required this.isUpdateAvailable,
    required this.latestVersion,
    required this.downloadUrl,
  });
}

class UpdateService {
  final Dio _dio;

  // The GitHub repository API URL for releases
  static const String _releasesUrl =
      'https://api.github.com/repos/Quirkydude/MaHyp/releases/latest';

  UpdateService(this._dio);

  Future<UpdateInfo?> checkForUpdate() async {
    try {
      // 1. Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersionString = packageInfo.version; // e.g., "1.0.0"
      final currentBuildNumber = packageInfo.buildNumber; // e.g., "3"

      final currentVersion = '$currentVersionString+$currentBuildNumber';

      // 2. Fetch latest release from GitHub
      final response = await _dio.get(
        _releasesUrl,
        options: Options(headers: {'Accept': 'application/vnd.github.v3+json'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        String latestTag = data['tag_name'] as String; // e.g., "v1.0.0+3"

        // Remove 'v' prefix if present for clean comparison
        if (latestTag.startsWith('v')) {
          latestTag = latestTag.substring(1);
        }

        // 3. Compare versions
        // Since tag is e.g. "1.0.0+4" and current is "1.0.0+3"
        bool isUpdateAvailable = latestTag != currentVersion;

        String downloadUrl = data['html_url'] as String;

        // Try to find the exact APK download URL in assets
        final assets = data['assets'] as List<dynamic>?;
        if (assets != null && assets.isNotEmpty) {
          for (final asset in assets) {
            final name = asset['name'] as String;
            if (name.endsWith('.apk')) {
              downloadUrl = asset['browser_download_url'] as String;
              break;
            }
          }
        }

        return UpdateInfo(
          isUpdateAvailable: isUpdateAvailable,
          latestVersion: latestTag,
          downloadUrl: downloadUrl,
        );
      }
    } catch (e) {
      // Ignore errors for update checking (e.g., no network)
      print('Update check failed: $e');
    }
    return null;
  }
}
