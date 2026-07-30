import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sync-friendly gate for whether a signed-in user may enter the app.
///
/// Email/password users normally need Firebase `emailVerified`.
/// Phone-OTP signup stores `phoneVerified` on the profile and caches it
/// locally so GoRouter redirects can stay synchronous.
class AuthAccessService {
  AuthAccessService._();

  static String? _cachedUid;
  static bool _phoneVerifiedCached = false;

  static String _prefsKey(String uid) => 'phone_verified_$uid';

  /// Warm the in-memory cache from SharedPreferences.
  static Future<void> loadCache(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    _cachedUid = uid;
    _phoneVerifiedCached = prefs.getBool(_prefsKey(uid)) ?? false;
  }

  /// Persist phone verification for this user (signup + profile sync).
  static Future<void> markPhoneVerified(String uid) async {
    _cachedUid = uid;
    _phoneVerifiedCached = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey(uid), true);
  }

  static Future<void> clear(String uid) async {
    if (_cachedUid == uid) {
      _cachedUid = null;
      _phoneVerifiedCached = false;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey(uid));
  }

  /// Whether the user may access protected routes without email verification.
  static bool canAccessApp(User? user) {
    if (user == null) return false;
    if (user.emailVerified) return true;

    final isPasswordProvider = user.providerData.any(
      (info) => info.providerId == 'password',
    );
    // Social / other providers are treated as verified.
    if (!isPasswordProvider) return true;

    return _cachedUid == user.uid && _phoneVerifiedCached;
  }

  /// True when this password user still needs the email-verification screen.
  static bool needsEmailVerification(User? user) {
    if (user == null) return false;
    if (canAccessApp(user)) return false;
    return user.providerData.any((info) => info.providerId == 'password');
  }
}
