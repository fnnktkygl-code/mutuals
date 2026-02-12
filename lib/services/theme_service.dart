import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

/// Service for persisting theme preferences
class ThemeService {
  static const String _themeModeKey = 'theme_mode';
  static const String _accentColorKey = 'accent_color';

  /// Load saved theme mode
  static Future<AppThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt(_themeModeKey) ?? 0;
    return AppThemeMode.values[modeIndex.clamp(0, AppThemeMode.values.length - 1)];
  }

  /// Save theme mode
  static Future<void> saveThemeMode(AppThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
  }

  /// Load saved accent color
  static Future<AccentColor> loadAccentColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorIndex = prefs.getInt(_accentColorKey) ?? 5; // Default to purple
    return AccentColor.values[colorIndex.clamp(0, AccentColor.values.length - 1)];
  }

  /// Save accent color
  static Future<void> saveAccentColor(AccentColor color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_accentColorKey, color.index);
  }
}
