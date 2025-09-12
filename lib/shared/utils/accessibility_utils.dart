import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

class AccessibilityUtils {
  static const Duration defaultAnnouncementDelay = Duration(milliseconds: 500);

  static void announceToScreen(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
    SemanticsService.announce(message, TextDirection.ltr);
  }

  static void announceToScreenReader(String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  static Widget buildSemanticButton({
    required Widget child,
    required VoidCallback onPressed,
    required String semanticLabel,
    String? hint,
    bool? excludeSemantics,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: hint,
      button: true,
      excludeSemantics: excludeSemantics ?? false,
      child: InkWell(
        onTap: onPressed,
        child: child,
      ),
    );
  }

  static Widget buildSemanticCard({
    required Widget child,
    required String semanticLabel,
    String? hint,
    VoidCallback? onTap,
    bool? excludeSemantics,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: hint,
      button: onTap != null,
      excludeSemantics: excludeSemantics ?? false,
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: child,
        ),
      ),
    );
  }

  static Widget buildSemanticListTile({
    Widget? leading,
    Widget? title,
    Widget? subtitle,
    Widget? trailing,
    required String semanticLabel,
    String? hint,
    VoidCallback? onTap,
    bool? excludeSemantics,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: hint,
      button: onTap != null,
      excludeSemantics: excludeSemantics ?? false,
      child: ListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  static Widget buildSemanticTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? errorText,
    bool obscureText = false,
    TextInputType? keyboardType,
    VoidCallback? onTap,
    Function(String)? onChanged,
    bool? enabled,
  }) {
    return Semantics(
      textField: true,
      label: label,
      hint: hint,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          errorText: errorText,
        ),
        obscureText: obscureText,
        keyboardType: keyboardType,
        onTap: onTap,
        onChanged: onChanged,
        enabled: enabled,
      ),
    );
  }

  static Widget buildSemanticImage({
    required ImageProvider image,
    required String semanticLabel,
    String? hint,
    double? width,
    double? height,
    BoxFit? fit,
  }) {
    return Semantics(
      image: true,
      label: semanticLabel,
      hint: hint,
      child: Image(
        image: image,
        width: width,
        height: height,
        fit: fit,
        semanticLabel: semanticLabel,
      ),
    );
  }

  static Widget buildSemanticIcon({
    required IconData icon,
    required String semanticLabel,
    String? hint,
    double? size,
    Color? color,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: hint,
      excludeSemantics: true,
      child: Icon(
        icon,
        size: size,
        color: color,
        semanticLabel: semanticLabel,
      ),
    );
  }

  static Widget buildSemanticProgressIndicator({
    required String semanticLabel,
    double? value,
    String? hint,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: hint,
      value: value?.toString(),
      child: value != null
          ? LinearProgressIndicator(value: value)
          : const CircularProgressIndicator(),
    );
  }

  static Widget excludeFromSemantics(Widget child) {
    return ExcludeSemantics(child: child);
  }

  static Widget mergeSemantics({
    required Widget child,
    String? label,
    String? hint,
    String? value,
    bool? button,
    bool? selected,
    bool? enabled,
  }) {
    return MergeSemantics(
      child: Semantics(
        label: label,
        hint: hint,
        value: value,
        button: button,
        selected: selected,
        enabled: enabled,
        child: child,
      ),
    );
  }

  static const Map<String, String> commonHints = {
    'tap': 'Double tap to activate',
    'navigate': 'Double tap to navigate',
    'edit': 'Double tap to edit',
    'delete': 'Double tap to delete',
    'add': 'Double tap to add',
    'search': 'Double tap to search',
    'filter': 'Double tap to filter',
    'sort': 'Double tap to sort',
    'refresh': 'Double tap to refresh',
    'save': 'Double tap to save',
    'cancel': 'Double tap to cancel',
    'back': 'Double tap to go back',
    'close': 'Double tap to close',
    'expand': 'Double tap to expand',
    'collapse': 'Double tap to collapse',
  };

  static String getCommonHint(String key) {
    return commonHints[key] ?? 'Double tap to activate';
  }

  static bool isScreenReaderActive(BuildContext context) {
    return MediaQuery.of(context).accessibleNavigation;
  }

  static double getAccessibleFontScale(BuildContext context) {
    return MediaQuery.of(context).textScaler.scale(1.0);
  }

  static bool isHighContrast(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }

  static bool isReduceMotionActive(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }
}