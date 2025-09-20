import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/database/app_database.dart';
import '../../../shared/providers/medical_records_providers.dart';
import '../../../shared/providers/profile_providers.dart';
import '../../../shared/widgets/gradient_button.dart'; // Updated to HealthButton
import '../../../shared/widgets/modern_card.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/animations/common_transitions.dart';
import '../../../shared/animations/stagger_animations.dart';
import '../../../shared/animations/micro_interactions.dart';
import '../widgets/medical_record_card.dart';
import 'prescription_form_screen.dart';
import 'medication_form_screen.dart';
import 'lab_report_form_screen.dart';
import 'medical_record_detail_screen.dart';

class MedicalRecordListScreen extends ConsumerStatefulWidget {
  final String? profileId;
  final String? initialRecordType;

  const MedicalRecordListScreen({
    super.key,
    this.profileId,
    this.initialRecordType,
  });

  @override
  ConsumerState<MedicalRecordListScreen> createState() =>
      _MedicalRecordListScreenState();
}

class _MedicalRecordListScreenState
    extends ConsumerState<MedicalRecordListScreen> {
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
    'Chronic Condition',
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

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(
          'Medical Records',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
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
          // Premium Search and Filter Section
          CommonTransitions.fadeSlideIn(
            child: ModernCard(
              elevation: CardElevation.low,
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Premium Search Bar
                  TextField(
                    onChanged: (query) {
                      setState(() {
                        _searchQuery = query;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Search Medical Records',
                      hintText: 'Search by title, description...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppTheme.primaryColorLight,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Record Type Filter
                  Row(
                    children: [
                      Icon(
                        Icons.filter_list_rounded,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Filter by type:',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.outline.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: DropdownButton<String>(
                            value: _selectedRecordType,
                            isExpanded: true,
                            underline: const SizedBox.shrink(),
                            items: _recordTypes
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(
                                      type,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedRecordType = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Profile Filter
          if (_selectedProfileId == null) _buildProfileSelector(),

          // Records List
          Expanded(child: _buildRecordsList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddRecordOptions(context),
        tooltip: 'Add New Medical Record',
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text(
          'Add Record',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
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
                    ...profiles.map(
                      (profile) => DropdownMenuItem<String?>(
                        value: profile.id,
                        child: Text('${profile.firstName} ${profile.lastName}'),
                      ),
                    ),
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
        loading: () => Center(
          child: CommonTransitions.fadeSlideIn(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MicroInteractions.breathingDots(
                  color: AppTheme.primaryColorLight,
                  dotCount: 3,
                  dotSize: 12.0,
                ),
                const SizedBox(height: 24),
                Text(
                  'Loading medical records...',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        error: (error, stack) => _buildErrorState(error, Theme.of(context)),
        data: (records) => _buildRecordsGrid(records, Theme.of(context)),
      ),
    );
  }

  Widget _buildErrorState(Object error, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Error loading medical records',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
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

  Widget _buildRecordsGrid(List<MedicalRecord> allRecords, ThemeData theme) {
    final filteredRecords = _filterRecords(allRecords);

    if (filteredRecords.isEmpty) {
      return _buildEmptyState(theme);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: StaggerAnimations.staggeredList(
        children: filteredRecords.map((record) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: MedicalRecordCard(
              record: record,
              onTap: () => _navigateToRecordDetail(record),
              onEdit: () => _navigateToEditRecord(record),
              onDelete: () => _showDeleteConfirmation(record),
            ),
          );
        }).toList(),
        staggerDelay: AppTheme.microDuration,
        direction: StaggerDirection.bottomToTop,
        animationType: StaggerAnimationType.fadeSlide,
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    final hasFilters =
        _searchQuery.isNotEmpty ||
        _selectedRecordType != 'All' ||
        _selectedProfileId != null ||
        _dateRange != null;

    return SingleChildScrollView(
      child: Center(
        child: CommonTransitions.fadeSlideIn(
          child: ModernCard(
            elevation: CardElevation.low,
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    hasFilters
                        ? Icons.search_off_rounded
                        : Icons.medical_information_rounded,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  hasFilters ? 'No records found' : 'No medical records yet',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  hasFilters
                      ? 'Try adjusting your search or filters to find more records'
                      : 'Add your first medical record to start tracking your health data',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                if (!hasFilters)
                  HealthButton(
                    onPressed: () => _showAddRecordOptions(context),
                    medicalTheme: MedicalButtonTheme.success,
                    size: HealthButtonSize.medium,
                    enableHoverEffect: true,
                    enablePressEffect: true,
                    enableHaptics: true,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Add First Record',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<MedicalRecord> _filterRecords(List<MedicalRecord> records) {
    var filteredRecords = records;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredRecords = filteredRecords.where((record) {
        final titleMatch = record.title.toLowerCase().contains(
          _searchQuery.toLowerCase(),
        );
        final descriptionMatch =
            record.description?.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ??
            false;
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
        return record.recordDate.isAfter(
              _dateRange!.start.subtract(const Duration(days: 1)),
            ) &&
            record.recordDate.isBefore(
              _dateRange!.end.add(const Duration(days: 1)),
            );
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
    // Get the currently selected profile from global state
    final profileState = ref.read(profileNotifierProvider);
    final selectedProfile = profileState.selectedProfile;
    final profileId = _selectedProfileId ?? selectedProfile?.id;

    if (profileId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a profile first')),
      );
      return;
    }

    switch (recordType) {
      case 'prescription':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PrescriptionFormScreen(profileId: profileId),
          ),
        );
        break;
      case 'medication':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MedicationFormScreen(profileId: profileId),
          ),
        );
        break;
      case 'lab_report':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LabReportFormScreen(profileId: profileId),
          ),
        );
        break;
    }
  }

  void _navigateToRecordDetail(MedicalRecord record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MedicalRecordDetailScreen(recordId: record.id, record: record),
      ),
    );
  }

  void _navigateToEditRecord(MedicalRecord record) {
    switch (record.recordType.toLowerCase()) {
      case 'prescription':
        // Note: PrescriptionFormScreen would need to be updated to accept a prescription parameter for editing
        _navigateToRecordDetail(record);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Prescription editing will be available in next update',
            ),
          ),
        );
        break;
      case 'medication':
        // Note: MedicationFormScreen would need to be updated to accept a medication parameter for editing
        _navigateToRecordDetail(record);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Medication editing will be available in next update',
            ),
          ),
        );
        break;
      case 'lab_report':
        // Note: LabReportFormScreen would need to be updated to accept a lab report parameter for editing
        _navigateToRecordDetail(record);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Lab report editing will be available in next update',
            ),
          ),
        );
        break;
      default:
        _navigateToRecordDetail(record);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${record.recordType} editing not yet supported'),
          ),
        );
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
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteRecord(record);
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

  Future<void> _deleteRecord(MedicalRecord record) async {
    try {
      final service = ref.read(medicalRecordsServiceProvider);
      await service.deleteRecord(record.id);

      // Refresh providers
      ref.invalidate(allMedicalRecordsProvider);
      ref.invalidate(recordsByProfileIdProvider(record.profileId));
      if (_selectedRecordType != 'All') {
        ref.invalidate(recordsByTypeProvider(_selectedRecordType));
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${record.title} deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete record: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
