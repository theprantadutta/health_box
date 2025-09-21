import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/background_sync_service.dart';

class BackgroundBackupIndicator extends ConsumerStatefulWidget {
  const BackgroundBackupIndicator({super.key});

  @override
  ConsumerState<BackgroundBackupIndicator> createState() =>
      _BackgroundBackupIndicatorState();
}

class _BackgroundBackupIndicatorState
    extends ConsumerState<BackgroundBackupIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -100,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showIndicator() {
    if (!_isVisible) {
      setState(() => _isVisible = true);
      _animationController.forward();
    }
  }

  void _hideIndicator() {
    if (_isVisible) {
      _animationController.reverse().then((_) {
        if (mounted) {
          setState(() => _isVisible = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final syncStatus = ref.watch(backgroundSyncStatusProvider);

    ref.listen(backgroundSyncStatusProvider, (previous, next) {
      next.when(
        data: (status) {
          switch (status.status) {
            case BackgroundSyncStatus.inProgress:
              _showIndicator();
              break;
            case BackgroundSyncStatus.completed:
            case BackgroundSyncStatus.error:
            case BackgroundSyncStatus.skipped:
              // Hide indicator after a delay for completed/error states
              Future.delayed(const Duration(seconds: 3), () {
                if (mounted) _hideIndicator();
              });
              break;
            case BackgroundSyncStatus.idle:
              _hideIndicator();
              break;
          }
        },
        loading: () {},
        error: (_, __) => _hideIndicator(),
      );
    });

    if (!_isVisible) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 16,
      right: 16,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: child,
            ),
          );
        },
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: syncStatus.when(
              data: (status) => _buildIndicatorContent(theme, status),
              loading: () => _buildLoadingContent(theme),
              error: (_, __) => _buildErrorContent(theme),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIndicatorContent(ThemeData theme, BackgroundSyncStatusData status) {
    IconData icon;
    Color iconColor;
    String title;
    String? subtitle;

    switch (status.status) {
      case BackgroundSyncStatus.inProgress:
        icon = Icons.cloud_upload;
        iconColor = theme.colorScheme.primary;
        title = 'Backing up data...';
        subtitle = 'This won\'t interrupt your app usage';
        break;
      case BackgroundSyncStatus.completed:
        icon = Icons.cloud_done;
        iconColor = Colors.green;
        title = 'Backup completed';
        subtitle = 'Your data is safely stored in Google Drive';
        break;
      case BackgroundSyncStatus.error:
        icon = Icons.cloud_off;
        iconColor = Colors.red;
        title = 'Backup failed';
        subtitle = status.message ?? 'Please try again later';
        break;
      case BackgroundSyncStatus.skipped:
        icon = Icons.cloud_queue;
        iconColor = Colors.orange;
        title = 'Backup skipped';
        subtitle = 'Check your sync settings';
        break;
      case BackgroundSyncStatus.idle:
        icon = Icons.cloud;
        iconColor = Colors.grey;
        title = 'Backup ready';
        subtitle = null;
        break;
    }

    return Row(
      children: [
        if (status.status == BackgroundSyncStatus.inProgress) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(iconColor),
            ),
          ),
        ] else ...[
          Icon(icon, color: iconColor, size: 20),
        ],
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        if (status.status != BackgroundSyncStatus.inProgress) ...[
          IconButton(
            onPressed: _hideIndicator,
            icon: const Icon(Icons.close),
            iconSize: 16,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 24,
              minHeight: 24,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingContent(ThemeData theme) {
    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Initializing backup...',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorContent(ThemeData theme) {
    return Row(
      children: [
        Icon(Icons.error, color: Colors.red, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Backup system error',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          onPressed: _hideIndicator,
          icon: const Icon(Icons.close),
          iconSize: 16,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: 24,
            minHeight: 24,
          ),
        ),
      ],
    );
  }
}