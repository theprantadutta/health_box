import 'package:drift/drift.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/medical_record_dao.dart';
import '../../../data/models/chronic_condition.dart';

class ChronicConditionService {
  final MedicalRecordDao _medicalRecordDao;
  final AppDatabase _database;

  ChronicConditionService({
    MedicalRecordDao? medicalRecordDao,
    AppDatabase? database,
  }) : _database = database ?? AppDatabase.instance,
       _medicalRecordDao =
           medicalRecordDao ??
           MedicalRecordDao(database ?? AppDatabase.instance);

  // CRUD Operations

  Future<List<ChronicCondition>> getAllChronicConditions({
    String? profileId,
  }) async {
    try {
      return await _medicalRecordDao.getAllChronicConditions(
        profileId: profileId,
      );
    } catch (e) {
      throw ChronicConditionServiceException(
        'Failed to retrieve chronic conditions: ${e.toString()}',
      );
    }
  }

  Future<List<ChronicCondition>> getActiveChronicConditions({
    String? profileId,
  }) async {
    try {
      return await _medicalRecordDao.getActiveChronicConditions(
        profileId: profileId,
      );
    } catch (e) {
      throw ChronicConditionServiceException(
        'Failed to retrieve active chronic conditions: ${e.toString()}',
      );
    }
  }

  Future<ChronicCondition?> getChronicConditionById(String id) async {
    try {
      if (id.isEmpty) {
        throw const ChronicConditionServiceException(
          'Chronic condition ID cannot be empty',
        );
      }

      final conditions = await _database.select(_database.chronicConditions).get();
      return conditions.where((c) => c.id == id).firstOrNull;
    } catch (e) {
      if (e is ChronicConditionServiceException) rethrow;
      throw ChronicConditionServiceException(
        'Failed to retrieve chronic condition: ${e.toString()}',
      );
    }
  }

  Future<String> createChronicCondition(
    CreateChronicConditionRequest request,
  ) async {
    try {
      _validateCreateChronicConditionRequest(request);

      final conditionId = 'chronic_condition_${DateTime.now().millisecondsSinceEpoch}';

      // Create chronic condition-specific record
      final conditionCompanion = ChronicConditionsCompanion(
        id: Value(conditionId),
        profileId: Value(request.profileId),
        recordType: const Value('chronic_condition'),
        title: Value(request.title.trim()),
        description: Value(request.description?.trim()),
        recordDate: Value(request.recordDate),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        isActive: const Value(true),
        // Chronic condition-specific fields
        conditionName: Value(request.conditionName.trim()),
        diagnosisDate: Value(request.diagnosisDate),
        diagnosingProvider: Value(request.diagnosingProvider?.trim()),
        severity: Value(request.severity),
        status: Value(request.status),
        treatment: Value(request.treatment?.trim()),
        managementPlan: Value(request.managementPlan?.trim()),
        relatedMedications: Value(request.relatedMedications?.trim()),
      );

      // Create general medical record entry
      final medicalRecordCompanion = MedicalRecordsCompanion(
        id: Value(conditionId),
        profileId: Value(request.profileId),
        recordType: const Value('chronic_condition'),
        title: Value(request.title.trim()),
        description: Value(request.description?.trim()),
        recordDate: Value(request.recordDate),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        isActive: const Value(true),
      );

      // Save both records in a transaction
      await _database.transaction(() async {
        await _medicalRecordDao.createChronicCondition(conditionCompanion);
        await _medicalRecordDao.createRecord(medicalRecordCompanion);
      });

      return conditionId;
    } catch (e) {
      if (e is ChronicConditionServiceException) rethrow;
      throw ChronicConditionServiceException(
        'Failed to create chronic condition: ${e.toString()}',
      );
    }
  }

  Future<bool> updateChronicCondition(
    String id,
    UpdateChronicConditionRequest request,
  ) async {
    try {
      if (id.isEmpty) {
        throw const ChronicConditionServiceException(
          'Chronic condition ID cannot be empty',
        );
      }

      final existingCondition = await getChronicConditionById(id);
      if (existingCondition == null) {
        throw const ChronicConditionServiceException(
          'Chronic condition not found',
        );
      }

      _validateUpdateChronicConditionRequest(request);

      final conditionCompanion = ChronicConditionsCompanion(
        title: request.title != null
            ? Value(request.title!.trim())
            : const Value.absent(),
        description: request.description != null
            ? Value(request.description?.trim())
            : const Value.absent(),
        recordDate: request.recordDate != null
            ? Value(request.recordDate!)
            : const Value.absent(),
        conditionName: request.conditionName != null
            ? Value(request.conditionName!.trim())
            : const Value.absent(),
        diagnosisDate: request.diagnosisDate != null
            ? Value(request.diagnosisDate!)
            : const Value.absent(),
        diagnosingProvider: request.diagnosingProvider != null
            ? Value(request.diagnosingProvider?.trim())
            : const Value.absent(),
        severity: request.severity != null
            ? Value(request.severity!)
            : const Value.absent(),
        status: request.status != null
            ? Value(request.status!)
            : const Value.absent(),
        treatment: request.treatment != null
            ? Value(request.treatment?.trim())
            : const Value.absent(),
        managementPlan: request.managementPlan != null
            ? Value(request.managementPlan?.trim())
            : const Value.absent(),
        relatedMedications: request.relatedMedications != null
            ? Value(request.relatedMedications?.trim())
            : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      );

      final rowsAffected = await (_database.update(
        _database.chronicConditions,
      )..where((c) => c.id.equals(id))).write(conditionCompanion);

      return rowsAffected > 0;
    } catch (e) {
      if (e is ChronicConditionServiceException) rethrow;
      throw ChronicConditionServiceException(
        'Failed to update chronic condition: ${e.toString()}',
      );
    }
  }

  Future<bool> deleteChronicCondition(String id) async {
    try {
      if (id.isEmpty) {
        throw const ChronicConditionServiceException(
          'Chronic condition ID cannot be empty',
        );
      }

      final existingCondition = await getChronicConditionById(id);
      if (existingCondition == null) {
        throw const ChronicConditionServiceException(
          'Chronic condition not found',
        );
      }

      final rowsAffected =
          await (_database.update(
            _database.chronicConditions,
          )..where((c) => c.id.equals(id))).write(
            ChronicConditionsCompanion(
              isActive: const Value(false),
              updatedAt: Value(DateTime.now()),
            ),
          );

      return rowsAffected > 0;
    } catch (e) {
      if (e is ChronicConditionServiceException) rethrow;
      throw ChronicConditionServiceException(
        'Failed to delete chronic condition: ${e.toString()}',
      );
    }
  }

  // Query Operations

  Future<List<ChronicCondition>> getChronicConditionsBySeverity(
    String severity, {
    String? profileId,
  }) async {
    try {
      if (!ConditionSeverity.isValidSeverity(severity)) {
        throw ChronicConditionServiceException('Invalid severity: $severity');
      }

      var query = _database.select(_database.chronicConditions)
        ..where((c) => c.isActive.equals(true) & c.severity.equals(severity));

      if (profileId != null) {
        query = query..where((c) => c.profileId.equals(profileId));
      }

      query = query
        ..orderBy([
          (c) => OrderingTerm(expression: c.diagnosisDate, mode: OrderingMode.desc),
        ]);

      return await query.get();
    } catch (e) {
      if (e is ChronicConditionServiceException) rethrow;
      throw ChronicConditionServiceException(
        'Failed to retrieve chronic conditions by severity: ${e.toString()}',
      );
    }
  }

  Future<List<ChronicCondition>> getChronicConditionsByStatus(
    String status, {
    String? profileId,
  }) async {
    try {
      if (!ConditionStatus.isValidStatus(status)) {
        throw ChronicConditionServiceException('Invalid status: $status');
      }

      var query = _database.select(_database.chronicConditions)
        ..where((c) => c.isActive.equals(true) & c.status.equals(status));

      if (profileId != null) {
        query = query..where((c) => c.profileId.equals(profileId));
      }

      query = query
        ..orderBy([
          (c) => OrderingTerm(expression: c.diagnosisDate, mode: OrderingMode.desc),
        ]);

      return await query.get();
    } catch (e) {
      if (e is ChronicConditionServiceException) rethrow;
      throw ChronicConditionServiceException(
        'Failed to retrieve chronic conditions by status: ${e.toString()}',
      );
    }
  }

  Future<List<ChronicCondition>> getChronicConditionsByName(
    String conditionName, {
    String? profileId,
  }) async {
    try {
      if (conditionName.trim().isEmpty) {
        throw const ChronicConditionServiceException(
          'Condition name cannot be empty',
        );
      }

      var query = _database.select(_database.chronicConditions)
        ..where((c) =>
            c.isActive.equals(true) &
            c.conditionName.like('%${conditionName.trim()}%'));

      if (profileId != null) {
        query = query..where((c) => c.profileId.equals(profileId));
      }

      query = query
        ..orderBy([
          (c) => OrderingTerm(expression: c.diagnosisDate, mode: OrderingMode.desc),
        ]);

      return await query.get();
    } catch (e) {
      if (e is ChronicConditionServiceException) rethrow;
      throw ChronicConditionServiceException(
        'Failed to retrieve chronic conditions by name: ${e.toString()}',
      );
    }
  }

  Future<List<ChronicCondition>> getActiveConditions({
    String? profileId,
  }) async {
    try {
      return await getChronicConditionsByStatus(
        ConditionStatus.active,
        profileId: profileId,
      );
    } catch (e) {
      throw ChronicConditionServiceException(
        'Failed to retrieve active conditions: ${e.toString()}',
      );
    }
  }

  Future<List<ChronicCondition>> getManagedConditions({
    String? profileId,
  }) async {
    try {
      return await getChronicConditionsByStatus(
        ConditionStatus.managed,
        profileId: profileId,
      );
    } catch (e) {
      throw ChronicConditionServiceException(
        'Failed to retrieve managed conditions: ${e.toString()}',
      );
    }
  }

  Future<List<ChronicCondition>> getResolvedConditions({
    String? profileId,
  }) async {
    try {
      return await getChronicConditionsByStatus(
        ConditionStatus.resolved,
        profileId: profileId,
      );
    } catch (e) {
      throw ChronicConditionServiceException(
        'Failed to retrieve resolved conditions: ${e.toString()}',
      );
    }
  }

  // Analytics

  Future<Map<String, int>> getConditionCountsBySeverity({
    String? profileId,
  }) async {
    try {
      final Map<String, int> counts = {};

      for (final severity in ConditionSeverity.allSeverities) {
        final conditions = await getChronicConditionsBySeverity(
          severity,
          profileId: profileId,
        );
        counts[severity] = conditions.length;
      }

      return counts;
    } catch (e) {
      throw ChronicConditionServiceException(
        'Failed to retrieve condition counts by severity: ${e.toString()}',
      );
    }
  }

  Future<Map<String, int>> getConditionCountsByStatus({
    String? profileId,
  }) async {
    try {
      final Map<String, int> counts = {};

      for (final status in ConditionStatus.allStatuses) {
        final conditions = await getChronicConditionsByStatus(
          status,
          profileId: profileId,
        );
        counts[status] = conditions.length;
      }

      return counts;
    } catch (e) {
      throw ChronicConditionServiceException(
        'Failed to retrieve condition counts by status: ${e.toString()}',
      );
    }
  }

  Future<Map<String, int>> getConditionCountsByName({
    String? profileId,
  }) async {
    try {
      var query = _database.select(_database.chronicConditions)
        ..where((c) => c.isActive.equals(true));

      if (profileId != null) {
        query = query..where((c) => c.profileId.equals(profileId));
      }

      final conditions = await query.get();
      final Map<String, int> counts = {};

      for (final condition in conditions) {
        final conditionName = condition.conditionName;
        counts[conditionName] = (counts[conditionName] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      throw ChronicConditionServiceException(
        'Failed to retrieve condition counts by name: ${e.toString()}',
      );
    }
  }

  // Status Management

  Future<bool> updateConditionStatus(String id, String status) async {
    try {
      if (id.isEmpty) {
        throw const ChronicConditionServiceException(
          'Chronic condition ID cannot be empty',
        );
      }
      if (!ConditionStatus.isValidStatus(status)) {
        throw ChronicConditionServiceException('Invalid status: $status');
      }

      final rowsAffected =
          await (_database.update(
            _database.chronicConditions,
          )..where((c) => c.id.equals(id))).write(
            ChronicConditionsCompanion(
              status: Value(status),
              updatedAt: Value(DateTime.now()),
            ),
          );

      return rowsAffected > 0;
    } catch (e) {
      if (e is ChronicConditionServiceException) rethrow;
      throw ChronicConditionServiceException(
        'Failed to update condition status: ${e.toString()}',
      );
    }
  }

  Future<bool> markAsActive(String id) async {
    return await updateConditionStatus(id, ConditionStatus.active);
  }

  Future<bool> markAsManaged(String id) async {
    return await updateConditionStatus(id, ConditionStatus.managed);
  }

  Future<bool> markAsResolved(String id) async {
    return await updateConditionStatus(id, ConditionStatus.resolved);
  }

  // Stream Operations

  Stream<List<ChronicCondition>> watchActiveChronicConditions({
    String? profileId,
  }) {
    return _medicalRecordDao.watchActiveChronicConditions(
      profileId: profileId,
    );
  }

  // Private Helper Methods

  void _validateCreateChronicConditionRequest(
    CreateChronicConditionRequest request,
  ) {
    if (request.profileId.isEmpty) {
      throw const ChronicConditionServiceException('Profile ID cannot be empty');
    }
    if (request.title.trim().isEmpty) {
      throw const ChronicConditionServiceException('Title cannot be empty');
    }
    if (request.conditionName.trim().isEmpty) {
      throw const ChronicConditionServiceException(
        'Condition name cannot be empty',
      );
    }
    if (!ConditionSeverity.isValidSeverity(request.severity)) {
      throw ChronicConditionServiceException(
        'Invalid severity: ${request.severity}',
      );
    }
    if (!ConditionStatus.isValidStatus(request.status)) {
      throw ChronicConditionServiceException(
        'Invalid status: ${request.status}',
      );
    }
    if (request.diagnosisDate.isAfter(DateTime.now())) {
      throw const ChronicConditionServiceException(
        'Diagnosis date cannot be in the future',
      );
    }
  }

  void _validateUpdateChronicConditionRequest(
    UpdateChronicConditionRequest request,
  ) {
    if (request.title != null && request.title!.trim().isEmpty) {
      throw const ChronicConditionServiceException('Title cannot be empty');
    }
    if (request.conditionName != null &&
        request.conditionName!.trim().isEmpty) {
      throw const ChronicConditionServiceException(
        'Condition name cannot be empty',
      );
    }
    if (request.severity != null &&
        !ConditionSeverity.isValidSeverity(request.severity!)) {
      throw ChronicConditionServiceException(
        'Invalid severity: ${request.severity}',
      );
    }
    if (request.status != null &&
        !ConditionStatus.isValidStatus(request.status!)) {
      throw ChronicConditionServiceException(
        'Invalid status: ${request.status}',
      );
    }
    if (request.diagnosisDate != null &&
        request.diagnosisDate!.isAfter(DateTime.now())) {
      throw const ChronicConditionServiceException(
        'Diagnosis date cannot be in the future',
      );
    }
  }
}

// Data Transfer Objects

class CreateChronicConditionRequest {
  final String profileId;
  final String title;
  final String? description;
  final DateTime recordDate;
  final String conditionName;
  final DateTime diagnosisDate;
  final String? diagnosingProvider;
  final String severity;
  final String status;
  final String? treatment;
  final String? managementPlan;
  final String? relatedMedications;

  const CreateChronicConditionRequest({
    required this.profileId,
    required this.title,
    this.description,
    required this.recordDate,
    required this.conditionName,
    required this.diagnosisDate,
    this.diagnosingProvider,
    required this.severity,
    required this.status,
    this.treatment,
    this.managementPlan,
    this.relatedMedications,
  });
}

class UpdateChronicConditionRequest {
  final String? title;
  final String? description;
  final DateTime? recordDate;
  final String? conditionName;
  final DateTime? diagnosisDate;
  final String? diagnosingProvider;
  final String? severity;
  final String? status;
  final String? treatment;
  final String? managementPlan;
  final String? relatedMedications;

  const UpdateChronicConditionRequest({
    this.title,
    this.description,
    this.recordDate,
    this.conditionName,
    this.diagnosisDate,
    this.diagnosingProvider,
    this.severity,
    this.status,
    this.treatment,
    this.managementPlan,
    this.relatedMedications,
  });
}

// Exceptions

class ChronicConditionServiceException implements Exception {
  final String message;

  const ChronicConditionServiceException(this.message);

  @override
  String toString() => 'ChronicConditionServiceException: $message';
}