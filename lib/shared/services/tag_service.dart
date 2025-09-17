import 'package:drift/drift.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/tag_dao.dart';

class TagService {
  final TagDao _tagDao;

  TagService({TagDao? tagDao, AppDatabase? database})
    : _tagDao = tagDao ?? TagDao(database ?? AppDatabase.instance);

  // CRUD Operations

  Future<List<Tag>> getAllTags() async {
    try {
      return await _tagDao.getAllTags();
    } catch (e) {
      throw TagServiceException('Failed to retrieve tags: ${e.toString()}');
    }
  }

  Future<Tag?> getTagById(String id) async {
    try {
      if (id.isEmpty) {
        throw const TagServiceException('Tag ID cannot be empty');
      }
      return await _tagDao.getTagById(id);
    } catch (e) {
      if (e is TagServiceException) rethrow;
      throw TagServiceException('Failed to retrieve tag: ${e.toString()}');
    }
  }

  Future<Tag?> getTagByName(String name) async {
    try {
      if (name.trim().isEmpty) {
        throw const TagServiceException('Tag name cannot be empty');
      }
      return await _tagDao.getTagByName(name.trim());
    } catch (e) {
      if (e is TagServiceException) rethrow;
      throw TagServiceException(
        'Failed to retrieve tag by name: ${e.toString()}',
      );
    }
  }

  Future<String> createTag(CreateTagRequest request) async {
    try {
      _validateCreateTagRequest(request);

      // Check if tag already exists
      final existingTag = await _tagDao.getTagByName(request.name.trim());
      if (existingTag != null) {
        throw TagServiceException('Tag "${request.name}" already exists');
      }

      final tagId = 'tag_${DateTime.now().millisecondsSinceEpoch}';
      final tagCompanion = TagsCompanion(
        id: Value(tagId),
        name: Value(request.name.trim()),
        description: request.description != null
            ? Value(request.description!.trim())
            : const Value.absent(),
        color: request.color != null
            ? Value(request.color!)
            : const Value.absent(),
        icon: Value(request.icon),
        category: Value(request.category),
        isSystem: Value(request.isSystem),
        usageCount: const Value(0),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        isActive: const Value(true),
      );

      return await _tagDao.createTag(tagCompanion);
    } catch (e) {
      if (e is TagServiceException) rethrow;
      throw TagServiceException('Failed to create tag: ${e.toString()}');
    }
  }

  Future<bool> updateTag(String id, UpdateTagRequest request) async {
    try {
      if (id.isEmpty) {
        throw const TagServiceException('Tag ID cannot be empty');
      }

      final existingTag = await _tagDao.getTagById(id);
      if (existingTag == null) {
        throw const TagServiceException('Tag not found');
      }

      _validateUpdateTagRequest(request);

      // Check if new name conflicts with existing tag
      if (request.name != null) {
        final conflictingTag = await _tagDao.getTagByName(request.name!.trim());
        if (conflictingTag != null && conflictingTag.id != id) {
          throw TagServiceException('Tag "${request.name}" already exists');
        }
      }

      final tagCompanion = TagsCompanion(
        name: request.name != null
            ? Value(request.name!.trim())
            : const Value.absent(),
        description: request.description != null
            ? Value(request.description?.trim())
            : const Value.absent(),
        color: request.color != null
            ? Value(request.color!)
            : const Value.absent(),
        icon: request.icon != null
            ? Value(request.icon!)
            : const Value.absent(),
        category: request.category != null
            ? Value(request.category!)
            : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      );

      return await _tagDao.updateTag(id, tagCompanion);
    } catch (e) {
      if (e is TagServiceException) rethrow;
      throw TagServiceException('Failed to update tag: ${e.toString()}');
    }
  }

  Future<bool> deleteTag(String id) async {
    try {
      if (id.isEmpty) {
        throw const TagServiceException('Tag ID cannot be empty');
      }

      final existingTag = await _tagDao.getTagById(id);
      if (existingTag == null) {
        throw const TagServiceException('Tag not found');
      }

      if (existingTag.isSystem) {
        throw const TagServiceException('Cannot delete system tags');
      }

      return await _tagDao.deleteTag(id);
    } catch (e) {
      if (e is TagServiceException) rethrow;
      throw TagServiceException('Failed to delete tag: ${e.toString()}');
    }
  }

  // Tag Usage Operations

  Future<bool> incrementTagUsage(String tagId) async {
    try {
      return await _tagDao.incrementUsageCount(tagId);
    } catch (e) {
      throw TagServiceException(
        'Failed to increment tag usage: ${e.toString()}',
      );
    }
  }

  Future<bool> decrementTagUsage(String tagId) async {
    try {
      return await _tagDao.decrementUsageCount(tagId);
    } catch (e) {
      throw TagServiceException(
        'Failed to decrement tag usage: ${e.toString()}',
      );
    }
  }

  // Advanced Query Operations

  Future<List<Tag>> getPopularTags({int limit = 10}) async {
    try {
      return await _tagDao.getPopularTags(limit: limit);
    } catch (e) {
      throw TagServiceException(
        'Failed to retrieve popular tags: ${e.toString()}',
      );
    }
  }

  Future<List<Tag>> getRecentlyCreatedTags({int limit = 10}) async {
    try {
      return await _tagDao.getRecentlyCreatedTags(limit: limit);
    } catch (e) {
      throw TagServiceException(
        'Failed to retrieve recently created tags: ${e.toString()}',
      );
    }
  }

  Future<List<Tag>> getUnusedTags() async {
    try {
      return await _tagDao.getUnusedTags();
    } catch (e) {
      throw TagServiceException(
        'Failed to retrieve unused tags: ${e.toString()}',
      );
    }
  }

  Future<List<Tag>> getTagsByCategory(String category) async {
    try {
      return await _tagDao.getTagsByCategory(category);
    } catch (e) {
      throw TagServiceException(
        'Failed to retrieve tags by category: ${e.toString()}',
      );
    }
  }

  Future<List<Tag>> searchTags(String searchTerm) async {
    try {
      if (searchTerm.trim().isEmpty) {
        return await getAllTags();
      }
      return await _tagDao.searchTagsByName(searchTerm.trim());
    } catch (e) {
      throw TagServiceException('Failed to search tags: ${e.toString()}');
    }
  }

  // Bulk Operations

  Future<int> bulkCreateTags(List<CreateTagRequest> requests) async {
    try {
      int createdCount = 0;
      for (final request in requests) {
        try {
          await createTag(request);
          createdCount++;
        } catch (e) {
          // Continue with other tags if one fails
        }
      }
      return createdCount;
    } catch (e) {
      throw TagServiceException('Failed to bulk create tags: ${e.toString()}');
    }
  }

  Future<int> bulkDeleteTags(List<String> tagIds) async {
    try {
      int deletedCount = 0;
      for (final tagId in tagIds) {
        try {
          final deleted = await deleteTag(tagId);
          if (deleted) deletedCount++;
        } catch (e) {
          // Continue with other tags if one fails
        }
      }
      return deletedCount;
    } catch (e) {
      throw TagServiceException('Failed to bulk delete tags: ${e.toString()}');
    }
  }

  Future<int> cleanupUnusedTags() async {
    try {
      final unusedTags = await getUnusedTags();
      final nonSystemTags = unusedTags.where((tag) => !tag.isSystem).toList();

      int deletedCount = 0;
      for (final tag in nonSystemTags) {
        try {
          final deleted = await deleteTag(tag.id);
          if (deleted) deletedCount++;
        } catch (e) {
          // Continue with other tags if one fails
        }
      }
      return deletedCount;
    } catch (e) {
      throw TagServiceException(
        'Failed to cleanup unused tags: ${e.toString()}',
      );
    }
  }

  // Statistics Operations

  Future<TagStatistics> getTagStatistics() async {
    try {
      final allTags = await _tagDao.getAllTags();
      final popularTags = await _tagDao.getPopularTags(limit: 10);
      final unusedTags = await _tagDao.getUnusedTags();

      final systemTags = allTags.where((tag) => tag.isSystem).length;
      final userTags = allTags.where((tag) => !tag.isSystem).length;

      final totalUsage = allTags.fold<int>(
        0,
        (sum, tag) => sum + tag.usageCount,
      );
      final averageUsage = allTags.isNotEmpty
          ? totalUsage / allTags.length
          : 0.0;

      final categoryCounts = <String, int>{};
      for (final tag in allTags) {
        final category = tag.category ?? 'Other';
        categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
      }

      return TagStatistics(
        totalTags: allTags.length,
        systemTags: systemTags,
        userTags: userTags,
        popularTags: popularTags.length,
        unusedTags: unusedTags.length,
        totalUsage: totalUsage,
        averageUsage: averageUsage,
        categoryCounts: categoryCounts,
      );
    } catch (e) {
      throw TagServiceException(
        'Failed to retrieve tag statistics: ${e.toString()}',
      );
    }
  }

  // Stream Operations

  Stream<List<Tag>> watchAllTags() {
    return _tagDao.watchAllTags();
  }

  Stream<List<Tag>> watchPopularTags({int limit = 10}) {
    return _tagDao.watchPopularTags(limit: limit);
  }

  Stream<Tag?> watchTag(String id) {
    return _tagDao.watchTag(id);
  }

  // Utility Methods

  Future<bool> tagExists(String id) async {
    try {
      if (id.isEmpty) return false;
      return await _tagDao.tagExists(id);
    } catch (e) {
      return false;
    }
  }

  Future<bool> tagNameExists(String name) async {
    try {
      if (name.trim().isEmpty) return false;
      final tag = await _tagDao.getTagByName(name.trim());
      return tag != null;
    } catch (e) {
      return false;
    }
  }

  Future<String> getOrCreateTag(
    String name, {
    String? description,
    String? color,
    String? icon,
    String? category,
  }) async {
    try {
      final existingTag = await getTagByName(name);
      if (existingTag != null) {
        return existingTag.id;
      }

      final request = CreateTagRequest(
        name: name,
        description: description,
        color: color,
        icon: icon,
        category: category,
      );

      return await createTag(request);
    } catch (e) {
      throw TagServiceException('Failed to get or create tag: ${e.toString()}');
    }
  }

  // Validation Methods

  void _validateCreateTagRequest(CreateTagRequest request) {
    if (request.name.trim().isEmpty) {
      throw const TagServiceException('Tag name cannot be empty');
    }
    if (request.name.length > 50) {
      throw const TagServiceException('Tag name cannot exceed 50 characters');
    }
    if (request.description != null && request.description!.length > 255) {
      throw const TagServiceException(
        'Tag description cannot exceed 255 characters',
      );
    }
    if (request.color != null && !_isValidColor(request.color!)) {
      throw const TagServiceException('Invalid color format');
    }
  }

  void _validateUpdateTagRequest(UpdateTagRequest request) {
    if (request.name != null && request.name!.trim().isEmpty) {
      throw const TagServiceException('Tag name cannot be empty');
    }
    if (request.name != null && request.name!.length > 50) {
      throw const TagServiceException('Tag name cannot exceed 50 characters');
    }
    if (request.description != null && request.description!.length > 255) {
      throw const TagServiceException(
        'Tag description cannot exceed 255 characters',
      );
    }
    if (request.color != null && !_isValidColor(request.color!)) {
      throw const TagServiceException('Invalid color format');
    }
  }

  bool _isValidColor(String color) {
    return RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(color);
  }
}

// Data Transfer Objects

class CreateTagRequest {
  final String name;
  final String? description;
  final String? color;
  final String? icon;
  final String? category;
  final bool isSystem;

  const CreateTagRequest({
    required this.name,
    this.description,
    this.color,
    this.icon,
    this.category,
    this.isSystem = false,
  });
}

class UpdateTagRequest {
  final String? name;
  final String? description;
  final String? color;
  final String? icon;
  final String? category;

  const UpdateTagRequest({
    this.name,
    this.description,
    this.color,
    this.icon,
    this.category,
  });
}

class TagStatistics {
  final int totalTags;
  final int systemTags;
  final int userTags;
  final int popularTags;
  final int unusedTags;
  final int totalUsage;
  final double averageUsage;
  final Map<String, int> categoryCounts;

  const TagStatistics({
    required this.totalTags,
    required this.systemTags,
    required this.userTags,
    required this.popularTags,
    required this.unusedTags,
    required this.totalUsage,
    required this.averageUsage,
    required this.categoryCounts,
  });
}

// Exceptions

class TagServiceException implements Exception {
  final String message;

  const TagServiceException(this.message);

  @override
  String toString() => 'TagServiceException: $message';
}
