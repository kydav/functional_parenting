import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Brand palette (from the Functional Parenting style guide) ───────────────
// Deep navy — primary brand + text + dark surfaces.
const kNavy = Color(0xFF0A0F2C);
const kNavySoft = Color(0xFF1C2244);
// Calm light blue — secondary accent, tints, highlights.
const kBlue = Color(0xFFB1CDD9);
const kBlueDeep = Color(0xFF6E96A8); // usable-on-white variant of the blue
// Warm sage/cream — supportive accent for softer moments.
const kSage = Color(0xFFE3DFB7);
const kSageDeep = Color(0xFF9B9560);
// Near-white page background (the 3rd swatch — its hex label was a typo).
const kBgPage = Color(0xFFF4F5F8);

const kTextPrimary = kNavy;
const kTextSecondary = Color(0xFF5B6178);
const kBorderColor = Color(0xFFE4E7EF);
const kSuccessGreen = Color(0xFF3F9D6E);
const kWarmAmber = Color(0xFFD9A441);

class AppTheme {
  /// Raleway for display/headings, Poppins for body — per the style guide.
  static TextTheme _buildTextTheme(TextTheme base) {
    final heading = GoogleFonts.ralewayTextTheme(base);
    final body = GoogleFonts.poppinsTextTheme(base);
    return base.copyWith(
      displayLarge: heading.displayLarge?.copyWith(
        color: kTextPrimary,
        fontWeight: FontWeight.w700,
      ),
      displayMedium: heading.displayMedium?.copyWith(
        color: kTextPrimary,
        fontWeight: FontWeight.w700,
      ),
      displaySmall: heading.displaySmall?.copyWith(
        color: kTextPrimary,
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: heading.headlineLarge?.copyWith(
        color: kTextPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 28,
      ),
      headlineMedium: heading.headlineMedium?.copyWith(
        color: kTextPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 22,
      ),
      headlineSmall: heading.headlineSmall?.copyWith(
        color: kTextPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      titleLarge: heading.titleLarge?.copyWith(
        color: kTextPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      titleMedium: body.titleMedium?.copyWith(
        color: kTextPrimary,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      titleSmall: body.titleSmall?.copyWith(
        color: kTextPrimary,
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ),
      bodyLarge: body.bodyLarge?.copyWith(
        color: kTextPrimary,
        fontWeight: FontWeight.w300,
        fontSize: 15,
      ),
      bodyMedium: body.bodyMedium?.copyWith(
        color: kTextPrimary,
        fontWeight: FontWeight.w300,
        fontSize: 14,
      ),
      bodySmall: body.bodySmall?.copyWith(
        color: kTextSecondary,
        fontWeight: FontWeight.w300,
        fontSize: 12,
      ),
      labelLarge: body.labelLarge?.copyWith(
        color: kTextPrimary,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      labelMedium: body.labelMedium?.copyWith(
        color: kTextSecondary,
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      labelSmall: body.labelSmall?.copyWith(
        color: kTextSecondary,
        fontWeight: FontWeight.w400,
        fontSize: 11,
      ),
    );
  }

  static ThemeData get light {
    final base = ThemeData(brightness: Brightness.light, useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: kNavy,
        primary: kNavy,
        secondary: kBlueDeep,
        surface: Colors.white,
        onSurface: kTextPrimary,
      ),
      scaffoldBackgroundColor: kBgPage,
      textTheme: _buildTextTheme(base.textTheme),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: kBorderColor),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: kNavy,
          foregroundColor: Colors.white,
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: kNavy,
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: kBorderColor),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: kNavy,
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kNavy, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      dividerTheme: const DividerThemeData(color: kBorderColor, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: kTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.raleway(
          color: kTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
