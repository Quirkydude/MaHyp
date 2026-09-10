import 'package:flutter_test/flutter_test.dart';
import 'package:mahyp_app/features/medication/data/medication_data.dart';

void main() {
  group('MedicationData Tests', () {
    test('allMedications contains medications from all antihypertensive classes', () {
      expect(MedicationData.allMedications.isNotEmpty, isTrue);
      expect(MedicationData.allMedications.length, greaterThan(40));
    });

    test('parseMedication correctly extracts name and dosage', () {
      final amlodipine = MedicationData.parseMedication('Amlodipine 5 mg');
      expect(amlodipine.name, equals('Amlodipine'));
      expect(amlodipine.dosage, equals('5 mg'));

      final bendro = MedicationData.parseMedication('Bendroflumethiazide 2.5 mg');
      expect(bendro.name, equals('Bendroflumethiazide'));
      expect(bendro.dosage, equals('2.5 mg'));

      final lisinopril = MedicationData.parseMedication('Lisinopril 20 mg');
      expect(lisinopril.name, equals('Lisinopril'));
      expect(lisinopril.dosage, equals('20 mg'));
    });

    test('getClassForMedication returns appropriate class', () {
      expect(
        MedicationData.getClassForMedication('Amlodipine 5 mg'),
        equals('Calcium Channel Blockers'),
      );
      expect(
        MedicationData.getClassForMedication('Lisinopril 10 mg'),
        equals('ACE Inhibitors'),
      );
      expect(
        MedicationData.getClassForMedication('Losartan 50 mg'),
        equals('Angiotensin II Receptor Blockers (ARBs)'),
      );
      expect(
        MedicationData.getClassForMedication('Hydrochlorothiazide 25 mg'),
        equals('Thiazide / Thiazide-like Diuretics'),
      );
      expect(
        MedicationData.getClassForMedication('Nonexistent Drug 100 mg'),
        isNull,
      );
    });
  });
}
