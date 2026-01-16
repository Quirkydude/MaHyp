import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/bp_reading_model.dart';

/// BP Readings Notifier
class BPNotifier extends StateNotifier<List<BPReadingModel>> {
  BPNotifier() : super(_generateDummyReadings());

  // Add reading
  void addReading(BPReadingModel reading) {
    state = [reading, ...state]
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
  }

  // Delete reading
  void deleteReading(String id) {
    state = state.where((r) => r.id != id).toList();
  }

  // Get readings for specific period
  List<BPReadingModel> getReadingsForPeriod(Duration period) {
    final cutoff = DateTime.now().subtract(period);
    return state.where((r) => r.recordedAt.isAfter(cutoff)).toList();
  }

  // Get today's readings
  List<BPReadingModel> get todayReadings {
    final now = DateTime.now();
    return state.where((r) {
      return r.recordedAt.year == now.year &&
          r.recordedAt.month == now.month &&
          r.recordedAt.day == now.day;
    }).toList();
  }

  // Get latest reading
  BPReadingModel? get latestReading => state.isNotEmpty ? state.first : null;

  // Check if last reading is emergency
  bool get hasEmergency => latestReading?.isEmergency ?? false;
}

/// BP Provider
final bpProvider = StateNotifierProvider<BPNotifier, List<BPReadingModel>>((
  ref,
) {
  return BPNotifier();
});

/// Statistics Provider
final bpStatisticsProvider = Provider<BPStatistics>((ref) {
  final readings = ref.watch(bpProvider);
  final weekReadings = readings.where((r) {
    return r.recordedAt.isAfter(
      DateTime.now().subtract(const Duration(days: 7)),
    );
  }).toList();
  return BPStatistics.fromReadings(weekReadings);
});

/// Latest Reading Provider
final latestReadingProvider = Provider<BPReadingModel?>((ref) {
  final readings = ref.watch(bpProvider);
  return readings.isNotEmpty ? readings.first : null;
});

/// Dummy readings generator
List<BPReadingModel> _generateDummyReadings() {
  final now = DateTime.now();
  final readings = <BPReadingModel>[];

  // Generate readings for last 7 days
  for (int day = 0; day < 7; day++) {
    final date = now.subtract(Duration(days: day));

    // Morning reading
    readings.add(
      BPReadingModel(
        id: '${date.millisecondsSinceEpoch}_morning',
        systolic: 118 + (day * 3),
        diastolic: 75 + (day * 2),
        heartRate: 72 + day,
        recordedAt: DateTime(date.year, date.month, date.day, 8, 30),
        timeOfDay: MeasurementTime.morning,
      ),
    );

    // Evening reading
    readings.add(
      BPReadingModel(
        id: '${date.millisecondsSinceEpoch}_evening',
        systolic: 125 + (day * 4),
        diastolic: 80 + (day * 2),
        heartRate: 75 + day,
        recordedAt: DateTime(date.year, date.month, date.day, 18, 0),
        timeOfDay: MeasurementTime.evening,
        notes: day == 1 ? 'Felt a bit dizzy' : null,
        feltDizzy: day == 1,
      ),
    );
  }

  // Add one high reading
  readings.add(
    BPReadingModel(
      id: '${now.millisecondsSinceEpoch}_high',
      systolic: 145,
      diastolic: 92,
      heartRate: 88,
      recordedAt: now.subtract(const Duration(days: 3, hours: 12)),
      timeOfDay: MeasurementTime.afternoon,
      notes: 'After stressful meeting',
      feltHeadache: true,
    ),
  );

  readings.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
  return readings;
}
