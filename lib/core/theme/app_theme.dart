import 'package:flutter/material.dart';

/// Design tokens, color schemes, and theme generation for Awrad.
///
/// Features a curated Islamic palette: deep forest emerald green,
/// warm golden sand accents, soft parchment light surfaces, and
/// deep night dark surfaces.
abstract final class AppTheme {
  // ── Brand Colors ───────────────────────────────────────────────────────────
  static const Color emeraldPrimary = Color(0xFF1B4D3E);
  static const Color emeraldLight = Color(0xFF2D6A4F);
  static const Color emeraldDark = Color(0xFF0F3227);

  static const Color goldAccent = Color(0xFFC5A059);
  static const Color goldLight = Color(0xFFDFBF7A);
  static const Color goldDark = Color(0xFFA67C2E);

  // Light Palette
  static const Color lightBackground = Color(0xFFF9F8F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF0EDE5);
  static const Color lightTextPrimary = Color(0xFF1E2824);
  static const Color lightTextSecondary = Color(0xFF5A6B63);

  // Dark Palette
  static const Color darkBackground = Color(0xFF101614);
  static const Color darkSurface = Color(0xFF18221E);
  static const Color darkSurfaceVariant = Color(0xFF212E29);
  static const Color darkTextPrimary = Color(0xFFF0F4F2);
  static const Color darkTextSecondary = Color(0xFF9EABA4);

  /// Resolves the actual font family name for Flutter typography.
  /// If [fontFamily] is 'System' or empty, returns null to use platform default.
  static String? resolveFontFamily(String fontFamily) {
    if (fontFamily.isEmpty || fontFamily.toLowerCase() == 'system') {
      return null;
    }
    return fontFamily;
  }

  /// Builds the Light Theme with the specified [fontFamily] and [fontScale].
  static ThemeData light({
    String fontFamily = 'Amiri',
    double fontScale = 1.0,
  }) {
    final effectiveFont = resolveFontFamily(fontFamily);

    final colorScheme = ColorScheme.light(
      primary: emeraldPrimary,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFD4EDE0),
      onPrimaryContainer: emeraldDark,
      secondary: goldAccent,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFF5EAC9),
      onSecondaryContainer: goldDark,
      surface: lightSurface,
      onSurface: lightTextPrimary,
      surfaceContainerHighest: lightSurfaceVariant,
      onSurfaceVariant: lightTextSecondary,
      error: const Color(0xFFBA1A1A),
      onError: Colors.white,
    );

    final baseTextTheme = _buildTextTheme(
      colorScheme.onSurface,
      colorScheme.onSurfaceVariant,
      effectiveFont,
      fontScale,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: lightBackground,
      fontFamily: effectiveFont,
      textTheme: baseTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: lightBackground,
        foregroundColor: lightTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: effectiveFont,
          fontSize: 20 * fontScale,
          fontWeight: FontWeight.bold,
          color: emeraldPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 1.5,
        shadowColor: Colors.black.withAlpha(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE8E5DD), width: 1),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: lightSurface,
        indicatorColor: emeraldPrimary.withAlpha(30),
        elevation: 3,
        shadowColor: Colors.black.withAlpha(30),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: effectiveFont,
            fontSize: 12 * fontScale,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? emeraldPrimary : lightTextSecondary,
          );
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE8E5DD),
        thickness: 1,
      ),
    );
  }

  /// Builds the Dark Theme with the specified [fontFamily] and [fontScale].
  static ThemeData dark({
    String fontFamily = 'Amiri',
    double fontScale = 1.0,
  }) {
    final effectiveFont = resolveFontFamily(fontFamily);

    final colorScheme = ColorScheme.dark(
      primary: emeraldLight,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFF17382B),
      onPrimaryContainer: const Color(0xFF98E2BD),
      secondary: goldLight,
      onSecondary: const Color(0xFF382900),
      secondaryContainer: const Color(0xFF4C3C15),
      onSecondaryContainer: const Color(0xFFF9DF98),
      surface: darkSurface,
      onSurface: darkTextPrimary,
      surfaceContainerHighest: darkSurfaceVariant,
      onSurfaceVariant: darkTextSecondary,
      error: const Color(0xFFFFB4AB),
      onError: const Color(0xFF690005),
    );

    final baseTextTheme = _buildTextTheme(
      colorScheme.onSurface,
      colorScheme.onSurfaceVariant,
      effectiveFont,
      fontScale,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkBackground,
      fontFamily: effectiveFont,
      textTheme: baseTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: effectiveFont,
          fontSize: 20 * fontScale,
          fontWeight: FontWeight.bold,
          color: goldLight,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 2,
        shadowColor: Colors.black.withAlpha(80),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withAlpha(20), width: 1),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkSurface,
        indicatorColor: emeraldLight.withAlpha(60),
        elevation: 4,
        shadowColor: Colors.black.withAlpha(80),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: effectiveFont,
            fontSize: 12 * fontScale,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? goldLight : darkTextSecondary,
          );
        }),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withAlpha(25),
        thickness: 1,
      ),
    );
  }

  static TextTheme _buildTextTheme(
    Color primaryTextColor,
    Color secondaryTextColor,
    String? fontFamily,
    double fontScale,
  ) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 32 * fontScale,
        fontWeight: FontWeight.bold,
        color: primaryTextColor,
        height: 1.6,
      ),
      displayMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 26 * fontScale,
        fontWeight: FontWeight.bold,
        color: primaryTextColor,
        height: 1.6,
      ),
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 22 * fontScale,
        fontWeight: FontWeight.w700,
        color: primaryTextColor,
        height: 1.5,
      ),
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 19 * fontScale,
        fontWeight: FontWeight.w700,
        color: primaryTextColor,
        height: 1.4,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16 * fontScale,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
        height: 1.4,
      ),
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16 * fontScale,
        fontWeight: FontWeight.normal,
        color: primaryTextColor,
        height: 1.7,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14 * fontScale,
        fontWeight: FontWeight.normal,
        color: secondaryTextColor,
        height: 1.6,
      ),
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14 * fontScale,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 11 * fontScale,
        fontWeight: FontWeight.w500,
        color: secondaryTextColor,
      ),
    );
  }
}
