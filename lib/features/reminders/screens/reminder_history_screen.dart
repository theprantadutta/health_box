import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../../../data/repositories/medication_adherence_dao.dart';
import '../../../shared/theme/design_system.dart';
import '../../../shared/widgets/hb_card.dart';
import '../../../shared/widgets/hb_chip.dart';
import '../../../shared/widgets/hb_loading.dart';
import '../../../shared/widgets/hb_button.dart';
import '../services/medication_adherence_service.dart';
import '../widgets/adherence_statistics_widget.dart';
import '../widgets/adherence_calendar_widget.dart';
import '../widgets/adherence_list_widget.dart';

/// Screen showing medication adherence history and statistics
class ReminderHistoryScreen extends ConsumerStatefulWidget {
  final String? profileId;
  final String? medicationId;

  const ReminderHistoryScreen({
    super.key,
    this.profileId,
    this.medicationId,
  });

  @override
  ConsumerState<ReminderHistoryScreen> createState() => _ReminderHistoryScreenState();
}

class _ReminderHistoryScreenState extends ConsumerState<ReminderHistoryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late MedicationAdherenceService _adherenceService;

  DateTime _selectedStartDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _selectedEndDate = DateTime.now();
  String? _selectedMedicationFilter;
  String? _selectedStatusFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _adherenceService = MedicationAdherenceService();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Medication History',
          style: TextStyle(
            color: Colors.white,
            fontWeight: AppTypography.fontWeightBold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: HealthBoxDesignSystem.chronicConditionGradient,
            boxShadow: AppElevation.coloredShadow(
              HealthBoxDesignSystem.chronicConditionGradient.colors.first,
              opacity: 0.3,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list, color: Colors.white),
            tooltip: 'Filter records',
          ),
          IconButton(
            onPressed: _showDateRangePicker,
            icon: const Icon(Icons.date_range, color: Colors.white),
            tooltip: 'Select date range',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Calendar', icon: Icon(Icons.calendar_today)),
            Tab(text: 'History', icon: Icon(Icons.list)),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildDateRangeHeader(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildCalendarTab(),
                _buildHistoryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeHeader() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(
            color: context.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.date_range,
            size: AppSizes.iconSm,
            color: context.colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: AppSpacing.sm),
          Text(
            '${_selectedStartDate.toString().substring(0, 10)} - ${_selectedEndDate.toString().substring(0, 10)}',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          if (_selectedMedicationFilter != null || _selectedStatusFilter != null)
            HBChip.filter(
              label: 'Filtered',
              onDeleted: _clearFilters,
            ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return FutureBuilder<AdherenceStatistics>(
      future: _getAdherenceStatistics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const HBLoading.circular();
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        }

        final stats = snapshot.data!;
        return SingleChildScrollView(
          padding: context.responsivePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AdherenceStatisticsWidget(
                statistics: stats,
                dateRange: DateRange(_selectedStartDate, _selectedEndDate),
              ),
              SizedBox(height: AppSpacing.xl),
              _buildQuickStatsCards(stats),
              SizedBox(height: AppSpacing.xl),
              _buildTrendsChart(stats),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalendarTab() {
    return FutureBuilder<List<MedicationAdherenceData>>(
      future: _getAdherenceRecords(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const HBLoading.circular();
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        }

        final records = snapshot.data ?? [];
        return AdherenceCalendarWidget(
          adherenceRecords: records,
          startDate: _selectedStartDate,
          endDate: _selectedEndDate,
          onDateSelected: _onCalendarDateSelected,
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    return FutureBuilder<List<MedicationAdherenceData>>(
      future: _getAdherenceRecords(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const HBLoading.circular();
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        }

        final records = snapshot.data ?? [];

        if (records.isEmpty) {
          return _buildEmptyState();
        }

        return AdherenceListWidget(
          adherenceRecords: records,
          onRecordTapped: _onAdherenceRecordTapped,
        );
      },
    );
  }

  Widget _buildQuickStatsCards(AdherenceStatistics stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'On Time',
            '${(stats.onTimeRate * 100).toInt()}%',
            stats.takenCount,
            Icons.check_circle,
            AppColors.success,
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildStatCard(
            'Late',
            '${(stats.lateRate * 100).toInt()}%',
            stats.takenLateCount,
            Icons.schedule,
            AppColors.warning,
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildStatCard(
            'Missed',
            '${(stats.missedRate * 100).toInt()}%',
            stats.missedCount,
            Icons.cancel,
            AppColors.error,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String percentage,
    int count,
    IconData icon,
    Color color,
  ) {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: AppSizes.iconSm),
              SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            percentage,
            style: context.textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: AppTypography.fontWeightBold,
            ),
          ),
          Text(
            '$count doses',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsChart(AdherenceStatistics stats) {
    // Placeholder for trends chart - could be implemented with fl_chart package
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Adherence Trends',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: AppTypography.fontWeightBold,
            ),
          ),
          SizedBox(height: AppSpacing.base),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: const Center(
              child: Text('Chart coming soon'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: context.responsivePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: AppSizes.iconXl * 1.5,
              color: AppColors.error,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Error loading data',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: AppTypography.fontWeightBold,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              error,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.lg),
            HBButton.primary(
              text: 'Retry',
              onPressed: () => setState(() {}),
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: context.responsivePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medication,
              size: AppSizes.iconXl * 1.5,
              color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'No medication records',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: AppTypography.fontWeightBold,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Take your medications to start tracking adherence',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<AdherenceStatistics> _getAdherenceStatistics() async {
    if (widget.medicationId != null) {
      return await _adherenceService.getMedicationAdherenceStats(
        widget.medicationId!,
        fromDate: _selectedStartDate,
        toDate: _selectedEndDate,
      );
    } else if (widget.profileId != null) {
      return await _adherenceService.getProfileAdherenceStats(
        widget.profileId!,
        fromDate: _selectedStartDate,
        toDate: _selectedEndDate,
      );
    } else {
      // Get all records - would need current profile context
      return await _adherenceService.getProfileAdherenceStats(
        'current_profile', // Placeholder - should come from context
        fromDate: _selectedStartDate,
        toDate: _selectedEndDate,
      );
    }
  }

  Future<List<MedicationAdherenceData>> _getAdherenceRecords() async {
    if (widget.medicationId != null) {
      return await _adherenceService.getMedicationAdherence(
        widget.medicationId!,
        fromDate: _selectedStartDate,
        toDate: _selectedEndDate,
      );
    } else if (widget.profileId != null) {
      return await _adherenceService.getProfileAdherence(
        widget.profileId!,
        fromDate: _selectedStartDate,
        toDate: _selectedEndDate,
      );
    } else {
      return await _adherenceService.getProfileAdherence(
        'current_profile', // Placeholder
        fromDate: _selectedStartDate,
        toDate: _selectedEndDate,
      );
    }
  }

  Future<void> _showDateRangePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _selectedStartDate,
        end: _selectedEndDate,
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedStartDate = picked.start;
        _selectedEndDate = picked.end;
      });
    }
  }

  Future<void> _showFilterDialog() async {
    // Show filter options dialog
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Medication filter
            // Status filter
            // Add filter UI here
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // Apply filters
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedMedicationFilter = null;
      _selectedStatusFilter = null;
    });
  }

  void _onCalendarDateSelected(DateTime date) {
    // Handle calendar date selection
    // Could show detailed view for that date
  }

  void _onAdherenceRecordTapped(MedicationAdherenceData record) {
    // Handle adherence record tap
    // Could show detailed view or edit options
  }
}
