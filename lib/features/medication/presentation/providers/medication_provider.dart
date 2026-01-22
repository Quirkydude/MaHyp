import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/medication_service.dart';
import '../../data/models/medication_model.dart';

/// Medication Service Provider
final medicationServiceProvider = Provider<MedicationService>((ref) {
  return MedicationService();
});

/// Medication Notifier - manages state and Firestore sync
class MedicationNotifier extends StateNotifier<AsyncValue<List<MedicationModel>>> {
  final MedicationService _service;

  MedicationNotifier(this._service) : super(const AsyncValue.loading()) {
    _loadMedications();
  }

  /// Load medications from Firestore
  Future<void> _loadMedications() async {
    try {
      final medications = await _service.getAllMedications();
      // Generate doses for each medication based on frequency
      final withDoses = medications.map((med) => _generateDoses(med)).toList();
      state = AsyncValue.data(withDoses);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Refresh medications
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadMedications();
  }

  /// Add medication
  Future<void> addMedication(MedicationModel medication) async {
    try {
      final id = await _service.addMedication(medication);
      final newMed = _generateDoses(medication.copyWith(id: id));
      
      state.whenData((medications) {
        state = AsyncValue.data([...medications, newMed]);
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Update medication
  Future<void> updateMedication(MedicationModel medication) async {
    try {
      await _service.updateMedication(medication.id, medication);
      state.whenData((medications) {
        state = AsyncValue.data([
          for (final med in medications)
            if (med.id == medication.id) _generateDoses(medication) else med,
        ]);
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Delete medication
  Future<void> deleteMedication(String id) async {
    try {
      await _service.deleteMedication(id);
      state.whenData((medications) {
        state = AsyncValue.data(medications.where((med) => med.id != id).toList());
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Mark dose as taken and log to Firestore
  Future<void> markDoseAsTaken(String medicationId, String doseId) async {
    state.whenData((medications) async {
      final med = medications.firstWhere((m) => m.id == medicationId);
      final dose = med.doses.firstWhere((d) => d.id == doseId);
      
      // Log to Firestore
      await _service.logDoseEvent(
        medicationId: medicationId,
        medicationName: med.name,
        scheduledTime: dose.scheduledTime,
        status: MedicationStatus.taken,
        takenTime: DateTime.now(),
      );

      // Update local state
      state = AsyncValue.data([
        for (final m in medications)
          if (m.id == medicationId)
            m.copyWith(
              doses: [
                for (final d in m.doses)
                  if (d.id == doseId)
                    d.copyWith(status: MedicationStatus.taken, takenTime: DateTime.now())
                  else
                    d,
              ],
            )
          else
            m,
      ]);
    });
  }

  /// Skip dose and log to Firestore
  Future<void> skipDose(String medicationId, String doseId) async {
    state.whenData((medications) async {
      final med = medications.firstWhere((m) => m.id == medicationId);
      final dose = med.doses.firstWhere((d) => d.id == doseId);
      
      await _service.logDoseEvent(
        medicationId: medicationId,
        medicationName: med.name,
        scheduledTime: dose.scheduledTime,
        status: MedicationStatus.skipped,
      );

      state = AsyncValue.data([
        for (final m in medications)
          if (m.id == medicationId)
            m.copyWith(
              doses: [
                for (final d in m.doses)
                  if (d.id == doseId)
                    d.copyWith(status: MedicationStatus.skipped)
                  else
                    d,
              ],
            )
          else
            m,
      ]);
    });
  }

  /// Generate doses for a medication based on frequency (client-side)
  MedicationModel _generateDoses(MedicationModel med) {
    final now = DateTime.now();
    final doses = <MedicationDose>[];
    
    // Map TimeOfDay to hours
    int getHour(TimeOfDay tod) {
      switch (tod) {
        case TimeOfDay.morning: return 8;
        case TimeOfDay.afternoon: return 14;
        case TimeOfDay.evening: return 18;
        case TimeOfDay.night: return 21;
      }
    }
    
    // Generate doses for past 2 days and next 7 days
    for (int day = -2; day < 7; day++) {
      final date = now.add(Duration(days: day));
      for (final tod in med.timesOfDay) {
        final hour = getHour(tod);
        final scheduledTime = DateTime(date.year, date.month, date.day, hour, 0);
        
        doses.add(MedicationDose(
          id: '${med.id}_${scheduledTime.millisecondsSinceEpoch}',
          scheduledTime: scheduledTime,
          status: MedicationStatus.upcoming,
        ));
      }
    }
    
    doses.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    return med.copyWith(doses: doses);
  }

  /// Get today's medications from state
  List<MedicationModel> get todayMedications {
    return state.value?.where((med) => med.todayDoses.isNotEmpty).toList() ?? [];
  }

  /// Get adherence stats from notifier
  Map<String, int> get adherenceStats {
    final meds = state.value ?? [];
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    int totalDoses = 0;
    int takenDoses = 0;
    int missedDoses = 0;

    for (final med in meds) {
      final recentDoses = med.doses.where((dose) {
        return dose.scheduledTime.isAfter(sevenDaysAgo) &&
            dose.scheduledTime.isBefore(now);
      });

      totalDoses += recentDoses.length;
      takenDoses += recentDoses.where((d) => d.status == MedicationStatus.taken).length;
      missedDoses += recentDoses.where((d) => d.status == MedicationStatus.missed).length;
    }

    final adherence = totalDoses > 0 ? ((takenDoses / totalDoses) * 100).round() : 100;

    return {
      'adherence': adherence,
      'taken': takenDoses,
      'total': totalDoses,
      'missed': missedDoses,
    };
  }
}

/// Medication provider - async-aware
final medicationProvider =
    StateNotifierProvider<MedicationNotifier, AsyncValue<List<MedicationModel>>>((ref) {
      final service = ref.watch(medicationServiceProvider);
      return MedicationNotifier(service);
    });

/// Adherence stats provider
final adherenceStatsProvider = Provider<Map<String, int>>((ref) {
  final notifier = ref.watch(medicationProvider.notifier);
  return notifier.adherenceStats;
});

/// Stream provider for real-time updates
final medicationsStreamProvider = StreamProvider<List<MedicationModel>>((ref) {
  final service = ref.watch(medicationServiceProvider);
  return service.medicationsStream();
});

