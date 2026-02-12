import 'package:intl/intl.dart';

class DateUtils {
  /// Returns the current month key in YYYY-MM format
  static String getCurrentMonthKey() {
    final date = DateTime.now();
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }

  /// Returns the last 12 months keys in chronological order
  static List<String> getLast12MonthsKeys() {
    final keys = <String>[];
    final now = DateTime.now();
    
    for (int i = 11; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      keys.add('${date.year}-${date.month.toString().padLeft(2, '0')}');
    }
    
    return keys;
  }

  /// Returns the current month and previous 11 months in REVERSE order (Current -> Past)
  static List<String> getLast12MonthsKeysReverse() {
    final keys = <String>[];
    final now = DateTime.now();
    
    for (int i = 0; i < 12; i++) {
      final date = DateTime(now.year, now.month - i, 1);
      keys.add('${date.year}-${date.month.toString().padLeft(2, '0')}');
    }
    
    return keys;
  }

  /// Returns the next 12 months keys including current month
  static List<String> getNext12MonthsKeys() {
    final keys = <String>[];
    final now = DateTime.now();
    
    for (int i = 0; i < 12; i++) {
      final date = DateTime(now.year, now.month + i, 1);
      keys.add('${date.year}-${date.month.toString().padLeft(2, '0')}');
    }
    
    return keys;
  }

  /// Formats month key to short format (e.g., "Jan")
  static String formatMonthShort(String monthKey) {
    final parts = monthKey.split('-');
    if (parts.length != 2) return '';
    
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    if (year == null || month == null) return '';
    
    final date = DateTime(year, month);
    return DateFormat('MMM', 'fr_FR').format(date);
  }

  /// Formats month key to long format (e.g., "janvier 2026")
  static String formatMonthLong(String monthKey) {
    final parts = monthKey.split('-');
    if (parts.length != 2) return '';
    
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    if (year == null || month == null) return '';
    
    final date = DateTime(year, month);
    return DateFormat('MMMM yyyy', 'fr_FR').format(date);
  }

  /// Returns the number of days remaining in the current month
  static int getDaysRemaining() {
    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    return lastDayOfMonth.day - now.day;
  }

  static DateTime getMonthFromKey(String key) {
    final parts = key.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]));
  }

  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 365) return 'il y a ${(diff.inDays / 365).floor()} an(s)';
    if (diff.inDays > 30) return 'il y a ${(diff.inDays / 30).floor()} mois';
    if (diff.inDays > 0) return 'il y a ${diff.inDays} jour(s)';
    return 'aujourd\'hui';
  }

  /// Calculates age from birthday
  static int calculateCustomAge(DateTime birthday) {
    final now = DateTime.now();
    int age = now.year - birthday.year;
    if (now.month < birthday.month || 
        (now.month == birthday.month && now.day < birthday.day)) {
      age--;
    }
    return age;
  }
}
