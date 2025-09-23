import 'package:drift/drift.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/medical_record_dao.dart';

class DentalRecordService {
  final MedicalRecordDao _medicalRecordDao;
  final AppDatabase _database;

  DentalRecordService({
    MedicalRecordDao? medicalRecordDao,
    AppDatabase? database,
  }) : _database = database ?? AppDatabase.instance,
       _medicalRecordDao =
           medicalRecordDao ??
           MedicalRecordDao(database ?? AppDatabase.instance);

  Future<String> createDentalRecord(CreateDentalRecordRequest request) async {
    try {
      _validateCreateDentalRecordRequest(request);

      final dentalRecordId =
          'dental_${DateTime.now().millisecondsSinceEpoch}';

      // Create dental record-specific record
      final dentalCompanion = DentalRecordsCompanion(
        id: Value(dentalRecordId),
        profileId: Value(request.profileId),
        recordType: const Value('dental'),
        title: Value(request.title.trim()),
        description: Value(request.description?.trim()),
        recordDate: Value(request.recordDate),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        isActive: const Value(true),
        // Dental record-specific fields
        dentistName: Value(request.dentistName?.trim()),
        dentalOffice: Value(request.clinic?.trim()),
        appointmentDate: Value(request.visitDate),
        procedureType: Value(request.visitType),
        treatmentProvided: Value(request.proceduresPerformed?.trim()),
        clinicalFindings: Value(request.treatmentDetails?.trim()),
        diagnosis: Value(request.notes?.trim()),
      );

      // Create general medical record entry
      final medicalRecordCompanion = MedicalRecordsCompanion(
        id: Value(dentalRecordId),
        profileId: Value(request.profileId),
        recordType: const Value('dental'),
        title: Value(request.title.trim()),
        description: Value(request.description?.trim()),
        recordDate: Value(request.recordDate),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        isActive: const Value(true),
      );

      // Save both records in a transaction
      await _database.transaction(() async {
        await _medicalRecordDao.createDentalRecord(dentalCompanion);
        await _medicalRecordDao.createRecord(medicalRecordCompanion);
      });

      return dentalRecordId;
    } catch (e) {
      if (e is DentalRecordServiceException) rethrow;
      throw DentalRecordServiceException(
        'Failed to create dental record: ${e.toString()}',
      );
    }
  }

  // Private Helper Methods

  void _validateCreateDentalRecordRequest(CreateDentalRecordRequest request) {
    if (request.profileId.isEmpty) {
      throw const DentalRecordServiceException('Profile ID cannot be empty');
    }
    if (request.title.trim().isEmpty) {
      throw const DentalRecordServiceException('Title cannot be empty');
    }
    if (request.visitDate.isAfter(DateTime.now().add(const Duration(days: 1)))) {
      throw const DentalRecordServiceException(
        'Visit date cannot be in the future',
      );
    }
  }
}

// Data Transfer Objects

class CreateDentalRecordRequest {
  final String profileId;
  final String title;
  final String? description;
  final DateTime recordDate;
  final String? dentistName;
  final String? clinic;
  final DateTime visitDate;
  final String visitType;
  final String? proceduresPerformed;
  final String? treatmentDetails;
  final String? notes;

  const CreateDentalRecordRequest({
    required this.profileId,
    required this.title,
    this.description,
    required this.recordDate,
    this.dentistName,
    this.clinic,
    required this.visitDate,
    required this.visitType,
    this.proceduresPerformed,
    this.treatmentDetails,
    this.notes,
  });
}

// Exceptions

class DentalRecordServiceException implements Exception {
  final String message;

  const DentalRecordServiceException(this.message);

  @override
  String toString() => 'DentalRecordServiceException: $message';
}