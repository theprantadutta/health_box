import 'package:drift/drift.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/medical_record_dao.dart';
import '../../../data/repositories/tag_dao.dart';
import '../../../data/models/medical_record.dart';

class MedicalRecordsService {
  final MedicalRecordDao _medicalRecordDao;

  MedicalRecordsService({
    MedicalRecordDao? medicalRecordDao,
    TagDao? tagDao,
    AppDatabase? database,
  })  : _medicalRecordDao = medicalRecordDao ?? MedicalRecordDao(database ?? AppDatabase.instance);

  // CRUD Operations

  Future<List<MedicalRecord>> getAllRecords() async {
    try {
      return await _medicalRecordDao.getAllRecords();
    } catch (e) {
      throw MedicalRecordsServiceException('Failed to retrieve medical records: ${e.toString()}');
    }
  }

  Future<List<MedicalRecord>> getRecordsByProfileId(String profileId) async {
    try {
      if (profileId.isEmpty) {
        throw const MedicalRecordsServiceException('Profile ID cannot be empty');
      }
      return await _medicalRecordDao.getRecordsByProfileId(profileId);
    } catch (e) {
      if (e is MedicalRecordsServiceException) rethrow;
      throw MedicalRecordsServiceException('Failed to retrieve records for profile: ${e.toString()}');
    }
  }

  Future<List<MedicalRecord>> getRecordsByType(String recordType) async {
    try {
      if (!MedicalRecordType.isValidType(recordType)) {
        throw MedicalRecordsServiceException('Invalid record type: $recordType');
      }
      return await _medicalRecordDao.getRecordsByType(recordType);
    } catch (e) {
      if (e is MedicalRecordsServiceException) rethrow;
      throw MedicalRecordsServiceException('Failed to retrieve records by type: ${e.toString()}');
    }
  }

  Future<MedicalRecord?> getRecordById(String id) async {
    try {
      if (id.isEmpty) {
        throw const MedicalRecordsServiceException('Record ID cannot be empty');
      }
      return await _medicalRecordDao.getRecordById(id);
    } catch (e) {
      if (e is MedicalRecordsServiceException) rethrow;
      throw MedicalRecordsServiceException('Failed to retrieve record: ${e.toString()}');
    }
  }

  Future<String> createRecord(CreateMedicalRecordRequest request) async {
    try {
      _validateCreateRecordRequest(request);
      
      final recordId = 'record_${DateTime.now().millisecondsSinceEpoch}';
      final recordCompanion = MedicalRecordsCompanion(
        id: Value(recordId),
        profileId: Value(request.profileId),
        recordType: Value(request.recordType),
        title: Value(request.title.trim()),
        description: Value(request.description?.trim()),
        recordDate: Value(request.recordDate),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        isActive: const Value(true),
      );

      return await _medicalRecordDao.createRecord(recordCompanion);
    } catch (e) {
      if (e is MedicalRecordsServiceException) rethrow;
      throw MedicalRecordsServiceException('Failed to create medical record: ${e.toString()}');
    }
  }

  Future<bool> updateRecord(String id, UpdateMedicalRecordRequest request) async {
    try {
      if (id.isEmpty) {
        throw const MedicalRecordsServiceException('Record ID cannot be empty');
      }

      final existingRecord = await _medicalRecordDao.getRecordById(id);
      if (existingRecord == null) {
        throw const MedicalRecordsServiceException('Medical record not found');
      }

      _validateUpdateRecordRequest(request);

      final recordCompanion = MedicalRecordsCompanion(
        title: request.title != null ? Value(request.title!.trim()) : const Value.absent(),
        description: request.description != null ? Value(request.description?.trim()) : const Value.absent(),
        recordDate: request.recordDate != null ? Value(request.recordDate!) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      );

      return await _medicalRecordDao.updateRecord(id, recordCompanion);
    } catch (e) {
      if (e is MedicalRecordsServiceException) rethrow;
      throw MedicalRecordsServiceException('Failed to update medical record: ${e.toString()}');
    }
  }

  Future<bool> deleteRecord(String id) async {
    try {
      if (id.isEmpty) {
        throw const MedicalRecordsServiceException('Record ID cannot be empty');
      }

      final existingRecord = await _medicalRecordDao.getRecordById(id);
      if (existingRecord == null) {
        throw const MedicalRecordsServiceException('Medical record not found');
      }

      return await _medicalRecordDao.deleteRecord(id);
    } catch (e) {
      if (e is MedicalRecordsServiceException) rethrow;
      throw MedicalRecordsServiceException('Failed to delete medical record: ${e.toString()}');
    }
  }

  // Search and Filtering Operations

  Future<List<MedicalRecord>> searchRecords({
    String? searchTerm,
    String? profileId,
    String? recordType,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? tags,
    int? limit,
  }) async {
    try {
      List<MedicalRecord> results = [];

      if (searchTerm != null && searchTerm.isNotEmpty) {
        results = await _medicalRecordDao.searchRecords(searchTerm, profileId: profileId);
      } else if (profileId != null && recordType != null) {
        results = await _medicalRecordDao.getRecordsByProfileAndType(profileId, recordType);
      } else if (profileId != null) {
        results = await _medicalRecordDao.getRecordsByProfileId(profileId);
      } else if (recordType != null) {
        results = await _medicalRecordDao.getRecordsByType(recordType);
      } else {
        results = await _medicalRecordDao.getAllRecords();
      }

      // Apply date range filter
      if (startDate != null || endDate != null) {
        results = results.where((record) {
          if (startDate != null && record.recordDate.isBefore(startDate)) {
            return false;
          }
          if (endDate != null && record.recordDate.isAfter(endDate)) {
            return false;
          }
          return true;
        }).toList();
      }

      // Apply limit
      if (limit != null && limit > 0) {
        results = results.take(limit).toList();
      }

      return results;
    } catch (e) {
      if (e is MedicalRecordsServiceException) rethrow;
      throw MedicalRecordsServiceException('Failed to search medical records: ${e.toString()}');
    }
  }

  Future<List<MedicalRecord>> getRecordsInDateRange(
    DateTime startDate,
    DateTime endDate, {
    String? profileId,
  }) async {
    try {
      if (startDate.isAfter(endDate)) {
        throw const MedicalRecordsServiceException('Start date cannot be after end date');
      }
      
      return await _medicalRecordDao.getRecordsInDateRange(startDate, endDate, profileId: profileId);
    } catch (e) {
      if (e is MedicalRecordsServiceException) rethrow;
      throw MedicalRecordsServiceException('Failed to retrieve records in date range: ${e.toString()}');
    }
  }

  Future<List<MedicalRecord>> getRecentRecords({int limit = 10, String? profileId}) async {
    try {
      if (limit <= 0) {
        throw const MedicalRecordsServiceException('Limit must be greater than 0');
      }
      return await _medicalRecordDao.getRecentRecords(limit: limit, profileId: profileId);
    } catch (e) {
      if (e is MedicalRecordsServiceException) rethrow;
      throw MedicalRecordsServiceException('Failed to retrieve recent records: ${e.toString()}');
    }
  }

  // Advanced Filtering

  Future<List<MedicalRecord>> getRecordsByMultipleTypes(List<String> recordTypes, {String? profileId}) async {
    try {
      for (String type in recordTypes) {
        if (!MedicalRecordType.isValidType(type)) {
          throw MedicalRecordsServiceException('Invalid record type: $type');
        }
      }

      List<MedicalRecord> allResults = [];
      
      for (String type in recordTypes) {
        List<MedicalRecord> typeResults;
        if (profileId != null) {
          typeResults = await _medicalRecordDao.getRecordsByProfileAndType(profileId, type);
        } else {
          typeResults = await _medicalRecordDao.getRecordsByType(type);
        }
        allResults.addAll(typeResults);
      }

      // Sort by record date (newest first)
      allResults.sort((a, b) => b.recordDate.compareTo(a.recordDate));
      
      return allResults;
    } catch (e) {
      if (e is MedicalRecordsServiceException) rethrow;
      throw MedicalRecordsServiceException('Failed to retrieve records by multiple types: ${e.toString()}');
    }
  }

  Future<FilteredRecordsResult> getFilteredRecords(MedicalRecordFilter filter) async {
    try {
      List<MedicalRecord> results = await searchRecords(
        searchTerm: filter.searchTerm,
        profileId: filter.profileId,
        recordType: filter.recordType,
        startDate: filter.startDate,
        endDate: filter.endDate,
        limit: filter.limit,
      );

      // Apply additional filters
      if (filter.excludeTypes != null && filter.excludeTypes!.isNotEmpty) {
        results = results.where((record) => !filter.excludeTypes!.contains(record.recordType)).toList();
      }

      return FilteredRecordsResult(
        records: results,
        totalCount: results.length,
        appliedFilters: filter,
      );
    } catch (e) {
      if (e is MedicalRecordsServiceException) rethrow;
      throw MedicalRecordsServiceException('Failed to get filtered records: ${e.toString()}');
    }
  }

  // Statistics and Analytics

  Future<int> getRecordCount({String? profileId}) async {
    try {
      if (profileId != null) {
        return await _medicalRecordDao.getRecordCountByProfile(profileId);
      } else {
        final allRecords = await _medicalRecordDao.getAllRecords();
        return allRecords.length;
      }
    } catch (e) {
      throw MedicalRecordsServiceException('Failed to retrieve record count: ${e.toString()}');
    }
  }

  Future<Map<String, int>> getRecordCountsByType({String? profileId}) async {
    try {
      return await _medicalRecordDao.getRecordCountsByType(profileId: profileId);
    } catch (e) {
      throw MedicalRecordsServiceException('Failed to retrieve record counts by type: ${e.toString()}');
    }
  }

  Future<MedicalRecordsStatistics> getRecordsStatistics({String? profileId}) async {
    try {
      final recordCounts = await getRecordCountsByType(profileId: profileId);
      final totalRecords = recordCounts.values.fold(0, (sum, count) => sum + count);
      final recentRecords = await getRecentRecords(limit: 30, profileId: profileId);
      
      // Calculate records added in the last 30 days
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final recentRecordsCount = recentRecords.where((record) => 
        record.createdAt.isAfter(thirtyDaysAgo)).length;

      return MedicalRecordsStatistics(
        totalRecords: totalRecords,
        recordCountsByType: recordCounts,
        recentRecordsCount: recentRecordsCount,
        mostCommonRecordType: _getMostCommonRecordType(recordCounts),
      );
    } catch (e) {
      throw MedicalRecordsServiceException('Failed to retrieve records statistics: ${e.toString()}');
    }
  }

  // Utility Methods

  Future<bool> recordExists(String id) async {
    try {
      if (id.isEmpty) return false;
      final record = await _medicalRecordDao.getRecordById(id);
      return record != null;
    } catch (e) {
      return false;
    }
  }

  List<String> getValidRecordTypes() {
    return MedicalRecordType.allTypes;
  }

  String getRecordTypeDisplayName(String recordType) {
    switch (recordType) {
      case MedicalRecordType.prescription:
        return 'Prescription';
      case MedicalRecordType.labReport:
        return 'Lab Report';
      case MedicalRecordType.medication:
        return 'Medication';
      case MedicalRecordType.vaccination:
        return 'Vaccination';
      case MedicalRecordType.allergy:
        return 'Allergy';
      case MedicalRecordType.chronicCondition:
        return 'Chronic Condition';
      default:
        return recordType;
    }
  }

  // Stream Operations

  Stream<List<MedicalRecord>> watchRecordsByProfile(String profileId) {
    return _medicalRecordDao.watchRecordsByProfile(profileId);
  }

  Stream<List<MedicalRecord>> watchRecordsByType(String recordType) {
    return _medicalRecordDao.watchRecordsByType(recordType);
  }

  Stream<MedicalRecord?> watchRecord(String id) {
    return _medicalRecordDao.watchRecord(id);
  }

  // Private Helper Methods

  void _validateCreateRecordRequest(CreateMedicalRecordRequest request) {
    if (request.profileId.isEmpty) {
      throw const MedicalRecordsServiceException('Profile ID cannot be empty');
    }
    if (request.title.trim().isEmpty) {
      throw const MedicalRecordsServiceException('Title cannot be empty');
    }
    if (request.title.length > 200) {
      throw const MedicalRecordsServiceException('Title cannot exceed 200 characters');
    }
    if (!MedicalRecordType.isValidType(request.recordType)) {
      throw MedicalRecordsServiceException('Invalid record type: ${request.recordType}');
    }
    if (request.recordDate.isAfter(DateTime.now()) && 
        request.recordType != MedicalRecordType.vaccination) {
      throw const MedicalRecordsServiceException('Record date cannot be in the future (except for vaccinations)');
    }
  }

  void _validateUpdateRecordRequest(UpdateMedicalRecordRequest request) {
    if (request.title != null && request.title!.trim().isEmpty) {
      throw const MedicalRecordsServiceException('Title cannot be empty');
    }
    if (request.title != null && request.title!.length > 200) {
      throw const MedicalRecordsServiceException('Title cannot exceed 200 characters');
    }
    if (request.recordDate != null && request.recordDate!.isAfter(DateTime.now())) {
      throw const MedicalRecordsServiceException('Record date cannot be in the future');
    }
  }

  String? _getMostCommonRecordType(Map<String, int> recordCounts) {
    if (recordCounts.isEmpty) return null;
    
    String? mostCommon;
    int maxCount = 0;
    
    recordCounts.forEach((type, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCommon = type;
      }
    });
    
    return mostCommon;
  }
}

// Data Transfer Objects

class CreateMedicalRecordRequest {
  final String profileId;
  final String recordType;
  final String title;
  final String? description;
  final DateTime recordDate;

  const CreateMedicalRecordRequest({
    required this.profileId,
    required this.recordType,
    required this.title,
    this.description,
    required this.recordDate,
  });
}

class UpdateMedicalRecordRequest {
  final String? title;
  final String? description;
  final DateTime? recordDate;

  const UpdateMedicalRecordRequest({
    this.title,
    this.description,
    this.recordDate,
  });
}

class MedicalRecordFilter {
  final String? searchTerm;
  final String? profileId;
  final String? recordType;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? excludeTypes;
  final int? limit;

  const MedicalRecordFilter({
    this.searchTerm,
    this.profileId,
    this.recordType,
    this.startDate,
    this.endDate,
    this.excludeTypes,
    this.limit,
  });
}

class FilteredRecordsResult {
  final List<MedicalRecord> records;
  final int totalCount;
  final MedicalRecordFilter appliedFilters;

  const FilteredRecordsResult({
    required this.records,
    required this.totalCount,
    required this.appliedFilters,
  });
}

class MedicalRecordsStatistics {
  final int totalRecords;
  final Map<String, int> recordCountsByType;
  final int recentRecordsCount;
  final String? mostCommonRecordType;

  const MedicalRecordsStatistics({
    required this.totalRecords,
    required this.recordCountsByType,
    required this.recentRecordsCount,
    this.mostCommonRecordType,
  });
}

// Exceptions

class MedicalRecordsServiceException implements Exception {
  final String message;
  
  const MedicalRecordsServiceException(this.message);
  
  @override
  String toString() => 'MedicalRecordsServiceException: $message';
}