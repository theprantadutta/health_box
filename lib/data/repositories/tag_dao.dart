import 'package:drift/drift.dart';
import '../database/app_database.dart';

class TagDao {
  final AppDatabase _database;

  TagDao(this._database);

  Future<List<Tag>> getAllTags() async {
    return await (_database.select(_database.tags)..orderBy([
          (tag) =>
              OrderingTerm(expression: tag.usageCount, mode: OrderingMode.desc),
          (tag) => OrderingTerm(expression: tag.name),
        ]))
        .get();
  }

  Future<List<Tag>> getPopularTags({int limit = 10}) async {
    return await (_database.select(_database.tags)
          ..where((tag) => tag.usageCount.isBiggerThanValue(0))
          ..orderBy([
            (tag) => OrderingTerm(
              expression: tag.usageCount,
              mode: OrderingMode.desc,
            ),
            (tag) => OrderingTerm(expression: tag.name),
          ])
          ..limit(limit))
        .get();
  }

  Future<List<Tag>> getRecentlyCreatedTags({int limit = 10}) async {
    return await (_database.select(_database.tags)
          ..orderBy([
            (tag) => OrderingTerm(
              expression: tag.createdAt,
              mode: OrderingMode.desc,
            ),
          ])
          ..limit(limit))
        .get();
  }

  Future<List<Tag>> getUnusedTags() async {
    return await (_database.select(_database.tags)
          ..where((tag) => tag.usageCount.equals(0))
          ..orderBy([
            (tag) => OrderingTerm(
              expression: tag.createdAt,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  Future<Tag?> getTagById(String id) async {
    return await (_database.select(
      _database.tags,
    )..where((tag) => tag.id.equals(id))).getSingleOrNull();
  }

  Future<Tag?> getTagByName(String name) async {
    return await (_database.select(
      _database.tags,
    )..where((tag) => tag.name.equals(name))).getSingleOrNull();
  }

  Future<List<Tag>> searchTagsByName(String searchTerm) async {
    final searchPattern = '%${searchTerm.toLowerCase()}%';

    return await (_database.select(_database.tags)
          ..where(
            (tag) =>
                tag.name.lower().like(searchPattern) |
                tag.description.lower().like(searchPattern),
          )
          ..orderBy([
            (tag) => OrderingTerm(
              expression: tag.usageCount,
              mode: OrderingMode.desc,
            ),
            (tag) => OrderingTerm(expression: tag.name),
          ]))
        .get();
  }

  Future<List<Tag>> getTagsByColor(String color) async {
    return await (_database.select(_database.tags)
          ..where((tag) => tag.color.equals(color))
          ..orderBy([(tag) => OrderingTerm(expression: tag.name)]))
        .get();
  }

  Future<List<Tag>> getTagsByUsageRange(int minUsage, int maxUsage) async {
    return await (_database.select(_database.tags)
          ..where((tag) => tag.usageCount.isBetweenValues(minUsage, maxUsage))
          ..orderBy([
            (tag) => OrderingTerm(
              expression: tag.usageCount,
              mode: OrderingMode.desc,
            ),
            (tag) => OrderingTerm(expression: tag.name),
          ]))
        .get();
  }

  Future<List<Tag>> getTagsByCategory(String category) async {
    return await (_database.select(_database.tags)
          ..where((tag) => tag.category.equals(category))
          ..orderBy([(tag) => OrderingTerm(expression: tag.name)]))
        .get();
  }

  Future<String> createTag(TagsCompanion tag) async {
    await _database.into(_database.tags).insert(tag);
    return tag.id.value;
  }

  Future<String> createTagIfNotExists(
    String name,
    String color, {
    String? description,
  }) async {
    final existingTag = await getTagByName(name);
    if (existingTag != null) {
      return existingTag.id;
    }

    final tagCompanion = TagsCompanion(
      id: Value(_generateTagId()),
      name: Value(name),
      color: Value(color),
      description: Value(description),
      createdAt: Value(DateTime.now()),
      usageCount: const Value(0),
    );

    return await createTag(tagCompanion);
  }

  Future<bool> updateTag(String id, TagsCompanion tag) async {
    final rowsAffected = await (_database.update(
      _database.tags,
    )..where((t) => t.id.equals(id))).write(tag);

    return rowsAffected > 0;
  }

  Future<bool> updateTagName(String id, String newName) async {
    // Check if name is already taken by another tag
    final existingTag = await getTagByName(newName);
    if (existingTag != null && existingTag.id != id) {
      return false; // Name conflict
    }

    final rowsAffected =
        await (_database.update(_database.tags)..where((t) => t.id.equals(id)))
            .write(TagsCompanion(name: Value(newName)));

    return rowsAffected > 0;
  }

  Future<bool> updateTagColor(String id, String newColor) async {
    final rowsAffected =
        await (_database.update(_database.tags)..where((t) => t.id.equals(id)))
            .write(TagsCompanion(color: Value(newColor)));

    return rowsAffected > 0;
  }

  Future<bool> updateTagDescription(String id, String? description) async {
    final rowsAffected =
        await (_database.update(_database.tags)..where((t) => t.id.equals(id)))
            .write(TagsCompanion(description: Value(description)));

    return rowsAffected > 0;
  }

  Future<bool> incrementUsageCount(String id) async {
    final tag = await getTagById(id);
    if (tag == null) return false;

    final rowsAffected =
        await (_database.update(_database.tags)..where((t) => t.id.equals(id)))
            .write(TagsCompanion(usageCount: Value(tag.usageCount + 1)));

    return rowsAffected > 0;
  }

  Future<bool> decrementUsageCount(String id) async {
    final tag = await getTagById(id);
    if (tag == null || tag.usageCount <= 0) return false;

    final rowsAffected =
        await (_database.update(_database.tags)..where((t) => t.id.equals(id)))
            .write(TagsCompanion(usageCount: Value(tag.usageCount - 1)));

    return rowsAffected > 0;
  }

  Future<bool> setUsageCount(String id, int count) async {
    if (count < 0) return false;

    final rowsAffected =
        await (_database.update(_database.tags)..where((t) => t.id.equals(id)))
            .write(TagsCompanion(usageCount: Value(count)));

    return rowsAffected > 0;
  }

  Future<bool> deleteTag(String id) async {
    final rowsAffected = await (_database.delete(
      _database.tags,
    )..where((t) => t.id.equals(id))).go();

    return rowsAffected > 0;
  }

  Future<int> deleteUnusedTags() async {
    return await (_database.delete(
      _database.tags,
    )..where((t) => t.usageCount.equals(0))).go();
  }

  Future<int> getTotalTagCount() async {
    final query = _database.selectOnly(_database.tags)
      ..addColumns([_database.tags.id.count()]);

    final result = await query.getSingle();
    return result.read(_database.tags.id.count()) ?? 0;
  }

  Future<int> getUsedTagCount() async {
    final query = _database.selectOnly(_database.tags)
      ..addColumns([_database.tags.id.count()])
      ..where(_database.tags.usageCount.isBiggerThanValue(0));

    final result = await query.getSingle();
    return result.read(_database.tags.id.count()) ?? 0;
  }

  Future<int> getTotalUsageCount() async {
    final query = _database.selectOnly(_database.tags)
      ..addColumns([_database.tags.usageCount.sum()]);

    final result = await query.getSingle();
    return result.read(_database.tags.usageCount.sum())?.toInt() ?? 0;
  }

  Future<Map<String, int>> getColorStatistics() async {
    final query = _database.selectOnly(_database.tags)
      ..addColumns([_database.tags.color, _database.tags.id.count()])
      ..groupBy([_database.tags.color]);

    final results = await query.get();
    final Map<String, int> colorCounts = {};

    for (final result in results) {
      final color = result.read(_database.tags.color)!;
      final count = result.read(_database.tags.id.count()) ?? 0;
      colorCounts[color] = count;
    }

    return colorCounts;
  }

  Future<bool> tagExists(String id) async {
    final count =
        await (_database.selectOnly(_database.tags)
              ..addColumns([_database.tags.id.count()])
              ..where(_database.tags.id.equals(id)))
            .getSingle();

    return (count.read(_database.tags.id.count()) ?? 0) > 0;
  }

  Future<bool> tagNameExists(String name, {String? excludeId}) async {
    var query = _database.selectOnly(_database.tags)
      ..addColumns([_database.tags.id.count()])
      ..where(_database.tags.name.equals(name));

    if (excludeId != null) {
      query = query..where(_database.tags.id.isNotValue(excludeId));
    }

    final result = await query.getSingle();
    return (result.read(_database.tags.id.count()) ?? 0) > 0;
  }

  Future<List<String>> getAllTagNames() async {
    final query = _database.selectOnly(_database.tags)
      ..addColumns([_database.tags.name])
      ..orderBy([OrderingTerm(expression: _database.tags.name)]);

    final results = await query.get();
    return results.map((result) => result.read(_database.tags.name)!).toList();
  }

  Future<List<String>> getAllColors() async {
    final query = _database.selectOnly(_database.tags)
      ..addColumns([_database.tags.color])
      ..groupBy([_database.tags.color])
      ..orderBy([OrderingTerm(expression: _database.tags.color)]);

    final results = await query.get();
    return results.map((result) => result.read(_database.tags.color)!).toList();
  }

  // Bulk operations
  Future<List<String>> createMultipleTags(List<TagsCompanion> tags) async {
    final List<String> ids = [];

    for (final tagCompanion in tags) {
      try {
        final id = await createTag(tagCompanion);
        ids.add(id);
      } catch (e) {
        // Skip if tag name already exists or other constraint violation
        continue;
      }
    }

    return ids;
  }

  Future<int> incrementMultipleUsageCounts(List<String> tagIds) async {
    int totalAffected = 0;

    for (final id in tagIds) {
      if (await incrementUsageCount(id)) {
        totalAffected++;
      }
    }

    return totalAffected;
  }

  Future<int> decrementMultipleUsageCounts(List<String> tagIds) async {
    int totalAffected = 0;

    for (final id in tagIds) {
      if (await decrementUsageCount(id)) {
        totalAffected++;
      }
    }

    return totalAffected;
  }

  Future<int> deleteMultipleTags(List<String> tagIds) async {
    return await (_database.delete(
      _database.tags,
    )..where((t) => t.id.isIn(tagIds))).go();
  }

  // Stream operations for real-time updates
  Stream<List<Tag>> watchAllTags() {
    return (_database.select(_database.tags)..orderBy([
          (tag) =>
              OrderingTerm(expression: tag.usageCount, mode: OrderingMode.desc),
          (tag) => OrderingTerm(expression: tag.name),
        ]))
        .watch();
  }

  Stream<List<Tag>> watchPopularTags({int limit = 10}) {
    return (_database.select(_database.tags)
          ..where((tag) => tag.usageCount.isBiggerThanValue(0))
          ..orderBy([
            (tag) => OrderingTerm(
              expression: tag.usageCount,
              mode: OrderingMode.desc,
            ),
            (tag) => OrderingTerm(expression: tag.name),
          ])
          ..limit(limit))
        .watch();
  }

  Stream<Tag?> watchTag(String id) {
    return (_database.select(
      _database.tags,
    )..where((tag) => tag.id.equals(id))).watchSingleOrNull();
  }

  Stream<int> watchTotalTagCount() {
    final query = _database.selectOnly(_database.tags)
      ..addColumns([_database.tags.id.count()]);

    return query.watchSingle().map(
      (result) => result.read(_database.tags.id.count()) ?? 0,
    );
  }

  // Helper method to generate unique tag IDs
  String _generateTagId() {
    return 'tag_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Tag validation helpers
  bool isValidTagName(String name) {
    return name.trim().isNotEmpty && name.length <= 50;
  }

  bool isValidHexColor(String color) {
    final hexColorRegex = RegExp(r'^#[0-9A-Fa-f]{6}$');
    return hexColorRegex.hasMatch(color);
  }

  // Suggested tag colors
  static const List<String> suggestedColors = [
    '#FF5722', // Deep Orange
    '#E91E63', // Pink
    '#9C27B0', // Purple
    '#673AB7', // Deep Purple
    '#3F51B5', // Indigo
    '#2196F3', // Blue
    '#03A9F4', // Light Blue
    '#00BCD4', // Cyan
    '#009688', // Teal
    '#4CAF50', // Green
    '#8BC34A', // Light Green
    '#CDDC39', // Lime
    '#FFEB3B', // Yellow
    '#FFC107', // Amber
    '#FF9800', // Orange
    '#795548', // Brown
    '#607D8B', // Blue Grey
  ];
}
