import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/medication_adherence.dart';

/// Data Access Object for medication adherence records
class MedicationAdherenceDao {
  final AppDatabase _database;

  MedicationAdherenceDao(this._database);

  // CRUD Operations

  /// Get all adherence records for a profile
  Future<List<MedicationAdherenceData>> getAllAdherenceRecords({
    String? profileId,
  }) async {
    try {
      var query = _database.select(_database.medicationAdherence);

      if (profileId != null) {
        query = query..where((a) => a.profileId.equals(profileId));
      }

      query = query
        ..orderBy([
          (a) => OrderingTerm(expression: a.scheduledTime, mode: OrderingMode.desc),
        ]);

      return await query.get();
    } catch (e) {
      throw Exception('Failed to get adherence records from database: $e');
    }
  }

  /// Get adherence records for a specific medication
  Future<List<MedicationAdherenceData>> getAdherenceByMedication(
    String medicationId, {
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      var query = _database.select(_database.medicationAdherence)
        ..where((a) => a.medicationId.equals(medicationId));

      if (fromDate != null) {
        query = query..where((a) => a.scheduledTime.isBiggerOrEqualValue(fromDate));
      }

      if (toDate != null) {
        query = query..where((a) => a.scheduledTime.isSmallerOrEqualValue(toDate));
      }

      query = query
        ..orderBy([
          (a) => OrderingTerm(expression: a.scheduledTime, mode: OrderingMode.desc),
        ]);

      return await query.get();
    } catch (e) {
      throw Exception('Failed to get medication adherence records from database: $e');
    }
  }

  /// Get adherence records for a specific reminder
  Future<List<MedicationAdherenceData>> getAdherenceByReminder(
    String reminderId,
  ) async {
    try {
      final query = _database.select(_database.medicationAdherence)
        ..where((a) => a.reminderId.equals(reminderId))
        ..orderBy([
          (a) => OrderingTerm(expression: a.scheduledTime, mode: OrderingMode.desc),
        ]);

      return await query.get();
    } catch (e) {
      throw Exception('Failed to get reminder adherence records from database: $e');
    }
  }

  /// Get adherence records by status
  Future<List<MedicationAdherenceData>> getAdherenceByStatus(
    String status, {
    String? profileId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      var query = _database.select(_database.medicationAdherence)
        ..where((a) => a.status.equals(status));

      if (profileId != null) {
        query = query..where((a) => a.profileId.equals(profileId));
      }

      if (fromDate != null) {
        query = query..where((a) => a.scheduledTime.isBiggerOrEqualValue(fromDate));
      }

      if (toDate != null) {
        query = query..where((a) => a.scheduledTime.isSmallerOrEqualValue(toDate));
      }

      query = query
        ..orderBy([
          (a) => OrderingTerm(expression: a.scheduledTime, mode: OrderingMode.desc),
        ]);

      return await query.get();
    } catch (e) {
      throw Exception('Failed to get adherence records by status from database: $e');
    }
  }

  /// Get adherence records for today
  Future<List<MedicationAdherenceData>> getTodaysAdherence({
    String? profileId,
  }) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      var query = _database.select(_database.medicationAdherence)
        ..where(
          (a) =>
              a.scheduledTime.isBiggerOrEqualValue(startOfDay) &
              a.scheduledTime.isSmallerThanValue(endOfDay),
        );

      if (profileId != null) {
        query = query..where((a) => a.profileId.equals(profileId));
      }

      query = query
        ..orderBy([
          (a) => OrderingTerm(expression: a.scheduledTime),
        ]);

      return await query.get();
    } catch (e) {
      throw Exception('Failed to get today\'s adherence records from database: $e');
    }
  }

  /// Create a new adherence record
  Future<String> createAdherenceRecord(
    MedicationAdherenceCompanion adherenceRecord,
  ) async {
    try {
      await _database.into(_database.medicationAdherence).insert(adherenceRecord);
      return adherenceRecord.id.value;
    } catch (e) {
      throw Exception('Failed to create adherence record in database: $e');
    }
  }

  /// Update an adherence record
  Future<bool> updateAdherenceRecord(
    String id,
    MedicationAdherenceCompanion adherenceRecord,
  ) async {
    try {
      final rowsAffected = await (_database.update(_database.medicationAdherence)
            ..where((a) => a.id.equals(id)))
          .write(adherenceRecord);
      return rowsAffected > 0;
    } catch (e) {
      throw Exception('Failed to update adherence record in database: $e');
    }
  }

  /// Delete an adherence record
  Future<bool> deleteAdherenceRecord(String id) async {
    try {
      final rowsAffected = await (_database.delete(_database.medicationAdherence)
            ..where((a) => a.id.equals(id)))
          .go();
      return rowsAffected > 0;
    } catch (e) {
      throw Exception('Failed to delete adherence record from database: $e');
    }
  }

  /// Check if adherence record exists for a reminder and scheduled time
  Future<bool> adherenceRecordExists(
    String reminderId,
    DateTime scheduledTime,
  ) async {
    try {
      final query = _database.select(_database.medicationAdherence)
        ..where(
          (a) =>
              a.reminderId.equals(reminderId) &
              a.scheduledTime.equals(scheduledTime),
        )
        ..limit(1);

      final result = await query.get();
      return result.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check if adherence record exists in database: $e');
    }
  }

  // Analytics and Statistics

  /// Get adherence statistics for a medication over a date range
  Future<AdherenceStatistics> getMedicationAdherenceStats(
    String medicationId, {
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final records = await getAdherenceByMedication(
      medicationId,
      fromDate: fromDate,
      toDate: toDate,
    );

    return _calculateAdherenceStatistics(records);
  }

  /// Get adherence statistics for a profile over a date range
  Future<AdherenceStatistics> getProfileAdherenceStats(
    String profileId, {
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      var query = _database.select(_database.medicationAdherence)
        ..where((a) => a.profileId.equals(profileId));

      if (fromDate != null) {
        query = query..where((a) => a.scheduledTime.isBiggerOrEqualValue(fromDate));
      }

      if (toDate != null) {
        query = query..where((a) => a.scheduledTime.isSmallerOrEqualValue(toDate));
      }

      final records = await query.get();
      return _calculateAdherenceStatistics(records);
    } catch (e) {
      throw Exception('Failed to get profile adherence stats from database: $e');
    }
  }

  /// Get adherence rate for a specific medication
  Future<double> getMedicationAdherenceRate(
    String medicationId, {
    int days = 30,
  }) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));

    final records = await getAdherenceByMedication(
      medicationId,
      fromDate: startDate,
      toDate: endDate,
    );

    if (records.isEmpty) return 0.0;

    final positiveCount = records
        .where((r) => MedicationAdherenceStatus.isPositiveAdherence(r.status))
        .length;

    return positiveCount / records.length;
  }

  /// Get recent missed medications
  Future<List<MedicationAdherenceData>> getRecentMissedMedications({
    String? profileId,
    int days = 7,
  }) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));

    return await getAdherenceByStatus(
      MedicationAdherenceStatus.missed,
      profileId: profileId,
      fromDate: startDate,
      toDate: endDate,
    );
  }

  // Stream Operations

  /// Watch adherence records for a medication
  Stream<List<MedicationAdherenceData>> watchMedicationAdherence(
    String medicationId,
  ) {
    return (_database.select(_database.medicationAdherence)
          ..where((a) => a.medicationId.equals(medicationId))
          ..orderBy([
            (a) => OrderingTerm(
              expression: a.scheduledTime,
              mode: OrderingMode.desc,
            ),
          ]))
        .watch();
  }

  /// Watch today's adherence records
  Stream<List<MedicationAdherenceData>> watchTodaysAdherence({
    String? profileId,
  }) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    var query = _database.select(_database.medicationAdherence)
      ..where(
        (a) =>
            a.scheduledTime.isBiggerOrEqualValue(startOfDay) &
            a.scheduledTime.isSmallerThanValue(endOfDay),
      );

    if (profileId != null) {
      query = query..where((a) => a.profileId.equals(profileId));
    }

    return (query
          ..orderBy([
            (a) => OrderingTerm(expression: a.scheduledTime),
          ]))
        .watch();
  }

  // Private Helper Methods

  AdherenceStatistics _calculateAdherenceStatistics(
    List<MedicationAdherenceData> records,
  ) {
    if (records.isEmpty) {
      return const AdherenceStatistics(
        totalRecords: 0,
        takenCount: 0,
        takenLateCount: 0,
        missedCount: 0,
        skippedCount: 0,
        rescheduledCount: 0,
        adherenceRate: 0.0,
        onTimeRate: 0.0,
      );
    }

    final takenCount = records
        .where((r) => r.status == MedicationAdherenceStatus.taken)
        .length;
    final takenLateCount = records
        .where((r) => r.status == MedicationAdherenceStatus.takenLate)
        .length;
    final missedCount = records
        .where((r) => r.status == MedicationAdherenceStatus.missed)
        .length;
    final skippedCount = records
        .where((r) => r.status == MedicationAdherenceStatus.skipped)
        .length;
    final rescheduledCount = records
        .where((r) => r.status == MedicationAdherenceStatus.rescheduled)
        .length;

    final totalPositive = takenCount + takenLateCount;
    final adherenceRate = totalPositive / records.length;
    final onTimeRate = takenCount / records.length;

    return AdherenceStatistics(
      totalRecords: records.length,
      takenCount: takenCount,
      takenLateCount: takenLateCount,
      missedCount: missedCount,
      skippedCount: skippedCount,
      rescheduledCount: rescheduledCount,
      adherenceRate: adherenceRate,
      onTimeRate: onTimeRate,
    );
  }
}

/// Statistics data class for medication adherence
class AdherenceStatistics {
  final int totalRecords;
  final int takenCount;
  final int takenLateCount;
  final int missedCount;
  final int skippedCount;
  final int rescheduledCount;
  final double adherenceRate;
  final double onTimeRate;

  const AdherenceStatistics({
    required this.totalRecords,
    required this.takenCount,
    required this.takenLateCount,
    required this.missedCount,
    required this.skippedCount,
    required this.rescheduledCount,
    required this.adherenceRate,
    required this.onTimeRate,
  });

  int get positiveAdherenceCount => takenCount + takenLateCount;
  int get negativeAdherenceCount => missedCount + skippedCount;

  double get missedRate => totalRecords > 0 ? missedCount / totalRecords : 0.0;
  double get lateRate => totalRecords > 0 ? takenLateCount / totalRecords : 0.0;
}