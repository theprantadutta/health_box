import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:drift/drift.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/attachment_dao.dart';
import '../utils/file_utils.dart';

class AttachmentService {
  final AttachmentDao _attachmentDao;
  final ImagePicker _imagePicker;

  AttachmentService({
    AttachmentDao? attachmentDao,
    AppDatabase? database,
  })  : _attachmentDao = attachmentDao ?? AttachmentDao(database ?? AppDatabase.instance),
        _imagePicker = ImagePicker();

  // File Selection Operations

  /// Pick a single image from gallery or camera
  Future<AttachmentResult?> pickImage({
    ImageSource source = ImageSource.gallery,
    int? maxWidth,
    int? maxHeight,
    int? imageQuality,
  }) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: maxWidth?.toDouble(),
        maxHeight: maxHeight?.toDouble(),
        imageQuality: imageQuality,
      );

      if (pickedFile == null) return null;

      final file = File(pickedFile.path);
      return await _processPickedFile(file, 'image');
    } catch (e) {
      throw AttachmentServiceException('Failed to pick image: ${e.toString()}');
    }
  }

  /// Pick multiple images from gallery
  Future<List<AttachmentResult>> pickMultipleImages({
    int? maxWidth,
    int? maxHeight,
    int? imageQuality,
  }) async {
    try {
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
        maxWidth: maxWidth?.toDouble(),
        maxHeight: maxHeight?.toDouble(),
        imageQuality: imageQuality,
      );

      final results = <AttachmentResult>[];
      for (final pickedFile in pickedFiles) {
        final file = File(pickedFile.path);
        final result = await _processPickedFile(file, 'image');
        results.add(result);
      }

      return results;
    } catch (e) {
      throw AttachmentServiceException('Failed to pick multiple images: ${e.toString()}');
    }
  }

  /// Pick a file using file picker
  Future<AttachmentResult?> pickFile({
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    bool allowMultiple = false,
  }) async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        allowMultiple: allowMultiple,
      );

      if (result == null || result.files.isEmpty) return null;

      final platformFile = result.files.first;
      final file = File(platformFile.path!);
      
      final fileType = _determineFileType(platformFile.extension, file.path);
      return await _processPickedFile(file, fileType);
    } catch (e) {
      throw AttachmentServiceException('Failed to pick file: ${e.toString()}');
    }
  }

  /// Pick multiple files using file picker
  Future<List<AttachmentResult>> pickMultipleFiles({
    FileType type = FileType.any,
    List<String>? allowedExtensions,
  }) async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) return [];

      final results = <AttachmentResult>[];
      for (final platformFile in result.files) {
        if (platformFile.path != null) {
          final file = File(platformFile.path!);
          final fileType = _determineFileType(platformFile.extension, file.path);
          final attachmentResult = await _processPickedFile(file, fileType);
          results.add(attachmentResult);
        }
      }

      return results;
    } catch (e) {
      throw AttachmentServiceException('Failed to pick multiple files: ${e.toString()}');
    }
  }

  // Database Operations

  /// Save attachment to database and secure storage
  Future<String> saveAttachment(
    AttachmentResult attachmentResult,
    String recordId, {
    String? description,
  }) async {
    try {
      // Copy file to secure app directory
      final secureFilePath = await _saveFileSecurely(attachmentResult.file);
      
      final attachmentId = 'attachment_${DateTime.now().millisecondsSinceEpoch}';
      final attachmentCompanion = AttachmentsCompanion(
        id: Value(attachmentId),
        recordId: Value(recordId),
        fileName: Value(attachmentResult.fileName),
        filePath: Value(secureFilePath),
        fileSize: Value(attachmentResult.fileSize),
        fileType: Value(attachmentResult.fileType),
        mimeType: Value(attachmentResult.mimeType),
        description: Value(description),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        isActive: const Value(true),
      );

      return await _attachmentDao.createAttachment(attachmentCompanion);
    } catch (e) {
      throw AttachmentServiceException('Failed to save attachment: ${e.toString()}');
    }
  }

  /// Get all attachments for a medical record
  Future<List<Attachment>> getAttachmentsForRecord(String recordId) async {
    try {
      return await _attachmentDao.getAttachmentsByRecordId(recordId);
    } catch (e) {
      throw AttachmentServiceException('Failed to get attachments for record: ${e.toString()}');
    }
  }

  /// Get attachment by ID
  Future<Attachment?> getAttachmentById(String attachmentId) async {
    try {
      return await _attachmentDao.getAttachmentById(attachmentId);
    } catch (e) {
      throw AttachmentServiceException('Failed to get attachment: ${e.toString()}');
    }
  }

  /// Delete attachment from database and storage
  Future<bool> deleteAttachment(String attachmentId) async {
    try {
      final attachment = await _attachmentDao.getAttachmentById(attachmentId);
      if (attachment == null) {
        throw const AttachmentServiceException('Attachment not found');
      }

      // Delete physical file
      final file = File(attachment.filePath);
      if (await file.exists()) {
        await file.delete();
      }

      // Delete from database
      return await _attachmentDao.deleteAttachment(attachmentId);
    } catch (e) {
      if (e is AttachmentServiceException) rethrow;
      throw AttachmentServiceException('Failed to delete attachment: ${e.toString()}');
    }
  }

  /// Update attachment description
  Future<bool> updateAttachmentDescription(String attachmentId, String? description) async {
    try {
      final attachmentCompanion = AttachmentsCompanion(
        description: Value(description),
        updatedAt: Value(DateTime.now()),
      );

      return await _attachmentDao.updateAttachment(attachmentId, attachmentCompanion);
    } catch (e) {
      throw AttachmentServiceException('Failed to update attachment description: ${e.toString()}');
    }
  }

  // File Management Operations

  /// Get file from attachment
  Future<File> getAttachmentFile(Attachment attachment) async {
    try {
      final file = File(attachment.filePath);
      if (!await file.exists()) {
        throw const AttachmentServiceException('Attachment file not found on disk');
      }
      return file;
    } catch (e) {
      if (e is AttachmentServiceException) rethrow;
      throw AttachmentServiceException('Failed to get attachment file: ${e.toString()}');
    }
  }

  /// Get file as bytes
  Future<Uint8List> getAttachmentBytes(Attachment attachment) async {
    try {
      final file = await getAttachmentFile(attachment);
      return await file.readAsBytes();
    } catch (e) {
      if (e is AttachmentServiceException) rethrow;
      throw AttachmentServiceException('Failed to read attachment bytes: ${e.toString()}');
    }
  }

  /// Get total storage size for all attachments
  Future<int> getTotalAttachmentSize() async {
    try {
      final attachments = await _attachmentDao.getAllAttachments();
      return attachments.fold<int>(0, (sum, attachment) => sum + attachment.fileSize);
    } catch (e) {
      throw AttachmentServiceException('Failed to calculate total attachment size: ${e.toString()}');
    }
  }

  /// Get storage statistics
  Future<AttachmentStorageStats> getStorageStatistics() async {
    try {
      final allAttachments = await _attachmentDao.getAllAttachments();
      final imageAttachments = await _attachmentDao.getImageAttachments();
      final pdfAttachments = await _attachmentDao.getPdfAttachments();
      final documentAttachments = await _attachmentDao.getDocumentAttachments();

      final totalSize = allAttachments.fold<int>(0, (sum, attachment) => sum + attachment.fileSize);
      final imageSize = imageAttachments.fold<int>(0, (sum, attachment) => sum + attachment.fileSize);
      final pdfSize = pdfAttachments.fold<int>(0, (sum, attachment) => sum + attachment.fileSize);
      final documentSize = documentAttachments.fold<int>(0, (sum, attachment) => sum + attachment.fileSize);

      return AttachmentStorageStats(
        totalFiles: allAttachments.length,
        totalSize: totalSize,
        imageFiles: imageAttachments.length,
        imageSize: imageSize,
        pdfFiles: pdfAttachments.length,
        pdfSize: pdfSize,
        documentFiles: documentAttachments.length,
        documentSize: documentSize,
      );
    } catch (e) {
      throw AttachmentServiceException('Failed to get storage statistics: ${e.toString()}');
    }
  }

  // Private Helper Methods

  Future<AttachmentResult> _processPickedFile(File file, String fileType) async {
    final fileName = path.basename(file.path);
    final fileSize = await file.length();
    final mimeType = FileUtils.getMimeType(file.path);

    return AttachmentResult(
      file: file,
      fileName: fileName,
      fileSize: fileSize,
      fileType: fileType,
      mimeType: mimeType,
    );
  }

  String _determineFileType(String? extension, String filePath) {
    if (extension == null) return 'unknown';
    
    final ext = extension.toLowerCase();
    
    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext)) {
      return 'image';
    } else if (['pdf'].contains(ext)) {
      return 'pdf';
    } else if (['doc', 'docx', 'txt', 'rtf'].contains(ext)) {
      return 'document';
    } else if (['mp4', 'avi', 'mov', 'wmv'].contains(ext)) {
      return 'video';
    } else if (['mp3', 'wav', 'aac', 'm4a'].contains(ext)) {
      return 'audio';
    } else {
      return 'other';
    }
  }

  Future<String> _saveFileSecurely(File sourceFile) async {
    try {
      final appDocumentsDir = await getApplicationDocumentsDirectory();
      final attachmentsDir = Directory(path.join(appDocumentsDir.path, 'attachments'));
      
      if (!await attachmentsDir.exists()) {
        await attachmentsDir.create(recursive: true);
      }

      final fileName = path.basename(sourceFile.path);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final secureFileName = '${timestamp}_$fileName';
      final secureFilePath = path.join(attachmentsDir.path, secureFileName);

      await sourceFile.copy(secureFilePath);
      return secureFilePath;
    } catch (e) {
      throw AttachmentServiceException('Failed to save file securely: ${e.toString()}');
    }
  }

  // Stream Operations
  
  Stream<List<Attachment>> watchAttachmentsForRecord(String recordId) {
    return _attachmentDao.watchAttachmentsByRecordId(recordId);
  }

  Stream<List<Attachment>> watchAllAttachments() {
    return _attachmentDao.watchAllAttachments();
  }

  // Validation Methods

  bool isValidFileSize(int fileSize, {int maxSizeMB = 50}) {
    final maxSizeBytes = maxSizeMB * 1024 * 1024;
    return fileSize <= maxSizeBytes;
  }

  bool isValidFileType(String fileType, {List<String>? allowedTypes}) {
    if (allowedTypes == null) return true;
    return allowedTypes.contains(fileType.toLowerCase());
  }

  bool isValidImageType(String extension) {
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension.toLowerCase());
  }

  bool isValidDocumentType(String extension) {
    return ['pdf', 'doc', 'docx', 'txt', 'rtf'].contains(extension.toLowerCase());
  }
}

// Data Transfer Objects

class AttachmentResult {
  final File file;
  final String fileName;
  final int fileSize;
  final String fileType;
  final String mimeType;

  AttachmentResult({
    required this.file,
    required this.fileName,
    required this.fileSize,
    required this.fileType,
    required this.mimeType,
  });
}

class AttachmentStorageStats {
  final int totalFiles;
  final int totalSize;
  final int imageFiles;
  final int imageSize;
  final int pdfFiles;
  final int pdfSize;
  final int documentFiles;
  final int documentSize;

  AttachmentStorageStats({
    required this.totalFiles,
    required this.totalSize,
    required this.imageFiles,
    required this.imageSize,
    required this.pdfFiles,
    required this.pdfSize,
    required this.documentFiles,
    required this.documentSize,
  });

  String get formattedTotalSize => FileUtils.formatFileSize(totalSize);
  String get formattedImageSize => FileUtils.formatFileSize(imageSize);
  String get formattedPdfSize => FileUtils.formatFileSize(pdfSize);
  String get formattedDocumentSize => FileUtils.formatFileSize(documentSize);
}

// Exceptions

class AttachmentServiceException implements Exception {
  final String message;
  
  const AttachmentServiceException(this.message);
  
  @override
  String toString() => 'AttachmentServiceException: $message';
}