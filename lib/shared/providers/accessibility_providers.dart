import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// Provider for high contrast mode
final highContrastModeProvider = StateProvider<bool>((ref) => false);

// Provider for large text mode
final largeTextModeProvider = StateProvider<bool>((ref) => false);

// Provider for reduced animations mode
final reducedAnimationsModeProvider = StateProvider<bool>((ref) => false);

// Combined accessibility settings provider
final accessibilitySettingsProvider = Provider<AccessibilitySettings>((ref) {
  return AccessibilitySettings(
    highContrast: ref.watch(highContrastModeProvider),
    largeText: ref.watch(largeTextModeProvider),
    reducedAnimations: ref.watch(reducedAnimationsModeProvider),
  );
});

class AccessibilitySettings {
  final bool highContrast;
  final bool largeText;
  final bool reducedAnimations;

  const AccessibilitySettings({
    required this.highContrast,
    required this.largeText,
    required this.reducedAnimations,
  });

  // Get high contrast color scheme
  static ColorScheme getHighContrastColorScheme(bool isDark) {
    if (isDark) {
      return const ColorScheme.dark(
        primary: Colors.white,
        onPrimary: Colors.black,
        secondary: Colors.yellow,
        onSecondary: Colors.black,
        surface: Colors.black,
        onSurface: Colors.white,
        error: Colors.red,
        onError: Colors.white,
      );
    } else {
      return const ColorScheme.light(
        primary: Colors.black,
        onPrimary: Colors.white,
        secondary: Colors.blue,
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black,
        error: Colors.red,
        onError: Colors.white,
      );
    }
  }

  // Get text scale factor for large text mode
  double get textScaleFactor => largeText ? 1.3 : 1.0;

  // Get animation duration (reduced for accessibility)
  Duration getAnimationDuration(Duration defaultDuration) {
    return reducedAnimations
        ? Duration(milliseconds: (defaultDuration.inMilliseconds * 0.3).round())
        : defaultDuration;
  }
}
