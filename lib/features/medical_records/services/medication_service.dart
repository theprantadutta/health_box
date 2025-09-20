import 'package:drift/drift.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/medical_record_dao.dart';
import '../../../data/repositories/reminder_dao.dart';
import '../../../data/models/medication.dart';

class MedicationService {
  final MedicalRecordDao _medicalRecordDao;
  final ReminderDao _reminderDao;
  final AppDatabase _database;

  MedicationService({
    MedicalRecordDao? medicalRecordDao,
    ReminderDao? reminderDao,
    AppDatabase? database,
  }) : _database = database ?? AppDatabase.instance,
       _medicalRecordDao =
           medicalRecordDao ??
           MedicalRecordDao(database ?? AppDatabase.instance),
       _reminderDao =
           reminderDao ?? ReminderDao(database ?? AppDatabase.instance);

  // CRUD Operations

  Future<List<Medication>> getAllMedications({String? profileId}) async {
    try {
      return await _medicalRecordDao.getAllMedications(profileId: profileId);
    } catch (e) {
      throw MedicationServiceException(
        'Failed to retrieve medications: ${e.toString()}',
      );
    }
  }

  Future<List<Medication>> getActiveMedications({String? profileId}) async {
    try {
      return await _medicalRecordDao.getActiveMedications(profileId: profileId);
    } catch (e) {
      throw MedicationServiceException(
        'Failed to retrieve active medications: ${e.toString()}',
      );
    }
  }

  Future<List<Medication>> getMedicationsWithReminders({
    String? profileId,
  }) async {
    try {
      return await _medicalRecordDao.getMedicationsWithReminders(
        profileId: profileId,
      );
    } catch (e) {
      throw MedicationServiceException(
        'Failed to retrieve medications with reminders: ${e.toString()}',
      );
    }
  }

  Future<Medication?> getMedicationById(String id) async {
    try {
      if (id.isEmpty) {
        throw const MedicationServiceException('Medication ID cannot be empty');
      }

      final medications = await _database.select(_database.medications).get();
      return medications.where((m) => m.id == id).firstOrNull;
    } catch (e) {
      if (e is MedicationServiceException) rethrow;
      throw MedicationServiceException(
        'Failed to retrieve medication: ${e.toString()}',
      );
    }
  }

  Future<String> createMedication(CreateMedicationRequest request) async {
    try {
      _validateCreateMedicationRequest(request);

      final medicationId =
          'medication_${DateTime.now().millisecondsSinceEpoch}';

      // Create medication-specific record
      final medicationCompanion = MedicationsCompanion(
        id: Value(medicationId),
        profileId: Value(request.profileId),
        recordType: const Value('medication'),
        title: Value(request.title.trim()),
        description: Value(request.description?.trim()),
        recordDate: Value(request.recordDate),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        isActive: const Value(true),
        // Medication-specific fields
        medicationName: Value(request.medicationName.trim()),
        dosage: Value(request.dosage.trim()),
        frequency: Value(request.frequency.trim()),
        schedule: Value(request.schedule),
        startDate: Value(request.startDate),
        endDate: Value(request.endDate),
        instructions: Value(request.instructions?.trim()),
        reminderEnabled: Value(request.reminderEnabled),
        pillCount: Value(request.pillCount),
        status: Value(request.status),
      );

      // Create general medical record entry
      final medicalRecordCompanion = MedicalRecordsCompanion(
        id: Value(medicationId),
        profileId: Value(request.profileId),
        recordType: const Value('medication'),
        title: Value(request.title.trim()),
        description: Value(request.description?.trim()),
        recordDate: Value(request.recordDate),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        isActive: const Value(true),
      );

      // Save both records in a transaction
      await _database.transaction(() async {
        await _medicalRecordDao.createMedication(medicationCompanion);
        await _medicalRecordDao.createRecord(medicalRecordCompanion);
      });

      // Create reminders if enabled
      if (request.reminderEnabled && request.reminderTimes.isNotEmpty) {
        await _createMedicationReminders(medicationId, request);
      }

      return medicationId;
    } catch (e) {
      if (e is MedicationServiceException) rethrow;
      throw MedicationServiceException(
        'Failed to create medication: ${e.toString()}',
      );
    }
  }

  Future<bool> updateMedication(
    String id,
    UpdateMedicationRequest request,
  ) async {
    try {
      if (id.isEmpty) {
        throw const MedicationServiceException('Medication ID cannot be empty');
      }

      final existingMedication = await getMedicationById(id);
      if (existingMedication == null) {
        throw const MedicationServiceException('Medication not found');
      }

      _validateUpdateMedicationRequest(request);

      final medicationCompanion = MedicationsCompanion(
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
        schedule: request.schedule != null
            ? Value(request.schedule!)
            : const Value.absent(),
        startDate: request.startDate != null
            ? Value(request.startDate!)
            : const Value.absent(),
        endDate: request.endDate != null
            ? Value(request.endDate)
            : const Value.absent(),
        instructions: request.instructions != null
            ? Value(request.instructions?.trim())
            : const Value.absent(),
        reminderEnabled: request.reminderEnabled != null
            ? Value(request.reminderEnabled!)
            : const Value.absent(),
        pillCount: request.pillCount != null
            ? Value(request.pillCount)
            : const Value.absent(),
        status: request.status != null
            ? Value(request.status!)
            : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      );

      final rowsAffected = await (_database.update(
        _database.medications,
      )..where((m) => m.id.equals(id))).write(medicationCompanion);

      // Update reminders if reminder settings changed
      if (request.reminderEnabled != null || request.reminderTimes != null) {
        await _updateMedicationReminders(id, request);
      }

      return rowsAffected > 0;
    } catch (e) {
      if (e is MedicationServiceException) rethrow;
      throw MedicationServiceException(
        'Failed to update medication: ${e.toString()}',
      );
    }
  }

  Future<bool> deleteMedication(String id) async {
    try {
      if (id.isEmpty) {
        throw const MedicationServiceException('Medication ID cannot be empty');
      }

      final existingMedication = await getMedicationById(id);
      if (existingMedication == null) {
        throw const MedicationServiceException('Medication not found');
      }

      // Delete associated reminders
      await _reminderDao.deleteRemindersByMedication(id);

      final rowsAffected =
          await (_database.update(
            _database.medications,
          )..where((m) => m.id.equals(id))).write(
            MedicationsCompanion(
              isActive: const Value(false),
              updatedAt: Value(DateTime.now()),
            ),
          );

      return rowsAffected > 0;
    } catch (e) {
      if (e is MedicationServiceException) rethrow;
      throw MedicationServiceException(
        'Failed to delete medication: ${e.toString()}',
      );
    }
  }

  // Status Management

  Future<bool> updateMedicationStatus(String id, String status) async {
    try {
      if (id.isEmpty) {
        throw const MedicationServiceException('Medication ID cannot be empty');
      }
      if (!_isValidStatus(status)) {
        throw MedicationServiceException('Invalid status: $status');
      }

      final rowsAffected =
          await (_database.update(
            _database.medications,
          )..where((m) => m.id.equals(id))).write(
            MedicationsCompanion(
              status: Value(status),
              updatedAt: Value(DateTime.now()),
            ),
          );

      return rowsAffected > 0;
    } catch (e) {
      if (e is MedicationServiceException) rethrow;
      throw MedicationServiceException(
        'Failed to update medication status: ${e.toString()}',
      );
    }
  }

  Future<bool> pauseMedication(String id) async {
    return await updateMedicationStatus(id, MedicationStatus.paused);
  }

  Future<bool> resumeMedication(String id) async {
    return await updateMedicationStatus(id, MedicationStatus.active);
  }

  Future<bool> completeMedication(String id) async {
    return await updateMedicationStatus(id, MedicationStatus.completed);
  }

  Future<bool> discontinueMedication(String id) async {
    return await updateMedicationStatus(id, MedicationStatus.discontinued);
  }

  // Pill Count Management

  Future<bool> updatePillCount(String id, int pillCount) async {
    try {
      if (id.isEmpty) {
        throw const MedicationServiceException('Medication ID cannot be empty');
      }
      if (pillCount < 0) {
        throw const MedicationServiceException('Pill count cannot be negative');
      }

      final rowsAffected =
          await (_database.update(
            _database.medications,
          )..where((m) => m.id.equals(id))).write(
            MedicationsCompanion(
              pillCount: Value(pillCount),
              updatedAt: Value(DateTime.now()),
            ),
          );

      return rowsAffected > 0;
    } catch (e) {
      if (e is MedicationServiceException) rethrow;
      throw MedicationServiceException(
        'Failed to update pill count: ${e.toString()}',
      );
    }
  }

  Future<bool> decrementPillCount(String id, {int amount = 1}) async {
    try {
      final medication = await getMedicationById(id);
      if (medication == null) {
        throw const MedicationServiceException('Medication not found');
      }

      if (medication.pillCount == null) {
        throw const MedicationServiceException(
          'Pill count not set for this medication',
        );
      }

      final newCount = medication.pillCount! - amount;
      if (newCount < 0) {
        throw const MedicationServiceException(
          'Cannot decrement below zero pills',
        );
      }

      return await updatePillCount(id, newCount);
    } catch (e) {
      if (e is MedicationServiceException) rethrow;
      throw MedicationServiceException(
        'Failed to decrement pill count: ${e.toString()}',
      );
    }
  }

  // Reminder Integration

  Future<List<Reminder>> getMedicationReminders(String medicationId) async {
    try {
      if (medicationId.isEmpty) {
        throw const MedicationServiceException('Medication ID cannot be empty');
      }
      return await _reminderDao.getRemindersByMedication(medicationId);
    } catch (e) {
      throw MedicationServiceException(
        'Failed to retrieve medication reminders: ${e.toString()}',
      );
    }
  }

  Future<bool> toggleReminders(String id, bool enabled) async {
    try {
      if (id.isEmpty) {
        throw const MedicationServiceException('Medication ID cannot be empty');
      }

      final rowsAffected =
          await (_database.update(
            _database.medications,
          )..where((m) => m.id.equals(id))).write(
            MedicationsCompanion(
              reminderEnabled: Value(enabled),
              updatedAt: Value(DateTime.now()),
            ),
          );

      if (!enabled) {
        // Deactivate existing reminders
        final reminders = await _reminderDao.getRemindersByMedication(id);
        for (final reminder in reminders) {
          await _reminderDao.toggleReminderActive(reminder.id, false);
        }
      }

      return rowsAffected > 0;
    } catch (e) {
      if (e is MedicationServiceException) rethrow;
      throw MedicationServiceException(
        'Failed to toggle medication reminders: ${e.toString()}',
      );
    }
  }

  // Analytics and Queries

  Future<List<Medication>> getMedicationsByStatus(
    String status, {
    String? profileId,
  }) async {
    try {
      if (!_isValidStatus(status)) {
        throw MedicationServiceException('Invalid status: $status');
      }

      var query = _database.select(_database.medications)
        ..where((m) => m.isActive.equals(true) & m.status.equals(status));

      if (profileId != null) {
        query = query..where((m) => m.profileId.equals(profileId));
      }

      query = query
        ..orderBy([
          (m) => OrderingTerm(expression: m.startDate, mode: OrderingMode.desc),
        ]);

      return await query.get();
    } catch (e) {
      if (e is MedicationServiceException) rethrow;
      throw MedicationServiceException(
        'Failed to retrieve medications by status: ${e.toString()}',
      );
    }
  }

  Future<List<Medication>> getMedicationsLowOnPills({
    int threshold = 7,
    String? profileId,
  }) async {
    try {
      var query = _database.select(_database.medications)
        ..where(
          (m) =>
              m.isActive.equals(true) &
              m.status.equals(MedicationStatus.active) &
              m.pillCount.isNotNull() &
              m.pillCount.isSmallerOrEqualValue(threshold),
        );

      if (profileId != null) {
        query = query..where((m) => m.profileId.equals(profileId));
      }

      query = query..orderBy([(m) => OrderingTerm(expression: m.pillCount)]);

      return await query.get();
    } catch (e) {
      throw MedicationServiceException(
        'Failed to retrieve medications low on pills: ${e.toString()}',
      );
    }
  }

  Future<Map<String, int>> getMedicationCountsByStatus({
    String? profileId,
  }) async {
    try {
      final Map<String, int> counts = {};

      for (final status in MedicationStatus.allStatuses) {
        final medications = await getMedicationsByStatus(
          status,
          profileId: profileId,
        );
        counts[status] = medications.length;
      }

      return counts;
    } catch (e) {
      throw MedicationServiceException(
        'Failed to retrieve medication counts by status: ${e.toString()}',
      );
    }
  }

  // Stream Operations

  Stream<List<Medication>> watchActiveMedications({String? profileId}) {
    return _medicalRecordDao.watchActiveMedications(profileId: profileId);
  }

  // Private Helper Methods

  Future<void> _createMedicationReminders(
    String medicationId,
    CreateMedicationRequest request,
  ) async {
    for (final reminderTime in request.reminderTimes) {
      final reminderId =
          'reminder_${DateTime.now().millisecondsSinceEpoch}_${reminderTime.hour}_${reminderTime.minute}';

      final scheduledTime = DateTime(
        request.startDate.year,
        request.startDate.month,
        request.startDate.day,
        reminderTime.hour,
        reminderTime.minute,
      );

      final reminderCompanion = RemindersCompanion(
        id: Value(reminderId),
        medicationId: Value(medicationId),
        title: Value('${request.medicationName} - ${request.dosage}'),
        description: Value(
          'Take ${request.dosage} of ${request.medicationName}',
        ),
        scheduledTime: Value(scheduledTime),
        frequency: Value('daily'),
        isActive: const Value(true),
        nextScheduled: Value(scheduledTime),
        snoozeMinutes: const Value(15),
      );

      await _reminderDao.createReminder(reminderCompanion);
    }
  }

  Future<void> _updateMedicationReminders(
    String medicationId,
    UpdateMedicationRequest request,
  ) async {
    // Delete existing reminders
    await _reminderDao.deleteRemindersByMedication(medicationId);

    // Create new reminders if enabled
    if (request.reminderEnabled == true &&
        request.reminderTimes != null &&
        request.reminderTimes!.isNotEmpty) {
      final medication = await getMedicationById(medicationId);
      if (medication != null) {
        final createRequest = CreateMedicationRequest(
          profileId: medication.profileId,
          title: medication.title,
          recordDate: medication.recordDate,
          medicationName: medication.medicationName,
          dosage: medication.dosage,
          frequency: medication.frequency,
          schedule: medication.schedule,
          startDate: medication.startDate,
          endDate: medication.endDate,
          reminderEnabled: true,
          status: medication.status,
          reminderTimes: request.reminderTimes!,
        );

        await _createMedicationReminders(medicationId, createRequest);
      }
    }
  }

  void _validateCreateMedicationRequest(CreateMedicationRequest request) {
    if (request.profileId.isEmpty) {
      throw const MedicationServiceException('Profile ID cannot be empty');
    }
    if (request.title.trim().isEmpty) {
      throw const MedicationServiceException('Title cannot be empty');
    }
    if (request.medicationName.trim().isEmpty) {
      throw const MedicationServiceException('Medication name cannot be empty');
    }
    if (request.dosage.trim().isEmpty) {
      throw const MedicationServiceException('Dosage cannot be empty');
    }
    if (request.frequency.trim().isEmpty) {
      throw const MedicationServiceException('Frequency cannot be empty');
    }
    if (!_isValidStatus(request.status)) {
      throw MedicationServiceException('Invalid status: ${request.status}');
    }
    if (request.endDate != null &&
        request.startDate.isAfter(request.endDate!)) {
      throw const MedicationServiceException(
        'Start date cannot be after end date',
      );
    }
    if (request.pillCount != null && request.pillCount! < 0) {
      throw const MedicationServiceException('Pill count cannot be negative');
    }
  }

  void _validateUpdateMedicationRequest(UpdateMedicationRequest request) {
    if (request.title != null && request.title!.trim().isEmpty) {
      throw const MedicationServiceException('Title cannot be empty');
    }
    if (request.medicationName != null &&
        request.medicationName!.trim().isEmpty) {
      throw const MedicationServiceException('Medication name cannot be empty');
    }
    if (request.dosage != null && request.dosage!.trim().isEmpty) {
      throw const MedicationServiceException('Dosage cannot be empty');
    }
    if (request.frequency != null && request.frequency!.trim().isEmpty) {
      throw const MedicationServiceException('Frequency cannot be empty');
    }
    if (request.status != null && !_isValidStatus(request.status!)) {
      throw MedicationServiceException('Invalid status: ${request.status}');
    }
    if (request.startDate != null &&
        request.endDate != null &&
        request.startDate!.isAfter(request.endDate!)) {
      throw const MedicationServiceException(
        'Start date cannot be after end date',
      );
    }
    if (request.pillCount != null && request.pillCount! < 0) {
      throw const MedicationServiceException('Pill count cannot be negative');
    }
  }

  bool _isValidStatus(String status) {
    return MedicationStatus.isValidStatus(status);
  }
}

// Data Transfer Objects

class CreateMedicationRequest {
  final String profileId;
  final String title;
  final String? description;
  final DateTime recordDate;
  final String medicationName;
  final String dosage;
  final String frequency;
  final String schedule;
  final DateTime startDate;
  final DateTime? endDate;
  final String? instructions;
  final bool reminderEnabled;
  final int? pillCount;
  final String status;
  final List<MedicationTime> reminderTimes;

  const CreateMedicationRequest({
    required this.profileId,
    required this.title,
    this.description,
    required this.recordDate,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.schedule,
    required this.startDate,
    this.endDate,
    this.instructions,
    this.reminderEnabled = true,
    this.pillCount,
    this.status = MedicationStatus.active,
    this.reminderTimes = const [],
  });
}

class UpdateMedicationRequest {
  final String? title;
  final String? description;
  final DateTime? recordDate;
  final String? medicationName;
  final String? dosage;
  final String? frequency;
  final String? schedule;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? instructions;
  final bool? reminderEnabled;
  final int? pillCount;
  final String? status;
  final List<MedicationTime>? reminderTimes;

  const UpdateMedicationRequest({
    this.title,
    this.description,
    this.recordDate,
    this.medicationName,
    this.dosage,
    this.frequency,
    this.schedule,
    this.startDate,
    this.endDate,
    this.instructions,
    this.reminderEnabled,
    this.pillCount,
    this.status,
    this.reminderTimes,
  });
}

class MedicationTime {
  final int hour;
  final int minute;

  const MedicationTime({required this.hour, required this.minute});
}

// Exceptions

class MedicationServiceException implements Exception {
  final String message;

  const MedicationServiceException(this.message);

  @override
  String toString() => 'MedicationServiceException: $message';
}
