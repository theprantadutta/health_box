import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/sync_preferences.dart';
import '../../../shared/widgets/modern_card.dart';
import '../../../shared/theme/app_theme.dart';
import '../providers/upload_providers.dart';
import '../services/file_upload_service.dart';

class UploadProgressWidget extends ConsumerWidget {
  final bool showHeader;
  final int maxItemsToShow;

  const UploadProgressWidget({
    super.key,
    this.showHeader = true,
    this.maxItemsToShow = 5,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final uploadQueueAsync = ref.watch(uploadQueueProvider);
    final uploadStatsAsync = ref.watch(uploadStatisticsProvider);

    return ModernCard(
      elevation: CardElevation.medium,
      enableHoverEffect: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader) ...[
            _buildHeader(theme, uploadStatsAsync),
            const SizedBox(height: 16),
          ],

          uploadQueueAsync.when(
            loading: () => _buildLoadingIndicator(),
            error: (error, _) => _buildErrorMessage(error.toString(), theme),
            data: (tasks) => _buildUploadList(tasks, theme, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AsyncValue<UploadStatistics> statsAsync) {
    return Row(
      children: [
        Icon(
          Icons.cloud_upload,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'File Uploads',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        if (statsAsync.hasValue)
          _buildStatsChip(statsAsync.value!, theme),
      ],
    );
  }

  Widget _buildStatsChip(UploadStatistics stats, ThemeData theme) {
    final color = stats.hasFailedUploads
        ? AppTheme.errorColor
        : stats.hasActiveUploads
          ? AppTheme.warningColor
          : stats.hasPendingUploads
            ? theme.colorScheme.primary
            : AppTheme.successColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            stats.hasFailedUploads
              ? Icons.error
              : stats.hasActiveUploads
                ? Icons.cloud_upload
                : stats.hasPendingUploads
                  ? Icons.cloud_queue
                  : Icons.cloud_done,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '${stats.completedCount}/${stats.totalCount}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorMessage(String error, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppTheme.errorColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Failed to load uploads: $error',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.errorColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadList(List<UploadTaskData> tasks, ThemeData theme, WidgetRef ref) {
    if (tasks.isEmpty) {
      return _buildEmptyState(theme);
    }

    final displayTasks = tasks.take(maxItemsToShow).toList();
    final hasMore = tasks.length > maxItemsToShow;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...displayTasks.map((task) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: UploadTaskTile(task: task),
        )),

        if (hasMore) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => _showAllUploadsDialog(ref),
            child: Text('View all ${tasks.length} uploads'),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.cloud_done,
            size: 48,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'No uploads in progress',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _showAllUploadsDialog(WidgetRef ref) {
    // TODO: Implement full upload queue dialog
  }
}

class UploadTaskTile extends ConsumerWidget {
  final UploadTaskData task;

  const UploadTaskTile({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final progressAsync = ref.watch(uploadProgressProvider(task.id));

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // File info and actions
          Row(
            children: [
              _buildFileIcon(theme),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.fileName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _formatFileSize(task.fileSize),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusIndicator(theme),
              const SizedBox(width: 8),
              _buildActionMenu(context, ref),
            ],
          ),

          // Progress bar and status
          const SizedBox(height: 8),
          _buildProgressSection(theme, progressAsync),

          // Error message if failed
          if (task.isFailed && task.errorMessage != null) ...[
            const SizedBox(height: 8),
            _buildErrorSection(task.errorMessage!, theme),
          ],
        ],
      ),
    );
  }

  Widget _buildFileIcon(ThemeData theme) {
    final extension = task.fileName.split('.').last.toLowerCase();
    IconData icon;
    Color color;

    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        icon = Icons.image;
        color = Colors.blue;
        break;
      case 'pdf':
        icon = Icons.picture_as_pdf;
        color = Colors.red;
        break;
      case 'doc':
      case 'docx':
        icon = Icons.description;
        color = Colors.blue[800]!;
        break;
      default:
        icon = Icons.attach_file;
        color = theme.colorScheme.onSurface.withOpacity(0.6);
    }

    return Icon(icon, size: 20, color: color);
  }

  Widget _buildStatusIndicator(ThemeData theme) {
    Color color;
    IconData icon;

    switch (task.status) {
      case FileSyncStatus.pending:
        color = Colors.orange;
        icon = Icons.schedule;
        break;
      case FileSyncStatus.uploading:
        color = Colors.blue;
        icon = Icons.cloud_upload;
        break;
      case FileSyncStatus.synced:
        color = Colors.green;
        icon = Icons.cloud_done;
        break;
      case FileSyncStatus.failed:
        color = Colors.red;
        icon = Icons.error;
        break;
      case FileSyncStatus.paused:
        color = Colors.grey;
        icon = Icons.pause_circle;
        break;
      case FileSyncStatus.notSynced:
        color = theme.colorScheme.onSurface.withOpacity(0.4);
        icon = Icons.cloud_off;
        break;
    }

    return Icon(icon, size: 16, color: color);
  }

  Widget _buildActionMenu(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 16),
      onSelected: (action) => _handleAction(action, ref, context),
      itemBuilder: (context) {
        final items = <PopupMenuEntry<String>>[];

        if (task.status == FileSyncStatus.uploading) {
          items.add(const PopupMenuItem(
            value: 'pause',
            child: ListTile(
              leading: Icon(Icons.pause),
              title: Text('Pause'),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ));
        } else if (task.status == FileSyncStatus.paused) {
          items.add(const PopupMenuItem(
            value: 'resume',
            child: ListTile(
              leading: Icon(Icons.play_arrow),
              title: Text('Resume'),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ));
        }

        if (task.isFailed && task.canRetry) {
          items.add(const PopupMenuItem(
            value: 'retry',
            child: ListTile(
              leading: Icon(Icons.refresh),
              title: Text('Retry'),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ));
        }

        if (task.status != FileSyncStatus.uploading) {
          items.add(const PopupMenuItem(
            value: 'cancel',
            child: ListTile(
              leading: Icon(Icons.cancel, color: Colors.red),
              title: Text('Cancel'),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ));
        }

        return items;
      },
    );
  }

  Widget _buildProgressSection(ThemeData theme, AsyncValue<int> progressAsync) {
    final progress = progressAsync.maybeWhen(
      data: (p) => p,
      orElse: () => task.progressPercent,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: task.isCompleted ? 1.0 : (progress / 100),
                backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  task.isFailed
                    ? AppTheme.errorColor
                    : task.isCompleted
                      ? AppTheme.successColor
                      : theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              task.isCompleted ? 'Complete' : '${progress}%',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _getStatusText(),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorSection(String error, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: 16,
            color: AppTheme.errorColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.errorColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText() {
    switch (task.status) {
      case FileSyncStatus.pending:
        return 'Waiting to upload...';
      case FileSyncStatus.uploading:
        return 'Uploading to Google Drive...';
      case FileSyncStatus.synced:
        return 'Uploaded successfully';
      case FileSyncStatus.failed:
        return 'Upload failed${task.retryCount > 0 ? ' (attempt ${task.retryCount + 1})' : ''}';
      case FileSyncStatus.paused:
        return 'Upload paused';
      case FileSyncStatus.notSynced:
        return 'Not scheduled for upload';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  void _handleAction(String action, WidgetRef ref, BuildContext context) {
    switch (action) {
      case 'pause':
        ref.read(fileUploadServiceProvider).pauseUpload(task.id);
        break;
      case 'resume':
        ref.read(fileUploadServiceProvider).resumeUpload(task.id);
        break;
      case 'retry':
        ref.read(fileUploadServiceProvider).retryUpload(task.id);
        break;
      case 'cancel':
        _showCancelDialog(context, ref);
        break;
    }
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Upload'),
        content: Text('Are you sure you want to cancel uploading "${task.fileName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(fileUploadServiceProvider).cancelUpload(task.id);
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Compact version for use in smaller spaces
class CompactUploadProgressWidget extends ConsumerWidget {
  const CompactUploadProgressWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statsAsync = ref.watch(uploadStatisticsProvider);

    return statsAsync.when(
      loading: () => const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, __) => Icon(
        Icons.cloud_off,
        color: AppTheme.errorColor,
        size: 20,
      ),
      data: (stats) {
        if (stats.totalCount == 0) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (stats.hasActiveUploads)
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                )
              else
                Icon(
                  stats.hasFailedUploads
                    ? Icons.cloud_off
                    : Icons.cloud_done,
                  size: 12,
                  color: stats.hasFailedUploads
                    ? AppTheme.errorColor
                    : AppTheme.successColor,
                ),
              const SizedBox(width: 4),
              Text(
                '${stats.completedCount}/${stats.totalCount}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}