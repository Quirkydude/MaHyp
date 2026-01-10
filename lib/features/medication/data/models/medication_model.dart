import 'package:equatable/equatable.dart';

enum MedicationFrequency { onceDaily, twiceDaily, thriceDaily, custom }

enum TimeOfDay { morning, afternoon, evening, night }

enum MedicationStatus { upcoming, taken, missed }

class MedicationModel extends Equatable {
  final String id;
  final String name;
  final String dosage;
  final MedicationFrequency frequency;
  final List<TimeOfDay> timesOfDay;
  final List<DateTime> scheduledTimes;
  final bool reminderEnabled;
  final String? notes;
  final DateTime createdAt;
  final DateTime? lastTaken;
  final MedicationStatus status;

  const MedicationModel({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.timesOfDay,
    required this.scheduledTimes,
    this.reminderEnabled = true,
    this.notes,
    required this.createdAt,
    this.lastTaken,
    this.status = MedicationStatus.upcoming,
  });

  // Get next scheduled dose
  DateTime? get nextDose {
    final now = DateTime.now();
    for (final time in scheduledTimes) {
      if (time.isAfter(now)) {
        return time;
      }
    }
    return null;
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

  // Copy with method
  MedicationModel copyWith({
    String? id,
    String? name,
    String? dosage,
    MedicationFrequency? frequency,
    List<TimeOfDay>? timesOfDay,
    List<DateTime>? scheduledTimes,
    bool? reminderEnabled,
    String? notes,
    DateTime? createdAt,
    DateTime? lastTaken,
    MedicationStatus? status,
  }) {
    return MedicationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      timesOfDay: timesOfDay ?? this.timesOfDay,
      scheduledTimes: scheduledTimes ?? this.scheduledTimes,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      lastTaken: lastTaken ?? this.lastTaken,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    dosage,
    frequency,
    timesOfDay,
    scheduledTimes,
    reminderEnabled,
    notes,
    createdAt,
    lastTaken,
    status,
  ];
}
