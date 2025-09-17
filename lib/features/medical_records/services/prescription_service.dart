import 'package:drift/drift.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/medical_record_dao.dart';

class PrescriptionService {
  final MedicalRecordDao _medicalRecordDao;
  final AppDatabase _database;

  PrescriptionService({
    MedicalRecordDao? medicalRecordDao,
    AppDatabase? database,
  }) : _database = database ?? AppDatabase.instance,
       _medicalRecordDao =
           medicalRecordDao ??
           MedicalRecordDao(database ?? AppDatabase.instance);

  // CRUD Operations

  Future<List<Prescription>> getAllPrescriptions({String? profileId}) async {
    try {
      return await _medicalRecordDao.getAllPrescriptions(profileId: profileId);
    } catch (e) {
      throw PrescriptionServiceException(
        'Failed to retrieve prescriptions: ${e.toString()}',
      );
    }
  }

  Future<List<Prescription>> getActivePrescriptions({String? profileId}) async {
    try {
      return await _medicalRecordDao.getActivePrescriptions(
        profileId: profileId,
      );
    } catch (e) {
      throw PrescriptionServiceException(
        'Failed to retrieve active prescriptions: ${e.toString()}',
      );
    }
  }

  Future<Prescription?> getPrescriptionById(String id) async {
    try {
      if (id.isEmpty) {
        throw const PrescriptionServiceException(
          'Prescription ID cannot be empty',
        );
      }

      final prescriptions = await _database
          .select(_database.prescriptions)
          .get();
      return prescriptions.where((p) => p.id == id).firstOrNull;
    } catch (e) {
      if (e is PrescriptionServiceException) rethrow;
      throw PrescriptionServiceException(
        'Failed to retrieve prescription: ${e.toString()}',
      );
    }
  }

  Future<String> createPrescription(CreatePrescriptionRequest request) async {
    try {
      _validateCreatePrescriptionRequest(request);

      final prescriptionId =
          'prescription_${DateTime.now().millisecondsSinceEpoch}';
      final prescriptionCompanion = PrescriptionsCompanion(
        id: Value(prescriptionId),
        profileId: Value(request.profileId),
        recordType: const Value('prescription'),
        title: Value(request.title.trim()),
        description: Value(request.description?.trim()),
        recordDate: Value(request.recordDate),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        isActive: const Value(true),
        // Prescription-specific fields
        medicationName: Value(request.medicationName.trim()),
        dosage: Value(request.dosage.trim()),
        frequency: Value(request.frequency.trim()),
        instructions: Value(request.instructions?.trim()),
        prescribingDoctor: Value(request.prescribingDoctor?.trim()),
        pharmacy: Value(request.pharmacy?.trim()),
        startDate: Value(request.startDate),
        endDate: Value(request.endDate),
        refillsRemaining: Value(request.refillsRemaining),
        isPrescriptionActive: Value(request.isPrescriptionActive),
      );

      return await _medicalRecordDao.createPrescription(prescriptionCompanion);
    } catch (e) {
      if (e is PrescriptionServiceException) rethrow;
      throw PrescriptionServiceException(
        'Failed to create prescription: ${e.toString()}',
      );
    }
  }

  Future<bool> updatePrescription(
    String id,
    UpdatePrescriptionRequest request,
  ) async {
    try {
      if (id.isEmpty) {
        throw const PrescriptionServiceException(
          'Prescription ID cannot be empty',
        );
      }

      final existingPrescription = await getPrescriptionById(id);
      if (existingPrescription == null) {
        throw const PrescriptionServiceException('Prescription not found');
      }

      _validateUpdatePrescriptionRequest(request);

      final prescriptionCompanion = PrescriptionsCompanion(
        title: request.title != null
            ? Value(request.title!.trim())
            : const Value.absent(),
        description: request.description != null
            ? Value(request.description?.trim())
            : const Value.absent(),
        recordDate: request.recordDate != null
            ? Value(request.recordDate!)
            : const Value.absent(),
        medicationName: request.medicationName != null
            ? Value(request.medicationName!.trim())
            : const Value.absent(),
        dosage: request.dosage != null
            ? Value(request.dosage!.trim())
            : const Value.absent(),
        frequency: request.frequency != null
            ? Value(request.frequency!.trim())
            : const Value.absent(),
        instructions: request.instructions != null
            ? Value(request.instructions?.trim())
            : const Value.absent(),
        prescribingDoctor: request.prescribingDoctor != null
            ? Value(request.prescribingDoctor?.trim())
            : const Value.absent(),
        pharmacy: request.pharmacy != null
            ? Value(request.pharmacy?.trim())
            : const Value.absent(),
        startDate: request.startDate != null
            ? Value(request.startDate)
            : const Value.absent(),
        endDate: request.endDate != null
            ? Value(request.endDate)
            : const Value.absent(),
        refillsRemaining: request.refillsRemaining != null
            ? Value(request.refillsRemaining)
            : const Value.absent(),
        isPrescriptionActive: request.isPrescriptionActive != null
            ? Value(request.isPrescriptionActive!)
            : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      );

      final rowsAffected = await (_database.update(
        _database.prescriptions,
      )..where((p) => p.id.equals(id))).write(prescriptionCompanion);

      return rowsAffected > 0;
    } catch (e) {
      if (e is PrescriptionServiceException) rethrow;
      throw PrescriptionServiceException(
        'Failed to update prescription: ${e.toString()}',
      );
    }
  }

  Future<bool> deletePrescription(String id) async {
    try {
      if (id.isEmpty) {
        throw const PrescriptionServiceException(
          'Prescription ID cannot be empty',
        );
      }

      final existingPrescription = await getPrescriptionById(id);
      if (existingPrescription == null) {
        throw const PrescriptionServiceException('Prescription not found');
      }

      final rowsAffected =
          await (_database.update(
            _database.prescriptions,
          )..where((p) => p.id.equals(id))).write(
            PrescriptionsCompanion(
              isActive: const Value(false),
              updatedAt: Value(DateTime.now()),
            ),
          );

      return rowsAffected > 0;
    } catch (e) {
      if (e is PrescriptionServiceException) rethrow;
      throw PrescriptionServiceException(
        'Failed to delete prescription: ${e.toString()}',
      );
    }
  }

  // Prescription-specific Operations

  Future<List<Prescription>> getPrescriptionsByMedication(
    String medicationName, {
    String? profileId,
  }) async {
    try {
      if (medicationName.isEmpty) {
        throw const PrescriptionServiceException(
          'Medication name cannot be empty',
        );
      }

      var query = _database.select(_database.prescriptions)
        ..where(
          (p) =>
              p.isActive.equals(true) &
              p.medicationName.lower().like(
                '%${medicationName.toLowerCase()}%',
              ),
        );

      if (profileId != null) {
        query = query..where((p) => p.profileId.equals(profileId));
      }

      query = query
        ..orderBy([
          (p) =>
              OrderingTerm(expression: p.recordDate, mode: OrderingMode.desc),
        ]);

      return await query.get();
    } catch (e) {
      if (e is PrescriptionServiceException) rethrow;
      throw PrescriptionServiceException(
        'Failed to retrieve prescriptions by medication: ${e.toString()}',
      );
    }
  }

  Future<List<Prescription>> getPrescriptionsByDoctor(
    String doctorName, {
    String? profileId,
  }) async {
    try {
      if (doctorName.isEmpty) {
        throw const PrescriptionServiceException('Doctor name cannot be empty');
      }

      var query = _database.select(_database.prescriptions)
        ..where(
          (p) =>
              p.isActive.equals(true) &
              p.prescribingDoctor.isNotNull() &
              p.prescribingDoctor.lower().like('%${doctorName.toLowerCase()}%'),
        );

      if (profileId != null) {
        query = query..where((p) => p.profileId.equals(profileId));
      }

      query = query
        ..orderBy([
          (p) =>
              OrderingTerm(expression: p.recordDate, mode: OrderingMode.desc),
        ]);

      return await query.get();
    } catch (e) {
      if (e is PrescriptionServiceException) rethrow;
      throw PrescriptionServiceException(
        'Failed to retrieve prescriptions by doctor: ${e.toString()}',
      );
    }
  }

  Future<List<Prescription>> getExpiredPrescriptions({
    String? profileId,
  }) async {
    try {
      final now = DateTime.now();

      var query = _database.select(_database.prescriptions)
        ..where(
          (p) =>
              p.isActive.equals(true) &
              p.endDate.isNotNull() &
              p.endDate.isSmallerThanValue(now),
        );

      if (profileId != null) {
        query = query..where((p) => p.profileId.equals(profileId));
      }

      query = query
        ..orderBy([
          (p) => OrderingTerm(expression: p.endDate, mode: OrderingMode.desc),
        ]);

      return await query.get();
    } catch (e) {
      throw PrescriptionServiceException(
        'Failed to retrieve expired prescriptions: ${e.toString()}',
      );
    }
  }

  Future<List<Prescription>> getExpiringPrescriptions({
    int daysAhead = 30,
    String? profileId,
  }) async {
    try {
      final now = DateTime.now();
      final futureDate = now.add(Duration(days: daysAhead));

      var query = _database.select(_database.prescriptions)
        ..where(
          (p) =>
              p.isActive.equals(true) &
              p.endDate.isNotNull() &
              p.endDate.isBiggerThanValue(now) &
              p.endDate.isSmallerOrEqualValue(futureDate),
        );

      if (profileId != null) {
        query = query..where((p) => p.profileId.equals(profileId));
      }

      query = query..orderBy([(p) => OrderingTerm(expression: p.endDate)]);

      return await query.get();
    } catch (e) {
      throw PrescriptionServiceException(
        'Failed to retrieve expiring prescriptions: ${e.toString()}',
      );
    }
  }

  Future<List<Prescription>> getPrescriptionsNeedingRefill({
    String? profileId,
  }) async {
    try {
      var query = _database.select(_database.prescriptions)
        ..where(
          (p) =>
              p.isActive.equals(true) &
              p.isPrescriptionActive.equals(true) &
              p.refillsRemaining.isNotNull() &
              p.refillsRemaining.isSmallerOrEqualValue(2),
        );

      if (profileId != null) {
        query = query..where((p) => p.profileId.equals(profileId));
      }

      query = query
        ..orderBy([(p) => OrderingTerm(expression: p.refillsRemaining)]);

      return await query.get();
    } catch (e) {
      throw PrescriptionServiceException(
        'Failed to retrieve prescriptions needing refill: ${e.toString()}',
      );
    }
  }

  Future<bool> markPrescriptionAsInactive(String id) async {
    try {
      if (id.isEmpty) {
        throw const PrescriptionServiceException(
          'Prescription ID cannot be empty',
        );
      }

      final rowsAffected =
          await (_database.update(
            _database.prescriptions,
          )..where((p) => p.id.equals(id))).write(
            PrescriptionsCompanion(
              isPrescriptionActive: const Value(false),
              updatedAt: Value(DateTime.now()),
            ),
          );

      return rowsAffected > 0;
    } catch (e) {
      throw PrescriptionServiceException(
        'Failed to mark prescription as inactive: ${e.toString()}',
      );
    }
  }

  Future<bool> updateRefillsRemaining(String id, int refills) async {
    try {
      if (id.isEmpty) {
        throw const PrescriptionServiceException(
          'Prescription ID cannot be empty',
        );
      }
      if (refills < 0) {
        throw const PrescriptionServiceException(
          'Refills remaining cannot be negative',
        );
      }

      final rowsAffected =
          await (_database.update(
            _database.prescriptions,
          )..where((p) => p.id.equals(id))).write(
            PrescriptionsCompanion(
              refillsRemaining: Value(refills),
              updatedAt: Value(DateTime.now()),
            ),
          );

      return rowsAffected > 0;
    } catch (e) {
      if (e is PrescriptionServiceException) rethrow;
      throw PrescriptionServiceException(
        'Failed to update refills remaining: ${e.toString()}',
      );
    }
  }

  Future<bool> decrementRefillsRemaining(String id) async {
    try {
      final prescription = await getPrescriptionById(id);
      if (prescription == null) {
        throw const PrescriptionServiceException('Prescription not found');
      }

      if (prescription.refillsRemaining == null ||
          prescription.refillsRemaining! <= 0) {
        throw const PrescriptionServiceException('No refills remaining');
      }

      return await updateRefillsRemaining(
        id,
        prescription.refillsRemaining! - 1,
      );
    } catch (e) {
      if (e is PrescriptionServiceException) rethrow;
      throw PrescriptionServiceException(
        'Failed to decrement refills remaining: ${e.toString()}',
      );
    }
  }

  // Analytics and Statistics

  Future<int> getPrescriptionCount({String? profileId}) async {
    try {
      var query = _database.selectOnly(_database.prescriptions)
        ..addColumns([_database.prescriptions.id.count()])
        ..where(_database.prescriptions.isActive.equals(true));

      if (profileId != null) {
        query = query
          ..where(_database.prescriptions.profileId.equals(profileId));
      }

      final result = await query.getSingle();
      return result.read(_database.prescriptions.id.count()) ?? 0;
    } catch (e) {
      throw PrescriptionServiceException(
        'Failed to retrieve prescription count: ${e.toString()}',
      );
    }
  }

  Future<Map<String, int>> getPrescriptionCountsByStatus({
    String? profileId,
  }) async {
    try {
      final activePrescriptions = await getActivePrescriptions(
        profileId: profileId,
      );
      final expiredPrescriptions = await getExpiredPrescriptions(
        profileId: profileId,
      );
      final needRefillPrescriptions = await getPrescriptionsNeedingRefill(
        profileId: profileId,
      );

      return {
        'active': activePrescriptions.length,
        'expired': expiredPrescriptions.length,
        'needRefill': needRefillPrescriptions.length,
        'total': activePrescriptions.length + expiredPrescriptions.length,
      };
    } catch (e) {
      throw PrescriptionServiceException(
        'Failed to retrieve prescription counts by status: ${e.toString()}',
      );
    }
  }

  Future<List<String>> getMostPrescribedMedications({
    String? profileId,
    int limit = 10,
  }) async {
    try {
      var query = _database.selectOnly(_database.prescriptions)
        ..addColumns([
          _database.prescriptions.medicationName,
          _database.prescriptions.id.count(),
        ])
        ..where(_database.prescriptions.isActive.equals(true));

      if (profileId != null) {
        query = query
          ..where(_database.prescriptions.profileId.equals(profileId));
      }

      query = query
        ..groupBy([_database.prescriptions.medicationName])
        ..orderBy([
          OrderingTerm(
            expression: _database.prescriptions.id.count(),
            mode: OrderingMode.desc,
          ),
        ])
        ..limit(limit);

      final results = await query.get();
      return results
          .map((result) => result.read(_database.prescriptions.medicationName)!)
          .toList();
    } catch (e) {
      throw PrescriptionServiceException(
        'Failed to retrieve most prescribed medications: ${e.toString()}',
      );
    }
  }

  // Utility Methods

  Future<bool> prescriptionExists(String id) async {
    try {
      if (id.isEmpty) return false;
      final prescription = await getPrescriptionById(id);
      return prescription != null;
    } catch (e) {
      return false;
    }
  }

  bool isPrescriptionExpired(Prescription prescription) {
    if (prescription.endDate == null) return false;
    return prescription.endDate!.isBefore(DateTime.now());
  }

  bool needsRefill(Prescription prescription) {
    if (prescription.refillsRemaining == null) return false;
    return prescription.refillsRemaining! <= 2;
  }

  int getDaysUntilExpiry(Prescription prescription) {
    if (prescription.endDate == null) return -1;
    return prescription.endDate!.difference(DateTime.now()).inDays;
  }

  // Validation Methods

  void _validateCreatePrescriptionRequest(CreatePrescriptionRequest request) {
    if (request.profileId.isEmpty) {
      throw const PrescriptionServiceException('Profile ID cannot be empty');
    }
    if (request.title.trim().isEmpty) {
      throw const PrescriptionServiceException('Title cannot be empty');
    }
    if (request.title.length > 200) {
      throw const PrescriptionServiceException(
        'Title cannot exceed 200 characters',
      );
    }
    if (request.medicationName.trim().isEmpty) {
      throw const PrescriptionServiceException(
        'Medication name cannot be empty',
      );
    }
    if (request.medicationName.length > 100) {
      throw const PrescriptionServiceException(
        'Medication name cannot exceed 100 characters',
      );
    }
    if (request.dosage.trim().isEmpty) {
      throw const PrescriptionServiceException('Dosage cannot be empty');
    }
    if (request.frequency.trim().isEmpty) {
      throw const PrescriptionServiceException('Frequency cannot be empty');
    }
    if (request.refillsRemaining != null && request.refillsRemaining! < 0) {
      throw const PrescriptionServiceException(
        'Refills remaining cannot be negative',
      );
    }
    if (request.startDate != null && request.endDate != null) {
      if (request.startDate!.isAfter(request.endDate!)) {
        throw const PrescriptionServiceException(
          'Start date cannot be after end date',
        );
      }
    }
  }

  void _validateUpdatePrescriptionRequest(UpdatePrescriptionRequest request) {
    if (request.title != null && request.title!.trim().isEmpty) {
      throw const PrescriptionServiceException('Title cannot be empty');
    }
    if (request.title != null && request.title!.length > 200) {
      throw const PrescriptionServiceException(
        'Title cannot exceed 200 characters',
      );
    }
    if (request.medicationName != null &&
        request.medicationName!.trim().isEmpty) {
      throw const PrescriptionServiceException(
        'Medication name cannot be empty',
      );
    }
    if (request.medicationName != null &&
        request.medicationName!.length > 100) {
      throw const PrescriptionServiceException(
        'Medication name cannot exceed 100 characters',
      );
    }
    if (request.dosage != null && request.dosage!.trim().isEmpty) {
      throw const PrescriptionServiceException('Dosage cannot be empty');
    }
    if (request.frequency != null && request.frequency!.trim().isEmpty) {
      throw const PrescriptionServiceException('Frequency cannot be empty');
    }
    if (request.refillsRemaining != null && request.refillsRemaining! < 0) {
      throw const PrescriptionServiceException(
        'Refills remaining cannot be negative',
      );
    }
    if (request.startDate != null && request.endDate != null) {
      if (request.startDate!.isAfter(request.endDate!)) {
        throw const PrescriptionServiceException(
          'Start date cannot be after end date',
        );
      }
    }
  }
}

// Data Transfer Objects

class CreatePrescriptionRequest {
  final String profileId;
  final String title;
  final String? description;
  final DateTime recordDate;
  final String medicationName;
  final String dosage;
  final String frequency;
  final String? instructions;
  final String? prescribingDoctor;
  final String? pharmacy;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? refillsRemaining;
  final bool isPrescriptionActive;

  const CreatePrescriptionRequest({
    required this.profileId,
    required this.title,
    this.description,
    required this.recordDate,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    this.instructions,
    this.prescribingDoctor,
    this.pharmacy,
    this.startDate,
    this.endDate,
    this.refillsRemaining,
    this.isPrescriptionActive = true,
  });
}

class UpdatePrescriptionRequest {
  final String? title;
  final String? description;
  final DateTime? recordDate;
  final String? medicationName;
  final String? dosage;
  final String? frequency;
  final String? instructions;
  final String? prescribingDoctor;
  final String? pharmacy;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? refillsRemaining;
  final bool? isPrescriptionActive;

  const UpdatePrescriptionRequest({
    this.title,
    this.description,
    this.recordDate,
    this.medicationName,
    this.dosage,
    this.frequency,
    this.instructions,
    this.prescribingDoctor,
    this.pharmacy,
    this.startDate,
    this.endDate,
    this.refillsRemaining,
    this.isPrescriptionActive,
  });
}

// Exceptions

class PrescriptionServiceException implements Exception {
  final String message;

  const PrescriptionServiceException(this.message);

  @override
  String toString() => 'PrescriptionServiceException: $message';
}
