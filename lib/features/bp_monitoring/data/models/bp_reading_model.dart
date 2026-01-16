import 'package:equatable/equatable.dart';

enum BPCategory {
  normal, // <120 and <80
  elevated, // 120-129 and <80
  highStage1, // 130-139 or 80-89
  highStage2, // ≥140 or ≥90
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

  // Get BP category based on AHA guidelines
  BPCategory get category {
    // Crisis - Seek emergency care
    if (systolic > 180 || diastolic > 120) {
      return BPCategory.crisis;
    }

    // High Blood Pressure Stage 2
    if (systolic >= 140 || diastolic >= 90) {
      return BPCategory.highStage2;
    }

    // High Blood Pressure Stage 1
    if ((systolic >= 130 && systolic <= 139) ||
        (diastolic >= 80 && diastolic <= 89)) {
      return BPCategory.highStage1;
    }

    // Elevated
    if (systolic >= 120 && systolic <= 129 && diastolic < 80) {
      return BPCategory.elevated;
    }

    // Normal
    return BPCategory.normal;
  }

  // Get category name
  String get categoryName {
    switch (category) {
      case BPCategory.normal:
        return 'Normal';
      case BPCategory.elevated:
        return 'Elevated';
      case BPCategory.highStage1:
        return 'High (Stage 1)';
      case BPCategory.highStage2:
        return 'High (Stage 2)';
      case BPCategory.crisis:
        return 'Hypertensive Crisis';
    }
  }

  // Get category color
  String get categoryColorHex {
    switch (category) {
      case BPCategory.normal:
        return '4CAF50'; // Green
      case BPCategory.elevated:
        return 'FF9800'; // Orange
      case BPCategory.highStage1:
        return 'FF9800'; // Orange
      case BPCategory.highStage2:
        return 'F44336'; // Red
      case BPCategory.crisis:
        return 'D32F2F'; // Dark Red
    }
  }

  // Check if emergency
  bool get isEmergency => category == BPCategory.crisis;

  // Check if needs attention
  bool get needsAttention =>
      category == BPCategory.highStage2 || category == BPCategory.crisis;

  // Get recommendation
  String get recommendation {
    switch (category) {
      case BPCategory.normal:
        return 'Your blood pressure is within normal range. Keep up the good work!';
      case BPCategory.elevated:
        return 'Elevated blood pressure means your reading is higher than normal but not yet at the high blood pressure stage. Following medical advice can help prevent progression.';
      case BPCategory.highStage1:
        return 'Take your prescribed medication regularly and monitor your readings daily. Consult your doctor if readings remain high.';
      case BPCategory.highStage2:
        return 'This indicates Stage 2 hypertension. Take your medication as prescribed and contact your doctor for a follow-up appointment.';
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
  final int normalCount;
  final int elevatedCount;
  final int highCount;
  final int crisisCount;
  final BPReadingModel? highestReading;
  final BPReadingModel? lowestReading;
  final List<BPReadingModel> recentReadings;

  BPStatistics({
    required this.avgSystolic,
    required this.avgDiastolic,
    required this.totalReadings,
    required this.normalCount,
    required this.elevatedCount,
    required this.highCount,
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
        normalCount: 0,
        elevatedCount: 0,
        highCount: 0,
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

    int normal = 0, elevated = 0, high = 0, crisis = 0;
    for (final reading in readings) {
      switch (reading.category) {
        case BPCategory.normal:
          normal++;
          break;
        case BPCategory.elevated:
          elevated++;
          break;
        case BPCategory.highStage1:
        case BPCategory.highStage2:
          high++;
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
      normalCount: normal,
      elevatedCount: elevated,
      highCount: high,
      crisisCount: crisis,
      highestReading: sorted.last,
      lowestReading: sorted.first,
      recentReadings: readings.take(5).toList(),
    );
  }
}
