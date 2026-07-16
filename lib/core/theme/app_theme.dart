import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Brand accents (constant across light & dark) ────────────────────────────
const kNavy = Color(0xFF0A0F2C);
const kNavySoft = Color(0xFF1C2244);
const kBlue = Color(0xFFB1CDD9);
const kBlueDeep = Color(0xFF6E96A8);
const kSage = Color(0xFFE3DFB7);
const kSageDeep = Color(0xFF9B9560);
const kSuccessGreen = Color(0xFF3F9D6E);
const kWarmAmber = Color(0xFFD9A441);

/// Semantic colors that swap between light and dark. Access via
/// `context.colors` (see the [AppColorsX] extension below). Brand accents above
/// stay constant; these are surfaces / text / borders that must flip.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.pageBg,
    required this.surface,
    required this.surfaceAlt,
    required this.brandFill,
    required this.onBrand,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
  });

  final Color pageBg;
  final Color surface; // default card / sheet
  final Color surfaceAlt; // subtly tinted card (e.g. the daily tip)
  final Color brandFill; // filled "hero" cards (Reset, upgrade, …)
  final Color onBrand; // content on brandFill
  final Color textPrimary;
  final Color textSecondary;
  final Color border;

  static const light = AppColors(
    pageBg: Color(0xFFF4F5F8),
    surface: Colors.white,
    surfaceAlt: Color(0xFFF3F6F8),
    brandFill: kNavy,
    onBrand: Colors.white,
    textPrimary: kNavy,
    textSecondary: Color(0xFF5B6178),
    border: Color(0xFFE4E7EF),
  );

  static const dark = AppColors(
    pageBg: Color(0xFF080B1C),
    surface: Color(0xFF141A33),
    surfaceAlt: Color(0xFF11162E),
    brandFill: Color(0xFF1B2347),
    onBrand: Colors.white,
    textPrimary: Color(0xFFF4F5F8),
    textSecondary: Color(0xFF9AA6C4),
    border: Color(0xFF283056),
  );

  @override
  AppColors copyWith({
    Color? pageBg,
    Color? surface,
    Color? surfaceAlt,
    Color? brandFill,
    Color? onBrand,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
  }) => AppColors(
    pageBg: pageBg ?? this.pageBg,
    surface: surface ?? this.surface,
    surfaceAlt: surfaceAlt ?? this.surfaceAlt,
    brandFill: brandFill ?? this.brandFill,
    onBrand: onBrand ?? this.onBrand,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    border: border ?? this.border,
  );

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      pageBg: Color.lerp(pageBg, other.pageBg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      brandFill: Color.lerp(brandFill, other.brandFill, t)!,
      onBrand: Color.lerp(onBrand, other.onBrand, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
    );
  }
}

extension AppColorsX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}

class AppTheme {
  static ThemeData get light => _build(Brightness.light, AppColors.light);
  static ThemeData get dark => _build(Brightness.dark, AppColors.dark);

  static TextTheme _buildTextTheme(TextTheme base, AppColors c) {
    final heading = GoogleFonts.ralewayTextTheme(base);
    final body = GoogleFonts.poppinsTextTheme(base);
    return base.copyWith(
      displayLarge: heading.displayLarge?.copyWith(
        color: c.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      displayMedium: heading.displayMedium?.copyWith(
        color: c.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      displaySmall: heading.displaySmall?.copyWith(
        color: c.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: heading.headlineLarge?.copyWith(
        color: c.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 28,
      ),
      headlineMedium: heading.headlineMedium?.copyWith(
        color: c.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 22,
      ),
      headlineSmall: heading.headlineSmall?.copyWith(
        color: c.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      titleLarge: heading.titleLarge?.copyWith(
        color: c.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      titleMedium: body.titleMedium?.copyWith(
        color: c.textPrimary,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      titleSmall: body.titleSmall?.copyWith(
        color: c.textPrimary,
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ),
      bodyLarge: body.bodyLarge?.copyWith(
        color: c.textPrimary,
        fontWeight: FontWeight.w300,
        fontSize: 15,
      ),
      bodyMedium: body.bodyMedium?.copyWith(
        color: c.textPrimary,
        fontWeight: FontWeight.w300,
        fontSize: 14,
      ),
      bodySmall: body.bodySmall?.copyWith(
        color: c.textSecondary,
        fontWeight: FontWeight.w300,
        fontSize: 12,
      ),
      labelLarge: body.labelLarge?.copyWith(
        color: c.textPrimary,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      labelMedium: body.labelMedium?.copyWith(
        color: c.textSecondary,
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      labelSmall: body.labelSmall?.copyWith(
        color: c.textSecondary,
        fontWeight: FontWeight.w400,
        fontSize: 11,
      ),
    );
  }

  static ThemeData _build(Brightness brightness, AppColors c) {
    final base = ThemeData(brightness: brightness, useMaterial3: true);
    final isDark = brightness == Brightness.dark;
    return base.copyWith(
      extensions: [c],
      colorScheme: ColorScheme.fromSeed(
        seedColor: kNavy,
        brightness: brightness,
        primary: isDark ? kBlue : kNavy,
        secondary: kBlueDeep,
        surface: c.surface,
        onSurface: c.textPrimary,
      ),
      scaffoldBackgroundColor: c.pageBg,
      textTheme: _buildTextTheme(base.textTheme, c),
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: c.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: isDark ? kBlue : kNavy,
          foregroundColor: isDark ? kNavy : Colors.white,
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
          foregroundColor: c.textPrimary,
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: c.border),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isDark ? kBlue : kNavy,
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? kBlue : kNavy, width: 2),
        ),
        filled: true,
        fillColor: c.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      dividerTheme: DividerThemeData(color: c.border, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: c.surface,
        foregroundColor: c.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.raleway(
          color: c.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
