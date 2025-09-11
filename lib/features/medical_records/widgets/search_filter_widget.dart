import 'package:flutter/material.dart';

class SearchFilterWidget extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final String selectedRecordType;
  final List<String> recordTypes;
  final ValueChanged<String> onRecordTypeChanged;

  const SearchFilterWidget({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.selectedRecordType,
    required this.recordTypes,
    required this.onRecordTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        TextField(
          decoration: InputDecoration(
            hintText: 'Search medical records...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => onSearchChanged(''),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          onChanged: onSearchChanged,
        ),
        const SizedBox(height: 12),
        
        // Record Type Filter
        Row(
          children: [
            const Text('Type: '),
            Expanded(
              child: DropdownButton<String>(
                value: selectedRecordType,
                isExpanded: true,
                items: recordTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) onRecordTypeChanged(value);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}