import 'package:flutter/material.dart';
// Optional (recommended) for a futuristic font:
// import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Arc reactor + Stark palette
  static const _cyan   = Color(0xFF00E5FF);
  static const _red    = Color(0xFFD32F2F);
  static const _gold   = Color(0xFFFFD54F);
  static const _ink    = Color(0xFF0A0F1A); // near-black blue
  static const _panel  = Color(0xFF121826); // dark panel
  static const _line   = Color(0xFF1E2A3A); // divider lines

  // Reusable glass fill
  static const _glassFillDark  = Color(0x66121826); // 40% panel
  static const _glassFillLight = Color(0xCCFFFFFF); // 80% white

  static ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _ink,
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: _cyan,
        onPrimary: Colors.black,
        secondary: _gold,
        onSecondary: Colors.black,
        surface: _panel,
        onSurface: Colors.white,
        background: _ink,
        onBackground: Colors.white,
        error: _red,
        onError: Colors.white,
        tertiary: _red,
        onTertiary: Colors.white,
      ),
    );

    // final hudFont = GoogleFonts.orbitron(); // uncomment if using GoogleFonts

    return base.copyWith(
      // textTheme: base.textTheme.apply(fontFamily: hudFont.fontFamily),
      textTheme: base.textTheme.copyWith(
        titleLarge: base.textTheme.titleLarge?.copyWith(
          letterSpacing: 0.5,
          fontWeight: FontWeight.w700,
          // shadows: const [Shadow(color: _cyan, blurRadius: 8)], // subtle glow
        ),
        labelLarge: base.textTheme.labelLarge?.copyWith(
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600,
        ),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),

      dividerColor: _line,
      dividerTheme: const DividerThemeData(
        color: _line,
        thickness: 1,
        space: 24,
      ),

      cardTheme: CardThemeData(
        color: _glassFillDark,
        surfaceTintColor: _cyan.withOpacity(.12),
        elevation: 0,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _cyan.withOpacity(.20), width: 1),
        ),
        shadowColor: _cyan.withOpacity(.25),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: _panel.withOpacity(.9),
        surfaceTintColor: _cyan.withOpacity(.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: _line),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _panel.withOpacity(.6),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _line, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _cyan, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _red, width: 1.5),
        ),
        hintStyle: TextStyle(color: Colors.white.withOpacity(.55)),
        labelStyle: const TextStyle(color: Colors.white70),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) return _cyan.withOpacity(.9);
            return _cyan;
          }),
          foregroundColor: WidgetStateProperty.all(Colors.black),
          overlayColor: WidgetStateProperty.all(_cyan.withOpacity(.12)),
          elevation: WidgetStateProperty.all(6),
          shadowColor: WidgetStateProperty.all(_cyan.withOpacity(.35)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: _cyan.withOpacity(.35), width: 1),
            ),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          ),
          side: WidgetStateProperty.all(BorderSide(color: _cyan.withOpacity(.65), width: 1.5)),
          foregroundColor: WidgetStateProperty.all(_cyan),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          overlayColor: WidgetStateProperty.all(_cyan.withOpacity(.1)),
          foregroundColor: WidgetStateProperty.all(_cyan),
        ),
      ),

      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? _cyan.withOpacity(.35) : _line,
        ),
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? _cyan : Colors.white70,
        ),
      ),

      sliderTheme: base.sliderTheme.copyWith(
        activeTrackColor: _cyan,
        inactiveTrackColor: _line,
        thumbColor: _cyan,
        overlayColor: _cyan.withOpacity(.15),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _panel.withOpacity(.9),
        selectedItemColor: _cyan,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        selectedIconTheme: const IconThemeData(size: 26),
        unselectedIconTheme: const IconThemeData(size: 22),
      ),
    );
  }

  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF7FAFF),
      colorScheme: const ColorScheme.light(
        primary: _cyan,
        secondary: _red,
        surface: Colors.white,
        background: Color(0xFFF7FAFF),
        onBackground: Colors.black87,
        onSurface: Colors.black87,
        error: _red,
        onError: Colors.white,
        tertiary: _gold,
        onTertiary: Colors.black,
      ),
    );

    // final hudFont = GoogleFonts.orbitron();

    return base.copyWith(
      // textTheme: base.textTheme.apply(fontFamily: hudFont.fontFamily),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: _glassFillLight,
        surfaceTintColor: _cyan.withOpacity(.08),
        elevation: 0,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _cyan.withOpacity(.15)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE6EEF7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _cyan, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          ),
          backgroundColor: WidgetStateProperty.all(_cyan),
          foregroundColor: WidgetStateProperty.all(Colors.black),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          elevation: WidgetStateProperty.all(3),
          shadowColor: WidgetStateProperty.all(_cyan.withOpacity(.25)),
        ),
      ),
    );
  }
}
