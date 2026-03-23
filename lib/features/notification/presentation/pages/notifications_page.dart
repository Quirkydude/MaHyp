import 'package:flutter/material.dart';
import '../../../../illustrations/illustrations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../data/models/notification_model.dart';
import '../providers/notification_provider.dart';
import '../widgets/notification_card.dart';

/// Notifications page showing all in-app notifications
/// 
/// Features:
/// - Grouped by date (Today, Yesterday, Earlier)
/// - Mark all as read action
/// - Swipe to delete individual notifications
/// - Empty state with illustration
class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationState = ref.watch(notificationProvider);
    final notifications = notificationState.notifications;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Notifications',
        showBackButton: true,
        actions: [
          if (notificationState.hasUnread)
            IconButton(
              icon: const Icon(Icons.done_all, color: AppColors.white),
              tooltip: 'Mark all as read',
              onPressed: () {
                ref.read(notificationProvider.notifier).markAllAsRead();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('All notifications marked as read'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.white),
            onSelected: (value) {
              if (value == 'clear_all') {
                _showClearAllDialog(context, ref);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, color: AppColors.error),
                    SizedBox(width: 12),
                    Text('Clear all'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: notificationState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? _buildEmptyState(context)
              : _buildNotificationList(context, ref, notifications),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            EmptyStateIllustration(size: 150),
            const SizedBox(height: 24),
            Text(
              'No Notifications',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'re all caught up! New notifications\nwill appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationList(
    BuildContext context,
    WidgetRef ref,
    List<NotificationItem> notifications,
  ) {
    // Group notifications by date
    final grouped = _groupNotificationsByDate(notifications);

    return RefreshIndicator(
      color: AppColors.primaryTurquoise,
      onRefresh: () => ref.read(notificationProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 12, bottom: 100),
        itemCount: grouped.length,
        itemBuilder: (context, index) {
          final group = grouped[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(
                  group.dateLabel,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              // Notifications for this date
              ...group.notifications.map((notification) => NotificationCard(
                    notification: notification,
                    onTap: () => _handleNotificationTap(context, ref, notification),
                    onDismiss: () {
                      ref.read(notificationProvider.notifier)
                          .deleteNotification(notification.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Notification removed'),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () {
                              // Re-add notification
                              ref.read(notificationProvider.notifier)
                                  .addNotification(notification);
                            },
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                  )),
            ],
          );
        },
      ),
    );
  }

  List<_NotificationGroup> _groupNotificationsByDate(
    List<NotificationItem> notifications,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final todayList = <NotificationItem>[];
    final yesterdayList = <NotificationItem>[];
    final earlierList = <NotificationItem>[];

    for (final notification in notifications) {
      final notifDate = DateTime(
        notification.createdAt.year,
        notification.createdAt.month,
        notification.createdAt.day,
      );

      if (notifDate == today) {
        todayList.add(notification);
      } else if (notifDate == yesterday) {
        yesterdayList.add(notification);
      } else {
        earlierList.add(notification);
      }
    }

    final groups = <_NotificationGroup>[];
    if (todayList.isNotEmpty) {
      groups.add(_NotificationGroup(dateLabel: 'TODAY', notifications: todayList));
    }
    if (yesterdayList.isNotEmpty) {
      groups.add(_NotificationGroup(dateLabel: 'YESTERDAY', notifications: yesterdayList));
    }
    if (earlierList.isNotEmpty) {
      groups.add(_NotificationGroup(dateLabel: 'EARLIER', notifications: earlierList));
    }

    return groups;
  }

  void _handleNotificationTap(
    BuildContext context,
    WidgetRef ref,
    NotificationItem notification,
  ) {
    // Mark as read
    ref.read(notificationProvider.notifier).markAsRead(notification.id);

    // Navigate based on notification type
    switch (notification.type) {
      case NotificationType.medicationReminder:
        context.push(AppRouter.medicationList);
        break;
      case NotificationType.bpReminder:
        context.push(AppRouter.recordBP);
        break;
      case NotificationType.healthTip:
        context.push(AppRouter.education);
        break;
      case NotificationType.system:
        // System notifications typically don't navigate anywhere
        break;
    }
  }

  void _showClearAllDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Clear All Notifications?'),
        content: const Text(
          'This will remove all notifications. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(notificationProvider.notifier).clearAll();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('All notifications cleared'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            child: Text(
              'Clear All',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper class for grouping notifications by date
class _NotificationGroup {
  final String dateLabel;
  final List<NotificationItem> notifications;

  _NotificationGroup({
    required this.dateLabel,
    required this.notifications,
  });
}
