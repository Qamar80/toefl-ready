import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness b) {
    final isDark = b == Brightness.dark;
    final scheme = ColorScheme.fromSeed(seedColor: AppColors.indigo600, brightness: b).copyWith(
      primary: AppColors.indigo600,
      surface: isDark ? const Color(0xFF1A1D2E) : Colors.white,
    );
    final base = isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;
    return ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? const Color(0xFF0F1220) : AppColors.bg,
      textTheme: GoogleFonts.interTextTheme(base),
      dividerColor: isDark ? Colors.white12 : AppColors.border,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
            fontSize: 17, fontWeight: FontWeight.w600, color: scheme.onSurface),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: AppColors.indigo600.withOpacity(.12),
        labelTextStyle: WidgetStatePropertyAll(
            GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500)),
      ),
    );
  }
}
