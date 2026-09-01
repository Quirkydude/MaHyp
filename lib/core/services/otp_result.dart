/// Result wrapper so callers can distinguish OTP send/verify outcomes.
class OtpResult {
  final bool success;
  final String? code;
  final String? message;

  OtpResult({required this.success, this.code, this.message});

  @override
  String toString() =>
      'OtpResult(success: $success, code: $code, message: $message)';
}
