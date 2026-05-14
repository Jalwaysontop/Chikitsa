import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChikitsaTheme {
  // ─── Brutalist / Swiss Palette ────────────────────────────────
  static const Color boneWhite = Color(0xFFF3F2EE); // Driftime background
  static const Color pureBlack = Color(0xFF000000);
  static const Color alertOrange = Color(0xFFFF5722); // High contrast accent
  static const Color darkGrey = Color(0xFF333333);

  static ThemeData lightTheme(Locale locale) {
    final bool isHindi = locale.languageCode == 'hi';
    final TextTheme textTheme =
        _buildTextTheme(isDark: false, isHindi: isHindi);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: pureBlack,
      scaffoldBackgroundColor: boneWhite,
      cardColor: boneWhite,
      colorScheme: const ColorScheme.light(
        primary: pureBlack,
        onPrimary: boneWhite,
        secondary: pureBlack,
        onSecondary: boneWhite,
        surface: boneWhite,
        onSurface: pureBlack,
        outline: pureBlack,
        error: alertOrange,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: boneWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: pureBlack, size: 28),
        titleTextStyle: isHindi
            ? GoogleFonts.notoSansDevanagari(
                color: pureBlack,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              )
            : GoogleFonts.archivoBlack(
                color: pureBlack,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.0,
              ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: pureBlack,
          foregroundColor: boneWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: isHindi
              ? GoogleFonts.notoSansDevanagari(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                )
              : GoogleFonts.archivo(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: pureBlack,
          side: const BorderSide(color: pureBlack, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: isHindi
              ? GoogleFonts.notoSansDevanagari(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                )
              : GoogleFonts.archivo(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: pureBlack, width: 2),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: pureBlack, width: 2),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: pureBlack, width: 4),
        ),
        hintStyle: isHindi
            ? GoogleFonts.notoSansDevanagari(color: Colors.black45)
            : GoogleFonts.archivo(color: Colors.black45),
        labelStyle: isHindi
            ? GoogleFonts.notoSansDevanagari(
                color: pureBlack, fontWeight: FontWeight.bold)
            : GoogleFonts.archivo(
                color: pureBlack, fontWeight: FontWeight.bold),
      ),
      iconTheme: const IconThemeData(color: pureBlack, size: 28),
      dividerTheme: const DividerThemeData(
        color: pureBlack,
        thickness: 2,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return boneWhite;
          return pureBlack;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return pureBlack;
          return Colors.transparent;
        }),
        trackOutlineColor: WidgetStateProperty.all(pureBlack),
        trackOutlineWidth: WidgetStateProperty.all(2.0),
      ),
      cardTheme: const CardThemeData(
        color: boneWhite,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: pureBlack, width: 2),
        ),
      ),
    );
  }

  // ─── Brutalist Dark Theme ────────────────────────────────
  // ─── Brutalist Dark Theme ────────────────────────────────
  static ThemeData darkTheme(Locale locale) {
    final bool isHindi = locale.languageCode == 'hi';

    // Softened Dark Palette
    const Color darkBackground = Color(0xFF121212); // Less harsh than #000000
    const Color darkSurface = Color(0xFF1E1E1E); // Slightly lighter for cards
    const Color darkBorder = Color(0xFF333333); // Subtle grey borders
    const Color darkText = Color(0xFFE0E0E0); // Off-white text (not pure white)

    final TextTheme textTheme = _buildTextTheme(isDark: true, isHindi: isHindi);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: darkText,
      scaffoldBackgroundColor: darkBackground,
      cardColor: darkSurface,
      colorScheme: const ColorScheme.dark(
        primary: darkText,
        onPrimary: darkBackground,
        secondary: darkText,
        onSecondary: darkBackground,
        surface: darkSurface,
        onSurface: darkText,
        outline: darkBorder,
        error: alertOrange,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: darkText, size: 28),
        titleTextStyle: isHindi
            ? GoogleFonts.notoSansDevanagari(
                color: darkText,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              )
            : GoogleFonts.archivoBlack(
                color: darkText,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.0,
              ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkText,
          foregroundColor: darkBackground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: isHindi
              ? GoogleFonts.notoSansDevanagari(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                )
              : GoogleFonts.archivo(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkText,
          side: const BorderSide(color: darkBorder, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: isHindi
              ? GoogleFonts.notoSansDevanagari(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                )
              : GoogleFonts.archivo(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C), // Distinct input background
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: darkBorder, width: 2),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: darkBorder, width: 2),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide:
              BorderSide(color: darkText, width: 2), // Highlight on focus
        ),
        hintStyle: isHindi
            ? GoogleFonts.notoSansDevanagari(color: Colors.white38)
            : GoogleFonts.archivo(color: Colors.white38),
        labelStyle: isHindi
            ? GoogleFonts.notoSansDevanagari(
                color: darkText, fontWeight: FontWeight.bold)
            : GoogleFonts.archivo(color: darkText, fontWeight: FontWeight.bold),
      ),
      iconTheme: const IconThemeData(color: darkText, size: 28),
      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 2,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return darkBackground;
          return darkText;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return darkText;
          return Colors.transparent;
        }),
        trackOutlineColor: WidgetStateProperty.all(darkText),
        trackOutlineWidth: WidgetStateProperty.all(2.0),
      ),
      cardTheme: const CardThemeData(
        color: darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: darkBorder, width: 2),
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme(
      {bool isDark = false, bool isHindi = false}) {
    // Colors
    final Color textColor = isDark ? const Color(0xFFE0E0E0) : pureBlack;
    final Color bodyColor = isDark ? const Color(0xFFBDBDBD) : darkGrey;

    // Font selection
    TextStyle Function(
            {TextStyle? textStyle,
            Color? color,
            Color? backgroundColor,
            double? fontSize,
            FontWeight? fontWeight,
            FontStyle? fontStyle,
            double? letterSpacing,
            double? wordSpacing,
            TextBaseline? textBaseline,
            double? height,
            Locale? locale,
            Paint? foreground,
            Paint? background,
            List<Shadow>? shadows,
            List<FontFeature>? fontFeatures,
            TextDecoration? decoration,
            Color? decorationColor,
            TextDecorationStyle? decorationStyle,
            double? decorationThickness}) headlineFont =
        isHindi ? GoogleFonts.notoSansDevanagari : GoogleFonts.archivoBlack;

    TextStyle Function(
            {TextStyle? textStyle,
            Color? color,
            Color? backgroundColor,
            double? fontSize,
            FontWeight? fontWeight,
            FontStyle? fontStyle,
            double? letterSpacing,
            double? wordSpacing,
            TextBaseline? textBaseline,
            double? height,
            Locale? locale,
            Paint? foreground,
            Paint? background,
            List<Shadow>? shadows,
            List<FontFeature>? fontFeatures,
            TextDecoration? decoration,
            Color? decorationColor,
            TextDecorationStyle? decorationStyle,
            double? decorationThickness}) bodyFont =
        isHindi ? GoogleFonts.notoSansDevanagari : GoogleFonts.archivo;

    return TextTheme(
      displayLarge: headlineFont(
        fontSize: 56,
        fontWeight: FontWeight.w900,
        color: textColor,
        letterSpacing: isHindi ? -1.0 : -3.0,
        height: 0.9,
      ),
      displayMedium: headlineFont(
        fontSize: 40,
        fontWeight: FontWeight.w900,
        color: textColor,
        letterSpacing: isHindi ? -0.5 : -2.0,
        height: 0.95,
      ),
      headlineSmall: bodyFont(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: textColor,
        letterSpacing: -0.5,
      ),
      titleLarge: bodyFont(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      titleMedium: bodyFont(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      bodyLarge: bodyFont(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: textColor,
        height: 1.4,
      ),
      bodyMedium: bodyFont(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: bodyColor,
        height: 1.4,
      ),
      bodySmall: bodyFont(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
        letterSpacing: 0.5,
      ),
    );
  }
}
