import 'package:flutter/material.dart';

/// هوية النظام: كلاسيكية حديثة — أخضر داكن وذهبي، خط أميري للعناوين،
/// بطاقات بحواف رفيعة وخط ذهبي علوي، وتباعد أنيق.
class AppColors {
  final bool isDark;
  final Color primary;
  final Color primaryMid;
  final Color primaryLight;
  final Color primaryDark;
  final Color gold;
  final Color goldLight;
  final Color goldDark;
  final Color ok;
  final Color warn;
  final Color err;
  final Color info;
  final Color bg;
  final Color card;
  final Color surf;
  final Color tx;
  final Color sub;
  final Color mu;
  final Color border;

  const AppColors({
    required this.isDark,
    required this.primary,
    required this.primaryMid,
    required this.primaryLight,
    required this.primaryDark,
    required this.gold,
    required this.goldLight,
    required this.goldDark,
    required this.ok,
    required this.warn,
    required this.err,
    required this.info,
    required this.bg,
    required this.card,
    required this.surf,
    required this.tx,
    required this.sub,
    required this.mu,
    required this.border,
  });

  static const AppColors light = AppColors(
    isDark: false,
    primary: Color(0xFF1B5E20),
    primaryMid: Color(0xFF2E7D32),
    primaryLight: Color(0xFF388E3C),
    primaryDark: Color(0xFF003300),
    gold: Color(0xFFF9A825),
    goldLight: Color(0xFFFDD835),
    goldDark: Color(0xFFBF6000),
    ok: Color(0xFF2E7D32),
    warn: Color(0xFFE65100),
    err: Color(0xFFB71C1C),
    info: Color(0xFF0D47A1),
    bg: Color(0xFFF2F6F1),
    card: Color(0xFFFFFFFF),
    surf: Color(0xFFF5FAF6),
    tx: Color(0xFF14210F),
    sub: Color(0xFF44553F),
    mu: Color(0xFF87977F),
    border: Color(0xFFD8E4D2),
  );

  static const AppColors dark = AppColors(
    isDark: true,
    primary: Color(0xFF1B5E20),
    primaryMid: Color(0xFF2E7D32),
    primaryLight: Color(0xFF388E3C),
    primaryDark: Color(0xFF0A1F0C),
    gold: Color(0xFFF9A825),
    goldLight: Color(0xFFFDD835),
    goldDark: Color(0xFFBF6000),
    ok: Color(0xFF66BB6A),
    warn: Color(0xFFFFB74D),
    err: Color(0xFFEF5350),
    info: Color(0xFF64B5F6),
    bg: Color(0xFF0C150D),
    card: Color(0xFF16241A),
    surf: Color(0xFF1D2E21),
    tx: Color(0xFFE8F5E9),
    sub: Color(0xFFA8C2A4),
    mu: Color(0xFF6E8A6E),
    border: Color(0xFF2A3E2C),
  );
}

class AppTheme {
  AppTheme._();

  static const String displayFont = 'Amiri';

  /// عنوان مقطع كلاسيكي بخط أميري.
  static TextStyle sectionTitle(AppColors c, {double size = 16}) => TextStyle(
        fontFamily: displayFont,
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: c.primaryDark == c.primaryDark ? c.tx : c.tx,
        height: 1.4,
      );

  static ThemeData theme(AppColors c) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: c.isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: c.bg,
    );
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: c.primary,
        secondary: c.gold,
        surface: c.card,
        error: c.err,
      ),
      scaffoldBackgroundColor: c.bg,
      textTheme: base.textTheme.copyWith(
        titleLarge: base.textTheme.titleLarge?.copyWith(
            fontFamily: displayFont, fontWeight: FontWeight.w700, color: c.tx),
        titleMedium: base.textTheme.titleMedium?.copyWith(
            fontFamily: displayFont, fontWeight: FontWeight.w700, color: c.tx),
        headlineSmall: base.textTheme.headlineSmall?.copyWith(
            fontFamily: displayFont, fontWeight: FontWeight.w700, color: c.tx),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: c.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: c.border.withOpacity(0.7)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surf,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c.primary, width: 1.6),
        ),
      ),
      dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: c.border),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: TextStyle(
            fontFamily: displayFont, fontSize: 18, fontWeight: FontWeight.w700, color: c.tx),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
