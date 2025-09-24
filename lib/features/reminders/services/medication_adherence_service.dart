import 'package:drift/drift.dart';

import '../../../data/database/app_database.dart';
import '../../../data/repositories/medication_adherence_dao.dart';
import '../../../data/models/medication_adherence.dart';

/// Service for managing medication adherence tracking
class MedicationAdherenceService {
  final MedicationAdherenceDao _adherenceDao;

  MedicationAdherenceService({
    MedicationAdherenceDao? adherenceDao,
    AppDatabase? database,
  }) : _adherenceDao = adherenceDao ??
           MedicationAdherenceDao(database ?? AppDatabase.instance);

  // CRUD Operations

  /// Record medication adherence
  Future<String> recordMedicationAdherence({
    required String reminderId,
    required String medicationId,
    required String profileId,
    required String medicationName,
    required String dosage,
    required DateTime scheduledTime,
    required String status,
    DateTime? recordedTime,
    String? notes,
  }) async {
    try {
      _validateAdherenceStatus(status);

      // Check if record already exists
      final exists = await _adherenceDao.adherenceRecordExists(
        reminderId,
        scheduledTime,
      );

      if (exists) {
        throw const MedicationAdherenceServiceException(
          'Adherence record already exists for this reminder and time',
        );
      }

      final adherenceId = 'adherence_${DateTime.now().millisecondsSinceEpoch}';

      final adherenceCompanion = MedicationAdherenceCompanion(
        id: Value(adherenceId),
        reminderId: Value(reminderId),
        medicationId: Value(medicationId),
        profileId: Value(profileId),
        medicationName: Value(medicationName.trim()),
        dosage: Value(dosage.trim()),
        scheduledTime: Value(scheduledTime),
        recordedTime: Value(recordedTime ?? DateTime.now()),
        status: Value(status),
        notes: Value(notes?.trim()),
        createdAt: Value(DateTime.now()),
      );

      return await _adherenceDao.createAdherenceRecord(adherenceCompanion);
    } catch (e) {
      if (e is MedicationAdherenceServiceException) rethrow;
      throw MedicationAdherenceServiceException(
        'Failed to record medication adherence: ${e.toString()}',
      );
    }
  }

  /// Record medication taken on time
  Future<String> recordMedicationTaken({
    required String reminderId,
    required String medicationId,
    required String profileId,
    required String medicationName,
    required String dosage,
    required DateTime scheduledTime,
    String? notes,
  }) async {
    final now = DateTime.now();
    final timeDifference = now.difference(scheduledTime).inMinutes.abs();

    // Consider "on time" if taken within 30 minutes of scheduled time
    const onTimeThreshold = 30;
    final status = timeDifference <= onTimeThreshold
        ? MedicationAdherenceStatus.taken
        : MedicationAdherenceStatus.takenLate;

    return await recordMedicationAdherence(
      reminderId: reminderId,
      medicationId: medicationId,
      profileId: profileId,
      medicationName: medicationName,
      dosage: dosage,
      scheduledTime: scheduledTime,
      recordedTime: now,
      status: status,
      notes: notes,
    );
  }

  /// Record medication missed
  Future<String> recordMedicationMissed({
    required String reminderId,
    required String medicationId,
    required String profileId,
    required String medicationName,
    required String dosage,
    required DateTime scheduledTime,
    String? notes,
  }) async {
    return await recordMedicationAdherence(
      reminderId: reminderId,
      medicationId: medicationId,
      profileId: profileId,
      medicationName: medicationName,
      dosage: dosage,
      scheduledTime: scheduledTime,
      status: MedicationAdherenceStatus.missed,
      notes: notes,
    );
  }

  /// Record medication skipped
  Future<String> recordMedicationSkipped({
    required String reminderId,
    required String medicationId,
    required String profileId,
    required String medicationName,
    required String dosage,
    required DateTime scheduledTime,
    String? notes,
  }) async {
    return await recordMedicationAdherence(
      reminderId: reminderId,
      medicationId: medicationId,
      profileId: profileId,
      medicationName: medicationName,
      dosage: dosage,
      scheduledTime: scheduledTime,
      status: MedicationAdherenceStatus.skipped,
      notes: notes,
    );
  }

  // Query Operations

  /// Get adherence records for a medication
  Future<List<MedicationAdherenceData>> getMedicationAdherence(
    String medicationId, {
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      return await _adherenceDao.getAdherenceByMedication(
        medicationId,
        fromDate: fromDate,
        toDate: toDate,
      );
    } catch (e) {
      throw MedicationAdherenceServiceException(
        'Failed to get medication adherence: ${e.toString()}',
      );
    }
  }

  /// Get adherence records for a profile
  Future<List<MedicationAdherenceData>> getProfileAdherence(
    String profileId, {
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      var records = await _adherenceDao.getAllAdherenceRecords(
        profileId: profileId,
      );

      if (fromDate != null) {
        records = records.where((r) =>
          r.scheduledTime.isAfter(fromDate) || r.scheduledTime.isAtSameMomentAs(fromDate)
        ).toList();
      }

      if (toDate != null) {
        records = records.where((r) =>
          r.scheduledTime.isBefore(toDate) || r.scheduledTime.isAtSameMomentAs(toDate)
        ).toList();
      }

      return records;
    } catch (e) {
      throw MedicationAdherenceServiceException(
        'Failed to get profile adherence: ${e.toString()}',
      );
    }
  }

  /// Get today's adherence records
  Future<List<MedicationAdherenceData>> getTodaysAdherence({
    String? profileId,
  }) async {
    try {
      return await _adherenceDao.getTodaysAdherence(profileId: profileId);
    } catch (e) {
      throw MedicationAdherenceServiceException(
        'Failed to get today\'s adherence: ${e.toString()}',
      );
    }
  }

  /// Get missed medications in recent period
  Future<List<MedicationAdherenceData>> getRecentMissedMedications({
    String? profileId,
    int days = 7,
  }) async {
    try {
      return await _adherenceDao.getRecentMissedMedications(
        profileId: profileId,
        days: days,
      );
    } catch (e) {
      throw MedicationAdherenceServiceException(
        'Failed to get recent missed medications: ${e.toString()}',
      );
    }
  }

  // Analytics Operations

  /// Get adherence statistics for a medication
  Future<AdherenceStatistics> getMedicationAdherenceStats(
    String medicationId, {
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      return await _adherenceDao.getMedicationAdherenceStats(
        medicationId,
        fromDate: fromDate,
        toDate: toDate,
      );
    } catch (e) {
      throw MedicationAdherenceServiceException(
        'Failed to get medication adherence stats: ${e.toString()}',
      );
    }
  }

  /// Get adherence statistics for a profile
  Future<AdherenceStatistics> getProfileAdherenceStats(
    String profileId, {
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      return await _adherenceDao.getProfileAdherenceStats(
        profileId,
        fromDate: fromDate,
        toDate: toDate,
      );
    } catch (e) {
      throw MedicationAdherenceServiceException(
        'Failed to get profile adherence stats: ${e.toString()}',
      );
    }
  }

  /// Get adherence rate for a medication
  Future<double> getMedicationAdherenceRate(
    String medicationId, {
    int days = 30,
  }) async {
    try {
      return await _adherenceDao.getMedicationAdherenceRate(
        medicationId,
        days: days,
      );
    } catch (e) {
      throw MedicationAdherenceServiceException(
        'Failed to get medication adherence rate: ${e.toString()}',
      );
    }
  }

  /// Get overall adherence summary for a profile
  Future<AdherenceSummary> getProfileAdherenceSummary(
    String profileId, {
    int days = 30,
  }) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));

      final records = await getProfileAdherence(
        profileId,
        fromDate: startDate,
        toDate: endDate,
      );

      final stats = await _adherenceDao.getProfileAdherenceStats(
        profileId,
        fromDate: startDate,
        toDate: endDate,
      );

      // Group by medication for detailed breakdown
      final medicationGroups = <String, List<MedicationAdherenceData>>{};
      for (final record in records) {
        medicationGroups
            .putIfAbsent(record.medicationId, () => [])
            .add(record);
      }

      final medicationStats = <String, AdherenceStatistics>{};
      for (final entry in medicationGroups.entries) {
        medicationStats[entry.key] = await _adherenceDao.getMedicationAdherenceStats(
          entry.key,
          fromDate: startDate,
          toDate: endDate,
        );
      }

      return AdherenceSummary(
        profileId: profileId,
        dateRange: DateRange(startDate, endDate),
        overallStats: stats,
        medicationStats: medicationStats,
        totalMedications: medicationGroups.length,
      );
    } catch (e) {
      throw MedicationAdherenceServiceException(
        'Failed to get profile adherence summary: ${e.toString()}',
      );
    }
  }

  // Stream Operations

  /// Watch adherence records for a medication
  Stream<List<MedicationAdherenceData>> watchMedicationAdherence(
    String medicationId,
  ) {
    return _adherenceDao.watchMedicationAdherence(medicationId);
  }

  /// Watch today's adherence records
  Stream<List<MedicationAdherenceData>> watchTodaysAdherence({
    String? profileId,
  }) {
    return _adherenceDao.watchTodaysAdherence(profileId: profileId);
  }

  // Helper Methods

  /// Check if reminder has adherence record
  Future<bool> hasAdherenceRecord(String reminderId, DateTime scheduledTime) async {
    try {
      return await _adherenceDao.adherenceRecordExists(reminderId, scheduledTime);
    } catch (e) {
      return false;
    }
  }

  /// Get adherence record for reminder
  Future<MedicationAdherenceData?> getAdherenceRecordForReminder(
    String reminderId,
    DateTime scheduledTime,
  ) async {
    try {
      final records = await _adherenceDao.getAdherenceByReminder(reminderId);
      return records
          .where((r) => r.scheduledTime.isAtSameMomentAs(scheduledTime))
          .firstOrNull;
    } catch (e) {
      return null;
    }
  }

  // Private Helper Methods

  void _validateAdherenceStatus(String status) {
    if (!MedicationAdherenceStatus.isValidStatus(status)) {
      throw MedicationAdherenceServiceException(
        'Invalid adherence status: $status',
      );
    }
  }
}

/// Data class for adherence summary
class AdherenceSummary {
  final String profileId;
  final DateRange dateRange;
  final AdherenceStatistics overallStats;
  final Map<String, AdherenceStatistics> medicationStats;
  final int totalMedications;

  const AdherenceSummary({
    required this.profileId,
    required this.dateRange,
    required this.overallStats,
    required this.medicationStats,
    required this.totalMedications,
  });
}

/// Data class for date range
class DateRange {
  final DateTime startDate;
  final DateTime endDate;

  const DateRange(this.startDate, this.endDate);

  int get dayCount => endDate.difference(startDate).inDays + 1;
}

/// Exception for medication adherence service
class MedicationAdherenceServiceException implements Exception {
  final String message;

  const MedicationAdherenceServiceException(this.message);

  @override
  String toString() => 'MedicationAdherenceServiceException: $message';
}