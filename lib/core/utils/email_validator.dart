/// Shared email validation used by login, signup, and forgot-password.
class EmailValidator {
  static final RegExp _emailRegex = RegExp(
    r'^[\w\.\+\-]+@([\w\-]+\.)+[\w\-]{2,}$',
  );
  
  static final RegExp _phoneRegex = RegExp(
    r'^\+?[0-9]{7,15}$',
  );

  static String? validate(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) {
      return 'Please enter your email or mobile number';
    }
    
    final isEmail = _emailRegex.hasMatch(input);
    final isPhone = _phoneRegex.hasMatch(input);
    
    if (!isEmail && !isPhone) {
      return 'Please enter a valid email or mobile number';
    }
    return null;
  }
}
