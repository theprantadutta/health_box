import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../services/google_drive_service.dart';
import '../../../shared/animations/common_transitions.dart';
import '../../../shared/navigation/app_router.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/modern_card.dart';
import '../providers/google_drive_providers.dart';
import '../widgets/backup_management_bottom_sheet.dart';
import '../widgets/file_sync_settings_widget.dart';

class SyncSettingsScreen extends ConsumerStatefulWidget {
  const SyncSettingsScreen({super.key});

  @override
  ConsumerState<SyncSettingsScreen> createState() => _SyncSettingsScreenState();
}

class _SyncSettingsScreenState extends ConsumerState<SyncSettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Check existing auth state when screen loads, don't force new sign-in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Only check the current state, don't trigger new authentication
      ref.read(googleDriveAuthProvider);
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
          backgroundColor: success
              ? AppTheme.successColor
              : AppTheme.errorColor,
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
    try {
      // Let the backup operation handle authentication
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
        String errorMessage = 'Backup failed: $e';
        if (e.toString().contains('authentication')) {
          errorMessage = 'Please sign in to Google Drive first';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppTheme.errorColor,
            action: e.toString().contains('authentication')
                ? SnackBarAction(
                    label: 'Sign In',
                    textColor: Colors.white,
                    onPressed: _signIn,
                  )
                : null,
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
    final backupProgressAsync = ref.watch(backupOperationsProvider);

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
          if (authAsync.isLoading ||
              (backupProgressAsync.hasValue &&
                  backupProgressAsync.value!.isActive))
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
                data: (syncSettings) =>
                    _buildSyncSettingsSection(authAsync, syncSettings, theme),
              ),
              const SizedBox(height: 16),

              // File Sync Settings Section
              FileSyncSettingsWidget(
                isEnabled: authAsync.maybeWhen(
                  data: (isSignedIn) => isSignedIn,
                  orElse: () => false,
                ),
              ),
              const SizedBox(height: 16),

              // Manual Actions Section
              _buildManualActionsSection(authAsync, backupProgressAsync, theme),
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
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.account_circle_outlined,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      title: const Text('Not connected'),
                      subtitle: const Text(
                        'Sign in to enable Google Drive sync',
                      ),
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
            subtitle: const Text('Automatically backup data to Google Drive'),
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
            subtitle: const Text('Only sync when connected to WiFi'),
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
    AsyncValue<BackupProgress> backupProgressAsync,
    ThemeData theme,
  ) {
    final backupProgress = backupProgressAsync.hasValue
        ? backupProgressAsync.value!
        : null;
    final isBackupActive = backupProgress?.isActive ?? false;

    return ModernCard(
      elevation: CardElevation.medium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with gradient background
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.1),
                  theme.colorScheme.primaryContainer.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.backup_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Backup Actions',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Create and manage your data backups',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Progress indicator when backup is active
          if (isBackupActive) ...[
            ..._buildBackupProgress(backupProgress!, theme),
            const SizedBox(height: 16),
          ],

          // Action cards in a grid
          Row(
            children: [
              // Primary backup action
              Expanded(
                flex: 2,
                child: _buildActionCard(
                  context: context,
                  title: _getBackupButtonText(backupProgress),
                  subtitle: 'Create a full backup now',
                  icon: isBackupActive
                      ? Icons.hourglass_empty
                      : Icons.cloud_upload,
                  color: theme.colorScheme.primary,
                  isPrimary: true,
                  isLoading: isBackupActive,
                  onTap: !isBackupActive ? _performManualBackup : null,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Secondary actions
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  context: context,
                  title: 'Export Data',
                  subtitle: 'Export to file',
                  icon: Icons.file_upload_outlined,
                  color: theme.colorScheme.secondary,
                  onTap: !isBackupActive
                      ? () => context.push(AppRoutes.export)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  context: context,
                  title: 'Import Data',
                  subtitle: 'Import from file',
                  icon: Icons.file_download_outlined,
                  color: theme.colorScheme.tertiary,
                  onTap: !isBackupActive
                      ? () => context.push(AppRoutes.import)
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    bool isPrimary = false,
    bool isLoading = false,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(isPrimary ? 20 : 16),
          decoration: BoxDecoration(
            color: isPrimary
                ? color.withValues(alpha: 0.1)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPrimary
                  ? color.withValues(alpha: 0.3)
                  : theme.colorScheme.outline.withValues(alpha: 0.2),
              width: isPrimary ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isPrimary ? 10 : 8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: isPrimary ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: isLoading
                        ? SizedBox(
                            width: isPrimary ? 20 : 16,
                            height: isPrimary ? 20 : 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                            ),
                          )
                        : Icon(icon, color: color, size: isPrimary ? 20 : 16),
                  ),
                  if (isPrimary) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: onTap != null
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onSurface.withValues(alpha: 0.5,),
                            ),
                          ),
                          Text(
                            subtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6,),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              if (!isPrimary) ...[
                const SizedBox(height: 12),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: onTap != null
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBackupProgress(BackupProgress progress, ThemeData theme) {
    return [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    progress.currentOperation ?? 'Processing...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (progress.fileSize != null)
                  Text(
                    progress.fileSize!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress.progress,
              backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(progress.progress * 100).toStringAsFixed(1)}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
    ];
  }

  String _getBackupButtonText(BackupProgress? progress) {
    if (progress == null || !progress.isActive) {
      return 'Create Backup Now';
    }

    switch (progress.status) {
      case BackupStatus.preparing:
        return 'Preparing...';
      case BackupStatus.creating:
        return 'Creating Backup...';
      case BackupStatus.uploading:
        return 'Uploading...';
      case BackupStatus.finalizing:
        return 'Finalizing...';
      case BackupStatus.completed:
        return 'Create Backup Now';
      default:
        return 'Processing...';
    }
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
          // Modern header with gradient background
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.secondary.withValues(alpha: 0.1),
                  theme.colorScheme.secondaryContainer.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.cloud_queue,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cloud Backups',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'View and manage your stored backups',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Enhanced backup stats with modern cards
          if (isSignedIn) ...[
            Consumer(
              builder: (context, ref, child) {
                final backupsAsync = ref.watch(googleDriveBackupsProvider);
                return backupsAsync.when(
                  loading: () => _buildStatsLoading(theme),
                  error: (_, __) => _buildStatsError(theme),
                  data: (backups) {
                    final databaseBackups = backups
                        .where((b) => b.type == BackupType.database)
                        .length;
                    final dataExports = backups
                        .where((b) => b.type == BackupType.export)
                        .length;
                    final totalSize = backups.fold<int>(
                      0,
                      (sum, backup) => sum + backup.size,
                    );

                    return _buildBackupStats(
                      theme: theme,
                      databaseBackups: databaseBackups,
                      dataExports: dataExports,
                      totalSize: totalSize,
                      totalBackups: backups.length,
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 20),
          ] else ...[
            // Not signed in state
            _buildNotSignedInState(theme),
            const SizedBox(height: 20),
          ],

          // Error display if backup failed
          Consumer(
            builder: (context, ref, child) {
              final backupProgress = ref.watch(backupOperationsProvider);
              if (backupProgress.hasValue && backupProgress.value!.hasError) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.errorColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppTheme.errorColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          backupProgress.value!.errorMessage!,
                          style: TextStyle(
                            color: AppTheme.errorColor,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Clear error by resetting state
                          ref.invalidate(backupOperationsProvider);
                        },
                        child: Text(
                          'Dismiss',
                          style: TextStyle(color: AppTheme.errorColor),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Progress display for cloud backup actions
          Consumer(
            builder: (context, ref, child) {
              final backupProgress = ref.watch(backupOperationsProvider);
              if (backupProgress.hasValue && backupProgress.value!.isActive) {
                return Column(
                  children: [
                    ..._buildBackupProgress(backupProgress.value!, theme),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Modern Action Button
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  theme.colorScheme.secondaryContainer.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isSignedIn
                    ? _showBackupManagementSheet
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Please sign in to Google Drive first',
                            ),
                            backgroundColor: AppTheme.warningColor,
                            action: SnackBarAction(
                              label: 'Sign In',
                              textColor: Colors.white,
                              onPressed: _signIn,
                            ),
                          ),
                        );
                      },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.folder_open,
                          color: theme.colorScheme.secondary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Manage All Backups',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'View, restore, and delete your cloud backups',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.7,),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
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

  Widget _buildBackupStats({
    required ThemeData theme,
    required int databaseBackups,
    required int dataExports,
    required int totalSize,
    required int totalBackups,
  }) {
    String formatSize(int bytes) {
      if (bytes < 1024) return '${bytes}B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }

    return Column(
      children: [
        // Quick stats cards
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                theme: theme,
                icon: Icons.backup,
                value: totalBackups.toString(),
                label: 'Total Backups',
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                theme: theme,
                icon: Icons.storage,
                value: formatSize(totalSize),
                label: 'Total Size',
                color: theme.colorScheme.tertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Detailed stats
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                theme: theme,
                icon: Icons.data_object,
                value: databaseBackups.toString(),
                label: 'Database Backups',
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                theme: theme,
                icon: Icons.description,
                value: dataExports.toString(),
                label: 'Data Exports',
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required ThemeData theme,
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsLoading(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          CircularProgressIndicator(color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Loading backup information...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsError(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unable to load backups',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Check your internet connection and try again',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotSignedInState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.cloud_off,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Sign in to Google Drive',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Connect your Google Drive account to view and manage your cloud backups',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(ThemeData theme, String error) {
    return ModernCard(
      medicalTheme: MedicalCardTheme.error,
      elevation: CardElevation.medium,
      child: Column(
        children: [
          Icon(Icons.error_outline, color: AppTheme.errorColor, size: 48),
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
