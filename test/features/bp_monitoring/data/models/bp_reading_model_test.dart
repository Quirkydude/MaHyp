import 'package:flutter_test/flutter_test.dart';
import 'package:mahyp_app/features/bp_monitoring/data/models/bp_reading_model.dart';
import 'package:mahyp_app/features/bp_monitoring/data/models/bp_reading_model.dart'
    as bp_model;

void main() {
  group('BPReadingModel Category Logic', () {
    test('category should be controlled for 110/70', () {
      final reading = BPReadingModel(
        id: '1',
        systolic: 110,
        diastolic: 70,
        recordedAt: DateTime.now(),
        timeOfDay: bp_model.MeasurementTime.morning,
      );

      expect(reading.category, BPCategory.controlled);
      expect(reading.categoryName, 'Controlled');
    });

    test('category should be controlled for 125/75', () {
      final reading = BPReadingModel(
        id: '2',
        systolic: 125,
        diastolic: 75,
        recordedAt: DateTime.now(),
        timeOfDay: bp_model.MeasurementTime.afternoon,
      );

      expect(reading.category, BPCategory.controlled);
      expect(reading.categoryName, 'Controlled');
    });

    test('category should be controlled for 135/85', () {
      final reading = BPReadingModel(
        id: '3',
        systolic: 135,
        diastolic: 85,
        recordedAt: DateTime.now(),
        timeOfDay: bp_model.MeasurementTime.evening,
      );

      expect(reading.category, BPCategory.controlled);
    });

    test('category should be notControlled for 145/95', () {
      final reading = BPReadingModel(
        id: '4',
        systolic: 145,
        diastolic: 95,
        recordedAt: DateTime.now(),
        timeOfDay: bp_model.MeasurementTime.night,
      );

      expect(reading.category, BPCategory.notControlled);
      expect(reading.needsAttention, true);
    });

    test('category should be crisis for 185/125', () {
      final reading = BPReadingModel(
        id: '5',
        systolic: 185,
        diastolic: 125,
        recordedAt: DateTime.now(),
        timeOfDay: bp_model.MeasurementTime.morning,
      );

      expect(reading.category, BPCategory.crisis);
      expect(reading.isEmergency, true);
      expect(reading.needsAttention, true);
    });
  });
}
