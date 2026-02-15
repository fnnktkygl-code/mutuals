/// Design tokens — single source of truth for spacing, radii & animation.
///
/// Usage: `BorderRadius.circular(DesignTokens.radiusLg)`
class DesignTokens {
  DesignTokens._();

  // ── Border Radii ──────────────────────────────────────────────
  /// Chips, badges, small interactive elements
  static const double radiusSm = 12.0;

  /// Inputs, small cards, inner containers
  static const double radiusMd = 20.0;

  /// Cards, modals, principal containers (the "Bubble" default)
  static const double radiusLg = 24.0;

  /// Bottom bar, full-screen sheets, large containers
  static const double radiusXl = 32.0;

  // ── Spacing ───────────────────────────────────────────────────
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // ── Animation Durations ───────────────────────────────────────
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animDefault = Duration(milliseconds: 250);
  static const Duration animSlow = Duration(milliseconds: 400);
}
