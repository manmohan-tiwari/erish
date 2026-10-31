import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// ERISH Official Design Tokens - Typography
/// Old-Money Aristocrat: Classical Roman chisel luxury (Cinzel) paired with
/// poetic Renaissance cursive (Cormorant Infant) and slender luxury sans (Tenor Sans).
class AppTypography {
  // Display & Editorial Headings (Cinzel)
  static TextStyle displayHero({
    Color color = AppColors.ivory,
    bool isMobile = false,
  }) {
    return GoogleFonts.cinzel(
      fontSize: isMobile ? 42 : 58,
      fontWeight: FontWeight.w600,
      color: color,
      height: 1.05,
      letterSpacing: 2.0,
    );
  }

  static TextStyle displayTagline({
    Color color = AppColors.gold,
    bool isMobile = false,
  }) {
    return GoogleFonts.cormorantInfant(
      fontSize: isMobile ? 46 : 64,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.italic,
      color: color,
      height: 1.08,
      letterSpacing: 0.5,
    );
  }

  static TextStyle sectionTitle({
    Color color = AppColors.ink,
    bool isMobile = false,
  }) {
    return GoogleFonts.cinzel(
      fontSize: isMobile ? 26 : 38,
      fontWeight: FontWeight.w600,
      color: color,
      height: 1.15,
      letterSpacing: 1.8,
    );
  }

  static TextStyle cardTitle({Color color = AppColors.ink}) {
    return GoogleFonts.cinzel(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: color,
      height: 1.25,
      letterSpacing: 0.8,
    );
  }

  static TextStyle quote({Color color = AppColors.pink}) {
    return GoogleFonts.cormorantInfant(
      fontSize: 22,
      fontStyle: FontStyle.italic,
      color: color,
      height: 1.3,
    );
  }

  // Functional UI & Body (Tenor Sans)
  static TextStyle eyebrow({Color color = AppColors.pink}) {
    return GoogleFonts.tenorSans(
      fontSize: 11,
      letterSpacing: 4.5,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }

  static TextStyle button({Color color = AppColors.ivory}) {
    return GoogleFonts.tenorSans(
      fontSize: 11.5,
      letterSpacing: 2.6,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }

  static TextStyle body({
    Color color = AppColors.charcoal,
    bool isMobile = false,
  }) {
    return GoogleFonts.tenorSans(
      fontSize: isMobile ? 13.5 : 14.5,
      fontWeight: FontWeight.w400,
      height: 1.8,
      letterSpacing: 0.3,
      color: color,
    );
  }

  static TextStyle price({Color color = AppColors.pink}) {
    return GoogleFonts.tenorSans(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.8,
      color: color,
    );
  }

  static TextStyle caption({Color color = AppColors.muted}) {
    return GoogleFonts.tenorSans(
      fontSize: 11.5,
      fontWeight: FontWeight.w400,
      letterSpacing: 1.2,
      color: color,
    );
  }
}
