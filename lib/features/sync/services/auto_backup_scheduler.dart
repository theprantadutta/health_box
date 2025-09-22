import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../providers/google_drive_providers.dart';

part 'auto_backup_scheduler.g.dart';

@riverpod
AutoBackupScheduler autoBackupScheduler(Ref ref) {
  return AutoBackupScheduler(ref);
}

class AutoBackupScheduler {
  final Ref ref;

  AutoBackupScheduler(this.ref);

  /// Checks if a backup is needed based on the current sync frequency and last sync time
  Future<bool> isBackupNeeded() async {
    try {
      final syncSettings = await ref.read(syncSettingsProvider.future);

      // If auto sync is disabled, no backup is needed
      if (!syncSettings.autoSyncEnabled) {
        debugPrint('Auto sync is disabled, no backup needed');
        return false;
      }

      final lastSyncTime = syncSettings.lastSyncTime;
      final syncFrequency = syncSettings.syncFrequency;

      // If no previous sync, backup is needed
      if (lastSyncTime == null) {
        debugPrint('No previous sync found, backup needed');
        return true;
      }

      final now = DateTime.now();
      final isNeeded = _shouldBackupBasedOnFrequency(lastSyncTime, now, syncFrequency);

      debugPrint('Backup needed check: frequency=$syncFrequency, lastSync=$lastSyncTime, needed=$isNeeded');
      return isNeeded;
    } catch (e) {
      debugPrint('Error checking if backup is needed: $e');
      // In case of error, default to not needing backup to avoid spam
      return false;
    }
  }

  /// Determines if backup is needed based on frequency and time comparison
  bool _shouldBackupBasedOnFrequency(DateTime lastSync, DateTime now, SyncFrequency frequency) {
    switch (frequency) {
      case SyncFrequency.daily:
        return _isDifferentDay(lastSync, now);

      case SyncFrequency.weekly:
        return _isDifferentWeek(lastSync, now);

      case SyncFrequency.monthly:
        return _isDifferentMonth(lastSync, now);
    }
  }

  /// Checks if two dates are on different days
  bool _isDifferentDay(DateTime date1, DateTime date2) {
    return date1.year != date2.year ||
           date1.month != date2.month ||
           date1.day != date2.day;
  }

  /// Checks if two dates are in different weeks (Monday to Sunday)
  bool _isDifferentWeek(DateTime date1, DateTime date2) {
    // Get the start of the week (Monday) for both dates
    final startOfWeek1 = _getStartOfWeek(date1);
    final startOfWeek2 = _getStartOfWeek(date2);

    return startOfWeek1 != startOfWeek2;
  }

  /// Checks if two dates are in different months
  bool _isDifferentMonth(DateTime date1, DateTime date2) {
    return date1.year != date2.year || date1.month != date2.month;
  }

  /// Gets the start of the week (Monday) for a given date
  DateTime _getStartOfWeek(DateTime date) {
    // DateTime.weekday: 1 = Monday, 7 = Sunday
    final daysFromMonday = date.weekday - 1;
    return DateTime(date.year, date.month, date.day - daysFromMonday);
  }

  /// Gets a human-readable description of when the next backup will be needed
  Future<String> getNextBackupDescription() async {
    try {
      final syncSettings = await ref.read(syncSettingsProvider.future);
      final lastSyncTime = syncSettings.lastSyncTime;
      final syncFrequency = syncSettings.syncFrequency;

      if (lastSyncTime == null) {
        return 'Backup needed now (first backup)';
      }

      final now = DateTime.now();

      switch (syncFrequency) {
        case SyncFrequency.daily:
          final nextDay = DateTime(now.year, now.month, now.day + 1);
          return 'Next backup: ${_formatDate(nextDay)}';

        case SyncFrequency.weekly:
          final startOfNextWeek = _getStartOfWeek(now).add(const Duration(days: 7));
          return 'Next backup: Week of ${_formatDate(startOfNextWeek)}';

        case SyncFrequency.monthly:
          final nextMonth = DateTime(now.year, now.month + 1, 1);
          return 'Next backup: ${_formatDate(nextMonth)}';
      }
    } catch (e) {
      debugPrint('Error getting next backup description: $e');
      return 'Next backup: Unknown';
    }
  }

  /// Formats a date for display
  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Gets detailed backup status information
  Future<BackupScheduleInfo> getBackupScheduleInfo() async {
    try {
      final syncSettings = await ref.read(syncSettingsProvider.future);
      final isNeeded = await isBackupNeeded();
      final nextBackupDescription = await getNextBackupDescription();

      return BackupScheduleInfo(
        autoSyncEnabled: syncSettings.autoSyncEnabled,
        syncFrequency: syncSettings.syncFrequency,
        lastSyncTime: syncSettings.lastSyncTime,
        isBackupNeeded: isNeeded,
        nextBackupDescription: nextBackupDescription,
      );
    } catch (e) {
      debugPrint('Error getting backup schedule info: $e');
      return BackupScheduleInfo(
        autoSyncEnabled: false,
        syncFrequency: SyncFrequency.daily,
        lastSyncTime: null,
        isBackupNeeded: false,
        nextBackupDescription: 'Error getting schedule info',
      );
    }
  }
}

class BackupScheduleInfo {
  final bool autoSyncEnabled;
  final SyncFrequency syncFrequency;
  final DateTime? lastSyncTime;
  final bool isBackupNeeded;
  final String nextBackupDescription;

  const BackupScheduleInfo({
    required this.autoSyncEnabled,
    required this.syncFrequency,
    required this.lastSyncTime,
    required this.isBackupNeeded,
    required this.nextBackupDescription,
  });

  @override
  String toString() {
    return 'BackupScheduleInfo(autoSyncEnabled: $autoSyncEnabled, '
           'frequency: $syncFrequency, lastSync: $lastSyncTime, '
           'isNeeded: $isBackupNeeded, next: $nextBackupDescription)';
  }
}