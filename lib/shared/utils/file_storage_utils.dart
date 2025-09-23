import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';

class FileStorageUtils {
  static const String _attachmentsFolder = 'attachments';
  static const String _thumbnailsFolder = 'thumbnails';

  /// Get the base directory for file storage
  static Future<Directory> getBaseDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory(path.join(appDir.path, 'healthbox_files'));
  }

  /// Get the attachments directory
  static Future<Directory> getAttachmentsDirectory() async {
    final baseDir = await getBaseDirectory();
    final attachmentsDir = Directory(path.join(baseDir.path, _attachmentsFolder));

    if (!await attachmentsDir.exists()) {
      await attachmentsDir.create(recursive: true);
    }

    return attachmentsDir;
  }

  /// Get the thumbnails directory
  static Future<Directory> getThumbnailsDirectory() async {
    final baseDir = await getBaseDirectory();
    final thumbnailsDir = Directory(path.join(baseDir.path, _thumbnailsFolder));

    if (!await thumbnailsDir.exists()) {
      await thumbnailsDir.create(recursive: true);
    }

    return thumbnailsDir;
  }

  /// Get organized file path based on record type and date
  static Future<String> getOrganizedFilePath({
    required String recordId,
    required String recordType,
    required String fileName,
    required DateTime createdDate,
  }) async {
    final attachmentsDir = await getAttachmentsDirectory();

    // Organize by year/month/record_type/record_id
    final year = createdDate.year.toString();
    final month = createdDate.month.toString().padLeft(2, '0');

    final organizationPath = path.join(
      attachmentsDir.path,
      year,
      month,
      recordType,
      recordId,
    );

    final organizationDir = Directory(organizationPath);
    if (!await organizationDir.exists()) {
      await organizationDir.create(recursive: true);
    }

    // Generate unique filename if file already exists
    final fileExtension = path.extension(fileName);
    final fileNameWithoutExt = path.basenameWithoutExtension(fileName);

    String finalFileName = fileName;
    int counter = 1;

    while (await File(path.join(organizationPath, finalFileName)).exists()) {
      finalFileName = '${fileNameWithoutExt}_$counter$fileExtension';
      counter++;
    }

    return path.join(organizationPath, finalFileName);
  }

  /// Save file to organized location
  static Future<String> saveFile({
    required String recordId,
    required String recordType,
    required String fileName,
    required List<int> fileBytes,
    DateTime? createdDate,
  }) async {
    try {
      final targetPath = await getOrganizedFilePath(
        recordId: recordId,
        recordType: recordType,
        fileName: fileName,
        createdDate: createdDate ?? DateTime.now(),
      );

      final file = File(targetPath);
      await file.writeAsBytes(fileBytes);

      debugPrint('File saved successfully: $targetPath');
      return targetPath;
    } catch (e) {
      debugPrint('Failed to save file: $e');
      rethrow;
    }
  }

  /// Copy file from source to organized location
  static Future<String> copyFile({
    required String sourcePath,
    required String recordId,
    required String recordType,
    DateTime? createdDate,
  }) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        throw Exception('Source file does not exist: $sourcePath');
      }

      final fileName = path.basename(sourcePath);
      final fileBytes = await sourceFile.readAsBytes();

      return await saveFile(
        recordId: recordId,
        recordType: recordType,
        fileName: fileName,
        fileBytes: fileBytes,
        createdDate: createdDate,
      );
    } catch (e) {
      debugPrint('Failed to copy file: $e');
      rethrow;
    }
  }

  /// Delete file and cleanup empty directories
  static Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('File deleted: $filePath');

        // Clean up empty directories
        await _cleanupEmptyDirectories(file.parent);
      }
    } catch (e) {
      debugPrint('Failed to delete file: $e');
      // Don't rethrow - file might already be deleted
    }
  }

  /// Delete thumbnail file
  static Future<void> deleteThumbnail(String thumbnailPath) async {
    try {
      final file = File(thumbnailPath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('Thumbnail deleted: $thumbnailPath');
      }
    } catch (e) {
      debugPrint('Failed to delete thumbnail: $e');
    }
  }

  /// Generate thumbnail path for an image
  static Future<String> getThumbnailPath(String originalFilePath) async {
    final thumbnailsDir = await getThumbnailsDirectory();
    final originalFileName = path.basenameWithoutExtension(originalFilePath);
    final thumbnailFileName = '${originalFileName}_thumb.jpg';

    return path.join(thumbnailsDir.path, thumbnailFileName);
  }

  /// Get file size in bytes
  static Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      debugPrint('Failed to get file size: $e');
      return 0;
    }
  }

  /// Format file size for display
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Calculate total storage used by attachments
  static Future<int> getTotalStorageUsed() async {
    try {
      final baseDir = await getBaseDirectory();
      if (!await baseDir.exists()) return 0;

      int totalSize = 0;
      await for (final entity in baseDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }

      return totalSize;
    } catch (e) {
      debugPrint('Failed to calculate total storage: $e');
      return 0;
    }
  }

  /// Clean up empty directories recursively
  static Future<void> _cleanupEmptyDirectories(Directory dir) async {
    try {
      if (!await dir.exists()) return;

      final baseDir = await getBaseDirectory();

      // Don't delete the base directory or its immediate children
      if (dir.path == baseDir.path ||
          dir.parent.path == baseDir.path) return;

      final contents = await dir.list().toList();
      if (contents.isEmpty) {
        await dir.delete();
        debugPrint('Empty directory deleted: ${dir.path}');

        // Recursively clean up parent directories
        await _cleanupEmptyDirectories(dir.parent);
      }
    } catch (e) {
      debugPrint('Failed to clean up directory: $e');
    }
  }

  /// Get all files for a specific record
  static Future<List<File>> getRecordFiles(String recordId) async {
    final baseDir = await getBaseDirectory();
    final List<File> recordFiles = [];

    if (!await baseDir.exists()) return recordFiles;

    await for (final entity in baseDir.list(recursive: true)) {
      if (entity is File && entity.path.contains(recordId)) {
        recordFiles.add(entity);
      }
    }

    return recordFiles;
  }

  /// Validate file path is within allowed directories
  static Future<bool> isValidFilePath(String filePath) async {
    try {
      final baseDir = await getBaseDirectory();
      final canonicalBasePath = baseDir.resolveSymbolicLinksSync();
      final canonicalFilePath = File(filePath).resolveSymbolicLinksSync();

      return canonicalFilePath.startsWith(canonicalBasePath);
    } catch (e) {
      debugPrint('Invalid file path: $e');
      return false;
    }
  }
}