import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../features/medication/data/models/medication_model.dart';

/// Service for managing medications in Firestore
class MedicationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _medicationsCollection {
    if (_uid == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(_uid).collection('medications');
  }

  CollectionReference<Map<String, dynamic>> get _doseLogsCollection {
    if (_uid == null) throw Exception('User not authenticated');
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('medication_logs');
  }

  /// Add a new medication
  Future<String> addMedication(MedicationModel medication) async {
    final docRef = await _medicationsCollection.add(
      _medicationToFirestore(medication),
    );
    return docRef.id;
  }

  /// Get all medications
  Future<List<MedicationModel>> getAllMedications() async {
    final snapshot = await _medicationsCollection
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => _medicationFromFirestore(doc)).toList();
  }

  /// Get all available medications from master list (for dropdown)
  Future<List<Map<String, String>>> getAvailableMedications() async {
    try {
      // Try to get from a master medications collection
      final snapshot = await _firestore
          .collection('master_medications')
          .orderBy('name')
          .get();

      return snapshot.docs
          .map(
            (doc) => {
              'id': doc.id,
              'name': doc.data()['name'] as String? ?? '',
              'dosage': doc.data()['dosage'] as String? ?? '',
            },
          )
          .toList();
    } catch (e) {
      // If master collection doesn't exist, return empty list
      return [];
    }
  }

  /// Add medication to master list (admin function)
  Future<void> addToMasterMedications(String name, String dosage) async {
    await _firestore.collection('master_medications').add({
      'name': name,
      'dosage': dosage,
      'createdAt': Timestamp.now(),
    });
  }

  /// Stream of all medications
  Stream<List<MedicationModel>> medicationsStream() {
    return _medicationsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _medicationFromFirestore(doc))
              .toList(),
        );
  }

  /// Update medication
  Future<void> updateMedication(String id, MedicationModel medication) async {
    await _medicationsCollection
        .doc(id)
        .update(_medicationToFirestore(medication));
  }

  /// Delete medication
  Future<void> deleteMedication(String id) async {
    await _medicationsCollection.doc(id).delete();
  }

  /// Log a dose event (taken, skipped, missed)
  Future<void> logDoseEvent({
    required String medicationId,
    required String medicationName,
    required DateTime scheduledTime,
    required MedicationStatus status,
    DateTime? takenTime,
  }) async {
    await _doseLogsCollection.add({
      'medicationId': medicationId,
      'medicationName': medicationName,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'status': status.name,
      'takenTime': takenTime != null ? Timestamp.fromDate(takenTime) : null,
      'loggedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Get dose logs for a medication
  Future<List<Map<String, dynamic>>> getDoseLogs(
    String medicationId, {
    int days = 7,
  }) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final snapshot = await _doseLogsCollection
        .where('medicationId', isEqualTo: medicationId)
        .where('scheduledTime', isGreaterThan: Timestamp.fromDate(cutoff))
        .orderBy('scheduledTime', descending: true)
        .get();

    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  /// Get adherence stats for a period
  Future<Map<String, int>> getAdherenceStats({int days = 7}) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final snapshot = await _doseLogsCollection
        .where('scheduledTime', isGreaterThan: Timestamp.fromDate(cutoff))
        .get();

    int total = snapshot.docs.length;
    int taken = snapshot.docs
        .where((doc) => doc.data()['status'] == 'taken')
        .length;
    int missed = snapshot.docs
        .where((doc) => doc.data()['status'] == 'missed')
        .length;
    int skipped = snapshot.docs
        .where((doc) => doc.data()['status'] == 'skipped')
        .length;

    return {
      'total': total,
      'taken': taken,
      'missed': missed,
      'skipped': skipped,
      'adherence': total > 0 ? ((taken / total) * 100).round() : 100,
    };
  }

  /// Convert MedicationModel to Firestore map
  Map<String, dynamic> _medicationToFirestore(MedicationModel med) {
    return {
      'name': med.name,
      'dosage': med.dosage,
      'frequency': med.frequency.name,
      'timesOfDay': med.timesOfDay.map((t) => t.name).toList(),
      'reminderEnabled': med.reminderEnabled,
      'notes': med.notes,
      'createdAt': Timestamp.fromDate(med.createdAt),
    };
  }

  /// Convert Firestore document to MedicationModel
  MedicationModel _medicationFromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null) {
      throw StateError('Medication document ${doc.id} has no data');
    }
    return MedicationModel(
      id: doc.id,
      name: data['name'] as String? ?? 'Unknown',
      dosage: data['dosage'] as String? ?? '',
      frequency: MedicationFrequency.values.firstWhere(
        (e) => e.name == data['frequency'],
        orElse: () => MedicationFrequency.onceDaily,
      ),
      timesOfDay:
          (data['timesOfDay'] as List<dynamic>?)
              ?.map(
                (t) => TimeOfDay.values.firstWhere(
                  (e) => e.name == t,
                  orElse: () => TimeOfDay.morning,
                ),
              )
              .toList() ??
          [TimeOfDay.morning],
      doses: [],
      reminderEnabled: data['reminderEnabled'] as bool? ?? true,
      notes: data['notes'] as String?,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
