import 'package:drift/drift.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/medical_record_dao.dart';

class VaccinationService {
  final MedicalRecordDao _medicalRecordDao;
  final AppDatabase _database;

  VaccinationService({
    MedicalRecordDao? medicalRecordDao,
    AppDatabase? database,
  }) : _database = database ?? AppDatabase.instance,
       _medicalRecordDao =
           medicalRecordDao ??
           MedicalRecordDao(database ?? AppDatabase.instance);

  // CRUD Operations

  Future<List<Vaccination>> getAllVaccinations({String? profileId}) async {
    try {
      return await _medicalRecordDao.getAllVaccinations(profileId: profileId);
    } catch (e) {
      throw VaccinationServiceException(
        'Failed to retrieve vaccinations: ${e.toString()}',
      );
    }
  }

  Future<List<Vaccination>> getActiveVaccinations({String? profileId}) async {
    try {
      return await _medicalRecordDao.getActiveVaccinations(profileId: profileId);
    } catch (e) {
      throw VaccinationServiceException(
        'Failed to retrieve active vaccinations: ${e.toString()}',
      );
    }
  }

  Future<Vaccination?> getVaccinationById(String id) async {
    try {
      if (id.isEmpty) {
        throw const VaccinationServiceException('Vaccination ID cannot be empty');
      }

      final vaccinations = await _database.select(_database.vaccinations).get();
      return vaccinations.where((v) => v.id == id).firstOrNull;
    } catch (e) {
      if (e is VaccinationServiceException) rethrow;
      throw VaccinationServiceException(
        'Failed to retrieve vaccination: ${e.toString()}',
      );
    }
  }

  Future<String> createVaccination(CreateVaccinationRequest request) async {
    try {
      _validateCreateVaccinationRequest(request);

      final vaccinationId =
          'vaccination_${DateTime.now().millisecondsSinceEpoch}';

      // Create vaccination-specific record
      final vaccinationCompanion = VaccinationsCompanion(
        id: Value(vaccinationId),
        profileId: Value(request.profileId),
        recordType: const Value('vaccination'),
        title: Value(request.title.trim()),
        description: Value(request.description?.trim()),
        recordDate: Value(request.recordDate),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        isActive: const Value(true),
        // Vaccination-specific fields
        vaccineName: Value(request.vaccineName.trim()),
        manufacturer: Value(request.manufacturer?.trim()),
        batchNumber: Value(request.batchNumber?.trim()),
        administrationDate: Value(request.administrationDate),
        administeredBy: Value(request.administeredBy?.trim()),
        site: Value(request.site),
        nextDueDate: Value(request.nextDueDate),
        doseNumber: Value(request.doseNumber),
        isComplete: Value(request.isComplete),
      );

      // Create general medical record entry
      final medicalRecordCompanion = MedicalRecordsCompanion(
        id: Value(vaccinationId),
        profileId: Value(request.profileId),
        recordType: const Value('vaccination'),
        title: Value(request.title.trim()),
        description: Value(request.description?.trim()),
        recordDate: Value(request.recordDate),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        isActive: const Value(true),
      );

      // Save both records in a transaction
      await _database.transaction(() async {
        await _medicalRecordDao.createVaccination(vaccinationCompanion);
        await _medicalRecordDao.createRecord(medicalRecordCompanion);
      });

      return vaccinationId;
    } catch (e) {
      if (e is VaccinationServiceException) rethrow;
      throw VaccinationServiceException(
        'Failed to create vaccination: ${e.toString()}',
      );
    }
  }

  Future<bool> updateVaccination(
    String id,
    UpdateVaccinationRequest request,
  ) async {
    try {
      if (id.isEmpty) {
        throw const VaccinationServiceException('Vaccination ID cannot be empty');
      }

      final existingVaccination = await getVaccinationById(id);
      if (existingVaccination == null) {
        throw const VaccinationServiceException('Vaccination not found');
      }

      _validateUpdateVaccinationRequest(request);

      final vaccinationCompanion = VaccinationsCompanion(
        title: request.title != null
            ? Value(request.title!.trim())
            : const Value.absent(),
        description: request.description != null
            ? Value(request.description?.trim())
            : const Value.absent(),
        recordDate: request.recordDate != null
            ? Value(request.recordDate!)
            : const Value.absent(),
        vaccineName: request.vaccineName != null
            ? Value(request.vaccineName!.trim())
            : const Value.absent(),
        manufacturer: request.manufacturer != null
            ? Value(request.manufacturer?.trim())
            : const Value.absent(),
        batchNumber: request.batchNumber != null
            ? Value(request.batchNumber?.trim())
            : const Value.absent(),
        administrationDate: request.administrationDate != null
            ? Value(request.administrationDate!)
            : const Value.absent(),
        administeredBy: request.administeredBy != null
            ? Value(request.administeredBy?.trim())
            : const Value.absent(),
        site: request.site != null
            ? Value(request.site)
            : const Value.absent(),
        nextDueDate: request.nextDueDate != null
            ? Value(request.nextDueDate)
            : const Value.absent(),
        doseNumber: request.doseNumber != null
            ? Value(request.doseNumber)
            : const Value.absent(),
        isComplete: request.isComplete != null
            ? Value(request.isComplete!)
            : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      );

      final rowsAffected = await (_database.update(
        _database.vaccinations,
      )..where((v) => v.id.equals(id))).write(vaccinationCompanion);

      return rowsAffected > 0;
    } catch (e) {
      if (e is VaccinationServiceException) rethrow;
      throw VaccinationServiceException(
        'Failed to update vaccination: ${e.toString()}',
      );
    }
  }

  Future<bool> deleteVaccination(String id) async {
    try {
      if (id.isEmpty) {
        throw const VaccinationServiceException('Vaccination ID cannot be empty');
      }

      final existingVaccination = await getVaccinationById(id);
      if (existingVaccination == null) {
        throw const VaccinationServiceException('Vaccination not found');
      }

      final rowsAffected =
          await (_database.update(
            _database.vaccinations,
          )..where((v) => v.id.equals(id))).write(
            VaccinationsCompanion(
              isActive: const Value(false),
              updatedAt: Value(DateTime.now()),
            ),
          );

      return rowsAffected > 0;
    } catch (e) {
      if (e is VaccinationServiceException) rethrow;
      throw VaccinationServiceException(
        'Failed to delete vaccination: ${e.toString()}',
      );
    }
  }

  // Query Operations

  Future<List<Vaccination>> getVaccinationsByVaccine(
    String vaccineName, {
    String? profileId,
  }) async {
    try {
      if (vaccineName.trim().isEmpty) {
        throw const VaccinationServiceException('Vaccine name cannot be empty');
      }

      var query = _database.select(_database.vaccinations)
        ..where((v) =>
            v.isActive.equals(true) &
            v.vaccineName.like('%${vaccineName.trim()}%'));

      if (profileId != null) {
        query = query..where((v) => v.profileId.equals(profileId));
      }

      query = query
        ..orderBy([
          (v) => OrderingTerm(expression: v.administrationDate, mode: OrderingMode.desc),
        ]);

      return await query.get();
    } catch (e) {
      if (e is VaccinationServiceException) rethrow;
      throw VaccinationServiceException(
        'Failed to retrieve vaccinations by vaccine: ${e.toString()}',
      );
    }
  }

  Future<List<Vaccination>> getIncompleteVaccinations({
    String? profileId,
  }) async {
    try {
      var query = _database.select(_database.vaccinations)
        ..where((v) => v.isActive.equals(true) & v.isComplete.equals(false));

      if (profileId != null) {
        query = query..where((v) => v.profileId.equals(profileId));
      }

      query = query
        ..orderBy([
          (v) => OrderingTerm(expression: v.nextDueDate),
        ]);

      return await query.get();
    } catch (e) {
      throw VaccinationServiceException(
        'Failed to retrieve incomplete vaccinations: ${e.toString()}',
      );
    }
  }

  Future<List<Vaccination>> getVaccinationsDueForBooster({
    String? profileId,
    int daysAhead = 30,
  }) async {
    try {
      final cutoffDate = DateTime.now().add(Duration(days: daysAhead));

      var query = _database.select(_database.vaccinations)
        ..where((v) =>
            v.isActive.equals(true) &
            v.nextDueDate.isNotNull() &
            v.nextDueDate.isSmallerOrEqualValue(cutoffDate));

      if (profileId != null) {
        query = query..where((v) => v.profileId.equals(profileId));
      }

      query = query
        ..orderBy([
          (v) => OrderingTerm(expression: v.nextDueDate),
        ]);

      return await query.get();
    } catch (e) {
      throw VaccinationServiceException(
        'Failed to retrieve vaccinations due for booster: ${e.toString()}',
      );
    }
  }

  // Analytics

  Future<Map<String, int>> getVaccinationCountsByVaccine({
    String? profileId,
  }) async {
    try {
      var query = _database.select(_database.vaccinations)
        ..where((v) => v.isActive.equals(true));

      if (profileId != null) {
        query = query..where((v) => v.profileId.equals(profileId));
      }

      final vaccinations = await query.get();
      final Map<String, int> counts = {};

      for (final vaccination in vaccinations) {
        final vaccineName = vaccination.vaccineName;
        counts[vaccineName] = (counts[vaccineName] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      throw VaccinationServiceException(
        'Failed to retrieve vaccination counts by vaccine: ${e.toString()}',
      );
    }
  }

  // Stream Operations

  Stream<List<Vaccination>> watchActiveVaccinations({String? profileId}) {
    return _medicalRecordDao.watchActiveVaccinations(profileId: profileId);
  }

  // Private Helper Methods

  void _validateCreateVaccinationRequest(CreateVaccinationRequest request) {
    if (request.profileId.isEmpty) {
      throw const VaccinationServiceException('Profile ID cannot be empty');
    }
    if (request.title.trim().isEmpty) {
      throw const VaccinationServiceException('Title cannot be empty');
    }
    if (request.vaccineName.trim().isEmpty) {
      throw const VaccinationServiceException('Vaccine name cannot be empty');
    }
    if (request.administrationDate.isAfter(DateTime.now().add(const Duration(days: 7)))) {
      throw const VaccinationServiceException(
        'Administration date cannot be more than 7 days in the future',
      );
    }
    if (request.nextDueDate != null &&
        request.nextDueDate!.isBefore(request.administrationDate)) {
      throw const VaccinationServiceException(
        'Next due date cannot be before administration date',
      );
    }
    if (request.doseNumber != null && request.doseNumber! <= 0) {
      throw const VaccinationServiceException('Dose number must be positive');
    }
  }

  void _validateUpdateVaccinationRequest(UpdateVaccinationRequest request) {
    if (request.title != null && request.title!.trim().isEmpty) {
      throw const VaccinationServiceException('Title cannot be empty');
    }
    if (request.vaccineName != null && request.vaccineName!.trim().isEmpty) {
      throw const VaccinationServiceException('Vaccine name cannot be empty');
    }
    if (request.administrationDate != null &&
        request.administrationDate!.isAfter(DateTime.now().add(const Duration(days: 7)))) {
      throw const VaccinationServiceException(
        'Administration date cannot be more than 7 days in the future',
      );
    }
    if (request.nextDueDate != null && request.administrationDate != null &&
        request.nextDueDate!.isBefore(request.administrationDate!)) {
      throw const VaccinationServiceException(
        'Next due date cannot be before administration date',
      );
    }
    if (request.doseNumber != null && request.doseNumber! <= 0) {
      throw const VaccinationServiceException('Dose number must be positive');
    }
  }
}

// Data Transfer Objects

class CreateVaccinationRequest {
  final String profileId;
  final String title;
  final String? description;
  final DateTime recordDate;
  final String vaccineName;
  final String? manufacturer;
  final String? batchNumber;
  final DateTime administrationDate;
  final String? administeredBy;
  final String? site;
  final DateTime? nextDueDate;
  final int? doseNumber;
  final bool isComplete;

  const CreateVaccinationRequest({
    required this.profileId,
    required this.title,
    this.description,
    required this.recordDate,
    required this.vaccineName,
    this.manufacturer,
    this.batchNumber,
    required this.administrationDate,
    this.administeredBy,
    this.site,
    this.nextDueDate,
    this.doseNumber,
    this.isComplete = false,
  });
}

class UpdateVaccinationRequest {
  final String? title;
  final String? description;
  final DateTime? recordDate;
  final String? vaccineName;
  final String? manufacturer;
  final String? batchNumber;
  final DateTime? administrationDate;
  final String? administeredBy;
  final String? site;
  final DateTime? nextDueDate;
  final int? doseNumber;
  final bool? isComplete;

  const UpdateVaccinationRequest({
    this.title,
    this.description,
    this.recordDate,
    this.vaccineName,
    this.manufacturer,
    this.batchNumber,
    this.administrationDate,
    this.administeredBy,
    this.site,
    this.nextDueDate,
    this.doseNumber,
    this.isComplete,
  });
}

// Exceptions

class VaccinationServiceException implements Exception {
  final String message;

  const VaccinationServiceException(this.message);

  @override
  String toString() => 'VaccinationServiceException: $message';
}