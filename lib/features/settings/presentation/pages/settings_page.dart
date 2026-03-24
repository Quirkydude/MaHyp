import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../providers/settings_provider.dart';

/// Settings Page - App configuration options with persistence
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const CustomAppBar(
        title: 'Settings',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppDimensions.spacing16),
            
            Center(
              child: SvgPicture.asset(
                'assets/logos/mahyp_logo.svg',
                height: 80,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing24),
            
            // Notifications Section
            _buildSectionHeader(context, 'Notifications'),
            _buildSwitchTile(
              context,
              ref,
              icon: Icons.notifications_outlined,
              title: 'Push Notifications',
              subtitle: 'Receive medication reminders',
              value: settings.notificationsEnabled,
              onChanged: (value) => ref.read(settingsProvider.notifier).setNotificationsEnabled(value),
            ),
            _buildSwitchTile(
              context,
              ref,
              icon: Icons.alarm_outlined,
              title: 'BP Reminders',
              subtitle: 'Daily BP measurement reminders',
              value: settings.remindersEnabled,
              onChanged: (value) => ref.read(settingsProvider.notifier).setRemindersEnabled(value),
            ),
            
            const SizedBox(height: 24),
            
            // Appearance Section
            _buildSectionHeader(context, 'Appearance'),
            _buildSwitchTile(
              context,
              ref,
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              subtitle: 'Enable dark theme',
              value: settings.darkModeEnabled,
              onChanged: (value) => ref.read(settingsProvider.notifier).setDarkModeEnabled(value),
            ),
            _buildNavigationTile(
              context,
              icon: Icons.text_fields,
              title: 'Font Size',
              subtitle: settings.fontSize,
              onTap: () => _showFontSizeDialog(context, ref, settings.fontSize),
            ),
            
            const SizedBox(height: 24),
            
            // Health Settings Section
            _buildSectionHeader(context, 'Health Settings'),
            _buildNavigationTile(
              context,
              icon: Icons.timer_outlined,
              title: 'Reminder Schedule',
              subtitle: '${settings.morningReminderTime}, ${settings.eveningReminderTime}',
              onTap: () => _showReminderScheduleDialog(context, ref, settings),
            ),
            
            const SizedBox(height: 24),
            
            // App Info Section
            _buildSectionHeader(context, 'About'),
            _buildNavigationTile(
              context,
              icon: Icons.info_outline,
              title: 'App Version',
              subtitle: '1.0.0',
              showArrow: false,
              onTap: () {},
            ),
            _buildNavigationTile(
              context,
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              onTap: () => _showInfoDialog(context, 'Terms of Service', 
                  'Terms of service content coming soon.'),
            ),
            _buildNavigationTile(
              context,
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () => _showInfoDialog(context, 'Privacy Policy', 
                  'Privacy policy content coming soon.'),
            ),
            _buildNavigationTile(
              context,
              icon: Icons.feedback_outlined,
              title: 'Send Feedback',
              onTap: () => _showFeedbackDialog(context),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.primaryTurquoise,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primaryTurquoise.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryTurquoise,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 13,
                ),
              )
            : null,
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primaryTurquoise,
        ),
      ),
    );
  }

  Widget _buildNavigationTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    bool showArrow = true,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        onTap: onTap,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primaryTurquoise.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryTurquoise,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 13,
                ),
              )
            : null,
        trailing: showArrow
            ? Icon(
                Icons.chevron_right,
                color: AppColors.primaryTurquoise,
              )
            : null,
      ),
    );
  }

  void _showFontSizeDialog(BuildContext context, WidgetRef ref, String currentSize) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Font Size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Small', 'Medium', 'Large', 'Extra Large'].map((size) {
            return ListTile(
              title: Text(size),
              trailing: currentSize == size
                  ? Icon(Icons.check, color: AppColors.primaryTurquoise)
                  : null,
              onTap: () {
                ref.read(settingsProvider.notifier).setFontSize(size);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }


  void _showReminderScheduleDialog(BuildContext context, WidgetRef ref, SettingsState settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('BP Reminder Schedule'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.wb_sunny_outlined),
              title: const Text('Morning'),
              subtitle: Text(settings.morningReminderTime),
              onTap: () async {
                Navigator.pop(context);
                final time = await _showTimePicker(context, settings.morningReminderTime);
                if (time != null) {
                  ref.read(settingsProvider.notifier).setMorningReminderTime(time);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.nights_stay_outlined),
              title: const Text('Evening'),
              subtitle: Text(settings.eveningReminderTime),
              onTap: () async {
                Navigator.pop(context);
                final time = await _showTimePicker(context, settings.eveningReminderTime);
                if (time != null) {
                  ref.read(settingsProvider.notifier).setEveningReminderTime(time);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<String?> _showTimePicker(BuildContext context, String currentTime) async {
    final parts = currentTime.split(':');
    final hour = int.tryParse(parts[0]) ?? 8;
    final minute = int.tryParse(parts[1]) ?? 0;
    
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
    );
    
    if (picked != null) {
      return '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
    return null;
  }

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        var isSending = false;
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Send Feedback'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('We\'d love to hear your thoughts!'),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Enter your feedback...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSending ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: isSending
                    ? null
                    : () async {
                        final text = controller.text.trim();
                        if (text.isEmpty) return;
                        setDialogState(() => isSending = true);
                        try {
                          final uid = FirebaseAuth.instance.currentUser?.uid;
                          await FirebaseFirestore.instance
                              .collection('feedback')
                              .add({
                            'uid': uid,
                            'message': text,
                            'createdAt': FieldValue.serverTimestamp(),
                            'appVersion': '1.0.0',
                          });
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Thank you for your feedback!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                        } catch (_) {
                          if (context.mounted) {
                            setDialogState(() => isSending = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to send. Please try again.'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        }
                      },
                child: isSending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Send'),
              ),
            ],
          ),
        );
      },
    );
  }
}
