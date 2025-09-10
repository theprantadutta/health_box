import 'package:drift/drift.dart';
import '../../../data/database/app_database.dart';

class LabReportService {
  final AppDatabase _database;

  LabReportService({AppDatabase? database}) 
      : _database = database ?? AppDatabase.instance;

  // CRUD Operations

  Future<List<LabReport>> getAllLabReports({String? profileId}) async {
    try {
      var query = _database.select(_database.labReports)
        ..where((lr) => lr.isActive.equals(true));

      if (profileId != null) {
        query = query..where((lr) => lr.profileId.equals(profileId));
      }

      query = query..orderBy([
        (lr) => OrderingTerm(expression: lr.recordDate, mode: OrderingMode.desc),
      ]);

      return await query.get();
    } catch (e) {
      throw LabReportServiceException('Failed to retrieve lab reports: ${e.toString()}');
    }
  }

  Future<LabReport?> getLabReportById(String id) async {
    try {
      if (id.isEmpty) {
        throw const LabReportServiceException('Lab report ID cannot be empty');
      }
      
      return await (_database.select(_database.labReports)
            ..where((lr) => lr.id.equals(id) & lr.isActive.equals(true)))
          .getSingleOrNull();
    } catch (e) {
      if (e is LabReportServiceException) rethrow;
      throw LabReportServiceException('Failed to retrieve lab report: ${e.toString()}');
    }
  }

  Future<String> createLabReport(CreateLabReportRequest request) async {
    try {
      _validateCreateLabReportRequest(request);
      
      final labReportId = 'lab_report_${DateTime.now().millisecondsSinceEpoch}';
      final labReportCompanion = LabReportsCompanion(
        id: Value(labReportId),
        profileId: Value(request.profileId),
        recordType: const Value('lab_report'),
        title: Value(request.title.trim()),
        description: Value(request.description?.trim()),
        recordDate: Value(request.recordDate),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        isActive: const Value(true),
        // Lab report-specific fields
        testName: Value(request.testName.trim()),
        testResults: Value(request.testResults?.trim()),
        referenceRange: Value(request.referenceRange?.trim()),
        orderingPhysician: Value(request.orderingPhysician?.trim()),
        labFacility: Value(request.labFacility?.trim()),
        testStatus: Value(request.testStatus),
        collectionDate: Value(request.collectionDate),
        isCritical: Value(request.isCritical),
      );

      await _database.into(_database.labReports).insert(labReportCompanion);
      return labReportId;
    } catch (e) {
      if (e is LabReportServiceException) rethrow;
      throw LabReportServiceException('Failed to create lab report: ${e.toString()}');
    }
  }

  Future<bool> updateLabReport(String id, UpdateLabReportRequest request) async {
    try {
      if (id.isEmpty) {
        throw const LabReportServiceException('Lab report ID cannot be empty');
      }

      final existingLabReport = await getLabReportById(id);
      if (existingLabReport == null) {
        throw const LabReportServiceException('Lab report not found');
      }

      _validateUpdateLabReportRequest(request);

      final labReportCompanion = LabReportsCompanion(
        title: request.title != null ? Value(request.title!.trim()) : const Value.absent(),
        description: request.description != null ? Value(request.description?.trim()) : const Value.absent(),
        recordDate: request.recordDate != null ? Value(request.recordDate!) : const Value.absent(),
        testName: request.testName != null ? Value(request.testName!.trim()) : const Value.absent(),
        testResults: request.testResults != null ? Value(request.testResults?.trim()) : const Value.absent(),
        referenceRange: request.referenceRange != null ? Value(request.referenceRange?.trim()) : const Value.absent(),
        orderingPhysician: request.orderingPhysician != null ? Value(request.orderingPhysician?.trim()) : const Value.absent(),
        labFacility: request.labFacility != null ? Value(request.labFacility?.trim()) : const Value.absent(),
        testStatus: request.testStatus != null ? Value(request.testStatus!) : const Value.absent(),
        collectionDate: request.collectionDate != null ? Value(request.collectionDate!) : const Value.absent(),
        isCritical: request.isCritical != null ? Value(request.isCritical!) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      );

      final rowsAffected = await (_database.update(_database.labReports)
            ..where((lr) => lr.id.equals(id)))
          .write(labReportCompanion);

      return rowsAffected > 0;
    } catch (e) {
      if (e is LabReportServiceException) rethrow;
      throw LabReportServiceException('Failed to update lab report: ${e.toString()}');
    }
  }

  Future<bool> deleteLabReport(String id) async {
    try {
      if (id.isEmpty) {
        throw const LabReportServiceException('Lab report ID cannot be empty');
      }

      final existingLabReport = await getLabReportById(id);
      if (existingLabReport == null) {
        throw const LabReportServiceException('Lab report not found');
      }

      final rowsAffected = await (_database.update(_database.labReports)
            ..where((lr) => lr.id.equals(id)))
          .write(LabReportsCompanion(
            isActive: const Value(false),
            updatedAt: Value(DateTime.now()),
          ));

      return rowsAffected > 0;
    } catch (e) {
      if (e is LabReportServiceException) rethrow;
      throw LabReportServiceException('Failed to delete lab report: ${e.toString()}');
    }
  }

  // Query Operations

  Future<List<LabReport>> getLabReportsByTestName(String testName, {String? profileId}) async {
    try {
      if (testName.isEmpty) {
        throw const LabReportServiceException('Test name cannot be empty');
      }

      var query = _database.select(_database.labReports)
        ..where((lr) => 
            lr.isActive.equals(true) & 
            lr.testName.lower().like('%${testName.toLowerCase()}%'));

      if (profileId != null) {
        query = query..where((lr) => lr.profileId.equals(profileId));
      }

      query = query..orderBy([
        (lr) => OrderingTerm(expression: lr.recordDate, mode: OrderingMode.desc),
      ]);

      return await query.get();
    } catch (e) {
      if (e is LabReportServiceException) rethrow;
      throw LabReportServiceException('Failed to retrieve lab reports by test name: ${e.toString()}');
    }
  }

  Future<List<LabReport>> getCriticalLabReports({String? profileId}) async {
    try {
      var query = _database.select(_database.labReports)
        ..where((lr) => 
            lr.isActive.equals(true) & 
            lr.isCritical.equals(true));

      if (profileId != null) {
        query = query..where((lr) => lr.profileId.equals(profileId));
      }

      query = query..orderBy([
        (lr) => OrderingTerm(expression: lr.recordDate, mode: OrderingMode.desc),
      ]);

      return await query.get();
    } catch (e) {
      throw LabReportServiceException('Failed to retrieve critical lab reports: ${e.toString()}');
    }
  }

  Future<List<LabReport>> getPendingLabReports({String? profileId}) async {
    try {
      var query = _database.select(_database.labReports)
        ..where((lr) => 
            lr.isActive.equals(true) & 
            lr.testStatus.equals('pending'));

      if (profileId != null) {
        query = query..where((lr) => lr.profileId.equals(profileId));
      }

      query = query..orderBy([
        (lr) => OrderingTerm(expression: lr.collectionDate, mode: OrderingMode.desc),
      ]);

      return await query.get();
    } catch (e) {
      throw LabReportServiceException('Failed to retrieve pending lab reports: ${e.toString()}');
    }
  }

  Future<Map<String, int>> getLabReportCountsByStatus({String? profileId}) async {
    try {
      final Map<String, int> counts = {
        'pending': 0,
        'completed': 0,
        'cancelled': 0,
      };

      for (final status in counts.keys) {
        var query = _database.selectOnly(_database.labReports)
          ..addColumns([_database.labReports.id.count()])
          ..where(_database.labReports.isActive.equals(true) & 
                  _database.labReports.testStatus.equals(status));

        if (profileId != null) {
          query = query..where(_database.labReports.profileId.equals(profileId));
        }

        final result = await query.getSingle();
        counts[status] = result.read(_database.labReports.id.count()) ?? 0;
      }

      return counts;
    } catch (e) {
      throw LabReportServiceException('Failed to retrieve lab report counts by status: ${e.toString()}');
    }
  }

  // Utility Methods

  Future<bool> labReportExists(String id) async {
    try {
      if (id.isEmpty) return false;
      final labReport = await getLabReportById(id);
      return labReport != null;
    } catch (e) {
      return false;
    }
  }

  bool isCritical(LabReport labReport) {
    return labReport.isCritical;
  }

  bool isPending(LabReport labReport) {
    return labReport.testStatus == 'pending';
  }

  List<String> getValidStatuses() {
    return ['pending', 'completed', 'cancelled'];
  }

  // Validation Methods

  void _validateCreateLabReportRequest(CreateLabReportRequest request) {
    if (request.profileId.isEmpty) {
      throw const LabReportServiceException('Profile ID cannot be empty');
    }
    if (request.title.trim().isEmpty) {
      throw const LabReportServiceException('Title cannot be empty');
    }
    if (request.testName.trim().isEmpty) {
      throw const LabReportServiceException('Test name cannot be empty');
    }
    if (!_isValidStatus(request.testStatus)) {
      throw LabReportServiceException('Invalid status: ${request.testStatus}');
    }
    if (request.collectionDate != null && 
        request.collectionDate!.isAfter(DateTime.now())) {
      throw const LabReportServiceException('Collection date cannot be in the future');
    }
  }

  void _validateUpdateLabReportRequest(UpdateLabReportRequest request) {
    if (request.title != null && request.title!.trim().isEmpty) {
      throw const LabReportServiceException('Title cannot be empty');
    }
    if (request.testName != null && request.testName!.trim().isEmpty) {
      throw const LabReportServiceException('Test name cannot be empty');
    }
    if (request.testStatus != null && !_isValidStatus(request.testStatus!)) {
      throw LabReportServiceException('Invalid status: ${request.testStatus}');
    }
    if (request.collectionDate != null && 
        request.collectionDate!.isAfter(DateTime.now())) {
      throw const LabReportServiceException('Collection date cannot be in the future');
    }
  }

  bool _isValidStatus(String status) {
    return ['pending', 'completed', 'cancelled'].contains(status);
  }
}

// Data Transfer Objects

class CreateLabReportRequest {
  final String profileId;
  final String title;
  final String? description;
  final DateTime recordDate;
  final String testName;
  final String? testResults;
  final String? referenceRange;
  final String? orderingPhysician;
  final String? labFacility;
  final String testStatus;
  final DateTime? collectionDate;
  final bool isCritical;

  const CreateLabReportRequest({
    required this.profileId,
    required this.title,
    this.description,
    required this.recordDate,
    required this.testName,
    this.testResults,
    this.referenceRange,
    this.orderingPhysician,
    this.labFacility,
    this.testStatus = 'pending',
    this.collectionDate,
    this.isCritical = false,
  });
}

class UpdateLabReportRequest {
  final String? title;
  final String? description;
  final DateTime? recordDate;
  final String? testName;
  final String? testResults;
  final String? referenceRange;
  final String? orderingPhysician;
  final String? labFacility;
  final String? testStatus;
  final DateTime? collectionDate;
  final bool? isCritical;

  const UpdateLabReportRequest({
    this.title,
    this.description,
    this.recordDate,
    this.testName,
    this.testResults,
    this.referenceRange,
    this.orderingPhysician,
    this.labFacility,
    this.testStatus,
    this.collectionDate,
    this.isCritical,
  });
}

// Exceptions

class LabReportServiceException implements Exception {
  final String message;
  
  const LabReportServiceException(this.message);
  
  @override
  String toString() => 'LabReportServiceException: $message';
}