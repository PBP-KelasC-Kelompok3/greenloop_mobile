import 'package:flutter/material.dart';

class GreenLoopColors {
  GreenLoopColors._();

  static const deepForest = Color(0xFF123A20);
  static const circleGreen = Color(0xFF1E5B2E);
  static const leaf = Color(0xFFB6E07A);

  static const forest = Color(0xFF0F3D2A);
  static const forest2 = Color(0xFF145238);
  static const primary = Color(0xFF008A5F);
  static const darkGreen = Color(0xFF506649);
  static const green = Color(0xFF789C6D);
  static const lightGreen = Color(0xFFC0CCBB);
  static const accent = Color(0xFF3DBE7E);

  static const mint = Color(0xFFEAF5EC);
  static const paleGreen = Color(0xFFEAF5EC);
  static const surface = Color(0xFFF5F8F3);
  static const border = Color(0xFFE3E9E0);
  static const muted = Color(0xFF6B7A68);
  static const ink = Color(0xFF193225);
  static const white = Colors.white;

  // Warna TEKS yang diukur langsung dari desain Figma.
  // Sengaja dipisah dari `ink` / `muted` supaya warna ikon dan komponen
  // lain yang masih memakai token lama tidak ikut berubah.
  static const textInk = Color(0xFF16281B);
  static const textMuted = Color(0xFF5E6E62);

  // Token warna dari variabel Figma "GreenLoop Mobile" (color/*).
  static const green900 = Color(0xFF123A20);
  static const green700 = Color(0xFF1E5B2E);
  static const green100 = Color(0xFFE7F3E1);
  static const green50 = Color(0xFFF3F8EF);
  static const green500 = Color(0xFF3D8B47);
  static const lime = Color(0xFFB5E07A);
  static const background = Color(0xFFF6F8F3);
  static const cardBorder = Color(0xFFDCE5D7);
  static const amber = Color(0xFFE89B2A);
  static const amber100 = Color(0xFFFDF1DC);
  static const red = Color(0xFFD9534F);
  static const red100 = Color(0xFFFBE6E5);
  static const blue = Color(0xFF3B82C4);
  static const blue100 = Color(0xFFE3EFFA);
}

/// Typography GreenLoop.
///
/// Font: Poppins, dibundel sebagai asset (lihat bagian `fonts:` di
/// pubspec.yaml). Satu family `Poppins` dengan weight 400/500/600/700/800,
/// sehingga `fontWeight` di TextStyle mana pun otomatis memilih file yang
/// benar. Letter spacing di Figma = 0 untuk seluruh teks.
class GreenLoopTypography {
  GreenLoopTypography._();

  static const String fontFamily = 'Poppins';

  /// Pembuat TextStyle dasar. `letterSpacing: 0` dan `height` ditulis
  /// eksplisit supaya nilai bawaan Material 3 (mis. letterSpacing 0.25 dan
  /// height 1.43 pada bodyMedium) tidak ikut ter-merge ke tema.
  static TextStyle style(
    double size,
    FontWeight weight, {
    double height = 1.5,
    Color color = GreenLoopColors.textInk,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: 0,
      color: color,
    );
  }

  static TextTheme get textTheme => TextTheme(
    // Display
    displayLarge: style(57, FontWeight.w700, height: 1.12),
    displayMedium: style(45, FontWeight.w700, height: 1.16),
    displaySmall: style(36, FontWeight.w700, height: 1.22),

    // Headline
    headlineLarge: style(32, FontWeight.w700, height: 1.25),
    // Figma M01: judul onboarding 28 / Bold / line height 125%
    headlineMedium: style(28, FontWeight.w700, height: 1.25),
    // Figma M02: judul halaman 26 / Bold
    headlineSmall: style(26, FontWeight.w700, height: 1.2),

    // Title
    // Figma M07: judul AppBar "Profil" 20 / Bold
    titleLarge: style(20, FontWeight.w700, height: 1.3),
    titleMedium: style(16, FontWeight.w600),
    titleSmall: style(14, FontWeight.w600),

    // Body. Figma: paragraf 14 / Regular / line height 150%
    bodyLarge: style(16, FontWeight.w400),
    bodyMedium: style(14, FontWeight.w400),
    bodySmall: style(12, FontWeight.w400),

    // Label. Figma: teks tombol 15 / SemiBold, label tab bar 11 / Medium
    labelLarge: style(15, FontWeight.w600),
    labelMedium: style(12, FontWeight.w600, height: 1.35),
    labelSmall: style(11, FontWeight.w500, height: 1.45),
  );
}

class GreenLoopTheme {
  GreenLoopTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      fontFamily: GreenLoopTypography.fontFamily,
      textTheme: GreenLoopTypography.textTheme,

      colorScheme: ColorScheme.fromSeed(
        seedColor: GreenLoopColors.forest2,
        brightness: Brightness.light,
      ),

      scaffoldBackgroundColor: GreenLoopColors.surface,

      appBarTheme: AppBarTheme(
        backgroundColor: GreenLoopColors.surface,
        foregroundColor: GreenLoopColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GreenLoopTypography.style(
          20,
          FontWeight.w700,
          height: 1.3,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        labelStyle: GreenLoopTypography.style(
          13,
          FontWeight.w600,
          color: GreenLoopColors.forest,
        ),
        // Figma: placeholder 14 / Regular / abu-abu muted
        hintStyle: GreenLoopTypography.style(
          14,
          FontWeight.w400,
          color: GreenLoopColors.textMuted,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        // Figma: field putih, border #DCE5D7, fokus border hijau 1.5
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: GreenLoopColors.cardBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: GreenLoopColors.cardBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF3D8B47),
            width: 1.5,
          ),
        ),
        prefixIconColor: GreenLoopColors.textInk,
        suffixIconColor: GreenLoopColors.textInk,
      ),

      // Teks tombol: 15 / SemiBold (Figma: Mobile/Button)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: GreenLoopTypography.style(15, FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: GreenLoopTypography.style(15, FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: GreenLoopTypography.style(14, FontWeight.w600),
        ),
      ),

      // Segmented control (tab role di Login): 13, aktif SemiBold,
      // tidak aktif Medium. Hanya typography; warna tidak diubah di sini.
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStateProperty.resolveWith((states) {
            return GreenLoopTypography.style(
              13,
              states.contains(WidgetState.selected)
                  ? FontWeight.w600
                  : FontWeight.w500,
            );
          }),
        ),
      ),
    );
  }
}