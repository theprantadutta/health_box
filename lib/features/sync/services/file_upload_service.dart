import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../../../data/database/app_database.dart';
import '../../../data/models/sync_preferences.dart';
import '../../../data/repositories/attachment_dao.dart';
import 'file_sync_preferences_service.dart';
import '../../../services/google_drive_service.dart';

class FileUploadService {

  final AppDatabase _database;
  final AttachmentDao _attachmentDao;
  final GoogleDriveService _driveService;
  final FileSyncPreferencesService _preferencesService;
  final Logger _logger = Logger();
  final Uuid _uuid = Uuid();

  // Upload state management
  final Map<String, StreamController<UploadProgressUpdate>> _progressControllers = {};
  final Set<String> _activeUploads = {};
  Timer? _queueProcessor;
  bool _isProcessingQueue = false;

  FileUploadService({
    AppDatabase? database,
    AttachmentDao? attachmentDao,
    GoogleDriveService? driveService,
    FileSyncPreferencesService? preferencesService,
  }) : _database = database ?? AppDatabase.instance,
        _attachmentDao = attachmentDao ?? AttachmentDao(database ?? AppDatabase.instance),
        _driveService = driveService ?? GoogleDriveService(),
        _preferencesService = preferencesService ?? FileSyncPreferencesService() {
    _startQueueProcessor();
  }

  // Add file to upload queue
  Future<String> queueFileUpload({
    required String attachmentId,
    required String filePath,
    UploadPriority priority = UploadPriority.normal,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw FileUploadException('File does not exist: $filePath');
      }

      final fileSize = await file.length();
      final fileName = path.basename(filePath);
      final mimeType = _getMimeType(fileName);

      // Check if file should be uploaded based on preferences
      final shouldUpload = await _shouldUploadFile(fileName, fileSize);
      if (!shouldUpload) {
        throw FileUploadException('File type or size not allowed for upload');
      }

      final taskId = _uuid.v4();

      // Insert into upload queue
      final companion = UploadQueueCompanion.insert(
        id: taskId,
        attachmentId: attachmentId,
        filePath: filePath,
        fileName: fileName,
        fileSize: fileSize,
        mimeType: mimeType,
        priority: Value(priority.value),
        status: const Value('pending'),
        scheduledAt: Value(DateTime.now()),
      );

      await _database.into(_database.uploadQueue).insert(companion);

      _logger.d('Queued file upload: $fileName (ID: $taskId)');
      return taskId;
    } catch (e) {
      _logger.e('Failed to queue file upload: $e');
      throw FileUploadException('Failed to queue file upload: ${e.toString()}');
    }
  }

  // Get upload progress stream
  Stream<UploadProgressUpdate> getUploadProgress(String taskId) {
    _progressControllers[taskId] ??= StreamController<UploadProgressUpdate>.broadcast();
    return _progressControllers[taskId]!.stream;
  }

  // Cancel upload
  Future<void> cancelUpload(String taskId) async {
    try {
      // Update status in database
      await (_database.update(_database.uploadQueue)
        ..where((u) => u.id.equals(taskId)))
        .write(UploadQueueCompanion(
          status: const Value('cancelled'),
          updatedAt: Value(DateTime.now()),
        ));

      // Remove from active uploads
      _activeUploads.remove(taskId);

      // Close progress stream
      _progressControllers[taskId]?.close();
      _progressControllers.remove(taskId);

      _logger.d('Cancelled upload: $taskId');
    } catch (e) {
      _logger.e('Failed to cancel upload: $e');
      throw FileUploadException('Failed to cancel upload: ${e.toString()}');
    }
  }

  // Pause upload
  Future<void> pauseUpload(String taskId) async {
    try {
      await (_database.update(_database.uploadQueue)
        ..where((u) => u.id.equals(taskId)))
        .write(UploadQueueCompanion(
          status: const Value('paused'),
          updatedAt: Value(DateTime.now()),
        ));

      _activeUploads.remove(taskId);
      _logger.d('Paused upload: $taskId');
    } catch (e) {
      _logger.e('Failed to pause upload: $e');
      throw FileUploadException('Failed to pause upload: ${e.toString()}');
    }
  }

  // Resume upload
  Future<void> resumeUpload(String taskId) async {
    try {
      await (_database.update(_database.uploadQueue)
        ..where((u) => u.id.equals(taskId)))
        .write(UploadQueueCompanion(
          status: const Value('pending'),
          scheduledAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ));

      _logger.d('Resumed upload: $taskId');
    } catch (e) {
      _logger.e('Failed to resume upload: $e');
      throw FileUploadException('Failed to resume upload: ${e.toString()}');
    }
  }

  // Retry failed upload
  Future<void> retryUpload(String taskId) async {
    try {
      final task = await (_database.select(_database.uploadQueue)
        ..where((u) => u.id.equals(taskId))).getSingleOrNull();

      if (task == null) {
        throw FileUploadException('Upload task not found');
      }

      final maxRetries = await _preferencesService.getMaxRetryCount();
      if (task.retryCount >= maxRetries) {
        throw FileUploadException('Maximum retry attempts exceeded');
      }

      await (_database.update(_database.uploadQueue)
        ..where((u) => u.id.equals(taskId)))
        .write(UploadQueueCompanion(
          status: const Value('pending'),
          retryCount: Value(task.retryCount + 1),
          progressPercent: const Value(0),
          errorMessage: const Value.absent(),
          scheduledAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ));

      _logger.d('Retrying upload: $taskId (attempt ${task.retryCount + 1})');
    } catch (e) {
      _logger.e('Failed to retry upload: $e');
      throw FileUploadException('Failed to retry upload: ${e.toString()}');
    }
  }

  // Get pending uploads
  Future<List<UploadTaskData>> getPendingUploads() async {
    try {
      final tasks = await (_database.select(_database.uploadQueue)
        ..where((u) => u.status.equals('pending'))
        ..orderBy([(u) => OrderingTerm(expression: u.priority, mode: OrderingMode.desc)])
        ..orderBy([(u) => OrderingTerm(expression: u.createdAt)]))
        .get();

      return tasks.map(_mapToTaskData).toList();
    } catch (e) {
      _logger.e('Failed to get pending uploads: $e');
      return [];
    }
  }

  // Get all upload tasks with optional status filter
  Future<List<UploadTaskData>> getUploadTasks({FileSyncStatus? status}) async {
    try {
      var query = _database.select(_database.uploadQueue)
        ..orderBy([(u) => OrderingTerm(expression: u.updatedAt, mode: OrderingMode.desc)]);

      if (status != null) {
        query = query..where((u) => u.status.equals(status.value));
      }

      final tasks = await query.get();
      return tasks.map(_mapToTaskData).toList();
    } catch (e) {
      _logger.e('Failed to get upload tasks: $e');
      return [];
    }
  }

  // Clear completed uploads
  Future<void> clearCompletedUploads() async {
    try {
      await (_database.delete(_database.uploadQueue)
        ..where((u) => u.status.equals('completed'))).go();
      _logger.d('Cleared completed uploads');
    } catch (e) {
      _logger.e('Failed to clear completed uploads: $e');
      throw FileUploadException('Failed to clear completed uploads: ${e.toString()}');
    }
  }

  // Clean failed uploads older than specified duration
  Future<void> cleanFailedUploads({Duration olderThan = const Duration(days: 7)}) async {
    try {
      final cutoffDate = DateTime.now().subtract(olderThan);
      await (_database.delete(_database.uploadQueue)
        ..where((u) =>
          u.status.equals('failed') &
          u.updatedAt.isSmallerThanValue(cutoffDate))).go();
      _logger.d('Cleaned failed uploads older than $olderThan');
    } catch (e) {
      _logger.e('Failed to clean failed uploads: $e');
      throw FileUploadException('Failed to clean failed uploads: ${e.toString()}');
    }
  }

  // Watch upload queue changes
  Stream<List<UploadTaskData>> watchUploadQueue() {
    final query = _database.select(_database.uploadQueue)
      ..orderBy([(u) => OrderingTerm(expression: u.updatedAt, mode: OrderingMode.desc)]);
    return query.watch().map((tasks) => tasks.map(_mapToTaskData).toList());
  }

  // Get upload statistics
  Future<UploadStatistics> getUploadStatistics() async {
    try {
      // Count tasks by status
      final pending = await (_database.selectOnly(_database.uploadQueue)
        ..addColumns([_database.uploadQueue.id.count()])
        ..where(_database.uploadQueue.status.equals('pending')))
        .map((row) => row.read(_database.uploadQueue.id.count()) ?? 0)
        .getSingle();

      final completed = await (_database.selectOnly(_database.uploadQueue)
        ..addColumns([_database.uploadQueue.id.count()])
        ..where(_database.uploadQueue.status.equals('completed')))
        .map((row) => row.read(_database.uploadQueue.id.count()) ?? 0)
        .getSingle();

      final failed = await (_database.selectOnly(_database.uploadQueue)
        ..addColumns([_database.uploadQueue.id.count()])
        ..where(_database.uploadQueue.status.equals('failed')))
        .map((row) => row.read(_database.uploadQueue.id.count()) ?? 0)
        .getSingle();

      final uploading = await (_database.selectOnly(_database.uploadQueue)
        ..addColumns([_database.uploadQueue.id.count()])
        ..where(_database.uploadQueue.status.equals('uploading')))
        .map((row) => row.read(_database.uploadQueue.id.count()) ?? 0)
        .getSingle();

      // Calculate total size
      final totalSize = await (_database.selectOnly(_database.uploadQueue)
        ..addColumns([_database.uploadQueue.fileSize.sum()]))
        .map((row) => row.read(_database.uploadQueue.fileSize.sum()) ?? 0)
        .getSingle();

      return UploadStatistics(
        pendingCount: pending,
        completedCount: completed,
        failedCount: failed,
        uploadingCount: uploading,
        totalSizeBytes: totalSize,
        activeUploads: _activeUploads.length,
      );
    } catch (e) {
      _logger.e('Failed to get upload statistics: $e');
      return const UploadStatistics(
        pendingCount: 0,
        completedCount: 0,
        failedCount: 0,
        uploadingCount: 0,
        totalSizeBytes: 0,
        activeUploads: 0,
      );
    }
  }

  // Dispose resources
  void dispose() {
    _queueProcessor?.cancel();
    for (final controller in _progressControllers.values) {
      controller.close();
    }
    _progressControllers.clear();
    _activeUploads.clear();
    _logger.d('FileUploadService disposed');
  }

  // Private methods

  void _startQueueProcessor() {
    _queueProcessor = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!_isProcessingQueue) {
        _processUploadQueue();
      }
    });
    _logger.d('Started upload queue processor');
  }

  Future<void> _processUploadQueue() async {
    if (_isProcessingQueue) return;

    _isProcessingQueue = true;
    try {
      // Check connectivity and preferences
      final connectivityResult = await Connectivity().checkConnectivity();
      final wifiOnly = await _preferencesService.shouldUploadOnWiFiOnly();
      final autoUpload = await _preferencesService.isAutoUploadEnabled();

      if (!autoUpload) return;

      // Check if we should upload based on connectivity
      bool shouldUpload = false;
      if (wifiOnly) {
        shouldUpload = connectivityResult == ConnectivityResult.wifi;
      } else {
        shouldUpload = connectivityResult != ConnectivityResult.none;
      }

      if (!shouldUpload) {
        _logger.d('Skipping upload due to connectivity constraints');
        return;
      }

      // Get pending uploads
      final pendingUploads = await getPendingUploads();
      const maxConcurrentUploads = 2;
      final availableSlots = maxConcurrentUploads - _activeUploads.length;

      if (availableSlots <= 0) return;

      // Start uploads for available slots
      final uploadsToStart = pendingUploads.take(availableSlots);
      for (final upload in uploadsToStart) {
        _startUpload(upload);
      }
    } catch (e) {
      _logger.e('Error processing upload queue: $e');
    } finally {
      _isProcessingQueue = false;
    }
  }

  Future<void> _startUpload(UploadTaskData task) async {
    if (_activeUploads.contains(task.id)) return;

    _activeUploads.add(task.id);

    try {
      // Update status to uploading
      await (_database.update(_database.uploadQueue)
        ..where((u) => u.id.equals(task.id)))
        .write(UploadQueueCompanion(
          status: const Value('uploading'),
          updatedAt: Value(DateTime.now()),
        ));

      await _performUpload(task);
    } catch (e) {
      _logger.e('Upload failed for ${task.fileName}: $e');
      await _markUploadFailed(task.id, e.toString());
    } finally {
      _activeUploads.remove(task.id);
    }
  }

  Future<void> _performUpload(UploadTaskData task) async {
    _logger.d('Starting upload: ${task.fileName}');

    try {
      // Ensure signed in to Google Drive
      if (!_driveService.isSignedIn) {
        throw FileUploadException('Not signed in to Google Drive');
      }

      final file = File(task.filePath);
      if (!await file.exists()) {
        throw FileUploadException('File not found: ${task.filePath}');
      }

      // Get the record type for proper folder organization
      final recordType = await _attachmentDao.getRecordTypeForAttachment(task.attachmentId)
          ?? 'general_record';

      // Upload file to Google Drive
      final driveFileId = await _uploadToGoogleDrive(
        file: file,
        fileName: task.fileName,
        mimeType: task.mimeType,
        recordType: recordType,
        onProgress: (progress) => _updateUploadProgress(task.id, progress),
      );

      // Mark as completed
      await (_database.update(_database.uploadQueue)
        ..where((u) => u.id.equals(task.id)))
        .write(UploadQueueCompanion(
          status: const Value('completed'),
          progressPercent: const Value(100),
          driveFileId: Value(driveFileId),
          completedAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ));

      // Update attachment sync status
      await _attachmentDao.markAsSynced(task.attachmentId, true);

      _updateUploadProgress(task.id, 100);
      _logger.d('Upload completed: ${task.fileName} to ${recordType} folder');

    } catch (e) {
      await _markUploadFailed(task.id, e.toString());
      rethrow;
    }
  }


  Future<String> _uploadToGoogleDrive({
    required File file,
    required String fileName,
    required String mimeType,
    required String recordType,
    required Function(int progress) onProgress,
  }) async {
    try {
      // Use the real GoogleDriveService to upload the file
      return await _driveService.uploadAttachment(
        filePath: file.path,
        fileName: fileName,
        mimeType: mimeType,
        recordType: recordType,
        onProgress: (progressPercent) {
          // Convert from 0.0-1.0 to 0-100
          final progressInt = (progressPercent * 100).round();
          onProgress(progressInt);
        },
      );
    } catch (e) {
      throw FileUploadException('Failed to upload to Google Drive: ${e.toString()}');
    }
  }

  void _updateUploadProgress(String taskId, int progress) {
    _progressControllers[taskId]?.add(UploadProgressUpdate(
      taskId: taskId,
      progress: progress,
      timestamp: DateTime.now(),
    ));
  }

  Future<void> _markUploadFailed(String taskId, String errorMessage) async {
    await (_database.update(_database.uploadQueue)
      ..where((u) => u.id.equals(taskId)))
      .write(UploadQueueCompanion(
        status: const Value('failed'),
        errorMessage: Value(errorMessage),
        updatedAt: Value(DateTime.now()),
      ));

    _updateUploadProgress(taskId, -1); // -1 indicates failure
  }

  Future<bool> _shouldUploadFile(String fileName, int fileSize) async {
    try {
      final preferences = await _preferencesService.getPreferences();
      return preferences.shouldSyncFileType(path.extension(fileName).substring(1)) &&
             await _preferencesService.isFileSizeAllowed(fileSize);
    } catch (e) {
      return false;
    }
  }

  String _getMimeType(String fileName) {
    final extension = path.extension(fileName).toLowerCase();
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
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
      default:
        return 'application/octet-stream';
    }
  }

  UploadTaskData _mapToTaskData(UploadQueueData task) {
    return UploadTaskData(
      id: task.id,
      attachmentId: task.attachmentId,
      filePath: task.filePath,
      fileName: task.fileName,
      fileSize: task.fileSize,
      mimeType: task.mimeType,
      priority: UploadPriority.fromInt(task.priority),
      status: FileSyncStatus.fromString(task.status),
      retryCount: task.retryCount,
      progressPercent: task.progressPercent,
      errorMessage: task.errorMessage,
      driveFileId: task.driveFileId,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
      scheduledAt: task.scheduledAt,
      completedAt: task.completedAt,
    );
  }
}

// Data classes

class UploadProgressUpdate {
  final String taskId;
  final int progress; // 0-100, -1 for error
  final DateTime timestamp;

  const UploadProgressUpdate({
    required this.taskId,
    required this.progress,
    required this.timestamp,
  });
}

class UploadStatistics {
  final int pendingCount;
  final int completedCount;
  final int failedCount;
  final int uploadingCount;
  final int totalSizeBytes;
  final int activeUploads;

  const UploadStatistics({
    required this.pendingCount,
    required this.completedCount,
    required this.failedCount,
    required this.uploadingCount,
    required this.totalSizeBytes,
    required this.activeUploads,
  });

  int get totalCount => pendingCount + completedCount + failedCount + uploadingCount;
  double get completionRate => totalCount > 0 ? completedCount / totalCount : 0.0;
  bool get hasActiveUploads => activeUploads > 0;
  bool get hasPendingUploads => pendingCount > 0;
  bool get hasFailedUploads => failedCount > 0;

  String get formattedTotalSize {
    if (totalSizeBytes < 1024) return '${totalSizeBytes}B';
    if (totalSizeBytes < 1024 * 1024) return '${(totalSizeBytes / 1024).toStringAsFixed(1)}KB';
    if (totalSizeBytes < 1024 * 1024 * 1024) return '${(totalSizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(totalSizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}

// Exception class
class FileUploadException implements Exception {
  final String message;

  const FileUploadException(this.message);

  @override
  String toString() => 'FileUploadException: $message';
}