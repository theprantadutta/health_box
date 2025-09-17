import 'dart:io';
import 'package:drift/drift.dart';
import '../database/app_database.dart';

class AttachmentDao {
  final AppDatabase _database;

  AttachmentDao(this._database);

  Future<List<Attachment>> getAllAttachments() async {
    return await (_database.select(_database.attachments)..orderBy([
          (attachment) => OrderingTerm(
            expression: attachment.createdAt,
            mode: OrderingMode.desc,
          ),
        ]))
        .get();
  }

  Future<List<Attachment>> getAttachmentsByRecordId(String recordId) async {
    return await (_database.select(_database.attachments)
          ..where((attachment) => attachment.recordId.equals(recordId))
          ..orderBy([
            (attachment) => OrderingTerm(
              expression: attachment.createdAt,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  Future<List<Attachment>> getAttachmentsByFileType(String fileType) async {
    return await (_database.select(_database.attachments)
          ..where((attachment) => attachment.fileType.equals(fileType))
          ..orderBy([
            (attachment) => OrderingTerm(
              expression: attachment.createdAt,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  Future<List<Attachment>> getImageAttachments() async {
    return await getAttachmentsByFileType('image');
  }

  Future<List<Attachment>> getPdfAttachments() async {
    return await getAttachmentsByFileType('pdf');
  }

  Future<List<Attachment>> getDocumentAttachments() async {
    return await getAttachmentsByFileType('document');
  }

  Future<Attachment?> getAttachmentById(String id) async {
    return await (_database.select(
      _database.attachments,
    )..where((attachment) => attachment.id.equals(id))).getSingleOrNull();
  }

  Future<List<Attachment>> searchAttachments(String searchTerm) async {
    final searchPattern = '%${searchTerm.toLowerCase()}%';

    return await (_database.select(_database.attachments)
          ..where(
            (attachment) =>
                attachment.fileName.lower().like(searchPattern) |
                attachment.description.lower().like(searchPattern),
          )
          ..orderBy([
            (attachment) => OrderingTerm(
              expression: attachment.createdAt,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  Future<List<Attachment>> getAttachmentsByFileSizeRange(
    int minSize,
    int maxSize,
  ) async {
    return await (_database.select(_database.attachments)
          ..where(
            (attachment) =>
                attachment.fileSize.isBetweenValues(minSize, maxSize),
          )
          ..orderBy([
            (attachment) => OrderingTerm(
              expression: attachment.fileSize,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  Future<List<Attachment>> getLargeAttachments({
    int sizeThresholdMB = 10,
  }) async {
    final sizeThresholdBytes = sizeThresholdMB * 1024 * 1024;
    return await (_database.select(_database.attachments)
          ..where(
            (attachment) =>
                attachment.fileSize.isBiggerThanValue(sizeThresholdBytes),
          )
          ..orderBy([
            (attachment) => OrderingTerm(
              expression: attachment.fileSize,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  Future<List<Attachment>> getRecentAttachments({int limit = 10}) async {
    return await (_database.select(_database.attachments)
          ..orderBy([
            (attachment) => OrderingTerm(
              expression: attachment.createdAt,
              mode: OrderingMode.desc,
            ),
          ])
          ..limit(limit))
        .get();
  }

  Future<List<Attachment>> getUnsyncedAttachments() async {
    return await (_database.select(_database.attachments)
          ..where((attachment) => attachment.isSynced.equals(false))
          ..orderBy([
            (attachment) => OrderingTerm(
              expression: attachment.createdAt,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  Future<List<Attachment>> getSyncedAttachments() async {
    return await (_database.select(_database.attachments)
          ..where((attachment) => attachment.isSynced.equals(true))
          ..orderBy([
            (attachment) => OrderingTerm(
              expression: attachment.createdAt,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  Future<List<Attachment>> getAttachmentsCreatedInDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await (_database.select(_database.attachments)
          ..where(
            (attachment) =>
                attachment.createdAt.isBetweenValues(startDate, endDate),
          )
          ..orderBy([
            (attachment) => OrderingTerm(
              expression: attachment.createdAt,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  Future<String> createAttachment(AttachmentsCompanion attachment) async {
    await _database.into(_database.attachments).insert(attachment);
    return attachment.id.value;
  }

  Future<bool> updateAttachment(
    String id,
    AttachmentsCompanion attachment,
  ) async {
    final rowsAffected = await (_database.update(
      _database.attachments,
    )..where((a) => a.id.equals(id))).write(attachment);

    return rowsAffected > 0;
  }

  Future<bool> updateFileName(String id, String newFileName) async {
    final rowsAffected =
        await (_database.update(_database.attachments)
              ..where((a) => a.id.equals(id)))
            .write(AttachmentsCompanion(fileName: Value(newFileName)));

    return rowsAffected > 0;
  }

  Future<bool> updateFilePath(String id, String newFilePath) async {
    final rowsAffected =
        await (_database.update(_database.attachments)
              ..where((a) => a.id.equals(id)))
            .write(AttachmentsCompanion(filePath: Value(newFilePath)));

    return rowsAffected > 0;
  }

  Future<bool> updateDescription(String id, String? description) async {
    final rowsAffected =
        await (_database.update(_database.attachments)
              ..where((a) => a.id.equals(id)))
            .write(AttachmentsCompanion(description: Value(description)));

    return rowsAffected > 0;
  }

  Future<bool> markAsSynced(String id, bool isSynced) async {
    final rowsAffected =
        await (_database.update(_database.attachments)
              ..where((a) => a.id.equals(id)))
            .write(AttachmentsCompanion(isSynced: Value(isSynced)));

    return rowsAffected > 0;
  }

  Future<bool> deleteAttachment(String id, {bool deleteFile = false}) async {
    // Optionally delete the physical file
    if (deleteFile) {
      final attachment = await getAttachmentById(id);
      if (attachment != null) {
        await deletePhysicalFile(attachment.filePath);
      }
    }

    final rowsAffected = await (_database.delete(
      _database.attachments,
    )..where((a) => a.id.equals(id))).go();

    return rowsAffected > 0;
  }

  Future<int> deleteAttachmentsByRecordId(
    String recordId, {
    bool deleteFiles = false,
  }) async {
    // Optionally delete physical files
    if (deleteFiles) {
      final attachments = await getAttachmentsByRecordId(recordId);
      for (final attachment in attachments) {
        await deletePhysicalFile(attachment.filePath);
      }
    }

    return await (_database.delete(
      _database.attachments,
    )..where((a) => a.recordId.equals(recordId))).go();
  }

  Future<int> getAttachmentCount() async {
    final query = _database.selectOnly(_database.attachments)
      ..addColumns([_database.attachments.id.count()]);

    final result = await query.getSingle();
    return result.read(_database.attachments.id.count()) ?? 0;
  }

  Future<int> getAttachmentCountByRecordId(String recordId) async {
    final query = _database.selectOnly(_database.attachments)
      ..addColumns([_database.attachments.id.count()])
      ..where(_database.attachments.recordId.equals(recordId));

    final result = await query.getSingle();
    return result.read(_database.attachments.id.count()) ?? 0;
  }

  Future<int> getAttachmentCountByFileType(String fileType) async {
    final query = _database.selectOnly(_database.attachments)
      ..addColumns([_database.attachments.id.count()])
      ..where(_database.attachments.fileType.equals(fileType));

    final result = await query.getSingle();
    return result.read(_database.attachments.id.count()) ?? 0;
  }

  Future<Map<String, int>> getAttachmentCountsByFileType() async {
    final query = _database.selectOnly(_database.attachments)
      ..addColumns([
        _database.attachments.fileType,
        _database.attachments.id.count(),
      ])
      ..groupBy([_database.attachments.fileType]);

    final results = await query.get();
    final Map<String, int> counts = {};

    for (final result in results) {
      final fileType = result.read(_database.attachments.fileType)!;
      final count = result.read(_database.attachments.id.count()) ?? 0;
      counts[fileType] = count;
    }

    return counts;
  }

  Future<int> getTotalFileSize() async {
    final query = _database.selectOnly(_database.attachments)
      ..addColumns([_database.attachments.fileSize.sum()]);

    final result = await query.getSingle();
    return result.read(_database.attachments.fileSize.sum())?.toInt() ?? 0;
  }

  Future<int> getTotalFileSizeByFileType(String fileType) async {
    final query = _database.selectOnly(_database.attachments)
      ..addColumns([_database.attachments.fileSize.sum()])
      ..where(_database.attachments.fileType.equals(fileType));

    final result = await query.getSingle();
    return result.read(_database.attachments.fileSize.sum())?.toInt() ?? 0;
  }

  // Stream operations for real-time updates
  Stream<List<Attachment>> watchAllAttachments() {
    return (_database.select(_database.attachments)..orderBy([
          (attachment) => OrderingTerm(
            expression: attachment.createdAt,
            mode: OrderingMode.desc,
          ),
        ]))
        .watch();
  }

  Stream<List<Attachment>> watchAttachmentsByRecordId(String recordId) {
    return (_database.select(_database.attachments)
          ..where((attachment) => attachment.recordId.equals(recordId))
          ..orderBy([
            (attachment) => OrderingTerm(
              expression: attachment.createdAt,
              mode: OrderingMode.desc,
            ),
          ]))
        .watch();
  }

  Future<int> getUnsyncedAttachmentCount() async {
    final query = _database.selectOnly(_database.attachments)
      ..addColumns([_database.attachments.id.count()])
      ..where(_database.attachments.isSynced.equals(false));

    final result = await query.getSingle();
    return result.read(_database.attachments.id.count()) ?? 0;
  }

  Future<bool> attachmentExists(String id) async {
    final count =
        await (_database.selectOnly(_database.attachments)
              ..addColumns([_database.attachments.id.count()])
              ..where(_database.attachments.id.equals(id)))
            .getSingle();

    return (count.read(_database.attachments.id.count()) ?? 0) > 0;
  }

  Future<bool> filePathExists(String filePath) async {
    final count =
        await (_database.selectOnly(_database.attachments)
              ..addColumns([_database.attachments.id.count()])
              ..where(_database.attachments.filePath.equals(filePath)))
            .getSingle();

    return (count.read(_database.attachments.id.count()) ?? 0) > 0;
  }

  Future<List<String>> getAllFilePaths() async {
    final query = _database.selectOnly(_database.attachments)
      ..addColumns([_database.attachments.filePath])
      ..orderBy([
        OrderingTerm(
          expression: _database.attachments.createdAt,
          mode: OrderingMode.desc,
        ),
      ]);

    final results = await query.get();
    return results
        .map((result) => result.read(_database.attachments.filePath)!)
        .toList();
  }

  Future<List<String>> getOrphanedFilePaths() async {
    final attachmentPaths = await getAllFilePaths();
    final List<String> orphanedPaths = [];

    for (final path in attachmentPaths) {
      final file = File(path);
      if (!await file.exists()) {
        orphanedPaths.add(path);
      }
    }

    return orphanedPaths;
  }

  Future<int> cleanupOrphanedRecords() async {
    final orphanedPaths = await getOrphanedFilePaths();
    if (orphanedPaths.isEmpty) return 0;

    return await (_database.delete(
      _database.attachments,
    )..where((a) => a.filePath.isIn(orphanedPaths))).go();
  }

  // Bulk operations
  Future<List<String>> createMultipleAttachments(
    List<AttachmentsCompanion> attachments,
  ) async {
    final List<String> ids = [];

    for (final attachmentCompanion in attachments) {
      try {
        final id = await createAttachment(attachmentCompanion);
        ids.add(id);
      } catch (e) {
        // Skip if constraint violation
        continue;
      }
    }

    return ids;
  }

  Future<int> markMultipleAsSynced(
    List<String> attachmentIds,
    bool isSynced,
  ) async {
    return await (_database.update(_database.attachments)
          ..where((a) => a.id.isIn(attachmentIds)))
        .write(AttachmentsCompanion(isSynced: Value(isSynced)));
  }

  Future<int> deleteMultipleAttachments(
    List<String> attachmentIds, {
    bool deleteFiles = false,
  }) async {
    // Optionally delete physical files
    if (deleteFiles) {
      for (final id in attachmentIds) {
        final attachment = await getAttachmentById(id);
        if (attachment != null) {
          await deletePhysicalFile(attachment.filePath);
        }
      }
    }

    return await (_database.delete(
      _database.attachments,
    )..where((a) => a.id.isIn(attachmentIds))).go();
  }

  // File operations
  Future<bool> deletePhysicalFile(String filePath) async {
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

  Future<bool> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  Future<int?> getPhysicalFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Stream<List<Attachment>> watchAttachmentsByFileType(String fileType) {
    return (_database.select(_database.attachments)
          ..where((attachment) => attachment.fileType.equals(fileType))
          ..orderBy([
            (attachment) => OrderingTerm(
              expression: attachment.createdAt,
              mode: OrderingMode.desc,
            ),
          ]))
        .watch();
  }

  Stream<List<Attachment>> watchUnsyncedAttachments() {
    return (_database.select(_database.attachments)
          ..where((attachment) => attachment.isSynced.equals(false))
          ..orderBy([
            (attachment) => OrderingTerm(
              expression: attachment.createdAt,
              mode: OrderingMode.desc,
            ),
          ]))
        .watch();
  }

  Stream<Attachment?> watchAttachment(String id) {
    return (_database.select(
      _database.attachments,
    )..where((attachment) => attachment.id.equals(id))).watchSingleOrNull();
  }

  Stream<int> watchAttachmentCount() {
    final query = _database.selectOnly(_database.attachments)
      ..addColumns([_database.attachments.id.count()]);

    return query.watchSingle().map(
      (result) => result.read(_database.attachments.id.count()) ?? 0,
    );
  }

  Stream<int> watchUnsyncedAttachmentCount() {
    final query = _database.selectOnly(_database.attachments)
      ..addColumns([_database.attachments.id.count()])
      ..where(_database.attachments.isSynced.equals(false));

    return query.watchSingle().map(
      (result) => result.read(_database.attachments.id.count()) ?? 0,
    );
  }

  Stream<int> watchTotalFileSize() {
    final query = _database.selectOnly(_database.attachments)
      ..addColumns([_database.attachments.fileSize.sum()]);

    return query.watchSingle().map(
      (result) =>
          result.read(_database.attachments.fileSize.sum())?.toInt() ?? 0,
    );
  }

  // File type validation
  static const List<String> validFileTypes = [
    'image',
    'pdf',
    'document',
    'other',
  ];

  bool isValidFileType(String fileType) {
    return validFileTypes.contains(fileType);
  }

  String detectFileType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
      case 'webp':
        return 'image';
      case 'pdf':
        return 'pdf';
      case 'doc':
      case 'docx':
      case 'txt':
      case 'rtf':
        return 'document';
      default:
        return 'other';
    }
  }

  // File size formatting
  String formatFileSize(int sizeInBytes) {
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
