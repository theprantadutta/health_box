import 'package:drift/drift.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/medical_record_dao.dart';

class MentalHealthRecordService {
  final MedicalRecordDao _medicalRecordDao;
  final AppDatabase _database;

  MentalHealthRecordService({
    MedicalRecordDao? medicalRecordDao,
    AppDatabase? database,
  }) : _database = database ?? AppDatabase.instance,
       _medicalRecordDao =
           medicalRecordDao ??
           MedicalRecordDao(database ?? AppDatabase.instance);

  Future<String> createMentalHealthRecord(CreateMentalHealthRecordRequest request) async {
    try {
      _validateCreateMentalHealthRecordRequest(request);

      final mentalHealthRecordId =
          'mental_health_${DateTime.now().millisecondsSinceEpoch}';

      // Create mental health record-specific record
      final mentalHealthCompanion = MentalHealthRecordsCompanion(
        id: Value(mentalHealthRecordId),
        profileId: Value(request.profileId),
        recordType: const Value('mental_health'),
        title: Value(request.title.trim()),
        description: Value(request.description?.trim()),
        recordDate: Value(request.recordDate),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        isActive: const Value(true),
        // Mental health record-specific fields
        providerName: Value(request.providerName?.trim()),
        facility: Value(request.facility?.trim()),
        sessionDate: Value(request.sessionDate),
        sessionType: Value(request.sessionType),
        moodRating: Value(request.moodRating),
        progressNotes: Value(request.sessionNotes?.trim()),
        moodAssessment: Value(request.assessment?.trim()),
        treatmentGoals: Value(request.treatmentPlan?.trim()),
        medicationDiscussion: Value(request.medications?.trim()),
      );

      // Create general medical record entry
      final medicalRecordCompanion = MedicalRecordsCompanion(
        id: Value(mentalHealthRecordId),
        profileId: Value(request.profileId),
        recordType: const Value('mental_health'),
        title: Value(request.title.trim()),
        description: Value(request.description?.trim()),
        recordDate: Value(request.recordDate),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        isActive: const Value(true),
      );

      // Save both records in a transaction
      await _database.transaction(() async {
        await _medicalRecordDao.createMentalHealthRecord(mentalHealthCompanion);
        await _medicalRecordDao.createRecord(medicalRecordCompanion);
      });

      return mentalHealthRecordId;
    } catch (e) {
      if (e is MentalHealthRecordServiceException) rethrow;
      throw MentalHealthRecordServiceException(
        'Failed to create mental health record: ${e.toString()}',
      );
    }
  }

  // Private Helper Methods

  void _validateCreateMentalHealthRecordRequest(CreateMentalHealthRecordRequest request) {
    if (request.profileId.isEmpty) {
      throw const MentalHealthRecordServiceException('Profile ID cannot be empty');
    }
    if (request.title.trim().isEmpty) {
      throw const MentalHealthRecordServiceException('Title cannot be empty');
    }
    if (request.sessionDate.isAfter(DateTime.now().add(const Duration(days: 1)))) {
      throw const MentalHealthRecordServiceException(
        'Session date cannot be in the future',
      );
    }
    if (request.moodRating < 1 || request.moodRating > 10) {
      throw const MentalHealthRecordServiceException(
        'Mood rating must be between 1 and 10',
      );
    }
  }
}

// Data Transfer Objects

class CreateMentalHealthRecordRequest {
  final String profileId;
  final String title;
  final String? description;
  final DateTime recordDate;
  final String? providerName;
  final String? facility;
  final DateTime sessionDate;
  final String sessionType;
  final int moodRating;
  final String? sessionNotes;
  final String? assessment;
  final String? treatmentPlan;
  final String? medications;

  const CreateMentalHealthRecordRequest({
    required this.profileId,
    required this.title,
    this.description,
    required this.recordDate,
    this.providerName,
    this.facility,
    required this.sessionDate,
    required this.sessionType,
    required this.moodRating,
    this.sessionNotes,
    this.assessment,
    this.treatmentPlan,
    this.medications,
  });
}

// Exceptions

class MentalHealthRecordServiceException implements Exception {
  final String message;

  const MentalHealthRecordServiceException(this.message);

  @override
  String toString() => 'MentalHealthRecordServiceException: $message';
}