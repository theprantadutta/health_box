// Storage Service Contract - Encrypted database and file operations
// Corresponds to FR-002: System MUST store all medical data locally in an encrypted database
// Corresponds to FR-010: System MUST maintain full functionality without internet connectivity
// Corresponds to FR-011: System MUST encrypt all stored medical data
// Corresponds to FR-015: System MUST maintain data integrity and prevent corruption

import 'shared_models.dart';

abstract class StorageServiceContract {
  // Initialize encrypted database
  // Returns: true on successful initialization
  Future<bool> initializeDatabase({String? password});

  // Change database encryption password
  // Returns: true on successful password change
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  // Verify database integrity
  // Returns: IntegrityResult with validation details
  Future<IntegrityResult> verifyIntegrity();

  // Create database backup
  // Returns: backup file path on success
  Future<String?> createBackup({
    String? backupPath,
    String? password,
  });

  // Restore from backup
  // Returns: true on successful restore
  Future<bool> restoreFromBackup({
    required String backupPath,
    String? password,
  });

  // Compact/optimize database
  // Returns: space freed in bytes
  Future<int> compactDatabase();

  // Get database statistics
  Future<DatabaseStats> getDatabaseStats();

  // Check if database is encrypted
  Future<bool> isDatabaseEncrypted();

  // Migrate database to newer version
  Future<bool> migrateDatabase(int fromVersion, int toVersion);
}

// File storage operations for attachments
abstract class FileStorageServiceContract {
  // Store file attachment
  // Returns: stored file path on success
  Future<String?> storeFile({
    required String sourceFilePath,
    required String recordId,
    String? customFileName,
  });

  // Get stored file path
  // Returns: file path if exists, null if not found
  Future<String?> getFilePath({
    required String recordId,
    required String fileName,
  });

  // Delete stored file
  // Returns: true on successful deletion
  Future<bool> deleteFile({
    required String recordId,
    required String fileName,
  });

  // Get file info
  // Returns: FileInfo if exists, null if not found
  Future<FileInfo?> getFileInfo({
    required String recordId,
    required String fileName,
  });

  // List files for record
  Future<List<FileInfo>> getFilesForRecord(String recordId);

  // Copy file to external location (for sharing)
  // Returns: temporary file path for sharing
  Future<String?> copyFileForSharing({
    required String recordId,
    required String fileName,
  });

  // Get total storage usage
  Future<StorageUsage> getStorageUsage();

  // Clean up orphaned files
  Future<int> cleanupOrphanedFiles();

  // Verify file integrity
  Future<List<FileIntegrityIssue>> verifyFileIntegrity();
}

// Tag management operations
abstract class TagServiceContract {
  // Create new tag
  // Returns: tag ID on success
  Future<String> createTag({
    required String name,
    required String color,
    String? description,
  });

  // Update tag
  // Returns: true on success
  Future<bool> updateTag({
    required String tagId,
    String? name,
    String? color,
    String? description,
  });

  // Delete tag
  // Returns: true on success, removes tag from all records
  Future<bool> deleteTag(String tagId);

  // Get all tags
  Future<List<Tag>> getAllTags();

  // Get tags for record
  Future<List<Tag>> getTagsForRecord(String recordId);

  // Add tag to record
  Future<bool> addTagToRecord(String recordId, String tagId);

  // Remove tag from record
  Future<bool> removeTagFromRecord(String recordId, String tagId);

  // Get records with tag
  Future<List<String>> getRecordsWithTag(String tagId);

  // Update tag usage counts
  Future<void> updateTagUsageCounts();
}

class IntegrityResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final int corruptedRecords;
  final DateTime checkedAt;

  IntegrityResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
    required this.corruptedRecords,
    required this.checkedAt,
  });
}

class DatabaseStats {
  final int totalRecords;
  final int totalProfiles;
  final int totalAttachments;
  final int databaseSizeBytes;
  final int attachmentsSizeBytes;
  final DateTime lastBackup;
  final double fragmentationPercent;

  DatabaseStats({
    required this.totalRecords,
    required this.totalProfiles,
    required this.totalAttachments,
    required this.databaseSizeBytes,
    required this.attachmentsSizeBytes,
    required this.lastBackup,
    required this.fragmentationPercent,
  });
}

class FileInfo {
  final String fileName;
  final String filePath;
  final int sizeBytes;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final String mimeType;
  final bool exists;

  FileInfo({
    required this.fileName,
    required this.filePath,
    required this.sizeBytes,
    required this.createdAt,
    required this.modifiedAt,
    required this.mimeType,
    required this.exists,
  });
}

class StorageUsage {
  final int databaseSizeBytes;
  final int attachmentsSizeBytes;
  final int totalSizeBytes;
  final int availableSpaceBytes;
  final double usagePercentage;

  StorageUsage({
    required this.databaseSizeBytes,
    required this.attachmentsSizeBytes,
    required this.totalSizeBytes,
    required this.availableSpaceBytes,
    required this.usagePercentage,
  });
}

class FileIntegrityIssue {
  final String recordId;
  final String fileName;
  final String issueType; // missing, corrupted, size_mismatch
  final String description;

  FileIntegrityIssue({
    required this.recordId,
    required this.fileName,
    required this.issueType,
    required this.description,
  });
}