import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'mascot_colors.dart';
import 'semantic_colors_extension.dart';
import 'typography_extension.dart';

/// Theme modes supported by the app
enum AppThemeMode {
  light,
  sepia,
  dark,
  oled,
}

/// Accent colors with improved saturation and vibrancy
enum AccentColor {
  red,
  orange,
  yellow,
  green,
  blue,
  purple,
  pink,
  brown,
}

/// Extension to get color values from AccentColor enum
extension AccentColorExtension on AccentColor {
  /// Primary accent color with improved saturation
  Color get color {
    switch (this) {
      case AccentColor.red:
        return const Color(0xFFDC2626); // More vibrant red
      case AccentColor.orange:
        return const Color(0xFFEA580C); // Richer orange
      case AccentColor.yellow:
        return const Color(0xFFCA8A04); // Deeper yellow for better contrast
      case AccentColor.green:
        return const Color(0xFF16A34A); // More saturated green
      case AccentColor.blue:
        return const Color(0xFF2563EB); // Classic blue
      case AccentColor.purple:
        return const Color(0xFF9333EA); // Vibrant purple
      case AccentColor.pink:
        return const Color(0xFFDB2777); // Rich pink
      case AccentColor.brown:
        return const Color(0xFF92400E); // Deeper brown
    }
  }

  String get label {
    switch (this) {
      case AccentColor.red:
        return 'Rouge';
      case AccentColor.orange:
        return 'Orange';
      case AccentColor.yellow:
        return 'Jaune';
      case AccentColor.green:
        return 'Vert';
      case AccentColor.blue:
        return 'Bleu';
      case AccentColor.purple:
        return 'Violet';
      case AccentColor.pink:
        return 'Rose';
      case AccentColor.brown:
        return 'Marron';
    }
  }
}

/// Theme-specific color palette with enhanced structure
class ThemePalette {
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color surfaceContainerLow;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
  final Color border;
  final Color borderSubtle;
  final Color divider;
  final Color shadow;
  final Brightness brightness;

  const ThemePalette({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.surfaceContainerLow,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.border,
    required this.borderSubtle,
    required this.divider,
    required this.shadow,
    required this.brightness,
  });

  // ═══════════════════════════════════════════════════════════════
  // LIGHT THEME - Clean, bright, with proper elevation hierarchy
  // ═══════════════════════════════════════════════════════════════
  static const light = ThemePalette(
    background: Color(0xFFFAFAFA), // Slight off-white to reduce eye strain
    surface: Color(0xFFFFFFFF), // Pure white for cards
    surfaceVariant: Color(0xFFF8F9FA), // Very subtle cool tint, not heavy grey
    surfaceContainerLow: Color(0xFFFFFFFF), // Pure white for low containers
    surfaceContainerHigh: Color(0xFFF6F8FC), // Very subtle blueish tint for depth
    surfaceContainerHighest: Color(0xFFEEF2F6), // Soft cool grey/blue for chips
    border: Color(0xFFE2E8F0), // Soft slate border
    borderSubtle: Color(0xFFF1F5F9), // Very subtle dividers
    divider: Color(0xFFF1F5F9),
    shadow: Color(0x1A64748B), // Slate shadow (10%) for modern feel
    brightness: Brightness.light,
  );

  // ═══════════════════════════════════════════════════════════════
  // SEPIA THEME - Warm, paper-like, reading-friendly
  // ═══════════════════════════════════════════════════════════════
  static const sepia = ThemePalette(
    background: Color(0xFFF8F4EB), // Lighter warm cream
    surface: Color(0xFFFFFCF8), // Almost white cream for cards
    surfaceVariant: Color(0xFFF2EFE9), // Very subtle warm input
    surfaceContainerLow: Color(0xFFFAF7F2),
    surfaceContainerHigh: Color(0xFFEFEBE4), // Warm tab background
    surfaceContainerHighest: Color(0xFFE6E1D8), // Warm chips
    border: Color(0xFFE6DACC), // Soft warm border
    borderSubtle: Color(0xFFF2EFE9),
    divider: Color(0xFFE6DACC),
    shadow: Color(0x1A5D4037), // Warm brown shadow
    brightness: Brightness.light,
  );

  // ═══════════════════════════════════════════════════════════════
  // DARK THEME - Slate-based, modern, reduced eye strain
  // ═══════════════════════════════════════════════════════════════
  static const dark = ThemePalette(
    background: Color(0xFF0F172A), // Deep slate background
    surface: Color(0xFF1E293B), // Slate cards
    surfaceVariant: Color(0xFF334155), // Lighter inputs
    surfaceContainerLow: Color(0xFF1A2332),
    surfaceContainerHigh: Color(0xFF2D3B4E), // Tab background
    surfaceContainerHighest: Color(0xFF3D4E63), // Chips
    border: Color(0xFF475569), // Visible borders
    borderSubtle: Color(0xFF2D3B4E),
    divider: Color(0xFF334155),
    shadow: Color(0x40000000), // 25% black shadow
    brightness: Brightness.dark,
  );

  // ═══════════════════════════════════════════════════════════════
  // OLED THEME - Pure black, maximum contrast, battery-efficient
  // ═══════════════════════════════════════════════════════════════
  static const oled = ThemePalette(
    background: Color(0xFF000000), // Pure black
    surface: Color(0xFF0A0A0A), // Barely visible elevation
    surfaceVariant: Color(0xFF1A1A1A), // Subtle inputs
    surfaceContainerLow: Color(0xFF0D0D0D),
    surfaceContainerHigh: Color(0xFF1F1F1F), // Tab background
    surfaceContainerHighest: Color(0xFF2A2A2A), // Chips
    border: Color(0xFF303030), // Subtle borders
    borderSubtle: Color(0xFF1A1A1A),
    divider: Color(0xFF1F1F1F),
    shadow: Color(0x00000000), // No shadows in OLED
    brightness: Brightness.dark,
  );

  static ThemePalette fromMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return light;
      case AppThemeMode.sepia:
        return sepia;
      case AppThemeMode.dark:
        return dark;
      case AppThemeMode.oled:
        return oled;
    }
  }
}

/// Extension on ThemeMode for labels
extension AppThemeModeExtension on AppThemeMode {
  String get label {
    switch (this) {
      case AppThemeMode.light:
        return 'Clair';
      case AppThemeMode.dark:
        return 'Sombre';
      case AppThemeMode.oled:
        return 'OLED';
      case AppThemeMode.sepia:
        return 'Sépia';
    }
  }

  String get icon {
    switch (this) {
      case AppThemeMode.light:
        return '☀️';
      case AppThemeMode.dark:
        return '🌙';
      case AppThemeMode.oled:
        return '⚫';
      case AppThemeMode.sepia:
        return '📜';
    }
  }
}

/// Main theme class
class AppTheme {
  // Gradient definitions for avatars
  static const Map<String, List<Color>> gradients = {
    'from-purple-400 to-purple-600': [Color(0xFFC084FC), Color(0xFF9333EA)],
    'from-blue-400 to-blue-600': [Color(0xFF60A5FA), Color(0xFF2563EB)],
    'from-pink-400 to-rose-500': [Color(0xFFF472B6), Color(0xFFF43F5E)],
    'from-orange-400 to-amber-500': [Color(0xFFFB923C), Color(0xFFF59E0B)],
    'from-emerald-400 to-teal-500': [Color(0xFF34D399), Color(0xFF14B8A6)],
    'from-slate-600 to-slate-800': [Color(0xFF475569), Color(0xFF1E293B)],
    'from-slate-200 to-slate-400': [Color(0xFFE2E8F0), Color(0xFF94A3B8)],
    'from-red-700 to-rose-900': [Color(0xFFB91C1C), Color(0xFF881337)],
    'from-blue-600 to-blue-800': [Color(0xFF2563EB), Color(0xFF1E40AF)],
    'from-slate-800 to-black': [Color(0xFF1E293B), Color(0xFF000000)],
  };

  static LinearGradient getGradient(String gradientKey) {
    final colors = gradients[gradientKey] ?? [const Color(0xFFC084FC), const Color(0xFF9333EA)];
    return LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// Generate ThemeData with improved color logic and accessibility
  static ThemeData generateTheme(AppThemeMode mode, AccentColor accent) {
    final palette = ThemePalette.fromMode(mode);
    final accentColor = accent.color;
    final isDark = palette.brightness == Brightness.dark;
    final isOled = mode == AppThemeMode.oled;

    // Generate Material 3 color scheme with proper tonal palette
    final baseScheme = ColorScheme.fromSeed(
      seedColor: accentColor,
      brightness: palette.brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
    );

    // Text colors with proper contrast ratios (WCAG AA compliant)
    final textPrimary = isDark ? const Color(0xFFFFFFFF) : const Color(0xFF0A0A0A);
    final textSecondary = isDark ? const Color(0xFFB0B0B0) : const Color(0xFF6B6B6B);
    final textTertiary = isDark ? const Color(0xFF808080) : const Color(0xFF9E9E9E);

    // Override with our carefully crafted palette
    final colorScheme = baseScheme.copyWith(
      // Primary colors
      primary: accentColor,
      onPrimary: _getContrastingTextColor(accentColor),
      primaryContainer: _getTintedContainer(accentColor, isDark, isOled),
      onPrimaryContainer: _getContrastingTextColor(_getTintedContainer(accentColor, isDark, isOled)),

      // Secondary colors (slightly desaturated accent)
      secondary: _getDesaturatedAccent(accentColor, isDark),
      onSecondary: _getContrastingTextColor(_getDesaturatedAccent(accentColor, isDark)),

      // Surface colors with proper elevation system
      surface: palette.surface,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,

      // Surface containers (elevation system)
      surfaceContainerLowest: palette.background,
      surfaceContainerLow: palette.surfaceContainerLow,
      surfaceContainer: palette.surface,
      surfaceContainerHigh: palette.surfaceContainerHigh,
      surfaceContainerHighest: palette.surfaceContainerHighest,

      // Borders and dividers
      outline: palette.border,
      outlineVariant: palette.borderSubtle,

      // Background
      // background: palette.background, // Deprecated
      // onBackground: textPrimary, // Deprecated

      // Shadows
      shadow: palette.shadow,
      scrim: isDark ? const Color(0xCC000000) : const Color(0x66000000),
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      brightness: palette.brightness,
      scaffoldBackgroundColor: palette.background,
      shadowColor: palette.shadow,

      // Typography with improved readability
      textTheme: _buildTextTheme(textPrimary, textSecondary, textTertiary),

      // Input decoration with better visual hierarchy
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.borderSubtle, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1),
        ),
        labelStyle: TextStyle(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: textTertiary,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),

      // Card theme with subtle elevation
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: isOled ? 0 : 1,
        shadowColor: palette.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isOled ? palette.border : Colors.transparent,
            width: isOled ? 1 : 0,
          ),
        ),
      ),

      // Chip theme with proper states and contrast
      chipTheme: ChipThemeData(
        backgroundColor: palette.surfaceContainerHighest,
        selectedColor: colorScheme.primaryContainer,
        disabledColor: palette.surfaceVariant,
        labelStyle: TextStyle(
          color: textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: TextStyle(
          color: colorScheme.onPrimaryContainer,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: BorderSide(
          color: palette.borderSubtle,
          width: 0.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),

      // Bottom sheet theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surface,
        modalBackgroundColor: palette.surface,
        elevation: isOled ? 0 : 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        elevation: isOled ? 0 : 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: isOled
              ? BorderSide(color: palette.border, width: 1)
              : BorderSide.none,
        ),
      ),

      // Elevated button theme with proper contrast
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: _getContrastingTextColor(accentColor),
          elevation: isOled ? 0 : 2,
          shadowColor: accentColor.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: _getContrastingTextColor(accentColor),
        elevation: isOled ? 0 : 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // Icon button theme
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: textPrimary,
        ),
      ),

      // Tab bar theme with proper visual hierarchy
      tabBarTheme: TabBarThemeData(
        labelColor: _getContrastingTextColor(accentColor),
        unselectedLabelColor: textSecondary,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        indicator: BoxDecoration(
          color: accentColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isOled
              ? null
              : [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: palette.divider,
        thickness: 1,
        space: 1,
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accentColor;
          }
          return palette.surfaceContainerHigh;
        }),
      ),

      // Register Extensions
      extensions: [
        SemanticColors.fromMode(mode),
        MascotColors.fromMode(mode),
        AppTypography.regular,
      ],
    );
  }

  /// Helper: Get contrasting text color for accessibility
  static Color _getContrastingTextColor(Color backgroundColor) {
    // Calculate relative luminance
    final luminance = backgroundColor.computeLuminance();
    // Use white text for dark backgrounds, black for light
    return luminance > 0.5 ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
  }

  /// Helper: Create a tinted container color
  static Color _getTintedContainer(Color accent, bool isDark, bool isOled) {
    if (isOled) {
      // For OLED, use very subtle accent tint
      return Color.alphaBlend(
        accent.withValues(alpha: 0.15),
        const Color(0xFF1A1A1A),
      );
    } else if (isDark) {
      // For dark theme, blend accent with dark surface
      return Color.alphaBlend(
        accent.withValues(alpha: 0.2),
        const Color(0xFF2D3B4E),
      );
    } else {
      // For light theme, use lighter tint
      return Color.alphaBlend(
        accent.withValues(alpha: 0.12),
        const Color(0xFFF5F5F5),
      );
    }
  }

  /// Helper: Create desaturated accent for secondary elements
  static Color _getDesaturatedAccent(Color accent, bool isDark) {
    final hsl = HSLColor.fromColor(accent);
    return hsl
        .withSaturation((hsl.saturation * 0.7).clamp(0.0, 1.0))
        .withLightness(isDark ? 0.7 : 0.5)
        .toColor();
  }

  /// Build text theme with proper hierarchy
  static TextTheme _buildTextTheme(
      Color primary,
      Color secondary,
      Color tertiary,
      ) {
    return GoogleFonts.interTextTheme(
      TextTheme(
        // Display styles
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w800,
          color: primary,
          letterSpacing: -0.5,
          height: 1.1,
        ),
        displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w700,
          color: primary,
          letterSpacing: -0.5,
          height: 1.15,
        ),
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: primary,
          letterSpacing: -0.5,
          height: 1.2,
        ),

        // Headline styles
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: primary,
          letterSpacing: -0.5,
          height: 1.25,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: primary,
          letterSpacing: -0.25,
          height: 1.3,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: primary,
          height: 1.35,
        ),

        // Title styles
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: primary,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: primary,
          letterSpacing: 0.15,
          height: 1.5,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: secondary,
          letterSpacing: 0.1,
          height: 1.45,
        ),

        // Body styles
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: primary,
          letterSpacing: 0.15,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: primary,
          letterSpacing: 0.25,
          height: 1.45,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: secondary,
          letterSpacing: 0.4,
          height: 1.4,
        ),

        // Label styles
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: primary,
          letterSpacing: 0.1,
          height: 1.4,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: secondary,
          letterSpacing: 0.5,
          height: 1.35,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: tertiary,
          letterSpacing: 0.5,
          height: 1.3,
        ),
      ),
    );
  }

  /// Glassmorphism effect with proper backdrop blur and modern roundness
  static BoxDecoration glassDecoration(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isOled = theme.scaffoldBackgroundColor == const Color(0xFF000000);

    return BoxDecoration(
      color: theme.colorScheme.surface.withValues(
        alpha: isOled ? 1.0 : (isDark ? 0.9 : 0.80),
      ),
      borderRadius: BorderRadius.circular(28), // Increased roundness
      border: Border.all(
        color: isOled
            ? Colors.white.withValues(alpha: 0.1)
            : theme.colorScheme.outline.withValues(alpha: 0.15), // Barely visible
        width: isOled ? 1 : 0.5,
      ),
      gradient: isOled ? null : LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.colorScheme.surface.withValues(alpha: isDark ? 0.95 : 0.9),
          theme.colorScheme.surface.withValues(alpha: isDark ? 0.85 : 0.7),
        ],
      ),
      boxShadow: isOled
          ? null
          : [
        BoxShadow(
          color: theme.shadowColor.withValues(alpha: isDark ? 0.3 : 0.05), // Softer shadow
          blurRadius: 24,
          offset: const Offset(0, 8),
          spreadRadius: -6,
        ),
        BoxShadow(
          color: theme.shadowColor.withValues(alpha: isDark ? 0.15 : 0.02),
          blurRadius: 8,
          offset: const Offset(0, 2),
          spreadRadius: -2,
        ),
      ],
    );
  }

  /// Selection decoration for tabs, chips, and interactive elements
  static BoxDecoration selectionDecoration(bool isSelected, BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final isOled = theme.scaffoldBackgroundColor == const Color(0xFF000000);
    final isDark = theme.brightness == Brightness.dark;

    if (isSelected) {
      return BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isOled
            ? null
            : [
          BoxShadow(
            color: accent.withValues(alpha: isDark ? 0.5 : 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
        border: isOled
            ? Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1)
            : null,
      );
    } else {
      return BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 0.5,
        ),
      );
    }
  }

  /// Text style for selections with proper contrast
  static TextStyle selectionTextStyle(bool isSelected, BuildContext context) {
    final theme = Theme.of(context);
    return TextStyle(
      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      fontSize: 13,
      letterSpacing: 0.1,
      color: isSelected
          ? _getContrastingTextColor(theme.colorScheme.primary)
          : theme.colorScheme.onSurface.withValues(alpha: 0.7),
    );
  }
}

/// Extension on BuildContext for easy theme access
extension ThemeContextExtension on BuildContext {
  /// Get current theme data
  ThemeData get theme => Theme.of(this);

  /// Get current color scheme
  ColorScheme get colors => Theme.of(this).colorScheme;

  /// Get current text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Check if dark mode
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Check if OLED mode
  bool get isOled => Theme.of(this).scaffoldBackgroundColor == const Color(0xFF000000);

  /// Get accent/primary color
  Color get accent => Theme.of(this).colorScheme.primary;

  /// Get surface color
  Color get surface => Theme.of(this).colorScheme.surface;

  /// Get background color
  Color get background => Theme.of(this).scaffoldBackgroundColor;

  /// Get text color with proper contrast
  Color get textColor => Theme.of(this).colorScheme.onSurface;

  /// Get secondary text color (70% opacity)
  Color get textSecondary => Theme.of(this).colorScheme.onSurface.withValues(alpha: 0.7);

  /// Get tertiary text color (50% opacity)
  Color get textTertiary => Theme.of(this).colorScheme.onSurface.withValues(alpha: 0.5);

  /// Get quaternary text color (35% opacity for disabled states)
  Color get textDisabled => Theme.of(this).colorScheme.onSurface.withValues(alpha: 0.35);

  /// Get border color
  Color get borderColor => Theme.of(this).colorScheme.outline;

  /// Get subtle border color
  Color get borderSubtle => Theme.of(this).colorScheme.outlineVariant;

  /// Get surface variant (for inputs, cards, etc.)
  Color get surfaceVariant => Theme.of(this).colorScheme.surfaceContainerHighest;

  /// Get semantic colors
  SemanticColors get semantic =>
      Theme.of(this).extension<SemanticColors>() ?? SemanticColors.light;

  /// Get mascot colors
  MascotColors get mascotColors =>
      Theme.of(this).extension<MascotColors>() ?? MascotColors.light;

  /// Get app typography
  AppTypography get typography =>
      Theme.of(this).extension<AppTypography>() ?? AppTypography.regular;
}

/// Legacy compatibility - DEPRECATED, use context extensions instead
@Deprecated('Use context.accent or context.colors instead')
class AppColors {
  static Color primary = const Color(0xFF9333EA);
  static const primaryDark = Color(0xFFC084FC);
  static const secondary = Color(0xFF3B82F6);
  static const secondaryDark = Color(0xFF60A5FA);
  static const backgroundLight = Color(0xFFF0F2F5);
  static const backgroundDark = Color(0xFF0F172A);
  static const surfaceLight = Colors.white;
  static const surfaceDark = Color(0xFF1E293B);
  static const textLight = Color(0xFF0F172A);
  static const textDark = Color(0xFFF8FAFC);
  static const textSecondaryLight = Color(0xFF64748B);
  static const textSecondaryDark = Color(0xFF94A3B8);
  static const selectedLight = Color(0xFF9333EA);
  static const selectedDark = Color(0xFFC084FC);
  static const unselectedLight = Colors.white;
  static const unselectedDark = Color(0xFF334155);
  static const borderLight = Color(0xFFE2E8F0);
  static const borderDark = Color(0xFF334155);
}