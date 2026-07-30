/// Arkesel OTP configuration.
///
/// Prefer passing secrets at build time:
/// `flutter build apk --dart-define=ARKESEL_API_KEY=... --dart-define=ARKESEL_SENDER_ID=...`
class ArkeselConfig {
  static const String apiKey = String.fromEnvironment(
    'ARKESEL_API_KEY',
    defaultValue: 'cmdwS2RvdVBBRG16aVJ4QW1IT0o',
  );

  static const String senderId = String.fromEnvironment(
    'ARKESEL_SENDER_ID',
    defaultValue: 'KamarTec',
  );
}
