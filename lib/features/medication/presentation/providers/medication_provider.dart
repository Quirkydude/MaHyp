import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/medication_model.dart';

/// Medication list state notifier
class MedicationNotifier extends StateNotifier<List<MedicationModel>> {
  MedicationNotifier() : super(_dummyMedications);

  // Add medication
  void addMedication(MedicationModel medication) {
    state = [...state, medication];
  }

  // Update medication
  void updateMedication(MedicationModel medication) {
    state = [
      for (final med in state)
        if (med.id == medication.id) medication else med,
    ];
  }

  // Delete medication
  void deleteMedication(String id) {
    state = state.where((med) => med.id != id).toList();
  }

  // Mark as taken
  void markAsTaken(String id) {
    state = [
      for (final med in state)
        if (med.id == id)
          med.copyWith(
            status: MedicationStatus.taken,
            lastTaken: DateTime.now(),
          )
        else
          med,
    ];
  }

  // Get today's medications
  List<MedicationModel> get todayMedications {
    final now = DateTime.now();
    return state.where((med) {
      if (med.scheduledTimes.isEmpty) return false;
      return med.scheduledTimes.any(
        (time) =>
            time.year == now.year &&
            time.month == now.month &&
            time.day == now.day,
      );
    }).toList();
  }

  // Get upcoming medications
  List<MedicationModel> get upcomingMedications {
    final now = DateTime.now();
    return state.where((med) {
      if (med.scheduledTimes.isEmpty) return false;
      return med.scheduledTimes.any((time) => time.isAfter(now));
    }).toList();
  }
}

/// Medication provider
final medicationProvider =
    StateNotifierProvider<MedicationNotifier, List<MedicationModel>>((ref) {
      return MedicationNotifier();
    });

/// Dummy medications for testing
final _dummyMedications = [
  MedicationModel(
    id: '1',
    name: 'Amlodipine',
    dosage: '10mg',
    frequency: MedicationFrequency.onceDaily,
    timesOfDay: [TimeOfDay.morning],
    scheduledTimes: [DateTime.now().add(const Duration(hours: 2))],
    reminderEnabled: true,
    createdAt: DateTime.now(),
    status: MedicationStatus.upcoming,
  ),
  MedicationModel(
    id: '2',
    name: 'Lisinopril',
    dosage: '10mg',
    frequency: MedicationFrequency.onceDaily,
    timesOfDay: [TimeOfDay.afternoon],
    scheduledTimes: [DateTime.now().subtract(const Duration(hours: 2))],
    reminderEnabled: true,
    createdAt: DateTime.now(),
    lastTaken: DateTime.now().subtract(const Duration(hours: 2)),
    status: MedicationStatus.taken,
  ),
  MedicationModel(
    id: '3',
    name: 'HCTZ',
    dosage: '10mg',
    frequency: MedicationFrequency.onceDaily,
    timesOfDay: [TimeOfDay.morning],
    scheduledTimes: [DateTime.now().subtract(const Duration(hours: 4))],
    reminderEnabled: true,
    createdAt: DateTime.now(),
    status: MedicationStatus.missed,
  ),
  MedicationModel(
    id: '4',
    name: 'Lisinopril',
    dosage: '10mg',
    frequency: MedicationFrequency.onceDaily,
    timesOfDay: [TimeOfDay.evening],
    scheduledTimes: [DateTime.now().add(const Duration(hours: 6))],
    reminderEnabled: true,
    createdAt: DateTime.now(),
    status: MedicationStatus.upcoming,
  ),
];
