import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

@immutable
class AppTypography extends ThemeExtension<AppTypography> {
  final TextStyle heroTitle;
  final TextStyle sectionHeader;
  final TextStyle cardTitle;
  final TextStyle cardSubtitle;
  final TextStyle inputLabel;
  final TextStyle smallLabel;

  const AppTypography({
    required this.heroTitle,
    required this.sectionHeader,
    required this.cardTitle,
    required this.cardSubtitle,
    required this.inputLabel,
    required this.smallLabel,
  });

  @override
  AppTypography copyWith({
    TextStyle? heroTitle,
    TextStyle? sectionHeader,
    TextStyle? cardTitle,
    TextStyle? cardSubtitle,
    TextStyle? inputLabel,
    TextStyle? smallLabel,
  }) {
    return AppTypography(
      heroTitle: heroTitle ?? this.heroTitle,
      sectionHeader: sectionHeader ?? this.sectionHeader,
      cardTitle: cardTitle ?? this.cardTitle,
      cardSubtitle: cardSubtitle ?? this.cardSubtitle,
      inputLabel: inputLabel ?? this.inputLabel,
      smallLabel: smallLabel ?? this.smallLabel,
    );
  }

  @override
  AppTypography lerp(ThemeExtension<AppTypography>? other, double t) {
    if (other is! AppTypography) {
      return this;
    }
    return AppTypography(
      heroTitle: TextStyle.lerp(heroTitle, other.heroTitle, t)!,
      sectionHeader: TextStyle.lerp(sectionHeader, other.sectionHeader, t)!,
      cardTitle: TextStyle.lerp(cardTitle, other.cardTitle, t)!,
      cardSubtitle: TextStyle.lerp(cardSubtitle, other.cardSubtitle, t)!,
      inputLabel: TextStyle.lerp(inputLabel, other.inputLabel, t)!,
      smallLabel: TextStyle.lerp(smallLabel, other.smallLabel, t)!,
    );
  }

  static final regular = AppTypography(
    heroTitle: GoogleFonts.nunito(fontSize: 32, fontWeight: FontWeight.w800),
    sectionHeader: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w700),
    cardTitle: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700),
    cardSubtitle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.normal),
    inputLabel: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
    smallLabel: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
  );
}
