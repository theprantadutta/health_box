import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:csv/csv.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;

import '../../../data/database/app_database.dart';
import '../../../data/repositories/attachment_dao.dart';
import '../../../data/repositories/medical_record_dao.dart';
import '../../../data/repositories/reminder_dao.dart';
import '../../../data/repositories/tag_dao.dart';
import '../../profiles/services/profile_service.dart';

enum ImportFormat { json, csv, zip, backup }

enum ImportMode { merge, replace, skipDuplicates }

enum ValidationSeverity { error, warning, info }

class ValidationIssue {
  final ValidationSeverity severity;
  final String message;
  final String? field;
  final int? lineNumber;
  final String? entityId;

  ValidationIssue({
    required this.severity,
    required this.message,
    this.field,
    this.lineNumber,
    this.entityId,
  });

  Map<String, dynamic> toJson() => {
    'severity': severity.name,
    'message': message,
    'field': field,
    'lineNumber': lineNumber,
    'entityId': entityId,
  };
}

class ImportResult {
  final bool success;
  final String? error;
  final List<ValidationIssue> validationIssues;
  final Map<String, int> importedCounts;
  final Map<String, int> skippedCounts;
  final Map<String, int> errorCounts;
  final String format;

  ImportResult({
    required this.success,
    this.error,
    this.validationIssues = const [],
    this.importedCounts = const {},
    this.skippedCounts = const {},
    this.errorCounts = const {},
    required this.format,
  });

  int get totalImported => importedCounts.values.fold(0, (a, b) => a + b);
  int get totalSkipped => skippedCounts.values.fold(0, (a, b) => a + b);
  int get totalErrors => errorCounts.values.fold(0, (a, b) => a + b);

  bool get hasErrors =>
      validationIssues.any((i) => i.severity == ValidationSeverity.error);
  bool get hasWarnings =>
      validationIssues.any((i) => i.severity == ValidationSeverity.warning);
}

class ImportOptions {
  final ImportFormat format;
  final ImportMode mode;
  final bool validateOnly;
  final bool createMissingProfiles;
  final bool updateExistingRecords;
  final List<String>? allowedEntityTypes;
  final Map<String, String>? fieldMappings;

  ImportOptions({
    required this.format,
    this.mode = ImportMode.merge,
    this.validateOnly = false,
    this.createMissingProfiles = true,
    this.updateExistingRecords = true,
    this.allowedEntityTypes,
    this.fieldMappings,
  });
}

class ImportService {
  final AppDatabase _database;
  final Logger _logger = Logger();

  // DAOs
  late final MedicalRecordDao _medicalRecordDao;
  late final ReminderDao _reminderDao;
  late final TagDao _tagDao;
  late final AttachmentDao _attachmentDao;

  // Callbacks for progress tracking
  Function(double progress, String status)? onProgress;

  ImportService({AppDatabase? database})
    : _database = database ?? AppDatabase.instance {
    _initializeDAOs();
  }

  void _initializeDAOs() {
    _medicalRecordDao = MedicalRecordDao(_database);
    _reminderDao = ReminderDao(_database);
    _tagDao = TagDao(_database);
    _attachmentDao = AttachmentDao(_database);
  }

  Future<ImportResult> importData({
    required String filePath,
    required ImportOptions options,
  }) async {
    try {
      _updateProgress(0.0, 'Starting import...');

      // Detect format if not specified
      final format = options.format == ImportFormat.json
          ? _detectFileFormat(filePath)
          : options.format;

      switch (format) {
        case ImportFormat.json:
          return await _importFromJson(filePath, options);
        case ImportFormat.csv:
          return await _importFromCsv(filePath, options);
        case ImportFormat.zip:
          return await _importFromZip(filePath, options);
        case ImportFormat.backup:
          return await _importFromBackup(filePath, options);
      }
    } catch (e, stackTrace) {
      _logger.e('Import failed', error: e, stackTrace: stackTrace);
      return ImportResult(
        success: false,
        error: e.toString(),
        format: options.format.name,
      );
    }
  }

  Future<ImportResult> validateFile({
    required String filePath,
    required ImportFormat format,
  }) async {
    return importData(
      filePath: filePath,
      options: ImportOptions(format: format, validateOnly: true),
    );
  }

  ImportFormat _detectFileFormat(String filePath) {
    final extension = p.extension(filePath).toLowerCase();
    switch (extension) {
      case '.json':
        return ImportFormat.json;
      case '.csv':
        return ImportFormat.csv;
      case '.zip':
        return ImportFormat.zip;
      case '.hbbackup':
        return ImportFormat.backup;
      default:
        return ImportFormat.json;
    }
  }

  Future<ImportResult> _importFromJson(
    String filePath,
    ImportOptions options,
  ) async {
    _updateProgress(0.1, 'Reading JSON file...');

    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File does not exist: $filePath');
    }

    final jsonString = await file.readAsString();
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    _updateProgress(0.3, 'Validating data...');

    final validationIssues = await _validateData(data, options);

    if (options.validateOnly) {
      return ImportResult(
        success: !_hasErrors(validationIssues),
        validationIssues: validationIssues,
        format: 'json',
      );
    }

    if (_hasErrors(validationIssues)) {
      return ImportResult(
        success: false,
        validationIssues: validationIssues,
        error: 'Validation failed with errors',
        format: 'json',
      );
    }

    _updateProgress(0.5, 'Importing data...');

    final result = await _performImport(data, options, validationIssues);

    _updateProgress(1.0, 'Import complete');

    return result;
  }

  Future<ImportResult> _importFromCsv(
    String filePath,
    ImportOptions options,
  ) async {
    _updateProgress(0.1, 'Reading CSV file...');

    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File does not exist: $filePath');
    }

    final csvString = await file.readAsString();
    final csvData = const CsvToListConverter().convert(csvString);

    if (csvData.isEmpty) {
      throw Exception('CSV file is empty');
    }

    _updateProgress(0.3, 'Processing CSV data...');

    final headers = csvData.first.map((e) => e.toString()).toList();
    final entityType = _detectEntityTypeFromHeaders(headers);

    final data = <String, dynamic>{entityType: <Map<String, dynamic>>[]};

    for (int i = 1; i < csvData.length; i++) {
      final row = csvData[i];
      final rowData = <String, dynamic>{};

      for (int j = 0; j < headers.length && j < row.length; j++) {
        rowData[headers[j]] = row[j];
      }

      (data[entityType] as List<Map<String, dynamic>>).add(rowData);
    }

    _updateProgress(0.5, 'Validating CSV data...');

    final validationIssues = await _validateData(data, options);

    if (options.validateOnly) {
      return ImportResult(
        success: !_hasErrors(validationIssues),
        validationIssues: validationIssues,
        format: 'csv',
      );
    }

    if (_hasErrors(validationIssues)) {
      return ImportResult(
        success: false,
        validationIssues: validationIssues,
        error: 'Validation failed with errors',
        format: 'csv',
      );
    }

    _updateProgress(0.7, 'Importing CSV data...');

    final result = await _performImport(data, options, validationIssues);

    _updateProgress(1.0, 'Import complete');

    return result;
  }

  Future<ImportResult> _importFromZip(
    String filePath,
    ImportOptions options,
  ) async {
    _updateProgress(0.1, 'Extracting ZIP file...');

    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File does not exist: $filePath');
    }

    final bytes = await file.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    _updateProgress(0.3, 'Processing extracted files...');

    final allData = <String, dynamic>{};

    for (final archiveFile in archive) {
      if (archiveFile.isFile) {
        final fileName = archiveFile.name;
        final content = archiveFile.content as List<int>;

        if (fileName.endsWith('.json')) {
          final jsonString = utf8.decode(content);
          final data = jsonDecode(jsonString) as Map<String, dynamic>;
          _mergeData(allData, data);
        } else if (fileName.endsWith('.csv')) {
          final csvString = utf8.decode(content);
          final csvData = const CsvToListConverter().convert(csvString);

          if (csvData.isNotEmpty) {
            final headers = csvData.first.map((e) => e.toString()).toList();
            final entityType = _detectEntityTypeFromHeaders(headers);

            if (!allData.containsKey(entityType)) {
              allData[entityType] = <Map<String, dynamic>>[];
            }

            for (int i = 1; i < csvData.length; i++) {
              final row = csvData[i];
              final rowData = <String, dynamic>{};

              for (int j = 0; j < headers.length && j < row.length; j++) {
                rowData[headers[j]] = row[j];
              }

              (allData[entityType] as List<Map<String, dynamic>>).add(rowData);
            }
          }
        }
      }
    }

    _updateProgress(0.6, 'Validating extracted data...');

    final validationIssues = await _validateData(allData, options);

    if (options.validateOnly) {
      return ImportResult(
        success: !_hasErrors(validationIssues),
        validationIssues: validationIssues,
        format: 'zip',
      );
    }

    if (_hasErrors(validationIssues)) {
      return ImportResult(
        success: false,
        validationIssues: validationIssues,
        error: 'Validation failed with errors',
        format: 'zip',
      );
    }

    _updateProgress(0.8, 'Importing data...');

    final result = await _performImport(allData, options, validationIssues);

    _updateProgress(1.0, 'Import complete');

    return result;
  }

  Future<ImportResult> _importFromBackup(
    String filePath,
    ImportOptions options,
  ) async {
    _updateProgress(0.1, 'Reading backup file...');

    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File does not exist: $filePath');
    }

    final jsonString = await file.readAsString();
    final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

    // Validate backup format
    if (!backupData.containsKey('version') || !backupData.containsKey('data')) {
      throw Exception('Invalid backup file format');
    }

    final version = backupData['version'] as String;
    final data = backupData['data'] as Map<String, dynamic>;
    final metadata = backupData['metadata'] as Map<String, dynamic>?;

    _updateProgress(0.2, 'Validating backup compatibility...');

    // Check version compatibility
    if (!_isVersionCompatible(version)) {
      throw Exception(
        'Backup version $version is not compatible with this app version',
      );
    }

    _updateProgress(0.4, 'Validating backup data...');

    final validationIssues = await _validateData(data, options);

    // Add metadata validation issues
    if (metadata != null) {
      validationIssues.addAll(await _validateBackupMetadata(metadata, data));
    }

    if (options.validateOnly) {
      return ImportResult(
        success: !_hasErrors(validationIssues),
        validationIssues: validationIssues,
        format: 'backup',
      );
    }

    if (_hasErrors(validationIssues)) {
      return ImportResult(
        success: false,
        validationIssues: validationIssues,
        error: 'Backup validation failed with errors',
        format: 'backup',
      );
    }

    _updateProgress(0.6, 'Importing backup data...');

    final result = await _performImport(data, options, validationIssues);

    _updateProgress(1.0, 'Backup import complete');

    return result;
  }

  Future<List<ValidationIssue>> _validateData(
    Map<String, dynamic> data,
    ImportOptions options,
  ) async {
    final issues = <ValidationIssue>[];

    // Validate each entity type
    for (final entry in data.entries) {
      final entityType = entry.key;
      final entities = entry.value;

      if (options.allowedEntityTypes != null &&
          !options.allowedEntityTypes!.contains(entityType)) {
        issues.add(
          ValidationIssue(
            severity: ValidationSeverity.warning,
            message:
                'Entity type "$entityType" is not in allowed list and will be skipped',
          ),
        );
        continue;
      }

      if (entities is List) {
        for (int i = 0; i < entities.length; i++) {
          final entity = entities[i];
          if (entity is Map<String, dynamic>) {
            issues.addAll(await _validateEntity(entityType, entity, i + 1));
          }
        }
      }
    }

    // Validate referential integrity
    issues.addAll(await _validateReferentialIntegrity(data));

    return issues;
  }

  Future<List<ValidationIssue>> _validateEntity(
    String entityType,
    Map<String, dynamic> entity,
    int lineNumber,
  ) async {
    final issues = <ValidationIssue>[];

    switch (entityType) {
      case 'profiles':
        issues.addAll(_validateProfile(entity, lineNumber));
        break;
      case 'medicalRecords':
        issues.addAll(_validateMedicalRecord(entity, lineNumber));
        break;
      case 'reminders':
        issues.addAll(_validateReminder(entity, lineNumber));
        break;
      case 'tags':
        issues.addAll(_validateTag(entity, lineNumber));
        break;
      case 'attachments':
        issues.addAll(_validateAttachment(entity, lineNumber));
        break;
      default:
        issues.add(
          ValidationIssue(
            severity: ValidationSeverity.warning,
            message: 'Unknown entity type: $entityType',
            lineNumber: lineNumber,
          ),
        );
    }

    return issues;
  }

  List<ValidationIssue> _validateProfile(
    Map<String, dynamic> profile,
    int lineNumber,
  ) {
    final issues = <ValidationIssue>[];

    // Required fields
    if (!profile.containsKey('id') ||
        profile['id'] == null ||
        profile['id'].toString().isEmpty) {
      issues.add(
        ValidationIssue(
          severity: ValidationSeverity.error,
          message: 'Profile ID is required',
          field: 'id',
          lineNumber: lineNumber,
        ),
      );
    }

    if (!profile.containsKey('firstName') ||
        profile['firstName'].toString().trim().isEmpty) {
      issues.add(
        ValidationIssue(
          severity: ValidationSeverity.error,
          message: 'First name is required',
          field: 'firstName',
          lineNumber: lineNumber,
        ),
      );
    }

    if (!profile.containsKey('lastName') ||
        profile['lastName'].toString().trim().isEmpty) {
      issues.add(
        ValidationIssue(
          severity: ValidationSeverity.error,
          message: 'Last name is required',
          field: 'lastName',
          lineNumber: lineNumber,
        ),
      );
    }

    // Optional field validations
    if (profile.containsKey('email') && profile['email'] != null) {
      final email = profile['email'].toString();
      if (email.isNotEmpty && !_isValidEmail(email)) {
        issues.add(
          ValidationIssue(
            severity: ValidationSeverity.warning,
            message: 'Invalid email format',
            field: 'email',
            lineNumber: lineNumber,
          ),
        );
      }
    }

    if (profile.containsKey('dateOfBirth') && profile['dateOfBirth'] != null) {
      final dobString = profile['dateOfBirth'].toString();
      if (dobString.isNotEmpty && DateTime.tryParse(dobString) == null) {
        issues.add(
          ValidationIssue(
            severity: ValidationSeverity.error,
            message: 'Invalid date of birth format',
            field: 'dateOfBirth',
            lineNumber: lineNumber,
          ),
        );
      }
    }

    return issues;
  }

  List<ValidationIssue> _validateMedicalRecord(
    Map<String, dynamic> record,
    int lineNumber,
  ) {
    final issues = <ValidationIssue>[];

    // Required fields
    if (!record.containsKey('id') || record['id'].toString().isEmpty) {
      issues.add(
        ValidationIssue(
          severity: ValidationSeverity.error,
          message: 'Medical record ID is required',
          field: 'id',
          lineNumber: lineNumber,
        ),
      );
    }

    if (!record.containsKey('profileId') ||
        record['profileId'].toString().isEmpty) {
      issues.add(
        ValidationIssue(
          severity: ValidationSeverity.error,
          message: 'Profile ID is required for medical record',
          field: 'profileId',
          lineNumber: lineNumber,
        ),
      );
    }

    if (!record.containsKey('recordType') ||
        record['recordType'].toString().isEmpty) {
      issues.add(
        ValidationIssue(
          severity: ValidationSeverity.error,
          message: 'Record type is required',
          field: 'recordType',
          lineNumber: lineNumber,
        ),
      );
    }

    if (!record.containsKey('title') ||
        record['title'].toString().trim().isEmpty) {
      issues.add(
        ValidationIssue(
          severity: ValidationSeverity.error,
          message: 'Title is required',
          field: 'title',
          lineNumber: lineNumber,
        ),
      );
    }

    // Date validation
    if (record.containsKey('recordDate') && record['recordDate'] != null) {
      final dateString = record['recordDate'].toString();
      if (dateString.isNotEmpty && DateTime.tryParse(dateString) == null) {
        issues.add(
          ValidationIssue(
            severity: ValidationSeverity.error,
            message: 'Invalid record date format',
            field: 'recordDate',
            lineNumber: lineNumber,
          ),
        );
      }
    }

    return issues;
  }

  List<ValidationIssue> _validateReminder(
    Map<String, dynamic> reminder,
    int lineNumber,
  ) {
    final issues = <ValidationIssue>[];

    // Required fields
    if (!reminder.containsKey('id') || reminder['id'].toString().isEmpty) {
      issues.add(
        ValidationIssue(
          severity: ValidationSeverity.error,
          message: 'Reminder ID is required',
          field: 'id',
          lineNumber: lineNumber,
        ),
      );
    }

    if (!reminder.containsKey('title') ||
        reminder['title'].toString().trim().isEmpty) {
      issues.add(
        ValidationIssue(
          severity: ValidationSeverity.error,
          message: 'Reminder title is required',
          field: 'title',
          lineNumber: lineNumber,
        ),
      );
    }

    if (reminder.containsKey('scheduledTime') &&
        reminder['scheduledTime'] != null) {
      final timeString = reminder['scheduledTime'].toString();
      if (timeString.isNotEmpty && DateTime.tryParse(timeString) == null) {
        issues.add(
          ValidationIssue(
            severity: ValidationSeverity.error,
            message: 'Invalid scheduled time format',
            field: 'scheduledTime',
            lineNumber: lineNumber,
          ),
        );
      }
    }

    return issues;
  }

  List<ValidationIssue> _validateTag(Map<String, dynamic> tag, int lineNumber) {
    final issues = <ValidationIssue>[];

    if (!tag.containsKey('id') || tag['id'].toString().isEmpty) {
      issues.add(
        ValidationIssue(
          severity: ValidationSeverity.error,
          message: 'Tag ID is required',
          field: 'id',
          lineNumber: lineNumber,
        ),
      );
    }

    if (!tag.containsKey('name') || tag['name'].toString().trim().isEmpty) {
      issues.add(
        ValidationIssue(
          severity: ValidationSeverity.error,
          message: 'Tag name is required',
          field: 'name',
          lineNumber: lineNumber,
        ),
      );
    }

    return issues;
  }

  List<ValidationIssue> _validateAttachment(
    Map<String, dynamic> attachment,
    int lineNumber,
  ) {
    final issues = <ValidationIssue>[];

    if (!attachment.containsKey('id') || attachment['id'].toString().isEmpty) {
      issues.add(
        ValidationIssue(
          severity: ValidationSeverity.error,
          message: 'Attachment ID is required',
          field: 'id',
          lineNumber: lineNumber,
        ),
      );
    }

    if (!attachment.containsKey('fileName') ||
        attachment['fileName'].toString().isEmpty) {
      issues.add(
        ValidationIssue(
          severity: ValidationSeverity.error,
          message: 'File name is required',
          field: 'fileName',
          lineNumber: lineNumber,
        ),
      );
    }

    return issues;
  }

  Future<List<ValidationIssue>> _validateReferentialIntegrity(
    Map<String, dynamic> data,
  ) async {
    final issues = <ValidationIssue>[];
    final profileIds = <String>{};

    // Collect profile IDs
    if (data.containsKey('profiles')) {
      final profiles = data['profiles'] as List<dynamic>;
      for (final profile in profiles) {
        if (profile is Map<String, dynamic> && profile.containsKey('id')) {
          profileIds.add(profile['id'].toString());
        }
      }
    }

    // Validate medical record profile references
    if (data.containsKey('medicalRecords')) {
      final records = data['medicalRecords'] as List<dynamic>;
      for (int i = 0; i < records.length; i++) {
        final record = records[i] as Map<String, dynamic>;
        final profileId = record['profileId']?.toString();

        if (profileId != null && !profileIds.contains(profileId)) {
          issues.add(
            ValidationIssue(
              severity: ValidationSeverity.error,
              message:
                  'Medical record references non-existent profile: $profileId',
              field: 'profileId',
              lineNumber: i + 1,
              entityId: record['id']?.toString(),
            ),
          );
        }
      }
    }

    // Validate reminder profile references
    if (data.containsKey('reminders')) {
      final reminders = data['reminders'] as List<dynamic>;
      for (int i = 0; i < reminders.length; i++) {
        final reminder = reminders[i] as Map<String, dynamic>;
        final profileId = reminder['profileId']?.toString();

        if (profileId != null && !profileIds.contains(profileId)) {
          issues.add(
            ValidationIssue(
              severity: ValidationSeverity.warning,
              message: 'Reminder references non-existent profile: $profileId',
              field: 'profileId',
              lineNumber: i + 1,
              entityId: reminder['id']?.toString(),
            ),
          );
        }
      }
    }

    return issues;
  }

  Future<List<ValidationIssue>> _validateBackupMetadata(
    Map<String, dynamic> metadata,
    Map<String, dynamic> data,
  ) async {
    final issues = <ValidationIssue>[];

    // Validate item counts
    if (metadata.containsKey('itemCounts')) {
      final itemCounts = metadata['itemCounts'] as Map<String, dynamic>;

      for (final entry in itemCounts.entries) {
        final entityType = entry.key;
        final expectedCount = entry.value as int;
        final actualCount = (data[entityType] as List<dynamic>?)?.length ?? 0;

        if (expectedCount != actualCount) {
          issues.add(
            ValidationIssue(
              severity: ValidationSeverity.warning,
              message:
                  'Item count mismatch for $entityType: expected $expectedCount, found $actualCount',
            ),
          );
        }
      }
    }

    return issues;
  }

  Future<ImportResult> _performImport(
    Map<String, dynamic> data,
    ImportOptions options,
    List<ValidationIssue> validationIssues,
  ) async {
    final importedCounts = <String, int>{};
    final skippedCounts = <String, int>{};
    final errorCounts = <String, int>{};

    // Import in order: tags, profiles, medical records, reminders, attachments
    final importOrder = [
      'tags',
      'profiles',
      'medicalRecords',
      'reminders',
      'attachments',
    ];

    for (final entityType in importOrder) {
      if (!data.containsKey(entityType)) continue;

      final entities = data[entityType] as List<dynamic>;
      if (entities.isEmpty) continue;

      final result = await _importEntities(entityType, entities, options);
      importedCounts[entityType] = result['imported'] as int;
      skippedCounts[entityType] = result['skipped'] as int;
      errorCounts[entityType] = result['errors'] as int;
    }

    final totalErrors = errorCounts.values.fold(0, (a, b) => a + b);

    return ImportResult(
      success: totalErrors == 0,
      validationIssues: validationIssues,
      importedCounts: importedCounts,
      skippedCounts: skippedCounts,
      errorCounts: errorCounts,
      format: options.format.name,
    );
  }

  Future<Map<String, int>> _importEntities(
    String entityType,
    List<dynamic> entities,
    ImportOptions options,
  ) async {
    int imported = 0;
    int skipped = 0;
    int errors = 0;

    for (final entity in entities) {
      try {
        final entityMap = entity as Map<String, dynamic>;

        // Apply field mappings if provided
        if (options.fieldMappings != null) {
          final mappedEntity = <String, dynamic>{};
          for (final entry in entityMap.entries) {
            final mappedKey = options.fieldMappings![entry.key] ?? entry.key;
            mappedEntity[mappedKey] = entry.value;
          }
          entityMap.clear();
          entityMap.addAll(mappedEntity);
        }

        final success = await _importSingleEntity(
          entityType,
          entityMap,
          options,
        );

        if (success) {
          imported++;
        } else {
          skipped++;
        }
      } catch (e) {
        _logger.w('Failed to import $entityType entity', error: e);
        errors++;
      }
    }

    return {'imported': imported, 'skipped': skipped, 'errors': errors};
  }

  Future<bool> _importSingleEntity(
    String entityType,
    Map<String, dynamic> entity,
    ImportOptions options,
  ) async {
    switch (entityType) {
      case 'profiles':
        return await _importProfile(entity, options);
      case 'medicalRecords':
        return await _importMedicalRecord(entity, options);
      case 'reminders':
        return await _importReminder(entity, options);
      case 'tags':
        return await _importTag(entity, options);
      case 'attachments':
        return await _importAttachment(entity, options);
      default:
        return false;
    }
  }

  Future<bool> _importProfile(
    Map<String, dynamic> profile,
    ImportOptions options,
  ) async {
    try {
      final profileService = ProfileService();

      // Check if profile exists
      FamilyMemberProfile? existingProfile;
      if (profile['id'] != null) {
        try {
          existingProfile = await profileService.getProfileById(profile['id']);
        } catch (e) {
          // Profile doesn't exist
          existingProfile = null;
        }
      }

      switch (options.mode) {
        case ImportMode.merge:
          if (existingProfile != null) {
            // Update existing profile
            final updateRequest = UpdateProfileRequest(
              firstName: profile['firstName'] ?? existingProfile.firstName,
              lastName: profile['lastName'] ?? existingProfile.lastName,
              middleName: profile['middleName'] ?? existingProfile.middleName,
              dateOfBirth: profile['dateOfBirth'] != null
                  ? DateTime.parse(profile['dateOfBirth'])
                  : existingProfile.dateOfBirth,
              gender: profile['gender'] ?? existingProfile.gender,
              bloodType: profile['bloodType'] ?? existingProfile.bloodType,
              height: profile['height']?.toDouble() ?? existingProfile.height,
              weight: profile['weight']?.toDouble() ?? existingProfile.weight,
              emergencyContact:
                  profile['emergencyContact'] ??
                  existingProfile.emergencyContact,
              insuranceInfo:
                  profile['insuranceInfo'] ?? existingProfile.insuranceInfo,
              profileImagePath:
                  profile['profileImagePath'] ??
                  existingProfile.profileImagePath,
            );
            await profileService.updateProfile(
              existingProfile.id,
              updateRequest,
            );
          } else {
            // Create new profile
            await _createProfileFromMap(profile, profileService);
          }
          return true;

        case ImportMode.replace:
          if (existingProfile != null) {
            await profileService.deleteProfile(existingProfile.id);
          }
          await _createProfileFromMap(profile, profileService);
          return true;

        case ImportMode.skipDuplicates:
          if (existingProfile != null) {
            return false; // Skip duplicate
          }
          await _createProfileFromMap(profile, profileService);
          return true;
      }
    } catch (e) {
      _logger.e('Failed to import profile: $e');
      return false;
    }
  }

  Future<void> _createProfileFromMap(
    Map<String, dynamic> profile,
    ProfileService profileService,
  ) async {
    final createRequest = CreateProfileRequest(
      firstName: profile['firstName'] ?? 'Unknown',
      lastName: profile['lastName'] ?? 'User',
      middleName: profile['middleName'],
      dateOfBirth: profile['dateOfBirth'] != null
          ? DateTime.parse(profile['dateOfBirth'])
          : DateTime.now().subtract(const Duration(days: 365 * 25)),
      gender: profile['gender'] ?? 'Unspecified',
      bloodType: profile['bloodType'],
      height: profile['height']?.toDouble(),
      weight: profile['weight']?.toDouble(),
      emergencyContact: profile['emergencyContact'],
      insuranceInfo: profile['insuranceInfo'],
      profileImagePath: profile['profileImagePath'],
    );
    await profileService.createProfile(createRequest);
  }

  Future<bool> _importMedicalRecord(
    Map<String, dynamic> record,
    ImportOptions options,
  ) async {
    // Implementation would depend on your DAO methods
    _logger.d('Using medical record DAO: ${_medicalRecordDao.runtimeType}');
    return true;
  }

  Future<bool> _importReminder(
    Map<String, dynamic> reminder,
    ImportOptions options,
  ) async {
    // Implementation would depend on your DAO methods
    _logger.d('Using reminder DAO: ${_reminderDao.runtimeType}');
    return true;
  }

  Future<bool> _importTag(
    Map<String, dynamic> tag,
    ImportOptions options,
  ) async {
    // Implementation would depend on your DAO methods
    _logger.d('Using tag DAO: ${_tagDao.runtimeType}');
    return true;
  }

  Future<bool> _importAttachment(
    Map<String, dynamic> attachment,
    ImportOptions options,
  ) async {
    // Implementation would depend on your DAO methods
    _logger.d('Using attachment DAO: ${_attachmentDao.runtimeType}');
    return true;
  }

  String _detectEntityTypeFromHeaders(List<String> headers) {
    if (headers.contains('firstName') && headers.contains('lastName')) {
      return 'profiles';
    } else if (headers.contains('recordType') &&
        headers.contains('recordDate')) {
      return 'medicalRecords';
    } else if (headers.contains('scheduledTime')) {
      return 'reminders';
    } else if (headers.contains('name') && headers.length <= 5) {
      return 'tags';
    } else if (headers.contains('fileName') || headers.contains('filePath')) {
      return 'attachments';
    }
    return 'unknown';
  }

  void _mergeData(Map<String, dynamic> target, Map<String, dynamic> source) {
    for (final entry in source.entries) {
      final key = entry.key;
      final value = entry.value;

      if (target.containsKey(key) && target[key] is List && value is List) {
        (target[key] as List).addAll(value);
      } else {
        target[key] = value;
      }
    }
  }

  bool _hasErrors(List<ValidationIssue> issues) {
    return issues.any((issue) => issue.severity == ValidationSeverity.error);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isVersionCompatible(String version) {
    // Simple version compatibility check
    final supportedVersions = ['1.0.0'];
    return supportedVersions.contains(version);
  }

  void _updateProgress(double progress, String status) {
    onProgress?.call(progress, status);
  }

  List<ImportFormat> getSupportedFormats() {
    return ImportFormat.values;
  }

  String getFormatDescription(ImportFormat format) {
    switch (format) {
      case ImportFormat.json:
        return 'JSON files with structured health data';
      case ImportFormat.csv:
        return 'CSV files from spreadsheet applications';
      case ImportFormat.zip:
        return 'ZIP archives with multiple data files';
      case ImportFormat.backup:
        return 'Health Box backup files (.hbbackup)';
    }
  }
}
