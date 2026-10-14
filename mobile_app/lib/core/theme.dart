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
    primary: Color(0xFF66BB6A), // أفتح من الفاتح: نصوص وأيقونات مقروءة على الخلفية الداكنة
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

/// مقاييس التباعد والزوايا — استخدمها بدل الأرقام المبعثرة لتوحيد الإيقاع البصري.
class AppSpace {
  AppSpace._();
  static const double xs = 4, sm = 8, md = 12, lg = 16, xl = 24, xxl = 32;
}

class AppRadius {
  AppRadius._();
  static const double sm = 8, md = 12, lg = 16, xl = 24, pill = 999;
}

class AppTheme {
  AppTheme._();

  /// خط العناوين الكلاسيكي (هوية الصندوق).
  static const String displayFont = 'Amiri';

  /// خط الواجهة: واضح في الأحجام الصغيرة، أرقام متناسقة، يعمل على كل الأجهزة بالمظهر نفسه.
  static const String bodyFont = 'Tajawal';

  /// عنوان مقطع كلاسيكي بخط أميري.
  static TextStyle sectionTitle(AppColors c, {double size = 16}) => TextStyle(
        fontFamily: displayFont,
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: c.tx,
        height: 1.4,
      );

  /// نمط المبالغ: أرقام بعرض ثابت لتصطف الأعمدة في الجداول والقوائم.
  static TextStyle amount(AppColors c, {double size = 14, Color? color, FontWeight? weight}) => TextStyle(
        fontFamily: bodyFont,
        fontSize: size,
        fontWeight: weight ?? FontWeight.w800,
        color: color ?? c.tx,
        fontFeatures: const [FontFeature.tabularFigures()],
        height: 1.25,
      );

  static ThemeData theme(AppColors c) {
    final brightness = c.isDark ? Brightness.dark : Brightness.light;
    final accent = c.isDark ? c.ok : c.primary;
    final scheme = ColorScheme.fromSeed(seedColor: c.primary, brightness: brightness).copyWith(
      primary: accent,
      onPrimary: Colors.white,
      secondary: c.gold,
      onSecondary: const Color(0xFF1B1300),
      surface: c.card,
      onSurface: c.tx,
      error: c.err,
      outline: c.border,
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: bodyFont,
      fontFamilyFallback: const [displayFont],
      colorScheme: scheme,
      scaffoldBackgroundColor: c.bg,
    );

    TextStyle t(double size, FontWeight w, {Color? color, String? family, double? height}) => TextStyle(
          fontFamily: family ?? bodyFont,
          fontSize: size,
          fontWeight: w,
          color: color ?? c.tx,
          height: height ?? 1.45,
        );

    final text = base.textTheme.copyWith(
      displaySmall: t(28, FontWeight.w700, family: displayFont),
      headlineMedium: t(24, FontWeight.w700, family: displayFont),
      headlineSmall: t(21, FontWeight.w700, family: displayFont),
      titleLarge: t(19, FontWeight.w700, family: displayFont),
      titleMedium: t(16, FontWeight.w700, family: displayFont),
      titleSmall: t(14, FontWeight.w700),
      bodyLarge: t(15, FontWeight.w400),
      bodyMedium: t(13.5, FontWeight.w400),
      bodySmall: t(12, FontWeight.w400, color: c.sub),
      labelLarge: t(14, FontWeight.w700),
      labelMedium: t(12, FontWeight.w700),
      labelSmall: t(11, FontWeight.w500, color: c.mu),
    );

    RoundedRectangleBorder shape(double r) => RoundedRectangleBorder(borderRadius: BorderRadius.circular(r));
    OutlineInputBorder outline(Color color, [double width = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: color, width: width),
        );

    return base.copyWith(
      textTheme: text,
      primaryTextTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: c.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: t(17, FontWeight.w800, color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: c.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: c.border.withValues(alpha: 0.7)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surf,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        labelStyle: t(13, FontWeight.w500, color: c.sub),
        hintStyle: t(13, FontWeight.w400, color: c.mu),
        helperStyle: t(11.5, FontWeight.w400, color: c.mu),
        errorStyle: t(11.5, FontWeight.w600, color: c.err),
        border: outline(c.border),
        enabledBorder: outline(c.border),
        focusedBorder: outline(accent, 1.8),
        errorBorder: outline(c.err),
        focusedErrorBorder: outline(c.err, 1.8),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.isDark ? c.primaryMid : c.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: shape(AppRadius.md),
          textStyle: t(14.5, FontWeight.w800, color: Colors.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          side: BorderSide(color: c.border, width: 1.4),
          shape: shape(AppRadius.md),
          textStyle: t(14.5, FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          minimumSize: const Size(48, 44),
          shape: shape(AppRadius.md),
          textStyle: t(14, FontWeight.w700),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.gold,
        foregroundColor: const Color(0xFF1B1300),
        elevation: 3,
        extendedTextStyle: t(14, FontWeight.w800, color: const Color(0xFF1B1300)),
        shape: shape(AppRadius.lg),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.card,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        height: 66,
        indicatorColor: c.primary.withValues(alpha: c.isDark ? 0.35 : 0.14),
        labelTextStyle: WidgetStateProperty.resolveWith((s) => t(
              11.5,
              s.contains(WidgetState.selected) ? FontWeight.w800 : FontWeight.w500,
              color: s.contains(WidgetState.selected) ? accent : c.mu,
            )),
        iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
              size: 24,
              color: s.contains(WidgetState.selected) ? accent : c.mu,
            )),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.card,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: c.border,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.card,
        surfaceTintColor: Colors.transparent,
        shape: shape(AppRadius.xl),
        titleTextStyle: t(19, FontWeight.w700, family: displayFont),
        contentTextStyle: t(14, FontWeight.w400, color: c.sub),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? Colors.white : c.mu),
        trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? (c.isDark ? c.primaryMid : c.primary) : c.border),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? (c.isDark ? c.primaryMid : c.primary) : null),
        shape: shape(5),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: c.sub,
        titleTextStyle: t(14, FontWeight.w700),
        subtitleTextStyle: t(12, FontWeight.w400, color: c.sub),
        shape: shape(AppRadius.md),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: shape(AppRadius.pill),
        side: BorderSide(color: c.border),
        labelStyle: t(12.5, FontWeight.w700),
        backgroundColor: c.card,
        selectedColor: c.primary.withValues(alpha: 0.16),
      ),
      tabBarTheme: TabBarThemeData(
        labelStyle: t(13.5, FontWeight.w800),
        unselectedLabelStyle: t(13.5, FontWeight.w500),
        labelColor: accent,
        unselectedLabelColor: c.mu,
        indicatorColor: c.gold,
        dividerColor: c.border,
      ),
      dataTableTheme: DataTableThemeData(
        headingTextStyle: t(12.5, FontWeight.w800, color: c.sub),
        dataTextStyle: t(13, FontWeight.w500),
        headingRowColor: WidgetStateProperty.all(c.surf),
        dividerThickness: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: accent, linearTrackColor: c.surf),
      dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: shape(AppRadius.md),
        contentTextStyle: t(13.5, FontWeight.w600, color: Colors.white),
      ),
      tooltipTheme: TooltipThemeData(
        textStyle: t(12, FontWeight.w500, color: Colors.white),
        decoration: BoxDecoration(color: c.primaryDark, borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
