import 'dart:developer';
import 'package:dio/dio.dart';

/// Result wrapper so callers can distinguish "sent" vs "failed" vs "why".
class OtpResult {
  final bool success;
  final String? code; // Arkesel's response code, e.g. "1000", "1104"
  final String? message;

  OtpResult({required this.success, this.code, this.message});

  @override
  String toString() =>
      'OtpResult(success: $success, code: $code, message: $message)';
}

/// Arkesel OTP integration.
///
/// Real endpoints confirmed by live testing against the actual API:
///   POST https://sms.arkesel.com/api/otp/generate
///   POST https://sms.arkesel.com/api/otp/verify
/// (NOT /api/v2/otp/send — that path 404s, it isn't a real endpoint.)
///
/// Field names confirmed by live testing, one 422 at a time:
///   - 'number' (not 'phone_number' as some Arkesel blog posts claim)
///   - 'expiry' is required (minutes until the code expires)
///   - 'length', 'type', and 'medium' included alongside for completeness —
///     if a later 422 says one of these is wrong/unneeded, trust that error
///     over this comment and adjust accordingly.
///
/// SECURITY NOTE: your Arkesel API key ships inside the compiled app bundle
/// when called straight from Flutter. You've said you're fine with that for
/// now — just keep in mind anyone can extract it from the built app. If you
/// ever want to close that gap, a small Firebase Cloud Function that proxies
/// these two calls does the trick without changing anything else here.
class ArkeselOTPService {
  final Dio _dio;
  final String _baseUrl = 'https://sms.arkesel.com/api';

  // Use your MAIN SMS API key — Arkesel explicitly documents that OTP does
  // NOT work with "Multiple API Keys" / sub-keys, only the main one.
  final String _apiKey;
  final String _senderId;

  ArkeselOTPService({
    required String apiKey,
    required String senderId,
    Dio? dio,
  }) : _apiKey = apiKey,
       _senderId = senderId,
       _dio = dio ?? Dio();

  /// Sends an OTP via Arkesel. Arkesel generates, stores, and expires the
  /// code server-side — you never see or manage the actual code yourself.
  /// [message] MUST contain the literal placeholder `%otp_code%`; Arkesel
  /// substitutes the real code into it before sending.
  Future<OtpResult> sendOTP(
    String phoneNumber, {
    String medium = 'sms', // 'sms' | 'voice'
    int expiryMinutes = 5,
    int length = 6,
    String type = 'numeric', // 'numeric' | 'alphanumeric'
  }) async {
    final formattedPhone = _formatPhoneNumber(phoneNumber);
    final message =
        'Your MaHyp verification code is %otp_code%. Do not share this with anyone.';

    // Voice medium has a hard 500-character limit on the message.
    if (medium == 'voice' && message.length > 500) {
      return OtpResult(
        success: false,
        message: 'Voice message exceeds 500 characters.',
      );
    }

    try {
      final response = await _dio.post(
        '$_baseUrl/otp/generate',
        options: Options(
          headers: {'api-key': _apiKey, 'Content-Type': 'application/json'},
        ),
        data: {
          'number': formattedPhone,
          'sender_id': _senderId,
          'message': message,
          'expiry': expiryMinutes,
          'length': length,
          'type': type,
          'medium': medium,
        },
      );

      final data = response.data;
      final respCode = data is Map ? data['code']?.toString() : null;
      final respMessage = data is Map ? data['message']?.toString() : null;

      // Arkesel can return HTTP 200 with a logical error in the body, so
      // check the "code" field, not just the HTTP status. "1000" = sent.
      final ok = response.statusCode == 200 && respCode == '1000';

      if (ok) {
        log('OTP send accepted for $formattedPhone: $respMessage');
      } else {
        log('OTP send rejected for $formattedPhone: [$respCode] $respMessage');
      }

      return OtpResult(success: ok, code: respCode, message: respMessage);
    } on DioException catch (e) {
      final respData = e.response?.data;
      log(
        'DioException sending OTP to $formattedPhone: '
        'status=${e.response?.statusCode} body=$respData error=${e.message}',
      );
      return OtpResult(
        success: false,
        code: e.response?.statusCode?.toString(),
        message: respData is Map ? respData['message']?.toString() : e.message,
      );
    } catch (e) {
      log('Unexpected error sending OTP to $formattedPhone: $e');
      return OtpResult(success: false, message: e.toString());
    }
  }

  /// Verifies the code the USER typed in against what Arkesel generated
  /// and stored server-side. Never compare against a locally-generated code.
  Future<OtpResult> verifyOTP(String phoneNumber, String otpCode) async {
    final formattedPhone = _formatPhoneNumber(phoneNumber);

    try {
      final response = await _dio.post(
        '$_baseUrl/otp/verify',
        options: Options(
          headers: {'api-key': _apiKey, 'Content-Type': 'application/json'},
        ),
        data: {'number': formattedPhone, 'code': otpCode},
      );

      final data = response.data;
      final respCode = data is Map ? data['code']?.toString() : null;
      final respMessage = data is Map ? data['message']?.toString() : null;

      // "1100" = verified. This is a DIFFERENT success code than the
      // "1000" used for generate — don't reuse the same check for both.
      final ok = response.statusCode == 200 && respCode == '1100';

      if (ok) {
        log('OTP verified for $formattedPhone');
      } else {
        log(
          'OTP verification failed for $formattedPhone: [$respCode] $respMessage',
        );
      }

      return OtpResult(success: ok, code: respCode, message: respMessage);
    } on DioException catch (e) {
      final respData = e.response?.data;
      log(
        'DioException verifying OTP for $formattedPhone: '
        'status=${e.response?.statusCode} body=$respData error=${e.message}',
      );
      return OtpResult(
        success: false,
        code: e.response?.statusCode?.toString(),
        message: respData is Map ? respData['message']?.toString() : e.message,
      );
    } catch (e) {
      log('Unexpected error verifying OTP for $formattedPhone: $e');
      return OtpResult(success: false, message: e.toString());
    }
  }

  /// Formats to Arkesel's expected "233XXXXXXXXX" form (no +, no spaces).
  String _formatPhoneNumber(String phoneNumber) {
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.startsWith('233')) {
      return digitsOnly;
    } else if (digitsOnly.startsWith('0')) {
      return '233${digitsOnly.substring(1)}';
    } else {
      return '233$digitsOnly';
    }
  }

  bool get isConfigured => _apiKey.isNotEmpty && _senderId.isNotEmpty;
}

/// -----------------------------------------------------------------------
/// USAGE EXAMPLE (MaHyp — Flutter client, Firebase backend, no proxy server)
/// -----------------------------------------------------------------------
///
/// final otpService = ArkeselOTPService(
///   apiKey: 'YOUR_MAIN_SMS_API_KEY',   // Main key, NOT a sub-key
///   senderId: 'MaHyp',                 // your registered sender ID
/// );
///
/// // 1. Send OTP
/// final sendResult = await otpService.sendOTP('0244000000');
/// if (sendResult.success) {
///   // Show the "enter code" screen. Arkesel is holding the real code —
///   // you don't have it and don't need it.
/// } else {
///   // sendResult.code / sendResult.message tell you why it failed.
///   // Common ones: 1004 gateway not active, 1005 invalid number,
///   // 1007/1008 insufficient balance.
/// }
///
/// // 2. Later, when the user types in the code they received:
/// final verifyResult = await otpService.verifyOTP('0244000000', userTypedCode);
/// if (verifyResult.success) {
///   // proceed with sign-in / Firebase custom auth, etc.
/// } else {
///   // 1104 = wrong code, 1105 = expired — verifyResult.message has detail
/// }
