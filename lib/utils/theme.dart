import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────
// 테마별 색상 팔레트
// ─────────────────────────────────────────────────────────────
class AppThemeColors {
  final Color primary;
  final Color primaryDark;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color card;
  final Color cardBright;
  final Color success;
  final Color error;
  final Color textPrimary;
  final Color textSecondary;
  final String name;
  final String emoji;
  final bool isLight;

  const AppThemeColors({
    required this.primary,
    required this.primaryDark,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.card,
    required this.cardBright,
    required this.success,
    required this.error,
    required this.textPrimary,
    required this.textSecondary,
    required this.name,
    required this.emoji,
    this.isLight = false,
  });
}

// ─────────────────────────────────────────────────────────────
// AppTheme — 다중 테마 지원
// ─────────────────────────────────────────────────────────────
class AppTheme {
  // ── 테마 0: 퍼플 나이트 (기본) ──────────────────────────────
  static const AppThemeColors purpleColors = AppThemeColors(
    primary:       Color(0xFF6C63FF),
    primaryDark:   Color(0xFF4A44C4),
    secondary:     Color(0xFFFF6B9D),
    accent:        Color(0xFFFFD166),
    background:    Color(0xFF0D0D1A),
    surface:       Color(0xFF13132A),
    card:          Color(0xFF1C1C3A),
    cardBright:    Color(0xFF252550),
    success:       Color(0xFF00D4A4),
    error:         Color(0xFFFF5C7A),
    textPrimary:   Color(0xFFF0F0FF),
    textSecondary: Color(0xFF8888BB),
    name:          '퍼플 나이트',
    emoji:         '🌌',
  );

  // ── 테마 1: 황금 사막 ────────────────────────────────────────
  static const AppThemeColors desertColors = AppThemeColors(
    primary:       Color(0xFFFFB800),
    primaryDark:   Color(0xFFCC9200),
    secondary:     Color(0xFFFF6B35),
    accent:        Color(0xFFFFEC7A),
    background:    Color(0xFF0F0A00),
    surface:       Color(0xFF1A1200),
    card:          Color(0xFF241A00),
    cardBright:    Color(0xFF2E2300),
    success:       Color(0xFF7AB648),
    error:         Color(0xFFFF4D4D),
    textPrimary:   Color(0xFFFFF8E7),
    textSecondary: Color(0xFFAA8844),
    name:          '황금 사막',
    emoji:         '🏜️',
  );

  // ── 테마 2: 사이버 네온 ──────────────────────────────────────
  static const AppThemeColors cyberColors = AppThemeColors(
    primary:       Color(0xFF00F5FF),
    primaryDark:   Color(0xFF00B8CC),
    secondary:     Color(0xFFFF00C8),
    accent:        Color(0xFFAAFF00),
    background:    Color(0xFF000000),
    surface:       Color(0xFF080808),
    card:          Color(0xFF0E0E0E),
    cardBright:    Color(0xFF161616),
    success:       Color(0xFF00FF88),
    error:         Color(0xFFFF2244),
    textPrimary:   Color(0xFFE8FFFF),
    textSecondary: Color(0xFF3A8899),
    name:          '사이버 네온',
    emoji:         '⚡',
  );

  // ── 테마 3: 서니 데이 (라이트) ──────────────────────────────
  static const AppThemeColors sunnyColors = AppThemeColors(
    primary:       Color(0xFF5A52E8),
    primaryDark:   Color(0xFF3D37B8),
    secondary:     Color(0xFFFF5A8E),
    accent:        Color(0xFFFFB300),
    background:    Color(0xFFF5F5FF),
    surface:       Color(0xFFFFFFFF),
    card:          Color(0xFFEEEEFF),
    cardBright:    Color(0xFFE4E4FF),
    success:       Color(0xFF00B896),
    error:         Color(0xFFFF3355),
    textPrimary:   Color(0xFF1A1A3A),
    textSecondary: Color(0xFF7777AA),
    name:          '서니 데이',
    emoji:         '☀️',
    isLight:       true,
  );

  static const List<AppThemeColors> allThemes = [purpleColors, desertColors, cyberColors, sunnyColors];

  // ── 현재 활성 테마 (AppProvider가 관리) ──────────────────────
  static AppThemeColors _current = purpleColors;
  static AppThemeColors get colors => _current;

  static void setTheme(int index) {
    _current = allThemes[index.clamp(0, allThemes.length - 1)];
  }

  // ── 하위 호환 정적 접근자 (기존 코드에서 AppTheme.primary 등으로 사용) ──
  static Color get primary       => _current.primary;
  static Color get primaryDark   => _current.primaryDark;
  static Color get secondary     => _current.secondary;
  static Color get accent        => _current.accent;
  static Color get background    => _current.background;
  static Color get surface       => _current.surface;
  static Color get card          => _current.card;
  static Color get cardBright    => _current.cardBright;
  static Color get success       => _current.success;
  static Color get error         => _current.error;
  static Color get textPrimary   => _current.textPrimary;
  static Color get textSecondary => _current.textSecondary;

  // ── ThemeData 생성 ────────────────────────────────────────────
  static ThemeData buildTheme(AppThemeColors c) {
    final baseTextTheme = c.isLight ? ThemeData.light().textTheme : ThemeData.dark().textTheme;
    final colorScheme = c.isLight
        ? ColorScheme.light(
            primary: c.primary,
            secondary: c.secondary,
            surface: c.surface,
            error: c.error,
          )
        : ColorScheme.dark(
            primary: c.primary,
            secondary: c.secondary,
            surface: c.surface,
            error: c.error,
          );

    return ThemeData(
      useMaterial3: true,
      brightness: c.isLight ? Brightness.light : Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: c.background,
      textTheme: GoogleFonts.notoSansKrTextTheme(baseTextTheme).apply(
        bodyColor: c.textPrimary,
        displayColor: c.textPrimary,
      ),
      cardTheme: CardThemeData(
        color: c.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: c.primary.withOpacity(0.18), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.isLight ? Colors.white : c.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.surface,
        foregroundColor: c.textPrimary,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: c.isLight ? Brightness.dark : Brightness.light,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surface,
        indicatorColor: c.primary.withOpacity(0.18),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return TextStyle(color: c.primary, fontSize: 11, fontWeight: FontWeight.bold);
          }
          return TextStyle(color: c.textSecondary, fontSize: 11);
        }),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return IconThemeData(color: c.primary, size: 22);
          }
          return IconThemeData(color: c.textSecondary, size: 22);
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.cardBright,
        contentTextStyle: TextStyle(color: c.textPrimary),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  // 기존 호환
  static ThemeData get darkTheme => buildTheme(_current);
}
