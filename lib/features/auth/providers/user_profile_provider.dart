import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/user_profile_service.dart';

/// Provider for UserProfileService
final userProfileServiceProvider = Provider<UserProfileService>((ref) {
  return UserProfileService();
});

/// Provider for current user's profile (stream)
final userProfileStreamProvider = StreamProvider<UserProfile?>((ref) {
  final auth = FirebaseAuth.instance;
  final user = auth.currentUser;
  
  if (user == null) {
    return Stream.value(null);
  }
  
  final profileService = ref.watch(userProfileServiceProvider);
  return profileService.userProfileStream(user.uid);
});

/// Provider for fetching user profile once (future)
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final auth = FirebaseAuth.instance;
  final user = auth.currentUser;
  
  if (user == null) return null;
  
  final profileService = ref.watch(userProfileServiceProvider);
  return profileService.getUserProfile(user.uid);
});
