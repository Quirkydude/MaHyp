/// Shared email validation used by login, signup, and forgot-password.
class EmailValidator {
  static final RegExp _emailRegex = RegExp(
    r'^[\w\.\+\-]+@([\w\-]+\.)+[\w\-]{2,}$',
  );

  static String? validate(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Please enter your email';
    }
    if (!_emailRegex.hasMatch(email)) {
      return 'Please enter a valid email';
    }
    return null;
  }
}
