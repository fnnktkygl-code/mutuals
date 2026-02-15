import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Theme-adaptive colors for the Filou mascot and speech bubbles.
///
/// - [fur], [scarf], [details] are reserved for future SVG recoloring.
/// - [outline] and [background] drive the current [FilouBubble] styling.
@immutable
class MascotColors extends ThemeExtension<MascotColors> {
  /// Main fur color (warm orange tones).
  final Color fur;

  /// Scarf / accent element color.
  final Color scarf;

  /// White details (eyes, belly).
  final Color details;

  /// Outlines and borders.
  final Color outline;

  /// Bubble / card background.
  final Color background;

  const MascotColors({
    required this.fur,
    required this.scarf,
    required this.details,
    required this.outline,
    required this.background,
  });

  @override
  MascotColors copyWith({
    Color? fur,
    Color? scarf,
    Color? details,
    Color? outline,
    Color? background,
  }) {
    return MascotColors(
      fur: fur ?? this.fur,
      scarf: scarf ?? this.scarf,
      details: details ?? this.details,
      outline: outline ?? this.outline,
      background: background ?? this.background,
    );
  }

  @override
  MascotColors lerp(ThemeExtension<MascotColors>? other, double t) {
    if (other is! MascotColors) return this;
    return MascotColors(
      fur: Color.lerp(fur, other.fur, t)!,
      scarf: Color.lerp(scarf, other.scarf, t)!,
      details: Color.lerp(details, other.details, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      background: Color.lerp(background, other.background, t)!,
    );
  }

  // ─── Palettes ───

  static const light = MascotColors(
    fur: Color(0xFFFF6B35),
    scarf: Color(0xFFF1C40F),
    details: Color(0xFFFFFFFF),
    outline: Color(0xFF2C3E50),
    background: Color(0xFFFFF3ED),
  );

  static const dark = MascotColors(
    fur: Color(0xFFFF8C5A),
    scarf: Color(0xFFFFD54F),
    details: Color(0xFFE0E0E0),
    outline: Color(0xFF1E272E),
    background: Color(0xFF2D1F15),
  );

  static const sepia = MascotColors(
    fur: Color(0xFFD35400),
    scarf: Color(0xFFF39C12),
    details: Color(0xFFEFEBE9),
    outline: Color(0xFF5D4037),
    background: Color(0xFFEFEBE9),
  );

  static const oled = MascotColors(
    fur: Color(0xFFFFAB91),
    scarf: Color(0xFFFFD54F),
    details: Color(0xFFBDBDBD),
    outline: Color(0xFF000000),
    background: Color(0xFF212121),
  );

  /// Select palette by [AppThemeMode].
  static MascotColors fromMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return light;
      case AppThemeMode.dark:
        return dark;
      case AppThemeMode.sepia:
        return sepia;
      case AppThemeMode.oled:
        return oled;
    }
  }
}
