import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const Color scaffoldBg = Color(0xFF0E0E10);
  static const Color surface = Color(0xFF16161A);
  static const Color accent = Color(0xFF64FFDA);
  static const Color headline = Color(0xFFFFFFFF);
  static const Color bodyText = Color(0xFF9E9E9E);

  static ThemeData get dark {
    final base = ThemeData.dark();

    return base.copyWith(
      scaffoldBackgroundColor: scaffoldBg,
      canvasColor: scaffoldBg,
      cardColor: surface,
      primaryColor: scaffoldBg,
      colorScheme: base.colorScheme.copyWith(
        surface: surface,
        secondary: accent,
        onSurface: headline,
      ),
      textTheme: GoogleFonts.interTextTheme(const TextTheme(
        titleLarge: TextStyle(color: headline, fontWeight: FontWeight.w600, fontSize: 18),
        bodyLarge: TextStyle(color: bodyText, fontSize: 14),
        bodySmall: TextStyle(color: bodyText, fontSize: 12),
        headlineSmall: TextStyle(color: headline, fontWeight: FontWeight.w700, fontSize: 16),
      )),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: scaffoldBg,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: InputBorder.none,
        hintStyle: const TextStyle(color: bodyText, fontSize: 24),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: BorderSide(color: accent.withOpacity(0.9)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      cardTheme: const CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        margin: EdgeInsets.zero,
      ),
    );
  }
}
