import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Model class for user profile data
class UserProfile {
  final String uid;
  final String fullName;
  final String email;
  final String? mobile;
  final DateTime? dob;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.uid,
    required this.fullName,
    required this.email,
    this.mobile,
    this.dob,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from Firestore document
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw StateError('User profile document ${doc.id} has no data');
    }
    return UserProfile(
      uid: doc.id,
      fullName: data['fullName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      mobile: data['mobile'] as String?,
      dob: data['dob'] is Timestamp ? (data['dob'] as Timestamp).toDate() : null,
      avatarUrl: data['avatarUrl'] as String?,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'fullName': fullName,
      'email': email,
      'mobile': mobile,
      'dob': dob != null ? Timestamp.fromDate(dob!) : null,
      'avatarUrl': avatarUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

/// Service for managing user profiles in Firestore
class UserProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Collection reference
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  /// Create a new user profile after registration
  Future<void> createUserProfile({
    required String uid,
    required String fullName,
    required String email,
    String? mobile,
    DateTime? dob,
    String? avatarUrl,
  }) async {
    final now = DateTime.now();
    await _usersCollection.doc(uid).set({
      'fullName': fullName,
      'email': email,
      'mobile': mobile,
      'dob': dob != null ? Timestamp.fromDate(dob) : null,
      'avatarUrl': avatarUrl,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });
  }

  /// Get user profile by UID
  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc);
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String uid,
    String? fullName,
    String? mobile,
    DateTime? dob,
    String? avatarUrl,
  }) async {
    final updates = <String, dynamic>{
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };

    if (fullName != null) updates['fullName'] = fullName;
    if (mobile != null) updates['mobile'] = mobile;
    if (dob != null) updates['dob'] = Timestamp.fromDate(dob);
    if (avatarUrl != null) updates['avatarUrl'] = avatarUrl;

    await _usersCollection.doc(uid).update(updates);
  }

  /// Stream user profile for real-time updates
  Stream<UserProfile?> userProfileStream(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromFirestore(doc);
    });
  }

  /// Delete user profile (for account deletion)
  Future<void> deleteUserProfile(String uid) async {
    await _usersCollection.doc(uid).delete();
  }
}
