import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.messageId}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  static const AndroidNotificationChannel _medicationChannel =
      AndroidNotificationChannel(
        'medication_reminders',
        'Medication Reminders',
        description: 'Notifications for medication reminders',
        importance: Importance.high,
        playSound: true,
      );

  static const AndroidNotificationChannel _generalChannel =
      AndroidNotificationChannel(
        'general_notifications',
        'General Notifications',
        description: 'General app notifications',
        importance: Importance.defaultImportance,
      );

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone database
    tz.initializeTimeZones();
    try {
      if (!kIsWeb) {
        final timeZoneName = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(timeZoneName.toString()));
      }
    } catch (e) {
      debugPrint('Error setting local timezone: $e');
    }

    try {
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
    } catch (e) {
      debugPrint('Error setting background handler: $e');
    }

    requestPermission();

    await _initializeLocalNotifications();
    await _createNotificationChannels();

    // Request exact alarm permission on Android 12+
    if (!kIsWeb && Platform.isAndroid) {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidPlugin?.requestExactAlarmsPermission();
    }

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    try {
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }
    } catch (e) {
      debugPrint('Error getting initial message: $e');
    }

    _isInitialized = true;
    debugPrint('NotificationService initialized');
  }

  Future<bool> requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      final granted =
          settings.authorizationStatus == AuthorizationStatus.authorized;
      debugPrint('Notification permission: ${settings.authorizationStatus}');
      return granted;
    } catch (e) {
      debugPrint('Error requesting permission: $e');
      return false;
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  Future<void> _createNotificationChannels() async {
    if (!kIsWeb && Platform.isAndroid) {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      await androidPlugin?.createNotificationChannel(_medicationChannel);
      await androidPlugin?.createNotificationChannel(_generalChannel);
    }
  }

  // ---------------------------------------------------------------------------
  // Foreground message handling
  // ---------------------------------------------------------------------------

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Received foreground message');

    _showLocalNotification(
      title: message.notification?.title ?? 'MaHyp',
      body: message.notification?.body ?? '',
      payload: _buildPayloadFromData(message.data),
    );
  }

  // ---------------------------------------------------------------------------
  // Tap navigation
  // ---------------------------------------------------------------------------

  /// Navigate based on FCM remote message tap (background / terminated)
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped');
    final payload = _buildPayloadFromData(message.data);
    _navigateFromPayload(payload);
  }

  /// Navigate based on local notification tap
  void _onNotificationTap(NotificationResponse response) {
    debugPrint('Local notification tapped');
    _navigateFromPayload(response.payload);
  }

  /// Convert FCM data map to a compact payload string
  String _buildPayloadFromData(Map<String, dynamic> data) {
    final type = data['type'] as String? ?? '';
    final id = data['id'] as String? ?? '';
    if (type.isNotEmpty) {
      return id.isNotEmpty ? '$type:$id' : type;
    }
    return '';
  }

  /// Parse a payload string and push the matching route via GoRouter
  void _navigateFromPayload(String? payload) {
    if (payload == null || payload.isEmpty) return;

    final context = AppRouter.navigatorKey.currentContext;
    if (context == null) {
      debugPrint('Navigator context not available for notification tap');
      return;
    }

    final parts = payload.split(':');
    final type = parts[0];

    switch (type) {
      case 'medication':
        context.push(AppRouter.medicationList);
        break;
      case 'bp':
      case 'bp_reminder':
        context.push(AppRouter.recordBP);
        break;
      case 'education':
      case 'health_tip':
        context.push(AppRouter.education);
        break;
      default:
        context.push(AppRouter.notifications);
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // Show immediate local notification
  // ---------------------------------------------------------------------------

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
    bool isMedicationReminder = false,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      isMedicationReminder ? _medicationChannel.id : _generalChannel.id,
      isMedicationReminder ? _medicationChannel.name : _generalChannel.name,
      channelDescription: isMedicationReminder
          ? _medicationChannel.description
          : _generalChannel.description,
      importance: isMedicationReminder
          ? Importance.high
          : Importance.defaultImportance,
      priority: isMedicationReminder ? Priority.high : Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // ---------------------------------------------------------------------------
  // Scheduled notifications
  // ---------------------------------------------------------------------------

  /// Schedule a one-time medication reminder at [scheduledTime].
  Future<void> scheduleMedicationReminder({
    required int id,
    required String medicationName,
    required String dosage,
    required DateTime scheduledTime,
  }) async {
    if (kIsWeb) {
      debugPrint('Scheduled notifications not supported on web');
      return;
    }

    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    // If the time is in the past, skip it
    if (tzScheduledTime.isBefore(tz.TZDateTime.now(tz.local))) {
      debugPrint('Scheduled time is in the past, skipping');
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      _medicationChannel.id,
      _medicationChannel.name,
      channelDescription: _medicationChannel.description,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      id,
      'Time to take $medicationName',
      'Take $dosage now',
      tzScheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'medication:$id',
    );

    debugPrint('Scheduled medication reminder at $tzScheduledTime');
  }

  /// Schedule a daily repeating reminder at [hour]:[minute].
  /// Used for BP measurement reminders.
  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    if (kIsWeb) {
      debugPrint('Daily reminders not supported on web');
      return;
    }

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the time already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final androidDetails = AndroidNotificationDetails(
      _generalChannel.id,
      _generalChannel.name,
      channelDescription: _generalChannel.description,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'bp_reminder:$id',
    );

    debugPrint('Scheduled daily reminder $id at $hour:$minute');
  }

  // ---------------------------------------------------------------------------
  // Cancel
  // ---------------------------------------------------------------------------

  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  // ---------------------------------------------------------------------------
  // FCM token & topics
  // ---------------------------------------------------------------------------

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }
}
