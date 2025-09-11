import 'package:drift/drift.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/profile_dao.dart';
import 'tag_service.dart';

class SearchService {
  final AppDatabase _database;
  final ProfileDao _profileDao;
  final TagService _tagService;

  SearchService({
    AppDatabase? database,
    ProfileDao? profileDao,
    TagService? tagService,
  })  : _database = database ?? AppDatabase.instance,
        _profileDao = profileDao ?? ProfileDao(database ?? AppDatabase.instance),
        _tagService = tagService ?? TagService();

  // Full-text search across all entities
  Future<SearchResults> searchAll({
    required String query,
    String? profileId,
    List<String>? recordTypes,
    List<String>? tagIds,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    if (query.trim().isEmpty) {
      return SearchResults.empty();
    }

    final results = await Future.wait([
      searchProfiles(query: query, limit: limit ~/ 4),
      searchMedicalRecords(
        query: query,
        profileId: profileId,
        recordTypes: recordTypes,
        tagIds: tagIds,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      ),
      searchTags(query: query, limit: limit ~/ 4),
    ]);

    return SearchResults(
      profiles: results[0] as List<FamilyMemberProfile>,
      medicalRecords: results[1] as List<MedicalRecord>,
      tags: results[2] as List<Tag>,
      query: query,
      totalResults: (results[0] as List).length + 
                   (results[1] as List).length + 
                   (results[2] as List).length,
    );
  }

  // Search profiles by name, notes, emergency contact, etc.
  Future<List<FamilyMemberProfile>> searchProfiles({
    required String query,
    int limit = 20,
  }) async {
    try {
      return await _profileDao.getProfilesByName(query);
    } catch (e) {
      throw SearchServiceException('Failed to search profiles: ${e.toString()}');
    }
  }

  // Search medical records with advanced filtering
  Future<List<MedicalRecord>> searchMedicalRecords({
    required String query,
    String? profileId,
    List<String>? recordTypes,
    List<String>? tagIds,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    try {
      final searchPattern = '%${query.toLowerCase()}%';
      
      var selectQuery = _database.select(_database.medicalRecords)
        ..where((record) =>
            record.title.lower().like(searchPattern) |
            record.description.lower().like(searchPattern));

      // Filter by profile
      if (profileId != null) {
        selectQuery = selectQuery
          ..where((record) => record.profileId.equals(profileId));
      }

      // Filter by record types
      if (recordTypes != null && recordTypes.isNotEmpty) {
        selectQuery = selectQuery
          ..where((record) => record.recordType.isIn(recordTypes));
      }

      // Filter by date range
      if (startDate != null) {
        selectQuery = selectQuery
          ..where((record) => record.recordDate.isBiggerOrEqualValue(startDate));
      }
      if (endDate != null) {
        selectQuery = selectQuery
          ..where((record) => record.recordDate.isSmallerOrEqualValue(endDate));
      }

      selectQuery = selectQuery
        ..orderBy([
          (record) => OrderingTerm(expression: record.recordDate, mode: OrderingMode.desc),
        ])
        ..limit(limit);

      var results = await selectQuery.get();

      // TODO: Filter by tags when recordTags table is implemented

      return results;
    } catch (e) {
      throw SearchServiceException('Failed to search medical records: ${e.toString()}');
    }
  }

  // Search tags
  Future<List<Tag>> searchTags({
    required String query,
    String? category,
    int limit = 20,
  }) async {
    try {
      return await _tagService.searchTags(query);
    } catch (e) {
      throw SearchServiceException('Failed to search tags: ${e.toString()}');
    }
  }

  // Advanced search with multiple criteria
  Future<List<MedicalRecord>> advancedSearch({
    String? textQuery,
    String? profileId,
    List<String>? recordTypes,
    List<String>? tagIds,
    DateTime? startDate,
    DateTime? endDate,
    String? severity,
    bool? hasAttachments,
    bool? hasReminders,
    int limit = 50,
  }) async {
    try {
      var selectQuery = _database.select(_database.medicalRecords);

      // Text search
      if (textQuery != null && textQuery.trim().isNotEmpty) {
        final searchPattern = '%${textQuery.toLowerCase()}%';
        selectQuery = selectQuery
          ..where((record) => 
              record.title.lower().like(searchPattern) |
              record.description.lower().like(searchPattern));
      }

      // Profile filter
      if (profileId != null) {
        selectQuery = selectQuery
          ..where((record) => record.profileId.equals(profileId));
      }

      // Record type filter
      if (recordTypes != null && recordTypes.isNotEmpty) {
        selectQuery = selectQuery
          ..where((record) => record.recordType.isIn(recordTypes));
      }

      // Date range filter
      if (startDate != null) {
        selectQuery = selectQuery
          ..where((record) => record.recordDate.isBiggerOrEqualValue(startDate));
      }
      if (endDate != null) {
        selectQuery = selectQuery
          ..where((record) => record.recordDate.isSmallerOrEqualValue(endDate));
      }

      // Remove severity filter as MedicalRecord doesn't have this field

      selectQuery = selectQuery
        ..orderBy([
          (record) => OrderingTerm(expression: record.recordDate, mode: OrderingMode.desc),
        ])
        ..limit(limit);

      return await selectQuery.get();
    } catch (e) {
      throw SearchServiceException('Failed to perform advanced search: ${e.toString()}');
    }
  }

  // Get search suggestions based on query
  Future<SearchSuggestions> getSearchSuggestions(String query) async {
    if (query.trim().isEmpty) {
      return SearchSuggestions.empty();
    }

    try {
      final results = await Future.wait([
        _getProfileSuggestions(query),
        _getRecordTypeSuggestions(query),
        _getTagSuggestions(query),
        _getRecentSearches(),
      ]);

      return SearchSuggestions(
        profiles: results[0],
        recordTypes: results[1],
        tags: results[2],
        recentSearches: results[3],
      );
    } catch (e) {
      throw SearchServiceException('Failed to get search suggestions: ${e.toString()}');
    }
  }

  // Save search query for future suggestions
  Future<void> saveSearchQuery(String query) async {
    // TODO: Implement when searchHistory table is added
    return;
  }

  // Get popular searches
  Future<List<String>> getPopularSearches({int limit = 10}) async {
    // TODO: Implement when searchHistory table is added
    return [];
  }

  // Clear search history
  Future<void> clearSearchHistory() async {
    // TODO: Implement when searchHistory table is added
    return;
  }

  // Private helper methods


  Future<List<String>> _getProfileSuggestions(String query) async {
    try {
      final profiles = await _profileDao.getProfilesByName(query);
      return profiles.map((profile) => '${profile.firstName} ${profile.lastName}').toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> _getRecordTypeSuggestions(String query) async {
    try {
      final recordTypes = ['prescription', 'lab_report', 'appointment', 'vaccination', 'surgery'];
      
      return recordTypes
          .where((type) => type.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> _getTagSuggestions(String query) async {
    try {
      final tags = await _tagService.searchTags(query);
      return tags.take(5).map((tag) => tag.name).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> _getRecentSearches() async {
    // TODO: Implement when searchHistory table is added
    return [];
  }

}

// Data Transfer Objects

class SearchResults {
  final List<FamilyMemberProfile> profiles;
  final List<MedicalRecord> medicalRecords;
  final List<Tag> tags;
  final String query;
  final int totalResults;

  const SearchResults({
    required this.profiles,
    required this.medicalRecords,
    required this.tags,
    required this.query,
    required this.totalResults,
  });

  factory SearchResults.empty() {
    return const SearchResults(
      profiles: [],
      medicalRecords: [],
      tags: [],
      query: '',
      totalResults: 0,
    );
  }

  bool get isEmpty => totalResults == 0;
  bool get isNotEmpty => totalResults > 0;
}

class SearchSuggestions {
  final List<String> profiles;
  final List<String> recordTypes;
  final List<String> tags;
  final List<String> recentSearches;

  const SearchSuggestions({
    required this.profiles,
    required this.recordTypes,
    required this.tags,
    required this.recentSearches,
  });

  factory SearchSuggestions.empty() {
    return const SearchSuggestions(
      profiles: [],
      recordTypes: [],
      tags: [],
      recentSearches: [],
    );
  }

  List<String> get allSuggestions {
    return [
      ...profiles,
      ...recordTypes,
      ...tags,
      ...recentSearches,
    ];
  }
}

class SearchFilter {
  final String? profileId;
  final List<String>? recordTypes;
  final List<String>? tagIds;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? severity;
  final bool? hasAttachments;
  final bool? hasReminders;

  const SearchFilter({
    this.profileId,
    this.recordTypes,
    this.tagIds,
    this.startDate,
    this.endDate,
    this.severity,
    this.hasAttachments,
    this.hasReminders,
  });

  SearchFilter copyWith({
    String? profileId,
    List<String>? recordTypes,
    List<String>? tagIds,
    DateTime? startDate,
    DateTime? endDate,
    String? severity,
    bool? hasAttachments,
    bool? hasReminders,
  }) {
    return SearchFilter(
      profileId: profileId ?? this.profileId,
      recordTypes: recordTypes ?? this.recordTypes,
      tagIds: tagIds ?? this.tagIds,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      severity: severity ?? this.severity,
      hasAttachments: hasAttachments ?? this.hasAttachments,
      hasReminders: hasReminders ?? this.hasReminders,
    );
  }

  bool get hasActiveFilters {
    return profileId != null ||
           (recordTypes?.isNotEmpty ?? false) ||
           (tagIds?.isNotEmpty ?? false) ||
           startDate != null ||
           endDate != null ||
           severity != null ||
           hasAttachments != null ||
           hasReminders != null;
  }
}

// Exception

class SearchServiceException implements Exception {
  final String message;
  
  const SearchServiceException(this.message);
  
  @override
  String toString() => 'SearchServiceException: $message';
}