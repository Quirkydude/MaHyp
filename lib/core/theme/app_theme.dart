import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_dimensions.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryTurquoise,
        secondary: AppColors.primaryTurquoiseLight,
        surface: AppColors.white,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.textPrimary,
        onError: AppColors.white,
      ),

      // Scaffold
      scaffoldBackgroundColor: AppColors.background,

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: AppColors.textPrimary,
          size: AppDimensions.iconLarge,
        ),
        titleTextStyle: AppTextStyles.h3,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.h1,
        displayMedium: AppTextStyles.h2,
        displaySmall: AppTextStyles.h3,
        headlineMedium: AppTextStyles.h4,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.button,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing20,
          vertical: AppDimensions.spacing16,
        ),

        // Border styles
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(
            color: AppColors.inputBorder,
            width: AppDimensions.inputBorderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(
            color: AppColors.inputBorder,
            width: AppDimensions.inputBorderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(
            color: AppColors.inputFocusBorder,
            width: AppDimensions.inputFocusBorderWidth,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: AppDimensions.inputBorderWidth,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: AppDimensions.inputFocusBorderWidth,
          ),
        ),

        // Text styles
        labelStyle: AppTextStyles.inputLabel,
        hintStyle: AppTextStyles.inputHint,
        errorStyle: AppTextStyles.error,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryTurquoise,
          foregroundColor: AppColors.white,
          minimumSize: const Size(
            AppDimensions.buttonMinWidth,
            AppDimensions.buttonHeight,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing32,
            vertical: AppDimensions.spacing16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          elevation: 2,
          textStyle: AppTextStyles.button,
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryTurquoise,
          textStyle: AppTextStyles.link,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing16,
            vertical: AppDimensions.spacing12,
          ),
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.primaryTurquoise,
        size: AppDimensions.iconMedium,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: AppDimensions.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
        ),
        margin: const EdgeInsets.symmetric(vertical: AppDimensions.spacing8),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.inputBorder,
        thickness: 1,
        space: AppDimensions.spacing24,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryTurquoise,
        secondary: AppColors.primaryTurquoiseLight,
        surface: const Color(0xFF1E1E1E),
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.white,
        onError: AppColors.white,
      ),

      // Scaffold
      scaffoldBackgroundColor: const Color(0xFF121212),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: AppColors.white,
          size: AppDimensions.iconLarge,
        ),
        titleTextStyle: TextStyle(
          color: AppColors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: AppColors.white),
        bodyMedium: TextStyle(fontSize: 14, color: Color(0xFFB0B0B0)),
        bodySmall: TextStyle(fontSize: 12, color: Color(0xFF909090)),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing20,
          vertical: AppDimensions.spacing16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(
            color: Color(0xFF3C3C3C),
            width: AppDimensions.inputBorderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(
            color: Color(0xFF3C3C3C),
            width: AppDimensions.inputBorderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(
            color: AppColors.primaryTurquoise,
            width: AppDimensions.inputFocusBorderWidth,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: AppDimensions.inputBorderWidth,
          ),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryTurquoise,
          foregroundColor: AppColors.white,
          minimumSize: const Size(
            AppDimensions.buttonMinWidth,
            AppDimensions.buttonHeight,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing32,
            vertical: AppDimensions.spacing16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          elevation: 2,
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryTurquoise,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing16,
            vertical: AppDimensions.spacing12,
          ),
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.primaryTurquoise,
        size: AppDimensions.iconMedium,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: AppDimensions.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
        ),
        margin: const EdgeInsets.symmetric(vertical: AppDimensions.spacing8),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: Color(0xFF3C3C3C),
        thickness: 1,
        space: AppDimensions.spacing24,
      ),
    );
  }
}
