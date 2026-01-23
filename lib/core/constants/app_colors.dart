import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Brand Colors - Refined teal/cyan palette
  static const Color primaryTurquoise = Color(0xFF00C9D6);
  static const Color primaryTurquoiseLight = Color(0xFF4FE0E8);
  static const Color primaryTurquoiseDark = Color(0xFF00A5B0);

  // Primary Gradient - Softer, more premium feel
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF5CE1E6), // Soft cyan
      Color(0xFF00C9D6), // Turquoise
    ],
  );

  // Light header gradient - Very subtle
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFE8FAFA), // Almost white with hint of cyan
      Color(0xFFD4F5F5), // Very light cyan
    ],
  );

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color background = Color(0xFFF8FAFA); // Slightly cyan-tinted
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textHint = Color(0xFFB2BEC3);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Input Field Colors
  static const Color inputBackground = Color(0xFFF0F9FA);
  static const Color inputBorder = Color(0xFFDFE6E9);
  static const Color inputFocusBorder = Color(0xFF00C9D6);

  // Status Colors
  static const Color success = Color(0xFF00B894);
  static const Color error = Color(0xFFFF7675);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color info = Color(0xFF74B9FF);

  // Social Login Colors
  static const Color google = Color(0xFFDB4437);
  static const Color facebook = Color(0xFF4267B2);
  static const Color twitter = Color(0xFF1DA1F2);
  static const Color apple = Color(0xFF000000);

  // Dashboard Stat Card Gradients - Softer, more refined
  static const LinearGradient bpCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF5CE1E6), // Soft cyan
      Color(0xFF00C9D6), // Turquoise
    ],
  );

  static const LinearGradient medicationCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF74B9FF), // Soft blue
      Color(0xFF0984E3), // Medium blue
    ],
  );

  // Action Card Gradients
  static const LinearGradient nextMedCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF81ECEC), // Light cyan
      Color(0xFF00CEC9), // Teal
    ],
  );

  // Calendar section background
  static const Color calendarBackground = Color(0xFFF0FAFA);
  static const Color calendarSelected = Color(0xFF00C9D6);
  static const Color calendarUnselected = Color(0xFFE0E0E0);
  static const Color calendarToday = Color(0xFF2D3436);

  // Card colors
  static const Color cardTeal = Color(0xFF00C9D6);
  static const Color cardBlue = Color(0xFF0984E3);

  // Shadow - Softer
  static const Color shadow = Color(0x0A000000);
  static const Color cardShadow = Color(0x15000000);
}
