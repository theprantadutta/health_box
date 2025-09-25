import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../data/models/sync_preferences.dart';
import '../services/file_upload_service.dart';

// Service provider
final fileUploadServiceProvider = Provider<FileUploadService>((ref) {
  return FileUploadService();
});

// Upload queue provider
final uploadQueueProvider = StreamProvider<List<UploadTaskData>>((ref) {
  final service = ref.read(fileUploadServiceProvider);
  return service.watchUploadQueue();
});

// Upload statistics provider
final uploadStatisticsProvider = FutureProvider<UploadStatistics>((ref) async {
  final service = ref.read(fileUploadServiceProvider);
  return await service.getUploadStatistics();
});

// Individual upload progress provider
final uploadProgressProvider = StreamProvider.family<int, String>((ref, taskId) {
  final service = ref.read(fileUploadServiceProvider);
  return service.getUploadProgress(taskId).map((update) => update.progress);
});

// Pending uploads count provider
final pendingUploadsCountProvider = Provider<int>((ref) {
  final queueAsync = ref.watch(uploadQueueProvider);
  return queueAsync.maybeWhen(
    data: (tasks) => tasks.where((task) => task.status == FileSyncStatus.pending).length,
    orElse: () => 0,
  );
});

// Active uploads count provider
final activeUploadsCountProvider = Provider<int>((ref) {
  final queueAsync = ref.watch(uploadQueueProvider);
  return queueAsync.maybeWhen(
    data: (tasks) => tasks.where((task) => task.status == FileSyncStatus.uploading).length,
    orElse: () => 0,
  );
});

// Failed uploads provider
final failedUploadsProvider = Provider<List<UploadTaskData>>((ref) {
  final queueAsync = ref.watch(uploadQueueProvider);
  return queueAsync.maybeWhen(
    data: (tasks) => tasks.where((task) => task.status == FileSyncStatus.failed).toList(),
    orElse: () => [],
  );
});

// Upload queue by status provider
final uploadsByStatusProvider = Provider.family<List<UploadTaskData>, FileSyncStatus>((ref, status) {
  final queueAsync = ref.watch(uploadQueueProvider);
  return queueAsync.maybeWhen(
    data: (tasks) => tasks.where((task) => task.status == status).toList(),
    orElse: () => [],
  );
});

// Upload manager provider for actions
final uploadManagerProvider = Provider<UploadManager>((ref) {
  return UploadManager(ref);
});

/// Upload manager for handling upload actions
class UploadManager {
  final Ref _ref;

  UploadManager(this._ref);

  FileUploadService get _service => _ref.read(fileUploadServiceProvider);

  /// Queue a new file for upload
  Future<String> queueUpload({
    required String attachmentId,
    required String filePath,
    UploadPriority priority = UploadPriority.normal,
  }) async {
    try {
      return await _service.queueFileUpload(
        attachmentId: attachmentId,
        filePath: filePath,
        priority: priority,
      );
    } catch (e) {
      throw UploadManagerException('Failed to queue upload: ${e.toString()}');
    }
  }

  /// Pause an upload
  Future<void> pauseUpload(String taskId) async {
    try {
      await _service.pauseUpload(taskId);
    } catch (e) {
      throw UploadManagerException('Failed to pause upload: ${e.toString()}');
    }
  }

  /// Resume a paused upload
  Future<void> resumeUpload(String taskId) async {
    try {
      await _service.resumeUpload(taskId);
    } catch (e) {
      throw UploadManagerException('Failed to resume upload: ${e.toString()}');
    }
  }

  /// Retry a failed upload
  Future<void> retryUpload(String taskId) async {
    try {
      await _service.retryUpload(taskId);
    } catch (e) {
      throw UploadManagerException('Failed to retry upload: ${e.toString()}');
    }
  }

  /// Cancel an upload
  Future<void> cancelUpload(String taskId) async {
    try {
      await _service.cancelUpload(taskId);
    } catch (e) {
      throw UploadManagerException('Failed to cancel upload: ${e.toString()}');
    }
  }

  /// Retry all failed uploads
  Future<void> retryAllFailedUploads() async {
    final failedUploads = _ref.read(failedUploadsProvider);
    final futures = <Future>[];

    for (final upload in failedUploads) {
      if (upload.canRetry) {
        futures.add(retryUpload(upload.id));
      }
    }

    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }

  /// Clear all completed uploads
  Future<void> clearCompletedUploads() async {
    try {
      await _service.clearCompletedUploads();
    } catch (e) {
      throw UploadManagerException('Failed to clear completed uploads: ${e.toString()}');
    }
  }

  /// Clean old failed uploads
  Future<void> cleanFailedUploads({Duration olderThan = const Duration(days: 7)}) async {
    try {
      await _service.cleanFailedUploads(olderThan: olderThan);
    } catch (e) {
      throw UploadManagerException('Failed to clean failed uploads: ${e.toString()}');
    }
  }

  /// Pause all active uploads
  Future<void> pauseAllUploads() async {
    final activeUploads = _ref.read(uploadsByStatusProvider(FileSyncStatus.uploading));
    final futures = <Future>[];

    for (final upload in activeUploads) {
      futures.add(pauseUpload(upload.id));
    }

    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }

  /// Resume all paused uploads
  Future<void> resumeAllUploads() async {
    final pausedUploads = _ref.read(uploadsByStatusProvider(FileSyncStatus.paused));
    final futures = <Future>[];

    for (final upload in pausedUploads) {
      futures.add(resumeUpload(upload.id));
    }

    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }
}

/// Upload manager actions state notifier
class UploadActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  UploadManager get _manager => _ref.read(uploadManagerProvider);

  UploadActionsNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> executeAction(Future<void> Function() action) async {
    state = const AsyncValue.loading();
    try {
      await action();
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> queueUpload({
    required String attachmentId,
    required String filePath,
    UploadPriority priority = UploadPriority.normal,
  }) async {
    await executeAction(() => _manager.queueUpload(
      attachmentId: attachmentId,
      filePath: filePath,
      priority: priority,
    ));
  }

  Future<void> pauseUpload(String taskId) async {
    await executeAction(() => _manager.pauseUpload(taskId));
  }

  Future<void> resumeUpload(String taskId) async {
    await executeAction(() => _manager.resumeUpload(taskId));
  }

  Future<void> retryUpload(String taskId) async {
    await executeAction(() => _manager.retryUpload(taskId));
  }

  Future<void> cancelUpload(String taskId) async {
    await executeAction(() => _manager.cancelUpload(taskId));
  }

  Future<void> retryAllFailedUploads() async {
    await executeAction(() => _manager.retryAllFailedUploads());
  }

  Future<void> clearCompletedUploads() async {
    await executeAction(() => _manager.clearCompletedUploads());
  }

  Future<void> cleanFailedUploads() async {
    await executeAction(() => _manager.cleanFailedUploads());
  }

  Future<void> pauseAllUploads() async {
    await executeAction(() => _manager.pauseAllUploads());
  }

  Future<void> resumeAllUploads() async {
    await executeAction(() => _manager.resumeAllUploads());
  }
}

final uploadActionsProvider = StateNotifierProvider<UploadActionsNotifier, AsyncValue<void>>((ref) {
  return UploadActionsNotifier(ref);
});

/// Helper providers for specific use cases

// Check if any uploads are in progress
final hasActiveUploadsProvider = Provider<bool>((ref) {
  final activeCount = ref.watch(activeUploadsCountProvider);
  return activeCount > 0;
});

// Check if there are any failed uploads
final hasFailedUploadsProvider = Provider<bool>((ref) {
  final failedUploads = ref.watch(failedUploadsProvider);
  return failedUploads.isNotEmpty;
});

// Get total upload progress as percentage
final totalUploadProgressProvider = Provider<double>((ref) {
  final statsAsync = ref.watch(uploadStatisticsProvider);
  return statsAsync.maybeWhen(
    data: (stats) => stats.completionRate,
    orElse: () => 0.0,
  );
});

// Get recent uploads (last 10)
final recentUploadsProvider = Provider<List<UploadTaskData>>((ref) {
  final queueAsync = ref.watch(uploadQueueProvider);
  return queueAsync.maybeWhen(
    data: (tasks) => tasks.take(10).toList(),
    orElse: () => [],
  );
});

// Get upload summary text
final uploadSummaryProvider = Provider<String>((ref) {
  final statsAsync = ref.watch(uploadStatisticsProvider);
  return statsAsync.maybeWhen(
    data: (stats) {
      if (stats.totalCount == 0) return 'No uploads';
      if (stats.hasActiveUploads) return 'Uploading ${stats.activeUploads} file${stats.activeUploads == 1 ? '' : 's'}...';
      if (stats.hasFailedUploads) return '${stats.failedCount} upload${stats.failedCount == 1 ? '' : 's'} failed';
      if (stats.hasPendingUploads) return '${stats.pendingCount} file${stats.pendingCount == 1 ? '' : 's'} pending';
      return 'All files uploaded';
    },
    orElse: () => 'Loading...',
  );
});

/// Exception class for upload manager operations
class UploadManagerException implements Exception {
  final String message;

  const UploadManagerException(this.message);

  @override
  String toString() => 'UploadManagerException: $message';
}