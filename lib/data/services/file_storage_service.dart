import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:drift/drift.dart';
import 'package:image/image.dart' as img;
import '../repositories/attachment_dao.dart';
import '../database/app_database.dart';
import 'storage_service.dart';

class FileStorageService {
  final AttachmentDao _attachmentDao;
  final StorageService _storageService;

  late final Directory _attachmentsDirectory;
  late final Directory _thumbnailsDirectory;
  bool _isInitialized = false;

  FileStorageService({
    AttachmentDao? attachmentDao,
    StorageService? storageService,
    AppDatabase? database,
  }) : _attachmentDao =
           attachmentDao ?? AttachmentDao(database ?? AppDatabase.instance),
       _storageService = storageService ?? StorageService();

  // Initialize file storage service
  Future<void> initialize() async {
    try {
      if (_isInitialized) return;

      await _storageService.initialize();

      final documentsDirectory = await getApplicationDocumentsDirectory();
      _attachmentsDirectory = Directory(
        path.join(documentsDirectory.path, 'attachments'),
      );
      _thumbnailsDirectory = Directory(
        path.join(documentsDirectory.path, 'thumbnails'),
      );

      // Create directories if they don't exist
      if (!await _attachmentsDirectory.exists()) {
        await _attachmentsDirectory.create(recursive: true);
      }

      if (!await _thumbnailsDirectory.exists()) {
        await _thumbnailsDirectory.create(recursive: true);
      }

      _isInitialized = true;
    } catch (e) {
      throw FileStorageServiceException(
        'Failed to initialize file storage service: ${e.toString()}',
      );
    }
  }

  // Core File Operations

  Future<String> storeFile({
    required String recordId,
    required File sourceFile,
    required String fileName,
    String? description,
    bool generateThumbnail = false,
  }) async {
    try {
      await _ensureInitialized();

      if (!await sourceFile.exists()) {
        throw const FileStorageServiceException('Source file does not exist');
      }

      // Generate unique file ID
      final fileId = 'file_${DateTime.now().millisecondsSinceEpoch}';
      final fileExtension = path.extension(fileName);
      final storedFileName = '$fileId$fileExtension';

      // Determine storage path
      final storagePath = path.join(_attachmentsDirectory.path, storedFileName);
      final destinationFile = File(storagePath);

      // Copy file to storage location
      await sourceFile.copy(storagePath);

      // Get file info
      final fileStats = await destinationFile.stat();
      final fileSize = fileStats.size;
      final fileType = _detectFileType(fileName);

      // Generate thumbnail if requested and file type supports it
      String? thumbnailPath;
      if (generateThumbnail && _supportsThumbnailerGeneration(fileType)) {
        thumbnailPath = await _generateThumbnail(destinationFile, fileId);
      }

      // Calculate file hash for integrity checking
      final fileHash = await _calculateFileHash(destinationFile);

      // Store attachment metadata in database
      final attachmentCompanion = AttachmentsCompanion(
        id: Value(fileId),
        recordId: Value(recordId),
        fileName: Value(fileName),
        filePath: Value(storagePath),
        fileType: Value(fileType),
        fileSize: Value(fileSize),
        description: Value(description),
        createdAt: Value(DateTime.now()),
        isSynced: const Value(false),
      );

      await _attachmentDao.createAttachment(attachmentCompanion);

      // Store additional metadata securely
      await _storeFileMetadata(fileId, {
        'originalFileName': fileName,
        'storedFileName': storedFileName,
        'fileHash': fileHash,
        'thumbnailPath': thumbnailPath,
        'uploadDate': DateTime.now().toIso8601String(),
      });

      return fileId;
    } catch (e) {
      if (e is FileStorageServiceException) rethrow;
      throw FileStorageServiceException(
        'Failed to store file: ${e.toString()}',
      );
    }
  }

  Future<File?> retrieveFile(String fileId) async {
    try {
      await _ensureInitialized();

      final attachment = await _attachmentDao.getAttachmentById(fileId);
      if (attachment == null) {
        return null;
      }

      final file = File(attachment.filePath);
      if (!await file.exists()) {
        // File is missing, mark attachment as orphaned
        await _attachmentDao.deleteAttachment(fileId);
        return null;
      }

      return file;
    } catch (e) {
      throw FileStorageServiceException(
        'Failed to retrieve file: ${e.toString()}',
      );
    }
  }

  Future<Uint8List?> retrieveFileData(String fileId) async {
    try {
      final file = await retrieveFile(fileId);
      if (file == null) return null;

      return await file.readAsBytes();
    } catch (e) {
      throw FileStorageServiceException(
        'Failed to retrieve file data: ${e.toString()}',
      );
    }
  }

  Future<bool> deleteFile(
    String fileId, {
    bool deletePhysicalFile = true,
  }) async {
    try {
      await _ensureInitialized();

      final attachment = await _attachmentDao.getAttachmentById(fileId);
      if (attachment == null) {
        return false;
      }

      // Delete physical file if requested
      if (deletePhysicalFile) {
        final file = File(attachment.filePath);
        if (await file.exists()) {
          await file.delete();
        }

        // Delete thumbnail if exists
        await _deleteThumbnail(fileId);

        // Delete metadata
        await _deleteFileMetadata(fileId);
      }

      // Remove from database
      return await _attachmentDao.deleteAttachment(fileId);
    } catch (e) {
      throw FileStorageServiceException(
        'Failed to delete file: ${e.toString()}',
      );
    }
  }

  // File Information and Validation

  Future<FileInfo?> getFileInfo(String fileId) async {
    try {
      await _ensureInitialized();

      final attachment = await _attachmentDao.getAttachmentById(fileId);
      if (attachment == null) {
        return null;
      }

      final file = File(attachment.filePath);
      final fileExists = await file.exists();

      final metadata = await _retrieveFileMetadata(fileId);

      return FileInfo(
        id: fileId,
        fileName: attachment.fileName,
        filePath: attachment.filePath,
        fileType: attachment.fileType,
        fileSize: attachment.fileSize,
        description: attachment.description,
        createdAt: attachment.createdAt,
        isSynced: attachment.isSynced,
        exists: fileExists,
        metadata: metadata,
      );
    } catch (e) {
      throw FileStorageServiceException(
        'Failed to get file info: ${e.toString()}',
      );
    }
  }

  Future<bool> verifyFileIntegrity(String fileId) async {
    try {
      final file = await retrieveFile(fileId);
      if (file == null) return false;

      final metadata = await _retrieveFileMetadata(fileId);
      final expectedHash = metadata?['fileHash'];

      if (expectedHash == null) {
        // No hash stored, calculate and store it now
        final currentHash = await _calculateFileHash(file);
        await _updateFileMetadata(fileId, {'fileHash': currentHash});
        return true;
      }

      final currentHash = await _calculateFileHash(file);
      return currentHash == expectedHash;
    } catch (e) {
      return false;
    }
  }

  // Thumbnail Operations

  Future<File?> getThumbnail(String fileId) async {
    try {
      final metadata = await _retrieveFileMetadata(fileId);
      final thumbnailPath = metadata?['thumbnailPath'];

      if (thumbnailPath == null) return null;

      final thumbnailFile = File(thumbnailPath);
      if (!await thumbnailFile.exists()) return null;

      return thumbnailFile;
    } catch (e) {
      return null;
    }
  }

  Future<String?> generateThumbnail(
    String fileId, {
    int maxWidth = 200,
    int maxHeight = 200,
  }) async {
    try {
      final file = await retrieveFile(fileId);
      if (file == null) return null;

      final attachment = await _attachmentDao.getAttachmentById(fileId);
      if (attachment == null ||
          !_supportsThumbnailerGeneration(attachment.fileType)) {
        return null;
      }

      return await _generateThumbnail(
        file,
        fileId,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );
    } catch (e) {
      return null;
    }
  }

  // Batch Operations

  Future<List<String>> storeMultipleFiles({
    required String recordId,
    required List<File> sourceFiles,
    required List<String> fileNames,
    List<String?>? descriptions,
    bool generateThumbnails = false,
  }) async {
    try {
      if (sourceFiles.length != fileNames.length) {
        throw const FileStorageServiceException(
          'Source files and file names lists must have the same length',
        );
      }

      final fileIds = <String>[];

      for (int i = 0; i < sourceFiles.length; i++) {
        try {
          final fileId = await storeFile(
            recordId: recordId,
            sourceFile: sourceFiles[i],
            fileName: fileNames[i],
            description: descriptions != null && i < descriptions.length
                ? descriptions[i]
                : null,
            generateThumbnail: generateThumbnails,
          );
          fileIds.add(fileId);
        } catch (e) {
          // Continue with other files even if one fails
          continue;
        }
      }

      return fileIds;
    } catch (e) {
      if (e is FileStorageServiceException) rethrow;
      throw FileStorageServiceException(
        'Failed to store multiple files: ${e.toString()}',
      );
    }
  }

  Future<int> deleteMultipleFiles(
    List<String> fileIds, {
    bool deletePhysicalFiles = true,
  }) async {
    try {
      int deletedCount = 0;

      for (final fileId in fileIds) {
        try {
          if (await deleteFile(
            fileId,
            deletePhysicalFile: deletePhysicalFiles,
          )) {
            deletedCount++;
          }
        } catch (e) {
          // Continue with other files even if one fails
          continue;
        }
      }

      return deletedCount;
    } catch (e) {
      throw FileStorageServiceException(
        'Failed to delete multiple files: ${e.toString()}',
      );
    }
  }

  // Storage Management

  Future<List<String>> findOrphanedFiles() async {
    try {
      await _ensureInitialized();

      final orphanedFiles = <String>[];

      // Get all files in attachments directory
      final attachmentFiles = await _attachmentsDirectory.list().toList();

      for (final entity in attachmentFiles) {
        if (entity is File) {
          final fileName = path.basename(entity.path);
          final fileId = path.basenameWithoutExtension(fileName);

          // Check if attachment exists in database
          final attachment = await _attachmentDao.getAttachmentById(fileId);
          if (attachment == null) {
            orphanedFiles.add(entity.path);
          }
        }
      }

      return orphanedFiles;
    } catch (e) {
      throw FileStorageServiceException(
        'Failed to find orphaned files: ${e.toString()}',
      );
    }
  }

  Future<int> cleanupOrphanedFiles() async {
    try {
      final orphanedFiles = await findOrphanedFiles();
      int deletedCount = 0;

      for (final filePath in orphanedFiles) {
        try {
          await File(filePath).delete();
          deletedCount++;
        } catch (e) {
          // Continue with other files even if one fails
          continue;
        }
      }

      // Also cleanup orphaned database records
      final orphanedRecords = await _attachmentDao.cleanupOrphanedRecords();

      return deletedCount + orphanedRecords;
    } catch (e) {
      throw FileStorageServiceException(
        'Failed to cleanup orphaned files: ${e.toString()}',
      );
    }
  }

  Future<StorageAnalytics> getStorageAnalytics() async {
    try {
      await _ensureInitialized();

      final allAttachments = await _attachmentDao.getAllAttachments();
      final totalFiles = allAttachments.length;
      final totalSize = allAttachments.fold<int>(
        0,
        (sum, attachment) => sum + attachment.fileSize,
      );

      final fileTypeCounts = <String, int>{};
      final fileTypeSizes = <String, int>{};

      for (final attachment in allAttachments) {
        fileTypeCounts[attachment.fileType] =
            (fileTypeCounts[attachment.fileType] ?? 0) + 1;
        fileTypeSizes[attachment.fileType] =
            (fileTypeSizes[attachment.fileType] ?? 0) + attachment.fileSize;
      }

      final orphanedFiles = await findOrphanedFiles();
      final largeFiles = allAttachments
          .where((a) => a.fileSize > 10 * 1024 * 1024)
          .length; // Files > 10MB

      return StorageAnalytics(
        totalFiles: totalFiles,
        totalSize: totalSize,
        fileTypeCounts: fileTypeCounts,
        fileTypeSizes: fileTypeSizes,
        orphanedFiles: orphanedFiles.length,
        largeFiles: largeFiles,
        averageFileSize: totalFiles > 0 ? totalSize ~/ totalFiles : 0,
      );
    } catch (e) {
      throw FileStorageServiceException(
        'Failed to get storage analytics: ${e.toString()}',
      );
    }
  }

  // Private Helper Methods

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  String _detectFileType(String fileName) {
    final extension = path.extension(fileName).toLowerCase();

    switch (extension) {
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
      case '.bmp':
      case '.webp':
        return 'image';
      case '.pdf':
        return 'pdf';
      case '.doc':
      case '.docx':
      case '.txt':
      case '.rtf':
        return 'document';
      default:
        return 'other';
    }
  }

  bool _supportsThumbnailerGeneration(String fileType) {
    return fileType == 'image' || fileType == 'pdf';
  }

  Future<String?> _generateThumbnail(
    File sourceFile,
    String fileId, {
    int maxWidth = 200,
    int maxHeight = 200,
  }) async {
    try {
      final thumbnailName = 'thumb_$fileId.jpg';
      final thumbnailPath = path.join(_thumbnailsDirectory.path, thumbnailName);

      // Read the original image
      final originalBytes = await sourceFile.readAsBytes();
      final originalImage = img.decodeImage(originalBytes);

      if (originalImage == null) {
        // If not a valid image, just copy the file
        await sourceFile.copy(thumbnailPath);
        return thumbnailPath;
      }

      // Generate thumbnail - resize to fit within maxWidth x maxHeight while maintaining aspect ratio
      final thumbnail = img.copyResize(
        originalImage,
        width: maxWidth,
        height: maxHeight,
        maintainAspect: true,
      );

      // Convert to JPEG for smaller file size
      final thumbnailBytes = img.encodeJpg(thumbnail, quality: 85);
      await File(thumbnailPath).writeAsBytes(thumbnailBytes);

      return thumbnailPath;
    } catch (e) {
      return null;
    }
  }

  Future<void> _deleteThumbnail(String fileId) async {
    try {
      final thumbnailName = 'thumb_$fileId.jpg';
      final thumbnailFile = File(
        path.join(_thumbnailsDirectory.path, thumbnailName),
      );

      if (await thumbnailFile.exists()) {
        await thumbnailFile.delete();
      }
    } catch (e) {
      // Ignore errors when deleting thumbnails
    }
  }

  Future<String> _calculateFileHash(File file) async {
    try {
      final fileBytes = await file.readAsBytes();
      final digest = sha256.convert(fileBytes);
      return digest.toString();
    } catch (e) {
      return '';
    }
  }

  Future<void> _storeFileMetadata(
    String fileId,
    Map<String, dynamic> metadata,
  ) async {
    try {
      await _storageService.storeSecureJsonData(
        'file_metadata_$fileId',
        metadata,
      );
    } catch (e) {
      // Ignore metadata storage errors
    }
  }

  Future<Map<String, dynamic>?> _retrieveFileMetadata(String fileId) async {
    try {
      return await _storageService.retrieveSecureJsonData(
        'file_metadata_$fileId',
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> _updateFileMetadata(
    String fileId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final existingMetadata =
          await _retrieveFileMetadata(fileId) ?? <String, dynamic>{};
      existingMetadata.addAll(updates);
      await _storeFileMetadata(fileId, existingMetadata);
    } catch (e) {
      // Ignore metadata update errors
    }
  }

  Future<void> _deleteFileMetadata(String fileId) async {
    try {
      await _storageService.deleteSecureData('file_metadata_$fileId');
    } catch (e) {
      // Ignore metadata deletion errors
    }
  }
}

// Data Classes

class FileInfo {
  final String id;
  final String fileName;
  final String filePath;
  final String fileType;
  final int fileSize;
  final String? description;
  final DateTime createdAt;
  final bool isSynced;
  final bool exists;
  final Map<String, dynamic>? metadata;

  const FileInfo({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.fileType,
    required this.fileSize,
    this.description,
    required this.createdAt,
    required this.isSynced,
    required this.exists,
    this.metadata,
  });

  String get formattedFileSize => _formatFileSize(fileSize);

  static String _formatFileSize(int sizeInBytes) {
    if (sizeInBytes < 1024) {
      return '$sizeInBytes B';
    } else if (sizeInBytes < 1024 * 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    } else if (sizeInBytes < 1024 * 1024 * 1024) {
      return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(sizeInBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}

class StorageAnalytics {
  final int totalFiles;
  final int totalSize;
  final Map<String, int> fileTypeCounts;
  final Map<String, int> fileTypeSizes;
  final int orphanedFiles;
  final int largeFiles;
  final int averageFileSize;

  const StorageAnalytics({
    required this.totalFiles,
    required this.totalSize,
    required this.fileTypeCounts,
    required this.fileTypeSizes,
    required this.orphanedFiles,
    required this.largeFiles,
    required this.averageFileSize,
  });

  String get formattedTotalSize => FileInfo._formatFileSize(totalSize);
  String get formattedAverageFileSize =>
      FileInfo._formatFileSize(averageFileSize);
}

// Exceptions

class FileStorageServiceException implements Exception {
  final String message;

  const FileStorageServiceException(this.message);

  @override
  String toString() => 'FileStorageServiceException: $message';
}
