import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/services/notification_service.dart';

/// Settings service provider (singleton)
final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

/// Settings state notifier for reactive state management
class SettingsNotifier extends StateNotifier<SettingsState> {
  final SettingsService _settingsService;
  final NotificationService? _notificationService;

  SettingsNotifier(this._settingsService, this._notificationService) 
      : super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await _settingsService.init();
    state = _settingsService.loadAll();
  }

  // ============ Notifications ============
  
  Future<void> setNotificationsEnabled(bool value) async {
    await _settingsService.setNotificationsEnabled(value);
    state = state.copyWith(notificationsEnabled: value);
    
    // Wire up actual notification functionality
    final notificationService = _notificationService;
    if (notificationService != null) {
      if (value) {
        // Request permission and enable
        await notificationService.requestPermission();
      }
      // Note: Actual disable would require platform-specific handling
    }
  }

  // ============ Reminders ============
  
  Future<void> setRemindersEnabled(bool value) async {
    await _settingsService.setRemindersEnabled(value);
    state = state.copyWith(remindersEnabled: value);
    
    // Wire up reminder scheduling
    final notificationService = _notificationService;
    if (notificationService != null) {
      if (value) {
        // Schedule BP measurement reminders
        await _scheduleBpReminders();
      } else {
        // Cancel only BP reminder IDs — medication reminders stay intact
        await notificationService.cancelNotification(100);
        await notificationService.cancelNotification(101);
      }
    }
  }

  Future<void> _scheduleBpReminders() async {
    final notificationService = _notificationService;
    if (notificationService == null) return;
    
    // Parse reminder times
    final morningParts = state.morningReminderTime.split(':');
    final eveningParts = state.eveningReminderTime.split(':');
    
    final morningHour = int.tryParse(morningParts[0]) ?? 8;
    final morningMinute = int.tryParse(morningParts[1]) ?? 0;
    final eveningHour = int.tryParse(eveningParts[0]) ?? 20;
    final eveningMinute = int.tryParse(eveningParts[1]) ?? 0;
    
    // Schedule morning reminder
    await notificationService.scheduleDailyReminder(
      id: 100,
      title: 'BP Measurement Reminder',
      body: 'Time to check your blood pressure!',
      hour: morningHour,
      minute: morningMinute,
    );
    
    // Schedule evening reminder
    await notificationService.scheduleDailyReminder(
      id: 101,
      title: 'BP Measurement Reminder',
      body: 'Time for your evening BP check!',
      hour: eveningHour,
      minute: eveningMinute,
    );
  }

  // ============ Appearance ============
  
  Future<void> setDarkModeEnabled(bool value) async {
    await _settingsService.setDarkModeEnabled(value);
    state = state.copyWith(darkModeEnabled: value);
    // Note: Theme change would be handled by the app's theme provider
  }

  Future<void> setFontSize(String value) async {
    await _settingsService.setFontSize(value);
    state = state.copyWith(fontSize: value);
  }

  // ============ Health Settings ============
  

  Future<void> setMorningReminderTime(String value) async {
    await _settingsService.setMorningReminderTime(value);
    state = state.copyWith(morningReminderTime: value);
    
    // Reschedule reminders if enabled
    if (state.remindersEnabled) {
      await _scheduleBpReminders();
    }
  }

  Future<void> setEveningReminderTime(String value) async {
    await _settingsService.setEveningReminderTime(value);
    state = state.copyWith(eveningReminderTime: value);
    
    // Reschedule reminders if enabled
    if (state.remindersEnabled) {
      await _scheduleBpReminders();
    }
  }
}

/// Main settings provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final settingsService = ref.watch(settingsServiceProvider);
  // NotificationService is optional - may not be initialized
  NotificationService? notificationService;
  try {
    notificationService = NotificationService();
  } catch (_) {
    // Notification service not available
  }
  return SettingsNotifier(settingsService, notificationService);
});

// Convenience providers for individual settings
final notificationsEnabledProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).notificationsEnabled;
});

final remindersEnabledProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).remindersEnabled;
});

final darkModeEnabledProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).darkModeEnabled;
});

final fontSizeProvider = Provider<String>((ref) {
  return ref.watch(settingsProvider).fontSize;
});

