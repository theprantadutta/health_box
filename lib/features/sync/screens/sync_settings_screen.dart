import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/modern_card.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/animations/common_transitions.dart';
import '../../../shared/navigation/app_router.dart';
import '../../../services/google_drive_service.dart';
import '../providers/google_drive_providers.dart';
import '../widgets/backup_management_bottom_sheet.dart';

class SyncSettingsScreen extends ConsumerStatefulWidget {
  const SyncSettingsScreen({super.key});

  @override
  ConsumerState<SyncSettingsScreen> createState() => _SyncSettingsScreenState();
}

class _SyncSettingsScreenState extends ConsumerState<SyncSettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Attempt silent sign-in when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(googleDriveAuthProvider.notifier).build();
    });
  }

  Future<void> _signIn() async {
    final success = await ref.read(googleDriveAuthProvider.notifier).signIn();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Successfully signed in to Google Drive'
                : 'Failed to sign in to Google Drive',
          ),
          backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _signOut() async {
    await ref.read(googleDriveAuthProvider.notifier).signOut();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Successfully signed out of Google Drive'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
    }
  }

  Future<void> _performManualBackup() async {
    final authState = ref.read(googleDriveAuthProvider);

    if (!authState.hasValue || !authState.value!) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please sign in to Google Drive first'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    try {
      await ref.read(backupOperationsProvider.notifier).createDatabaseBackup();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Backup created successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup failed: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }


  void _showBackupManagementSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BackupManagementBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authAsync = ref.watch(googleDriveAuthProvider);
    final syncSettingsAsync = ref.watch(syncSettingsProvider);
    final backupStatusAsync = ref.watch(backupOperationsProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(
          'Google Drive Sync',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (authAsync.isLoading || backupStatusAsync.hasValue && backupStatusAsync.value == BackupStatus.creating)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: CommonTransitions.fadeSlideIn(
          child: Column(
            children: [

              // Google Drive Account Section
              _buildAccountSection(authAsync, theme),
              const SizedBox(height: 16),

              // Sync Settings Section
              syncSettingsAsync.when(
                loading: () => _buildLoadingCard(theme),
                error: (error, _) => _buildErrorCard(theme, error.toString()),
                data: (syncSettings) => _buildSyncSettingsSection(authAsync, syncSettings, theme),
              ),
              const SizedBox(height: 16),

              // Manual Actions Section
              _buildManualActionsSection(authAsync, backupStatusAsync, theme),
              const SizedBox(height: 16),

              // Backup Management Section
              _buildBackupManagementSection(authAsync, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountSection(AsyncValue<bool> authAsync, ThemeData theme) {
    return ModernCard(
      elevation: CardElevation.medium,
      enableHoverEffect: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cloud, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Google Drive Account',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          authAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, _) => ListTile(
              leading: const Icon(Icons.error, color: Colors.red),
              title: const Text('Sign-in Error'),
              subtitle: Text('Failed to authenticate: ${error.toString()}'),
            ),
            data: (isSignedIn) {
              if (isSignedIn) {
                final authNotifier = ref.read(googleDriveAuthProvider.notifier);
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.account_circle,
                      color: AppTheme.successColor,
                    ),
                  ),
                  title: Text(
                    authNotifier.userName ?? 'Google User',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    authNotifier.userEmail ?? 'No email',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  trailing: TextButton(
                    onPressed: _signOut,
                    child: const Text('Sign Out'),
                  ),
                );
              } else {
                return Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.outline.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.account_circle_outlined,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      title: const Text('Not connected'),
                      subtitle: const Text('Sign in to enable Google Drive sync'),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _signIn,
                        icon: const Icon(Icons.login),
                        label: const Text('Connect to Google Drive'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
  Widget _buildSyncSettingsSection(
    AsyncValue<bool> authAsync,
    SyncConfiguration syncSettings,
    ThemeData theme,
  ) {
    final isSignedIn = authAsync.hasValue && authAsync.value!;

    return ModernCard(
      elevation: CardElevation.medium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.sync, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Sync Settings',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            secondary: const Icon(Icons.sync_outlined),
            title: const Text('Auto Sync'),
            subtitle: const Text(
              'Automatically backup data to Google Drive',
            ),
            value: syncSettings.autoSyncEnabled,
            onChanged: isSignedIn
                ? (value) {
                    ref
                        .read(syncSettingsProvider.notifier)
                        .updateAutoSyncEnabled(value);
                  }
                : null,
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Sync Frequency'),
            subtitle: Text(syncSettings.syncFrequency.displayName),
            trailing: DropdownButton<SyncFrequency>(
              value: syncSettings.syncFrequency,
              onChanged: isSignedIn && syncSettings.autoSyncEnabled
                  ? (value) {
                      if (value != null) {
                        ref
                            .read(syncSettingsProvider.notifier)
                            .updateSyncFrequency(value);
                      }
                    }
                  : null,
              items: SyncFrequency.values
                  .map(
                    (frequency) => DropdownMenuItem(
                      value: frequency,
                      child: Text(frequency.displayName),
                    ),
                  )
                  .toList(),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.merge),
            title: const Text('Conflict Resolution'),
            subtitle: Text(syncSettings.conflictResolution.displayName),
            trailing: DropdownButton<ConflictResolution>(
              value: syncSettings.conflictResolution,
              onChanged: isSignedIn
                  ? (value) {
                      if (value != null) {
                        ref
                            .read(syncSettingsProvider.notifier)
                            .updateConflictResolution(value);
                      }
                    }
                  : null,
              items: ConflictResolution.values
                  .map(
                    (resolution) => DropdownMenuItem(
                      value: resolution,
                      child: Text(resolution.displayName),
                    ),
                  )
                  .toList(),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.wifi),
            title: const Text('WiFi Only'),
            subtitle: const Text(
              'Only sync when connected to WiFi',
            ),
            value: syncSettings.syncOnlyOnWifi,
            onChanged: isSignedIn
                ? (value) {
                    ref
                        .read(syncSettingsProvider.notifier)
                        .updateSyncOnlyOnWifi(value);
                  }
                : null,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Backup Retention'),
            subtitle: Text(
              'Keep last ${syncSettings.maxBackupCount} backup${syncSettings.maxBackupCount > 1 ? 's' : ''}',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text('1'),
                Expanded(
                  child: Slider(
                    value: syncSettings.maxBackupCount.toDouble(),
                    min: 1,
                    max: 30,
                    divisions: 29,
                    label: syncSettings.maxBackupCount.toString(),
                    onChanged: isSignedIn
                        ? (value) {
                            ref
                                .read(syncSettingsProvider.notifier)
                                .updateMaxBackupCount(value.round());
                          }
                        : null,
                  ),
                ),
                const Text('30'),
              ],
            ),
          ),
          if (syncSettings.lastSyncTime != null) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Last Sync'),
              subtitle: Text(
                '${syncSettings.lastSyncTime!.toString().split('.')[0]}',
              ),
            ),
          ],
        ],
      ),
    );
  }
  Widget _buildManualActionsSection(
    AsyncValue<bool> authAsync,
    AsyncValue<BackupStatus> backupStatusAsync,
    ThemeData theme,
  ) {
    final isSignedIn = authAsync.hasValue && authAsync.value!;
    final isCreatingBackup = backupStatusAsync.hasValue &&
        backupStatusAsync.value == BackupStatus.creating;

    return ModernCard(
      elevation: CardElevation.medium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.backup, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Backup Actions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isSignedIn && !isCreatingBackup
                  ? _performManualBackup
                  : null,
              icon: isCreatingBackup
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.backup),
              label: Text(isCreatingBackup ? 'Creating Backup...' : 'Create Backup Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isSignedIn && !isCreatingBackup
                  ? () => context.push(AppRoutes.export)
                  : null,
              icon: const Icon(Icons.upload),
              label: const Text('Export Data'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isSignedIn && !isCreatingBackup
                  ? () => context.push(AppRoutes.import)
                  : null,
              icon: const Icon(Icons.download),
              label: const Text('Import Data'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupManagementSection(
    AsyncValue<bool> authAsync,
    ThemeData theme,
  ) {
    final isSignedIn = authAsync.hasValue && authAsync.value!;

    return ModernCard(
      elevation: CardElevation.medium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.cloud_queue,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cloud Backups',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Manage your Google Drive backups',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Backup stats
          if (isSignedIn) ...[
            Consumer(
              builder: (context, ref, child) {
                final backupsAsync = ref.watch(googleDriveBackupsProvider);
                return backupsAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (backups) {
                    final databaseBackups = backups.where((b) => b.type == BackupType.database).length;
                    final dataExports = backups.where((b) => b.type == BackupType.export).length;
                    final totalSize = backups.fold<int>(0, (sum, backup) => sum + backup.size);

                    String formatSize(int bytes) {
                      if (bytes < 1024) return '${bytes}B';
                      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
                      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
                    }

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  '🗄️',
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$databaseBackups',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Database',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  '📄',
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$dataExports',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Exports',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.storage,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formatSize(totalSize),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Total Size',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 16),
          ],

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isSignedIn
                      ? () async {
                          try {
                            await ref
                                .read(backupOperationsProvider.notifier)
                                .createDatabaseBackup();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Database backup created'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Backup failed: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      : null,
                  icon: const Text('🗄️'),
                  label: const Text('Database'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isSignedIn
                      ? () async {
                          try {
                            await ref
                                .read(backupOperationsProvider.notifier)
                                .createDataExport();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Data export created'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Export failed: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      : null,
                  icon: const Text('📄'),
                  label: const Text('Export'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isSignedIn ? _showBackupManagementSheet : null,
              icon: const Icon(Icons.folder_open),
              label: const Text('Manage All Backups'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard(ThemeData theme) {
    return ModernCard(
      elevation: CardElevation.medium,
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildErrorCard(ThemeData theme, String error) {
    return ModernCard(
      medicalTheme: MedicalCardTheme.error,
      elevation: CardElevation.medium,
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: AppTheme.errorColor,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading sync settings',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppTheme.errorColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

}
