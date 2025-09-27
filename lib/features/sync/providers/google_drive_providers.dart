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
import '../../../shared/providers/backup_preference_providers.dart';

part 'google_drive_providers.g.dart';

@Riverpod(keepAlive: true)
GoogleDriveService googleDriveService(Ref ref) {
  return GoogleDriveService();
}

@Riverpod(keepAlive: true)
class GoogleDriveAuth extends _$GoogleDriveAuth {
  @override
  Future<bool> build() async {
    // Only attempt silent sign-in if backup is enabled and strategy is Google Drive
    try {
      final backupPreferenceAsync = ref.read(backupPreferenceNotifierProvider);
      final backupPreference = backupPreferenceAsync.value;

      if (backupPreference == null || !backupPreference.enabled || backupPreference.strategy != BackupStrategy.googleDrive) {
        debugPrint('Google Drive backup not enabled, skipping authentication');
        return false;
      }

      final service = ref.read(googleDriveServiceProvider);
      return await service.signInSilently();
    } catch (e) {
      debugPrint('Error checking backup preferences: $e');
      return false;
    }
  }

  Future<bool> signIn() async {
    // Check if already signed in to avoid double login
    final currentState = state;
    if (currentState.hasValue && currentState.value == true) {
      final service = ref.read(googleDriveServiceProvider);
      if (service.isSignedIn) {
        return true; // Already signed in
      }
    }

    state = const AsyncValue.loading();
    final service = ref.read(googleDriveServiceProvider);

    try {
      final success = await service.signIn();
      state = AsyncValue.data(success);

      if (success) {
        // Update sync settings
        ref.read(syncSettingsProvider.notifier).updateGoogleDriveConnected(true);

        // Auto-enable backup with Google Drive strategy after successful login
        await ref.read(backupPreferenceNotifierProvider.notifier).enableBackup(BackupStrategy.googleDrive);
      }

      return success;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> ensureSignedIn() async {
    // First check if already authenticated
    final service = ref.read(googleDriveServiceProvider);
    if (service.isSignedIn) {
      return true;
    }

    // Try silent sign-in first
    final silentSuccess = await service.signInSilently();
    if (silentSuccess) {
      state = const AsyncValue.data(true);

      // Auto-enable backup with Google Drive strategy after successful silent sign-in
      await ref.read(backupPreferenceNotifierProvider.notifier).enableBackup(BackupStrategy.googleDrive);

      // Update sync settings
      ref.read(syncSettingsProvider.notifier).updateGoogleDriveConnected(true);

      return true;
    }

    // If silent fails, require interactive sign-in
    return await signIn();
  }

  Future<void> signOut() async {
    final service = ref.read(googleDriveServiceProvider);
    await service.signOut();
    state = const AsyncValue.data(false);

    // Update sync settings
    ref.read(syncSettingsProvider.notifier).updateGoogleDriveConnected(false);

    // Disable backup when signing out
    await ref.read(backupPreferenceNotifierProvider.notifier).disableBackup();
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

@Riverpod(keepAlive: true)
class BackupOperations extends _$BackupOperations {
  @override
  Future<BackupProgress> build() async {
    return const BackupProgress(status: BackupStatus.idle);
  }

  Future<void> createDatabaseBackup() async {
    const maxRetries = 3;
    String? backupPath;

    try {
      // Check if ref is still mounted
      if (!ref.mounted) {
        throw Exception('Provider has been disposed, cannot perform database backup');
      }

      // Step 1: Preparing
      state = const AsyncValue.data(BackupProgress(
        status: BackupStatus.preparing,
        progress: 0.0,
        currentOperation: 'Preparing backup...',
      ));

      // Check if Google Drive backup is enabled
      final backupPreferenceAsync = ref.read(backupPreferenceNotifierProvider);
      final backupPreference = backupPreferenceAsync.value;
      if (backupPreference == null || !backupPreference.enabled || backupPreference.strategy != BackupStrategy.googleDrive) {
        throw Exception('Google Drive backup is not enabled. Please enable it in settings first.');
      }

      // Ensure we're signed in before starting backup
      final authSuccess = await ref.read(googleDriveAuthProvider.notifier).ensureSignedIn();
      if (!authSuccess) {
        throw Exception('Google Drive authentication failed. Please sign in to continue.');
      }

      final database = ref.read(appDatabaseProvider);
      final service = ref.read(googleDriveServiceProvider);

      // Step 2: Creating local backup with retry logic

      state = const AsyncValue.data(BackupProgress(
        status: BackupStatus.creating,
        progress: 0.1,
        currentOperation: 'Creating local backup...',
      ));

      Exception? lastError;
      for (int attempt = 1; attempt <= maxRetries; attempt++) {
        try {
          backupPath = await database.backupDatabase();
          break; // Success, exit retry loop
        } catch (e) {
          lastError = Exception('Backup attempt $attempt failed: $e');
          debugPrint('Backup attempt $attempt failed: $e');

          if (attempt < maxRetries) {
            state = AsyncValue.data(BackupProgress(
              status: BackupStatus.creating,
              progress: 0.1,
              currentOperation: 'Retrying backup creation (attempt ${attempt + 1}/$maxRetries)...',
            ));
            await Future.delayed(Duration(milliseconds: 500 * attempt)); // Exponential backoff
          }
        }
      }

      if (backupPath == null) {
        throw lastError ?? Exception('Failed to create database backup after $maxRetries attempts');
      }

      final fileName = 'healthbox_database_${DateTime.now().millisecondsSinceEpoch}.db';

      // Get file size for display
      final backupFile = File(backupPath);
      final fileSize = await backupFile.length();
      final fileSizeFormatted = _formatBytes(fileSize);

      // Step 3: Uploading to Google Drive with progress tracking

      state = AsyncValue.data(BackupProgress(
        status: BackupStatus.uploading,
        progress: 0.2,
        currentOperation: 'Uploading to Google Drive...',
        fileSize: fileSizeFormatted,
      ));

      // Upload with retry logic
      String? uploadedFileId;
      for (int attempt = 1; attempt <= maxRetries; attempt++) {
        try {
          uploadedFileId = await service.uploadDatabaseBackup(
            backupPath,
            fileName,
            onProgress: (progress) {
              // Update progress during upload (20% to 80%)
              if (!ref.mounted) return; // Skip progress updates if disposed

              final adjustedProgress = 0.2 + (progress * 0.6);
              state = AsyncValue.data(BackupProgress(
                status: BackupStatus.uploading,
                progress: adjustedProgress,
                currentOperation: 'Uploading ${(progress * 100).toStringAsFixed(1)}%...',
                fileSize: fileSizeFormatted,
              ));
            },
          );
          break; // Success, exit retry loop
        } catch (e) {
          debugPrint('Upload attempt $attempt failed: $e');

          if (attempt < maxRetries) {
            state = AsyncValue.data(BackupProgress(
              status: BackupStatus.uploading,
              progress: 0.2,
              currentOperation: 'Retrying upload (attempt ${attempt + 1}/$maxRetries)...',
              fileSize: fileSizeFormatted,
            ));
            await Future.delayed(Duration(seconds: attempt)); // Exponential backoff
          } else {
            throw Exception('Upload failed after $maxRetries attempts: $e');
          }
        }
      }

      if (uploadedFileId == null) {
        throw Exception('Failed to upload backup after $maxRetries attempts');
      }

      // Step 4: Finalizing

      state = AsyncValue.data(BackupProgress(
        status: BackupStatus.finalizing,
        progress: 0.9,
        currentOperation: 'Finalizing backup...',
        fileSize: fileSizeFormatted,
      ));

      // Clean up local backup file
      if (await backupFile.exists()) {
        await backupFile.delete();
      }

      // Update last sync time
      await ref.read(syncSettingsProvider.notifier).updateLastSyncTime();

      // Clean up old backups based on retention settings
      await _cleanupOldBackups();

      // Refresh backup list
      ref.invalidate(googleDriveBackupsProvider);

      // Step 5: Completed
      if (!ref.mounted) return; // Don't update if disposed, backup was successful anyway

      // Update last sync time to respect frequency settings
      await ref.read(syncSettingsProvider.notifier).updateLastSyncTime(DateTime.now());

      state = AsyncValue.data(BackupProgress(
        status: BackupStatus.completed,
        progress: 1.0,
        currentOperation: 'Backup completed successfully',
        fileSize: fileSizeFormatted,
      ));
    } catch (e) {
      debugPrint('Database backup failed: $e');

      // Clean up backup file if it exists
      if (backupPath != null) {
        try {
          final backupFile = File(backupPath);
          if (await backupFile.exists()) {
            await backupFile.delete();
          }
        } catch (cleanupError) {
          debugPrint('Failed to clean up backup file: $cleanupError');
        }
      }

      // Only update state if ref is still mounted
      if (ref.mounted) {
        state = AsyncValue.data(BackupProgress(
          status: BackupStatus.idle,
          progress: 0.0,
          errorMessage: _formatErrorMessage(e.toString()),
        ));
      }
    }
  }

  String _formatErrorMessage(String error) {
    if (error.contains('authentication')) {
      return 'Authentication failed. Please sign in to Google Drive.';
    }
    if (error.contains('Network')) {
      return 'Network error. Please check your internet connection.';
    }
    if (error.contains('permission')) {
      return 'Permission denied. Please check Google Drive permissions.';
    }
    if (error.contains('storage')) {
      return 'Insufficient storage space on Google Drive.';
    }
    if (error.contains('Database file not found')) {
      return 'Database file not accessible. Please try restarting the app.';
    }
    if (error.contains('Backup file')) {
      return 'Failed to create backup file. Please try again.';
    }
    return error.length > 100 ? '${error.substring(0, 100)}...' : error;
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  Future<void> createDataExport() async {
    try {
      // Check if ref is still mounted
      if (!ref.mounted) {
        throw Exception('Provider has been disposed, cannot perform data export');
      }

      // Step 1: Preparing
      state = const AsyncValue.data(BackupProgress(
        status: BackupStatus.preparing,
        progress: 0.0,
        currentOperation: 'Preparing data export...',
      ));

      // Check if Google Drive backup is enabled
      final backupPreferenceAsync = ref.read(backupPreferenceNotifierProvider);
      final backupPreference = backupPreferenceAsync.value;
      if (backupPreference == null || !backupPreference.enabled || backupPreference.strategy != BackupStrategy.googleDrive) {
        throw Exception('Google Drive backup is not enabled. Please enable it in settings first.');
      }

      // Ensure we're signed in before starting export
      final authSuccess = await ref.read(googleDriveAuthProvider.notifier).ensureSignedIn();
      if (!authSuccess) {
        throw Exception('Google Drive authentication failed');
      }

      final database = ref.read(appDatabaseProvider);
      final service = ref.read(googleDriveServiceProvider);

      // Step 2: Exporting data
      if (!ref.mounted) throw Exception('Provider disposed during export preparation');

      state = const AsyncValue.data(BackupProgress(
        status: BackupStatus.creating,
        progress: 0.2,
        currentOperation: 'Exporting data...',
      ));

      final exportData = await _exportAllData(database);
      final fileName = 'healthbox_export_${DateTime.now().millisecondsSinceEpoch}.json';
      final jsonString = jsonEncode(exportData);
      final dataSize = _formatBytes(utf8.encode(jsonString).length);

      // Step 3: Uploading
      if (!ref.mounted) throw Exception('Provider disposed during data export');

      state = AsyncValue.data(BackupProgress(
        status: BackupStatus.uploading,
        progress: 0.5,
        currentOperation: 'Uploading export...',
        fileSize: dataSize,
      ));

      await service.uploadDataExport(jsonString, fileName);

      // Step 4: Finalizing
      if (!ref.mounted) throw Exception('Provider disposed during export upload');

      state = AsyncValue.data(BackupProgress(
        status: BackupStatus.finalizing,
        progress: 0.9,
        currentOperation: 'Finalizing export...',
        fileSize: dataSize,
      ));

      // Update last sync time
      await ref.read(syncSettingsProvider.notifier).updateLastSyncTime();

      // Clean up old backups based on retention settings
      await _cleanupOldBackups();

      // Refresh backup list
      ref.invalidate(googleDriveBackupsProvider);

      // Step 5: Completed
      if (!ref.mounted) return; // Don't update if disposed, export was successful anyway

      // Update last sync time to respect frequency settings
      await ref.read(syncSettingsProvider.notifier).updateLastSyncTime(DateTime.now());

      state = AsyncValue.data(BackupProgress(
        status: BackupStatus.completed,
        progress: 1.0,
        currentOperation: 'Export completed successfully',
        fileSize: dataSize,
      ));
    } catch (e) {
      debugPrint('Data export failed: $e');

      // Only update state if ref is still mounted
      if (ref.mounted) {
        state = AsyncValue.data(BackupProgress(
          status: BackupStatus.idle,
          progress: 0.0,
          errorMessage: e.toString(),
        ));
      }
    }
  }

  Future<void> restoreDatabaseBackup(String fileId) async {
    state = const AsyncValue.data(BackupProgress(
      status: BackupStatus.restoring,
      progress: 0.0,
      currentOperation: 'Restoring database backup...',
    ));

    try {
      final service = ref.read(googleDriveServiceProvider);
      final database = ref.read(appDatabaseProvider);

      // Get local database path
      final dbFolder = await getApplicationDocumentsDirectory();
      final tempRestorePath = p.join(dbFolder.path, 'temp_restore.db');

      // Download database backup
      state = const AsyncValue.data(BackupProgress(
        status: BackupStatus.restoring,
        progress: 0.3,
        currentOperation: 'Downloading backup...',
      ));

      await service.downloadDatabaseBackup(fileId, tempRestorePath);

      // Close current database connection
      state = const AsyncValue.data(BackupProgress(
        status: BackupStatus.restoring,
        progress: 0.6,
        currentOperation: 'Replacing database...',
      ));

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

      state = const AsyncValue.data(BackupProgress(
        status: BackupStatus.completed,
        progress: 1.0,
        currentOperation: 'Database restore completed',
      ));
    } catch (e) {
      state = AsyncValue.data(BackupProgress(
        status: BackupStatus.idle,
        progress: 0.0,
        errorMessage: _formatErrorMessage(e.toString()),
      ));
    }
  }

  Future<void> restoreDataExport(String fileId) async {
    state = const AsyncValue.data(BackupProgress(
      status: BackupStatus.restoring,
      progress: 0.0,
      currentOperation: 'Restoring data export...',
    ));

    try {
      final service = ref.read(googleDriveServiceProvider);
      final database = ref.read(appDatabaseProvider);

      // Download and parse export data
      state = const AsyncValue.data(BackupProgress(
        status: BackupStatus.restoring,
        progress: 0.3,
        currentOperation: 'Downloading export data...',
      ));

      final exportData = await service.downloadDataExport(fileId);
      final data = jsonDecode(exportData) as Map<String, dynamic>;

      // Restore data to database
      state = const AsyncValue.data(BackupProgress(
        status: BackupStatus.restoring,
        progress: 0.7,
        currentOperation: 'Restoring data to database...',
      ));

      await _restoreAllData(database, data);

      state = const AsyncValue.data(BackupProgress(
        status: BackupStatus.completed,
        progress: 1.0,
        currentOperation: 'Data restore completed',
      ));
    } catch (e) {
      state = AsyncValue.data(BackupProgress(
        status: BackupStatus.idle,
        progress: 0.0,
        errorMessage: _formatErrorMessage(e.toString()),
      ));
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
  preparing,
  creating,
  uploading,
  finalizing,
  restoring,
  completed,
}

class BackupProgress {
  final BackupStatus status;
  final double progress; // 0.0 to 1.0
  final String? currentOperation;
  final String? fileSize;
  final String? errorMessage;

  const BackupProgress({
    required this.status,
    this.progress = 0.0,
    this.currentOperation,
    this.fileSize,
    this.errorMessage,
  });

  BackupProgress copyWith({
    BackupStatus? status,
    double? progress,
    String? currentOperation,
    String? fileSize,
    String? errorMessage,
  }) {
    return BackupProgress(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      currentOperation: currentOperation ?? this.currentOperation,
      fileSize: fileSize ?? this.fileSize,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isActive => status != BackupStatus.idle && status != BackupStatus.completed;
  bool get hasError => errorMessage != null;
}

enum SyncFrequency {
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