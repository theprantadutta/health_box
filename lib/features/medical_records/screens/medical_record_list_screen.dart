import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/database/app_database.dart';
import '../../../shared/providers/medical_records_providers.dart';
import '../../../shared/providers/profile_providers.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/theme/app_theme.dart';
import '../widgets/medical_record_card.dart';
import '../widgets/search_filter_widget.dart';
import 'prescription_form_screen.dart';
import 'medication_form_screen.dart';
import 'lab_report_form_screen.dart';

class MedicalRecordListScreen extends ConsumerStatefulWidget {
  final String? profileId;
  final String? initialRecordType;

  const MedicalRecordListScreen({
    super.key,
    this.profileId,
    this.initialRecordType,
  });

  @override
  ConsumerState<MedicalRecordListScreen> createState() => _MedicalRecordListScreenState();
}

class _MedicalRecordListScreenState extends ConsumerState<MedicalRecordListScreen> {
  String _searchQuery = '';
  String _selectedRecordType = 'All';
  String? _selectedProfileId;
  DateTimeRange? _dateRange;
  
  final List<String> _recordTypes = [
    'All',
    'Prescription',
    'Medication',
    'Lab Report',
    'Vaccination',
    'Allergy',
    'Chronic Condition'
  ];

  @override
  void initState() {
    super.initState();
    _selectedProfileId = widget.profileId;
    _selectedRecordType = widget.initialRecordType ?? 'All';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Medical Records',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.getPrimaryGradient(isDarkMode),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterDialog,
            tooltip: 'Filter Records',
          ),
          PopupMenuButton<String>(
            onSelected: _onAddRecordSelected,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'prescription',
                child: Row(
                  children: [
                    Icon(Icons.medication),
                    SizedBox(width: 8),
                    Text('Add Prescription'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'medication',
                child: Row(
                  children: [
                    Icon(Icons.medical_services),
                    SizedBox(width: 8),
                    Text('Add Medication'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'lab_report',
                child: Row(
                  children: [
                    Icon(Icons.science),
                    SizedBox(width: 8),
                    Text('Add Lab Report'),
                  ],
                ),
              ),
            ],
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Quick Filter
          Container(
            padding: const EdgeInsets.all(16.0),
            child: SearchFilterWidget(
              searchQuery: _searchQuery,
              onSearchChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
              selectedRecordType: _selectedRecordType,
              recordTypes: _recordTypes,
              onRecordTypeChanged: (type) {
                setState(() {
                  _selectedRecordType = type;
                });
              },
            ),
          ),
          
          // Profile Filter
          if (_selectedProfileId == null) _buildProfileSelector(),
          
          // Records List
          Expanded(
            child: _buildRecordsList(),
          ),
        ],
      ),
      floatingActionButton: GradientButton(
        onPressed: () => _showAddRecordOptions(context),
        style: GradientButtonStyle.primary,
        size: GradientButtonSize.medium,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: Colors.white),
            SizedBox(width: 8),
            Text('Add Record'),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSelector() {
    final profilesAsync = ref.watch(allProfilesProvider);

    return profilesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
      data: (profiles) {
        if (profiles.isEmpty) return const SizedBox.shrink();
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              const Text('Profile: '),
              Expanded(
                child: DropdownButton<String?>(
                  value: _selectedProfileId,
                  isExpanded: true,
                  hint: const Text('All Profiles'),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All Profiles'),
                    ),
                    ...profiles.map((profile) => DropdownMenuItem<String?>(
                          value: profile.id,
                          child: Text('${profile.firstName} ${profile.lastName}'),
                        )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedProfileId = value;
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecordsList() {
    final recordsAsync = _selectedProfileId != null
        ? ref.watch(recordsByProfileIdProvider(_selectedProfileId!))
        : ref.watch(allMedicalRecordsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(allMedicalRecordsProvider);
        if (_selectedProfileId != null) {
          ref.invalidate(recordsByProfileIdProvider);
        }
      },
      child: recordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error),
        data: (records) => _buildRecordsGrid(records),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading medical records',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              ref.invalidate(allMedicalRecordsProvider);
              if (_selectedProfileId != null) {
                ref.invalidate(recordsByProfileIdProvider);
              }
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsGrid(List<MedicalRecord> allRecords) {
    final filteredRecords = _filterRecords(allRecords);

    if (filteredRecords.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredRecords.length,
      itemBuilder: (context, index) {
        final record = filteredRecords[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: MedicalRecordCard(
            record: record,
            onTap: () => _navigateToRecordDetail(record),
            onEdit: () => _navigateToEditRecord(record),
            onDelete: () => _showDeleteConfirmation(record),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final hasFilters = _searchQuery.isNotEmpty || 
                      _selectedRecordType != 'All' || 
                      _selectedProfileId != null ||
                      _dateRange != null;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasFilters ? Icons.search_off : Icons.medical_information,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters ? 'No records found' : 'No medical records yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            hasFilters
                ? 'Try adjusting your search or filters'
                : 'Add your first medical record to get started',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          if (!hasFilters)
            ElevatedButton.icon(
              onPressed: () => _showAddRecordOptions(context),
              icon: const Icon(Icons.add),
              label: const Text('Add First Record'),
            ),
        ],
      ),
    );
  }

  List<MedicalRecord> _filterRecords(List<MedicalRecord> records) {
    var filteredRecords = records;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredRecords = filteredRecords.where((record) {
        final titleMatch = record.title.toLowerCase().contains(_searchQuery.toLowerCase());
        final descriptionMatch = record.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
        return titleMatch || descriptionMatch;
      }).toList();
    }

    // Apply record type filter
    if (_selectedRecordType != 'All') {
      filteredRecords = filteredRecords.where((record) {
        return record.recordType == _selectedRecordType;
      }).toList();
    }

    // Apply date range filter
    if (_dateRange != null) {
      filteredRecords = filteredRecords.where((record) {
        return record.recordDate.isAfter(_dateRange!.start.subtract(const Duration(days: 1))) &&
               record.recordDate.isBefore(_dateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    // Sort by date (newest first)
    filteredRecords.sort((a, b) => b.recordDate.compareTo(a.recordDate));

    return filteredRecords;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Records'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Date Range Filter
            Row(
              children: [
                Expanded(
                  child: Text(
                    _dateRange != null
                        ? 'From: ${_dateRange!.start.day}/${_dateRange!.start.month}/${_dateRange!.start.year}\nTo: ${_dateRange!.end.day}/${_dateRange!.end.month}/${_dateRange!.end.year}'
                        : 'Select date range',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                TextButton(
                  onPressed: _selectDateRange,
                  child: const Text('Select'),
                ),
              ],
            ),
            if (_dateRange != null)
              TextButton(
                onPressed: () {
                  setState(() {
                    _dateRange = null;
                  });
                },
                child: const Text('Clear Date Filter'),
              ),
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

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    
    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  void _showAddRecordOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add New Medical Record',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.medication),
              title: const Text('Prescription'),
              onTap: () {
                Navigator.of(context).pop();
                _onAddRecordSelected('prescription');
              },
            ),
            ListTile(
              leading: const Icon(Icons.medical_services),
              title: const Text('Medication'),
              onTap: () {
                Navigator.of(context).pop();
                _onAddRecordSelected('medication');
              },
            ),
            ListTile(
              leading: const Icon(Icons.science),
              title: const Text('Lab Report'),
              onTap: () {
                Navigator.of(context).pop();
                _onAddRecordSelected('lab_report');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onAddRecordSelected(String recordType) {
    switch (recordType) {
      case 'prescription':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PrescriptionFormScreen(
              profileId: _selectedProfileId,
            ),
          ),
        );
        break;
      case 'medication':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MedicationFormScreen(
              profileId: _selectedProfileId,
            ),
          ),
        );
        break;
      case 'lab_report':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LabReportFormScreen(
              profileId: _selectedProfileId,
            ),
          ),
        );
        break;
    }
  }

  void _navigateToRecordDetail(MedicalRecord record) {
    // TODO: Navigate to detail screen once implemented
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Detail view for ${record.title} - Will be implemented in T055'),
      ),
    );
  }

  void _navigateToEditRecord(MedicalRecord record) {
    switch (record.recordType) {
      case 'Prescription':
        // TODO: Navigate to prescription edit form
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Edit Prescription - Coming in T056')),
        );
        break;
      case 'Medication':
        // TODO: Navigate to medication edit form
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Edit Medication - Coming in T057')),
        );
        break;
      case 'Lab Report':
        // TODO: Navigate to lab report edit form
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Edit Lab Report - Coming in T058')),
        );
        break;
    }
  }

  void _showDeleteConfirmation(MedicalRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: Text(
          'Are you sure you want to delete "${record.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement delete functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Delete functionality will be implemented with service integration'),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}