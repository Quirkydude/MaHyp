import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/notification_model.dart';
import '../../../medication/presentation/providers/medication_provider.dart';
import '../../../medication/data/models/medication_model.dart';
import '../../../bp_monitoring/presentation/providers/bp_provider.dart';
import '../../../bp_monitoring/data/models/bp_reading_model.dart';

/// State class for notifications
class NotificationState {
  final List<NotificationItem> notifications;
  final bool isLoading;
  final String? error;

  const NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
  });

  NotificationState copyWith({
    List<NotificationItem>? notifications,
    bool? isLoading,
    String? error,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Get count of unread notifications
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  /// Check if there are any unread notifications
  bool get hasUnread => unreadCount > 0;
}

/// StateNotifier for managing notifications
class NotificationNotifier extends StateNotifier<NotificationState> {
  final Ref _ref;
  
  NotificationNotifier(this._ref) : super(const NotificationState(isLoading: true)) {
    _initNotifications();
  }

  /// Initialize and listen to data changes
  void _initNotifications() {
    // Listen to medication changes
    _ref.listen<AsyncValue<List<MedicationModel>>>(medicationProvider, (previous, next) {
      next.whenData((medications) {
        _generateMedicationNotifications(medications);
      });
    });

    // Listen to BP changes
    _ref.listen<AsyncValue<List<BPReadingModel>>>(bpProvider, (previous, next) {
      next.whenData((readings) {
        _generateBPNotifications(readings);
      });
    });

    // Initial load
    _loadInitialNotifications();
  }

  /// Load initial notifications: Firestore first, then generate from live data
  void _loadInitialNotifications() {
    _loadFromFirestore().then((persisted) {
      if (persisted.isNotEmpty) {
        state = state.copyWith(notifications: persisted, isLoading: false);
      }
      // Merge with freshly generated notifications on top
      final medications = _ref.read(medicationProvider);
      final bpReadings = _ref.read(bpProvider);
      medications.whenData((meds) => _generateMedicationNotifications(meds));
      bpReadings.whenData((readings) => _generateBPNotifications(readings));
      state = state.copyWith(isLoading: false);
    }).catchError((e) {
      debugPrint('Failed to load notifications from Firestore: $e');
      state = state.copyWith(isLoading: false);
    });
  }

  // ── Firestore helpers ────────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>>? _notifCollection() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications');
  }

  Future<List<NotificationItem>> _loadFromFirestore() async {
    try {
      final col = _notifCollection();
      if (col == null) return [];
      final snap = await col
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();
      return snap.docs
          .map((d) => NotificationItem.fromMap(d.data()))
          .toList();
    } catch (e) {
      debugPrint('Firestore load notifications error: $e');
      return [];
    }
  }

  Future<void> _saveToFirestore(List<NotificationItem> notifications) async {
    try {
      final col = _notifCollection();
      if (col == null) return;
      final batch = FirebaseFirestore.instance.batch();
      for (final n in notifications.take(50)) {
        batch.set(col.doc(n.id), n.toMap(), SetOptions(merge: true));
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Firestore save notifications error: $e');
    }
  }

  /// Generate notifications from medication data
  void _generateMedicationNotifications(List<MedicationModel> medications) {
    final now = DateTime.now();
    final newNotifications = <NotificationItem>[];

    for (final med in medications) {
      for (final dose in med.doses) {
        // Ready to take (within 30 min window)
        if (dose.currentStatus == MedicationStatus.ready) {
          newNotifications.add(NotificationItem(
            id: 'med_ready_${med.id}_${dose.id}',
            title: 'Time to take ${med.name}',
            body: 'Take ${med.dosage} now. Tap to mark as taken.',
            type: NotificationType.medicationReminder,
            createdAt: dose.scheduledTime,
            isRead: false,
            payload: {'medicationId': med.id, 'doseId': dose.id},
          ));
        }

        // Missed doses
        if (dose.currentStatus == MedicationStatus.missed) {
          newNotifications.add(NotificationItem(
            id: 'med_missed_${med.id}_${dose.id}',
            title: 'Missed: ${med.name}',
            body: 'You missed your ${med.dosage} dose. Please take it as soon as possible if safe.',
            type: NotificationType.medicationReminder,
            createdAt: dose.scheduledTime.add(const Duration(hours: 2)),
            isRead: false,
            payload: {'medicationId': med.id, 'doseId': dose.id, 'missed': true},
          ));
        }

        // Taken confirmation (recent)
        if (dose.status == MedicationStatus.taken && 
            dose.takenTime != null &&
            now.difference(dose.takenTime!).inHours < 2) {
          newNotifications.add(NotificationItem(
            id: 'med_taken_${med.id}_${dose.id}',
            title: '${med.name} taken ✓',
            body: 'Great job! You took your ${med.dosage} dose on time.',
            type: NotificationType.system,
            createdAt: dose.takenTime!,
            isRead: true, // Auto-read for confirmations
            payload: {'medicationId': med.id, 'doseId': dose.id},
          ));
        }
      }
    }

    _mergeNotifications(newNotifications);
  }

  /// Generate notifications from BP readings
  void _generateBPNotifications(List<BPReadingModel> readings) {
    if (readings.isEmpty) return;

    final now = DateTime.now();
    final newNotifications = <NotificationItem>[];

    // Check latest reading for high BP alert
    final latest = readings.first;
    if (now.difference(latest.recordedAt).inHours < 24) {
      final category = latest.category;
      
      if (category == BPCategory.crisis) {
        newNotifications.add(NotificationItem(
          id: 'bp_crisis_${latest.id}',
          title: '⚠️ Hypertensive Crisis Alert!',
          body: 'Your reading of ${latest.systolic}/${latest.diastolic} mmHg is dangerously high. Seek emergency medical attention immediately.',
          type: NotificationType.bpReminder,
          createdAt: latest.recordedAt,
          isRead: false,
          payload: {'readingId': latest.id, 'systolic': latest.systolic, 'diastolic': latest.diastolic},
        ));
      } else if (category == BPCategory.highStage2) {
        newNotifications.add(NotificationItem(
          id: 'bp_high_${latest.id}',
          title: 'High Blood Pressure (Stage 2)',
          body: 'Your reading of ${latest.systolic}/${latest.diastolic} mmHg indicates Stage 2 hypertension. Take your medication and monitor closely.',
          type: NotificationType.bpReminder,
          createdAt: latest.recordedAt,
          isRead: false,
          payload: {'readingId': latest.id, 'systolic': latest.systolic, 'diastolic': latest.diastolic},
        ));
      } else if (category == BPCategory.highStage1 || category == BPCategory.elevated) {
        newNotifications.add(NotificationItem(
          id: 'bp_elevated_${latest.id}',
          title: 'Elevated Blood Pressure',
          body: 'Your reading of ${latest.systolic}/${latest.diastolic} mmHg is slightly elevated. Continue monitoring and follow your treatment plan.',
          type: NotificationType.bpReminder,
          createdAt: latest.recordedAt,
          isRead: false,
          payload: {'readingId': latest.id, 'systolic': latest.systolic, 'diastolic': latest.diastolic},
        ));
      } else if (category == BPCategory.normal) {
        newNotifications.add(NotificationItem(
          id: 'bp_normal_${latest.id}',
          title: 'Great BP Reading! 🎉',
          body: 'Your blood pressure of ${latest.systolic}/${latest.diastolic} mmHg is in the normal range. Keep it up!',
          type: NotificationType.system,
          createdAt: latest.recordedAt,
          isRead: true, // Auto-read for good news
          payload: {'readingId': latest.id},
        ));
      }
    }

    // Check if no reading today - reminder to measure
    final todayStart = DateTime(now.year, now.month, now.day);
    final hasReadingToday = readings.any((r) => r.recordedAt.isAfter(todayStart));
    
    if (!hasReadingToday && now.hour >= 9) { // Only remind after 9 AM
      newNotifications.add(NotificationItem(
        id: 'bp_reminder_${now.year}_${now.month}_${now.day}',
        title: 'BP Check Reminder',
        body: "You haven't measured your blood pressure today. Regular monitoring helps track your health.",
        type: NotificationType.bpReminder,
        createdAt: DateTime(now.year, now.month, now.day, 9, 0),
        isRead: false,
      ));
    }

    _mergeNotifications(newNotifications);
  }

  /// Merge new notifications with existing, avoiding duplicates
  void _mergeNotifications(List<NotificationItem> newNotifications) {
    final existingIds = state.notifications.map((n) => n.id).toSet();
    final existingNotifications = List<NotificationItem>.from(state.notifications);

    for (final notification in newNotifications) {
      if (!existingIds.contains(notification.id)) {
        existingNotifications.add(notification);
        existingIds.add(notification.id);
      }
    }

    // Sort by createdAt descending
    existingNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Keep only last 50 notifications
    final trimmed = existingNotifications.take(50).toList();

    state = state.copyWith(notifications: trimmed, isLoading: false);
    _saveToFirestore(trimmed);
  }

  /// Mark a single notification as read
  void markAsRead(String id) {
    final updated = state.notifications.map((n) {
      return n.id == id ? n.copyWith(isRead: true) : n;
    }).toList();
    state = state.copyWith(notifications: updated);
    _saveToFirestore(updated);
  }

  /// Mark all notifications as read
  void markAllAsRead() {
    final updated = state.notifications.map((n) => n.copyWith(isRead: true)).toList();
    state = state.copyWith(notifications: updated);
    _saveToFirestore(updated);
  }

  /// Delete a notification
  void deleteNotification(String id) {
    final updated = state.notifications.where((n) => n.id != id).toList();
    state = state.copyWith(notifications: updated);
    // Remove from Firestore too
    final col = _notifCollection();
    col?.doc(id).delete().catchError((e) => debugPrint('Delete notif error: $e'));
    _saveToFirestore(updated);
  }

  /// Clear all notifications
  void clearAll() {
    final col = _notifCollection();
    for (final n in state.notifications) {
      col?.doc(n.id).delete().catchError((e) => debugPrint('Clear notif error: $e'));
    }
    state = state.copyWith(notifications: []);
  }

  /// Add a new notification (used by notification service)
  void addNotification(NotificationItem notification) {
    final existing = state.notifications.any((n) => n.id == notification.id);
    if (!existing) {
      state = state.copyWith(
        notifications: [notification, ...state.notifications],
      );
    }
  }

  /// Refresh notifications
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    _loadInitialNotifications();
  }
}

/// Provider for notification state
final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier(ref);
});

/// Provider for unread count (convenient for badge display)
final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(notificationProvider).unreadCount;
});
