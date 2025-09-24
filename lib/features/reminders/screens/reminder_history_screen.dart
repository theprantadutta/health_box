import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../../../data/repositories/medication_adherence_dao.dart';
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
        title: const Text('Medication History'),
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter records',
          ),
          IconButton(
            onPressed: _showDateRangePicker,
            icon: const Icon(Icons.date_range),
            tooltip: 'Select date range',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
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
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.date_range,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            '${_selectedStartDate.toString().substring(0, 10)} - ${_selectedEndDate.toString().substring(0, 10)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          if (_selectedMedicationFilter != null || _selectedStatusFilter != null)
            Chip(
              label: Text(
                'Filtered',
                style: TextStyle(fontSize: 12),
              ),
              deleteIcon: const Icon(Icons.close, size: 16),
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
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
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
                  'Error loading statistics',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final stats = snapshot.data!;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AdherenceStatisticsWidget(
                statistics: stats,
                dateRange: DateRange(_selectedStartDate, _selectedEndDate),
              ),
              const SizedBox(height: 24),
              _buildQuickStatsCards(stats),
              const SizedBox(height: 24),
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
          return const Center(child: CircularProgressIndicator());
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
          return const Center(child: CircularProgressIndicator());
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
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Late',
            '${(stats.lateRate * 100).toInt()}%',
            stats.takenLateCount,
            Icons.schedule,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Missed',
            '${(stats.missedRate * 100).toInt()}%',
            stats.missedCount,
            Icons.cancel,
            Colors.red,
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
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              percentage,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$count doses',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendsChart(AdherenceStatistics stats) {
    // Placeholder for trends chart - could be implemented with fl_chart package
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Adherence Trends',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('Chart coming soon'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
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
            'Error loading data',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => setState(() {}),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medication,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No medication records',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Take your medications to start tracking adherence',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
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