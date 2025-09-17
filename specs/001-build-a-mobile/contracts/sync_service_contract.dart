// Sync Service Contract - Google Drive synchronization
// Corresponds to FR-009: System MUST provide optional Google Drive synchronization
// Corresponds to FR-012: System MUST allow users to control what data is synchronized

abstract class SyncServiceContract {
  // Check if user has configured Google Drive sync
  Future<bool> isSyncEnabled();

  // Authenticate with Google Drive
  // Returns: true on successful authentication, false on failure/cancellation
  Future<bool> authenticateGoogleDrive();

  // Disconnect Google Drive sync
  // Returns: true on successful disconnection
  Future<bool> disconnectGoogleDrive();

  // Get current sync status
  // Returns: SyncStatus with current state
  Future<SyncStatus> getSyncStatus();

  // Start manual sync
  // Returns: SyncResult with operation details
  Future<SyncResult> startSync({
    String? profileId, // null = all profiles
    List<String>? recordTypes, // null = all types
    bool uploadOnly = false,
    bool downloadOnly = false,
  });

  // Configure sync settings
  // Returns: true on successful configuration update
  Future<bool> updateSyncSettings({
    bool? autoSync,
    int? syncIntervalMinutes,
    bool? syncOnWiFiOnly,
    List<String>? excludedRecordTypes,
    List<String>? excludedProfiles,
  });

  // Get sync settings
  Future<SyncSettings> getSyncSettings();

  // Force upload specific record
  // Returns: true on successful upload, false on failure
  Future<bool> uploadRecord(String recordId);

  // Force download from Google Drive
  // Returns: number of records downloaded
  Future<int> downloadFromDrive();

  // Get sync history/log
  Future<List<SyncLogEntry>> getSyncHistory({int limit = 50});

  // Resolve sync conflicts
  // Returns: true on successful resolution
  Future<bool> resolveSyncConflict({
    required String recordId,
    required ConflictResolution resolution,
  });

  // Check for conflicts
  Future<List<SyncConflict>> getSyncConflicts();

  // Cancel ongoing sync
  Future<void> cancelSync();
}

// File sync contract for attachments
abstract class FileSyncServiceContract {
  // Upload file to Google Drive
  // Returns: Google Drive file ID on success
  Future<String?> uploadFile({
    required String localFilePath,
    required String fileName,
    String? folderId,
  });

  // Download file from Google Drive
  // Returns: local file path on success
  Future<String?> downloadFile({
    required String driveFileId,
    required String fileName,
  });

  // Delete file from Google Drive
  // Returns: true on successful deletion
  Future<bool> deleteFileFromDrive(String driveFileId);

  // Sync all attachments for a record
  Future<SyncResult> syncRecordAttachments(String recordId);
}

enum SyncState {
  idle,
  authenticating,
  syncing,
  uploading,
  downloading,
  error,
  conflicted,
}

class SyncStatus {
  final SyncState state;
  final DateTime? lastSyncTime;
  final String? errorMessage;
  final int pendingUploads;
  final int pendingDownloads;
  final bool hasConflicts;

  SyncStatus({
    required this.state,
    this.lastSyncTime,
    this.errorMessage,
    required this.pendingUploads,
    required this.pendingDownloads,
    required this.hasConflicts,
  });
}

class SyncResult {
  final bool success;
  final int recordsUploaded;
  final int recordsDownloaded;
  final int filesUploaded;
  final int filesDownloaded;
  final List<String> errors;
  final Duration duration;

  SyncResult({
    required this.success,
    required this.recordsUploaded,
    required this.recordsDownloaded,
    required this.filesUploaded,
    required this.filesDownloaded,
    required this.errors,
    required this.duration,
  });
}

class SyncSettings {
  final bool autoSync;
  final int syncIntervalMinutes;
  final bool syncOnWiFiOnly;
  final List<String> excludedRecordTypes;
  final List<String> excludedProfiles;

  SyncSettings({
    required this.autoSync,
    required this.syncIntervalMinutes,
    required this.syncOnWiFiOnly,
    required this.excludedRecordTypes,
    required this.excludedProfiles,
  });
}

class SyncLogEntry {
  final String id;
  final DateTime timestamp;
  final String operation; // upload, download, sync
  final String status; // success, error, partial
  final String? details;
  final int recordCount;

  SyncLogEntry({
    required this.id,
    required this.timestamp,
    required this.operation,
    required this.status,
    this.details,
    required this.recordCount,
  });
}

class SyncConflict {
  final String recordId;
  final DateTime localModified;
  final DateTime remoteModified;
  final String recordType;
  final String conflictType; // modified, deleted, created

  SyncConflict({
    required this.recordId,
    required this.localModified,
    required this.remoteModified,
    required this.recordType,
    required this.conflictType,
  });
}

enum ConflictResolution { useLocal, useRemote, merge, createDuplicate }
