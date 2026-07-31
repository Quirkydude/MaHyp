import 'package:equatable/equatable.dart';

enum BPCategory {
  controlled, // < 140/90
  notControlled, // ≥ 140/90
  crisis, // >180 or >120
}

enum MeasurementTime { morning, afternoon, evening, night }

/// Blood Pressure Reading Model
class BPReadingModel extends Equatable {
  final String id;
  final int systolic;
  final int diastolic;
  final int? heartRate;
  final DateTime recordedAt;
  final MeasurementTime timeOfDay;
  final String? notes;
  final bool feltDizzy;
  final bool hadHeadache;
  final bool feltNausea;

  const BPReadingModel({
    required this.id,
    required this.systolic,
    required this.diastolic,
    this.heartRate,
    required this.recordedAt,
    required this.timeOfDay,
    this.notes,
    this.feltDizzy = false,
    this.hadHeadache = false,
    this.feltNausea = false,
  });

  // Get BP category based on simplified guidelines
  // < 140/90 = Controlled
  // ≥ 140/90 = Not Controlled
  // > 180/120 = Crisis (unchanged)
  BPCategory get category {
    // Crisis - Seek emergency care (unchanged)
    if (systolic > 180 || diastolic > 120) {
      return BPCategory.crisis;
    }

    // Not Controlled - ≥ 140/90
    if (systolic >= 140 || diastolic >= 90) {
      return BPCategory.notControlled;
    }

    // Controlled - < 140/90
    return BPCategory.controlled;
  }

  // Get category name
  String get categoryName {
    switch (category) {
      case BPCategory.controlled:
        return 'Controlled';
      case BPCategory.notControlled:
        return 'Not Controlled';
      case BPCategory.crisis:
        return 'Hypertensive Crisis';
    }
  }

  // Get category color
  String get categoryColorHex {
    switch (category) {
      case BPCategory.controlled:
        return '4CAF50'; // Green
      case BPCategory.notControlled:
        return 'FF9800'; // Orange
      case BPCategory.crisis:
        return 'D32F2F'; // Dark Red
    }
  }

  // Check if emergency
  bool get isEmergency => category == BPCategory.crisis;

  // Check if needs attention
  bool get needsAttention =>
      category == BPCategory.notControlled || category == BPCategory.crisis;

  // Get recommendation
  String get recommendation {
    switch (category) {
      case BPCategory.controlled:
        return 'Your blood pressure is controlled (below 140/90). Keep up the good work! Continue taking your medication as prescribed and monitoring regularly.';
      case BPCategory.notControlled:
        return 'Your blood pressure is not controlled (140/90 or higher). Take your medication as prescribed and contact your doctor for a follow-up appointment to adjust your treatment plan.';
      case BPCategory.crisis:
        return 'This is a hypertensive crisis. Seek emergency medical attention immediately. Call emergency services or go to the nearest hospital.';
    }
  }

  // Formatted reading
  String get formattedReading => '$systolic/$diastolic mmHg';

  // Time of day string
  String get timeOfDayString {
    switch (timeOfDay) {
      case MeasurementTime.morning:
        return 'Morning';
      case MeasurementTime.afternoon:
        return 'Afternoon';
      case MeasurementTime.evening:
        return 'Evening';
      case MeasurementTime.night:
        return 'Night';
    }
  }

  // Check if reading is valid (basic validation)
  bool get isValid {
    return systolic >= 70 &&
        systolic <= 250 &&
        diastolic >= 40 &&
        diastolic <= 150 &&
        systolic > diastolic; // Systolic must be higher than diastolic
  }

  BPReadingModel copyWith({
    String? id,
    int? systolic,
    int? diastolic,
    int? heartRate,
    DateTime? recordedAt,
    MeasurementTime? timeOfDay,
    String? notes,
    bool? feltDizzy,
    bool? hadHeadache,
    bool? feltNausea,
  }) {
    return BPReadingModel(
      id: id ?? this.id,
      systolic: systolic ?? this.systolic,
      diastolic: diastolic ?? this.diastolic,
      heartRate: heartRate ?? this.heartRate,
      recordedAt: recordedAt ?? this.recordedAt,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      notes: notes ?? this.notes,
      feltDizzy: feltDizzy ?? this.feltDizzy,
      hadHeadache: hadHeadache ?? this.hadHeadache,
      feltNausea: feltNausea ?? this.feltNausea,
    );
  }

  @override
  List<Object?> get props => [
    id,
    systolic,
    diastolic,
    heartRate,
    recordedAt,
    timeOfDay,
    notes,
    feltDizzy,
    hadHeadache,
    feltNausea,
  ];
}

/// BP Statistics Model
class BPStatistics {
  final double avgSystolic;
  final double avgDiastolic;
  final int totalReadings;
  final int controlledCount;
  final int notControlledCount;
  final int crisisCount;
  final BPReadingModel? highestReading;
  final BPReadingModel? lowestReading;
  final List<BPReadingModel> recentReadings;

  BPStatistics({
    required this.avgSystolic,
    required this.avgDiastolic,
    required this.totalReadings,
    required this.controlledCount,
    required this.notControlledCount,
    required this.crisisCount,
    this.highestReading,
    this.lowestReading,
    required this.recentReadings,
  });

  // Calculate from readings
  factory BPStatistics.fromReadings(List<BPReadingModel> readings) {
    if (readings.isEmpty) {
      return BPStatistics(
        avgSystolic: 0,
        avgDiastolic: 0,
        totalReadings: 0,
        controlledCount: 0,
        notControlledCount: 0,
        crisisCount: 0,
        recentReadings: [],
      );
    }

    final avgSys =
        readings.map((r) => r.systolic).reduce((a, b) => a + b) /
        readings.length;
    final avgDia =
        readings.map((r) => r.diastolic).reduce((a, b) => a + b) /
        readings.length;

    int controlled = 0, notControlled = 0, crisis = 0;
    for (final reading in readings) {
      switch (reading.category) {
        case BPCategory.controlled:
          controlled++;
          break;
        case BPCategory.notControlled:
          notControlled++;
          break;
        case BPCategory.crisis:
          crisis++;
          break;
      }
    }

    // Find highest and lowest
    final sorted = [...readings]
      ..sort((a, b) => a.systolic.compareTo(b.systolic));

    return BPStatistics(
      avgSystolic: avgSys,
      avgDiastolic: avgDia,
      totalReadings: readings.length,
      controlledCount: controlled,
      notControlledCount: notControlled,
      crisisCount: crisis,
      highestReading: sorted.last,
      lowestReading: sorted.first,
      recentReadings: readings.take(5).toList(),
    );
  }
}
