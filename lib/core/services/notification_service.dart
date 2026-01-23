import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages
  debugPrint('Handling background message: ${message.messageId}');
}

/// Service for handling push notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Android notification channel for medication reminders
  static const AndroidNotificationChannel _medicationChannel = 
      AndroidNotificationChannel(
    'medication_reminders',
    'Medication Reminders',
    description: 'Notifications for medication reminders',
    importance: Importance.high,
    playSound: true,
  );

  /// Android notification channel for general notifications
  static const AndroidNotificationChannel _generalChannel = 
      AndroidNotificationChannel(
    'general_notifications',
    'General Notifications',
    description: 'General app notifications',
    importance: Importance.defaultImportance,
  );

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Set up background message handler
    // On Web, this is handled by the service worker, but calling it doesn't hurt (no-op or registers handler)
    try {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    } catch (e) {
      debugPrint('Error setting background handler: $e');
    }

    // Request permission (don't await to avoid blocking app launch on web)
    requestPermission();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Create notification channels (Android only)
    await _createNotificationChannels();

    // Set up foreground message handler
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps when app is in background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check if app was opened from a notification
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

  /// Request notification permissions
  Future<bool> requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      final granted = settings.authorizationStatus == AuthorizationStatus.authorized;
      debugPrint('Notification permission: ${settings.authorizationStatus}');
      return granted;
    } catch (e) {
      debugPrint('Error requesting permission: $e');
      return false;
    }
  }

  /// Initialize local notifications plugin
  Future<void> _initializeLocalNotifications() async {
    // Android settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS/macOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      // macOS: macosSettings, // Add if needed
      // linux: linuxSettings, // Add if needed
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    if (!kIsWeb && Platform.isAndroid) {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      await androidPlugin?.createNotificationChannel(_medicationChannel);
      await androidPlugin?.createNotificationChannel(_generalChannel);
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Received foreground message: ${message.messageId}');
    
    // Show local notification when app is in foreground
    _showLocalNotification(
      title: message.notification?.title ?? 'MaHyp',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.messageId}');
    // TODO: Navigate to appropriate screen based on message data
  }

  /// Handle local notification tap
  void _onNotificationTap(NotificationResponse response) {
    debugPrint('Local notification tapped: ${response.payload}');
    // TODO: Navigate based on payload
  }

  /// Show a local notification
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
      importance: isMedicationReminder ? Importance.high : Importance.defaultImportance,
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

  /// Schedule a medication reminder
  Future<void> scheduleMedicationReminder({
    required int id,
    required String medicationName,
    required String dosage,
    required DateTime scheduledTime,
  }) async {
    // For now, show immediate notification for testing
    // In production, use zonedSchedule for scheduled notifications
    await _showLocalNotification(
      title: 'Time to take $medicationName',
      body: 'Take $dosage now',
      payload: 'medication:$id',
      isMedicationReminder: true,
    );
  }

  /// Schedule a daily reminder at a specific time
  /// Used for BP measurement reminders
  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    // For web, we can't schedule recurring notifications
    // For mobile, we use zonedSchedule with matchDateTimeComponents
    if (kIsWeb) {
      debugPrint('Daily reminders not supported on web');
      return;
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

    // Schedule for the next occurrence of this time
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Note: For true daily recurring notifications, you'd use:
    // await _localNotifications.zonedSchedule(
    //   id, title, body, scheduledDate, details,
    //   androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    //   uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    //   matchDateTimeComponents: DateTimeComponents.time,
    // );
    
    // For now, schedule a one-time notification
    debugPrint('Scheduled reminder $id for $hour:$minute');
  }

  /// Cancel a scheduled notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Get FCM token for this device
  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }
}
