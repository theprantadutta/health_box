import 'package:drift/drift.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/medical_record_dao.dart';

class RadiologyRecordService {
  final MedicalRecordDao _medicalRecordDao;
  final AppDatabase _database;

  RadiologyRecordService({
    MedicalRecordDao? medicalRecordDao,
    AppDatabase? database,
  }) : _database = database ?? AppDatabase.instance,
       _medicalRecordDao =
           medicalRecordDao ??
           MedicalRecordDao(database ?? AppDatabase.instance);

  Future<String> createRadiologyRecord(CreateRadiologyRecordRequest request) async {
    try {
      final recordId = 'radiology_record_${DateTime.now().millisecondsSinceEpoch}';

      final radiologyRecordCompanion = RadiologyRecordsCompanion(
        id: Value(recordId),
        profileId: Value(request.profileId),
        recordType: const Value('radiology_record'),
        title: Value(request.title.trim()),
        description: Value(request.description?.trim()),
        recordDate: Value(request.recordDate),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        isActive: const Value(true),
        studyType: Value(request.studyType),
        bodyPart: Value(request.bodyPart?.trim()),
        radiologist: Value(request.radiologist?.trim()),
        facility: Value(request.facility?.trim()),
        studyDate: Value(request.studyDate),
        technique: Value(request.technique?.trim()),
        contrast: Value(request.contrast?.trim()),
        findings: Value(request.findings?.trim()),
        impression: Value(request.impression?.trim()),
        recommendation: Value(request.recommendation?.trim()),
        urgency: Value(request.urgency),
        isNormal: Value(request.isNormal),
        referringPhysician: Value(request.referringPhysician?.trim()),
        protocolUsed: Value(request.protocolUsed?.trim()),
      );

      final medicalRecordCompanion = MedicalRecordsCompanion(
        id: Value(recordId),
        profileId: Value(request.profileId),
        recordType: const Value('radiology_record'),
        title: Value(request.title.trim()),
        description: Value(request.description?.trim()),
        recordDate: Value(request.recordDate),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        isActive: const Value(true),
      );

      await _database.transaction(() async {
        await _medicalRecordDao.createRadiologyRecord(radiologyRecordCompanion);
        await _medicalRecordDao.createRecord(medicalRecordCompanion);
      });

      return recordId;
    } catch (e) {
      throw RadiologyRecordServiceException(
        'Failed to create radiology record: ${e.toString()}',
      );
    }
  }
}

class CreateRadiologyRecordRequest {
  final String profileId;
  final String title;
  final String? description;
  final DateTime recordDate;
  final String studyType;
  final String? bodyPart;
  final String? radiologist;
  final String? facility;
  final DateTime studyDate;
  final String? technique;
  final String? contrast;
  final String? findings;
  final String? impression;
  final String? recommendation;
  final String urgency;
  final bool isNormal;
  final String? referringPhysician;
  final String? protocolUsed;

  const CreateRadiologyRecordRequest({
    required this.profileId,
    required this.title,
    this.description,
    required this.recordDate,
    required this.studyType,
    this.bodyPart,
    this.radiologist,
    this.facility,
    required this.studyDate,
    this.technique,
    this.contrast,
    this.findings,
    this.impression,
    this.recommendation,
    required this.urgency,
    this.isNormal = false,
    this.referringPhysician,
    this.protocolUsed,
  });
}

class RadiologyRecordServiceException implements Exception {
  final String message;
  const RadiologyRecordServiceException(this.message);
  @override
  String toString() => 'RadiologyRecordServiceException: $message';
}