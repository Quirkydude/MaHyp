import 'dart:convert';
import 'dart:developer';
import 'dart:math' show Random;

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'otp_result.dart';

/// Moolre SMS OTP integration.
///
/// Moolre provides SMS delivery only (no server-side OTP verify API), so this
/// service generates a code locally, stores it with an expiry, sends it via
/// Moolre's Send SMS API, then verifies the user-entered code locally.
///
/// API docs: https://docs.moolre.com/ai/send-sms.html
class MoolreOtpService {
  final Dio _dio;
  final String _baseUrl;
  final String _vasKey;
  final String _senderId;
  final int _otpLength;
  final int _expiryMinutes;

  static const _otpPrefsPrefix = 'moolre_otp_';

  MoolreOtpService({
    required String vasKey,
    required String senderId,
    String? baseUrl,
    Dio? dio,
    int otpLength = 6,
    int expiryMinutes = 5,
  })  : _vasKey = vasKey,
        _senderId = senderId,
        _baseUrl = baseUrl ?? 'https://api.moolre.com',
        _dio = dio ?? Dio(),
        _otpLength = otpLength,
        _expiryMinutes = expiryMinutes;

  bool get isConfigured => _vasKey.isNotEmpty && _senderId.isNotEmpty;

  /// Generates an OTP, stores it locally, and sends it via Moolre SMS.
  Future<OtpResult> sendOTP(String phoneNumber) async {
    if (!isConfigured) {
      return OtpResult(
        success: false,
        message:
            'Moolre is not configured. Add your VAS key and Sender ID in lib/core/config/moolre_config.dart',
      );
    }

    final formattedPhone = _formatPhoneNumber(phoneNumber);
    final otpCode = _generateOtp(_otpLength);

    final smsResult = await _sendSms(
      recipient: formattedPhone,
      message:
          'Your MaHyp verification code is $otpCode. Do not share this with anyone.',
    );

    if (!smsResult.success) {
      return smsResult;
    }

    await _storeOtp(formattedPhone, otpCode);
    log('OTP sent via Moolre to $formattedPhone');
    return OtpResult(success: true, code: smsResult.code, message: 'OTP sent');
  }

  /// Verifies the code the user entered against the locally stored OTP.
  Future<OtpResult> verifyOTP(String phoneNumber, String otpCode) async {
    final formattedPhone = _formatPhoneNumber(phoneNumber);
    final stored = await _readStoredOtp(formattedPhone);

    if (stored == null) {
      return OtpResult(
        success: false,
        message: 'No OTP found. Please request a new code.',
      );
    }

    if (DateTime.now().millisecondsSinceEpoch > stored.expiresAtMs) {
      await _clearOtp(formattedPhone);
      return OtpResult(
        success: false,
        message: 'OTP has expired. Please request a new code.',
      );
    }

    if (stored.code != otpCode.trim()) {
      return OtpResult(
        success: false,
        message: 'Invalid OTP. Please try again.',
      );
    }

    await _clearOtp(formattedPhone);
    log('OTP verified for $formattedPhone');
    return OtpResult(success: true, message: 'OTP verified');
  }

  Future<OtpResult> _sendSms({
    required String recipient,
    required String message,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/open/sms/send',
        options: Options(
          headers: {
            'X-API-VASKEY': _vasKey,
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'type': 1,
          'senderid': _senderId,
          'messages': [
            {
              'recipient': recipient,
              'message': message,
            },
          ],
        },
      );

      final data = response.data;
      final status = data is Map ? data['status'] : null;
      final respCode = data is Map ? data['code']?.toString() : null;
      final respMessage = data is Map ? data['message']?.toString() : null;

      final ok = response.statusCode == 200 && status == 1 && respCode == 'SMS01';

      if (!ok) {
        log(
          'Moolre SMS rejected for $recipient: [$respCode] $respMessage',
        );
      }

      return OtpResult(
        success: ok,
        code: respCode,
        message: respMessage ?? (ok ? 'Success' : 'Failed to send SMS'),
      );
    } on DioException catch (e) {
      final respData = e.response?.data;
      log(
        'DioException sending SMS to $recipient: '
        'status=${e.response?.statusCode} body=$respData error=${e.message}',
      );
      return OtpResult(
        success: false,
        code: e.response?.statusCode?.toString(),
        message: _extractErrorMessage(respData) ?? e.message,
      );
    } catch (e) {
      log('Unexpected error sending SMS to $recipient: $e');
      return OtpResult(success: false, message: e.toString());
    }
  }

  String _generateOtp(int length) {
    final random = Random.secure();
    return List.generate(length, (_) => random.nextInt(10)).join();
  }

  Future<void> _storeOtp(String phone, String code) async {
    final prefs = await SharedPreferences.getInstance();
    final expiresAt = DateTime.now()
        .add(Duration(minutes: _expiryMinutes))
        .millisecondsSinceEpoch;

    await prefs.setString(
      '$_otpPrefsPrefix$phone',
      jsonEncode({'code': code, 'expiresAt': expiresAt}),
    );
  }

  Future<_StoredOtp?> _readStoredOtp(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_otpPrefsPrefix$phone');
    if (raw == null) return null;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return _StoredOtp(
        code: map['code'] as String,
        expiresAtMs: map['expiresAt'] as int,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _clearOtp(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_otpPrefsPrefix$phone');
  }

  String? _extractErrorMessage(dynamic respData) {
    if (respData is Map) {
      return respData['message']?.toString();
    }
    return null;
  }

  /// Moolre expects local Ghana format: 0XXXXXXXXX
  String _formatPhoneNumber(String phoneNumber) {
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.startsWith('233') && digitsOnly.length >= 12) {
      return '0${digitsOnly.substring(3)}';
    }
    if (digitsOnly.startsWith('0')) {
      return digitsOnly;
    }
    return '0$digitsOnly';
  }
}

class _StoredOtp {
  final String code;
  final int expiresAtMs;

  _StoredOtp({required this.code, required this.expiresAtMs});
}
