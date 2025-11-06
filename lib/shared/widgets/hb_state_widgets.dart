import 'package:flutter/material.dart';
import '../theme/design_system.dart';
import 'hb_button.dart';

/// ============================================================================
/// HBLoading - Standardized loading state
/// Shows a spinner with optional message
/// ============================================================================

class HBLoading extends StatelessWidget {
  const HBLoading({
    super.key,
    this.message,
    this.size = 40,
    this.color,
    this.strokeWidth = 4,
    this.centered = true,
  });

  final String? message;
  final double size;
  final Color? color;
  final double strokeWidth;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final loadingWidget = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? context.colorScheme.primary,
            ),
          ),
        ),
        if (message != null) ...[
          SizedBox(height: AppSpacing.base),
          Text(
            message!,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (centered) {
      return Center(child: loadingWidget);
    }

    return loadingWidget;
  }

  /// Small loading indicator (24px)
  factory HBLoading.small({
    Key? key,
    String? message,
    Color? color,
    bool centered = true,
  }) {
    return HBLoading(
      key: key,
      message: message,
      size: 24,
      strokeWidth: 3,
      color: color,
      centered: centered,
    );
  }

  /// Medium loading indicator (40px) - default
  factory HBLoading.medium({
    Key? key,
    String? message,
    Color? color,
    bool centered = true,
  }) {
    return HBLoading(
      key: key,
      message: message,
      size: 40,
      strokeWidth: 4,
      color: color,
      centered: centered,
    );
  }

  /// Large loading indicator (64px)
  factory HBLoading.large({
    Key? key,
    String? message,
    Color? color,
    bool centered = true,
  }) {
    return HBLoading(
      key: key,
      message: message,
      size: 64,
      strokeWidth: 5,
      color: color,
      centered: centered,
    );
  }

  /// Loading overlay that can be placed on top of content
  factory HBLoading.overlay({
    Key? key,
    String? message,
    Color? backgroundColor,
  }) {
    return HBLoading(
      key: key,
      message: message,
      centered: true,
    );
  }
}

/// ============================================================================
/// HBEmptyState - Standardized empty state
/// Shows icon, title, message, and optional action button
/// ============================================================================

class HBEmptyState extends StatelessWidget {
  const HBEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.iconSize = 80,
    this.iconColor,
    this.iconGradient,
    this.centered = true,
    this.padding,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  final double iconSize;
  final Color? iconColor;
  final Gradient? iconGradient;
  final bool centered;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final emptyStateWidget = Padding(
      padding: padding ?? const EdgeInsets.all(AppSpacing.xl2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              gradient: iconGradient,
              color: iconGradient == null
                  ? (iconColor ?? context.colorScheme.primaryContainer)
                  : null,
              borderRadius: BorderRadius.circular(AppRadii.xl),
              boxShadow: iconGradient != null
                  ? AppElevation.coloredShadow(
                      iconGradient!.colors.first,
                      opacity: 0.2,
                    )
                  : null,
            ),
            child: Icon(
              icon,
              size: iconSize * 0.5,
              color: iconGradient != null
                  ? Colors.white
                  : (iconColor ?? context.colorScheme.onPrimaryContainer),
            ),
          ),
          SizedBox(height: AppSpacing.lg),

          // Title
          Text(
            title,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: AppTypography.fontWeightSemiBold,
              color: context.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.sm),

          // Message
          Text(
            message,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
              height: AppTypography.lineHeightRelaxed,
            ),
            textAlign: TextAlign.center,
          ),

          // Action button
          if (action != null) ...[
            SizedBox(height: AppSpacing.xl),
            action!,
          ],
        ],
      ),
    );

    if (centered) {
      return Center(child: emptyStateWidget);
    }

    return emptyStateWidget;
  }

  /// Empty state for no records
  factory HBEmptyState.noRecords({
    Key? key,
    required VoidCallback onAddRecord,
    String title = 'No records yet',
    String message = 'Add your first medical record to get started',
  }) {
    return HBEmptyState(
      key: key,
      icon: Icons.folder_open,
      title: title,
      message: message,
      iconGradient: AppColors.primaryGradient,
      action: HBButton.primary(
        onPressed: onAddRecord,
        icon: Icons.add,
        child: const Text('Add Record'),
      ),
    );
  }

  /// Empty state for no search results
  factory HBEmptyState.noSearchResults({
    Key? key,
    String query = '',
  }) {
    return HBEmptyState(
      key: key,
      icon: Icons.search_off,
      title: 'No results found',
      message: query.isNotEmpty
          ? 'No results found for "$query"\nTry a different search term'
          : 'No results found\nTry adjusting your search',
      iconColor: AppColors.secondary,
    );
  }

  /// Empty state for no reminders
  factory HBEmptyState.noReminders({
    Key? key,
    required VoidCallback onAddReminder,
  }) {
    return HBEmptyState(
      key: key,
      icon: Icons.notifications_none,
      title: 'No reminders set',
      message: 'Set up medication or appointment reminders to stay on track',
      iconGradient: AppColors.primaryGradient,
      action: HBButton.primary(
        onPressed: onAddReminder,
        icon: Icons.add,
        child: const Text('Add Reminder'),
      ),
    );
  }

  /// Empty state for no filters
  factory HBEmptyState.noFilters({
    Key? key,
    required VoidCallback onClearFilters,
  }) {
    return HBEmptyState(
      key: key,
      icon: Icons.filter_alt_off,
      title: 'No matching records',
      message: 'Try adjusting your filters to see more results',
      action: HBButton.outline(
        onPressed: onClearFilters,
        child: const Text('Clear Filters'),
      ),
    );
  }

  /// Empty state for offline mode
  factory HBEmptyState.offline({
    Key? key,
    VoidCallback? onRetry,
  }) {
    return HBEmptyState(
      key: key,
      icon: Icons.cloud_off,
      title: 'No internet connection',
      message: 'Check your connection and try again',
      iconColor: AppColors.warning,
      action: onRetry != null
          ? HBButton.primary(
              onPressed: onRetry,
              icon: Icons.refresh,
              child: const Text('Retry'),
            )
          : null,
    );
  }
}

/// ============================================================================
/// HBErrorState - Standardized error state
/// Shows error icon, message, and retry button
/// ============================================================================

class HBErrorState extends StatelessWidget {
  const HBErrorState({
    super.key,
    this.error,
    this.errorMessage,
    this.stackTrace,
    this.onRetry,
    this.retryButtonText = 'Try Again',
    this.centered = true,
    this.padding,
    this.showDetails = false,
  });

  final Object? error;
  final String? errorMessage;
  final StackTrace? stackTrace;
  final VoidCallback? onRetry;
  final String retryButtonText;
  final bool centered;
  final EdgeInsetsGeometry? padding;
  final bool showDetails;

  @override
  Widget build(BuildContext context) {
    final message = errorMessage ?? error?.toString() ?? 'An error occurred';

    final errorStateWidget = Padding(
      padding: padding ?? const EdgeInsets.all(AppSpacing.xl2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Error icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppColors.errorGradient,
              borderRadius: BorderRadius.circular(AppRadii.xl),
              boxShadow: AppElevation.coloredShadow(
                AppColors.error,
                opacity: 0.2,
              ),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 40,
              color: Colors.white,
            ),
          ),
          SizedBox(height: AppSpacing.lg),

          // Title
          Text(
            'Something went wrong',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: AppTypography.fontWeightSemiBold,
              color: context.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.sm),

          // Error message
          Text(
            message,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
              height: AppTypography.lineHeightRelaxed,
            ),
            textAlign: TextAlign.center,
          ),

          // Stack trace (if showDetails is true)
          if (showDetails && stackTrace != null) ...[
            SizedBox(height: AppSpacing.md),
            Flexible(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: context.colorScheme.errorContainer,
                    borderRadius: AppRadii.radiusMd,
                  ),
                  child: Text(
                    stackTrace.toString(),
                    style: context.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: context.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ),
            ),
          ],

          // Retry button
          if (onRetry != null) ...[
            SizedBox(height: AppSpacing.xl),
            HBButton.primary(
              onPressed: onRetry,
              icon: Icons.refresh,
              child: Text(retryButtonText),
            ),
          ],
        ],
      ),
    );

    if (centered) {
      return Center(child: errorStateWidget);
    }

    return errorStateWidget;
  }

  /// Network error state
  factory HBErrorState.network({
    Key? key,
    VoidCallback? onRetry,
  }) {
    return HBErrorState(
      key: key,
      errorMessage: 'Unable to connect to the server\nCheck your internet connection and try again',
      onRetry: onRetry,
    );
  }

  /// Not found error state
  factory HBErrorState.notFound({
    Key? key,
    String? resourceName,
  }) {
    return HBErrorState(
      key: key,
      errorMessage: resourceName != null
          ? '$resourceName not found'
          : 'The requested resource was not found',
      onRetry: null,
    );
  }

  /// Permission denied error state
  factory HBErrorState.permissionDenied({
    Key? key,
    VoidCallback? onRetry,
  }) {
    return HBErrorState(
      key: key,
      errorMessage: 'Permission denied\nYou don\'t have access to this resource',
      onRetry: onRetry,
    );
  }

  /// Generic error with custom message
  factory HBErrorState.custom({
    Key? key,
    required String message,
    VoidCallback? onRetry,
    String retryButtonText = 'Try Again',
  }) {
    return HBErrorState(
      key: key,
      errorMessage: message,
      onRetry: onRetry,
      retryButtonText: retryButtonText,
    );
  }
}

/// ============================================================================
/// HBLoadingOverlay - Full-screen loading overlay
/// ============================================================================

class HBLoadingOverlay extends StatelessWidget {
  const HBLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.backgroundColor,
  });

  final bool isLoading;
  final Widget child;
  final String? message;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor ?? Colors.black.withValues(alpha: 0.5),
            child: HBLoading(
              message: message,
            ),
          ),
      ],
    );
  }
}

/// ============================================================================
/// HBRefreshIndicator - Standardized pull-to-refresh indicator
/// ============================================================================

class HBRefreshIndicator extends StatelessWidget {
  const HBRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.color,
    this.backgroundColor,
    this.displacement = 40.0,
    this.strokeWidth = 2.0,
  });

  final Future<void> Function() onRefresh;
  final Widget child;
  final Color? color;
  final Color? backgroundColor;
  final double displacement;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? context.colorScheme.primary,
      backgroundColor: backgroundColor ?? context.colorScheme.surface,
      displacement: displacement,
      strokeWidth: strokeWidth,
      child: child,
    );
  }
}
