/// Moolre SMS configuration.
///
/// Fill in your credentials below, or pass them at build time:
/// `flutter run --dart-define=MOOLRE_VAS_KEY=your_key --dart-define=MOOLRE_SENDER_ID=MaHyp`
///
/// Get your VAS key and approve your Sender ID at https://app.moolre.com
class MoolreConfig {
  /// SMS API VAS key (sent as `X-API-VASKEY` header).
  static const String vasKey = String.fromEnvironment(
    'MOOLRE_VAS_KEY',
    defaultValue: 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ2YXNpZCI6MTI3MzcsImV4cCI6MTk1NjUyNzk5OX0.yLQPpAh0mYw3VmXe3oRB4LLix3Ksk-sin_Z4wgAtNmo',
  );

  /// Registered and approved Sender ID (max 11 characters).
  static const String senderId = String.fromEnvironment(
    'MOOLRE_SENDER_ID',
    defaultValue: 'KamarTec',
  );

  /// Set to true to use Moolre sandbox instead of production.
  static const bool useSandbox = bool.fromEnvironment(
    'MOOLRE_USE_SANDBOX',
    defaultValue: false,
  );

  static String get baseUrl => useSandbox
      ? 'https://sandbox.moolre.com'
      : 'https://api.moolre.com';

  static bool get isConfigured => vasKey.isNotEmpty && senderId.isNotEmpty;
}
