library;

enum NotificationType { medicationReminder, bpReminder, system, healthTip }

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? payload;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.payload,
  });

  /// Create a copy with updated fields
  NotificationItem copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? payload,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      payload: payload ?? this.payload,
    );
  }

  /// Get icon data based on notification type
  static String getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.medicationReminder:
        return 'medication';
      case NotificationType.bpReminder:
        return 'monitor_heart';
      case NotificationType.system:
        return 'info';
      case NotificationType.healthTip:
        return 'lightbulb';
    }
  }

  /// Get a user-friendly type label
  String get typeLabel {
    switch (type) {
      case NotificationType.medicationReminder:
        return 'Medication';
      case NotificationType.bpReminder:
        return 'Blood Pressure';
      case NotificationType.system:
        return 'System';
      case NotificationType.healthTip:
        return 'Health Tip';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isRead': isRead,
      'payload': payload,
    };
  }

  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    return NotificationItem(
      id: map['id'] as String,
      title: map['title'] as String,
      body: map['body'] as String,
      type: NotificationType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => NotificationType.system,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      isRead: map['isRead'] as bool? ?? false,
      payload: map['payload'] != null
          ? Map<String, dynamic>.from(map['payload'] as Map)
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
