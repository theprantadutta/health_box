import 'package:drift/drift.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/medical_record_dao.dart';

class SurgicalRecordService {
  final MedicalRecordDao _medicalRecordDao;
  final AppDatabase _database;

  SurgicalRecordService({
    MedicalRecordDao? medicalRecordDao,
    AppDatabase? database,
  }) : _database = database ?? AppDatabase.instance,
       _medicalRecordDao =
           medicalRecordDao ??
           MedicalRecordDao(database ?? AppDatabase.instance);

  // CRUD Operations

  Future<List<SurgicalRecord>> getAllSurgicalRecords({String? profileId}) async {
    try {
      return await _medicalRecordDao.getAllSurgicalRecords(profileId: profileId);
    } catch (e) {
      throw SurgicalRecordServiceException(
        'Failed to retrieve surgical records: ${e.toString()}',
      );
    }
  }

  Future<List<SurgicalRecord>> getActiveSurgicalRecords({String? profileId}) async {
    try {
      return await _medicalRecordDao.getActiveSurgicalRecords(profileId: profileId);
    } catch (e) {
      throw SurgicalRecordServiceException(
        'Failed to retrieve active surgical records: ${e.toString()}',
      );
    }
  }

  Future<SurgicalRecord?> getSurgicalRecordById(String id) async {
    try {
      if (id.isEmpty) {
        throw const SurgicalRecordServiceException('Surgical record ID cannot be empty');
      }

      final records = await _database.select(_database.surgicalRecords).get();
      return records.where((r) => r.id == id).firstOrNull;
    } catch (e) {
      if (e is SurgicalRecordServiceException) rethrow;
      throw SurgicalRecordServiceException(
        'Failed to retrieve surgical record: ${e.toString()}',
      );
    }
  }

  Future<String> createSurgicalRecord(CreateSurgicalRecordRequest request) async {
    try {
      _validateCreateSurgicalRecordRequest(request);

      final recordId = 'surgical_record_${DateTime.now().millisecondsSinceEpoch}';

      // Create surgical record-specific record
      final surgicalRecordCompanion = SurgicalRecordsCompanion(
        id: Value(recordId),
        profileId: Value(request.profileId),
        recordType: const Value('surgical_record'),
        title: Value(request.title.trim()),
        description: Value(request.description?.trim()),
        recordDate: Value(request.recordDate),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        isActive: const Value(true),
        // Surgical record-specific fields
        procedureName: Value(request.procedureName.trim()),
        surgeonName: Value(request.surgeonName?.trim()),
        hospital: Value(request.hospital?.trim()),
        operatingRoom: Value(request.operatingRoom?.trim()),
        surgeryDate: Value(request.surgeryDate),
        surgeryStartTime: Value(request.surgeryStartTime),
        surgeryEndTime: Value(request.surgeryEndTime),
        anesthesiaType: Value(request.anesthesiaType?.trim()),
        anesthesiologist: Value(request.anesthesiologist?.trim()),
        indication: Value(request.indication?.trim()),
        findings: Value(request.findings?.trim()),
        complications: Value(request.complications?.trim()),
        recoveryNotes: Value(request.recoveryNotes?.trim()),
        followUpPlan: Value(request.followUpPlan?.trim()),
        dischargeDate: Value(request.dischargeDate),
        isEmergency: Value(request.isEmergency),
      );

      // Create general medical record entry
      final medicalRecordCompanion = MedicalRecordsCompanion(
        id: Value(recordId),
        profileId: Value(request.profileId),
        recordType: const Value('surgical_record'),
        title: Value(request.title.trim()),
        description: Value(request.description?.trim()),
        recordDate: Value(request.recordDate),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        isActive: const Value(true),
      );

      // Save both records in a transaction
      await _database.transaction(() async {
        await _medicalRecordDao.createSurgicalRecord(surgicalRecordCompanion);
        await _medicalRecordDao.createRecord(medicalRecordCompanion);
      });

      return recordId;
    } catch (e) {
      if (e is SurgicalRecordServiceException) rethrow;
      throw SurgicalRecordServiceException(
        'Failed to create surgical record: ${e.toString()}',
      );
    }
  }

  Future<bool> updateSurgicalRecord(
    String id,
    UpdateSurgicalRecordRequest request,
  ) async {
    try {
      if (id.isEmpty) {
        throw const SurgicalRecordServiceException('Surgical record ID cannot be empty');
      }

      final existingRecord = await getSurgicalRecordById(id);
      if (existingRecord == null) {
        throw const SurgicalRecordServiceException('Surgical record not found');
      }

      _validateUpdateSurgicalRecordRequest(request);

      final surgicalRecordCompanion = SurgicalRecordsCompanion(
        title: request.title != null
            ? Value(request.title!.trim())
            : const Value.absent(),
        description: request.description != null
            ? Value(request.description?.trim())
            : const Value.absent(),
        recordDate: request.recordDate != null
            ? Value(request.recordDate!)
            : const Value.absent(),
        procedureName: request.procedureName != null
            ? Value(request.procedureName!.trim())
            : const Value.absent(),
        surgeonName: request.surgeonName != null
            ? Value(request.surgeonName?.trim())
            : const Value.absent(),
        hospital: request.hospital != null
            ? Value(request.hospital?.trim())
            : const Value.absent(),
        operatingRoom: request.operatingRoom != null
            ? Value(request.operatingRoom?.trim())
            : const Value.absent(),
        surgeryDate: request.surgeryDate != null
            ? Value(request.surgeryDate!)
            : const Value.absent(),
        surgeryStartTime: request.surgeryStartTime != null
            ? Value(request.surgeryStartTime)
            : const Value.absent(),
        surgeryEndTime: request.surgeryEndTime != null
            ? Value(request.surgeryEndTime)
            : const Value.absent(),
        anesthesiaType: request.anesthesiaType != null
            ? Value(request.anesthesiaType?.trim())
            : const Value.absent(),
        anesthesiologist: request.anesthesiologist != null
            ? Value(request.anesthesiologist?.trim())
            : const Value.absent(),
        indication: request.indication != null
            ? Value(request.indication?.trim())
            : const Value.absent(),
        findings: request.findings != null
            ? Value(request.findings?.trim())
            : const Value.absent(),
        complications: request.complications != null
            ? Value(request.complications?.trim())
            : const Value.absent(),
        recoveryNotes: request.recoveryNotes != null
            ? Value(request.recoveryNotes?.trim())
            : const Value.absent(),
        followUpPlan: request.followUpPlan != null
            ? Value(request.followUpPlan?.trim())
            : const Value.absent(),
        dischargeDate: request.dischargeDate != null
            ? Value(request.dischargeDate)
            : const Value.absent(),
        isEmergency: request.isEmergency != null
            ? Value(request.isEmergency!)
            : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      );

      final rowsAffected = await (_database.update(
        _database.surgicalRecords,
      )..where((s) => s.id.equals(id))).write(surgicalRecordCompanion);

      return rowsAffected > 0;
    } catch (e) {
      if (e is SurgicalRecordServiceException) rethrow;
      throw SurgicalRecordServiceException(
        'Failed to update surgical record: ${e.toString()}',
      );
    }
  }

  Future<bool> deleteSurgicalRecord(String id) async {
    try {
      if (id.isEmpty) {
        throw const SurgicalRecordServiceException('Surgical record ID cannot be empty');
      }

      final existingRecord = await getSurgicalRecordById(id);
      if (existingRecord == null) {
        throw const SurgicalRecordServiceException('Surgical record not found');
      }

      final rowsAffected =
          await (_database.update(
            _database.surgicalRecords,
          )..where((s) => s.id.equals(id))).write(
            SurgicalRecordsCompanion(
              isActive: const Value(false),
              updatedAt: Value(DateTime.now()),
            ),
          );

      return rowsAffected > 0;
    } catch (e) {
      if (e is SurgicalRecordServiceException) rethrow;
      throw SurgicalRecordServiceException(
        'Failed to delete surgical record: ${e.toString()}',
      );
    }
  }

  // Query Operations

  Future<List<SurgicalRecord>> getEmergencySurgeries({String? profileId}) async {
    try {
      var query = _database.select(_database.surgicalRecords)
        ..where((s) => s.isActive.equals(true) & s.isEmergency.equals(true));

      if (profileId != null) {
        query = query..where((s) => s.profileId.equals(profileId));
      }

      query = query
        ..orderBy([
          (s) => OrderingTerm(expression: s.surgeryDate, mode: OrderingMode.desc),
        ]);

      return await query.get();
    } catch (e) {
      throw SurgicalRecordServiceException(
        'Failed to retrieve emergency surgeries: ${e.toString()}',
      );
    }
  }

  Future<List<SurgicalRecord>> getSurgeriesByProcedure(
    String procedureName, {
    String? profileId,
  }) async {
    try {
      if (procedureName.trim().isEmpty) {
        throw const SurgicalRecordServiceException('Procedure name cannot be empty');
      }

      var query = _database.select(_database.surgicalRecords)
        ..where((s) =>
            s.isActive.equals(true) &
            s.procedureName.like('%${procedureName.trim()}%'));

      if (profileId != null) {
        query = query..where((s) => s.profileId.equals(profileId));
      }

      query = query
        ..orderBy([
          (s) => OrderingTerm(expression: s.surgeryDate, mode: OrderingMode.desc),
        ]);

      return await query.get();
    } catch (e) {
      if (e is SurgicalRecordServiceException) rethrow;
      throw SurgicalRecordServiceException(
        'Failed to retrieve surgeries by procedure: ${e.toString()}',
      );
    }
  }

  Future<List<SurgicalRecord>> getSurgeriesBySurgeon(
    String surgeonName, {
    String? profileId,
  }) async {
    try {
      if (surgeonName.trim().isEmpty) {
        throw const SurgicalRecordServiceException('Surgeon name cannot be empty');
      }

      var query = _database.select(_database.surgicalRecords)
        ..where((s) =>
            s.isActive.equals(true) &
            s.surgeonName.isNotNull() &
            s.surgeonName.like('%${surgeonName.trim()}%'));

      if (profileId != null) {
        query = query..where((s) => s.profileId.equals(profileId));
      }

      query = query
        ..orderBy([
          (s) => OrderingTerm(expression: s.surgeryDate, mode: OrderingMode.desc),
        ]);

      return await query.get();
    } catch (e) {
      if (e is SurgicalRecordServiceException) rethrow;
      throw SurgicalRecordServiceException(
        'Failed to retrieve surgeries by surgeon: ${e.toString()}',
      );
    }
  }

  Future<List<SurgicalRecord>> getSurgeriesWithComplications({
    String? profileId,
  }) async {
    try {
      var query = _database.select(_database.surgicalRecords)
        ..where((s) =>
            s.isActive.equals(true) &
            s.complications.isNotNull() &
            s.complications.isNotValue(''));

      if (profileId != null) {
        query = query..where((s) => s.profileId.equals(profileId));
      }

      query = query
        ..orderBy([
          (s) => OrderingTerm(expression: s.surgeryDate, mode: OrderingMode.desc),
        ]);

      return await query.get();
    } catch (e) {
      throw SurgicalRecordServiceException(
        'Failed to retrieve surgeries with complications: ${e.toString()}',
      );
    }
  }

  // Analytics

  Future<Map<String, int>> getSurgeryCountsByProcedure({
    String? profileId,
  }) async {
    try {
      var query = _database.select(_database.surgicalRecords)
        ..where((s) => s.isActive.equals(true));

      if (profileId != null) {
        query = query..where((s) => s.profileId.equals(profileId));
      }

      final surgeries = await query.get();
      final Map<String, int> counts = {};

      for (final surgery in surgeries) {
        final procedureName = surgery.procedureName;
        counts[procedureName] = (counts[procedureName] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      throw SurgicalRecordServiceException(
        'Failed to retrieve surgery counts by procedure: ${e.toString()}',
      );
    }
  }

  Future<Map<String, int>> getSurgeryCountsBySurgeon({
    String? profileId,
  }) async {
    try {
      var query = _database.select(_database.surgicalRecords)
        ..where((s) => s.isActive.equals(true) & s.surgeonName.isNotNull());

      if (profileId != null) {
        query = query..where((s) => s.profileId.equals(profileId));
      }

      final surgeries = await query.get();
      final Map<String, int> counts = {};

      for (final surgery in surgeries) {
        final surgeonName = surgery.surgeonName ?? 'Unknown';
        counts[surgeonName] = (counts[surgeonName] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      throw SurgicalRecordServiceException(
        'Failed to retrieve surgery counts by surgeon: ${e.toString()}',
      );
    }
  }

  // Stream Operations

  Stream<List<SurgicalRecord>> watchActiveSurgicalRecords({String? profileId}) {
    return _medicalRecordDao.watchActiveSurgicalRecords(profileId: profileId);
  }

  // Private Helper Methods

  void _validateCreateSurgicalRecordRequest(CreateSurgicalRecordRequest request) {
    if (request.profileId.isEmpty) {
      throw const SurgicalRecordServiceException('Profile ID cannot be empty');
    }
    if (request.title.trim().isEmpty) {
      throw const SurgicalRecordServiceException('Title cannot be empty');
    }
    if (request.procedureName.trim().isEmpty) {
      throw const SurgicalRecordServiceException('Procedure name cannot be empty');
    }
    if (request.surgeryDate.isAfter(DateTime.now())) {
      throw const SurgicalRecordServiceException(
        'Surgery date cannot be in the future',
      );
    }
    if (request.surgeryStartTime != null &&
        request.surgeryEndTime != null &&
        request.surgeryStartTime!.isAfter(request.surgeryEndTime!)) {
      throw const SurgicalRecordServiceException(
        'Surgery start time cannot be after end time',
      );
    }
    if (request.dischargeDate != null &&
        request.dischargeDate!.isBefore(request.surgeryDate)) {
      throw const SurgicalRecordServiceException(
        'Discharge date cannot be before surgery date',
      );
    }
  }

  void _validateUpdateSurgicalRecordRequest(UpdateSurgicalRecordRequest request) {
    if (request.title != null && request.title!.trim().isEmpty) {
      throw const SurgicalRecordServiceException('Title cannot be empty');
    }
    if (request.procedureName != null && request.procedureName!.trim().isEmpty) {
      throw const SurgicalRecordServiceException('Procedure name cannot be empty');
    }
    if (request.surgeryDate != null && request.surgeryDate!.isAfter(DateTime.now())) {
      throw const SurgicalRecordServiceException(
        'Surgery date cannot be in the future',
      );
    }
    if (request.surgeryStartTime != null &&
        request.surgeryEndTime != null &&
        request.surgeryStartTime!.isAfter(request.surgeryEndTime!)) {
      throw const SurgicalRecordServiceException(
        'Surgery start time cannot be after end time',
      );
    }
    if (request.dischargeDate != null &&
        request.surgeryDate != null &&
        request.dischargeDate!.isBefore(request.surgeryDate!)) {
      throw const SurgicalRecordServiceException(
        'Discharge date cannot be before surgery date',
      );
    }
  }
}

// Data Transfer Objects

class CreateSurgicalRecordRequest {
  final String profileId;
  final String title;
  final String? description;
  final DateTime recordDate;
  final String procedureName;
  final String? surgeonName;
  final String? hospital;
  final String? operatingRoom;
  final DateTime surgeryDate;
  final DateTime? surgeryStartTime;
  final DateTime? surgeryEndTime;
  final String? anesthesiaType;
  final String? anesthesiologist;
  final String? indication;
  final String? findings;
  final String? complications;
  final String? recoveryNotes;
  final String? followUpPlan;
  final DateTime? dischargeDate;
  final bool isEmergency;

  const CreateSurgicalRecordRequest({
    required this.profileId,
    required this.title,
    this.description,
    required this.recordDate,
    required this.procedureName,
    this.surgeonName,
    this.hospital,
    this.operatingRoom,
    required this.surgeryDate,
    this.surgeryStartTime,
    this.surgeryEndTime,
    this.anesthesiaType,
    this.anesthesiologist,
    this.indication,
    this.findings,
    this.complications,
    this.recoveryNotes,
    this.followUpPlan,
    this.dischargeDate,
    this.isEmergency = false,
  });
}

class UpdateSurgicalRecordRequest {
  final String? title;
  final String? description;
  final DateTime? recordDate;
  final String? procedureName;
  final String? surgeonName;
  final String? hospital;
  final String? operatingRoom;
  final DateTime? surgeryDate;
  final DateTime? surgeryStartTime;
  final DateTime? surgeryEndTime;
  final String? anesthesiaType;
  final String? anesthesiologist;
  final String? indication;
  final String? findings;
  final String? complications;
  final String? recoveryNotes;
  final String? followUpPlan;
  final DateTime? dischargeDate;
  final bool? isEmergency;

  const UpdateSurgicalRecordRequest({
    this.title,
    this.description,
    this.recordDate,
    this.procedureName,
    this.surgeonName,
    this.hospital,
    this.operatingRoom,
    this.surgeryDate,
    this.surgeryStartTime,
    this.surgeryEndTime,
    this.anesthesiaType,
    this.anesthesiologist,
    this.indication,
    this.findings,
    this.complications,
    this.recoveryNotes,
    this.followUpPlan,
    this.dischargeDate,
    this.isEmergency,
  });
}

// Exceptions

class SurgicalRecordServiceException implements Exception {
  final String message;

  const SurgicalRecordServiceException(this.message);

  @override
  String toString() => 'SurgicalRecordServiceException: $message';
}