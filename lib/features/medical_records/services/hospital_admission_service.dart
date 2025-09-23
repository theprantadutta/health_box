import 'package:drift/drift.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/medical_record_dao.dart';

class HospitalAdmissionService {
  final MedicalRecordDao _medicalRecordDao;
  final AppDatabase _database;

  HospitalAdmissionService({
    MedicalRecordDao? medicalRecordDao,
    AppDatabase? database,
  }) : _database = database ?? AppDatabase.instance,
       _medicalRecordDao =
           medicalRecordDao ??
           MedicalRecordDao(database ?? AppDatabase.instance);

  Future<String> createHospitalAdmission(CreateHospitalAdmissionRequest request) async {
    try {
      _validateCreateHospitalAdmissionRequest(request);

      final hospitalAdmissionId =
          'admission_${DateTime.now().millisecondsSinceEpoch}';

      // Create hospital admission-specific record
      final admissionCompanion = HospitalAdmissionsCompanion(
        id: Value(hospitalAdmissionId),
        profileId: Value(request.profileId),
        recordType: const Value('hospital_admission'),
        title: Value(request.title.trim()),
        description: Value(request.description?.trim()),
        recordDate: Value(request.recordDate),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        isActive: const Value(true),
        // Hospital admission-specific fields
        hospital: Value(request.hospital.trim()),
        admissionDate: Value(request.admissionDate),
        admissionType: Value(request.admissionType),
        chiefComplaint: Value(request.chiefComplaint.trim()),
        reasonForAdmission: Value(request.reasonForAdmission?.trim()),
        admittingPhysician: Value(request.admittingPhysician?.trim()),
      );

      // Create general medical record entry
      final medicalRecordCompanion = MedicalRecordsCompanion(
        id: Value(hospitalAdmissionId),
        profileId: Value(request.profileId),
        recordType: const Value('hospital_admission'),
        title: Value(request.title.trim()),
        description: Value(request.description?.trim()),
        recordDate: Value(request.recordDate),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        isActive: const Value(true),
      );

      // Save both records in a transaction
      await _database.transaction(() async {
        await _medicalRecordDao.createHospitalAdmission(admissionCompanion);
        await _medicalRecordDao.createRecord(medicalRecordCompanion);
      });

      return hospitalAdmissionId;
    } catch (e) {
      if (e is HospitalAdmissionServiceException) rethrow;
      throw HospitalAdmissionServiceException(
        'Failed to create hospital admission: ${e.toString()}',
      );
    }
  }

  // Private Helper Methods

  void _validateCreateHospitalAdmissionRequest(CreateHospitalAdmissionRequest request) {
    if (request.profileId.isEmpty) {
      throw const HospitalAdmissionServiceException('Profile ID cannot be empty');
    }
    if (request.title.trim().isEmpty) {
      throw const HospitalAdmissionServiceException('Title cannot be empty');
    }
    if (request.hospital.trim().isEmpty) {
      throw const HospitalAdmissionServiceException('Hospital cannot be empty');
    }
    if (request.chiefComplaint.trim().isEmpty) {
      throw const HospitalAdmissionServiceException('Chief complaint cannot be empty');
    }
    if (request.admissionDate.isAfter(DateTime.now().add(const Duration(days: 1)))) {
      throw const HospitalAdmissionServiceException(
        'Admission date cannot be in the future',
      );
    }
  }
}

// Data Transfer Objects

class CreateHospitalAdmissionRequest {
  final String profileId;
  final String title;
  final String? description;
  final DateTime recordDate;
  final String hospital;
  final DateTime admissionDate;
  final String admissionType;
  final String chiefComplaint;
  final String? reasonForAdmission;
  final String? admittingPhysician;

  const CreateHospitalAdmissionRequest({
    required this.profileId,
    required this.title,
    this.description,
    required this.recordDate,
    required this.hospital,
    required this.admissionDate,
    required this.admissionType,
    required this.chiefComplaint,
    this.reasonForAdmission,
    this.admittingPhysician,
  });
}

// Exceptions

class HospitalAdmissionServiceException implements Exception {
  final String message;

  const HospitalAdmissionServiceException(this.message);

  @override
  String toString() => 'HospitalAdmissionServiceException: $message';
}