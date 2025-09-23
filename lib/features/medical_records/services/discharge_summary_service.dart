import 'package:drift/drift.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/medical_record_dao.dart';

class DischargeSummaryService {
  final MedicalRecordDao _medicalRecordDao;
  final AppDatabase _database;

  DischargeSummaryService({
    MedicalRecordDao? medicalRecordDao,
    AppDatabase? database,
  }) : _database = database ?? AppDatabase.instance,
       _medicalRecordDao =
           medicalRecordDao ??
           MedicalRecordDao(database ?? AppDatabase.instance);

  Future<String> createDischargeSummary(CreateDischargeSummaryRequest request) async {
    try {
      _validateCreateDischargeSummaryRequest(request);

      final dischargeSummaryId =
          'discharge_${DateTime.now().millisecondsSinceEpoch}';

      // Create discharge summary-specific record
      final dischargeCompanion = DischargeSummariesCompanion(
        id: Value(dischargeSummaryId),
        profileId: Value(request.profileId),
        recordType: const Value('discharge_summary'),
        title: Value(request.title.trim()),
        description: Value(request.description?.trim()),
        recordDate: Value(request.recordDate),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        isActive: const Value(true),
        // Discharge summary-specific fields
        hospital: Value(request.hospital.trim()),
        admissionDate: Value(request.admissionDate),
        dischargeDate: Value(request.dischargeDate),
        attendingPhysician: Value(request.attendingPhysician?.trim()),
        principalDiagnosis: Value(request.primaryDiagnosis.trim()),
        secondaryDiagnoses: Value(request.secondaryDiagnoses?.trim()),
        hospitalCourse: Value(request.hospitalCourse?.trim()),
        dischargeDestination: Value(request.dischargeDisposition),
        dischargeCondition: Value(request.dischargeCondition?.trim()),
        dischargeMedications: Value(request.dischargeMedications?.trim()),
        followUpInstructions: Value(request.followUpInstructions?.trim()),
      );

      // Create general medical record entry
      final medicalRecordCompanion = MedicalRecordsCompanion(
        id: Value(dischargeSummaryId),
        profileId: Value(request.profileId),
        recordType: const Value('discharge_summary'),
        title: Value(request.title.trim()),
        description: Value(request.description?.trim()),
        recordDate: Value(request.recordDate),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        isActive: const Value(true),
      );

      // Save both records in a transaction
      await _database.transaction(() async {
        await _medicalRecordDao.createDischargeSummary(dischargeCompanion);
        await _medicalRecordDao.createRecord(medicalRecordCompanion);
      });

      return dischargeSummaryId;
    } catch (e) {
      if (e is DischargeSummaryServiceException) rethrow;
      throw DischargeSummaryServiceException(
        'Failed to create discharge summary: ${e.toString()}',
      );
    }
  }

  // Private Helper Methods

  void _validateCreateDischargeSummaryRequest(CreateDischargeSummaryRequest request) {
    if (request.profileId.isEmpty) {
      throw const DischargeSummaryServiceException('Profile ID cannot be empty');
    }
    if (request.title.trim().isEmpty) {
      throw const DischargeSummaryServiceException('Title cannot be empty');
    }
    if (request.hospital.trim().isEmpty) {
      throw const DischargeSummaryServiceException('Hospital cannot be empty');
    }
    if (request.primaryDiagnosis.trim().isEmpty) {
      throw const DischargeSummaryServiceException('Primary diagnosis cannot be empty');
    }
    if (request.dischargeDate.isBefore(request.admissionDate)) {
      throw const DischargeSummaryServiceException(
        'Discharge date cannot be before admission date',
      );
    }
    if (request.admissionDate.isAfter(DateTime.now().add(const Duration(days: 1)))) {
      throw const DischargeSummaryServiceException(
        'Admission date cannot be in the future',
      );
    }
  }
}

// Data Transfer Objects

class CreateDischargeSummaryRequest {
  final String profileId;
  final String title;
  final String? description;
  final DateTime recordDate;
  final String hospital;
  final DateTime admissionDate;
  final DateTime dischargeDate;
  final String? attendingPhysician;
  final String primaryDiagnosis;
  final String? secondaryDiagnoses;
  final String? hospitalCourse;
  final String dischargeDisposition;
  final String? dischargeCondition;
  final String? dischargeMedications;
  final String? followUpInstructions;

  const CreateDischargeSummaryRequest({
    required this.profileId,
    required this.title,
    this.description,
    required this.recordDate,
    required this.hospital,
    required this.admissionDate,
    required this.dischargeDate,
    this.attendingPhysician,
    required this.primaryDiagnosis,
    this.secondaryDiagnoses,
    this.hospitalCourse,
    required this.dischargeDisposition,
    this.dischargeCondition,
    this.dischargeMedications,
    this.followUpInstructions,
  });
}

// Exceptions

class DischargeSummaryServiceException implements Exception {
  final String message;

  const DischargeSummaryServiceException(this.message);

  @override
  String toString() => 'DischargeSummaryServiceException: $message';
}