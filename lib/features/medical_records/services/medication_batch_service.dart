import 'dart:convert';
import 'dart:developer' as developer;

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../data/database/app_database.dart';
import '../../../data/models/medication.dart';
import '../../../data/models/medication_batch.dart';

class MedicationBatchService {
  static final MedicationBatchService _instance = MedicationBatchService._internal();
  factory MedicationBatchService() => _instance;
  MedicationBatchService._internal();

  final AppDatabase _database = AppDatabase.instance;
  final Uuid _uuid = const Uuid();

  /// Create a new medication batch
  Future<MedicationBatche> createBatch({
    required String name,
    required String timingType,
    Map<String, dynamic>? timingDetails,
    String? description,
  }) async {
    try {
      if (!MedicationBatchTimingType.isValidType(timingType)) {
        throw MedicationBatchServiceException('Invalid timing type: $timingType');
      }

      final id = _uuid.v4();
      final now = DateTime.now();

      final batch = MedicationBatchesCompanion(
        id: Value(id),
        name: Value(name.trim()),
        timingType: Value(timingType),
        timingDetails: Value(timingDetails != null ? jsonEncode(timingDetails) : null),
        description: Value(description?.trim()),
        isActive: const Value(true),
        createdAt: Value(now),
        updatedAt: Value(now),
      );

      await _database.into(_database.medicationBatches).insert(batch);

      final createdBatch = await getBatchById(id);
      if (createdBatch == null) {
        throw const MedicationBatchServiceException('Failed to retrieve created batch');
      }

      developer.log('Created medication batch: $name (ID: $id)', name: 'MedicationBatchService');
      return createdBatch;
    } catch (e) {
      developer.log('Failed to create medication batch: $e', name: 'MedicationBatchService');
      throw MedicationBatchServiceException('Failed to create medication batch: $e');
    }
  }

  /// Get a medication batch by ID
  Future<MedicationBatche?> getBatchById(String id) async {
    try {
      final batch = await (_database.select(_database.medicationBatches)
            ..where((tbl) => tbl.id.equals(id)))
          .getSingleOrNull();
      return batch;
    } catch (e) {
      developer.log('Failed to get batch by ID $id: $e', name: 'MedicationBatchService');
      throw MedicationBatchServiceException('Failed to get batch: $e');
    }
  }

  /// Get all active medication batches
  Future<List<MedicationBatche>> getActiveBatches() async {
    try {
      final batches = await (_database.select(_database.medicationBatches)
            ..where((tbl) => tbl.isActive.equals(true))
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
          .get();
      return batches;
    } catch (e) {
      developer.log('Failed to get active batches: $e', name: 'MedicationBatchService');
      throw MedicationBatchServiceException('Failed to get active batches: $e');
    }
  }

  /// Get all batches (active and inactive)
  Future<List<MedicationBatche>> getAllBatches() async {
    try {
      final batches = await (_database.select(_database.medicationBatches)
            ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
          .get();
      return batches;
    } catch (e) {
      developer.log('Failed to get all batches: $e', name: 'MedicationBatchService');
      throw MedicationBatchServiceException('Failed to get all batches: $e');
    }
  }

  /// Update a medication batch
  Future<MedicationBatche> updateBatch({
    required String id,
    String? name,
    String? timingType,
    Map<String, dynamic>? timingDetails,
    String? description,
    bool? isActive,
  }) async {
    try {
      final existingBatch = await getBatchById(id);
      if (existingBatch == null) {
        throw const MedicationBatchServiceException('Batch not found');
      }

      if (timingType != null && !MedicationBatchTimingType.isValidType(timingType)) {
        throw MedicationBatchServiceException('Invalid timing type: $timingType');
      }

      final update = MedicationBatchesCompanion(
        name: name != null ? Value(name.trim()) : const Value.absent(),
        timingType: timingType != null ? Value(timingType) : const Value.absent(),
        timingDetails: timingDetails != null
            ? Value(jsonEncode(timingDetails))
            : const Value.absent(),
        description: description != null
            ? Value(description.trim())
            : const Value.absent(),
        isActive: isActive != null ? Value(isActive) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      );

      final rowsUpdated = await (_database.update(_database.medicationBatches)
            ..where((tbl) => tbl.id.equals(id)))
          .write(update);

      if (rowsUpdated == 0) {
        throw const MedicationBatchServiceException('No rows updated');
      }

      final updatedBatch = await getBatchById(id);
      if (updatedBatch == null) {
        throw const MedicationBatchServiceException('Failed to retrieve updated batch');
      }

      developer.log('Updated medication batch: $id', name: 'MedicationBatchService');
      return updatedBatch;
    } catch (e) {
      developer.log('Failed to update batch $id: $e', name: 'MedicationBatchService');
      throw MedicationBatchServiceException('Failed to update batch: $e');
    }
  }

  /// Delete a medication batch (soft delete by marking inactive)
  Future<void> deleteBatch(String id) async {
    try {
      // Check if batch has medications
      final medicationCount = await (_database.selectOnly(_database.medications)
            ..addColumns([_database.medications.id.count()])
            ..where(_database.medications.batchId.equals(id)))
          .getSingle()
          .then((row) => row.read(_database.medications.id.count()) ?? 0);

      if (medicationCount > 0) {
        throw MedicationBatchServiceException(
          'Cannot delete batch with $medicationCount medications. Please move medications to another batch first.',
        );
      }

      final rowsUpdated = await (_database.update(_database.medicationBatches)
            ..where((tbl) => tbl.id.equals(id)))
          .write(const MedicationBatchesCompanion(
            isActive: Value(false),
            updatedAt: Value.absent(),
          ));

      if (rowsUpdated == 0) {
        throw const MedicationBatchServiceException('Batch not found');
      }

      developer.log('Deleted medication batch: $id', name: 'MedicationBatchService');
    } catch (e) {
      developer.log('Failed to delete batch $id: $e', name: 'MedicationBatchService');
      throw MedicationBatchServiceException('Failed to delete batch: $e');
    }
  }

  /// Hard delete a medication batch (permanently removes from database)
  Future<void> hardDeleteBatch(String id) async {
    try {
      // Check if batch has medications
      final medicationCount = await (_database.selectOnly(_database.medications)
            ..addColumns([_database.medications.id.count()])
            ..where(_database.medications.batchId.equals(id)))
          .getSingle()
          .then((row) => row.read(_database.medications.id.count()) ?? 0);

      if (medicationCount > 0) {
        throw MedicationBatchServiceException(
          'Cannot delete batch with $medicationCount medications. Please move medications to another batch first.',
        );
      }

      final rowsDeleted = await (_database.delete(_database.medicationBatches)
            ..where((tbl) => tbl.id.equals(id)))
          .go();

      if (rowsDeleted == 0) {
        throw const MedicationBatchServiceException('Batch not found');
      }

      developer.log('Hard deleted medication batch: $id', name: 'MedicationBatchService');
    } catch (e) {
      developer.log('Failed to hard delete batch $id: $e', name: 'MedicationBatchService');
      throw MedicationBatchServiceException('Failed to hard delete batch: $e');
    }
  }

  /// Get medications in a specific batch
  Future<List<Medication>> getMedicationsInBatch(String batchId) async {
    try {
      final medications = await (_database.select(_database.medications)
            ..where((tbl) => tbl.batchId.equals(batchId))
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.medicationName)]))
          .get();
      return medications;
    } catch (e) {
      developer.log('Failed to get medications in batch $batchId: $e', name: 'MedicationBatchService');
      throw MedicationBatchServiceException('Failed to get medications in batch: $e');
    }
  }

  /// Move medication to a different batch
  Future<void> moveMedicationToBatch(String medicationId, String? newBatchId) async {
    try {
      if (newBatchId != null) {
        final batch = await getBatchById(newBatchId);
        if (batch == null) {
          throw const MedicationBatchServiceException('Target batch not found');
        }
      }

      final rowsUpdated = await (_database.update(_database.medications)
            ..where((tbl) => tbl.id.equals(medicationId)))
          .write(MedicationsCompanion(
            batchId: Value(newBatchId),
            updatedAt: Value(DateTime.now()),
          ));

      if (rowsUpdated == 0) {
        throw const MedicationBatchServiceException('Medication not found');
      }

      developer.log('Moved medication $medicationId to batch $newBatchId', name: 'MedicationBatchService');
    } catch (e) {
      developer.log('Failed to move medication $medicationId: $e', name: 'MedicationBatchService');
      throw MedicationBatchServiceException('Failed to move medication: $e');
    }
  }

  /// Get batch statistics
  Future<BatchStatistics> getBatchStatistics(String batchId) async {
    try {
      final medicationCount = await (_database.selectOnly(_database.medications)
            ..addColumns([_database.medications.id.count()])
            ..where(_database.medications.batchId.equals(batchId)))
          .getSingle()
          .then((row) => row.read(_database.medications.id.count()) ?? 0);

      final activeMedicationCount = await (_database.selectOnly(_database.medications)
            ..addColumns([_database.medications.id.count()])
            ..where(_database.medications.batchId.equals(batchId) &
                   _database.medications.status.equals(MedicationStatus.active)))
          .getSingle()
          .then((row) => row.read(_database.medications.id.count()) ?? 0);

      return BatchStatistics(
        totalMedications: medicationCount,
        activeMedications: activeMedicationCount,
        inactiveMedications: medicationCount - activeMedicationCount,
      );
    } catch (e) {
      developer.log('Failed to get batch statistics for $batchId: $e', name: 'MedicationBatchService');
      throw MedicationBatchServiceException('Failed to get batch statistics: $e');
    }
  }

  /// Parse timing details based on timing type
  Map<String, dynamic>? parseTimingDetails(String timingType, String? timingDetailsJson) {
    if (timingDetailsJson == null) return null;

    try {
      return jsonDecode(timingDetailsJson) as Map<String, dynamic>;
    } catch (e) {
      developer.log('Failed to parse timing details: $e', name: 'MedicationBatchService');
      return null;
    }
  }

  /// Create default medication batches for new users
  Future<void> createDefaultBatches() async {
    try {
      final existingBatches = await getActiveBatches();
      if (existingBatches.isNotEmpty) {
        developer.log('Default batches already exist, skipping creation', name: 'MedicationBatchService');
        return;
      }

      // Create morning batch
      await createBatch(
        name: 'Morning Medications',
        timingType: MedicationBatchTimingType.afterMeal,
        timingDetails: MealTimingDetails(
          mealType: MealType.breakfast,
          minutesAfterBefore: 30,
        ).toJson(),
        description: 'Medications to be taken 30 minutes after breakfast',
      );

      // Create evening batch
      await createBatch(
        name: 'Evening Medications',
        timingType: MedicationBatchTimingType.afterMeal,
        timingDetails: MealTimingDetails(
          mealType: MealType.dinner,
          minutesAfterBefore: 30,
        ).toJson(),
        description: 'Medications to be taken 30 minutes after dinner',
      );

      // Create as-needed batch
      await createBatch(
        name: 'As Needed',
        timingType: MedicationBatchTimingType.asNeeded,
        description: 'Medications to be taken as needed',
      );

      developer.log('Created default medication batches', name: 'MedicationBatchService');
    } catch (e) {
      developer.log('Failed to create default batches: $e', name: 'MedicationBatchService');
      // Don't throw here as this is not critical
    }
  }
}

/// Statistics for a medication batch
class BatchStatistics {
  final int totalMedications;
  final int activeMedications;
  final int inactiveMedications;

  const BatchStatistics({
    required this.totalMedications,
    required this.activeMedications,
    required this.inactiveMedications,
  });
}

/// Exception thrown by MedicationBatchService
class MedicationBatchServiceException implements Exception {
  final String message;

  const MedicationBatchServiceException(this.message);

  @override
  String toString() => 'MedicationBatchServiceException: $message';
}