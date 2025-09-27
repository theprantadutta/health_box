import 'dart:convert';
import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class GoogleDriveService {
  static const String _backupFolderName = 'HealthBox';
  static const String _databaseFolderName = 'Database Backups';
  static const String _exportFolderName = 'Data Exports';
  static const String _appDataScope =
      'https://www.googleapis.com/auth/drive.appdata';
  static const String _driveFileScope =
      'https://www.googleapis.com/auth/drive.file';

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  final Logger _logger = Logger();

  GoogleSignInAccount? _currentUser;
  drive.DriveApi? _driveApi;
  String? _backupFolderId;
  String? _databaseFolderId;
  String? _exportFolderId;

  GoogleDriveService._();

  static final GoogleDriveService _instance = GoogleDriveService._();
  factory GoogleDriveService() => _instance;

  GoogleSignInAccount? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser != null;

  Future<bool> signIn() async {
    try {
      _logger.i('Starting Google Sign-In...');

      // Initialize Google Sign In first
      await _googleSignIn.initialize();

      // Use authenticate() method directly for interactive sign-in
      final account = await _googleSignIn.authenticate();

      // if (account == null) {
      //   _logger.w('Authentication failed or cancelled');
      //   return false;
      // }

      _currentUser = account;

      // Initialize Drive API with proper authorization
      await _initializeDriveApi();
      await _ensureFolderStructure();

      _logger.i('Successfully signed into Google Drive');
      return true;
    } catch (e) {
      _logger.e('Error during Google Sign-In: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _currentUser = null;
      _driveApi = null;
      _backupFolderId = null;
      _databaseFolderId = null;
      _exportFolderId = null;
      _logger.i('Successfully signed out of Google Drive');
    } catch (e) {
      _logger.e('Error during sign-out: $e');
    }
  }

  Future<bool> signInSilently() async {
    try {
      // Initialize Google Sign In
      await _googleSignIn.initialize();

      // Try lightweight authentication first
      final account = await _googleSignIn.attemptLightweightAuthentication();
      if (account != null) {
        _currentUser = account;
        try {
          await _initializeDriveApi();
          await _ensureFolderStructure();
          _logger.i('Silent sign-in successful');
          return true;
        } catch (e) {
          _logger.w(
            'Silent sign-in succeeded but Drive API initialization failed: $e',
          );
          // Clear the account if Drive API fails
          _currentUser = null;
          return false;
        }
      }
      _logger.i('No cached authentication found');
      return false;
    } catch (e) {
      _logger.e('Error during silent sign-in: $e');
      return false;
    }
  }

  Future<void> _initializeDriveApi() async {
    if (_currentUser == null) throw Exception('User not signed in');

    try {
      // Get authorization for Google Drive scopes
      final authorization = await _currentUser!.authorizationClient
          .authorizeScopes([_appDataScope, _driveFileScope]);

      // if (authorization.accessToken == null) {
      //   throw Exception('Failed to get access token');
      // }

      final headers = <String, String>{
        'Authorization': 'Bearer ${authorization.accessToken}',
      };
      final authenticateClient = GoogleAuthClient(headers);
      _driveApi = drive.DriveApi(authenticateClient);

      _logger.i('Drive API initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize Drive API: $e');
      throw Exception('Failed to initialize Google Drive API: $e');
    }
  }

  Future<void> _ensureFolderStructure() async {
    if (_driveApi == null) throw Exception('Drive API not initialized');

    try {
      // Create main HealthBox folder
      _backupFolderId = await _createOrFindFolder(_backupFolderName, null);
      _logger.i('Main HealthBox folder: $_backupFolderId');

      // Create Database Backups subfolder
      _databaseFolderId = await _createOrFindFolder(
        _databaseFolderName,
        _backupFolderId,
      );
      _logger.i('Database Backups folder: $_databaseFolderId');

      // Create Data Exports subfolder
      _exportFolderId = await _createOrFindFolder(
        _exportFolderName,
        _backupFolderId,
      );
      _logger.i('Data Exports folder: $_exportFolderId');
    } catch (e) {
      _logger.e('Error ensuring folder structure: $e');
      throw Exception('Failed to create/find folder structure: $e');
    }
  }

  Future<String> _createOrFindFolder(
    String folderName,
    String? parentId,
  ) async {
    // Search for existing folder
    String query =
        "name='$folderName' and mimeType='application/vnd.google-apps.folder' and trashed=false";
    if (parentId != null) {
      query += " and '$parentId' in parents";
    }

    final folderList = await _driveApi!.files.list(q: query);

    if (folderList.files?.isNotEmpty == true) {
      return folderList.files!.first.id!;
    } else {
      // Create new folder
      final folder = drive.File()
        ..name = folderName
        ..mimeType = 'application/vnd.google-apps.folder';

      if (parentId != null) {
        folder.parents = [parentId];
      }

      final createdFolder = await _driveApi!.files.create(folder);
      return createdFolder.id!;
    }
  }

  Future<String> uploadDatabaseBackup(
    String databasePath,
    String fileName, {
    Function(double)? onProgress,
  }) async {
    if (_driveApi == null || _databaseFolderId == null) {
      throw Exception('Drive API not initialized or database folder not found');
    }

    try {
      final databaseFile = File(databasePath);
      if (!await databaseFile.exists()) {
        throw Exception('Database file not found at: $databasePath');
      }

      // Get file size for progress tracking
      final fileSize = await databaseFile.length();
      _logger.i(
        'Uploading database backup: $fileName (${_formatBytes(fileSize)})',
      );

      onProgress?.call(0.1); // Starting upload

      final databaseBytes = await databaseFile.readAsBytes();

      onProgress?.call(0.3); // File read complete

      // Create file metadata
      final fileMetadata = drive.File()
        ..name = fileName
        ..parents = [_databaseFolderId!]
        ..description =
            'HealthBox SQLite database backup created on ${DateTime.now().toIso8601String()}';

      onProgress?.call(0.4); // Metadata prepared

      // Create progress-tracking media stream
      final media = drive.Media(
        _createProgressStream(databaseBytes, onProgress),
        databaseBytes.length,
        contentType: 'application/x-sqlite3',
      );

      onProgress?.call(0.5); // Starting upload

      final uploadedFile = await _driveApi!.files.create(
        fileMetadata,
        uploadMedia: media,
      );

      onProgress?.call(1.0); // Upload complete

      _logger.i(
        'Successfully uploaded database backup: ${uploadedFile.id} (${_formatBytes(fileSize)})',
      );
      return uploadedFile.id!;
    } catch (e) {
      _logger.e('Error uploading database backup: $e');
      throw Exception('Failed to upload database backup: $e');
    }
  }

  Stream<List<int>> _createProgressStream(
    List<int> data,
    Function(double)? onProgress,
  ) async* {
    const chunkSize = 1024 * 1024; // 1MB chunks
    int bytesUploaded = 0;
    final totalBytes = data.length;

    for (int i = 0; i < totalBytes; i += chunkSize) {
      final end = (i + chunkSize < totalBytes) ? i + chunkSize : totalBytes;
      final chunk = data.sublist(i, end);

      bytesUploaded += chunk.length;
      final progress =
          0.5 + (bytesUploaded / totalBytes) * 0.5; // 50-100% for upload
      onProgress?.call(progress);

      yield chunk;
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  Future<String> uploadDataExport(String exportData, String fileName) async {
    if (_driveApi == null || _exportFolderId == null) {
      throw Exception('Drive API not initialized or export folder not found');
    }

    try {
      final exportBytes = utf8.encode(exportData);

      // Create file metadata
      final fileMetadata = drive.File()
        ..name = fileName
        ..parents = [_exportFolderId!]
        ..description =
            'HealthBox data export created on ${DateTime.now().toIso8601String()}';

      // Determine content type based on file extension
      String contentType = 'text/plain';
      if (fileName.endsWith('.json')) {
        contentType = 'application/json';
      } else if (fileName.endsWith('.csv')) {
        contentType = 'text/csv';
      }

      // Upload file
      final media = drive.Media(
        Stream.fromIterable([exportBytes]),
        exportBytes.length,
        contentType: contentType,
      );

      final uploadedFile = await _driveApi!.files.create(
        fileMetadata,
        uploadMedia: media,
      );

      _logger.i('Successfully uploaded data export: ${uploadedFile.id}');
      return uploadedFile.id!;
    } catch (e) {
      _logger.e('Error uploading data export: $e');
      throw Exception('Failed to upload data export: $e');
    }
  }

  Future<String> downloadDatabaseBackup(String fileId, String localPath) async {
    if (_driveApi == null) {
      throw Exception('Drive API not initialized');
    }

    try {
      final media =
          await _driveApi!.files.get(
                fileId,
                downloadOptions: drive.DownloadOptions.fullMedia,
              )
              as drive.Media;

      final databaseData = <int>[];
      await for (final chunk in media.stream) {
        databaseData.addAll(chunk);
      }

      // Write to local file
      final file = File(localPath);
      await file.writeAsBytes(databaseData);

      _logger.i(
        'Successfully downloaded database backup: $fileId to $localPath',
      );
      return localPath;
    } catch (e) {
      _logger.e('Error downloading database backup: $e');
      throw Exception('Failed to download database backup: $e');
    }
  }

  Future<String> downloadDataExport(String fileId) async {
    if (_driveApi == null) {
      throw Exception('Drive API not initialized');
    }

    try {
      final media =
          await _driveApi!.files.get(
                fileId,
                downloadOptions: drive.DownloadOptions.fullMedia,
              )
              as drive.Media;

      final exportData = <int>[];
      await for (final chunk in media.stream) {
        exportData.addAll(chunk);
      }

      final exportString = utf8.decode(exportData);
      _logger.i('Successfully downloaded data export: $fileId');
      return exportString;
    } catch (e) {
      _logger.e('Error downloading data export: $e');
      throw Exception('Failed to download data export: $e');
    }
  }

  Future<List<BackupFile>> listDatabaseBackups() async {
    if (_driveApi == null || _databaseFolderId == null) {
      throw Exception('Drive API not initialized or database folder not found');
    }

    try {
      final query = "'$_databaseFolderId' in parents and trashed=false";
      final fileList = await _driveApi!.files.list(
        q: query,
        orderBy: 'createdTime desc',
        spaces: 'drive',
      );

      final backups = <BackupFile>[];
      for (final file in fileList.files ?? []) {
        if (file.id != null && file.name != null) {
          int size = 0;
          if (file.size != null) {
            size = int.tryParse(file.size!) ?? 0;
          }

          backups.add(
            BackupFile(
              id: file.id!,
              name: file.name!,
              createdTime: file.createdTime ?? DateTime.now(),
              size: size,
              description: file.description,
              type: BackupType.database,
            ),
          );
        }
      }

      _logger.i('Found ${backups.length} database backups');
      return backups;
    } catch (e) {
      _logger.e('Error listing database backups: $e');
      throw Exception('Failed to list database backups: $e');
    }
  }

  Future<List<BackupFile>> listDataExports() async {
    if (_driveApi == null || _exportFolderId == null) {
      throw Exception('Drive API not initialized or export folder not found');
    }

    try {
      final query = "'$_exportFolderId' in parents and trashed=false";
      final fileList = await _driveApi!.files.list(
        q: query,
        orderBy: 'createdTime desc',
        spaces: 'drive',
      );

      final exports = <BackupFile>[];
      for (final file in fileList.files ?? []) {
        if (file.id != null && file.name != null) {
          int size = 0;
          if (file.size != null) {
            size = int.tryParse(file.size!) ?? 0;
          }

          exports.add(
            BackupFile(
              id: file.id!,
              name: file.name!,
              createdTime: file.createdTime ?? DateTime.now(),
              size: size,
              description: file.description,
              type: BackupType.export,
            ),
          );
        }
      }

      _logger.i('Found ${exports.length} data exports');
      return exports;
    } catch (e) {
      _logger.e('Error listing data exports: $e');
      throw Exception('Failed to list data exports: $e');
    }
  }

  Future<List<BackupFile>> listAllBackups() async {
    final databaseBackups = await listDatabaseBackups();
    final dataExports = await listDataExports();

    final allBackups = [...databaseBackups, ...dataExports];
    allBackups.sort((a, b) => b.createdTime.compareTo(a.createdTime));

    return allBackups;
  }

  Future<void> deleteBackup(String fileId) async {
    if (_driveApi == null) {
      throw Exception('Drive API not initialized');
    }

    try {
      await _driveApi!.files.delete(fileId);
      _logger.i('Successfully deleted backup: $fileId');
    } catch (e) {
      _logger.e('Error deleting backup: $e');
      throw Exception('Failed to delete backup: $e');
    }
  }

  Future<String> getStorageInfo() async {
    if (_driveApi == null) {
      throw Exception('Drive API not initialized');
    }

    try {
      final about = await _driveApi!.about.get($fields: 'storageQuota');
      final quota = about.storageQuota;

      if (quota != null) {
        final used = int.tryParse(quota.usage ?? '0') ?? 0;
        final limit = int.tryParse(quota.limit ?? '0') ?? 0;

        final usedMB = (used / (1024 * 1024)).toStringAsFixed(2);
        final limitGB = (limit / (1024 * 1024 * 1024)).toStringAsFixed(2);

        return 'Used: ${usedMB}MB / ${limitGB}GB';
      }

      return 'Storage info unavailable';
    } catch (e) {
      _logger.e('Error getting storage info: $e');
      return 'Storage info unavailable';
    }
  }

  Future<bool> checkConnection() async {
    if (!isSignedIn) return false;

    try {
      await _driveApi!.about.get($fields: 'user');
      return true;
    } catch (e) {
      _logger.e('Connection check failed: $e');
      return false;
    }
  }

  // Attachment upload functionality
  String? _attachmentsFolderId;

  Future<String> uploadAttachment({
    required String filePath,
    required String fileName,
    required String mimeType,
    required String recordType,
    Function(double)? onProgress,
  }) async {
    if (_driveApi == null) {
      throw Exception('Drive API not initialized');
    }

    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Attachment file not found at: $filePath');
      }

      // Get file size for progress tracking
      final fileSize = await file.length();
      _logger.i('Uploading attachment: $fileName (${_formatBytes(fileSize)})');

      onProgress?.call(0.1); // Starting upload

      final fileBytes = await file.readAsBytes();
      onProgress?.call(0.3); // File read complete

      // Ensure attachments folder structure exists
      final recordFolderId = await _ensureAttachmentFolderStructure(recordType);
      onProgress?.call(0.4); // Folder structure ready

      // Create file metadata
      final fileMetadata = drive.File()
        ..name = fileName
        ..parents = [recordFolderId]
        ..description = 'HealthBox attachment uploaded on ${DateTime.now().toIso8601String()}';

      // Create progress-tracking media stream
      final media = drive.Media(
        _createProgressStream(fileBytes, onProgress),
        fileBytes.length,
        contentType: mimeType,
      );

      onProgress?.call(0.5); // Starting upload

      final uploadedFile = await _driveApi!.files.create(
        fileMetadata,
        uploadMedia: media,
      );

      onProgress?.call(1.0); // Upload complete

      _logger.i('Successfully uploaded attachment: ${uploadedFile.id} (${_formatBytes(fileSize)})');
      return uploadedFile.id!;
    } catch (e) {
      _logger.e('Error uploading attachment: $e');
      throw Exception('Failed to upload attachment: $e');
    }
  }

  Future<String> _ensureAttachmentFolderStructure(String recordType) async {
    try {
      // Create main Attachments folder if it doesn't exist
      _attachmentsFolderId ??= await _createOrFindFolder('Attachments', _backupFolderId);
      _logger.i('Attachments folder: $_attachmentsFolderId');

      // Create record type subfolder
      final recordTypeFolderId = await _createOrFindFolder(
        _getRecordTypeFolderName(recordType),
        _attachmentsFolderId,
      );
      _logger.i('Record type folder ($recordType): $recordTypeFolderId');

      return recordTypeFolderId;
    } catch (e) {
      _logger.e('Error ensuring attachment folder structure: $e');
      throw Exception('Failed to create/find attachment folder structure: $e');
    }
  }

  String _getRecordTypeFolderName(String recordType) {
    switch (recordType.toLowerCase()) {
      case 'vaccination':
        return 'Vaccinations';
      case 'allergy':
        return 'Allergies';
      case 'chronic_condition':
        return 'Chronic Conditions';
      case 'surgical_record':
        return 'Surgical Records';
      case 'radiology_record':
        return 'Radiology & Imaging';
      case 'pathology_record':
        return 'Pathology Reports';
      case 'discharge_summary':
        return 'Discharge Summaries';
      case 'hospital_admission':
        return 'Hospital Admissions';
      case 'dental_record':
        return 'Dental Records';
      case 'mental_health_record':
        return 'Mental Health Records';
      case 'general_record':
        return 'General Records';
      case 'prescription':
        return 'Prescriptions & Appointments';
      case 'lab_report':
        return 'Lab Reports';
      case 'medical_record':
        return 'Medical Records';
      default:
        return 'Other Attachments';
    }
  }

  Future<void> deleteAttachment(String fileId) async {
    if (_driveApi == null) {
      throw Exception('Drive API not initialized');
    }

    try {
      await _driveApi!.files.delete(fileId);
      _logger.i('Successfully deleted attachment: $fileId');
    } catch (e) {
      _logger.e('Error deleting attachment: $e');
      throw Exception('Failed to delete attachment: $e');
    }
  }

  Future<List<AttachmentFile>> listAttachments({String? recordType}) async {
    if (_driveApi == null || _attachmentsFolderId == null) {
      await _ensureAttachmentFolderStructure(recordType ?? 'general_record');
    }

    try {
      String folderId = _attachmentsFolderId!;
      if (recordType != null) {
        folderId = await _ensureAttachmentFolderStructure(recordType);
      }

      final query = "'$folderId' in parents and trashed=false";
      final fileList = await _driveApi!.files.list(
        q: query,
        orderBy: 'createdTime desc',
        spaces: 'drive',
      );

      final attachments = <AttachmentFile>[];
      for (final file in fileList.files ?? []) {
        if (file.id != null && file.name != null) {
          int size = 0;
          if (file.size != null) {
            size = int.tryParse(file.size!) ?? 0;
          }

          attachments.add(
            AttachmentFile(
              id: file.id!,
              name: file.name!,
              createdTime: file.createdTime ?? DateTime.now(),
              size: size,
              description: file.description,
              mimeType: file.mimeType ?? 'application/octet-stream',
            ),
          );
        }
      }

      _logger.i('Found ${attachments.length} attachments');
      return attachments;
    } catch (e) {
      _logger.e('Error listing attachments: $e');
      throw Exception('Failed to list attachments: $e');
    }
  }
}

enum BackupType {
  database('Database Backup'),
  export('Data Export');

  const BackupType(this.displayName);
  final String displayName;
}

class AttachmentFile {
  final String id;
  final String name;
  final DateTime createdTime;
  final int size;
  final String? description;
  final String mimeType;

  AttachmentFile({
    required this.id,
    required this.name,
    required this.createdTime,
    required this.size,
    this.description,
    required this.mimeType,
  });

  String get sizeFormatted {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  String get typeIcon {
    if (mimeType.startsWith('image/')) return '🖼️';
    if (mimeType == 'application/pdf') return '📄';
    if (mimeType.contains('document') || mimeType.contains('word')) return '📝';
    return '📎';
  }
}

class BackupFile {
  final String id;
  final String name;
  final DateTime createdTime;
  final int size;
  final String? description;
  final BackupType type;

  BackupFile({
    required this.id,
    required this.name,
    required this.createdTime,
    required this.size,
    this.description,
    required this.type,
  });

  String get sizeFormatted {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  String get typeIcon {
    switch (type) {
      case BackupType.database:
        return '🗄️';
      case BackupType.export:
        return '📄';
    }
  }
}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }

  @override
  void close() {
    _client.close();
  }
}
