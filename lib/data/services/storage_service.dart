import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late final Directory _documentsDirectory;
  late final Directory _cacheDirectory;
  late final Directory _secureDirectory;
  bool _isInitialized = false;

  // Encryption key for sensitive data (in production, this should come from secure storage)
  static const String _encryptionKey = 'health_box_storage_encryption_key_2024';

  // Initialize storage service
  Future<void> initialize() async {
    try {
      if (_isInitialized) return;

      _documentsDirectory = await getApplicationDocumentsDirectory();
      _cacheDirectory = await getTemporaryDirectory();

      // Create secure directory for encrypted files
      _secureDirectory = Directory(
        path.join(_documentsDirectory.path, 'secure'),
      );
      if (!await _secureDirectory.exists()) {
        await _secureDirectory.create(recursive: true);
      }

      _isInitialized = true;
    } catch (e) {
      throw StorageServiceException(
        'Failed to initialize storage service: ${e.toString()}',
      );
    }
  }

  // Secure Storage Operations

  Future<void> storeSecureData(String key, String data) async {
    try {
      await _ensureInitialized();
      final encryptedData = _encryptData(data);
      final file = File(path.join(_secureDirectory.path, '$key.enc'));
      await file.writeAsBytes(encryptedData);
    } catch (e) {
      throw StorageServiceException(
        'Failed to store secure data: ${e.toString()}',
      );
    }
  }

  Future<String?> retrieveSecureData(String key) async {
    try {
      await _ensureInitialized();
      final file = File(path.join(_secureDirectory.path, '$key.enc'));

      if (!await file.exists()) {
        return null;
      }

      final encryptedData = await file.readAsBytes();
      return _decryptData(encryptedData);
    } catch (e) {
      throw StorageServiceException(
        'Failed to retrieve secure data: ${e.toString()}',
      );
    }
  }

  Future<bool> deleteSecureData(String key) async {
    try {
      await _ensureInitialized();
      final file = File(path.join(_secureDirectory.path, '$key.enc'));

      if (await file.exists()) {
        await file.delete();
        return true;
      }

      return false;
    } catch (e) {
      throw StorageServiceException(
        'Failed to delete secure data: ${e.toString()}',
      );
    }
  }

  Future<List<String>> listSecureDataKeys() async {
    try {
      await _ensureInitialized();
      final files = await _secureDirectory.list().toList();

      return files
          .where((entity) => entity is File && entity.path.endsWith('.enc'))
          .map((entity) => path.basenameWithoutExtension(entity.path))
          .toList();
    } catch (e) {
      throw StorageServiceException(
        'Failed to list secure data keys: ${e.toString()}',
      );
    }
  }

  // Regular File Operations

  Future<void> storeData(String relativePath, String data) async {
    try {
      await _ensureInitialized();
      final file = File(path.join(_documentsDirectory.path, relativePath));
      await file.create(recursive: true);
      await file.writeAsString(data);
    } catch (e) {
      throw StorageServiceException('Failed to store data: ${e.toString()}');
    }
  }

  Future<String?> retrieveData(String relativePath) async {
    try {
      await _ensureInitialized();
      final file = File(path.join(_documentsDirectory.path, relativePath));

      if (!await file.exists()) {
        return null;
      }

      return await file.readAsString();
    } catch (e) {
      throw StorageServiceException('Failed to retrieve data: ${e.toString()}');
    }
  }

  Future<void> storeBinaryData(String relativePath, Uint8List data) async {
    try {
      await _ensureInitialized();
      final file = File(path.join(_documentsDirectory.path, relativePath));
      await file.create(recursive: true);
      await file.writeAsBytes(data);
    } catch (e) {
      throw StorageServiceException(
        'Failed to store binary data: ${e.toString()}',
      );
    }
  }

  Future<Uint8List?> retrieveBinaryData(String relativePath) async {
    try {
      await _ensureInitialized();
      final file = File(path.join(_documentsDirectory.path, relativePath));

      if (!await file.exists()) {
        return null;
      }

      return await file.readAsBytes();
    } catch (e) {
      throw StorageServiceException(
        'Failed to retrieve binary data: ${e.toString()}',
      );
    }
  }

  // JSON Storage Operations

  Future<void> storeJsonData(
    String relativePath,
    Map<String, dynamic> data,
  ) async {
    try {
      final jsonString = json.encode(data);
      await storeData(relativePath, jsonString);
    } catch (e) {
      throw StorageServiceException(
        'Failed to store JSON data: ${e.toString()}',
      );
    }
  }

  Future<Map<String, dynamic>?> retrieveJsonData(String relativePath) async {
    try {
      final jsonString = await retrieveData(relativePath);
      if (jsonString == null) return null;

      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw StorageServiceException(
        'Failed to retrieve JSON data: ${e.toString()}',
      );
    }
  }

  Future<void> storeSecureJsonData(
    String key,
    Map<String, dynamic> data,
  ) async {
    try {
      final jsonString = json.encode(data);
      await storeSecureData(key, jsonString);
    } catch (e) {
      throw StorageServiceException(
        'Failed to store secure JSON data: ${e.toString()}',
      );
    }
  }

  Future<Map<String, dynamic>?> retrieveSecureJsonData(String key) async {
    try {
      final jsonString = await retrieveSecureData(key);
      if (jsonString == null) return null;

      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw StorageServiceException(
        'Failed to retrieve secure JSON data: ${e.toString()}',
      );
    }
  }

  // File Management Operations

  Future<bool> fileExists(String relativePath) async {
    try {
      await _ensureInitialized();
      final file = File(path.join(_documentsDirectory.path, relativePath));
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteFile(String relativePath) async {
    try {
      await _ensureInitialized();
      final file = File(path.join(_documentsDirectory.path, relativePath));

      if (await file.exists()) {
        await file.delete();
        return true;
      }

      return false;
    } catch (e) {
      throw StorageServiceException('Failed to delete file: ${e.toString()}');
    }
  }

  Future<List<String>> listFiles({String? subdirectory}) async {
    try {
      await _ensureInitialized();
      final directory = subdirectory != null
          ? Directory(path.join(_documentsDirectory.path, subdirectory))
          : _documentsDirectory;

      if (!await directory.exists()) {
        return [];
      }

      final files = await directory.list(recursive: false).toList();

      return files
          .where((entity) => entity is File)
          .map((entity) => path.basename(entity.path))
          .toList();
    } catch (e) {
      throw StorageServiceException('Failed to list files: ${e.toString()}');
    }
  }

  Future<int> getFileSize(String relativePath) async {
    try {
      await _ensureInitialized();
      final file = File(path.join(_documentsDirectory.path, relativePath));

      if (!await file.exists()) {
        return 0;
      }

      return await file.length();
    } catch (e) {
      return 0;
    }
  }

  Future<DateTime?> getFileModifiedTime(String relativePath) async {
    try {
      await _ensureInitialized();
      final file = File(path.join(_documentsDirectory.path, relativePath));

      if (!await file.exists()) {
        return null;
      }

      final stat = await file.stat();
      return stat.modified;
    } catch (e) {
      return null;
    }
  }

  // Directory Operations

  Future<void> createDirectory(String relativePath) async {
    try {
      await _ensureInitialized();
      final directory = Directory(
        path.join(_documentsDirectory.path, relativePath),
      );
      await directory.create(recursive: true);
    } catch (e) {
      throw StorageServiceException(
        'Failed to create directory: ${e.toString()}',
      );
    }
  }

  Future<bool> directoryExists(String relativePath) async {
    try {
      await _ensureInitialized();
      final directory = Directory(
        path.join(_documentsDirectory.path, relativePath),
      );
      return await directory.exists();
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteDirectory(
    String relativePath, {
    bool recursive = false,
  }) async {
    try {
      await _ensureInitialized();
      final directory = Directory(
        path.join(_documentsDirectory.path, relativePath),
      );

      if (await directory.exists()) {
        await directory.delete(recursive: recursive);
        return true;
      }

      return false;
    } catch (e) {
      throw StorageServiceException(
        'Failed to delete directory: ${e.toString()}',
      );
    }
  }

  // Cache Operations

  Future<void> storeCacheData(String key, String data, {Duration? ttl}) async {
    try {
      await _ensureInitialized();
      final cacheData = {
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'ttl': ttl?.inMilliseconds,
      };

      final file = File(path.join(_cacheDirectory.path, '$key.cache'));
      await file.writeAsString(json.encode(cacheData));
    } catch (e) {
      throw StorageServiceException(
        'Failed to store cache data: ${e.toString()}',
      );
    }
  }

  Future<String?> retrieveCacheData(String key) async {
    try {
      await _ensureInitialized();
      final file = File(path.join(_cacheDirectory.path, '$key.cache'));

      if (!await file.exists()) {
        return null;
      }

      final cacheDataString = await file.readAsString();
      final cacheData = json.decode(cacheDataString) as Map<String, dynamic>;

      final timestamp = cacheData['timestamp'] as int;
      final ttl = cacheData['ttl'] as int?;

      if (ttl != null) {
        final expiryTime = DateTime.fromMillisecondsSinceEpoch(
          timestamp,
        ).add(Duration(milliseconds: ttl));
        if (DateTime.now().isAfter(expiryTime)) {
          // Cache expired, delete and return null
          await file.delete();
          return null;
        }
      }

      return cacheData['data'] as String;
    } catch (e) {
      return null;
    }
  }

  Future<void> clearCache() async {
    try {
      await _ensureInitialized();
      final cacheFiles = await _cacheDirectory.list().toList();

      for (final entity in cacheFiles) {
        if (entity is File && entity.path.endsWith('.cache')) {
          await entity.delete();
        }
      }
    } catch (e) {
      throw StorageServiceException('Failed to clear cache: ${e.toString()}');
    }
  }

  // Backup and Export Operations

  Future<String> createBackup({
    List<String>? includePatterns,
    List<String>? excludePatterns,
  }) async {
    try {
      await _ensureInitialized();
      final backupName = 'backup_${DateTime.now().millisecondsSinceEpoch}';
      final backupPath = path.join(
        _documentsDirectory.path,
        'backups',
        '$backupName.json',
      );

      await createDirectory('backups');

      final backupData = <String, dynamic>{
        'created': DateTime.now().toIso8601String(),
        'version': '1.0',
        'files': <String, dynamic>{},
      };

      final files = await _getAllFiles();

      for (final relativePath in files) {
        if (_shouldIncludeInBackup(
          relativePath,
          includePatterns,
          excludePatterns,
        )) {
          final data = await retrieveData(relativePath);
          if (data != null) {
            backupData['files'][relativePath] = data;
          }
        }
      }

      await storeData('backups/$backupName.json', json.encode(backupData));
      return backupPath;
    } catch (e) {
      throw StorageServiceException('Failed to create backup: ${e.toString()}');
    }
  }

  Future<void> restoreBackup(String backupPath) async {
    try {
      await _ensureInitialized();
      final backupData = await retrieveJsonData(backupPath);

      if (backupData == null) {
        throw const StorageServiceException('Backup file not found');
      }

      final files = backupData['files'] as Map<String, dynamic>;

      for (final entry in files.entries) {
        await storeData(entry.key, entry.value.toString());
      }
    } catch (e) {
      if (e is StorageServiceException) rethrow;
      throw StorageServiceException(
        'Failed to restore backup: ${e.toString()}',
      );
    }
  }

  // Storage Analytics

  Future<StorageInfo> getStorageInfo() async {
    try {
      await _ensureInitialized();

      final totalFiles = await _countFiles(_documentsDirectory);
      final totalSize = await _calculateDirectorySize(_documentsDirectory);
      final secureFiles = await _countFiles(_secureDirectory);
      final secureSize = await _calculateDirectorySize(_secureDirectory);
      final cacheFiles = await _countFiles(_cacheDirectory);
      final cacheSize = await _calculateDirectorySize(_cacheDirectory);

      return StorageInfo(
        totalFiles: totalFiles,
        totalSize: totalSize,
        secureFiles: secureFiles,
        secureSize: secureSize,
        cacheFiles: cacheFiles,
        cacheSize: cacheSize,
        documentsPath: _documentsDirectory.path,
        securePath: _secureDirectory.path,
        cachePath: _cacheDirectory.path,
      );
    } catch (e) {
      throw StorageServiceException(
        'Failed to get storage info: ${e.toString()}',
      );
    }
  }

  // Private Helper Methods

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  Uint8List _encryptData(String data) {
    // Simple XOR encryption (in production, use proper encryption like AES)
    final dataBytes = utf8.encode(data);
    final keyBytes = utf8.encode(_encryptionKey);
    final encrypted = Uint8List(dataBytes.length);

    for (int i = 0; i < dataBytes.length; i++) {
      encrypted[i] = dataBytes[i] ^ keyBytes[i % keyBytes.length];
    }

    return encrypted;
  }

  String _decryptData(Uint8List encryptedData) {
    // Simple XOR decryption (in production, use proper decryption like AES)
    final keyBytes = utf8.encode(_encryptionKey);
    final decrypted = Uint8List(encryptedData.length);

    for (int i = 0; i < encryptedData.length; i++) {
      decrypted[i] = encryptedData[i] ^ keyBytes[i % keyBytes.length];
    }

    return utf8.decode(decrypted);
  }

  Future<List<String>> _getAllFiles() async {
    final files = <String>[];
    await for (final entity in _documentsDirectory.list(recursive: true)) {
      if (entity is File) {
        final relativePath = path.relative(
          entity.path,
          from: _documentsDirectory.path,
        );
        files.add(relativePath);
      }
    }
    return files;
  }

  bool _shouldIncludeInBackup(
    String filePath,
    List<String>? includePatterns,
    List<String>? excludePatterns,
  ) {
    if (excludePatterns != null) {
      for (final pattern in excludePatterns) {
        if (filePath.contains(pattern)) {
          return false;
        }
      }
    }

    if (includePatterns != null) {
      for (final pattern in includePatterns) {
        if (filePath.contains(pattern)) {
          return true;
        }
      }
      return false;
    }

    return true;
  }

  Future<int> _countFiles(Directory directory) async {
    if (!await directory.exists()) return 0;

    int count = 0;
    await for (final entity in directory.list(recursive: true)) {
      if (entity is File) count++;
    }
    return count;
  }

  Future<int> _calculateDirectorySize(Directory directory) async {
    if (!await directory.exists()) return 0;

    int totalSize = 0;
    await for (final entity in directory.list(recursive: true)) {
      if (entity is File) {
        try {
          totalSize += await entity.length();
        } catch (e) {
          // Skip files that can't be accessed
        }
      }
    }
    return totalSize;
  }
}

// Data Classes

class StorageInfo {
  final int totalFiles;
  final int totalSize;
  final int secureFiles;
  final int secureSize;
  final int cacheFiles;
  final int cacheSize;
  final String documentsPath;
  final String securePath;
  final String cachePath;

  const StorageInfo({
    required this.totalFiles,
    required this.totalSize,
    required this.secureFiles,
    required this.secureSize,
    required this.cacheFiles,
    required this.cacheSize,
    required this.documentsPath,
    required this.securePath,
    required this.cachePath,
  });

  String get formattedTotalSize => _formatBytes(totalSize);
  String get formattedSecureSize => _formatBytes(secureSize);
  String get formattedCacheSize => _formatBytes(cacheSize);

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

// Exceptions

class StorageServiceException implements Exception {
  final String message;

  const StorageServiceException(this.message);

  @override
  String toString() => 'StorageServiceException: $message';
}
