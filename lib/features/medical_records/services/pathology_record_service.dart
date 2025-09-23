import 'package:drift/drift.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/medical_record_dao.dart';

class PathologyRecordService {
  final MedicalRecordDao _medicalRecordDao;
  final AppDatabase _database;

  PathologyRecordService({
    MedicalRecordDao? medicalRecordDao,
    AppDatabase? database,
  }) : _database = database ?? AppDatabase.instance,
       _medicalRecordDao =
           medicalRecordDao ??
           MedicalRecordDao(database ?? AppDatabase.instance);

  Future<String> createPathologyRecord(CreatePathologyRecordRequest request) async {
    try {
      _validateCreatePathologyRecordRequest(request);

      final pathologyRecordId =
          'pathology_${DateTime.now().millisecondsSinceEpoch}';

      // Create pathology-specific record
      final pathologyCompanion = PathologyRecordsCompanion(
        id: Value(pathologyRecordId),
        profileId: Value(request.profileId),
        recordType: const Value('pathology'),
        title: Value(request.title.trim()),
        description: Value(request.description?.trim()),
        recordDate: Value(request.recordDate),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        isActive: const Value(true),
        // Pathology-specific fields
        specimenType: Value(request.specimenType.trim()),
        specimenSite: Value(request.specimenSite?.trim()),
        collectionDate: Value(request.collectionDate),
        collectionMethod: Value(request.collectionMethod?.trim()),
        pathologist: Value(request.pathologist?.trim()),
        laboratory: Value(request.laboratory?.trim()),
        urgency: Value(request.urgencyLevel),
        grossDescription: Value(request.grossDescription?.trim()),
        microscopicFindings: Value(request.microscopicFindings?.trim()),
        diagnosis: Value(request.diagnosis?.trim()),
        isMalignant: Value(request.isMalignant),
        stagingGrading: Value(request.stagingGrading?.trim()),
        immunohistochemistry: Value(request.immunohistochemistry?.trim()),
        molecularStudies: Value(request.molecularStudies?.trim()),
        recommendation: Value(request.recommendations?.trim()),
        reportDate: Value(request.reportDate),
        referringPhysician: Value(request.referringPhysician?.trim()),
      );

      // Create general medical record entry
      final medicalRecordCompanion = MedicalRecordsCompanion(
        id: Value(pathologyRecordId),
        profileId: Value(request.profileId),
        recordType: const Value('pathology'),
        title: Value(request.title.trim()),
        description: Value(request.description?.trim()),
        recordDate: Value(request.recordDate),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        isActive: const Value(true),
      );

      // Save both records in a transaction
      await _database.transaction(() async {
        await _medicalRecordDao.createPathologyRecord(pathologyCompanion);
        await _medicalRecordDao.createRecord(medicalRecordCompanion);
      });

      return pathologyRecordId;
    } catch (e) {
      if (e is PathologyRecordServiceException) rethrow;
      throw PathologyRecordServiceException(
        'Failed to create pathology record: ${e.toString()}',
      );
    }
  }

  // Private Helper Methods

  void _validateCreatePathologyRecordRequest(CreatePathologyRecordRequest request) {
    if (request.profileId.isEmpty) {
      throw const PathologyRecordServiceException('Profile ID cannot be empty');
    }
    if (request.title.trim().isEmpty) {
      throw const PathologyRecordServiceException('Title cannot be empty');
    }
    if (request.specimenType.trim().isEmpty) {
      throw const PathologyRecordServiceException('Specimen type cannot be empty');
    }
    if (request.collectionDate.isAfter(DateTime.now().add(const Duration(days: 1)))) {
      throw const PathologyRecordServiceException(
        'Collection date cannot be in the future',
      );
    }
    if (request.reportDate != null &&
        request.reportDate!.isBefore(request.collectionDate)) {
      throw const PathologyRecordServiceException(
        'Report date cannot be before collection date',
      );
    }
  }
}

// Data Transfer Objects

class CreatePathologyRecordRequest {
  final String profileId;
  final String title;
  final String? description;
  final DateTime recordDate;
  final String specimenType;
  final String? specimenSite;
  final DateTime collectionDate;
  final String? collectionMethod;
  final String? pathologist;
  final String? laboratory;
  final String urgencyLevel;
  final String? grossDescription;
  final String? microscopicFindings;
  final String? diagnosis;
  final bool isMalignant;
  final String? stagingGrading;
  final String? immunohistochemistry;
  final String? molecularStudies;
  final String? recommendations;
  final DateTime? reportDate;
  final String? referringPhysician;

  const CreatePathologyRecordRequest({
    required this.profileId,
    required this.title,
    this.description,
    required this.recordDate,
    required this.specimenType,
    this.specimenSite,
    required this.collectionDate,
    this.collectionMethod,
    this.pathologist,
    this.laboratory,
    this.urgencyLevel = 'routine',
    this.grossDescription,
    this.microscopicFindings,
    this.diagnosis,
    this.isMalignant = false,
    this.stagingGrading,
    this.immunohistochemistry,
    this.molecularStudies,
    this.recommendations,
    this.reportDate,
    this.referringPhysician,
  });
}

// Exceptions

class PathologyRecordServiceException implements Exception {
  final String message;

  const PathologyRecordServiceException(this.message);

  @override
  String toString() => 'PathologyRecordServiceException: $message';
}