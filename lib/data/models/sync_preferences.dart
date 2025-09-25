import 'package:drift/drift.dart';

/// File sync preferences table for storing user's sync configuration
class SyncPreferences extends Table {
  TextColumn get id => text().named('id')();
  BoolColumn get fileUploadEnabled => boolean().withDefault(const Constant(true)).named('file_upload_enabled')();
  BoolColumn get syncImages => boolean().withDefault(const Constant(true)).named('sync_images')();
  BoolColumn get syncPdfs => boolean().withDefault(const Constant(true)).named('sync_pdfs')();
  BoolColumn get syncDocuments => boolean().withDefault(const Constant(true)).named('sync_documents')();
  IntColumn get maxFileSizeMb => integer().withDefault(const Constant(50)).named('max_file_size_mb')();
  BoolColumn get wifiOnlyUpload => boolean().withDefault(const Constant(true)).named('wifi_only_upload')();
  BoolColumn get autoUpload => boolean().withDefault(const Constant(true)).named('auto_upload')();
  IntColumn get maxUploadRetries => integer().withDefault(const Constant(3)).named('max_upload_retries')();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime).named('created_at')();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime).named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}

/// Upload queue table for managing background file uploads
class UploadQueue extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get attachmentId => text().named('attachment_id')();
  TextColumn get filePath => text().named('file_path')();
  TextColumn get fileName => text().named('file_name')();
  IntColumn get fileSize => integer().named('file_size')();
  TextColumn get mimeType => text().named('mime_type')();
  IntColumn get priority => integer().withDefault(const Constant(0)).named('priority')(); // 0=normal, 1=high, 2=urgent
  TextColumn get status => text().withDefault(const Constant('pending')).named('status')(); // pending, uploading, completed, failed, paused
  IntColumn get retryCount => integer().withDefault(const Constant(0)).named('retry_count')();
  IntColumn get progressPercent => integer().withDefault(const Constant(0)).named('progress_percent')();
  TextColumn get errorMessage => text().nullable().named('error_message')();
  TextColumn get driveFileId => text().nullable().named('drive_file_id')();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime).named('created_at')();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime).named('updated_at')();
  DateTimeColumn get scheduledAt => dateTime().nullable().named('scheduled_at')();
  DateTimeColumn get completedAt => dateTime().nullable().named('completed_at')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (attachment_id) REFERENCES attachments (id) ON DELETE CASCADE',
  ];
}

/// File sync status enumeration
enum FileSyncStatus {
  notSynced('not_synced'),
  pending('pending'),
  uploading('uploading'),
  synced('synced'),
  failed('failed'),
  paused('paused');

  const FileSyncStatus(this.value);
  final String value;

  static FileSyncStatus fromString(String value) {
    return FileSyncStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => FileSyncStatus.notSynced,
    );
  }
}

/// Upload priority enumeration
enum UploadPriority {
  normal(0),
  high(1),
  urgent(2);

  const UploadPriority(this.value);
  final int value;

  static UploadPriority fromInt(int value) {
    return UploadPriority.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => UploadPriority.normal,
    );
  }
}

/// File type filter for selective sync
enum FileTypeFilter {
  images(['jpg', 'jpeg', 'png', 'gif', 'webp'], 'Images'),
  pdfs(['pdf'], 'PDFs'),
  documents(['doc', 'docx', 'txt', 'rtf'], 'Documents');

  const FileTypeFilter(this.extensions, this.displayName);
  final List<String> extensions;
  final String displayName;

  static FileTypeFilter? fromExtension(String extension) {
    final ext = extension.toLowerCase();
    for (final filter in FileTypeFilter.values) {
      if (filter.extensions.contains(ext)) {
        return filter;
      }
    }
    return null;
  }
}

/// Sync preferences data model
class SyncPreferencesData {
  final String id;
  final bool fileUploadEnabled;
  final bool syncImages;
  final bool syncPdfs;
  final bool syncDocuments;
  final int maxFileSizeMb;
  final bool wifiOnlyUpload;
  final bool autoUpload;
  final int maxUploadRetries;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SyncPreferencesData({
    required this.id,
    required this.fileUploadEnabled,
    required this.syncImages,
    required this.syncPdfs,
    required this.syncDocuments,
    required this.maxFileSizeMb,
    required this.wifiOnlyUpload,
    required this.autoUpload,
    required this.maxUploadRetries,
    required this.createdAt,
    required this.updatedAt,
  });

  SyncPreferencesData copyWith({
    String? id,
    bool? fileUploadEnabled,
    bool? syncImages,
    bool? syncPdfs,
    bool? syncDocuments,
    int? maxFileSizeMb,
    bool? wifiOnlyUpload,
    bool? autoUpload,
    int? maxUploadRetries,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SyncPreferencesData(
      id: id ?? this.id,
      fileUploadEnabled: fileUploadEnabled ?? this.fileUploadEnabled,
      syncImages: syncImages ?? this.syncImages,
      syncPdfs: syncPdfs ?? this.syncPdfs,
      syncDocuments: syncDocuments ?? this.syncDocuments,
      maxFileSizeMb: maxFileSizeMb ?? this.maxFileSizeMb,
      wifiOnlyUpload: wifiOnlyUpload ?? this.wifiOnlyUpload,
      autoUpload: autoUpload ?? this.autoUpload,
      maxUploadRetries: maxUploadRetries ?? this.maxUploadRetries,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if a file type should be synced based on preferences
  bool shouldSyncFileType(String fileExtension) {
    if (!fileUploadEnabled) return false;

    final fileType = FileTypeFilter.fromExtension(fileExtension);
    switch (fileType) {
      case FileTypeFilter.images:
        return syncImages;
      case FileTypeFilter.pdfs:
        return syncPdfs;
      case FileTypeFilter.documents:
        return syncDocuments;
      case null:
        return false; // Unknown file types are not synced
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fileUploadEnabled': fileUploadEnabled,
    'syncImages': syncImages,
    'syncPdfs': syncPdfs,
    'syncDocuments': syncDocuments,
    'maxFileSizeMb': maxFileSizeMb,
    'wifiOnlyUpload': wifiOnlyUpload,
    'autoUpload': autoUpload,
    'maxUploadRetries': maxUploadRetries,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}

/// Upload task data model
class UploadTaskData {
  final String id;
  final String attachmentId;
  final String filePath;
  final String fileName;
  final int fileSize;
  final String mimeType;
  final UploadPriority priority;
  final FileSyncStatus status;
  final int retryCount;
  final int progressPercent;
  final String? errorMessage;
  final String? driveFileId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? scheduledAt;
  final DateTime? completedAt;

  const UploadTaskData({
    required this.id,
    required this.attachmentId,
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    required this.mimeType,
    required this.priority,
    required this.status,
    required this.retryCount,
    required this.progressPercent,
    this.errorMessage,
    this.driveFileId,
    required this.createdAt,
    required this.updatedAt,
    this.scheduledAt,
    this.completedAt,
  });

  UploadTaskData copyWith({
    String? id,
    String? attachmentId,
    String? filePath,
    String? fileName,
    int? fileSize,
    String? mimeType,
    UploadPriority? priority,
    FileSyncStatus? status,
    int? retryCount,
    int? progressPercent,
    String? errorMessage,
    String? driveFileId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? scheduledAt,
    DateTime? completedAt,
  }) {
    return UploadTaskData(
      id: id ?? this.id,
      attachmentId: attachmentId ?? this.attachmentId,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      progressPercent: progressPercent ?? this.progressPercent,
      errorMessage: errorMessage ?? this.errorMessage,
      driveFileId: driveFileId ?? this.driveFileId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  bool get isCompleted => status == FileSyncStatus.synced;
  bool get isFailed => status == FileSyncStatus.failed;
  bool get isInProgress => status == FileSyncStatus.uploading;
  bool get canRetry => isFailed && retryCount < 3;

  Map<String, dynamic> toJson() => {
    'id': id,
    'attachmentId': attachmentId,
    'filePath': filePath,
    'fileName': fileName,
    'fileSize': fileSize,
    'mimeType': mimeType,
    'priority': priority.value,
    'status': status.value,
    'retryCount': retryCount,
    'progressPercent': progressPercent,
    'errorMessage': errorMessage,
    'driveFileId': driveFileId,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'scheduledAt': scheduledAt?.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
  };
}