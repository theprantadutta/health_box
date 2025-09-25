import 'package:drift/drift.dart';
import '../../../data/database/app_database.dart';
import '../../../data/models/sync_preferences.dart';

class FileSyncPreferencesService {
  final AppDatabase _database;

  FileSyncPreferencesService({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  static const String _defaultPreferencesId = 'default_sync_prefs';

  /// Get current sync preferences, creating default if none exist
  Future<SyncPreferencesData> getPreferences() async {
    try {
      final prefs = await (_database.select(_database.syncPreferences)
            ..where((p) => p.id.equals(_defaultPreferencesId)))
          .getSingleOrNull();

      if (prefs != null) {
        return _mapToData(prefs);
      }

      // Create default preferences
      return await _createDefaultPreferences();
    } catch (e) {
      throw FileSyncPreferencesException(
          'Failed to get sync preferences: ${e.toString()}');
    }
  }

  /// Update sync preferences
  Future<SyncPreferencesData> updatePreferences({
    bool? fileUploadEnabled,
    bool? syncImages,
    bool? syncPdfs,
    bool? syncDocuments,
    int? maxFileSizeMb,
    bool? wifiOnlyUpload,
    bool? autoUpload,
    int? maxUploadRetries,
  }) async {
    try {

      final companion = SyncPreferencesCompanion(
        id: const Value(_defaultPreferencesId),
        fileUploadEnabled: fileUploadEnabled != null
            ? Value(fileUploadEnabled)
            : const Value.absent(),
        syncImages:
            syncImages != null ? Value(syncImages) : const Value.absent(),
        syncPdfs: syncPdfs != null ? Value(syncPdfs) : const Value.absent(),
        syncDocuments: syncDocuments != null
            ? Value(syncDocuments)
            : const Value.absent(),
        maxFileSizeMb: maxFileSizeMb != null
            ? Value(maxFileSizeMb)
            : const Value.absent(),
        wifiOnlyUpload: wifiOnlyUpload != null
            ? Value(wifiOnlyUpload)
            : const Value.absent(),
        autoUpload:
            autoUpload != null ? Value(autoUpload) : const Value.absent(),
        maxUploadRetries: maxUploadRetries != null
            ? Value(maxUploadRetries)
            : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      );

      await _database.update(_database.syncPreferences).replace(companion);

      return await getPreferences();
    } catch (e) {
      throw FileSyncPreferencesException(
          'Failed to update sync preferences: ${e.toString()}');
    }
  }

  /// Check if file upload is enabled
  Future<bool> isFileUploadEnabled() async {
    try {
      final prefs = await getPreferences();
      return prefs.fileUploadEnabled;
    } catch (e) {
      return true; // Default to enabled
    }
  }

  /// Check if a specific file type should be synced
  Future<bool> shouldSyncFileType(String fileExtension) async {
    try {
      final prefs = await getPreferences();
      return prefs.shouldSyncFileType(fileExtension);
    } catch (e) {
      return false; // Default to not syncing on error
    }
  }

  /// Check if file size is within upload limits
  Future<bool> isFileSizeAllowed(int fileSizeBytes) async {
    try {
      final prefs = await getPreferences();
      final maxSizeBytes = prefs.maxFileSizeMb * 1024 * 1024;
      return fileSizeBytes <= maxSizeBytes;
    } catch (e) {
      return false; // Default to not allowing on error
    }
  }

  /// Get maximum allowed file size in bytes
  Future<int> getMaxFileSizeBytes() async {
    try {
      final prefs = await getPreferences();
      return prefs.maxFileSizeMb * 1024 * 1024;
    } catch (e) {
      return 50 * 1024 * 1024; // Default 50MB
    }
  }

  /// Check if uploads should only happen on WiFi
  Future<bool> shouldUploadOnWiFiOnly() async {
    try {
      final prefs = await getPreferences();
      return prefs.wifiOnlyUpload;
    } catch (e) {
      return true; // Default to WiFi only
    }
  }

  /// Check if auto upload is enabled
  Future<bool> isAutoUploadEnabled() async {
    try {
      final prefs = await getPreferences();
      return prefs.autoUpload;
    } catch (e) {
      return true; // Default to enabled
    }
  }

  /// Get maximum retry count for failed uploads
  Future<int> getMaxRetryCount() async {
    try {
      final prefs = await getPreferences();
      return prefs.maxUploadRetries;
    } catch (e) {
      return 3; // Default to 3 retries
    }
  }

  /// Reset preferences to default values
  Future<SyncPreferencesData> resetToDefaults() async {
    try {
      // Delete existing preferences
      await (_database.delete(_database.syncPreferences)
            ..where((p) => p.id.equals(_defaultPreferencesId)))
          .go();

      // Create new default preferences
      return await _createDefaultPreferences();
    } catch (e) {
      throw FileSyncPreferencesException(
          'Failed to reset sync preferences: ${e.toString()}');
    }
  }

  /// Get file type filter settings as a map
  Future<Map<FileTypeFilter, bool>> getFileTypeFilters() async {
    try {
      final prefs = await getPreferences();
      return {
        FileTypeFilter.images: prefs.syncImages,
        FileTypeFilter.pdfs: prefs.syncPdfs,
        FileTypeFilter.documents: prefs.syncDocuments,
      };
    } catch (e) {
      return {
        FileTypeFilter.images: true,
        FileTypeFilter.pdfs: true,
        FileTypeFilter.documents: true,
      };
    }
  }

  /// Update file type filter settings
  Future<void> updateFileTypeFilters(Map<FileTypeFilter, bool> filters) async {
    await updatePreferences(
      syncImages: filters[FileTypeFilter.images],
      syncPdfs: filters[FileTypeFilter.pdfs],
      syncDocuments: filters[FileTypeFilter.documents],
    );
  }

  /// Get sync statistics summary
  Future<SyncStatsSummary> getSyncStats() async {
    try {
      // Count total attachments
      final totalAttachments = await (_database.selectOnly(
        _database.attachments,
        distinct: false,
      )..addColumns([_database.attachments.id.count()]))
          .map((row) => row.read(_database.attachments.id.count()) ?? 0)
          .getSingle();

      // Count synced attachments
      final syncedAttachments = await (_database.selectOnly(
        _database.attachments,
        distinct: false,
      )
            ..addColumns([_database.attachments.id.count()])
            ..where(_database.attachments.isSynced.equals(true)))
          .map((row) => row.read(_database.attachments.id.count()) ?? 0)
          .getSingle();

      // Count pending uploads
      final pendingUploads = await (_database.selectOnly(
        _database.uploadQueue,
        distinct: false,
      )
            ..addColumns([_database.uploadQueue.id.count()])
            ..where(_database.uploadQueue.status
                .equals(FileSyncStatus.pending.value)))
          .map((row) => row.read(_database.uploadQueue.id.count()) ?? 0)
          .getSingle();

      return SyncStatsSummary(
        totalAttachments: totalAttachments,
        syncedAttachments: syncedAttachments,
        pendingUploads: pendingUploads,
        syncPercentage: totalAttachments > 0
            ? (syncedAttachments / totalAttachments * 100).round()
            : 100,
      );
    } catch (e) {
      throw FileSyncPreferencesException(
          'Failed to get sync stats: ${e.toString()}');
    }
  }

  /// Create default sync preferences
  Future<SyncPreferencesData> _createDefaultPreferences() async {
    final companion = SyncPreferencesCompanion.insert(
      id: _defaultPreferencesId,
      fileUploadEnabled: const Value(true),
      syncImages: const Value(true),
      syncPdfs: const Value(true),
      syncDocuments: const Value(true),
      maxFileSizeMb: const Value(50),
      wifiOnlyUpload: const Value(true),
      autoUpload: const Value(true),
      maxUploadRetries: const Value(3),
    );

    await _database.into(_database.syncPreferences).insert(companion);
    return await getPreferences();
  }

  /// Map database row to data model
  SyncPreferencesData _mapToData(SyncPreference prefs) {
    return SyncPreferencesData(
      id: prefs.id,
      fileUploadEnabled: prefs.fileUploadEnabled,
      syncImages: prefs.syncImages,
      syncPdfs: prefs.syncPdfs,
      syncDocuments: prefs.syncDocuments,
      maxFileSizeMb: prefs.maxFileSizeMb,
      wifiOnlyUpload: prefs.wifiOnlyUpload,
      autoUpload: prefs.autoUpload,
      maxUploadRetries: prefs.maxUploadRetries,
      createdAt: prefs.createdAt,
      updatedAt: prefs.updatedAt,
    );
  }

  /// Watch preferences changes
  Stream<SyncPreferencesData> watchPreferences() {
    return (_database.select(_database.syncPreferences)
          ..where((p) => p.id.equals(_defaultPreferencesId)))
        .watchSingleOrNull()
        .asyncMap((prefs) async {
      if (prefs != null) {
        return _mapToData(prefs);
      }
      return await _createDefaultPreferences();
    });
  }
}

/// Sync statistics summary
class SyncStatsSummary {
  final int totalAttachments;
  final int syncedAttachments;
  final int pendingUploads;
  final int syncPercentage;

  const SyncStatsSummary({
    required this.totalAttachments,
    required this.syncedAttachments,
    required this.pendingUploads,
    required this.syncPercentage,
  });

  int get unsyncedAttachments => totalAttachments - syncedAttachments;
  bool get allSynced => totalAttachments > 0 && syncedAttachments == totalAttachments;
  bool get hasPendingUploads => pendingUploads > 0;
}

/// Exception for file sync preferences operations
class FileSyncPreferencesException implements Exception {
  final String message;

  const FileSyncPreferencesException(this.message);

  @override
  String toString() => 'FileSyncPreferencesException: $message';
}