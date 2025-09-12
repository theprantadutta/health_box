import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/tag_service.dart';
import '../../data/database/app_database.dart';

class TagSelectorWidget extends ConsumerStatefulWidget {
  final List<String> selectedTagIds;
  final ValueChanged<List<String>> onSelectionChanged;
  final bool allowMultiSelect;
  final bool showCreateNew;
  final String? filterCategory;
  final int maxTags;

  const TagSelectorWidget({
    super.key,
    required this.selectedTagIds,
    required this.onSelectionChanged,
    this.allowMultiSelect = true,
    this.showCreateNew = true,
    this.filterCategory,
    this.maxTags = 10,
  });

  @override
  ConsumerState<TagSelectorWidget> createState() => _TagSelectorWidgetState();
}

class _TagSelectorWidgetState extends ConsumerState<TagSelectorWidget> {
  final TagService _tagService = TagService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showPopular = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 16),
            _buildSearchBar(theme),
            const SizedBox(height: 16),
            _buildSelectedTags(theme),
            const SizedBox(height: 16),
            _buildAvailableTags(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Icon(Icons.local_offer, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          'Tags',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        if (widget.selectedTagIds.isNotEmpty)
          Text(
            '${widget.selectedTagIds.length}/${widget.maxTags}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: TextField(
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
              isDense: true,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(
            _showPopular ? Icons.trending_up : Icons.trending_down,
            color: _showPopular ? theme.colorScheme.primary : null,
          ),
          onPressed: () {
            setState(() {
              _showPopular = !_showPopular;
            });
          },
          tooltip: _showPopular ? 'Show all tags' : 'Show popular tags',
        ),
      ],
    );
  }

  Widget _buildSelectedTags(ThemeData theme) {
    if (widget.selectedTagIds.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              'No tags selected',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return FutureBuilder<List<Tag>>(
      future: _getSelectedTags(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(height: 40, child: Center(child: CircularProgressIndicator()));
        }

        final selectedTags = snapshot.data!;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: selectedTags.map((tag) => _buildSelectedTagChip(theme, tag)).toList(),
        );
      },
    );
  }

  Widget _buildSelectedTagChip(ThemeData theme, Tag tag) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: _parseColor(tag.color),
        radius: 8,
      ),
      label: Text(tag.name),
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: () {
        final updatedSelection = List<String>.from(widget.selectedTagIds)
          ..remove(tag.id);
        widget.onSelectionChanged(updatedSelection);
      },
      backgroundColor: theme.colorScheme.primaryContainer,
      labelStyle: TextStyle(color: theme.colorScheme.onPrimaryContainer),
    );
  }

  Widget _buildAvailableTags(ThemeData theme) {
    return StreamBuilder<List<Tag>>(
      stream: _getTagsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var tags = snapshot.data!;
        tags = _filterTags(tags);

        if (tags.isEmpty && _searchQuery.isNotEmpty && widget.showCreateNew) {
          return _buildCreateNewTag(theme);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tags.isNotEmpty) ...[
              Text(
                'Available Tags',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              _buildTagGrid(theme, tags),
            ],
            if (widget.showCreateNew && _searchQuery.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildCreateNewTag(theme),
            ],
          ],
        );
      },
    );
  }

  Widget _buildTagGrid(ThemeData theme, List<Tag> tags) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) => _buildTagChip(theme, tag)).toList(),
    );
  }

  Widget _buildTagChip(ThemeData theme, Tag tag) {
    final isSelected = widget.selectedTagIds.contains(tag.id);
    final canSelect = widget.allowMultiSelect || widget.selectedTagIds.isEmpty || isSelected;
    final atMaxLimit = widget.selectedTagIds.length >= widget.maxTags && !isSelected;

    return FilterChip(
      avatar: CircleAvatar(
        backgroundColor: _parseColor(tag.color),
        radius: 8,
      ),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(tag.name),
          if (tag.usageCount > 0) ...[
            const SizedBox(width: 4),
            Text(
              '(${tag.usageCount})',
              style: TextStyle(
                fontSize: 10,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
      selected: isSelected,
      onSelected: (canSelect && !atMaxLimit)
          ? (selected) {
              List<String> updatedSelection;
              if (widget.allowMultiSelect) {
                updatedSelection = List<String>.from(widget.selectedTagIds);
                if (selected) {
                  updatedSelection.add(tag.id);
                } else {
                  updatedSelection.remove(tag.id);
                }
              } else {
                updatedSelection = selected ? [tag.id] : [];
              }
              widget.onSelectionChanged(updatedSelection);
            }
          : null,
      backgroundColor: isSelected
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHighest,
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.onPrimaryContainer,
      labelStyle: TextStyle(
        color: isSelected
            ? theme.colorScheme.onPrimaryContainer
            : (canSelect && !atMaxLimit)
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurface.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildCreateNewTag(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create New Tag',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        ActionChip(
          avatar: const Icon(Icons.add, size: 18),
          label: Text('Create "${_searchQuery.trim()}"'),
          onPressed: _searchQuery.trim().isNotEmpty ? () => _showCreateTagDialog(_searchQuery.trim()) : null,
          backgroundColor: theme.colorScheme.secondaryContainer,
          labelStyle: TextStyle(color: theme.colorScheme.onSecondaryContainer),
        ),
      ],
    );
  }

  Stream<List<Tag>> _getTagsStream() {
    if (_showPopular) {
      return _tagService.watchPopularTags(limit: 20);
    } else {
      return _tagService.watchAllTags();
    }
  }

  List<Tag> _filterTags(List<Tag> tags) {
    var filtered = tags;

    // Filter out already selected tags
    filtered = filtered.where((tag) => !widget.selectedTagIds.contains(tag.id)).toList();

    // Filter by category if specified
    if (widget.filterCategory != null) {
      filtered = filtered.where((tag) => tag.category == widget.filterCategory).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((tag) =>
              tag.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (tag.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false))
          .toList();
    }

    return filtered;
  }

  Future<List<Tag>> _getSelectedTags() async {
    if (widget.selectedTagIds.isEmpty) return [];

    final List<Tag> tags = [];
    for (final tagId in widget.selectedTagIds) {
      final tag = await _tagService.getTagById(tagId);
      if (tag != null) {
        tags.add(tag);
      }
    }
    return tags;
  }

  void _showCreateTagDialog(String name) {
    final descriptionController = TextEditingController();
    Color selectedColor = const Color(0xFF2196F3);
    String? selectedCategory = widget.filterCategory;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create New Tag'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: TextEditingController(text: name),
                  decoration: const InputDecoration(
                    labelText: 'Tag Name',
                    border: OutlineInputBorder(),
                  ),
                  enabled: false,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 255,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                if (widget.filterCategory == null)
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
              onPressed: () => _createAndSelectTag(
                context,
                name,
                descriptionController.text,
                selectedColor,
                selectedCategory,
              ),
              child: const Text('Create & Select'),
            ),
          ],
        ),
      ),
    );
  }

  void _createAndSelectTag(
    BuildContext context,
    String name,
    String description,
    Color color,
    String? category,
  ) async {
    try {
      final request = CreateTagRequest(
        name: name.trim(),
        description: description.trim().isNotEmpty ? description.trim() : null,
        color: '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
        category: category,
      );

      final tagId = await _tagService.createTag(request);
      
      if (mounted) {
        Navigator.of(context).pop();
        
        // Add the new tag to selection
        final updatedSelection = List<String>.from(widget.selectedTagIds)..add(tagId);
        widget.onSelectionChanged(updatedSelection);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tag created and selected')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating tag: ${e.toString()}')),
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
    ];
  }
}