import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/bp_service.dart';
import '../../data/models/bp_reading_model.dart';

/// BP Service Provider
final bpServiceProvider = Provider<BPService>((ref) {
  return BPService();
});

/// BP Readings Notifier - manages state and Firestore sync
class BPNotifier extends StateNotifier<AsyncValue<List<BPReadingModel>>> {
  final BPService _bpService;

  BPNotifier(this._bpService) : super(const AsyncValue.loading()) {
    _loadReadings();
  }

  /// Load readings from Firestore
  Future<void> _loadReadings() async {
    try {
      final readings = await _bpService.getAllReadings();
      state = AsyncValue.data(readings);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Refresh readings from Firestore
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadReadings();
  }

  /// Add reading to Firestore and update state
  Future<void> addReading(BPReadingModel reading) async {
    try {
      final id = await _bpService.addReading(reading);
      final newReading = reading.copyWith(id: id);
      
      state.whenData((readings) {
        state = AsyncValue.data([newReading, ...readings]
          ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt)));
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Delete reading from Firestore and update state
  Future<void> deleteReading(String id) async {
    try {
      await _bpService.deleteReading(id);
      state.whenData((readings) {
        state = AsyncValue.data(readings.where((r) => r.id != id).toList());
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Get readings for specific period from current state
  List<BPReadingModel> getReadingsForPeriod(Duration period) {
    final cutoff = DateTime.now().subtract(period);
    return state.value?.where((r) => r.recordedAt.isAfter(cutoff)).toList() ?? [];
  }

  /// Get today's readings from current state
  List<BPReadingModel> get todayReadings {
    final now = DateTime.now();
    return state.value?.where((r) {
      return r.recordedAt.year == now.year &&
          r.recordedAt.month == now.month &&
          r.recordedAt.day == now.day;
    }).toList() ?? [];
  }

  /// Get latest reading from current state
  BPReadingModel? get latestReading => 
      state.value?.isNotEmpty == true ? state.value!.first : null;

  /// Check if last reading is emergency
  bool get hasEmergency => latestReading?.isEmergency ?? false;
}

/// BP Provider - now async-aware
final bpProvider = StateNotifierProvider<BPNotifier, AsyncValue<List<BPReadingModel>>>((
  ref,
) {
  final bpService = ref.watch(bpServiceProvider);
  return BPNotifier(bpService);
});

/// Statistics Provider - derives from bp readings
final bpStatisticsProvider = Provider<BPStatistics>((ref) {
  final readingsAsync = ref.watch(bpProvider);
  
  return readingsAsync.when(
    data: (readings) {
      final weekReadings = readings.where((r) {
        return r.recordedAt.isAfter(
          DateTime.now().subtract(const Duration(days: 7)),
        );
      }).toList();
      return BPStatistics.fromReadings(weekReadings);
    },
    loading: () => BPStatistics.fromReadings([]),
    error: (_, __) => BPStatistics.fromReadings([]),
  );
});

/// Latest Reading Provider
final latestReadingProvider = Provider<BPReadingModel?>((ref) {
  final readingsAsync = ref.watch(bpProvider);
  return readingsAsync.when(
    data: (readings) => readings.isNotEmpty ? readings.first : null,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Stream provider for real-time updates (optional)
final bpReadingsStreamProvider = StreamProvider<List<BPReadingModel>>((ref) {
  final bpService = ref.watch(bpServiceProvider);
  return bpService.readingsStream();
});

