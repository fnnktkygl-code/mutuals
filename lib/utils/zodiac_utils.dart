class ZodiacUtils {
  static String getZodiacSign(DateTime date) {
    final day = date.day;
    final month = date.month;

    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return '♒ Verseau';
    if ((month == 2 && day >= 19) || (month == 3 && day <= 20)) return '♓ Poissons';
    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return '♈ Bélier';
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return '♉ Taureau';
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return '♊ Gémeaux';
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return '♋ Cancer';
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return '♌ Lion';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return '♍ Vierge';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return '♎ Balance';
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return '♏ Scorpion';
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return '♐ Sagittaire';
    return '♑ Capricorne';
  }

  static String getZodiacEmoji(DateTime date) {
    return getZodiacSign(date).split(' ')[0];
  }
}
