import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:drift/drift.dart';

import '../../../data/database/app_database.dart';
import '../../../services/google_drive_service.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/providers/onboarding_providers.dart';

part 'google_drive_providers.g.dart';

@Riverpod(keepAlive: true)
GoogleDriveService googleDriveService(Ref ref) {
  return GoogleDriveService();
}

@Riverpod(keepAlive: true)
class GoogleDriveAuth extends _$GoogleDriveAuth {
  @override
  Future<bool> build() async {
    final service = ref.read(googleDriveServiceProvider);
    return await service.signInSilently();
  }

  Future<bool> signIn() async {
    state = const AsyncValue.loading();
    final service = ref.read(googleDriveServiceProvider);

    try {
      final success = await service.signIn();
      state = AsyncValue.data(success);

      if (success) {
        // Update sync settings
        ref.read(syncSettingsProvider.notifier).updateGoogleDriveConnected(true);
      }

      return success;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  Future<void> signOut() async {
    final service = ref.read(googleDriveServiceProvider);
    await service.signOut();
    state = const AsyncValue.data(false);

    // Update sync settings
    ref.read(syncSettingsProvider.notifier).updateGoogleDriveConnected(false);
  }

  String? get userEmail {
    final service = ref.read(googleDriveServiceProvider);
    return service.currentUser?.email;
  }

  String? get userName {
    final service = ref.read(googleDriveServiceProvider);
    return service.currentUser?.displayName;
  }
}

@Riverpod(keepAlive: true)
class SyncSettings extends _$SyncSettings {
  @override
  Future<SyncConfiguration> build() async {
    final prefs = ref.read(sharedPreferencesProvider);

    return SyncConfiguration(
      isGoogleDriveConnected: prefs.getBool('google_drive_connected') ?? false,
      autoSyncEnabled: prefs.getBool('auto_sync_enabled') ?? false,
      syncFrequency: SyncFrequency.values.firstWhere(
        (freq) => freq.name == (prefs.getString('sync_frequency') ?? 'daily'),
        orElse: () => SyncFrequency.daily,
      ),
      conflictResolution: ConflictResolution.values.firstWhere(
        (res) => res.name == (prefs.getString('conflict_resolution') ?? 'askUser'),
        orElse: () => ConflictResolution.askUser,
      ),
      lastSyncTime: DateTime.tryParse(prefs.getString('last_sync_time') ?? ''),
      syncOnlyOnWifi: prefs.getBool('sync_only_on_wifi') ?? true,
      maxBackupCount: prefs.getInt('max_backup_count') ?? 5,
    );
  }

  Future<void> updateGoogleDriveConnected(bool connected) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool('google_drive_connected', connected);

    final currentState = await future;
    state = AsyncValue.data(currentState.copyWith(isGoogleDriveConnected: connected));
  }

  Future<void> updateAutoSyncEnabled(bool enabled) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool('auto_sync_enabled', enabled);

    final currentState = await future;
    state = AsyncValue.data(currentState.copyWith(autoSyncEnabled: enabled));
  }

  Future<void> updateSyncFrequency(SyncFrequency frequency) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString('sync_frequency', frequency.name);

    final currentState = await future;
    state = AsyncValue.data(currentState.copyWith(syncFrequency: frequency));
  }

  Future<void> updateConflictResolution(ConflictResolution resolution) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString('conflict_resolution', resolution.name);

    final currentState = await future;
    state = AsyncValue.data(currentState.copyWith(conflictResolution: resolution));
  }

  Future<void> updateSyncOnlyOnWifi(bool wifiOnly) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool('sync_only_on_wifi', wifiOnly);

    final currentState = await future;
    state = AsyncValue.data(currentState.copyWith(syncOnlyOnWifi: wifiOnly));
  }

  Future<void> updateLastSyncTime([DateTime? time]) async {
    final syncTime = time ?? DateTime.now();
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString('last_sync_time', syncTime.toIso8601String());

    final currentState = await future;
    state = AsyncValue.data(currentState.copyWith(lastSyncTime: syncTime));
  }

  Future<void> updateMaxBackupCount(int count) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt('max_backup_count', count);

    final currentState = await future;
    state = AsyncValue.data(currentState.copyWith(maxBackupCount: count));
  }
}

@riverpod
Future<List<BackupFile>> googleDriveBackups(Ref ref) async {
  final service = ref.read(googleDriveServiceProvider);
  final isSignedIn = await ref.watch(googleDriveAuthProvider.future);

  if (!isSignedIn) return [];

  try {
    return await service.listAllBackups();
  } catch (e) {
    throw Exception('Failed to load backups: $e');
  }
}

@riverpod
class BackupOperations extends _$BackupOperations {
  @override
  Future<BackupStatus> build() async {
    return BackupStatus.idle;
  }

  Future<void> createDatabaseBackup() async {
    state = const AsyncValue.data(BackupStatus.creating);

    try {
      final database = ref.read(appDatabaseProvider);
      final service = ref.read(googleDriveServiceProvider);

      // Create local database backup
      final backupPath = await database.backupDatabase();
      final fileName = 'healthbox_database_${DateTime.now().millisecondsSinceEpoch}.db';

      // Upload database file to Google Drive
      await service.uploadDatabaseBackup(backupPath, fileName);

      // Clean up local backup file
      final backupFile = File(backupPath);
      if (await backupFile.exists()) {
        await backupFile.delete();
      }

      // Update last sync time
      await ref.read(syncSettingsProvider.notifier).updateLastSyncTime();

      // Clean up old backups based on retention settings
      await _cleanupOldBackups();

      // Refresh backup list
      ref.invalidate(googleDriveBackupsProvider);

      state = const AsyncValue.data(BackupStatus.completed);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> createDataExport() async {
    state = const AsyncValue.data(BackupStatus.creating);

    try {
      final database = ref.read(appDatabaseProvider);
      final service = ref.read(googleDriveServiceProvider);

      // Export all data as JSON
      final exportData = await _exportAllData(database);
      final fileName = 'healthbox_export_${DateTime.now().millisecondsSinceEpoch}.json';

      await service.uploadDataExport(jsonEncode(exportData), fileName);

      // Update last sync time
      await ref.read(syncSettingsProvider.notifier).updateLastSyncTime();

      // Clean up old backups based on retention settings
      await _cleanupOldBackups();

      // Refresh backup list
      ref.invalidate(googleDriveBackupsProvider);

      state = const AsyncValue.data(BackupStatus.completed);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> restoreDatabaseBackup(String fileId) async {
    state = const AsyncValue.data(BackupStatus.restoring);

    try {
      final service = ref.read(googleDriveServiceProvider);
      final database = ref.read(appDatabaseProvider);

      // Get local database path
      final dbFolder = await getApplicationDocumentsDirectory();
      final tempRestorePath = p.join(dbFolder.path, 'temp_restore.db');

      // Download database backup
      await service.downloadDatabaseBackup(fileId, tempRestorePath);

      // Close current database connection
      await database.close();

      // Replace current database with backup
      final currentDbPath = p.join(dbFolder.path, 'health_box.db');
      final tempFile = File(tempRestorePath);
      final currentFile = File(currentDbPath);

      if (await currentFile.exists()) {
        await currentFile.delete();
      }

      await tempFile.copy(currentDbPath);
      await tempFile.delete();

      // Reinitialize database
      // Note: You may need to restart the app for this to take full effect

      state = const AsyncValue.data(BackupStatus.completed);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> restoreDataExport(String fileId) async {
    state = const AsyncValue.data(BackupStatus.restoring);

    try {
      final service = ref.read(googleDriveServiceProvider);
      final database = ref.read(appDatabaseProvider);

      // Download and parse export data
      final exportData = await service.downloadDataExport(fileId);
      final data = jsonDecode(exportData) as Map<String, dynamic>;

      // Restore data to database
      await _restoreAllData(database, data);

      state = const AsyncValue.data(BackupStatus.completed);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deleteBackup(String fileId) async {
    try {
      final service = ref.read(googleDriveServiceProvider);
      await service.deleteBackup(fileId);

      // Refresh backup list
      ref.invalidate(googleDriveBackupsProvider);
    } catch (e) {
      throw Exception('Failed to delete backup: $e');
    }
  }

  Future<Map<String, dynamic>> _exportAllData(AppDatabase database) async {
    final profiles = await database.select(database.familyMemberProfiles).get();
    final medicalRecords = await database.select(database.medicalRecords).get();
    final prescriptions = await database.select(database.prescriptions).get();
    final medications = await database.select(database.medications).get();
    final labReports = await database.select(database.labReports).get();
    final vaccinations = await database.select(database.vaccinations).get();
    final allergies = await database.select(database.allergies).get();
    final chronicConditions = await database.select(database.chronicConditions).get();
    final reminders = await database.select(database.reminders).get();
    final emergencyCards = await database.select(database.emergencyCards).get();

    return {
      'export_date': DateTime.now().toIso8601String(),
      'app_version': '1.0.0',
      'data': {
        'profiles': profiles.map((p) => p.toJson()).toList(),
        'medical_records': medicalRecords.map((r) => r.toJson()).toList(),
        'prescriptions': prescriptions.map((p) => p.toJson()).toList(),
        'medications': medications.map((m) => m.toJson()).toList(),
        'lab_reports': labReports.map((l) => l.toJson()).toList(),
        'vaccinations': vaccinations.map((v) => v.toJson()).toList(),
        'allergies': allergies.map((a) => a.toJson()).toList(),
        'chronic_conditions': chronicConditions.map((c) => c.toJson()).toList(),
        'reminders': reminders.map((r) => r.toJson()).toList(),
        'emergency_cards': emergencyCards.map((e) => e.toJson()).toList(),
      },
    };
  }

  Future<void> _restoreAllData(AppDatabase database, Map<String, dynamic> backupData) async {
    final data = backupData['data'] as Map<String, dynamic>;

    // Clear existing data first (optional - you might want to merge instead)
    await database.transaction(() async {
      // Restore profiles
      if (data['profiles'] != null) {
        for (final profileData in data['profiles'] as List) {
          await database.into(database.familyMemberProfiles).insertOnConflictUpdate(
            FamilyMemberProfilesCompanion.insert(
              id: profileData['id'],
              firstName: profileData['first_name'],
              lastName: profileData['last_name'],
              dateOfBirth: DateTime.parse(profileData['date_of_birth']),
              gender: profileData['gender'],
              bloodType: Value(profileData['blood_type']),
              height: Value(profileData['height']?.toDouble()),
              weight: Value(profileData['weight']?.toDouble()),
              emergencyContact: Value(profileData['emergency_contact']),
              insuranceInfo: Value(profileData['insurance_info']),
              createdAt: Value(DateTime.parse(profileData['created_at'])),
              updatedAt: Value(DateTime.parse(profileData['updated_at'])),
            ),
          );
        }
      }

      // Restore other data types...
      // Note: This is a simplified example. You'll need to implement restoration
      // for all data types based on your database schema
    });
  }

  Future<void> _cleanupOldBackups() async {
    try {
      final service = ref.read(googleDriveServiceProvider);
      final syncSettings = await ref.read(syncSettingsProvider.future);
      final maxCount = syncSettings.maxBackupCount;

      // Get database backups and clean up
      final databaseBackups = await service.listDatabaseBackups();
      if (databaseBackups.length > maxCount) {
        // Sort by creation time (newest first)
        databaseBackups.sort((a, b) => b.createdTime.compareTo(a.createdTime));

        // Delete excess backups
        final backupsToDelete = databaseBackups.skip(maxCount);
        for (final backup in backupsToDelete) {
          await service.deleteBackup(backup.id);
        }
      }

      // Get data exports and clean up
      final dataExports = await service.listDataExports();
      if (dataExports.length > maxCount) {
        // Sort by creation time (newest first)
        dataExports.sort((a, b) => b.createdTime.compareTo(a.createdTime));

        // Delete excess exports
        final exportsToDelete = dataExports.skip(maxCount);
        for (final export in exportsToDelete) {
          await service.deleteBackup(export.id);
        }
      }
    } catch (e) {
      // Log error but don't fail the backup operation
      debugPrint('Failed to cleanup old backups: $e');
    }
  }
}

enum BackupStatus {
  idle,
  creating,
  restoring,
  completed,
}

enum SyncFrequency {
  manual('Manual'),
  daily('Daily'),
  weekly('Weekly'),
  monthly('Monthly');

  const SyncFrequency(this.displayName);
  final String displayName;
}

enum ConflictResolution {
  askUser('Ask me'),
  useLocal('Use local'),
  useRemote('Use remote'),
  mergeData('Merge data');

  const ConflictResolution(this.displayName);
  final String displayName;
}

class SyncConfiguration {
  final bool isGoogleDriveConnected;
  final bool autoSyncEnabled;
  final SyncFrequency syncFrequency;
  final ConflictResolution conflictResolution;
  final DateTime? lastSyncTime;
  final bool syncOnlyOnWifi;
  final int maxBackupCount;

  const SyncConfiguration({
    required this.isGoogleDriveConnected,
    required this.autoSyncEnabled,
    required this.syncFrequency,
    required this.conflictResolution,
    this.lastSyncTime,
    required this.syncOnlyOnWifi,
    required this.maxBackupCount,
  });

  SyncConfiguration copyWith({
    bool? isGoogleDriveConnected,
    bool? autoSyncEnabled,
    SyncFrequency? syncFrequency,
    ConflictResolution? conflictResolution,
    DateTime? lastSyncTime,
    bool? syncOnlyOnWifi,
    int? maxBackupCount,
  }) {
    return SyncConfiguration(
      isGoogleDriveConnected: isGoogleDriveConnected ?? this.isGoogleDriveConnected,
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      syncFrequency: syncFrequency ?? this.syncFrequency,
      conflictResolution: conflictResolution ?? this.conflictResolution,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      syncOnlyOnWifi: syncOnlyOnWifi ?? this.syncOnlyOnWifi,
      maxBackupCount: maxBackupCount ?? this.maxBackupCount,
    );
  }
}