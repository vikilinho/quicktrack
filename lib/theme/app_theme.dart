import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const teal = Color(0xFF006A60);
  static const darkTeal = Color(0xFF004D46);
  static const ink = Color(0xFF17201E);
  static const background = Color(0xFFF7F9F8);

  static ThemeData get light {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: teal,
          brightness: Brightness.light,
          surface: const Color(0xFFFBFDFC),
        ).copyWith(
          primary: teal,
          onPrimary: Colors.white,
          primaryContainer: const Color(0xFFBDECE4),
          onPrimaryContainer: const Color(0xFF00201C),
          secondaryContainer: const Color(0xFFDCE5E2),
          surfaceContainerLow: const Color(0xFFF1F4F2),
          surfaceContainerHighest: const Color(0xFFE1E7E4),
          outlineVariant: const Color(0xFFC2CAC7),
          error: const Color(0xFFBA1A1A),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: ink,
          fontSize: 30,
          height: 1.1,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.7,
        ),
        titleLarge: TextStyle(
          color: ink,
          fontSize: 22,
          height: 1.2,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.25,
        ),
        titleMedium: TextStyle(
          color: ink,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: Color(0xFF3E4946), height: 1.45),
        bodyMedium: TextStyle(color: Color(0xFF56625F), height: 1.4),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: ink,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: ink,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: const StadiumBorder(),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant),
    );
  }
}
