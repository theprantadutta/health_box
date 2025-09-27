import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/google_drive_providers.dart';
import 'auto_backup_scheduler.dart';

class BackgroundSyncService {
  static final BackgroundSyncService _instance = BackgroundSyncService._();
  factory BackgroundSyncService() => _instance;
  BackgroundSyncService._();

  bool _isBackupInProgress = false;
  StreamController<BackgroundSyncStatusData>? _statusController;

  Stream<BackgroundSyncStatusData> get statusStream {
    _statusController ??= StreamController<BackgroundSyncStatusData>.broadcast();
    return _statusController!.stream;
  }

  Future<void> performBackgroundBackup(WidgetRef ref) async {
    if (_isBackupInProgress) {
      debugPrint('Background backup already in progress, skipping');
      return;
    }

    _isBackupInProgress = true;
    _emitStatus(BackgroundSyncStatus.inProgress);

    try {
      debugPrint('Starting background backup...');

      // Check if user is authenticated and auto-sync is enabled
      final authState = await ref.read(googleDriveAuthProvider.future);
      if (!authState) {
        debugPrint('Google Drive not authenticated, skipping background backup');
        _emitStatus(BackgroundSyncStatus.skipped);
        return;
      }

      final syncSettings = await ref.read(syncSettingsProvider.future);
      if (!syncSettings.autoSyncEnabled) {
        debugPrint('Auto-sync not enabled, skipping background backup');
        _emitStatus(BackgroundSyncStatus.skipped);
        return;
      }

      // Check if backup is needed based on frequency
      final autoBackupScheduler = ref.read(autoBackupSchedulerProvider);
      final isBackupNeeded = await autoBackupScheduler.isBackupNeeded();

      if (!isBackupNeeded) {
        debugPrint('Backup not needed based on current frequency schedule, skipping');
        _emitStatus(BackgroundSyncStatus.skipped);
        return;
      }

      debugPrint('Backup needed based on frequency schedule, proceeding...');

      // Check if we should only sync on WiFi (simplified for now)
      // In a real implementation, you'd check network connectivity
      if (syncSettings.syncOnlyOnWifi) {
        debugPrint('WiFi-only sync enabled (network check not implemented)');
      }

      // Perform backup in the background using compute
      await _performIsolatedBackup(ref);

      debugPrint('Background backup completed successfully');
      _emitStatus(BackgroundSyncStatus.completed);
    } catch (e, stackTrace) {
      debugPrint('Background backup failed: $e');
      debugPrint('Stack trace: $stackTrace');
      _emitStatus(BackgroundSyncStatus.error, e.toString());
    } finally {
      _isBackupInProgress = false;
    }
  }

  Future<void> _performIsolatedBackup(WidgetRef ref) async {
    try {
      // For now, we'll use the existing backup operation
      // In a real implementation, you might want to use compute() for heavy operations
      await ref.read(backupOperationsProvider.notifier).createDatabaseBackup();
    } catch (e) {
      // If database backup fails, try data export as fallback
      debugPrint('Database backup failed, trying data export: $e');
      try {
        await ref.read(backupOperationsProvider.notifier).createDataExport();
      } catch (exportError) {
        // Re-throw the original error since fallback also failed
        throw Exception('Both database backup and data export failed. Original error: $e, Export error: $exportError');
      }
    }
  }

  void _emitStatus(BackgroundSyncStatus status, [String? message]) {
    if (_statusController != null && !_statusController!.isClosed) {
      _statusController!.add(BackgroundSyncStatusData(status, message));
    }
  }

  void dispose() {
    _statusController?.close();
    _statusController = null;
  }
}

enum BackgroundSyncStatus {
  idle,
  inProgress,
  completed,
  error,
  skipped,
}

class BackgroundSyncStatusData {
  final BackgroundSyncStatus status;
  final String? message;
  final DateTime timestamp;

  BackgroundSyncStatusData(this.status, [this.message])
      : timestamp = DateTime.now();

  @override
  String toString() {
    return 'BackgroundSyncStatus{status: $status, message: $message, timestamp: $timestamp}';
  }
}

// Provider for the background sync service
final backgroundSyncServiceProvider = Provider<BackgroundSyncService>((ref) {
  final service = BackgroundSyncService();
  ref.onDispose(() => service.dispose());
  return service;
});

// Provider for background sync status
final backgroundSyncStatusProvider = StreamProvider<BackgroundSyncStatusData>((ref) {
  final service = ref.watch(backgroundSyncServiceProvider);
  return service.statusStream.cast<BackgroundSyncStatusData>();
});