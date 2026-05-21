import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── 색상 팔레트 (더 세련된 보라/남색 계열) ─────────────────
  static const Color primary     = Color(0xFF6C63FF); // 생동감 있는 보라
  static const Color primaryDark = Color(0xFF4A44C4);
  static const Color secondary   = Color(0xFFFF6B9D); // 핑크 포인트
  static const Color accent      = Color(0xFFFFD166); // 골드 강조
  static const Color background  = Color(0xFF0D0D1A); // 더 깊은 다크
  static const Color surface     = Color(0xFF13132A); // 카드 배경
  static const Color card        = Color(0xFF1C1C3A); // 카드 내부
  static const Color cardBright  = Color(0xFF252550); // 밝은 카드
  static const Color success     = Color(0xFF00D4A4); // 청록 성공
  static const Color error       = Color(0xFFFF5C7A);
  static const Color textPrimary    = Color(0xFFF0F0FF); // 살짝 보라빛 흰색
  static const Color textSecondary  = Color(0xFF8888BB);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: error,
      ),
      scaffoldBackgroundColor: background,
      textTheme: GoogleFonts.notoSansKrTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2A2A5A), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withOpacity(0.25),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const TextStyle(
              color: primary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            );
          }
          return const TextStyle(color: textSecondary, fontSize: 11);
        }),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: primary, size: 22);
          }
          return const IconThemeData(color: textSecondary, size: 22);
        }),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: cardBright,
        contentTextStyle: TextStyle(color: textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        ),
      ),
    );
  }
}
