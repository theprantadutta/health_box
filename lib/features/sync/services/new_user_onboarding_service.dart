import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/google_drive_service.dart';
import '../providers/google_drive_providers.dart';

class NewUserOnboardingService {
  static final NewUserOnboardingService _instance = NewUserOnboardingService._();
  factory NewUserOnboardingService() => _instance;
  NewUserOnboardingService._();

  /// Check if user has existing backups when they first sign in
  Future<OnboardingResult> checkExistingBackups(WidgetRef ref) async {
    try {
      final service = ref.read(googleDriveServiceProvider);

      // Get all existing backups
      final allBackups = await service.listAllBackups();

      if (allBackups.isEmpty) {
        return OnboardingResult.noBackups();
      }

      // Separate database backups and data exports
      final databaseBackups = allBackups.where((b) => b.type == BackupType.database).toList();
      final dataExports = allBackups.where((b) => b.type == BackupType.export).toList();

      return OnboardingResult.hasBackups(
        totalBackups: allBackups.length,
        databaseBackups: databaseBackups.length,
        dataExports: dataExports.length,
        latestBackup: allBackups.isNotEmpty
            ? allBackups.reduce((a, b) =>
                a.createdTime.isAfter(b.createdTime) ? a : b)
            : null,
      );
    } catch (e) {
      debugPrint('Failed to check existing backups: $e');
      return OnboardingResult.error(e.toString());
    }
  }

  /// Show onboarding dialog to user with import/cleanup choice
  Future<UserChoice?> showOnboardingDialog(
    BuildContext context,
    OnboardingResult result,
  ) async {
    if (result.hasError || !result.hasExistingBackups) {
      return null;
    }

    return showDialog<UserChoice>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _OnboardingDialog(result: result),
    );
  }

  /// Import the latest database backup
  Future<void> importLatestBackup(WidgetRef ref, BackupFile backup) async {
    try {
      if (backup.type == BackupType.database) {
        await ref
            .read(backupOperationsProvider.notifier)
            .restoreDatabaseBackup(backup.id);
      } else {
        await ref
            .read(backupOperationsProvider.notifier)
            .restoreDataExport(backup.id);
      }
    } catch (e) {
      debugPrint('Failed to import backup: $e');
      rethrow;
    }
  }

  /// Delete all existing backups
  Future<void> deleteAllBackups(WidgetRef ref) async {
    try {
      final service = ref.read(googleDriveServiceProvider);
      final allBackups = await service.listAllBackups();

      for (final backup in allBackups) {
        await service.deleteBackup(backup.id);
      }
    } catch (e) {
      debugPrint('Failed to delete backups: $e');
      rethrow;
    }
  }
}

class OnboardingResult {
  final bool hasExistingBackups;
  final int totalBackups;
  final int databaseBackups;
  final int dataExports;
  final BackupFile? latestBackup;
  final String? error;

  const OnboardingResult._({
    required this.hasExistingBackups,
    required this.totalBackups,
    required this.databaseBackups,
    required this.dataExports,
    this.latestBackup,
    this.error,
  });

  factory OnboardingResult.noBackups() {
    return const OnboardingResult._(
      hasExistingBackups: false,
      totalBackups: 0,
      databaseBackups: 0,
      dataExports: 0,
    );
  }

  factory OnboardingResult.hasBackups({
    required int totalBackups,
    required int databaseBackups,
    required int dataExports,
    BackupFile? latestBackup,
  }) {
    return OnboardingResult._(
      hasExistingBackups: true,
      totalBackups: totalBackups,
      databaseBackups: databaseBackups,
      dataExports: dataExports,
      latestBackup: latestBackup,
    );
  }

  factory OnboardingResult.error(String error) {
    return OnboardingResult._(
      hasExistingBackups: false,
      totalBackups: 0,
      databaseBackups: 0,
      dataExports: 0,
      error: error,
    );
  }

  bool get hasError => error != null;
}

enum UserChoice {
  importBackups,
  deleteBackups,
  skipOnboarding,
}

class _OnboardingDialog extends StatelessWidget {
  final OnboardingResult result;

  const _OnboardingDialog({required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.cloud_queue, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          const Text('Existing Backups Found'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'We found ${result.totalBackups} existing backup${result.totalBackups > 1 ? 's' : ''} in your Google Drive:',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),

          // Backup stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '🗄️',
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${result.databaseBackups}',
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
                    Column(
                      children: [
                        Text(
                          '📄',
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${result.dataExports}',
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
                  ],
                ),
                if (result.latestBackup != null) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Latest: ${result.latestBackup!.name}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),
          Text(
            'Would you like to:',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, UserChoice.skipOnboarding),
          child: const Text('Skip for now'),
        ),
        OutlinedButton.icon(
          onPressed: () => Navigator.pop(context, UserChoice.deleteBackups),
          icon: const Icon(Icons.delete, color: Colors.red),
          label: const Text('Delete all'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => Navigator.pop(context, UserChoice.importBackups),
          icon: const Icon(Icons.download),
          label: const Text('Import data'),
        ),
      ],
    );
  }
}

// Provider for the onboarding service
final newUserOnboardingServiceProvider = Provider<NewUserOnboardingService>((ref) {
  return NewUserOnboardingService();
});