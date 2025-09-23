import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../models/medical_record.dart';
import '../models/medication.dart';

class MedicalRecordDao {
  final AppDatabase _database;

  MedicalRecordDao(this._database);

  // Base Medical Records Operations
  Future<List<MedicalRecord>> getAllRecords() async {
    return await (_database.select(_database.medicalRecords)
          ..where((record) => record.isActive.equals(true))
          ..orderBy([
            (record) => OrderingTerm(
              expression: record.recordDate,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  Future<List<MedicalRecord>> getRecordsByProfileId(String profileId) async {
    return await (_database.select(_database.medicalRecords)
          ..where(
            (record) =>
                record.profileId.equals(profileId) &
                record.isActive.equals(true),
          )
          ..orderBy([
            (record) => OrderingTerm(
              expression: record.recordDate,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  Future<List<MedicalRecord>> getRecordsByType(String recordType) async {
    if (!MedicalRecordType.isValidType(recordType)) {
      throw ArgumentError('Invalid record type: $recordType');
    }

    return await (_database.select(_database.medicalRecords)
          ..where(
            (record) =>
                record.recordType.equals(recordType) &
                record.isActive.equals(true),
          )
          ..orderBy([
            (record) => OrderingTerm(
              expression: record.recordDate,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  Future<List<MedicalRecord>> getRecordsByProfileAndType(
    String profileId,
    String recordType,
  ) async {
    if (!MedicalRecordType.isValidType(recordType)) {
      throw ArgumentError('Invalid record type: $recordType');
    }

    return await (_database.select(_database.medicalRecords)
          ..where(
            (record) =>
                record.profileId.equals(profileId) &
                record.recordType.equals(recordType) &
                record.isActive.equals(true),
          )
          ..orderBy([
            (record) => OrderingTerm(
              expression: record.recordDate,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  Future<MedicalRecord?> getRecordById(String id) async {
    return await (_database.select(_database.medicalRecords)..where(
          (record) => record.id.equals(id) & record.isActive.equals(true),
        ))
        .getSingleOrNull();
  }

  Future<List<MedicalRecord>> searchRecords(
    String searchTerm, {
    String? profileId,
  }) async {
    final searchPattern = '%${searchTerm.toLowerCase()}%';

    var query = _database.select(_database.medicalRecords)
      ..where(
        (record) =>
            record.isActive.equals(true) &
            (record.title.lower().like(searchPattern) |
                record.description.lower().like(searchPattern)),
      );

    if (profileId != null) {
      query = query..where((record) => record.profileId.equals(profileId));
    }

    query = query
      ..orderBy([
        (record) => OrderingTerm(
          expression: record.recordDate,
          mode: OrderingMode.desc,
        ),
      ]);

    return await query.get();
  }

  Future<List<MedicalRecord>> getRecordsInDateRange(
    DateTime startDate,
    DateTime endDate, {
    String? profileId,
  }) async {
    var query = _database.select(_database.medicalRecords)
      ..where(
        (record) =>
            record.isActive.equals(true) &
            record.recordDate.isBetweenValues(startDate, endDate),
      );

    if (profileId != null) {
      query = query..where((record) => record.profileId.equals(profileId));
    }

    query = query
      ..orderBy([
        (record) => OrderingTerm(
          expression: record.recordDate,
          mode: OrderingMode.desc,
        ),
      ]);

    return await query.get();
  }

  Future<List<MedicalRecord>> getRecentRecords({
    int limit = 10,
    String? profileId,
  }) async {
    var query = _database.select(_database.medicalRecords)
      ..where((record) => record.isActive.equals(true));

    if (profileId != null) {
      query = query..where((record) => record.profileId.equals(profileId));
    }

    query = query
      ..orderBy([
        (record) => OrderingTerm(
          expression: record.recordDate,
          mode: OrderingMode.desc,
        ),
      ])
      ..limit(limit);

    return await query.get();
  }

  Future<String> createRecord(MedicalRecordsCompanion record) async {
    await _database.into(_database.medicalRecords).insert(record);
    return record.id.value;
  }

  Future<bool> updateRecord(String id, MedicalRecordsCompanion record) async {
    final updatedRecord = record.copyWith(updatedAt: Value(DateTime.now()));

    final rowsAffected = await (_database.update(
      _database.medicalRecords,
    )..where((r) => r.id.equals(id))).write(updatedRecord);

    return rowsAffected > 0;
  }

  Future<bool> deleteRecord(String id) async {
    final rowsAffected =
        await (_database.update(
          _database.medicalRecords,
        )..where((r) => r.id.equals(id))).write(
          MedicalRecordsCompanion(
            isActive: const Value(false),
            updatedAt: Value(DateTime.now()),
          ),
        );

    return rowsAffected > 0;
  }

  Future<bool> permanentlyDeleteRecord(String id) async {
    final rowsAffected = await (_database.delete(
      _database.medicalRecords,
    )..where((r) => r.id.equals(id))).go();

    return rowsAffected > 0;
  }

  Future<int> getRecordCountByProfile(String profileId) async {
    final query = _database.selectOnly(_database.medicalRecords)
      ..addColumns([_database.medicalRecords.id.count()])
      ..where(
        _database.medicalRecords.profileId.equals(profileId) &
            _database.medicalRecords.isActive.equals(true),
      );

    final result = await query.getSingle();
    return result.read(_database.medicalRecords.id.count()) ?? 0;
  }

  Future<int> getRecordCountByType(
    String recordType, {
    String? profileId,
  }) async {
    if (!MedicalRecordType.isValidType(recordType)) {
      throw ArgumentError('Invalid record type: $recordType');
    }

    var query = _database.selectOnly(_database.medicalRecords)
      ..addColumns([_database.medicalRecords.id.count()])
      ..where(
        _database.medicalRecords.recordType.equals(recordType) &
            _database.medicalRecords.isActive.equals(true),
      );

    if (profileId != null) {
      query = query
        ..where(_database.medicalRecords.profileId.equals(profileId));
    }

    final result = await query.getSingle();
    return result.read(_database.medicalRecords.id.count()) ?? 0;
  }

  Future<Map<String, int>> getRecordCountsByType({String? profileId}) async {
    var query = _database.selectOnly(_database.medicalRecords)
      ..addColumns([
        _database.medicalRecords.recordType,
        _database.medicalRecords.id.count(),
      ])
      ..where(_database.medicalRecords.isActive.equals(true));

    if (profileId != null) {
      query = query
        ..where(_database.medicalRecords.profileId.equals(profileId));
    }

    query = query..groupBy([_database.medicalRecords.recordType]);

    final results = await query.get();
    final Map<String, int> counts = {};

    for (final result in results) {
      final recordType = result.read(_database.medicalRecords.recordType)!;
      final count = result.read(_database.medicalRecords.id.count()) ?? 0;
      counts[recordType] = count;
    }

    return counts;
  }

  // Specialized Record Operations

  // Prescription Operations
  Future<List<Prescription>> getAllPrescriptions({String? profileId}) async {
    var query = _database.select(_database.prescriptions)
      ..where((p) => p.isActive.equals(true));

    if (profileId != null) {
      query = query..where((p) => p.profileId.equals(profileId));
    }

    query = query
      ..orderBy([
        (p) => OrderingTerm(expression: p.recordDate, mode: OrderingMode.desc),
      ]);

    return await query.get();
  }

  Future<List<Prescription>> getActivePrescriptions({String? profileId}) async {
    var query = _database.select(_database.prescriptions)
      ..where(
        (p) => p.isActive.equals(true) & p.isPrescriptionActive.equals(true),
      );

    if (profileId != null) {
      query = query..where((p) => p.profileId.equals(profileId));
    }

    query = query
      ..orderBy([
        (p) => OrderingTerm(expression: p.recordDate, mode: OrderingMode.desc),
      ]);

    return await query.get();
  }

  Future<String> createPrescription(PrescriptionsCompanion prescription) async {
    await _database.into(_database.prescriptions).insert(prescription);
    return prescription.id.value;
  }

  // Medication Operations
  Future<List<Medication>> getAllMedications({String? profileId}) async {
    var query = _database.select(_database.medications)
      ..where((m) => m.isActive.equals(true));

    if (profileId != null) {
      query = query..where((m) => m.profileId.equals(profileId));
    }

    query = query
      ..orderBy([
        (m) => OrderingTerm(expression: m.startDate, mode: OrderingMode.desc),
      ]);

    return await query.get();
  }

  Future<List<Medication>> getActiveMedications({String? profileId}) async {
    var query = _database.select(_database.medications)
      ..where(
        (m) =>
            m.isActive.equals(true) & m.status.equals(MedicationStatus.active),
      );

    if (profileId != null) {
      query = query..where((m) => m.profileId.equals(profileId));
    }

    query = query
      ..orderBy([
        (m) => OrderingTerm(expression: m.startDate, mode: OrderingMode.desc),
      ]);

    return await query.get();
  }

  Future<List<Medication>> getMedicationsWithReminders({
    String? profileId,
  }) async {
    var query = _database.select(_database.medications)
      ..where((m) => m.isActive.equals(true) & m.reminderEnabled.equals(true));

    if (profileId != null) {
      query = query..where((m) => m.profileId.equals(profileId));
    }

    query = query
      ..orderBy([
        (m) => OrderingTerm(expression: m.startDate, mode: OrderingMode.desc),
      ]);

    return await query.get();
  }

  Future<String> createMedication(MedicationsCompanion medication) async {
    await _database.into(_database.medications).insert(medication);
    return medication.id.value;
  }

  // Stream operations for real-time updates
  Stream<List<MedicalRecord>> watchRecordsByProfile(String profileId) {
    return (_database.select(_database.medicalRecords)
          ..where(
            (record) =>
                record.profileId.equals(profileId) &
                record.isActive.equals(true),
          )
          ..orderBy([
            (record) => OrderingTerm(
              expression: record.recordDate,
              mode: OrderingMode.desc,
            ),
          ]))
        .watch();
  }

  Stream<List<MedicalRecord>> watchRecordsByType(String recordType) {
    if (!MedicalRecordType.isValidType(recordType)) {
      throw ArgumentError('Invalid record type: $recordType');
    }

    return (_database.select(_database.medicalRecords)
          ..where(
            (record) =>
                record.recordType.equals(recordType) &
                record.isActive.equals(true),
          )
          ..orderBy([
            (record) => OrderingTerm(
              expression: record.recordDate,
              mode: OrderingMode.desc,
            ),
          ]))
        .watch();
  }

  Stream<MedicalRecord?> watchRecord(String id) {
    return (_database.select(_database.medicalRecords)..where(
          (record) => record.id.equals(id) & record.isActive.equals(true),
        ))
        .watchSingleOrNull();
  }

  Stream<List<Medication>> watchActiveMedications({String? profileId}) {
    var query = _database.select(_database.medications)
      ..where(
        (m) =>
            m.isActive.equals(true) & m.status.equals(MedicationStatus.active),
      );

    if (profileId != null) {
      query = query..where((m) => m.profileId.equals(profileId));
    }

    query = query
      ..orderBy([
        (m) => OrderingTerm(expression: m.startDate, mode: OrderingMode.desc),
      ]);

    return query.watch();
  }

  // Vaccination Operations
  Future<List<Vaccination>> getAllVaccinations({String? profileId}) async {
    var query = _database.select(_database.vaccinations)
      ..where((v) => v.isActive.equals(true));

    if (profileId != null) {
      query = query..where((v) => v.profileId.equals(profileId));
    }

    query = query
      ..orderBy([
        (v) => OrderingTerm(expression: v.administrationDate, mode: OrderingMode.desc),
      ]);

    return await query.get();
  }

  Future<List<Vaccination>> getActiveVaccinations({String? profileId}) async {
    var query = _database.select(_database.vaccinations)
      ..where((v) => v.isActive.equals(true));

    if (profileId != null) {
      query = query..where((v) => v.profileId.equals(profileId));
    }

    query = query
      ..orderBy([
        (v) => OrderingTerm(expression: v.administrationDate, mode: OrderingMode.desc),
      ]);

    return await query.get();
  }

  Future<String> createVaccination(VaccinationsCompanion vaccination) async {
    await _database.into(_database.vaccinations).insert(vaccination);
    return vaccination.id.value;
  }

  Stream<List<Vaccination>> watchActiveVaccinations({String? profileId}) {
    var query = _database.select(_database.vaccinations)
      ..where((v) => v.isActive.equals(true));

    if (profileId != null) {
      query = query..where((v) => v.profileId.equals(profileId));
    }

    query = query
      ..orderBy([
        (v) => OrderingTerm(expression: v.administrationDate, mode: OrderingMode.desc),
      ]);

    return query.watch();
  }

  // Allergy Operations
  Future<List<Allergy>> getAllAllergies({String? profileId}) async {
    var query = _database.select(_database.allergies)
      ..where((a) => a.isActive.equals(true));

    if (profileId != null) {
      query = query..where((a) => a.profileId.equals(profileId));
    }

    query = query
      ..orderBy([
        (a) => OrderingTerm(expression: a.recordDate, mode: OrderingMode.desc),
      ]);

    return await query.get();
  }

  Future<List<Allergy>> getActiveAllergies({String? profileId}) async {
    var query = _database.select(_database.allergies)
      ..where((a) => a.isActive.equals(true) & a.isAllergyActive.equals(true));

    if (profileId != null) {
      query = query..where((a) => a.profileId.equals(profileId));
    }

    query = query
      ..orderBy([
        (a) => OrderingTerm(expression: a.recordDate, mode: OrderingMode.desc),
      ]);

    return await query.get();
  }

  Future<String> createAllergy(AllergiesCompanion allergy) async {
    await _database.into(_database.allergies).insert(allergy);
    return allergy.id.value;
  }

  Stream<List<Allergy>> watchActiveAllergies({String? profileId}) {
    var query = _database.select(_database.allergies)
      ..where((a) => a.isActive.equals(true) & a.isAllergyActive.equals(true));

    if (profileId != null) {
      query = query..where((a) => a.profileId.equals(profileId));
    }

    query = query
      ..orderBy([
        (a) => OrderingTerm(expression: a.recordDate, mode: OrderingMode.desc),
      ]);

    return query.watch();
  }

  // Chronic Condition Operations
  Future<List<ChronicCondition>> getAllChronicConditions({String? profileId}) async {
    var query = _database.select(_database.chronicConditions)
      ..where((c) => c.isActive.equals(true));

    if (profileId != null) {
      query = query..where((c) => c.profileId.equals(profileId));
    }

    query = query
      ..orderBy([
        (c) => OrderingTerm(expression: c.diagnosisDate, mode: OrderingMode.desc),
      ]);

    return await query.get();
  }

  Future<List<ChronicCondition>> getActiveChronicConditions({String? profileId}) async {
    var query = _database.select(_database.chronicConditions)
      ..where((c) => c.isActive.equals(true));

    if (profileId != null) {
      query = query..where((c) => c.profileId.equals(profileId));
    }

    query = query
      ..orderBy([
        (c) => OrderingTerm(expression: c.diagnosisDate, mode: OrderingMode.desc),
      ]);

    return await query.get();
  }

  Future<String> createChronicCondition(ChronicConditionsCompanion condition) async {
    await _database.into(_database.chronicConditions).insert(condition);
    return condition.id.value;
  }

  Stream<List<ChronicCondition>> watchActiveChronicConditions({String? profileId}) {
    var query = _database.select(_database.chronicConditions)
      ..where((c) => c.isActive.equals(true));

    if (profileId != null) {
      query = query..where((c) => c.profileId.equals(profileId));
    }

    query = query
      ..orderBy([
        (c) => OrderingTerm(expression: c.diagnosisDate, mode: OrderingMode.desc),
      ]);

    return query.watch();
  }

  // Surgical Record Operations
  Future<List<SurgicalRecord>> getAllSurgicalRecords({String? profileId}) async {
    var query = _database.select(_database.surgicalRecords)
      ..where((s) => s.isActive.equals(true));

    if (profileId != null) {
      query = query..where((s) => s.profileId.equals(profileId));
    }

    query = query
      ..orderBy([
        (s) => OrderingTerm(expression: s.surgeryDate, mode: OrderingMode.desc),
      ]);

    return await query.get();
  }

  Future<List<SurgicalRecord>> getActiveSurgicalRecords({String? profileId}) async {
    var query = _database.select(_database.surgicalRecords)
      ..where((s) => s.isActive.equals(true));

    if (profileId != null) {
      query = query..where((s) => s.profileId.equals(profileId));
    }

    query = query
      ..orderBy([
        (s) => OrderingTerm(expression: s.surgeryDate, mode: OrderingMode.desc),
      ]);

    return await query.get();
  }

  Future<String> createSurgicalRecord(SurgicalRecordsCompanion surgicalRecord) async {
    await _database.into(_database.surgicalRecords).insert(surgicalRecord);
    return surgicalRecord.id.value;
  }

  Stream<List<SurgicalRecord>> watchActiveSurgicalRecords({String? profileId}) {
    var query = _database.select(_database.surgicalRecords)
      ..where((s) => s.isActive.equals(true));

    if (profileId != null) {
      query = query..where((s) => s.profileId.equals(profileId));
    }

    query = query
      ..orderBy([
        (s) => OrderingTerm(expression: s.surgeryDate, mode: OrderingMode.desc),
      ]);

    return query.watch();
  }

  // Radiology Record Operations
  Future<String> createRadiologyRecord(RadiologyRecordsCompanion radiologyRecord) async {
    await _database.into(_database.radiologyRecords).insert(radiologyRecord);
    return radiologyRecord.id.value;
  }

  // Pathology Record Operations
  Future<String> createPathologyRecord(PathologyRecordsCompanion pathologyRecord) async {
    await _database.into(_database.pathologyRecords).insert(pathologyRecord);
    return pathologyRecord.id.value;
  }

  // Discharge Summary Operations
  Future<String> createDischargeSummary(DischargeSummariesCompanion dischargeSummary) async {
    await _database.into(_database.dischargeSummaries).insert(dischargeSummary);
    return dischargeSummary.id.value;
  }

  // Hospital Admission Operations
  Future<String> createHospitalAdmission(HospitalAdmissionsCompanion hospitalAdmission) async {
    await _database.into(_database.hospitalAdmissions).insert(hospitalAdmission);
    return hospitalAdmission.id.value;
  }

  // Dental Record Operations
  Future<String> createDentalRecord(DentalRecordsCompanion dentalRecord) async {
    await _database.into(_database.dentalRecords).insert(dentalRecord);
    return dentalRecord.id.value;
  }

  // Mental Health Record Operations
  Future<String> createMentalHealthRecord(MentalHealthRecordsCompanion mentalHealthRecord) async {
    await _database.into(_database.mentalHealthRecords).insert(mentalHealthRecord);
    return mentalHealthRecord.id.value;
  }

  // General Record Operations
  Future<String> createGeneralRecord(GeneralRecordsCompanion generalRecord) async {
    await _database.into(_database.generalRecords).insert(generalRecord);
    return generalRecord.id.value;
  }
}
