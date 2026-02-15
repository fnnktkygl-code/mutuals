import 'package:flutter/material.dart';
import 'app_theme.dart';

@immutable
class SemanticColors extends ThemeExtension<SemanticColors> {
  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  final Color mascot;        // Filou's warm orange
  final Color mascotSurface; // light peach tint for backgrounds

  final Color family;
  final Color friends;
  final Color work;
  final Color other;

  const SemanticColors({
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.mascot,
    required this.mascotSurface,
    required this.family,
    required this.friends,
    required this.work,
    required this.other,
  });

  @override
  SemanticColors copyWith({
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
    Color? mascot,
    Color? mascotSurface,
    Color? family,
    Color? friends,
    Color? work,
    Color? other,
  }) {
    return SemanticColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
      mascot: mascot ?? this.mascot,
      mascotSurface: mascotSurface ?? this.mascotSurface,
      family: family ?? this.family,
      friends: friends ?? this.friends,
      work: work ?? this.work,
      other: other ?? this.other,
    );
  }

  @override
  SemanticColors lerp(ThemeExtension<SemanticColors>? otherExtension, double t) {
    if (otherExtension is! SemanticColors) {
      return this;
    }
    return SemanticColors(
      success: Color.lerp(success, otherExtension.success, t)!,
      warning: Color.lerp(warning, otherExtension.warning, t)!,
      error: Color.lerp(error, otherExtension.error, t)!,
      info: Color.lerp(info, otherExtension.info, t)!,
      mascot: Color.lerp(mascot, otherExtension.mascot, t)!,
      mascotSurface: Color.lerp(mascotSurface, otherExtension.mascotSurface, t)!,
      family: Color.lerp(family, otherExtension.family, t)!,
      friends: Color.lerp(friends, otherExtension.friends, t)!,
      work: Color.lerp(work, otherExtension.work, t)!,
      other: Color.lerp(other, otherExtension.other, t)!,
    );
  }

  /// Select palette by [AppThemeMode].
  static SemanticColors fromMode(AppThemeMode mode) {
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

  static const light = SemanticColors(
    success: Color(0xFF22C55E),
    warning: Color(0xFFF59E0B),
    error: Color(0xFFEF4444),
    info: Color(0xFF3B82F6),
    mascot: Color(0xFFFF6B35),
    mascotSurface: Color(0xFFFFF3ED),
    family: Color(0xFF8B5CF6),
    friends: Color(0xFFEC4899),
    work: Color(0xFF10B981),
    other: Color(0xFF6B7280),
  );

  static const dark = SemanticColors(
    success: Color(0xFF4ADE80),
    warning: Color(0xFFFBBF24),
    error: Color(0xFFF87171),
    info: Color(0xFF60A5FA),
    mascot: Color(0xFFFF8C5A),
    mascotSurface: Color(0xFF2D1F15),
    family: Color(0xFFA78BFA),
    friends: Color(0xFFF472B6),
    work: Color(0xFF34D399),
    other: Color(0xFF9CA3AF),
  );

  static const sepia = SemanticColors(
    success: Color(0xFF2E7D32),
    warning: Color(0xFFF57F17),
    error: Color(0xFFC62828),
    info: Color(0xFF1565C0),
    mascot: Color(0xFFD35400),
    mascotSurface: Color(0xFFEFEBE9),
    family: Color(0xFF7E57C2),
    friends: Color(0xFFAD1457),
    work: Color(0xFF2E7D32),
    other: Color(0xFF795548),
  );

  static const oled = SemanticColors(
    success: Color(0xFF69F0AE),
    warning: Color(0xFFFFD740),
    error: Color(0xFFFF5252),
    info: Color(0xFF448AFF),
    mascot: Color(0xFFFFAB91),
    mascotSurface: Color(0xFF1A1210),
    family: Color(0xFFB388FF),
    friends: Color(0xFFFF80AB),
    work: Color(0xFF69F0AE),
    other: Color(0xFF757575),
  );
}

