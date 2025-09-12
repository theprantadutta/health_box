import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/tag_service.dart';
import '../../data/database/app_database.dart';

class TagManagementScreen extends ConsumerStatefulWidget {
  const TagManagementScreen({super.key});

  @override
  ConsumerState<TagManagementScreen> createState() => _TagManagementScreenState();
}

class _TagManagementScreenState extends ConsumerState<TagManagementScreen> {
  final TagService _tagService = TagService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showOnlyUserTags = false;
  String? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tag Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showStatistics,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(theme),
          Expanded(
            child: StreamBuilder<List<Tag>>(
              stream: _tagService.watchAllTags(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var tags = snapshot.data!;
                tags = _filterTags(tags);

                if (tags.isEmpty) {
                  return _buildEmptyState(theme);
                }

                return _buildTagList(theme, tags);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateTagDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchAndFilters(ThemeData theme) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search tags...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('User tags only'),
                    value: _showOnlyUserTags,
                    onChanged: (value) {
                      setState(() {
                        _showOnlyUserTags = value ?? false;
                      });
                    },
                    dense: true,
                  ),
                ),
                Expanded(
                  child: PopupMenuButton<String?>(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colorScheme.outline),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedCategory ?? 'All categories',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                    onSelected: (category) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem<String?>(
                        value: null,
                        child: Text('All categories'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Medical',
                        child: Text('Medical'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Medication',
                        child: Text('Medication'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Appointment',
                        child: Text('Appointment'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Personal',
                        child: Text('Personal'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No tags found',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try adjusting your search or filters'
                : 'Create your first tag to get started',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagList(ThemeData theme, List<Tag> tags) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: tags.length,
      itemBuilder: (context, index) {
        final tag = tags[index];
        return _buildTagItem(theme, tag);
      },
    );
  }

  Widget _buildTagItem(ThemeData theme, Tag tag) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: _parseColor(tag.color),
            shape: BoxShape.circle,
          ),
        ),
        title: Text(
          tag.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tag.description?.isNotEmpty == true) ...[
              Text(tag.description!),
              const SizedBox(height: 4),
            ],
            Row(
              children: [
                if (tag.category != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tag.category!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  'Used ${tag.usageCount} times',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (tag.isSystem) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'System',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) => _handleTagAction(action, tag),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            if (!tag.isSystem)
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Tag> _filterTags(List<Tag> tags) {
    var filtered = tags;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((tag) =>
              tag.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (tag.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false))
          .toList();
    }

    if (_showOnlyUserTags) {
      filtered = filtered.where((tag) => !tag.isSystem).toList();
    }

    if (_selectedCategory != null) {
      filtered = filtered.where((tag) => tag.category == _selectedCategory).toList();
    }

    return filtered;
  }

  void _handleTagAction(String action, Tag tag) {
    switch (action) {
      case 'edit':
        _showEditTagDialog(tag);
        break;
      case 'delete':
        _showDeleteConfirmation(tag);
        break;
    }
  }

  void _showCreateTagDialog() {
    _showTagDialog();
  }

  void _showEditTagDialog(Tag tag) {
    _showTagDialog(tag: tag);
  }

  void _showTagDialog({Tag? tag}) {
    final nameController = TextEditingController(text: tag?.name ?? '');
    final descriptionController = TextEditingController(text: tag?.description ?? '');
    Color selectedColor = _parseColor(tag?.color ?? '#2196F3');
    String? selectedCategory = tag?.category;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(tag == null ? 'Create Tag' : 'Edit Tag'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tag Name*',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 50,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 255,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  child: DropdownButton<String?>(
                    value: selectedCategory,
                    isExpanded: true,
                    underline: const SizedBox(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                      });
                    },
                    items: const [
                      DropdownMenuItem(value: null, child: Text('None')),
                      DropdownMenuItem(value: 'Medical', child: Text('Medical')),
                      DropdownMenuItem(value: 'Medication', child: Text('Medication')),
                      DropdownMenuItem(value: 'Appointment', child: Text('Appointment')),
                      DropdownMenuItem(value: 'Personal', child: Text('Personal')),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Color:'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _getTagColors().map((color) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedColor = color;
                            });
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selectedColor == color
                                    ? Colors.black
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => _saveTag(
                context,
                tag,
                nameController.text,
                descriptionController.text,
                selectedColor,
                selectedCategory,
              ),
              child: Text(tag == null ? 'Create' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveTag(
    BuildContext context,
    Tag? existingTag,
    String name,
    String description,
    Color color,
    String? category,
  ) async {
    if (name.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tag name is required')),
      );
      return;
    }

    try {
      if (existingTag == null) {
        final request = CreateTagRequest(
          name: name.trim(),
          description: description.trim().isNotEmpty ? description.trim() : null,
          color: '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
          category: category,
        );
        await _tagService.createTag(request);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tag created successfully')),
          );
        }
      } else {
        final request = UpdateTagRequest(
          name: name.trim(),
          description: description.trim().isNotEmpty ? description.trim() : null,
          color: '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
          category: category,
        );
        await _tagService.updateTag(existingTag.id, request);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tag updated successfully')),
          );
        }
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _showDeleteConfirmation(Tag tag) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tag'),
        content: Text(
          'Are you sure you want to delete "${tag.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _deleteTag(tag),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteTag(Tag tag) async {
    try {
      await _tagService.deleteTag(tag.id);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tag deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _showStatistics() async {
    try {
      final stats = await _tagService.getTagStatistics();
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Tag Statistics'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Tags: ${stats.totalTags}'),
                Text('System Tags: ${stats.systemTags}'),
                Text('User Tags: ${stats.userTags}'),
                Text('Popular Tags: ${stats.popularTags}'),
                Text('Unused Tags: ${stats.unusedTags}'),
                Text('Total Usage: ${stats.totalUsage}'),
                Text('Average Usage: ${stats.averageUsage.toStringAsFixed(1)}'),
                const SizedBox(height: 16),
                const Text('Categories:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...stats.categoryCounts.entries.map((entry) =>
                    Text('${entry.key}: ${entry.value}')),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading statistics: ${e.toString()}')),
        );
      }
    }
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }

  List<Color> _getTagColors() {
    return [
      const Color(0xFF2196F3), // Blue
      const Color(0xFF4CAF50), // Green  
      const Color(0xFFF44336), // Red
      const Color(0xFFFF9800), // Orange
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFFFFC107), // Amber
      const Color(0xFF795548), // Brown
      const Color(0xFF607D8B), // Blue Grey
      const Color(0xFFE91E63), // Pink
      const Color(0xFF8BC34A), // Light Green
      const Color(0xFF673AB7), // Deep Purple
    ];
  }
}