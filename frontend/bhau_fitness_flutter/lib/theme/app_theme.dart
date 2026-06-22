import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colors lifted straight from the web app's CSS variables, so the Flutter
/// client feels like the same brand rather than a generic Material app.
class BhauColors {
  static const cyan = Color(0xFF00E0FF);
  static const cyanDeep = Color(0xFF0098C2);
  static const lime = Color(0xFFC6FF3D);
  static const limeDeep = Color(0xFF9AD400);
  static const bg = Color(0xFF07090C);
  static const bg1 = Color(0xFF0B0E13);
  static const bg2 = Color(0xFF10141A);
  static const bg3 = Color(0xFF181E26);
  static const ink = Color(0xFFF4F6F8);
  static const muted = Color(0xFFA8B0BC);
  static const faint = Color(0xFF6B7480);
  static const line = Color(0xFF20262E);
  static const line2 = Color(0xFF2B323C);
  static const ok = Color(0xFF27D796);
  static const warn = Color(0xFFFFB020);
  static const bad = Color(0xFFFF5470);

  static const cyanLimeGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [cyan, lime],
  );
}

/// The HTML site's three font roles: Anton for shouty display headlines,
/// Inter for body copy, Space Mono for eyebrows/stats/mono accents.
class BhauText {
  static TextStyle display({double fontSize = 32, Color color = BhauColors.ink, double? height}) =>
      GoogleFonts.anton(
        fontSize: fontSize,
        color: color,
        height: height ?? 0.95,
        letterSpacing: 0.2,
      );

  static TextStyle mono({
    double fontSize = 12,
    Color color = BhauColors.cyan,
    FontWeight weight = FontWeight.w400,
    double letterSpacing = 1.6,
  }) =>
      GoogleFonts.spaceMono(
        fontSize: fontSize,
        color: color,
        fontWeight: weight,
        letterSpacing: letterSpacing,
      );

  static TextStyle eyebrow({Color color = BhauColors.cyan}) => mono(
        fontSize: 11.5,
        color: color,
        weight: FontWeight.w700,
        letterSpacing: 3.0,
      );

  static TextStyle body({double fontSize = 15, Color color = BhauColors.muted, double height = 1.55}) =>
      GoogleFonts.inter(fontSize: fontSize, color: color, height: height);
}

/// Reusable decorations matching the HTML's `.glass` / `.card` / gradient-pass
/// look, so screens don't repeat the same BoxDecoration blocks.
class BhauDecor {
  static BoxDecoration card({Color? border, double radius = 18}) => BoxDecoration(
        color: BhauColors.bg2,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border ?? BhauColors.line),
      );

  static BoxDecoration glass({double radius = 18}) => BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: BhauColors.line),
      );

  static BoxDecoration gradientPass({double radius = 18}) => BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D2730), Color(0xFF0A1116)],
        ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: BhauColors.line2),
      );
}

ThemeData buildBhauTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  final inter = GoogleFonts.interTextTheme(base.textTheme);

  return base.copyWith(
    scaffoldBackgroundColor: BhauColors.bg,
    colorScheme: base.colorScheme.copyWith(
      primary: BhauColors.cyan,
      secondary: BhauColors.lime,
      surface: BhauColors.bg2,
      error: BhauColors.bad,
    ),
    textTheme: inter.apply(
      bodyColor: BhauColors.ink,
      displayColor: BhauColors.ink,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: BhauColors.bg,
      elevation: 0,
      foregroundColor: BhauColors.ink,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: BhauColors.bg2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: BhauColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: BhauColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: BhauColors.cyan, width: 1.5),
      ),
      labelStyle: const TextStyle(color: BhauColors.muted),
    ),
    // Buttons mirror the HTML's `.btn` class exactly: Inter at 700 weight /
    // 15px, 12px corner radius, 24px/14px padding — NOT the Anton display
    // font, and not Material 3's default full-pill (StadiumBorder) shape.
    // The previous button textStyle omitted a fontFamily, which made button
    // labels silently fall back to the browser's default font instead of
    // Inter — the "off" look. Defining all three button themes here means
    // every ElevatedButton/OutlinedButton/TextButton in the app picks this up
    // automatically; per-widget `.styleFrom` calls only need to override
    // colour, not font or shape.
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: BhauColors.lime,
        foregroundColor: BhauColors.bg,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: BhauColors.ink,
        side: const BorderSide(color: BhauColors.line2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: BhauColors.cyan,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    cardTheme: CardThemeData(
      color: BhauColors.bg2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: BhauColors.line),
      ),
    ),
  );
}
