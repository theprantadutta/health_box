import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/database/app_database.dart';
import '../../../shared/animations/common_transitions.dart';
import '../../../shared/providers/medical_records_providers.dart';
import '../../../shared/providers/profile_providers.dart';
import '../../../shared/theme/design_system.dart';
import '../../../shared/widgets/hb_button.dart';
import '../../../shared/widgets/hb_card.dart';
import '../../../shared/widgets/hb_chip.dart';
import '../../../shared/widgets/hb_list_tile.dart';
import '../../../shared/widgets/hb_state_widgets.dart';
import '../../../shared/widgets/hb_text_field.dart';
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
  final TextEditingController _searchController = TextEditingController();
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surfaceContainerLowest,
      body: CustomScrollView(
        slivers: [
          // App Bar with gradient
          SliverAppBar(
            floating: true,
            snap: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                boxShadow: AppElevation.coloredShadow(
                  AppColors.primary,
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
                icon: Icon(
                  Icons.group_work_rounded,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                onPressed: () =>
                    context.push('/medical-records/medication-batches'),
                tooltip: 'Medication Batches',
              ),
              IconButton(
                icon: Icon(
                  Icons.tune_rounded,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                onPressed: _showFilterBottomSheet,
                tooltip: 'Filter Records',
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.add_rounded,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                onSelected: _onAddRecordSelected,
                itemBuilder: (context) => _buildAddMenuItems(context),
              ),
              SizedBox(width: AppSpacing.sm),
            ],
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(context.responsivePadding),
              child: HBTextField.filled(
                controller: _searchController,
                hint: 'Search medical records...',
                prefixIcon: Icons.search_rounded,
                onChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                },
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
        icon: Icon(Icons.add_rounded, size: AppSizes.iconMd),
        label: Text(
          'Add Record',
          style: TextStyle(
            fontWeight: AppTypography.fontWeightSemiBold,
            fontSize: AppTypography.fontSizeSm,
          ),
        ),
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildAddMenuItems(BuildContext context) {
    final items = [
      _MenuItem('prescription', 'Add Prescription', Icons.medication),
      _MenuItem('medication', 'Add Medication', Icons.medical_services),
      _MenuItem('lab_report', 'Add Lab Report', Icons.science),
      _MenuItem('vaccination', 'Add Vaccination', Icons.vaccines),
      _MenuItem('allergy', 'Add Allergy', Icons.warning),
      _MenuItem(
        'chronic_condition',
        'Add Chronic Condition',
        Icons.health_and_safety,
      ),
      _MenuItem(
        'surgical_record',
        'Add Surgical Record',
        Icons.medical_services,
      ),
      _MenuItem(
        'radiology_record',
        'Add Radiology Record',
        Icons.medical_information,
      ),
      _MenuItem('pathology_record', 'Add Pathology Record', Icons.biotech),
      _MenuItem(
        'discharge_summary',
        'Add Discharge Summary',
        Icons.exit_to_app,
      ),
      _MenuItem(
        'hospital_admission',
        'Add Hospital Admission',
        Icons.local_hospital,
      ),
      _MenuItem('dental_record', 'Add Dental Record', Icons.healing),
      _MenuItem(
        'mental_health_record',
        'Add Mental Health Record',
        Icons.psychology,
      ),
      _MenuItem('general_record', 'Add General Record', Icons.description),
    ];

    return items
        .map(
          (item) => PopupMenuItem<String>(
            value: item.value,
            child: Row(
              children: [
                Icon(item.icon),
                SizedBox(width: AppSpacing.sm),
                Text(item.label),
              ],
            ),
          ),
        )
        .toList();
  }

  Widget _buildRecordsList() {
    final recordsAsync = _selectedProfileId != null
        ? ref.watch(recordsByProfileIdProvider(_selectedProfileId!))
        : ref.watch(allMedicalRecordsProvider);

    return recordsAsync.when(
      loading: () => SliverFillRemaining(
        child: CommonTransitions.fadeSlideIn(
          child: HBLoading.large(
            message: 'Loading medical records...',
          ),
        ),
      ),
      error: (error, stack) => SliverFillRemaining(
        child: HBErrorState(
          error: error,
          onRetry: () {
            ref.invalidate(allMedicalRecordsProvider);
            if (_selectedProfileId != null) {
              ref.invalidate(recordsByProfileIdProvider);
            }
          },
        ),
      ),
      data: (records) => _buildRecordsGrid(records),
    );
  }

  Widget _buildRecordsGrid(List<MedicalRecord> allRecords) {
    final filteredRecords = _filterRecords(allRecords);

    if (filteredRecords.isEmpty) {
      return SliverFillRemaining(
        child: _buildEmptyState(),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        context.responsivePadding,
        AppSpacing.sm,
        context.responsivePadding,
        AppSpacing.xl2 * 4,
      ),
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

  Widget _buildEmptyState() {
    final hasFilters = _searchQuery.isNotEmpty ||
        _selectedRecordType != 'All' ||
        _selectedProfileId != null ||
        _dateRange != null;

    return Center(
      child: CommonTransitions.fadeSlideIn(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl2),
          child: hasFilters
              ? HBEmptyState.noSearchResults(query: _searchQuery)
              : HBEmptyState.noRecords(
                  onAddRecord: () => _showAddRecordOptions(context),
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
        final titleMatch =
            record.title.toLowerCase().contains(_searchQuery.toLowerCase());
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
        return record.recordDate
                .isAfter(_dateRange!.start.subtract(const Duration(days: 1))) &&
            record.recordDate
                .isBefore(_dateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    // Sort by date (newest first)
    filteredRecords.sort((a, b) => b.recordDate.compareTo(a.recordDate));

    return filteredRecords;
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadii.xl2),
            ),
            boxShadow: AppElevation.shadow(
              AppElevation.level5,
              isDark: context.isDark,
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: AppSizes.xl,
                height: 4,
                margin: EdgeInsets.only(
                  top: AppSpacing.md,
                  bottom: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: context.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(AppRadii.xs),
                ),
              ),

              // Header
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.sm,
                  AppSpacing.xl,
                  AppSpacing.base,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: AppRadii.radiusMd,
                        boxShadow: AppElevation.coloredShadow(
                          AppColors.primary,
                          opacity: 0.3,
                        ),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: Colors.white,
                        size: AppSizes.iconLg,
                      ),
                    ),
                    SizedBox(width: AppSpacing.base),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Filter Records',
                            style: context.textTheme.titleLarge?.copyWith(
                              fontWeight: AppTypography.fontWeightBold,
                              color: context.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Customize your view',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    HBButton.text(
                      onPressed: () {
                        setState(() {
                          _selectedRecordType = 'All';
                          _selectedProfileId = null;
                          _dateRange = null;
                        });
                        context.pop();
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              ),

              HBDivider(),

              // Filters content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.all(AppSpacing.xl),
                  children: [
                    // Record Type Filter
                    HBSectionHeader(
                      title: 'Record Type',
                      padding: EdgeInsets.only(bottom: AppSpacing.md),
                    ),
                    HBChipGroup.multiSelect(
                      labels: _recordTypes,
                      selectedIndices: {_recordTypes.indexOf(_selectedRecordType)},
                      onChanged: (selected) {
                        if (selected.isNotEmpty) {
                          setState(() {
                            _selectedRecordType =
                                _recordTypes[selected.first];
                          });
                        }
                      },
                    ),

                    SizedBox(height: AppSpacing.xl),

                    // Profile Filter
                    HBSectionHeader(
                      title: 'Profile',
                      padding: EdgeInsets.only(bottom: AppSpacing.md),
                    ),
                    _buildProfileFilterSection(),

                    SizedBox(height: AppSpacing.xl),

                    // Date Range Filter
                    HBSectionHeader(
                      title: 'Date Range',
                      padding: EdgeInsets.only(bottom: AppSpacing.md),
                    ),
                    _buildDateRangeSection(),
                  ],
                ),
              ),

              // Apply button
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: SizedBox(
                    width: double.infinity,
                    child: HBButton.primary(
                      onPressed: () => context.pop(),
                      size: HBButtonSize.large,
                      child: const Text('Apply Filters'),
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

  Widget _buildProfileFilterSection() {
    final profilesAsync = ref.watch(allProfilesProvider);

    return profilesAsync.when(
      loading: () => HBLoading.small(),
      error: (error, stack) => Text(
        'Error loading profiles',
        style: TextStyle(color: context.colorScheme.error),
      ),
      data: (profiles) {
        if (profiles.isEmpty) {
          return Text(
            'No profiles available',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          );
        }

        final labels = ['All Profiles', ...profiles.map((p) => '${p.firstName} ${p.lastName}')];
        final selectedIndex = _selectedProfileId == null
            ? 0
            : profiles.indexWhere((p) => p.id == _selectedProfileId) + 1;

        return HBChipGroup.singleSelect(
          labels: labels,
          selectedIndex: selectedIndex,
          onSelected: (index) {
            setState(() {
              _selectedProfileId = index == 0 ? null : profiles[index - 1].id;
            });
          },
        );
      },
    );
  }

  Widget _buildDateRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_dateRange != null)
          HBCard.flat(
            padding: EdgeInsets.all(AppSpacing.base),
            borderColor: context.colorScheme.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      size: AppSizes.iconSm,
                      color: context.colorScheme.primary,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'From: ${_dateRange!.start.day}/${_dateRange!.start.month}/${_dateRange!.start.year}',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.primary,
                        fontWeight: AppTypography.fontWeightSemiBold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      size: AppSizes.iconSm,
                      color: context.colorScheme.primary,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'To: ${_dateRange!.end.day}/${_dateRange!.end.month}/${_dateRange!.end.year}',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.primary,
                        fontWeight: AppTypography.fontWeightSemiBold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: HBButton.outline(
                onPressed: _selectDateRange,
                icon: Icons.date_range_rounded,
                child: Text(_dateRange != null ? 'Change Range' : 'Select Range'),
              ),
            ),
            if (_dateRange != null) ...[
              SizedBox(width: AppSpacing.md),
              HBButton.destructive(
                onPressed: () {
                  setState(() {
                    _dateRange = null;
                  });
                },
                size: HBButtonSize.medium,
                child: Icon(Icons.close_rounded, size: AppSizes.iconSm),
              ),
            ],
          ],
        ),
      ],
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadii.lg),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(AppSpacing.base),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: AppSizes.xl,
                height: 4,
                margin: EdgeInsets.only(bottom: AppSpacing.base),
                decoration: BoxDecoration(
                  color: context.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppRadii.xs),
                ),
              ),
              Text(
                'Add New Medical Record',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: AppTypography.fontWeightBold,
                ),
              ),
              SizedBox(height: AppSpacing.base),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    HBListTile.icon(
                      icon: Icons.medication,
                      title: 'Prescription',
                      subtitle: 'Add prescription details',
                      onTap: () {
                        context.pop();
                        _onAddRecordSelected('prescription');
                      },
                    ),
                    HBListTile.icon(
                      icon: Icons.medical_services,
                      title: 'Medication',
                      subtitle: 'Track medication intake',
                      onTap: () {
                        context.pop();
                        _onAddRecordSelected('medication');
                      },
                    ),
                    HBListTile.icon(
                      icon: Icons.science,
                      title: 'Lab Report',
                      subtitle: 'Upload lab test results',
                      onTap: () {
                        context.pop();
                        _onAddRecordSelected('lab_report');
                      },
                    ),
                    HBListTile.icon(
                      icon: Icons.vaccines,
                      title: 'Vaccination',
                      subtitle: 'Record vaccination details',
                      onTap: () {
                        context.pop();
                        _onAddRecordSelected('vaccination');
                      },
                    ),
                    HBListTile.icon(
                      icon: Icons.warning,
                      title: 'Allergy',
                      subtitle: 'Document allergy information',
                      onTap: () {
                        context.pop();
                        _onAddRecordSelected('allergy');
                      },
                    ),
                    HBListTile.icon(
                      icon: Icons.health_and_safety,
                      title: 'Chronic Condition',
                      subtitle: 'Track chronic health conditions',
                      onTap: () {
                        context.pop();
                        _onAddRecordSelected('chronic_condition');
                      },
                    ),
                    HBListTile.icon(
                      icon: Icons.medical_services,
                      title: 'Surgical Record',
                      subtitle: 'Document surgical procedures',
                      onTap: () {
                        context.pop();
                        _onAddRecordSelected('surgical_record');
                      },
                    ),
                    HBListTile.icon(
                      icon: Icons.medical_information,
                      title: 'Radiology Record',
                      subtitle: 'Add imaging and radiology reports',
                      onTap: () {
                        context.pop();
                        _onAddRecordSelected('radiology_record');
                      },
                    ),
                    HBListTile.icon(
                      icon: Icons.biotech,
                      title: 'Pathology Record',
                      subtitle: 'Document pathology reports',
                      onTap: () {
                        context.pop();
                        _onAddRecordSelected('pathology_record');
                      },
                    ),
                    HBListTile.icon(
                      icon: Icons.exit_to_app,
                      title: 'Discharge Summary',
                      subtitle: 'Hospital discharge documentation',
                      onTap: () {
                        context.pop();
                        _onAddRecordSelected('discharge_summary');
                      },
                    ),
                    HBListTile.icon(
                      icon: Icons.local_hospital,
                      title: 'Hospital Admission',
                      subtitle: 'Record hospital admission details',
                      onTap: () {
                        context.pop();
                        _onAddRecordSelected('hospital_admission');
                      },
                    ),
                    HBListTile.icon(
                      icon: Icons.healing,
                      title: 'Dental Record',
                      subtitle: 'Track dental procedures and checkups',
                      onTap: () {
                        context.pop();
                        _onAddRecordSelected('dental_record');
                      },
                    ),
                    HBListTile.icon(
                      icon: Icons.psychology,
                      title: 'Mental Health Record',
                      subtitle: 'Document therapy and mental health',
                      onTap: () {
                        context.pop();
                        _onAddRecordSelected('mental_health_record');
                      },
                    ),
                    HBListTile.icon(
                      icon: Icons.description,
                      title: 'General Record',
                      subtitle: 'Other medical documentation',
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
    final profileState = ref.read(profileNotifierProvider);
    final selectedProfile = profileState.selectedProfile;
    final profileId = _selectedProfileId ?? selectedProfile?.id;

    if (profileId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a profile first')),
      );
      return;
    }

    final routes = {
      'prescription': '/medical-records/prescription/form',
      'medication': '/medical-records/medication/form',
      'lab_report': '/medical-records/lab-report/form',
      'vaccination': '/medical-records/vaccination/form',
      'allergy': '/medical-records/allergy/form',
      'chronic_condition': '/medical-records/chronic-condition/form',
      'surgical_record': '/medical-records/surgical-record/form',
      'radiology_record': '/medical-records/radiology-record/form',
      'pathology_record': '/medical-records/pathology-record/form',
      'discharge_summary': '/medical-records/discharge-summary/form',
      'hospital_admission': '/medical-records/hospital-admission/form',
      'dental_record': '/medical-records/dental-record/form',
      'mental_health_record': '/medical-records/mental-health-record/form',
      'general_record': '/medical-records/general-record/form',
    };

    final route = routes[recordType];
    if (route != null) {
      context.push('$route?profileId=$profileId');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$recordType form not implemented yet'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _navigateToRecordDetail(MedicalRecord record) {
    context.push('/medical-records/detail/${record.id}');
  }

  void _navigateToEditRecord(MedicalRecord record) {
    _navigateToRecordDetail(record);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${record.recordType} editing will be available in next update',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.radiusMd,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(MedicalRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.radiusLg,
        ),
        title: const Text('Delete Record'),
        content: Text(
          'Are you sure you want to delete "${record.title}"? This action cannot be undone.',
        ),
        actions: [
          HBButton.text(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          HBButton.destructive(
            onPressed: () async {
              context.pop();
              await _deleteRecord(record);
            },
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${record.title} deleted successfully'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadii.radiusMd,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete record: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadii.radiusMd,
            ),
          ),
        );
      }
    }
  }
}

class _MenuItem {
  final String value;
  final String label;
  final IconData icon;

  _MenuItem(this.value, this.label, this.icon);
}
