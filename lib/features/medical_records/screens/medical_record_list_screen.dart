import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/database/app_database.dart';
import '../../../shared/animations/common_transitions.dart';
import '../../../shared/animations/micro_interactions.dart';
import '../../../shared/providers/medical_records_providers.dart';
import '../../../shared/providers/profile_providers.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/modern_card.dart';
import '../widgets/medical_record_card.dart';

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
    'Surgical Record',
    'Radiology Record',
    'Pathology Record',
    'Discharge Summary',
    'Hospital Admission',
    'Dental Record',
    'Mental Health Record',
    'General Record',
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
              const PopupMenuItem(
                value: 'vaccination',
                child: Row(
                  children: [
                    Icon(Icons.vaccines),
                    SizedBox(width: 8),
                    Text('Add Vaccination'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'allergy',
                child: Row(
                  children: [
                    Icon(Icons.warning),
                    SizedBox(width: 8),
                    Text('Add Allergy'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'chronic_condition',
                child: Row(
                  children: [
                    Icon(Icons.health_and_safety),
                    SizedBox(width: 8),
                    Text('Add Chronic Condition'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'surgical_record',
                child: Row(
                  children: [
                    Icon(Icons.medical_services),
                    SizedBox(width: 8),
                    Text('Add Surgical Record'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'radiology_record',
                child: Row(
                  children: [
                    Icon(Icons.medical_information),
                    SizedBox(width: 8),
                    Text('Add Radiology Record'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'pathology_record',
                child: Row(
                  children: [
                    Icon(Icons.biotech),
                    SizedBox(width: 8),
                    Text('Add Pathology Record'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'discharge_summary',
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app),
                    SizedBox(width: 8),
                    Text('Add Discharge Summary'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'hospital_admission',
                child: Row(
                  children: [
                    Icon(Icons.local_hospital),
                    SizedBox(width: 8),
                    Text('Add Hospital Admission'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'dental_record',
                child: Row(
                  children: [
                    Icon(Icons.healing),
                    SizedBox(width: 8),
                    Text('Add Dental Record'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'mental_health_record',
                child: Row(
                  children: [
                    Icon(Icons.psychology),
                    SizedBox(width: 8),
                    Text('Add Mental Health Record'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'general_record',
                child: Row(
                  children: [
                    Icon(Icons.description),
                    SizedBox(width: 8),
                    Text('Add General Record'),
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

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filteredRecords.length,
      itemBuilder: (context, index) {
        final record = filteredRecords[index];
        return MedicalRecordCard(
          record: record,
          onTap: () => _navigateToRecordDetail(record),
          onEdit: () => _navigateToEditRecord(record),
          onDelete: () => _showDeleteConfirmation(record),
        );
      },
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
      final filterType = _selectedRecordType.toLowerCase().replaceAll(' ', '_');
      filteredRecords = filteredRecords.where((record) {
        return record.recordType == filterType;
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
            onPressed: () => context.pop(),
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
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Add New Medical Record',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.medication),
                      title: const Text('Prescription'),
                      subtitle: const Text('Add prescription details'),
                      onTap: () {
                        context.pop();
                        _onAddRecordSelected('prescription');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.medical_services),
                      title: const Text('Medication'),
                      subtitle: const Text('Track medication intake'),
                      onTap: () {
                        context.pop();
                        _onAddRecordSelected('medication');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.science),
                      title: const Text('Lab Report'),
                      subtitle: const Text('Upload lab test results'),
                      onTap: () {
                        context.pop();
                        _onAddRecordSelected('lab_report');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.vaccines),
                      title: const Text('Vaccination'),
                      subtitle: const Text('Record vaccination details'),
                      onTap: () {
                        context.pop();
                        _onAddRecordSelected('vaccination');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.warning),
                      title: const Text('Allergy'),
                      subtitle: const Text('Document allergy information'),
                      onTap: () {
                        context.pop();
                        _onAddRecordSelected('allergy');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.health_and_safety),
                      title: const Text('Chronic Condition'),
                      subtitle: const Text('Track chronic health conditions'),
                      onTap: () {
                        context.pop();
                        _onAddRecordSelected('chronic_condition');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.medical_services),
                      title: const Text('Surgical Record'),
                      subtitle: const Text('Document surgical procedures'),
                      onTap: () {
                        context.pop();
                        _onAddRecordSelected('surgical_record');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.medical_information),
                      title: const Text('Radiology Record'),
                      subtitle: const Text('Add imaging and radiology reports'),
                      onTap: () {
                        context.pop();
                        _onAddRecordSelected('radiology_record');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.biotech),
                      title: const Text('Pathology Record'),
                      subtitle: const Text('Document pathology reports'),
                      onTap: () {
                        context.pop();
                        _onAddRecordSelected('pathology_record');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.exit_to_app),
                      title: const Text('Discharge Summary'),
                      subtitle: const Text('Hospital discharge documentation'),
                      onTap: () {
                        context.pop();
                        _onAddRecordSelected('discharge_summary');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.local_hospital),
                      title: const Text('Hospital Admission'),
                      subtitle: const Text('Record hospital admission details'),
                      onTap: () {
                        context.pop();
                        _onAddRecordSelected('hospital_admission');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.healing),
                      title: const Text('Dental Record'),
                      subtitle: const Text('Track dental procedures and checkups'),
                      onTap: () {
                        context.pop();
                        _onAddRecordSelected('dental_record');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.psychology),
                      title: const Text('Mental Health Record'),
                      subtitle: const Text('Document therapy and mental health'),
                      onTap: () {
                        context.pop();
                        _onAddRecordSelected('mental_health_record');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.description),
                      title: const Text('General Record'),
                      subtitle: const Text('Other medical documentation'),
                      onTap: () {
                        context.pop();
                        _onAddRecordSelected('general_record');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
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
        context.push('/medical-records/prescription/form?profileId=$profileId');
        break;
      case 'medication':
        context.push('/medical-records/medication/form?profileId=$profileId');
        break;
      case 'lab_report':
        context.push('/medical-records/lab-report/form?profileId=$profileId');
        break;
      case 'vaccination':
        context.push('/medical-records/vaccination/form?profileId=$profileId');
        break;
      case 'allergy':
        context.push('/medical-records/allergy/form?profileId=$profileId');
        break;
      case 'chronic_condition':
        context.push('/medical-records/chronic-condition/form?profileId=$profileId');
        break;
      case 'surgical_record':
        context.push('/medical-records/surgical-record/form?profileId=$profileId');
        break;
      case 'radiology_record':
        context.push('/medical-records/radiology-record/form?profileId=$profileId');
        break;
      case 'pathology_record':
        context.push('/medical-records/pathology-record/form?profileId=$profileId');
        break;
      case 'discharge_summary':
        context.push('/medical-records/discharge-summary/form?profileId=$profileId');
        break;
      case 'hospital_admission':
        context.push('/medical-records/hospital-admission/form?profileId=$profileId');
        break;
      case 'dental_record':
        context.push('/medical-records/dental-record/form?profileId=$profileId');
        break;
      case 'mental_health_record':
        context.push('/medical-records/mental-health-record/form?profileId=$profileId');
        break;
      case 'general_record':
        context.push('/medical-records/general-record/form?profileId=$profileId');
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$recordType form not implemented yet'),
            backgroundColor: Colors.red,
          ),
        );
    }
  }

  void _navigateToRecordDetail(MedicalRecord record) {
    context.push('/medical-records/detail/${record.id}');
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
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              context.pop();
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
