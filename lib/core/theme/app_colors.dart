import 'package:flutter/material.dart';

/// ERISH Official Design Tokens - Color Palette
/// Derived from Section 8 of the ERISH Flutter E-Commerce Build Plan
class AppColors {
  // Surfaces & Backgrounds (Soft Linen & Cream)
  static const Color warmIvory = Color(0xFFFBF9F5);
  static const Color paperWhite = Color(0xFFFFFEFD);
  static const Color ivory = Color(0xFFFBF9F5);
  static const Color cream = Color(0xFFF4EFEA);

  // Typography & Inks (Deep Forest Noir & Espresso)
  static const Color espresso = Color(0xFF13251E);
  static const Color ink = Color(0xFF0F1E18);
  static const Color charcoal = Color(0xFF1E352C);
  static const Color muted = Color(0xFF6B7B73);
  static const Color lightMuted = Color(0xFFE2EBE6);

  // Emerald Oasis & Champagne Gold Accents
  static const Color emerald = Color(0xFF1B4332);
  static const Color emeraldLight = Color(0xFFE8F2EC);
  static const Color emeraldDeep = Color(0xFF0F2B20);
  static const Color gold = Color(0xFFC5A059);
  static const Color goldSoft = Color(0xFFF7F1E5);

  // Heritage mappings (pink maps to Royal Emerald for unified brand signature)
  static const Color pink = emerald;
  static const Color pinkSoft = emeraldLight;
  static const Color terracotta = gold;
  static const Color softOlive = Color(0xFF52796F);

  // Borders & Dividers
  static const Color sandBorder = Color(0xFFE2DED6);
  static const Color borderLight = Color(0x1F0F1E18);
}
