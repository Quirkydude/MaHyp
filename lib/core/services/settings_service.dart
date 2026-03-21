import 'package:shared_preferences/shared_preferences.dart';

/// Service for persisting and retrieving app settings
class SettingsService {
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyRemindersEnabled = 'reminders_enabled';
  static const String _keyDarkModeEnabled = 'dark_mode_enabled';
  static const String _keyFontSize = 'font_size';

  static const String _keyMorningReminderTime = 'morning_reminder_time';
  static const String _keyEveningReminderTime = 'evening_reminder_time';

  SharedPreferences? _prefs;

  /// Initialize SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ============ Notifications ============
  
  bool get notificationsEnabled => _prefs?.getBool(_keyNotificationsEnabled) ?? true;
  
  Future<void> setNotificationsEnabled(bool value) async {
    await _prefs?.setBool(_keyNotificationsEnabled, value);
  }

  // ============ Reminders ============
  
  bool get remindersEnabled => _prefs?.getBool(_keyRemindersEnabled) ?? true;
  
  Future<void> setRemindersEnabled(bool value) async {
    await _prefs?.setBool(_keyRemindersEnabled, value);
  }

  // ============ Appearance ============
  
  bool get darkModeEnabled => _prefs?.getBool(_keyDarkModeEnabled) ?? false;
  
  Future<void> setDarkModeEnabled(bool value) async {
    await _prefs?.setBool(_keyDarkModeEnabled, value);
  }

  String get fontSize => _prefs?.getString(_keyFontSize) ?? 'Medium';
  
  Future<void> setFontSize(String value) async {
    await _prefs?.setString(_keyFontSize, value);
  }

  // ============ Health Settings ============
  
  String get morningReminderTime => _prefs?.getString(_keyMorningReminderTime) ?? '08:00';
  
  Future<void> setMorningReminderTime(String value) async {
    await _prefs?.setString(_keyMorningReminderTime, value);
  }

  String get eveningReminderTime => _prefs?.getString(_keyEveningReminderTime) ?? '20:00';
  
  Future<void> setEveningReminderTime(String value) async {
    await _prefs?.setString(_keyEveningReminderTime, value);
  }

  // ============ Load All Settings ============
  
  SettingsState loadAll() {
    return SettingsState(
      notificationsEnabled: notificationsEnabled,
      remindersEnabled: remindersEnabled,
      darkModeEnabled: darkModeEnabled,
      fontSize: fontSize,

      morningReminderTime: morningReminderTime,
      eveningReminderTime: eveningReminderTime,
    );
  }
}

/// Immutable settings state
class SettingsState {
  final bool notificationsEnabled;
  final bool remindersEnabled;
  final bool darkModeEnabled;
  final String fontSize;

  final String morningReminderTime;
  final String eveningReminderTime;

  const SettingsState({
    this.notificationsEnabled = true,
    this.remindersEnabled = true,
    this.darkModeEnabled = false,
    this.fontSize = 'Medium',

    this.morningReminderTime = '08:00',
    this.eveningReminderTime = '20:00',
  });

  SettingsState copyWith({
    bool? notificationsEnabled,
    bool? remindersEnabled,
    bool? darkModeEnabled,
    String? fontSize,

    String? morningReminderTime,
    String? eveningReminderTime,
  }) {
    return SettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      fontSize: fontSize ?? this.fontSize,

      morningReminderTime: morningReminderTime ?? this.morningReminderTime,
      eveningReminderTime: eveningReminderTime ?? this.eveningReminderTime,
    );
  }
}
