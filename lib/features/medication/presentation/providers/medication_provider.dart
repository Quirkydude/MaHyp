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

  // Mark dose as taken
  void markDoseAsTaken(String medicationId, String doseId) {
    state = [
      for (final med in state)
        if (med.id == medicationId)
          med.copyWith(
            doses: [
              for (final dose in med.doses)
                if (dose.id == doseId)
                  dose.copyWith(
                    status: MedicationStatus.taken,
                    takenTime: DateTime.now(),
                  )
                else
                  dose,
            ],
          )
        else
          med,
    ];
  }

  // Skip dose
  void skipDose(String medicationId, String doseId) {
    state = [
      for (final med in state)
        if (med.id == medicationId)
          med.copyWith(
            doses: [
              for (final dose in med.doses)
                if (dose.id == doseId)
                  dose.copyWith(status: MedicationStatus.skipped)
                else
                  dose,
            ],
          )
        else
          med,
    ];
  }

  // Snooze dose (reschedule)
  void snoozeDose(String medicationId, String doseId, int minutes) {
    state = [
      for (final med in state)
        if (med.id == medicationId)
          med.copyWith(
            doses: [
              for (final dose in med.doses)
                if (dose.id == doseId)
                  dose.copyWith(
                    scheduledTime: dose.scheduledTime.add(
                      Duration(minutes: minutes),
                    ),
                  )
                else
                  dose,
            ],
          )
        else
          med,
    ];
  }

  // Undo taken (within 5 minutes)
  void undoTaken(String medicationId, String doseId) {
    state = [
      for (final med in state)
        if (med.id == medicationId)
          med.copyWith(
            doses: [
              for (final dose in med.doses)
                if (dose.id == doseId)
                  dose.copyWith(
                    status: MedicationStatus.upcoming,
                    takenTime: null,
                  )
                else
                  dose,
            ],
          )
        else
          med,
    ];
  }

  // Get today's medications
  List<MedicationModel> get todayMedications {
    return state.where((med) => med.todayDoses.isNotEmpty).toList();
  }

  // Get upcoming medications
  List<MedicationModel> get upcomingMedications {
    return state.where((med) => med.nextDose != null).toList();
  }

  // Get adherence stats
  Map<String, int> get adherenceStats {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    int totalDoses = 0;
    int takenDoses = 0;
    int missedDoses = 0;

    for (final med in state) {
      final recentDoses = med.doses.where((dose) {
        return dose.scheduledTime.isAfter(sevenDaysAgo) &&
            dose.scheduledTime.isBefore(now);
      });

      totalDoses += recentDoses.length;
      takenDoses += recentDoses
          .where((d) => d.status == MedicationStatus.taken)
          .length;
      missedDoses += recentDoses
          .where((d) => d.status == MedicationStatus.missed)
          .length;
    }

    final adherence = totalDoses > 0
        ? ((takenDoses / totalDoses) * 100).round()
        : 100;

    return {
      'adherence': adherence,
      'taken': takenDoses,
      'total': totalDoses,
      'missed': missedDoses,
    };
  }
}

/// Medication provider
final medicationProvider =
    StateNotifierProvider<MedicationNotifier, List<MedicationModel>>((ref) {
      return MedicationNotifier();
    });

/// Adherence stats provider
final adherenceStatsProvider = Provider<Map<String, int>>((ref) {
  final notifier = ref.watch(medicationProvider.notifier);
  return notifier.adherenceStats;
});

/// Generate dummy medications with proper dose scheduling
List<MedicationModel> get _dummyMedications {
  final now = DateTime.now();

  // Helper to create doses
  List<MedicationDose> createDoses(List<int> hours, int days) {
    final doses = <MedicationDose>[];
    for (int day = -2; day < days; day++) {
      for (final hour in hours) {
        final date = now.add(Duration(days: day));
        final scheduledTime = DateTime(
          date.year,
          date.month,
          date.day,
          hour,
          0,
        );

        MedicationStatus status = MedicationStatus.upcoming;
        DateTime? takenTime;

        // For past doses, randomly mark as taken or missed
        if (scheduledTime.isBefore(now)) {
          if (day == -1 || (day == 0 && hour < now.hour - 2)) {
            status = MedicationStatus.missed;
          } else if (DateTime.now().difference(scheduledTime).inHours < 2) {
            // Recent doses - some taken
            status = hour % 2 == 0
                ? MedicationStatus.taken
                : MedicationStatus.missed;
            if (status == MedicationStatus.taken) {
              takenTime = scheduledTime.add(const Duration(minutes: 5));
            }
          } else {
            status = MedicationStatus.taken;
            takenTime = scheduledTime.add(const Duration(minutes: 5));
          }
        }

        doses.add(
          MedicationDose(
            id: '${scheduledTime.millisecondsSinceEpoch}',
            scheduledTime: scheduledTime,
            takenTime: takenTime,
            status: status,
          ),
        );
      }
    }
    return doses;
  }

  return [
    MedicationModel(
      id: '1',
      name: 'Amlodipine',
      dosage: '10mg',
      frequency: MedicationFrequency.onceDaily,
      timesOfDay: [TimeOfDay.morning],
      doses: createDoses([8], 30),
      reminderEnabled: true,
      createdAt: now.subtract(const Duration(days: 30)),
    ),
    MedicationModel(
      id: '2',
      name: 'Lisinopril',
      dosage: '10mg',
      frequency: MedicationFrequency.twiceDaily,
      timesOfDay: [TimeOfDay.morning, TimeOfDay.evening],
      doses: createDoses([8, 18], 30),
      reminderEnabled: true,
      notes: 'Take with food',
      createdAt: now.subtract(const Duration(days: 25)),
    ),
    MedicationModel(
      id: '3',
      name: 'HCTZ',
      dosage: '25mg',
      frequency: MedicationFrequency.onceDaily,
      timesOfDay: [TimeOfDay.morning],
      doses: createDoses([8], 30),
      reminderEnabled: true,
      notes: 'Take in the morning',
      createdAt: now.subtract(const Duration(days: 20)),
    ),
    MedicationModel(
      id: '4',
      name: 'Metformin',
      dosage: '500mg',
      frequency: MedicationFrequency.twiceDaily,
      timesOfDay: [TimeOfDay.morning, TimeOfDay.evening],
      doses: createDoses([8, 18], 30),
      reminderEnabled: true,
      notes: 'Take with meals',
      createdAt: now.subtract(const Duration(days: 15)),
    ),
  ];
}
