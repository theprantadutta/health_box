import 'package:drift/drift.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/medical_record_dao.dart';

class GeneralRecordService {
  final MedicalRecordDao _medicalRecordDao;
  final AppDatabase _database;

  GeneralRecordService({
    MedicalRecordDao? medicalRecordDao,
    AppDatabase? database,
  }) : _database = database ?? AppDatabase.instance,
       _medicalRecordDao =
           medicalRecordDao ??
           MedicalRecordDao(database ?? AppDatabase.instance);

  Future<String> createGeneralRecord(CreateGeneralRecordRequest request) async {
    try {
      final recordId = 'general_record_${DateTime.now().millisecondsSinceEpoch}';

      final generalRecordCompanion = GeneralRecordsCompanion(
        id: Value(recordId),
        profileId: Value(request.profileId),
        recordType: const Value('general_record'),
        title: Value(request.title.trim()),
        description: Value(request.description?.trim()),
        recordDate: Value(request.recordDate),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        isActive: const Value(true),
        category: Value(request.category.trim()),
        subcategory: Value(request.subcategory?.trim()),
        providerName: Value(request.providerName?.trim()),
        institution: Value(request.institution?.trim()),
        documentDate: Value(request.documentDate),
        documentType: Value(request.documentType?.trim()),
        referenceNumber: Value(request.referenceNumber?.trim()),
        relatedCondition: Value(request.relatedCondition?.trim()),
        notes: Value(request.notes?.trim()),
        followUpRequired: Value(request.followUpRequired?.trim()),
        expirationDate: Value(request.expirationDate),
        reminderDate: Value(request.reminderDate),
        tags: Value(request.tags?.trim()),
        isConfidential: Value(request.isConfidential),
        requiresAction: Value(request.requiresAction),
      );

      final medicalRecordCompanion = MedicalRecordsCompanion(
        id: Value(recordId),
        profileId: Value(request.profileId),
        recordType: const Value('general_record'),
        title: Value(request.title.trim()),
        description: Value(request.description?.trim()),
        recordDate: Value(request.recordDate),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        isActive: const Value(true),
      );

      await _database.transaction(() async {
        await _medicalRecordDao.createGeneralRecord(generalRecordCompanion);
        await _medicalRecordDao.createRecord(medicalRecordCompanion);
      });

      return recordId;
    } catch (e) {
      throw GeneralRecordServiceException(
        'Failed to create general record: ${e.toString()}',
      );
    }
  }
}

class CreateGeneralRecordRequest {
  final String profileId;
  final String title;
  final String? description;
  final DateTime recordDate;
  final String category;
  final String? subcategory;
  final String? providerName;
  final String? institution;
  final DateTime? documentDate;
  final String? documentType;
  final String? referenceNumber;
  final String? relatedCondition;
  final String? notes;
  final String? followUpRequired;
  final DateTime? expirationDate;
  final DateTime? reminderDate;
  final String? tags;
  final bool isConfidential;
  final bool requiresAction;

  const CreateGeneralRecordRequest({
    required this.profileId,
    required this.title,
    this.description,
    required this.recordDate,
    required this.category,
    this.subcategory,
    this.providerName,
    this.institution,
    this.documentDate,
    this.documentType,
    this.referenceNumber,
    this.relatedCondition,
    this.notes,
    this.followUpRequired,
    this.expirationDate,
    this.reminderDate,
    this.tags,
    this.isConfidential = false,
    this.requiresAction = false,
  });
}

class GeneralRecordServiceException implements Exception {
  final String message;
  const GeneralRecordServiceException(this.message);
  @override
  String toString() => 'GeneralRecordServiceException: $message';
}