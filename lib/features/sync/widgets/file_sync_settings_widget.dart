import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/sync_preferences.dart';
import '../../../shared/widgets/modern_card.dart';
import '../../../shared/theme/app_theme.dart';
import '../providers/file_sync_providers.dart';
import '../services/file_sync_preferences_service.dart';

class FileSyncSettingsWidget extends ConsumerStatefulWidget {
  final bool isEnabled;

  const FileSyncSettingsWidget({
    super.key,
    required this.isEnabled,
  });

  @override
  ConsumerState<FileSyncSettingsWidget> createState() => _FileSyncSettingsWidgetState();
}

class _FileSyncSettingsWidgetState extends ConsumerState<FileSyncSettingsWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preferencesAsync = ref.watch(fileSyncPreferencesProvider);
    final statsAsync = ref.watch(syncStatsProvider);

    return ModernCard(
      elevation: CardElevation.medium,
      enableHoverEffect: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with stats
          Row(
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                color: widget.isEnabled
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'File Upload Settings',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              if (statsAsync.hasValue)
                _buildSyncStatsChip(statsAsync.value!, theme),
            ],
          ),

          const SizedBox(height: 16),

          if (!widget.isEnabled)
            _buildDisabledMessage(theme)
          else
            preferencesAsync.when(
              loading: () => _buildLoadingIndicator(),
              error: (error, _) => _buildErrorMessage(error.toString(), theme),
              data: (preferences) => _buildPreferencesContent(preferences, theme),
            ),
        ],
      ),
    );
  }

  Widget _buildSyncStatsChip(SyncStatsSummary stats, ThemeData theme) {
    final color = stats.allSynced
        ? AppTheme.successColor
        : stats.hasPendingUploads
          ? AppTheme.warningColor
          : theme.colorScheme.onSurface.withOpacity(0.6);

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
            stats.allSynced
              ? Icons.cloud_done
              : stats.hasPendingUploads
                ? Icons.cloud_upload
                : Icons.cloud_off,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '${stats.syncedAttachments}/${stats.totalAttachments}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisabledMessage(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Sign in to Google Drive to enable file upload settings',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
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
              'Failed to load preferences: $error',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.errorColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesContent(SyncPreferencesData preferences, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Master toggle
        _buildMasterToggle(preferences, theme),

        if (preferences.fileUploadEnabled) ...[
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // File type filters
          _buildFileTypeFilters(preferences, theme),

          const SizedBox(height: 16),

          // Upload settings
          _buildUploadSettings(preferences, theme),
        ],
      ],
    );
  }

  Widget _buildMasterToggle(SyncPreferencesData preferences, ThemeData theme) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Enable File Uploads'),
      subtitle: Text(
        preferences.fileUploadEnabled
            ? 'Files will be automatically uploaded to Google Drive'
            : 'File uploads are disabled',
        style: theme.textTheme.bodySmall,
      ),
      value: preferences.fileUploadEnabled,
      onChanged: (value) {
        ref.read(fileSyncPreferencesProvider.notifier).updatePreferences(
          fileUploadEnabled: value,
        );
      },
    );
  }

  Widget _buildFileTypeFilters(SyncPreferencesData preferences, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'File Types to Sync',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        // Images toggle
        CheckboxListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          title: Row(
            children: [
              Icon(Icons.image, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.7)),
              const SizedBox(width: 8),
              const Text('Images'),
            ],
          ),
          subtitle: const Text('JPG, PNG, GIF, WebP'),
          value: preferences.syncImages,
          onChanged: (value) {
            ref.read(fileSyncPreferencesProvider.notifier).updatePreferences(
              syncImages: value ?? false,
            );
          },
        ),

        // PDFs toggle
        CheckboxListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          title: Row(
            children: [
              Icon(Icons.picture_as_pdf, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.7)),
              const SizedBox(width: 8),
              const Text('PDFs'),
            ],
          ),
          subtitle: const Text('PDF documents'),
          value: preferences.syncPdfs,
          onChanged: (value) {
            ref.read(fileSyncPreferencesProvider.notifier).updatePreferences(
              syncPdfs: value ?? false,
            );
          },
        ),

        // Documents toggle
        CheckboxListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          title: Row(
            children: [
              Icon(Icons.description, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.7)),
              const SizedBox(width: 8),
              const Text('Documents'),
            ],
          ),
          subtitle: const Text('DOC, DOCX, TXT, RTF'),
          value: preferences.syncDocuments,
          onChanged: (value) {
            ref.read(fileSyncPreferencesProvider.notifier).updatePreferences(
              syncDocuments: value ?? false,
            );
          },
        ),
      ],
    );
  }

  Widget _buildUploadSettings(SyncPreferencesData preferences, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Settings',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        // File size limit
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.data_usage),
          title: const Text('Max File Size'),
          subtitle: Text('${preferences.maxFileSizeMb} MB per file'),
          trailing: PopupMenuButton<int>(
            icon: const Icon(Icons.edit),
            onSelected: (value) {
              ref.read(fileSyncPreferencesProvider.notifier).updatePreferences(
                maxFileSizeMb: value,
              );
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 25, child: Text('25 MB')),
              const PopupMenuItem(value: 50, child: Text('50 MB')),
              const PopupMenuItem(value: 100, child: Text('100 MB')),
              const PopupMenuItem(value: 200, child: Text('200 MB')),
            ],
          ),
        ),

        // WiFi only toggle
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('WiFi Only'),
          subtitle: const Text('Only upload files when connected to WiFi'),
          value: preferences.wifiOnlyUpload,
          onChanged: (value) {
            ref.read(fileSyncPreferencesProvider.notifier).updatePreferences(
              wifiOnlyUpload: value,
            );
          },
        ),

        // Auto upload toggle
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Auto Upload'),
          subtitle: const Text('Automatically upload new files'),
          value: preferences.autoUpload,
          onChanged: (value) {
            ref.read(fileSyncPreferencesProvider.notifier).updatePreferences(
              autoUpload: value,
            );
          },
        ),
      ],
    );
  }
}