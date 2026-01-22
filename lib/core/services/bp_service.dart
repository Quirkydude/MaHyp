import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../features/bp_monitoring/data/models/bp_reading_model.dart';

/// Service for managing BP readings in Firestore
class BPService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user's UID
  String? get _uid => _auth.currentUser?.uid;

  /// Reference to user's BP readings collection
  CollectionReference<Map<String, dynamic>> get _bpCollection {
    if (_uid == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(_uid).collection('bp_readings');
  }

  /// Add a new BP reading
  Future<String> addReading(BPReadingModel reading) async {
    final docRef = await _bpCollection.add(_toFirestore(reading));
    return docRef.id;
  }

  /// Get all readings for current user (ordered by date desc)
  Future<List<BPReadingModel>> getAllReadings() async {
    final snapshot = await _bpCollection
        .orderBy('recordedAt', descending: true)
        .get();
    
    return snapshot.docs
        .map((doc) => _fromFirestore(doc))
        .toList();
  }

  /// Stream of all readings (real-time updates)
  Stream<List<BPReadingModel>> readingsStream() {
    return _bpCollection
        .orderBy('recordedAt', descending: true)
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => _fromFirestore(doc)).toList());
  }

  /// Get readings for a specific period
  Future<List<BPReadingModel>> getReadingsForPeriod(Duration period) async {
    final cutoff = DateTime.now().subtract(period);
    final snapshot = await _bpCollection
        .where('recordedAt', isGreaterThan: Timestamp.fromDate(cutoff))
        .orderBy('recordedAt', descending: true)
        .get();
    
    return snapshot.docs
        .map((doc) => _fromFirestore(doc))
        .toList();
  }

  /// Get latest reading
  Future<BPReadingModel?> getLatestReading() async {
    final snapshot = await _bpCollection
        .orderBy('recordedAt', descending: true)
        .limit(1)
        .get();
    
    if (snapshot.docs.isEmpty) return null;
    return _fromFirestore(snapshot.docs.first);
  }

  /// Delete a reading
  Future<void> deleteReading(String id) async {
    await _bpCollection.doc(id).delete();
  }

  /// Update a reading
  Future<void> updateReading(String id, BPReadingModel reading) async {
    await _bpCollection.doc(id).update(_toFirestore(reading));
  }

  /// Convert BPReadingModel to Firestore map
  Map<String, dynamic> _toFirestore(BPReadingModel reading) {
    return {
      'systolic': reading.systolic,
      'diastolic': reading.diastolic,
      'heartRate': reading.heartRate,
      'recordedAt': Timestamp.fromDate(reading.recordedAt),
      'timeOfDay': reading.timeOfDay.name,
      'notes': reading.notes,
      'feltDizzy': reading.feltDizzy,
      'hadHeadache': reading.hadHeadache,
      'feltNausea': reading.feltNausea,
    };
  }

  /// Convert Firestore document to BPReadingModel
  BPReadingModel _fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return BPReadingModel(
      id: doc.id,
      systolic: data['systolic'] as int,
      diastolic: data['diastolic'] as int,
      heartRate: data['heartRate'] as int?,
      recordedAt: (data['recordedAt'] as Timestamp).toDate(),
      timeOfDay: MeasurementTime.values.firstWhere(
        (e) => e.name == data['timeOfDay'],
        orElse: () => MeasurementTime.morning,
      ),
      notes: data['notes'] as String?,
      feltDizzy: data['feltDizzy'] as bool? ?? false,
      hadHeadache: data['hadHeadache'] as bool? ?? false,
      feltNausea: data['feltNausea'] as bool? ?? false,
    );
  }
}
