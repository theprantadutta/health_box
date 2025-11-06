import 'package:flutter/material.dart';
import '../theme/design_system.dart';
import 'gradient_button.dart';

/// Modern dialog with Material 3 styling and medical theme support
class HealthDialog {
  /// Show a confirmation dialog with optional gradient theme
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    HealthButtonStyle confirmStyle = HealthButtonStyle.primary,
    MedicalButtonTheme? medicalTheme,
    IconData? icon,
    bool isDangerous = false,
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => _HealthDialogWidget(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmStyle: isDangerous ? HealthButtonStyle.error : confirmStyle,
        medicalTheme: medicalTheme,
        icon: icon,
      ),
    );
  }

  /// Show an information dialog
  static Future<void> showInfo({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    IconData? icon,
    MedicalButtonTheme? medicalTheme,
  }) async {
    return showDialog<void>(
      context: context,
      builder: (context) => _HealthInfoDialogWidget(
        title: title,
        message: message,
        buttonText: buttonText,
        icon: icon,
        medicalTheme: medicalTheme,
      ),
    );
  }

  /// Show a success dialog with animation
  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    String? message,
    String buttonText = 'OK',
    Duration? autoDismissDuration,
  }) async {
    final result = showDialog<void>(
      context: context,
      builder: (context) => _HealthSuccessDialogWidget(
        title: title,
        message: message,
        buttonText: buttonText,
      ),
    );

    // Auto-dismiss if duration is provided
    if (autoDismissDuration != null) {
      Future.delayed(autoDismissDuration, () {
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      });
    }

    return result;
  }

  /// Show an error dialog
  static Future<void> showError({
    required BuildContext context,
    required String title,
    String? message,
    String buttonText = 'OK',
    IconData? icon,
  }) async {
    return showDialog<void>(
      context: context,
      builder: (context) => _HealthErrorDialogWidget(
        title: title,
        message: message,
        buttonText: buttonText,
        icon: icon,
      ),
    );
  }

  /// Show a custom dialog with flexible content
  static Future<T?> showCustom<T>({
    required BuildContext context,
    required Widget child,
    EdgeInsetsGeometry? padding,
    bool barrierDismissible = true,
  }) async {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HealthBoxDesignSystem.radiusXl),
        ),
        child: Padding(
          padding: padding ??
              EdgeInsets.all(HealthBoxDesignSystem.spacing6),
          child: child,
        ),
      ),
    );
  }

  /// Show a loading dialog
  static void showLoading({
    required BuildContext context,
    String message = 'Loading...',
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _HealthLoadingDialogWidget(message: message),
    );
  }

  /// Dismiss the currently showing dialog
  static void dismiss(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}

/// Internal confirmation dialog widget
class _HealthDialogWidget extends StatelessWidget {
  const _HealthDialogWidget({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    required this.confirmStyle,
    this.medicalTheme,
    this.icon,
  });

  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final HealthButtonStyle confirmStyle;
  final MedicalButtonTheme? medicalTheme;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(HealthBoxDesignSystem.radiusXl),
      ),
      child: Padding(
        padding: EdgeInsets.all(HealthBoxDesignSystem.spacing6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon (if provided)
            if (icon != null) ...[
              Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: _getIconGradient(),
                    borderRadius: BorderRadius.circular(
                      HealthBoxDesignSystem.radiusXl,
                    ),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
              ),
              SizedBox(height: HealthBoxDesignSystem.spacing4),
            ],

            // Title
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: HealthBoxDesignSystem.fontWeightSemiBold,
              ),
            ),
            SizedBox(height: HealthBoxDesignSystem.spacing3),

            // Message
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: HealthBoxDesignSystem.textSecondary,
                height: HealthBoxDesignSystem.lineHeightRelaxed,
              ),
            ),
            SizedBox(height: HealthBoxDesignSystem.spacing6),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Cancel button
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: HealthBoxDesignSystem.spacing4,
                      vertical: HealthBoxDesignSystem.spacing2,
                    ),
                  ),
                  child: Text(cancelText),
                ),
                SizedBox(width: HealthBoxDesignSystem.spacing2),

                // Confirm button
                HealthButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: confirmStyle,
                  medicalTheme: medicalTheme,
                  size: HealthButtonSize.medium,
                  child: Text(confirmText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient _getIconGradient() {
    switch (confirmStyle) {
      case HealthButtonStyle.primary:
        return HealthBoxDesignSystem.medicalBlue;
      case HealthButtonStyle.success:
        return HealthBoxDesignSystem.successGradient;
      case HealthButtonStyle.warning:
        return HealthBoxDesignSystem.warningGradient;
      case HealthButtonStyle.error:
        return HealthBoxDesignSystem.errorGradient;
    }
  }
}

/// Internal info dialog widget
class _HealthInfoDialogWidget extends StatelessWidget {
  const _HealthInfoDialogWidget({
    required this.title,
    required this.message,
    required this.buttonText,
    this.icon,
    this.medicalTheme,
  });

  final String title;
  final String message;
  final String buttonText;
  final IconData? icon;
  final MedicalButtonTheme? medicalTheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(HealthBoxDesignSystem.radiusXl),
      ),
      child: Padding(
        padding: EdgeInsets.all(HealthBoxDesignSystem.spacing6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            if (icon != null) ...[
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: HealthBoxDesignSystem.infoGradient,
                  borderRadius: BorderRadius.circular(
                    HealthBoxDesignSystem.radiusFull,
                  ),
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
              SizedBox(height: HealthBoxDesignSystem.spacing4),
            ],

            // Title
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: HealthBoxDesignSystem.fontWeightSemiBold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: HealthBoxDesignSystem.spacing3),

            // Message
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: HealthBoxDesignSystem.textSecondary,
                height: HealthBoxDesignSystem.lineHeightRelaxed,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: HealthBoxDesignSystem.spacing6),

            // Button
            HealthButton(
              onPressed: () => Navigator.of(context).pop(),
              style: HealthButtonStyle.primary,
              medicalTheme: medicalTheme,
              size: HealthButtonSize.medium,
              width: double.infinity,
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}

/// Internal success dialog widget
class _HealthSuccessDialogWidget extends StatelessWidget {
  const _HealthSuccessDialogWidget({
    required this.title,
    this.message,
    required this.buttonText,
  });

  final String title;
  final String? message;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(HealthBoxDesignSystem.radiusXl),
      ),
      child: Padding(
        padding: EdgeInsets.all(HealthBoxDesignSystem.spacing6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success icon with animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: HealthBoxDesignSystem.durationSlow,
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: HealthBoxDesignSystem.successGradient,
                      borderRadius: BorderRadius.circular(
                        HealthBoxDesignSystem.radiusFull,
                      ),
                      boxShadow: HealthBoxDesignSystem.coloredShadow(
                        HealthBoxDesignSystem.successColor,
                      ),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: HealthBoxDesignSystem.spacing4),

            // Title
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: HealthBoxDesignSystem.fontWeightSemiBold,
              ),
              textAlign: TextAlign.center,
            ),

            if (message != null) ...[
              SizedBox(height: HealthBoxDesignSystem.spacing3),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: HealthBoxDesignSystem.textSecondary,
                  height: HealthBoxDesignSystem.lineHeightRelaxed,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            SizedBox(height: HealthBoxDesignSystem.spacing6),

            // Button
            HealthButton(
              onPressed: () => Navigator.of(context).pop(),
              style: HealthButtonStyle.success,
              size: HealthButtonSize.medium,
              width: double.infinity,
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}

/// Internal error dialog widget
class _HealthErrorDialogWidget extends StatelessWidget {
  const _HealthErrorDialogWidget({
    required this.title,
    this.message,
    required this.buttonText,
    this.icon,
  });

  final String title;
  final String? message;
  final String buttonText;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(HealthBoxDesignSystem.radiusXl),
      ),
      child: Padding(
        padding: EdgeInsets.all(HealthBoxDesignSystem.spacing6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: HealthBoxDesignSystem.errorGradient,
                borderRadius: BorderRadius.circular(
                  HealthBoxDesignSystem.radiusFull,
                ),
                boxShadow: HealthBoxDesignSystem.coloredShadow(
                  HealthBoxDesignSystem.errorColor,
                ),
              ),
              child: Icon(
                icon ?? Icons.error_outline_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            SizedBox(height: HealthBoxDesignSystem.spacing4),

            // Title
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: HealthBoxDesignSystem.fontWeightSemiBold,
              ),
              textAlign: TextAlign.center,
            ),

            if (message != null) ...[
              SizedBox(height: HealthBoxDesignSystem.spacing3),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: HealthBoxDesignSystem.textSecondary,
                  height: HealthBoxDesignSystem.lineHeightRelaxed,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            SizedBox(height: HealthBoxDesignSystem.spacing6),

            // Button
            HealthButton(
              onPressed: () => Navigator.of(context).pop(),
              style: HealthButtonStyle.error,
              size: HealthButtonSize.medium,
              width: double.infinity,
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}

/// Internal loading dialog widget
class _HealthLoadingDialogWidget extends StatelessWidget {
  const _HealthLoadingDialogWidget({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(HealthBoxDesignSystem.radiusXl),
      ),
      child: Padding(
        padding: EdgeInsets.all(HealthBoxDesignSystem.spacing6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Loading indicator
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  HealthBoxDesignSystem.primaryBlue,
                ),
              ),
            ),
            SizedBox(height: HealthBoxDesignSystem.spacing4),

            // Message
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: HealthBoxDesignSystem.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
