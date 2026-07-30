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
  final bool isPhoneVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.uid,
    required this.fullName,
    required this.email,
    this.mobile,
    this.dob,
    this.avatarUrl,
    this.isPhoneVerified = false,
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
      isPhoneVerified: data['isPhoneVerified'] as bool? ?? false,
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
      'isPhoneVerified': isPhoneVerified,
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
    bool isPhoneVerified = false,
  }) async {
    final now = DateTime.now();
    await _usersCollection.doc(uid).set({
      'fullName': fullName,
      'email': email,
      'mobile': mobile,
      'dob': dob != null ? Timestamp.fromDate(dob) : null,
      'avatarUrl': avatarUrl,
      'isPhoneVerified': isPhoneVerified,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });
  }

  /// Ensure a Firestore profile exists for social / first-time sign-in.
  Future<void> ensureUserProfile({
    required String uid,
    required String fullName,
    required String email,
    String? mobile,
    String? avatarUrl,
  }) async {
    final existing = await getUserProfile(uid);
    if (existing != null) return;
    await createUserProfile(
      uid: uid,
      fullName: fullName.isNotEmpty ? fullName : 'User',
      email: email,
      mobile: mobile,
      avatarUrl: avatarUrl,
    );
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
    final docRef = _usersCollection.doc(uid);
    final docSnap = await docRef.get();
    
    // If the profile document doesn't exist, create it instead of updating
    if (!docSnap.exists) {
      final user = FirebaseAuth.instance.currentUser;
      await createUserProfile(
        uid: uid,
        fullName: fullName ?? 'User',
        email: user?.email ?? '',
        mobile: mobile,
        dob: dob,
        avatarUrl: avatarUrl,
      );
      return;
    }

    final updates = <String, dynamic>{
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };

    if (fullName != null) updates['fullName'] = fullName;
    if (mobile != null) updates['mobile'] = mobile;
    if (dob != null) updates['dob'] = Timestamp.fromDate(dob);
    if (avatarUrl != null) updates['avatarUrl'] = avatarUrl;

    await docRef.update(updates);
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
