import 'dart:io';
import 'package:path/path.dart' as path;

class FileUtils {
  /// Get MIME type for a file based on extension
  static String getMimeType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();

    switch (extension) {
      // Images
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.bmp':
        return 'image/bmp';
      case '.webp':
        return 'image/webp';
      case '.svg':
        return 'image/svg+xml';

      // Documents
      case '.pdf':
        return 'application/pdf';
      case '.doc':
        return 'application/msword';
      case '.docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case '.txt':
        return 'text/plain';
      case '.rtf':
        return 'application/rtf';

      // Audio
      case '.mp3':
        return 'audio/mpeg';
      case '.wav':
        return 'audio/wav';
      case '.aac':
        return 'audio/aac';
      case '.m4a':
        return 'audio/mp4';

      // Video
      case '.mp4':
        return 'video/mp4';
      case '.avi':
        return 'video/x-msvideo';
      case '.mov':
        return 'video/quicktime';
      case '.wmv':
        return 'video/x-ms-wmv';

      default:
        return 'application/octet-stream';
    }
  }

  /// Format file size in human-readable format
  static String formatFileSize(int bytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];

    if (bytes == 0) return '0 B';

    int i = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    return '${size.toStringAsFixed(size < 10 ? 1 : 0)} ${suffixes[i]}';
  }

  /// Get file extension from path
  static String getFileExtension(String filePath) {
    return path.extension(filePath).toLowerCase();
  }

  /// Get file name without extension
  static String getFileNameWithoutExtension(String filePath) {
    return path.basenameWithoutExtension(filePath);
  }

  /// Check if file is an image
  static bool isImageFile(String filePath) {
    final extension = getFileExtension(filePath);
    return [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.bmp',
      '.webp',
      '.svg',
    ].contains(extension);
  }

  /// Check if file is a document
  static bool isDocumentFile(String filePath) {
    final extension = getFileExtension(filePath);
    return ['.pdf', '.doc', '.docx', '.txt', '.rtf'].contains(extension);
  }

  /// Check if file is a video
  static bool isVideoFile(String filePath) {
    final extension = getFileExtension(filePath);
    return ['.mp4', '.avi', '.mov', '.wmv'].contains(extension);
  }

  /// Check if file is an audio file
  static bool isAudioFile(String filePath) {
    final extension = getFileExtension(filePath);
    return ['.mp3', '.wav', '.aac', '.m4a'].contains(extension);
  }

  /// Sanitize filename for safe storage
  static String sanitizeFileName(String fileName) {
    // Replace unsafe characters with underscores
    return fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
  }

  /// Generate unique filename
  static String generateUniqueFileName(String originalFileName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = getFileExtension(originalFileName);
    final nameWithoutExt = getFileNameWithoutExtension(originalFileName);
    final sanitizedName = sanitizeFileName(nameWithoutExt);

    return '${timestamp}_${sanitizedName}$extension';
  }

  /// Get file size asynchronously
  static Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      return await file.length();
    } catch (e) {
      return 0;
    }
  }

  /// Check if file exists
  static Future<bool> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Delete file safely
  static Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Copy file to new location
  static Future<String?> copyFile(
    String sourcePath,
    String destinationPath,
  ) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) return null;

      final copiedFile = await sourceFile.copy(destinationPath);
      return copiedFile.path;
    } catch (e) {
      return null;
    }
  }

  /// Get directory size
  static Future<int> getDirectorySize(String directoryPath) async {
    try {
      final directory = Directory(directoryPath);
      if (!await directory.exists()) return 0;

      int totalSize = 0;
      await for (final entity in directory.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is File) {
          try {
            totalSize += await entity.length();
          } catch (e) {
            // Skip files that can't be read
          }
        }
      }

      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// Clean up old files in directory
  static Future<int> cleanupOldFiles(
    String directoryPath,
    Duration maxAge,
  ) async {
    try {
      final directory = Directory(directoryPath);
      if (!await directory.exists()) return 0;

      final cutoffDate = DateTime.now().subtract(maxAge);
      int deletedCount = 0;

      await for (final entity in directory.list()) {
        if (entity is File) {
          try {
            final stat = await entity.stat();
            if (stat.modified.isBefore(cutoffDate)) {
              await entity.delete();
              deletedCount++;
            }
          } catch (e) {
            // Skip files that can't be processed
          }
        }
      }

      return deletedCount;
    } catch (e) {
      return 0;
    }
  }

  /// Validate file extension
  static bool hasValidExtension(
    String filePath,
    List<String> allowedExtensions,
  ) {
    final extension = getFileExtension(filePath);
    return allowedExtensions.any(
      (allowed) => allowed.toLowerCase() == extension,
    );
  }

  /// Get human-readable file type
  static String getReadableFileType(String filePath) {
    final extension = getFileExtension(filePath);

    if ([
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.bmp',
      '.webp',
    ].contains(extension)) {
      return 'Image';
    } else if (['.pdf'].contains(extension)) {
      return 'PDF Document';
    } else if (['.doc', '.docx'].contains(extension)) {
      return 'Word Document';
    } else if (['.txt'].contains(extension)) {
      return 'Text File';
    } else if (['.rtf'].contains(extension)) {
      return 'Rich Text';
    } else if (['.mp3', '.wav', '.aac', '.m4a'].contains(extension)) {
      return 'Audio File';
    } else if (['.mp4', '.avi', '.mov', '.wmv'].contains(extension)) {
      return 'Video File';
    } else {
      return 'File';
    }
  }
}
