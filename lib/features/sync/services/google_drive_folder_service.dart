import 'package:googleapis/drive/v3.dart' as drive;
import 'package:logger/logger.dart';
import 'google_drive_service.dart';

/// Service for managing Google Drive folder structure for HealthBox attachments
class GoogleDriveFolderService {
  static const String _attachmentsFolderName = 'Attachments';

  // Subfolder structure for attachments
  static const Map<String, String> _recordTypeFolders = {
    'medication': 'Medications',
    'lab_report': 'Lab Reports',
    'vaccination': 'Vaccinations',
    'allergy': 'Allergies',
    'chronic_condition': 'Chronic Conditions',
    'surgical_procedure': 'Surgeries & Procedures',
    'radiology_imaging': 'Radiology & Imaging',
    'pathology': 'Pathology Reports',
    'discharge_summary': 'Discharge Summaries',
    'hospital_admission': 'Hospital Admissions',
    'dental_record': 'Dental Records',
    'mental_health': 'Mental Health',
    'general_record': 'General Records',
    'prescription': 'Prescriptions',
  };

  final GoogleDriveService _driveService;
  final Logger _logger = Logger();

  // Cache folder IDs to avoid repeated API calls
  final Map<String, String> _folderCache = {};

  GoogleDriveFolderService({GoogleDriveService? driveService})
      : _driveService = driveService ?? GoogleDriveService();

  /// Get or create the main attachments folder
  Future<String> getAttachmentsFolderId() async {
    if (_folderCache.containsKey(_attachmentsFolderName)) {
      return _folderCache[_attachmentsFolderName]!;
    }

    try {
      if (!_driveService.isSignedIn) {
        throw FolderServiceException('Not signed in to Google Drive');
      }

      final driveApi = _driveService.driveApi;
      if (driveApi == null) {
        throw FolderServiceException('Drive API not initialized');
      }

      // First get the main app folder
      final appFolderId = await _driveService.getAppFolderId();

      // Look for attachments folder within app folder
      final folderId = await _getOrCreateFolder(
        folderName: _attachmentsFolderName,
        parentFolderId: appFolderId,
        driveApi: driveApi,
      );

      _folderCache[_attachmentsFolderName] = folderId;
      _logger.d('Attachments folder ID: $folderId');
      return folderId;
    } catch (e) {
      _logger.e('Failed to get attachments folder: $e');
      throw FolderServiceException('Failed to get attachments folder: ${e.toString()}');
    }
  }

  /// Get or create folder for specific record type
  Future<String> getRecordTypeFolderId(String recordType) async {
    final cacheKey = 'record_$recordType';
    if (_folderCache.containsKey(cacheKey)) {
      return _folderCache[cacheKey]!;
    }

    try {
      final attachmentsFolderId = await getAttachmentsFolderId();
      final folderName = _recordTypeFolders[recordType] ?? 'Other';

      final driveApi = _driveService.driveApi;
      if (driveApi == null) {
        throw FolderServiceException('Drive API not initialized');
      }

      final folderId = await _getOrCreateFolder(
        folderName: folderName,
        parentFolderId: attachmentsFolderId,
        driveApi: driveApi,
      );

      _folderCache[cacheKey] = folderId;
      _logger.d('Record type folder [$recordType] ID: $folderId');
      return folderId;
    } catch (e) {
      _logger.e('Failed to get record type folder for $recordType: $e');
      throw FolderServiceException('Failed to get record type folder: ${e.toString()}');
    }
  }

  /// Get or create profile-specific folder within a record type folder
  Future<String> getProfileFolderId(String recordType, String profileName) async {
    final cacheKey = 'profile_${recordType}_${profileName}';
    if (_folderCache.containsKey(cacheKey)) {
      return _folderCache[cacheKey]!;
    }

    try {
      final recordTypeFolderId = await getRecordTypeFolderId(recordType);
      final sanitizedProfileName = _sanitizeFolderName(profileName);

      final driveApi = _driveService.driveApi;
      if (driveApi == null) {
        throw FolderServiceException('Drive API not initialized');
      }

      final folderId = await _getOrCreateFolder(
        folderName: sanitizedProfileName,
        parentFolderId: recordTypeFolderId,
        driveApi: driveApi,
      );

      _folderCache[cacheKey] = folderId;
      _logger.d('Profile folder [$profileName] in [$recordType] ID: $folderId');
      return folderId;
    } catch (e) {
      _logger.e('Failed to get profile folder for $profileName in $recordType: $e');
      throw FolderServiceException('Failed to get profile folder: ${e.toString()}');
    }
  }

  /// Upload file to appropriate folder based on record type and profile
  Future<String> uploadFileToOrganizedFolder({
    required List<int> fileBytes,
    required String fileName,
    required String mimeType,
    required String recordType,
    String? profileName,
    Map<String, String>? metadata,
  }) async {
    try {
      String folderId;

      if (profileName != null && profileName.isNotEmpty) {
        // Upload to profile-specific folder
        folderId = await getProfileFolderId(recordType, profileName);
      } else {
        // Upload to record type folder
        folderId = await getRecordTypeFolderId(recordType);
      }

      return await _uploadFile(
        fileBytes: fileBytes,
        fileName: fileName,
        mimeType: mimeType,
        folderId: folderId,
        metadata: metadata,
      );
    } catch (e) {
      _logger.e('Failed to upload file to organized folder: $e');
      throw FolderServiceException('Failed to upload file: ${e.toString()}');
    }
  }

  /// Get the full folder path for a record type and profile
  String getFolderPath(String recordType, {String? profileName}) {
    final recordTypeName = _recordTypeFolders[recordType] ?? 'Other';

    if (profileName != null && profileName.isNotEmpty) {
      return 'HealthBox/Attachments/$recordTypeName/${_sanitizeFolderName(profileName)}';
    } else {
      return 'HealthBox/Attachments/$recordTypeName';
    }
  }

  /// Get all available record type folders
  List<String> getAvailableRecordTypes() {
    return _recordTypeFolders.keys.toList();
  }

  /// Get display name for record type
  String getRecordTypeDisplayName(String recordType) {
    return _recordTypeFolders[recordType] ?? recordType;
  }

  /// Clear folder cache (useful when folder structure changes)
  void clearCache() {
    _folderCache.clear();
    _logger.d('Folder cache cleared');
  }

  /// Get folder statistics
  Future<FolderStatistics> getFolderStatistics() async {
    try {
      final driveApi = _driveService.driveApi;
      if (driveApi == null) {
        throw FolderServiceException('Drive API not initialized');
      }

      await getAttachmentsFolderId();
      final stats = <String, int>{};

      // Count files in each record type folder
      for (final recordType in _recordTypeFolders.keys) {
        try {
          final folderId = await getRecordTypeFolderId(recordType);
          final fileCount = await _countFilesInFolder(folderId, driveApi);
          stats[recordType] = fileCount;
        } catch (e) {
          _logger.w('Failed to count files for $recordType: $e');
          stats[recordType] = 0;
        }
      }

      final totalFiles = stats.values.fold(0, (sum, count) => sum + count);

      return FolderStatistics(
        totalFiles: totalFiles,
        filesByRecordType: stats,
        folderStructureCreated: _folderCache.isNotEmpty,
      );
    } catch (e) {
      _logger.e('Failed to get folder statistics: $e');
      return FolderStatistics(
        totalFiles: 0,
        filesByRecordType: {},
        folderStructureCreated: false,
      );
    }
  }

  /// Initialize folder structure (creates all record type folders)
  Future<void> initializeFolderStructure() async {
    try {
      _logger.d('Initializing Google Drive folder structure...');

      // Create attachments folder
      await getAttachmentsFolderId();

      // Create all record type folders
      final futures = _recordTypeFolders.keys.map((recordType) async {
        try {
          await getRecordTypeFolderId(recordType);
        } catch (e) {
          _logger.w('Failed to create folder for $recordType: $e');
        }
      });

      await Future.wait(futures);
      _logger.i('Folder structure initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize folder structure: $e');
      throw FolderServiceException('Failed to initialize folder structure: ${e.toString()}');
    }
  }

  // Private helper methods

  Future<String> _getOrCreateFolder({
    required String folderName,
    required String parentFolderId,
    required drive.DriveApi driveApi,
  }) async {
    try {
      // Search for existing folder
      final query = "name='$folderName' and '$parentFolderId' in parents and mimeType='application/vnd.google-apps.folder' and trashed=false";
      final fileList = await driveApi.files.list(q: query);

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        return fileList.files!.first.id!;
      }

      // Create new folder
      final folder = drive.File()
        ..name = folderName
        ..parents = [parentFolderId]
        ..mimeType = 'application/vnd.google-apps.folder';

      final createdFolder = await driveApi.files.create(folder);
      return createdFolder.id!;
    } catch (e) {
      throw FolderServiceException('Failed to get or create folder $folderName: ${e.toString()}');
    }
  }

  Future<String> _uploadFile({
    required List<int> fileBytes,
    required String fileName,
    required String mimeType,
    required String folderId,
    Map<String, String>? metadata,
  }) async {
    try {
      final driveApi = _driveService.driveApi;
      if (driveApi == null) {
        throw FolderServiceException('Drive API not initialized');
      }

      final driveFile = drive.File()
        ..name = fileName
        ..parents = [folderId];

      // Add metadata if provided
      if (metadata != null) {
        driveFile.properties = metadata;
      }

      final media = drive.Media(
        Stream.fromIterable([fileBytes]),
        fileBytes.length,
        contentType: mimeType,
      );

      final uploadedFile = await driveApi.files.create(
        driveFile,
        uploadMedia: media,
      );

      return uploadedFile.id!;
    } catch (e) {
      throw FolderServiceException('Failed to upload file: ${e.toString()}');
    }
  }

  Future<int> _countFilesInFolder(String folderId, drive.DriveApi driveApi) async {
    try {
      final query = "'$folderId' in parents and trashed=false";
      final fileList = await driveApi.files.list(
        q: query,
        pageSize: 1000, // Get up to 1000 files to count
      );

      return fileList.files?.length ?? 0;
    } catch (e) {
      _logger.w('Failed to count files in folder $folderId: $e');
      return 0;
    }
  }

  String _sanitizeFolderName(String name) {
    // Remove or replace characters that are not allowed in folder names
    return name
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

/// Statistics about the folder structure
class FolderStatistics {
  final int totalFiles;
  final Map<String, int> filesByRecordType;
  final bool folderStructureCreated;

  const FolderStatistics({
    required this.totalFiles,
    required this.filesByRecordType,
    required this.folderStructureCreated,
  });

  /// Get the record type with the most files
  String? getMostPopulatedRecordType() {
    if (filesByRecordType.isEmpty) return null;

    return filesByRecordType.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Get record types with no files
  List<String> getEmptyRecordTypes() {
    return filesByRecordType.entries
        .where((entry) => entry.value == 0)
        .map((entry) => entry.key)
        .toList();
  }

  /// Get formatted summary
  String getFormattedSummary() {
    if (totalFiles == 0) return 'No files uploaded';

    final populated = filesByRecordType.values.where((count) => count > 0).length;
    return '$totalFiles files across $populated record types';
  }
}

/// Exception for folder service operations
class FolderServiceException implements Exception {
  final String message;

  const FolderServiceException(this.message);

  @override
  String toString() => 'FolderServiceException: $message';
}