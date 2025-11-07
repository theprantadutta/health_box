import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/database/app_database.dart';
import '../../../shared/providers/medical_records_providers.dart';
import '../../../shared/providers/profile_providers.dart';
import '../../../shared/theme/design_system.dart';
import '../../../shared/widgets/hb_card.dart';
import '../../../shared/widgets/hb_button.dart';
import '../../../shared/widgets/hb_loading.dart';
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
    return Scaffold(
      backgroundColor: context.colorScheme.surfaceContainerLowest,
      body: CustomScrollView(
        slivers: [
          // Dashboard-style app bar
          SliverAppBar(
            floating: true,
            snap: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: HealthBoxDesignSystem.medicalBlue,
                boxShadow: AppElevation.coloredShadow(
                  HealthBoxDesignSystem.medicalBlue.colors.first,
                  opacity: 0.3,
                ),
              ),
            ),
            title: Text(
              'Medical Records',
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: AppTypography.fontWeightBold,
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.group_work_rounded,
                  color: Colors.white,
                ),
                onPressed: () => context.push('/medical-records/medication-batches'),
                tooltip: 'Medication Batches',
              ),
              IconButton(
                icon: const Icon(
                  Icons.tune_rounded,
                  color: Colors.white,
                ),
                onPressed: _showFilterBottomSheet,
                tooltip: 'Filter Records',
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                ),
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
          ),
          const SizedBox(width: 8),
        ],
      ),

          // Search Bar
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: TextField(
                onChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search medical records...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),

          // Records List
          _buildRecordsList(),
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


  Widget _buildRecordsList() {
    final recordsAsync = _selectedProfileId != null
        ? ref.watch(recordsByProfileIdProvider(_selectedProfileId!))
        : ref.watch(allMedicalRecordsProvider);

    return recordsAsync.when(
      loading: () => SliverFillRemaining(
        child: Center(
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
      ),
      error: (error, stack) => SliverFillRemaining(
        child: _buildErrorState(error, Theme.of(context)),
      ),
      data: (records) => _buildRecordsGrid(records, Theme.of(context)),
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
      return SliverFillRemaining(
        child: _buildEmptyState(theme),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final record = filteredRecords[index];
            return MedicalRecordCard(
              record: record,
              onTap: () => _navigateToRecordDetail(record),
              onEdit: () => _navigateToEditRecord(record),
              onDelete: () => _showDeleteConfirmation(record),
            );
          },
          childCount: filteredRecords.length,
        ),
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

  void _showFilterBottomSheet() {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: HealthBoxDesignSystem.medicalPurple,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: HealthBoxDesignSystem.coloredShadow(
                          HealthBoxDesignSystem.medicalPurple.colors.first,
                          opacity: 0.3,
                        ),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Filter Records',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Customize your view',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedRecordType = 'All';
                          _selectedProfileId = null;
                          _dateRange = null;
                        });
                        context.pop();
                      },
                      child: Text(
                        'Reset',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Filters content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Record Type Filter
                    _buildFilterSection(
                      theme,
                      'Record Type',
                      Icons.category_rounded,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _recordTypes.map((type) {
                          final isSelected = _selectedRecordType == type;
                          return FilterChip(
                            label: Text(type),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedRecordType = type;
                              });
                            },
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            selectedColor: theme.colorScheme.primaryContainer,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                            checkmarkColor: theme.colorScheme.primary,
                            side: BorderSide(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outlineVariant,
                              width: 1,
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Profile Filter
                    _buildFilterSection(
                      theme,
                      'Profile',
                      Icons.person_rounded,
                      child: _buildProfileFilterSection(theme),
                    ),

                    const SizedBox(height: 24),

                    // Date Range Filter
                    _buildFilterSection(
                      theme,
                      'Date Range',
                      Icons.calendar_today_rounded,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_dateRange != null)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month_rounded,
                                        size: 16,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'From: ${_dateRange!.start.day}/${_dateRange!.start.month}/${_dateRange!.start.year}',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month_rounded,
                                        size: 16,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'To: ${_dateRange!.end.day}/${_dateRange!.end.month}/${_dateRange!.end.year}',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _selectDateRange,
                                  icon: const Icon(Icons.date_range_rounded, size: 18),
                                  label: Text(_dateRange != null ? 'Change Range' : 'Select Range'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    side: BorderSide(color: theme.colorScheme.primary),
                                    foregroundColor: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                              if (_dateRange != null) ...[
                                const SizedBox(width: 12),
                                OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      _dateRange = null;
                                    });
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.all(12),
                                    side: BorderSide(color: theme.colorScheme.error),
                                    foregroundColor: theme.colorScheme.error,
                                  ),
                                  child: const Icon(Icons.close_rounded, size: 18),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Apply button
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(
    ThemeData theme,
    String title,
    IconData icon, {
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildProfileFilterSection(ThemeData theme) {
    final profilesAsync = ref.watch(allProfilesProvider);

    return profilesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text(
        'Error loading profiles',
        style: TextStyle(color: theme.colorScheme.error),
      ),
      data: (profiles) {
        if (profiles.isEmpty) {
          return Text(
            'No profiles available',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          );
        }

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: const Text('All Profiles'),
              selected: _selectedProfileId == null,
              onSelected: (selected) {
                setState(() {
                  _selectedProfileId = null;
                });
              },
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              selectedColor: theme.colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: _selectedProfileId == null
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
                fontWeight: _selectedProfileId == null ? FontWeight.w600 : FontWeight.w500,
              ),
              checkmarkColor: theme.colorScheme.primary,
              side: BorderSide(
                color: _selectedProfileId == null
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            ...profiles.map((profile) {
              final isSelected = _selectedProfileId == profile.id;
              return FilterChip(
                label: Text('${profile.firstName} ${profile.lastName}'),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedProfileId = profile.id;
                  });
                },
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                selectedColor: theme.colorScheme.primaryContainer,
                labelStyle: TextStyle(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                checkmarkColor: theme.colorScheme.primary,
                side: BorderSide(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant,
                  width: 1,
                ),
              );
            }),
          ],
        );
      },
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
