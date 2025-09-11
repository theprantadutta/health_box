import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class GoogleDriveService {
  static const List<String> _scopes = [
    drive.DriveApi.driveFileScope,
  ];

  static const String _appFolderName = 'HealthBox';
  static const String _backupFileName = 'healthbox_backup.json';
  static const String _metadataFileName = 'sync_metadata.json';

  final Logger _logger = Logger();

  GoogleSignInAccount? _currentUser;
  drive.DriveApi? _driveApi;
  String? _appFolderId;

  bool get isSignedIn => _currentUser != null;
  GoogleSignInAccount? get currentUser => _currentUser;

  Future<bool> signIn() async {
    try {
      _logger.d('Attempting Google Sign In');
      
      // Initialize Google Sign In with scopes
      await GoogleSignIn.instance.initialize();
      
      // Check if authentication is supported
      if (GoogleSignIn.instance.supportsAuthenticate()) {
        await GoogleSignIn.instance.authenticate();
      }
      
      // Try lightweight authentication first
      final account = await GoogleSignIn.instance.attemptLightweightAuthentication();
      if (account == null) {
        _logger.w('Authentication failed or cancelled');
        return false;
      }

      _currentUser = account;
      await _initializeDriveApi();
      await _ensureAppFolderExists();

      _logger.i('Successfully signed in: ${account.email}');
      return true;
    } catch (e, stackTrace) {
      _logger.e('Sign in failed', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  Future<bool> signInSilently() async {
    try {
      _logger.d('Attempting silent sign in');
      
      // Initialize first
      await GoogleSignIn.instance.initialize();
      
      // Try lightweight authentication (silent)
      final account = await GoogleSignIn.instance.attemptLightweightAuthentication();
      if (account == null) {
        _logger.d('No stored credentials found');
        return false;
      }

      _currentUser = account;
      await _initializeDriveApi();
      await _ensureAppFolderExists();

      _logger.i('Successfully signed in silently: ${account.email}');
      return true;
    } catch (e, stackTrace) {
      _logger.e('Silent sign in failed', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      // Note: Google Sign In v7+ doesn't have a direct signOut method
      // We'll just clear our local state
      _currentUser = null;
      _driveApi = null;
      _appFolderId = null;
      _logger.i('Successfully signed out');
    } catch (e, stackTrace) {
      _logger.e('Sign out failed', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> _initializeDriveApi() async {
    if (_currentUser == null) {
      throw Exception('User must be signed in to initialize Drive API');
    }

    try {
      // Request authorization for Drive API scopes
      final authorization = await _currentUser!.authorizationClient.authorizeScopes(_scopes);
      
      // Create authenticated client
      final authenticatedClient = auth.authenticatedClient(
        http.Client(),
        auth.AccessCredentials(
          auth.AccessToken(
            'Bearer',
            authorization.accessToken,
            DateTime.now().add(const Duration(hours: 1)).toUtc(),
          ),
          null,
          _scopes,
        ),
      );

      _driveApi = drive.DriveApi(authenticatedClient);
      _logger.d('Drive API initialized');
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize Drive API', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> _ensureAppFolderExists() async {
    if (_driveApi == null) return;

    try {
      final query = "name='$_appFolderName' and mimeType='application/vnd.google-apps.folder' and trashed=false";
      final fileList = await _driveApi!.files.list(q: query);

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        _appFolderId = fileList.files!.first.id;
        _logger.d('App folder found: $_appFolderId');
        return;
      }

      final folder = drive.File()
        ..name = _appFolderName
        ..mimeType = 'application/vnd.google-apps.folder';

      final createdFolder = await _driveApi!.files.create(folder);
      _appFolderId = createdFolder.id;
      _logger.i('App folder created: $_appFolderId');
    } catch (e, stackTrace) {
      _logger.e('Failed to ensure app folder exists', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<bool> uploadBackup({
    required String jsonData,
    required Map<String, dynamic> metadata,
  }) async {
    if (_driveApi == null || _appFolderId == null) {
      throw Exception('Drive API not initialized');
    }

    try {
      final backupData = {
        'timestamp': DateTime.now().toIso8601String(),
        'version': '1.0.0',
        'checksum': _calculateChecksum(jsonData),
        'data': jsonData,
      };

      final backupJson = jsonEncode(backupData);
      final backupBytes = utf8.encode(backupJson);

      final existingBackupId = await _findFileInAppFolder(_backupFileName);
      
      late drive.File backupFile;
      if (existingBackupId != null) {
        _logger.d('Updating existing backup file: $existingBackupId');
        backupFile = await _driveApi!.files.update(
          drive.File()..name = _backupFileName,
          existingBackupId,
          uploadMedia: drive.Media(Stream.value(backupBytes), backupBytes.length),
        );
      } else {
        _logger.d('Creating new backup file');
        backupFile = await _driveApi!.files.create(
          drive.File()
            ..name = _backupFileName
            ..parents = [_appFolderId!],
          uploadMedia: drive.Media(Stream.value(backupBytes), backupBytes.length),
        );
      }

      await _uploadMetadata(metadata);
      
      _logger.i('Backup uploaded successfully: ${backupFile.id}');
      return true;
    } catch (e, stackTrace) {
      _logger.e('Upload backup failed', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  Future<Map<String, dynamic>?> downloadBackup() async {
    if (_driveApi == null || _appFolderId == null) {
      throw Exception('Drive API not initialized');
    }

    try {
      final backupFileId = await _findFileInAppFolder(_backupFileName);
      if (backupFileId == null) {
        _logger.w('No backup file found');
        return null;
      }

      final media = await _driveApi!.files.get(
        backupFileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final bytes = <int>[];
      await for (final chunk in media.stream) {
        bytes.addAll(chunk);
      }

      final backupJson = utf8.decode(bytes);
      final backupData = jsonDecode(backupJson) as Map<String, dynamic>;

      final storedChecksum = backupData['checksum'] as String?;
      final jsonData = backupData['data'] as String;
      final calculatedChecksum = _calculateChecksum(jsonData);

      if (storedChecksum != calculatedChecksum) {
        throw Exception('Backup data integrity check failed');
      }

      _logger.i('Backup downloaded and verified successfully');
      return {
        'data': jsonData,
        'timestamp': backupData['timestamp'],
        'version': backupData['version'],
      };
    } catch (e, stackTrace) {
      _logger.e('Download backup failed', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<Map<String, dynamic>?> downloadMetadata() async {
    if (_driveApi == null || _appFolderId == null) {
      throw Exception('Drive API not initialized');
    }

    try {
      final metadataFileId = await _findFileInAppFolder(_metadataFileName);
      if (metadataFileId == null) {
        _logger.w('No metadata file found');
        return null;
      }

      final media = await _driveApi!.files.get(
        metadataFileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final bytes = <int>[];
      await for (final chunk in media.stream) {
        bytes.addAll(chunk);
      }

      final metadataJson = utf8.decode(bytes);
      final metadata = jsonDecode(metadataJson) as Map<String, dynamic>;

      _logger.d('Metadata downloaded successfully');
      return metadata;
    } catch (e, stackTrace) {
      _logger.e('Download metadata failed', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<void> _uploadMetadata(Map<String, dynamic> metadata) async {
    try {
      final metadataJson = jsonEncode({
        ...metadata,
        'lastSyncTimestamp': DateTime.now().toIso8601String(),
      });
      final metadataBytes = utf8.encode(metadataJson);

      final existingMetadataId = await _findFileInAppFolder(_metadataFileName);
      
      if (existingMetadataId != null) {
        await _driveApi!.files.update(
          drive.File()..name = _metadataFileName,
          existingMetadataId,
          uploadMedia: drive.Media(Stream.value(metadataBytes), metadataBytes.length),
        );
      } else {
        await _driveApi!.files.create(
          drive.File()
            ..name = _metadataFileName
            ..parents = [_appFolderId!],
          uploadMedia: drive.Media(Stream.value(metadataBytes), metadataBytes.length),
        );
      }

      _logger.d('Metadata uploaded successfully');
    } catch (e, stackTrace) {
      _logger.e('Upload metadata failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<String?> _findFileInAppFolder(String fileName) async {
    if (_driveApi == null || _appFolderId == null) return null;

    try {
      final query = "name='$fileName' and parents in '$_appFolderId' and trashed=false";
      final fileList = await _driveApi!.files.list(q: query);

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        return fileList.files!.first.id;
      }

      return null;
    } catch (e, stackTrace) {
      _logger.e('Failed to find file in app folder', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  String _calculateChecksum(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> deleteBackup() async {
    if (_driveApi == null || _appFolderId == null) {
      throw Exception('Drive API not initialized');
    }

    try {
      final backupFileId = await _findFileInAppFolder(_backupFileName);
      final metadataFileId = await _findFileInAppFolder(_metadataFileName);

      if (backupFileId != null) {
        await _driveApi!.files.delete(backupFileId);
        _logger.i('Backup file deleted: $backupFileId');
      }

      if (metadataFileId != null) {
        await _driveApi!.files.delete(metadataFileId);
        _logger.i('Metadata file deleted: $metadataFileId');
      }

      return true;
    } catch (e, stackTrace) {
      _logger.e('Delete backup failed', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> listBackups() async {
    if (_driveApi == null || _appFolderId == null) {
      throw Exception('Drive API not initialized');
    }

    try {
      final query = "parents in '$_appFolderId' and trashed=false";
      final fileList = await _driveApi!.files.list(
        q: query,
        orderBy: 'modifiedTime desc',
      );

      final backups = <Map<String, dynamic>>[];
      
      if (fileList.files != null) {
        for (final file in fileList.files!) {
          if (file.name == _backupFileName || file.name == _metadataFileName) {
            backups.add({
              'id': file.id,
              'name': file.name,
              'modifiedTime': file.modifiedTime?.toIso8601String(),
              'size': file.size,
            });
          }
        }
      }

      _logger.d('Found ${backups.length} backup files');
      return backups;
    } catch (e, stackTrace) {
      _logger.e('List backups failed', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  Future<int> getAvailableSpace() async {
    if (_driveApi == null) {
      throw Exception('Drive API not initialized');
    }

    try {
      final about = await _driveApi!.about.get();
      final quota = about.storageQuota;
      
      if (quota != null) {
        final limit = int.tryParse(quota.limit ?? '0') ?? 0;
        final usage = int.tryParse(quota.usage ?? '0') ?? 0;
        return limit - usage;
      }

      return 0;
    } catch (e, stackTrace) {
      _logger.e('Get available space failed', error: e, stackTrace: stackTrace);
      return 0;
    }
  }
}