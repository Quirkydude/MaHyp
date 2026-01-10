import 'package:equatable/equatable.dart';

enum MedicationFrequency { onceDaily, twiceDaily, thriceDaily, custom }

enum TimeOfDay { morning, afternoon, evening, night }

enum MedicationStatus { upcoming, ready, taken, missed, skipped }

/// Medication dose with specific time
class MedicationDose extends Equatable {
  final String id;
  final DateTime scheduledTime;
  final DateTime? takenTime;
  final MedicationStatus status;

  const MedicationDose({
    required this.id,
    required this.scheduledTime,
    this.takenTime,
    this.status = MedicationStatus.upcoming,
  });

  // Check if dose is within taking window (30 min before to 2 hours after)
  bool get canTake {
    final now = DateTime.now();
    final diff = scheduledTime.difference(now);

    // Can take 30 min before scheduled time
    if (diff.inMinutes <= 30 && diff.inMinutes >= -120) {
      return status == MedicationStatus.upcoming ||
          status == MedicationStatus.ready ||
          status == MedicationStatus.missed;
    }
    return false;
  }

  // Get current status based on time
  MedicationStatus get currentStatus {
    if (status == MedicationStatus.taken ||
        status == MedicationStatus.skipped) {
      return status;
    }

    final now = DateTime.now();
    final diff = scheduledTime.difference(now);

    // Within 30 min window - ready to take
    if (diff.inMinutes <= 30 && diff.inMinutes >= 0) {
      return MedicationStatus.ready;
    }

    // More than 2 hours late - missed
    if (diff.inMinutes < -120) {
      return MedicationStatus.missed;
    }

    // Less than 2 hours late but past time - still ready (late)
    if (diff.inMinutes < 0 && diff.inMinutes >= -120) {
      return MedicationStatus.ready;
    }

    // Future dose
    return MedicationStatus.upcoming;
  }

  MedicationDose copyWith({
    String? id,
    DateTime? scheduledTime,
    DateTime? takenTime,
    MedicationStatus? status,
  }) {
    return MedicationDose(
      id: id ?? this.id,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      takenTime: takenTime ?? this.takenTime,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [id, scheduledTime, takenTime, status];
}

/// Medication model
class MedicationModel extends Equatable {
  final String id;
  final String name;
  final String dosage;
  final MedicationFrequency frequency;
  final List<TimeOfDay> timesOfDay; // Multiple times for twice/thrice daily
  final List<MedicationDose> doses; // All scheduled doses
  final bool reminderEnabled;
  final String? notes;
  final DateTime createdAt;

  const MedicationModel({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.timesOfDay,
    required this.doses,
    this.reminderEnabled = true,
    this.notes,
    required this.createdAt,
  });

  // Get today's doses
  List<MedicationDose> get todayDoses {
    final now = DateTime.now();
    return doses.where((dose) {
      return dose.scheduledTime.year == now.year &&
          dose.scheduledTime.month == now.month &&
          dose.scheduledTime.day == now.day;
    }).toList()..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  // Get next dose
  MedicationDose? get nextDose {
    final now = DateTime.now();
    final upcomingDoses = doses.where((dose) {
      return dose.scheduledTime.isAfter(now) &&
          (dose.status == MedicationStatus.upcoming ||
              dose.status == MedicationStatus.ready);
    }).toList()..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

    return upcomingDoses.isNotEmpty ? upcomingDoses.first : null;
  }

  // Get overall status (for list view)
  MedicationStatus get overallStatus {
    final today = todayDoses;
    if (today.isEmpty) return MedicationStatus.upcoming;

    // Check if any dose is ready
    if (today.any((d) => d.currentStatus == MedicationStatus.ready)) {
      return MedicationStatus.ready;
    }

    // Check if all taken
    if (today.every((d) => d.status == MedicationStatus.taken)) {
      return MedicationStatus.taken;
    }

    // Check if any missed
    if (today.any((d) => d.currentStatus == MedicationStatus.missed)) {
      return MedicationStatus.missed;
    }

    return MedicationStatus.upcoming;
  }

  // Get frequency as string
  String get frequencyString {
    switch (frequency) {
      case MedicationFrequency.onceDaily:
        return 'Once daily';
      case MedicationFrequency.twiceDaily:
        return 'Twice daily';
      case MedicationFrequency.thriceDaily:
        return 'Thrice daily';
      case MedicationFrequency.custom:
        return 'Custom';
    }
  }

  // Get time of day as string
  String timeOfDayString(TimeOfDay timeOfDay) {
    switch (timeOfDay) {
      case TimeOfDay.morning:
        return 'Morning';
      case TimeOfDay.afternoon:
        return 'Afternoon';
      case TimeOfDay.evening:
        return 'Evening';
      case TimeOfDay.night:
        return 'Night';
    }
  }

  // Get adherence percentage (last 7 days)
  int get adherencePercentage {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    final recentDoses = doses.where((dose) {
      return dose.scheduledTime.isAfter(sevenDaysAgo) &&
          dose.scheduledTime.isBefore(now);
    }).toList();

    if (recentDoses.isEmpty) return 100;

    final takenCount = recentDoses
        .where((d) => d.status == MedicationStatus.taken)
        .length;

    return ((takenCount / recentDoses.length) * 100).round();
  }

  MedicationModel copyWith({
    String? id,
    String? name,
    String? dosage,
    MedicationFrequency? frequency,
    List<TimeOfDay>? timesOfDay,
    List<MedicationDose>? doses,
    bool? reminderEnabled,
    String? notes,
    DateTime? createdAt,
  }) {
    return MedicationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      timesOfDay: timesOfDay ?? this.timesOfDay,
      doses: doses ?? this.doses,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    dosage,
    frequency,
    timesOfDay,
    doses,
    reminderEnabled,
    notes,
    createdAt,
  ];
}
