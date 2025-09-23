import 'package:drift/drift.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/medical_record_dao.dart';
import '../../../data/models/allergy.dart';
import 'dart:convert';

class AllergyService {
  final MedicalRecordDao _medicalRecordDao;
  final AppDatabase _database;

  AllergyService({
    MedicalRecordDao? medicalRecordDao,
    AppDatabase? database,
  }) : _database = database ?? AppDatabase.instance,
       _medicalRecordDao =
           medicalRecordDao ??
           MedicalRecordDao(database ?? AppDatabase.instance);

  // CRUD Operations

  Future<List<Allergy>> getAllAllergies({String? profileId}) async {
    try {
      return await _medicalRecordDao.getAllAllergies(profileId: profileId);
    } catch (e) {
      throw AllergyServiceException(
        'Failed to retrieve allergies: ${e.toString()}',
      );
    }
  }

  Future<List<Allergy>> getActiveAllergies({String? profileId}) async {
    try {
      return await _medicalRecordDao.getActiveAllergies(profileId: profileId);
    } catch (e) {
      throw AllergyServiceException(
        'Failed to retrieve active allergies: ${e.toString()}',
      );
    }
  }

  Future<Allergy?> getAllergyById(String id) async {
    try {
      if (id.isEmpty) {
        throw const AllergyServiceException('Allergy ID cannot be empty');
      }

      final allergies = await _database.select(_database.allergies).get();
      return allergies.where((a) => a.id == id).firstOrNull;
    } catch (e) {
      if (e is AllergyServiceException) rethrow;
      throw AllergyServiceException(
        'Failed to retrieve allergy: ${e.toString()}',
      );
    }
  }

  Future<String> createAllergy(CreateAllergyRequest request) async {
    try {
      _validateCreateAllergyRequest(request);

      final allergyId = 'allergy_${DateTime.now().millisecondsSinceEpoch}';

      // Create allergy-specific record
      final allergyCompanion = AllergiesCompanion(
        id: Value(allergyId),
        profileId: Value(request.profileId),
        recordType: const Value('allergy'),
        title: Value(request.title.trim()),
        description: Value(request.description?.trim()),
        recordDate: Value(request.recordDate),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        isActive: const Value(true),
        // Allergy-specific fields
        allergen: Value(request.allergen.trim()),
        severity: Value(request.severity),
        symptoms: Value(jsonEncode(request.symptoms)),
        treatment: Value(request.treatment?.trim()),
        notes: Value(request.notes?.trim()),
        isAllergyActive: Value(request.isAllergyActive),
        firstReaction: Value(request.firstReaction),
        lastReaction: Value(request.lastReaction),
      );

      // Create general medical record entry
      final medicalRecordCompanion = MedicalRecordsCompanion(
        id: Value(allergyId),
        profileId: Value(request.profileId),
        recordType: const Value('allergy'),
        title: Value(request.title.trim()),
        description: Value(request.description?.trim()),
        recordDate: Value(request.recordDate),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        isActive: const Value(true),
      );

      // Save both records in a transaction
      await _database.transaction(() async {
        await _medicalRecordDao.createAllergy(allergyCompanion);
        await _medicalRecordDao.createRecord(medicalRecordCompanion);
      });

      return allergyId;
    } catch (e) {
      if (e is AllergyServiceException) rethrow;
      throw AllergyServiceException(
        'Failed to create allergy: ${e.toString()}',
      );
    }
  }

  Future<bool> updateAllergy(
    String id,
    UpdateAllergyRequest request,
  ) async {
    try {
      if (id.isEmpty) {
        throw const AllergyServiceException('Allergy ID cannot be empty');
      }

      final existingAllergy = await getAllergyById(id);
      if (existingAllergy == null) {
        throw const AllergyServiceException('Allergy not found');
      }

      _validateUpdateAllergyRequest(request);

      final allergyCompanion = AllergiesCompanion(
        title: request.title != null
            ? Value(request.title!.trim())
            : const Value.absent(),
        description: request.description != null
            ? Value(request.description?.trim())
            : const Value.absent(),
        recordDate: request.recordDate != null
            ? Value(request.recordDate!)
            : const Value.absent(),
        allergen: request.allergen != null
            ? Value(request.allergen!.trim())
            : const Value.absent(),
        severity: request.severity != null
            ? Value(request.severity!)
            : const Value.absent(),
        symptoms: request.symptoms != null
            ? Value(jsonEncode(request.symptoms!))
            : const Value.absent(),
        treatment: request.treatment != null
            ? Value(request.treatment?.trim())
            : const Value.absent(),
        notes: request.notes != null
            ? Value(request.notes?.trim())
            : const Value.absent(),
        isAllergyActive: request.isAllergyActive != null
            ? Value(request.isAllergyActive!)
            : const Value.absent(),
        firstReaction: request.firstReaction != null
            ? Value(request.firstReaction)
            : const Value.absent(),
        lastReaction: request.lastReaction != null
            ? Value(request.lastReaction)
            : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      );

      final rowsAffected = await (_database.update(
        _database.allergies,
      )..where((a) => a.id.equals(id))).write(allergyCompanion);

      return rowsAffected > 0;
    } catch (e) {
      if (e is AllergyServiceException) rethrow;
      throw AllergyServiceException(
        'Failed to update allergy: ${e.toString()}',
      );
    }
  }

  Future<bool> deleteAllergy(String id) async {
    try {
      if (id.isEmpty) {
        throw const AllergyServiceException('Allergy ID cannot be empty');
      }

      final existingAllergy = await getAllergyById(id);
      if (existingAllergy == null) {
        throw const AllergyServiceException('Allergy not found');
      }

      final rowsAffected =
          await (_database.update(
            _database.allergies,
          )..where((a) => a.id.equals(id))).write(
            AllergiesCompanion(
              isActive: const Value(false),
              updatedAt: Value(DateTime.now()),
            ),
          );

      return rowsAffected > 0;
    } catch (e) {
      if (e is AllergyServiceException) rethrow;
      throw AllergyServiceException(
        'Failed to delete allergy: ${e.toString()}',
      );
    }
  }

  // Query Operations

  Future<List<Allergy>> getAllergiesBySeverity(
    String severity, {
    String? profileId,
  }) async {
    try {
      if (!AllergySeverity.isValidSeverity(severity)) {
        throw AllergyServiceException('Invalid severity: $severity');
      }

      var query = _database.select(_database.allergies)
        ..where((a) =>
            a.isActive.equals(true) &
            a.isAllergyActive.equals(true) &
            a.severity.equals(severity));

      if (profileId != null) {
        query = query..where((a) => a.profileId.equals(profileId));
      }

      query = query
        ..orderBy([
          (a) => OrderingTerm(expression: a.recordDate, mode: OrderingMode.desc),
        ]);

      return await query.get();
    } catch (e) {
      if (e is AllergyServiceException) rethrow;
      throw AllergyServiceException(
        'Failed to retrieve allergies by severity: ${e.toString()}',
      );
    }
  }

  Future<List<Allergy>> getAllergiesByAllergen(
    String allergen, {
    String? profileId,
  }) async {
    try {
      if (allergen.trim().isEmpty) {
        throw const AllergyServiceException('Allergen cannot be empty');
      }

      var query = _database.select(_database.allergies)
        ..where((a) =>
            a.isActive.equals(true) &
            a.allergen.like('%${allergen.trim()}%'));

      if (profileId != null) {
        query = query..where((a) => a.profileId.equals(profileId));
      }

      query = query
        ..orderBy([
          (a) => OrderingTerm(expression: a.recordDate, mode: OrderingMode.desc),
        ]);

      return await query.get();
    } catch (e) {
      if (e is AllergyServiceException) rethrow;
      throw AllergyServiceException(
        'Failed to retrieve allergies by allergen: ${e.toString()}',
      );
    }
  }

  Future<List<Allergy>> getLifeThreateningAllergies({
    String? profileId,
  }) async {
    try {
      return await getAllergiesBySeverity(
        AllergySeverity.lifeThreatening,
        profileId: profileId,
      );
    } catch (e) {
      throw AllergyServiceException(
        'Failed to retrieve life-threatening allergies: ${e.toString()}',
      );
    }
  }

  Future<List<Allergy>> getInactiveAllergies({String? profileId}) async {
    try {
      var query = _database.select(_database.allergies)
        ..where((a) =>
            a.isActive.equals(true) & a.isAllergyActive.equals(false));

      if (profileId != null) {
        query = query..where((a) => a.profileId.equals(profileId));
      }

      query = query
        ..orderBy([
          (a) => OrderingTerm(expression: a.recordDate, mode: OrderingMode.desc),
        ]);

      return await query.get();
    } catch (e) {
      throw AllergyServiceException(
        'Failed to retrieve inactive allergies: ${e.toString()}',
      );
    }
  }

  // Analytics

  Future<Map<String, int>> getAllergyCountsBySeverity({
    String? profileId,
  }) async {
    try {
      final Map<String, int> counts = {};

      for (final severity in AllergySeverity.allSeverities) {
        final allergies = await getAllergiesBySeverity(
          severity,
          profileId: profileId,
        );
        counts[severity] = allergies.length;
      }

      return counts;
    } catch (e) {
      throw AllergyServiceException(
        'Failed to retrieve allergy counts by severity: ${e.toString()}',
      );
    }
  }

  Future<Map<String, int>> getAllergyCountsByAllergen({
    String? profileId,
  }) async {
    try {
      var query = _database.select(_database.allergies)
        ..where((a) => a.isActive.equals(true) & a.isAllergyActive.equals(true));

      if (profileId != null) {
        query = query..where((a) => a.profileId.equals(profileId));
      }

      final allergies = await query.get();
      final Map<String, int> counts = {};

      for (final allergy in allergies) {
        final allergen = allergy.allergen;
        counts[allergen] = (counts[allergen] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      throw AllergyServiceException(
        'Failed to retrieve allergy counts by allergen: ${e.toString()}',
      );
    }
  }

  // Status Management

  Future<bool> toggleAllergyStatus(String id, bool isActive) async {
    try {
      if (id.isEmpty) {
        throw const AllergyServiceException('Allergy ID cannot be empty');
      }

      final rowsAffected =
          await (_database.update(
            _database.allergies,
          )..where((a) => a.id.equals(id))).write(
            AllergiesCompanion(
              isAllergyActive: Value(isActive),
              updatedAt: Value(DateTime.now()),
            ),
          );

      return rowsAffected > 0;
    } catch (e) {
      if (e is AllergyServiceException) rethrow;
      throw AllergyServiceException(
        'Failed to toggle allergy status: ${e.toString()}',
      );
    }
  }

  // Stream Operations

  Stream<List<Allergy>> watchActiveAllergies({String? profileId}) {
    return _medicalRecordDao.watchActiveAllergies(profileId: profileId);
  }

  // Utility Methods

  List<String> parseSymptoms(String symptomsJson) {
    try {
      final decoded = jsonDecode(symptomsJson);
      if (decoded is List) {
        return decoded.cast<String>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Private Helper Methods

  void _validateCreateAllergyRequest(CreateAllergyRequest request) {
    if (request.profileId.isEmpty) {
      throw const AllergyServiceException('Profile ID cannot be empty');
    }
    if (request.title.trim().isEmpty) {
      throw const AllergyServiceException('Title cannot be empty');
    }
    if (request.allergen.trim().isEmpty) {
      throw const AllergyServiceException('Allergen cannot be empty');
    }
    if (!AllergySeverity.isValidSeverity(request.severity)) {
      throw AllergyServiceException('Invalid severity: ${request.severity}');
    }
    if (request.symptoms.isEmpty) {
      throw const AllergyServiceException('At least one symptom is required');
    }
    if (request.firstReaction != null &&
        request.lastReaction != null &&
        request.firstReaction!.isAfter(request.lastReaction!)) {
      throw const AllergyServiceException(
        'First reaction cannot be after last reaction',
      );
    }
  }

  void _validateUpdateAllergyRequest(UpdateAllergyRequest request) {
    if (request.title != null && request.title!.trim().isEmpty) {
      throw const AllergyServiceException('Title cannot be empty');
    }
    if (request.allergen != null && request.allergen!.trim().isEmpty) {
      throw const AllergyServiceException('Allergen cannot be empty');
    }
    if (request.severity != null &&
        !AllergySeverity.isValidSeverity(request.severity!)) {
      throw AllergyServiceException('Invalid severity: ${request.severity}');
    }
    if (request.symptoms != null && request.symptoms!.isEmpty) {
      throw const AllergyServiceException('At least one symptom is required');
    }
    if (request.firstReaction != null &&
        request.lastReaction != null &&
        request.firstReaction!.isAfter(request.lastReaction!)) {
      throw const AllergyServiceException(
        'First reaction cannot be after last reaction',
      );
    }
  }
}

// Data Transfer Objects

class CreateAllergyRequest {
  final String profileId;
  final String title;
  final String? description;
  final DateTime recordDate;
  final String allergen;
  final String severity;
  final List<String> symptoms;
  final String? treatment;
  final String? notes;
  final bool isAllergyActive;
  final DateTime? firstReaction;
  final DateTime? lastReaction;

  const CreateAllergyRequest({
    required this.profileId,
    required this.title,
    this.description,
    required this.recordDate,
    required this.allergen,
    required this.severity,
    required this.symptoms,
    this.treatment,
    this.notes,
    this.isAllergyActive = true,
    this.firstReaction,
    this.lastReaction,
  });
}

class UpdateAllergyRequest {
  final String? title;
  final String? description;
  final DateTime? recordDate;
  final String? allergen;
  final String? severity;
  final List<String>? symptoms;
  final String? treatment;
  final String? notes;
  final bool? isAllergyActive;
  final DateTime? firstReaction;
  final DateTime? lastReaction;

  const UpdateAllergyRequest({
    this.title,
    this.description,
    this.recordDate,
    this.allergen,
    this.severity,
    this.symptoms,
    this.treatment,
    this.notes,
    this.isAllergyActive,
    this.firstReaction,
    this.lastReaction,
  });
}

// Exceptions

class AllergyServiceException implements Exception {
  final String message;

  const AllergyServiceException(this.message);

  @override
  String toString() => 'AllergyServiceException: $message';
}