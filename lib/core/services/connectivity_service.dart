import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Connectivity status enum
enum ConnectivityStatus {
  online,
  offline,
}

/// Service for monitoring network connectivity
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final _connectivity = Connectivity();
  
  final _statusController = StreamController<ConnectivityStatus>.broadcast();
  Stream<ConnectivityStatus> get statusStream => _statusController.stream;
  
  ConnectivityStatus _currentStatus = ConnectivityStatus.online;
  ConnectivityStatus get currentStatus => _currentStatus;

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    // Check initial status
    final results = await _connectivity.checkConnectivity();
    _updateStatus(results);

    // Listen for changes
    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
    
    debugPrint('ConnectivityService initialized: $_currentStatus');
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final hasConnection = results.any((result) => 
        result != ConnectivityResult.none);
    
    final newStatus = hasConnection 
        ? ConnectivityStatus.online 
        : ConnectivityStatus.offline;
    
    if (newStatus != _currentStatus) {
      _currentStatus = newStatus;
      _statusController.add(_currentStatus);
      debugPrint('Connectivity changed: $_currentStatus');
    }
  }

  /// Check if currently online
  bool get isOnline => _currentStatus == ConnectivityStatus.online;

  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
    _statusController.close();
  }
}

/// Connectivity status provider
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

/// Stream provider for connectivity status
final connectivityStatusProvider = StreamProvider<ConnectivityStatus>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.statusStream;
});

/// Simple provider for current connectivity status
final isOnlineProvider = Provider<bool>((ref) {
  final asyncStatus = ref.watch(connectivityStatusProvider);
  return asyncStatus.whenOrNull(data: (status) => status == ConnectivityStatus.online) ?? true;
});
