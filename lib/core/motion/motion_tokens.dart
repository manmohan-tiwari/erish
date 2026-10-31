import 'package:flutter/material.dart';

/// ERISH Official Motion Tokens & Accessibility Helpers
class MotionTokens {
  // Standard Durations
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 650);
  static const Duration cinematic = Duration(milliseconds: 1200);

  // Standard Curves
  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve easeInOut = Curves.easeInOutCubic;
  static const Curve bounce = Curves.elasticOut;

  /// Returns true if the user's OS has requested reduced motion
  static bool shouldReduceMotion(BuildContext context) {
    return MediaQuery.maybeAccessibleNavigationOf(context) ?? false;
  }

  /// Calculates safe animation duration respecting reduced-motion preferences
  static Duration safeDuration(BuildContext context, Duration standard) {
    if (shouldReduceMotion(context)) {
      return const Duration(milliseconds: 1);
    }
    return standard;
  }
}
