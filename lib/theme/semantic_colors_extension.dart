import 'package:flutter/material.dart';

@immutable
class SemanticColors extends ThemeExtension<SemanticColors> {
  final Color success;
  final Color warning;
  final Color error;
  final Color info;
  
  final Color family;
  final Color friends;
  final Color work;
  final Color other;

  const SemanticColors({
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
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
      family: Color.lerp(family, otherExtension.family, t)!,
      friends: Color.lerp(friends, otherExtension.friends, t)!,
      work: Color.lerp(work, otherExtension.work, t)!,
      other: Color.lerp(other, otherExtension.other, t)!,
    );
  }

  // Define light theme values
  static const light = SemanticColors(
    success: Color(0xFF22C55E),
    warning: Color(0xFFF59E0B),
    error: Color(0xFFEF4444),
    info: Color(0xFF3B82F6),
    family: Color(0xFF8B5CF6), // Purple
    friends: Color(0xFFEC4899), // Pink
    work: Color(0xFF10B981),    // Emerald
    other: Color(0xFF6B7280),   // Grey
  );

  // Define dark theme values
  static const dark = SemanticColors(
    success: Color(0xFF4ADE80),
    warning: Color(0xFFFBBF24),
    error: Color(0xFFF87171),
    info: Color(0xFF60A5FA),
    family: Color(0xFFA78BFA),
    friends: Color(0xFFF472B6),
    work: Color(0xFF34D399),
    other: Color(0xFF9CA3AF),
  );
}
