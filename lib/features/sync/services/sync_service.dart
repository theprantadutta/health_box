import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../../../data/database/app_database.dart';
import '../../../data/repositories/attachment_dao.dart';
import '../../../data/repositories/medical_record_dao.dart';
import '../../../data/repositories/profile_dao.dart';
import '../../../data/repositories/reminder_dao.dart';
import '../../../data/repositories/tag_dao.dart';
import 'google_drive_service.dart';

enum SyncStatus {
  idle,
  syncing,
  uploading,
  downloading,
  resolving,
  completed,
  error,
  noConnection,
}

enum ConflictResolution { localWins, remoteWins, merge, manual }

class SyncConflict {
  final String entityType;
  final String entityId;
  final Map<String, dynamic> localData;
  final Map<String, dynamic> remoteData;
  final DateTime localTimestamp;
  final DateTime remoteTimestamp;

  SyncConflict({
    required this.entityType,
    required this.entityId,
    required this.localData,
    required this.remoteData,
    required this.localTimestamp,
    required this.remoteTimestamp,
  });

  Map<String, dynamic> toJson() => {
    'entityType': entityType,
    'entityId': entityId,
    'localData': localData,
    'remoteData': remoteData,
    'localTimestamp': localTimestamp.toIso8601String(),
    'remoteTimestamp': remoteTimestamp.toIso8601String(),
  };

  static SyncConflict fromJson(Map<String, dynamic> json) => SyncConflict(
    entityType: json['entityType'] as String,
    entityId: json['entityId'] as String,
    localData: json['localData'] as Map<String, dynamic>,
    remoteData: json['remoteData'] as Map<String, dynamic>,
    localTimestamp: DateTime.parse(json['localTimestamp'] as String),
    remoteTimestamp: DateTime.parse(json['remoteTimestamp'] as String),
  );
}

class SyncResult {
  final bool success;
  final SyncStatus status;
  final String? error;
  final List<SyncConflict> conflicts;
  final Map<String, int> syncStats;
  final DateTime? lastSyncTime;

  SyncResult({
    required this.success,
    required this.status,
    this.error,
    this.conflicts = const [],
    this.syncStats = const {},
    this.lastSyncTime,
  });
}

class SyncService {
  final GoogleDriveService _googleDriveService;
  final AppDatabase _database;
  final Logger _logger = Logger();
  final Uuid _uuid = const Uuid();

  // DAOs
  late final ProfileDao _profileDao;
  late final MedicalRecordDao _medicalRecordDao;
  late final ReminderDao _reminderDao;
  late final TagDao _tagDao;
  late final AttachmentDao _attachmentDao;

  SyncStatus _currentStatus = SyncStatus.idle;
  DateTime? _lastSyncTime;
  List<SyncConflict> _pendingConflicts = [];

  // Callbacks
  Function(SyncStatus)? onStatusChanged;
  Function(double)? onProgressChanged;
  Function(List<SyncConflict>)? onConflictsDetected;

  SyncService({
    required GoogleDriveService googleDriveService,
    AppDatabase? database,
  }) : _googleDriveService = googleDriveService,
       _database = database ?? AppDatabase.instance {
    _initializeDAOs();
  }

  void _initializeDAOs() {
    _profileDao = ProfileDao(_database);
    _medicalRecordDao = MedicalRecordDao(_database);
    _reminderDao = ReminderDao(_database);
    _tagDao = TagDao(_database);
    _attachmentDao = AttachmentDao(_database);
  }

  SyncStatus get currentStatus => _currentStatus;
  DateTime? get lastSyncTime => _lastSyncTime;
  List<SyncConflict> get pendingConflicts =>
      List.unmodifiable(_pendingConflicts);

  Future<bool> get isOnline async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<SyncResult> performFullSync({
    ConflictResolution defaultResolution = ConflictResolution.manual,
  }) async {
    if (!await isOnline) {
      _updateStatus(SyncStatus.noConnection);
      return SyncResult(
        success: false,
        status: SyncStatus.noConnection,
        error: 'No internet connection available',
      );
    }

    if (!_googleDriveService.isSignedIn) {
      return SyncResult(
        success: false,
        status: SyncStatus.error,
        error: 'Google Drive not authenticated',
      );
    }

    try {
      _updateStatus(SyncStatus.syncing);
      _pendingConflicts.clear();

      // Step 1: Download remote data
      _updateStatus(SyncStatus.downloading);
      final remoteBackup = await _googleDriveService.downloadBackup();
      final remoteMetadata = await _googleDriveService.downloadMetadata();

      // Step 2: Export local data
      final localData = await _exportLocalData();
      final localMetadata = await _generateLocalMetadata();

      // Step 3: Compare and detect conflicts
      _updateStatus(SyncStatus.resolving);
      final conflicts = await _detectConflicts(
        localData,
        remoteBackup?['data'] != null
            ? jsonDecode(remoteBackup!['data'] as String)
                  as Map<String, dynamic>
            : {},
        localMetadata,
        remoteMetadata ?? {},
      );

      if (conflicts.isNotEmpty &&
          defaultResolution == ConflictResolution.manual) {
        _pendingConflicts = conflicts;
        onConflictsDetected?.call(conflicts);
        return SyncResult(
          success: false,
          status: SyncStatus.resolving,
          conflicts: conflicts,
        );
      }

      // Step 4: Resolve conflicts automatically if resolution strategy provided
      final resolvedData = await _resolveConflicts(
        conflicts,
        localData,
        remoteBackup?['data'] != null
            ? jsonDecode(remoteBackup!['data'] as String)
                  as Map<String, dynamic>
            : {},
        defaultResolution,
      );

      // Step 5: Apply resolved data locally
      final applyStats = await _applyResolvedData(resolvedData);

      // Step 6: Upload merged data to remote
      _updateStatus(SyncStatus.uploading);
      final finalData = await _exportLocalData();
      final finalMetadata = await _generateLocalMetadata();

      final uploadSuccess = await _googleDriveService.uploadBackup(
        jsonData: jsonEncode(finalData),
        metadata: finalMetadata,
      );

      if (!uploadSuccess) {
        throw Exception('Failed to upload synchronized data');
      }

      _lastSyncTime = DateTime.now();
      _updateStatus(SyncStatus.completed);

      return SyncResult(
        success: true,
        status: SyncStatus.completed,
        syncStats: applyStats,
        lastSyncTime: _lastSyncTime,
      );
    } catch (e, stackTrace) {
      _logger.e('Sync failed', error: e, stackTrace: stackTrace);
      _updateStatus(SyncStatus.error);
      return SyncResult(
        success: false,
        status: SyncStatus.error,
        error: e.toString(),
      );
    } finally {
      if (_currentStatus != SyncStatus.resolving) {
        _updateStatus(SyncStatus.idle);
      }
    }
  }

  Future<bool> resolveConflictManually(
    String conflictId,
    ConflictResolution resolution, {
    Map<String, dynamic>? customData,
  }) async {
    try {
      final conflictIndex = _pendingConflicts.indexWhere(
        (c) => '${c.entityType}_${c.entityId}' == conflictId,
      );

      if (conflictIndex == -1) {
        return false;
      }

      final conflict = _pendingConflicts[conflictIndex];
      Map<String, dynamic> resolvedData;

      switch (resolution) {
        case ConflictResolution.localWins:
          resolvedData = conflict.localData;
          break;
        case ConflictResolution.remoteWins:
          resolvedData = conflict.remoteData;
          break;
        case ConflictResolution.merge:
          resolvedData = _mergeConflictData(conflict);
          break;
        case ConflictResolution.manual:
          if (customData == null) {
            return false;
          }
          resolvedData = customData;
          break;
      }

      // Apply the resolved data
      await _applyEntityData(conflict.entityType, resolvedData);

      // Remove from pending conflicts
      _pendingConflicts.removeAt(conflictIndex);

      // If all conflicts resolved, complete the sync
      if (_pendingConflicts.isEmpty) {
        await _completeManualSync();
      }

      return true;
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to resolve conflict manually',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<void> _completeManualSync() async {
    try {
      _updateStatus(SyncStatus.uploading);

      // Export final resolved data
      final finalData = await _exportLocalData();
      final finalMetadata = await _generateLocalMetadata();

      // Upload to remote
      final uploadSuccess = await _googleDriveService.uploadBackup(
        jsonData: jsonEncode(finalData),
        metadata: finalMetadata,
      );

      if (uploadSuccess) {
        _lastSyncTime = DateTime.now();
        _updateStatus(SyncStatus.completed);
      } else {
        _updateStatus(SyncStatus.error);
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to complete manual sync',
        error: e,
        stackTrace: stackTrace,
      );
      _updateStatus(SyncStatus.error);
    } finally {
      _updateStatus(SyncStatus.idle);
    }
  }

  Future<Map<String, dynamic>> _exportLocalData() async {
    final data = <String, dynamic>{};

    // Export profiles
    final profiles = await _profileDao.getAllProfiles();
    data['profiles'] = profiles.map((p) => p.toJson()).toList();

    // Export medical records
    final medicalRecords = await _medicalRecordDao.getAllRecords();
    data['medicalRecords'] = medicalRecords.map((r) => r.toJson()).toList();

    // Export reminders
    final reminders = await _reminderDao.getAllReminders();
    data['reminders'] = reminders.map((r) => r.toJson()).toList();

    // Export tags
    final tags = await _tagDao.getAllTags();
    data['tags'] = tags.map((t) => t.toJson()).toList();

    // Export attachments metadata (not the actual files)
    final attachments = await _attachmentDao.getAllAttachments();
    data['attachments'] = attachments.map((a) => a.toJson()).toList();

    return data;
  }

  Future<Map<String, dynamic>> _generateLocalMetadata() async {
    final profiles = await _profileDao.getAllProfiles();
    final medicalRecords = await _medicalRecordDao.getAllRecords();
    final reminders = await _reminderDao.getAllReminders();
    final tags = await _tagDao.getAllTags();
    final attachments = await _attachmentDao.getAllAttachments();

    return {
      'deviceId': await _getDeviceId(),
      'exportTimestamp': DateTime.now().toIso8601String(),
      'version': '1.0.0',
      'counts': {
        'profiles': profiles.length,
        'medicalRecords': medicalRecords.length,
        'reminders': reminders.length,
        'tags': tags.length,
        'attachments': attachments.length,
      },
      'checksums': {
        'profiles': _calculateEntityChecksum(profiles),
        'medicalRecords': _calculateEntityChecksum(medicalRecords),
        'reminders': _calculateEntityChecksum(reminders),
        'tags': _calculateEntityChecksum(tags),
        'attachments': _calculateEntityChecksum(attachments),
      },
    };
  }

  Future<List<SyncConflict>> _detectConflicts(
    Map<String, dynamic> localData,
    Map<String, dynamic> remoteData,
    Map<String, dynamic> localMetadata,
    Map<String, dynamic> remoteMetadata,
  ) async {
    final conflicts = <SyncConflict>[];
    final entityTypes = [
      'profiles',
      'medicalRecords',
      'reminders',
      'tags',
      'attachments',
    ];

    for (final entityType in entityTypes) {
      final localEntities = localData[entityType] as List<dynamic>? ?? [];
      final remoteEntities = remoteData[entityType] as List<dynamic>? ?? [];

      // Create maps for easier lookup
      final localEntityMap = <String, Map<String, dynamic>>{};
      for (final entity in localEntities) {
        final entityMap = entity as Map<String, dynamic>;
        localEntityMap[entityMap['id'] as String] = entityMap;
      }

      final remoteEntityMap = <String, Map<String, dynamic>>{};
      for (final entity in remoteEntities) {
        final entityMap = entity as Map<String, dynamic>;
        remoteEntityMap[entityMap['id'] as String] = entityMap;
      }

      // Find conflicts
      final allIds = {...localEntityMap.keys, ...remoteEntityMap.keys};
      for (final id in allIds) {
        final localEntity = localEntityMap[id];
        final remoteEntity = remoteEntityMap[id];

        if (localEntity != null && remoteEntity != null) {
          // Both exist - check for conflicts
          final localUpdated = DateTime.tryParse(
            (localEntity['updatedAt'] ?? localEntity['createdAt']) as String? ??
                '',
          );
          final remoteUpdated = DateTime.tryParse(
            (remoteEntity['updatedAt'] ?? remoteEntity['createdAt'])
                    as String? ??
                '',
          );

          if (localUpdated != null &&
              remoteUpdated != null &&
              _entitiesAreDifferent(localEntity, remoteEntity)) {
            conflicts.add(
              SyncConflict(
                entityType: entityType,
                entityId: id,
                localData: localEntity,
                remoteData: remoteEntity,
                localTimestamp: localUpdated,
                remoteTimestamp: remoteUpdated,
              ),
            );
          }
        }
      }
    }

    return conflicts;
  }

  bool _entitiesAreDifferent(
    Map<String, dynamic> entity1,
    Map<String, dynamic> entity2,
  ) {
    // Compare significant fields (excluding timestamps)
    final excludeFields = {'createdAt', 'updatedAt', 'lastSyncAt'};

    final keys1 = entity1.keys.where((k) => !excludeFields.contains(k)).toSet();
    final keys2 = entity2.keys.where((k) => !excludeFields.contains(k)).toSet();

    if (!keys1.containsAll(keys2) || !keys2.containsAll(keys1)) {
      return true;
    }

    for (final key in keys1) {
      if (entity1[key] != entity2[key]) {
        return true;
      }
    }

    return false;
  }

  Future<Map<String, dynamic>> _resolveConflicts(
    List<SyncConflict> conflicts,
    Map<String, dynamic> localData,
    Map<String, dynamic> remoteData,
    ConflictResolution resolution,
  ) async {
    final resolvedData = Map<String, dynamic>.from(localData);

    for (final conflict in conflicts) {
      Map<String, dynamic> resolvedEntity;

      switch (resolution) {
        case ConflictResolution.localWins:
          resolvedEntity = conflict.localData;
          break;
        case ConflictResolution.remoteWins:
          resolvedEntity = conflict.remoteData;
          break;
        case ConflictResolution.merge:
          resolvedEntity = _mergeConflictData(conflict);
          break;
        case ConflictResolution.manual:
          // This should not happen in automatic resolution
          continue;
      }

      // Update the resolved data
      final entityType = conflict.entityType;
      final entities = resolvedData[entityType] as List<dynamic>? ?? [];
      final entityIndex = entities.indexWhere(
        (e) => (e as Map<String, dynamic>)['id'] == conflict.entityId,
      );

      if (entityIndex >= 0) {
        entities[entityIndex] = resolvedEntity;
      } else {
        entities.add(resolvedEntity);
      }

      resolvedData[entityType] = entities;
    }

    return resolvedData;
  }

  Map<String, dynamic> _mergeConflictData(SyncConflict conflict) {
    final merged = Map<String, dynamic>.from(conflict.localData);
    final remote = conflict.remoteData;

    // Use remote timestamp if it's newer
    if (conflict.remoteTimestamp.isAfter(conflict.localTimestamp)) {
      merged['updatedAt'] = remote['updatedAt'];
    }

    // Merge specific fields based on entity type
    switch (conflict.entityType) {
      case 'profiles':
        // For profiles, prefer non-empty values
        for (final key in ['firstName', 'lastName', 'email', 'phone']) {
          final remoteValue = remote[key] as String?;
          if (remoteValue != null && remoteValue.isNotEmpty) {
            merged[key] = remoteValue;
          }
        }
        break;

      case 'medicalRecords':
        // For medical records, prefer the newer version entirely
        if (conflict.remoteTimestamp.isAfter(conflict.localTimestamp)) {
          return Map<String, dynamic>.from(remote);
        }
        break;

      default:
        // For other entities, use timestamp-based resolution
        if (conflict.remoteTimestamp.isAfter(conflict.localTimestamp)) {
          return Map<String, dynamic>.from(remote);
        }
    }

    return merged;
  }

  Future<Map<String, int>> _applyResolvedData(
    Map<String, dynamic> resolvedData,
  ) async {
    final stats = <String, int>{};

    // Apply profiles
    if (resolvedData.containsKey('profiles')) {
      final profiles = resolvedData['profiles'] as List<dynamic>;
      int profileCount = 0;
      for (final profileData in profiles) {
        await _applyEntityData('profiles', profileData as Map<String, dynamic>);
        profileCount++;
      }
      stats['profiles'] = profileCount;
    }

    // Apply medical records
    if (resolvedData.containsKey('medicalRecords')) {
      final medicalRecords = resolvedData['medicalRecords'] as List<dynamic>;
      int recordCount = 0;
      for (final recordData in medicalRecords) {
        await _applyEntityData(
          'medicalRecords',
          recordData as Map<String, dynamic>,
        );
        recordCount++;
      }
      stats['medicalRecords'] = recordCount;
    }

    // Apply reminders
    if (resolvedData.containsKey('reminders')) {
      final reminders = resolvedData['reminders'] as List<dynamic>;
      int reminderCount = 0;
      for (final reminderData in reminders) {
        await _applyEntityData(
          'reminders',
          reminderData as Map<String, dynamic>,
        );
        reminderCount++;
      }
      stats['reminders'] = reminderCount;
    }

    // Apply tags
    if (resolvedData.containsKey('tags')) {
      final tags = resolvedData['tags'] as List<dynamic>;
      int tagCount = 0;
      for (final tagData in tags) {
        await _applyEntityData('tags', tagData as Map<String, dynamic>);
        tagCount++;
      }
      stats['tags'] = tagCount;
    }

    // Apply attachments
    if (resolvedData.containsKey('attachments')) {
      final attachments = resolvedData['attachments'] as List<dynamic>;
      int attachmentCount = 0;
      for (final attachmentData in attachments) {
        await _applyEntityData(
          'attachments',
          attachmentData as Map<String, dynamic>,
        );
        attachmentCount++;
      }
      stats['attachments'] = attachmentCount;
    }

    return stats;
  }

  Future<void> _applyEntityData(
    String entityType,
    Map<String, dynamic> data,
  ) async {
    switch (entityType) {
      case 'profiles':
        // Note: This would need to be implemented based on your ProfileDao methods
        // await _profileDao.insertOrUpdateFromJson(data);
        break;

      case 'medicalRecords':
        // Note: This would need to be implemented based on your MedicalRecordDao methods
        // await _medicalRecordDao.insertOrUpdateFromJson(data);
        break;

      case 'reminders':
        // Note: This would need to be implemented based on your ReminderDao methods
        // await _reminderDao.insertOrUpdateFromJson(data);
        break;

      case 'tags':
        // Note: This would need to be implemented based on your TagDao methods
        // await _tagDao.insertOrUpdateFromJson(data);
        break;

      case 'attachments':
        // Note: This would need to be implemented based on your AttachmentDao methods
        // await _attachmentDao.insertOrUpdateFromJson(data);
        break;
    }
  }

  String _calculateEntityChecksum(List<dynamic> entities) {
    final jsonString = jsonEncode(entities);
    return jsonString.hashCode.toString();
  }

  Future<String> _getDeviceId() async {
    // In production, you might want to use a more persistent device ID
    // For now, generate a UUID-based ID
    return _uuid.v4();
  }

  void _updateStatus(SyncStatus status) {
    _currentStatus = status;
    onStatusChanged?.call(status);
  }

  Future<bool> cancelSync() async {
    if (_currentStatus == SyncStatus.idle ||
        _currentStatus == SyncStatus.completed) {
      return false;
    }

    _updateStatus(SyncStatus.idle);
    _pendingConflicts.clear();
    return true;
  }

  void dispose() {
    onStatusChanged = null;
    onProgressChanged = null;
    onConflictsDetected = null;
  }
}
