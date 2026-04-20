import 'package:flutter/material.dart';

class AppThemeData {
  final Color bgDark, bgCard, bgElevated;
  final Color textPrimary, textSecondary, textMuted;
  final Color divider;
  final bool isDark;
  const AppThemeData({required this.bgDark, required this.bgCard, required this.bgElevated, required this.textPrimary, required this.textSecondary, required this.textMuted, required this.divider, required this.isDark});
}

class AppTheme {
  // Accents — same in both themes
  static const Color accentNeon   = Color(0xFF00C87A);
  static const Color accentOrange = Color(0xFFFF6B35);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentBlue   = Color(0xFF3B82F6);
  static const Color accentPink   = Color(0xFFEC4899);
  static const Color accentAmber  = Color(0xFFF59E0B);
  static const Color errorRed     = Color(0xFFEF4444);
  static const Color successGreen = Color(0xFF22C55E);

  // Dark palette
  static const Color _dBg  = Color(0xFF0A0A0F), _dCard = Color(0xFF12121A), _dElev = Color(0xFF1A1A26);
  static const Color _dTxt = Color(0xFFFFFFFF), _dTxt2 = Color(0xFFB0B0C8), _dMut  = Color(0xFF5A5A7A);
  static const Color _dDiv = Color(0xFF1E1E2E);

  // Light palette
  static const Color _lBg  = Color(0xFFF4F6FA), _lCard = Color(0xFFFFFFFF), _lElev = Color(0xFFEEF0F7);
  static const Color _lTxt = Color(0xFF0D0D1A), _lTxt2 = Color(0xFF4A4A6A), _lMut  = Color(0xFF9494B0);
  static const Color _lDiv = Color(0xFFE2E4EF);

  // Context accessor
  static AppThemeData of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? _dark : _light;
  }

  static const AppThemeData _dark  = AppThemeData(bgDark: _dBg, bgCard: _dCard, bgElevated: _dElev, textPrimary: _dTxt, textSecondary: _dTxt2, textMuted: _dMut, divider: _dDiv, isDark: true);
  static const AppThemeData _light = AppThemeData(bgDark: _lBg, bgCard: _lCard, bgElevated: _lElev, textPrimary: _lTxt, textSecondary: _lTxt2, textMuted: _lMut, divider: _lDiv, isDark: false);

  static ThemeData get darkTheme  => _buildTheme(Brightness.dark,  _dBg,  _dCard, _dElev, _dTxt, _dTxt2, _dMut, _dDiv);
  static ThemeData get lightTheme => _buildTheme(Brightness.light, _lBg,  _lCard, _lElev, _lTxt, _lTxt2, _lMut, _lDiv);

  static ThemeData _buildTheme(Brightness br, Color bg, Color card, Color elev, Color txt, Color txt2, Color mut, Color div) {
    return ThemeData(
      useMaterial3: true, brightness: br, scaffoldBackgroundColor: bg, fontFamily: 'Poppins',
      colorScheme: ColorScheme(brightness: br, primary: accentNeon, secondary: accentOrange, surface: card, background: bg, error: errorRed, onPrimary: Colors.black, onSecondary: Colors.black, onSurface: txt, onBackground: txt, onError: Colors.white),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: elev,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: div)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: div)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: accentNeon, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: errorRed)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: errorRed, width: 1.5)),
        hintStyle: TextStyle(color: mut, fontFamily: 'Poppins', fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: accentNeon, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0, textStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 16))),
      textTheme: TextTheme(
        displayLarge:  TextStyle(fontFamily: 'Poppins', fontSize: 40, fontWeight: FontWeight.w800, color: txt),
        displayMedium: TextStyle(fontFamily: 'Poppins', fontSize: 32, fontWeight: FontWeight.w700, color: txt),
        headlineLarge: TextStyle(fontFamily: 'Poppins', fontSize: 26, fontWeight: FontWeight.w700, color: txt),
        headlineMedium:TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600, color: txt),
        headlineSmall: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600, color: txt),
        bodyLarge:     TextStyle(fontFamily: 'Poppins', fontSize: 16, color: txt2),
        bodyMedium:    TextStyle(fontFamily: 'Poppins', fontSize: 14, color: mut),
        bodySmall:     TextStyle(fontFamily: 'Poppins', fontSize: 12, color: mut),
        labelLarge:    TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: txt),
      ),
      appBarTheme: AppBarTheme(backgroundColor: bg, foregroundColor: txt, elevation: 0, iconTheme: IconThemeData(color: txt)),
    );
  }

  // Legacy statics for backward compat
  static const Color bgDark = _dBg; static const Color bgCard = _dCard; static const Color bgElevated = _dElev;
  static const Color textPrimary = _dTxt; static const Color textSecondary = _dTxt2; static const Color textMuted = _dMut; static const Color divider = _dDiv;
}