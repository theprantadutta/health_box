import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/theme/design_system.dart';
import '../services/analytics_service.dart';
import '../widgets/vitals_chart_widget.dart';

class VitalsTrackingScreen extends ConsumerStatefulWidget {
  final String profileId;

  const VitalsTrackingScreen({super.key, required this.profileId});

  @override
  ConsumerState<VitalsTrackingScreen> createState() =>
      _VitalsTrackingScreenState();
}

class _VitalsTrackingScreenState extends ConsumerState<VitalsTrackingScreen>
    with TickerProviderStateMixin {
  final AnalyticsService _analyticsService = AnalyticsService();

  // UI State
  VitalType _selectedVitalType = VitalType.bloodPressure;
  TimeRange _selectedTimeRange = TimeRange.month;
  bool _isLoading = false;
  bool _showAddForm = false;

  // Data
  VitalStatistics? _statistics;
  List<VitalReading> _readings = [];
  Map<VitalType, VitalStatistics> _allStatistics = {};

  // Form controllers
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _secondaryValueController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Animation
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      // Load readings for selected vital type and time range
      final readings = await _analyticsService.getVitalReadings(
        profileId: widget.profileId,
        type: _selectedVitalType,
        timeRange: _selectedTimeRange,
      );

      // Load statistics
      final statistics = await _analyticsService.getVitalStatistics(
        profileId: widget.profileId,
        type: _selectedVitalType,
        timeRange: _selectedTimeRange,
      );

      // Load all statistics for overview
      final allStats = await _analyticsService.getAllVitalStatistics(
        profileId: widget.profileId,
        timeRange: _selectedTimeRange,
      );

      if (mounted) {
        setState(() {
          _readings = readings;
          _statistics = statistics;
          _allStatistics = allStats;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vitals Tracking', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: HealthBoxDesignSystem.vitalsGradient,
            boxShadow: [
              BoxShadow(
                color: HealthBoxDesignSystem.vitalsGradient.colors.first.withValues(alpha: 0.3),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.timeline), text: 'Charts'),
            Tab(icon: Icon(Icons.analytics), text: 'Statistics'),
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _loadData),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildChartsTab(),
                _buildStatisticsTab(),
                _buildOverviewTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _showAddForm = true),
        child: const Icon(Icons.add),
      ),
      bottomSheet: _showAddForm ? _buildAddVitalForm() : null,
    );
  }

  Widget _buildChartsTab() {
    return Column(
      children: [
        // Vital type and time range selectors
        _buildSelectors(),

        // Chart
        Expanded(
          child: _readings.isEmpty
              ? _buildEmptyState()
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: VitalsChartWidget(
                    readings: _readings,
                    vitalType: _selectedVitalType,
                    timeRange: _selectedTimeRange,
                  ),
                ),
        ),

        // Recent readings list
        if (_readings.isNotEmpty) _buildRecentReadings(),
      ],
    );
  }

  Widget _buildStatisticsTab() {
    if (_statistics == null || _statistics!.totalReadings == 0) {
      return _buildEmptyState();
    }

    final stats = _statistics!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Vital type selector
          _buildVitalTypeSelector(),
          const SizedBox(height: 16),

          // Summary cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Readings',
                  '${stats.totalReadings}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Average',
                  stats.average.toStringAsFixed(1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Minimum',
                  stats.minimum.toStringAsFixed(1),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Maximum',
                  stats.maximum.toStringAsFixed(1),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Trend analysis
          _buildTrendCard(stats.trend),

          const SizedBox(height: 16),

          // Status distribution
          _buildStatusDistributionCard(stats.statusDistribution),

          const SizedBox(height: 16),

          // Detailed readings
          _buildDetailedReadingsList(stats.readings.take(10).toList()),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    if (_allStatistics.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Time range selector
          _buildTimeRangeSelector(),
          const SizedBox(height: 16),

          // Overview cards for each vital type
          for (final entry in _allStatistics.entries) ...[
            _buildVitalOverviewCard(entry.key, entry.value),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectors() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Vital type selector
          _buildVitalTypeSelector(),
          const SizedBox(height: 12),
          // Time range selector
          _buildTimeRangeSelector(),
        ],
      ),
    );
  }

  Widget _buildVitalTypeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: DropdownButtonFormField<VitalType>(
          initialValue: _selectedVitalType,
          decoration: const InputDecoration(
            labelText: 'Vital Sign',
            border: InputBorder.none,
          ),
          items: VitalType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Row(
                children: [
                  Icon(_getVitalTypeIcon(type), size: 20),
                  const SizedBox(width: 8),
                  Text(_analyticsService.getVitalTypeDisplayName(type)),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedVitalType = value;
              });
              _loadData();
            }
          },
        ),
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: DropdownButtonFormField<TimeRange>(
          initialValue: _selectedTimeRange,
          decoration: const InputDecoration(
            labelText: 'Time Range',
            border: InputBorder.none,
          ),
          items: TimeRange.values.map((range) {
            return DropdownMenuItem(
              value: range,
              child: Text(_getTimeRangeDisplayName(range)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedTimeRange = value;
              });
              _loadData();
            }
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getVitalTypeIcon(_selectedVitalType),
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No ${_analyticsService.getVitalTypeDisplayName(_selectedVitalType).toLowerCase()} data',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the + button to add your first reading',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentReadings() {
    final recentReadings = _readings.take(3).toList();

    return Container(
      height: 120,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Readings',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recentReadings.length,
              itemBuilder: (context, index) {
                final reading = recentReadings[index];
                return Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 8),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            reading.displayValue,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            reading.unit ?? '',
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${reading.timestamp.day}/${reading.timestamp.month}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendCard(VitalTrend trend) {
    Color trendColor;
    IconData trendIcon;

    switch (trend.direction) {
      case TrendDirection.increasing:
        trendColor = Colors.red;
        trendIcon = Icons.trending_up;
        break;
      case TrendDirection.decreasing:
        trendColor = Colors.green;
        trendIcon = Icons.trending_down;
        break;
      case TrendDirection.volatile:
        trendColor = Colors.orange;
        trendIcon = Icons.swap_vert;
        break;
      case TrendDirection.stable:
        trendColor = Colors.blue;
        trendIcon = Icons.trending_flat;
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(trendIcon, color: trendColor),
                const SizedBox(width: 8),
                const Text(
                  'Trend Analysis',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(trend.summary),
            const SizedBox(height: 8),
            if (trend.changePercent != 0)
              Text(
                '${trend.changePercent > 0 ? '+' : ''}${trend.changePercent.toStringAsFixed(1)}% change',
                style: TextStyle(
                  color: trendColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDistributionCard(Map<VitalStatus, int> distribution) {
    final total = distribution.values.fold(0, (sum, count) => sum + count);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reading Status Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            for (final entry in distribution.entries) ...[
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getStatusColor(entry.key),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(_getStatusDisplayName(entry.key)),
                  const Spacer(),
                  Text(
                    '${entry.value} (${(entry.value / total * 100).toStringAsFixed(1)}%)',
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedReadingsList(List<VitalReading> readings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Detailed Readings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            for (final reading in readings) ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reading.displayValue +
                              (reading.unit != null ? ' ${reading.unit}' : ''),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${reading.timestamp.day}/${reading.timestamp.month}/${reading.timestamp.year} '
                          '${reading.timestamp.hour.toString().padLeft(2, '0')}:'
                          '${reading.timestamp.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        reading.status,
                      ).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusDisplayName(reading.status),
                      style: TextStyle(
                        color: _getStatusColor(reading.status),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (reading != readings.last) const Divider(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVitalOverviewCard(VitalType type, VitalStatistics stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(_getVitalTypeIcon(type)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _analyticsService.getVitalTypeDisplayName(type),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getTrendColor(
                      stats.trend.direction,
                    ).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getTrendIcon(stats.trend.direction),
                        size: 12,
                        color: _getTrendColor(stats.trend.direction),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        stats.trend.direction.name,
                        style: TextStyle(
                          color: _getTrendColor(stats.trend.direction),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Latest',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        stats.readings.isNotEmpty
                            ? stats.readings.last.displayValue
                            : 'N/A',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Average',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        stats.average.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Readings',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        '${stats.totalReadings}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
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

  Widget _buildAddVitalForm() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Add Vital Reading',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _showAddForm = false),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Vital type dropdown
          DropdownButtonFormField<VitalType>(
            initialValue: _selectedVitalType,
            decoration: const InputDecoration(
              labelText: 'Vital Sign',
              border: OutlineInputBorder(),
            ),
            items: VitalType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(_analyticsService.getVitalTypeDisplayName(type)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedVitalType = value);
              }
            },
          ),
          const SizedBox(height: 16),

          // Value inputs
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _valueController,
                  decoration: InputDecoration(
                    labelText: _selectedVitalType == VitalType.bloodPressure
                        ? 'Systolic'
                        : 'Value',
                    border: const OutlineInputBorder(),
                    suffixText: _analyticsService.getVitalTypeUnit(
                      _selectedVitalType,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              if (_selectedVitalType == VitalType.bloodPressure) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _secondaryValueController,
                    decoration: const InputDecoration(
                      labelText: 'Diastolic',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Notes
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _clearForm();
                    setState(() => _showAddForm = false);
                  },
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveVitalReading,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _saveVitalReading() async {
    final value = double.tryParse(_valueController.text);
    if (value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid value'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    double? secondaryValue;
    if (_selectedVitalType == VitalType.bloodPressure) {
      secondaryValue = double.tryParse(_secondaryValueController.text);
      if (secondaryValue == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter valid blood pressure values'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    try {
      final reading = VitalReading(
        id: const Uuid().v4(),
        profileId: widget.profileId,
        type: _selectedVitalType,
        value: value,
        secondaryValue: secondaryValue,
        unit: _analyticsService.getVitalTypeUnit(_selectedVitalType),
        timestamp: DateTime.now(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      await _analyticsService.addVitalReading(reading);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vital reading saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        _clearForm();
        setState(() => _showAddForm = false);
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save reading: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearForm() {
    _valueController.clear();
    _secondaryValueController.clear();
    _notesController.clear();
  }

  IconData _getVitalTypeIcon(VitalType type) {
    switch (type) {
      case VitalType.bloodPressure:
        return Icons.favorite;
      case VitalType.heartRate:
        return Icons.monitor_heart;
      case VitalType.temperature:
        return Icons.thermostat;
      case VitalType.weight:
        return Icons.monitor_weight;
      case VitalType.height:
        return Icons.height;
      case VitalType.bloodSugar:
        return Icons.bloodtype;
      case VitalType.cholesterol:
        return Icons.science;
      case VitalType.oxygenSaturation:
        return Icons.air;
      case VitalType.respiratoryRate:
        return Icons.air;
      case VitalType.bmi:
        return Icons.calculate;
    }
  }

  String _getTimeRangeDisplayName(TimeRange range) {
    switch (range) {
      case TimeRange.week:
        return 'Last Week';
      case TimeRange.month:
        return 'Last Month';
      case TimeRange.threeMonths:
        return 'Last 3 Months';
      case TimeRange.sixMonths:
        return 'Last 6 Months';
      case TimeRange.year:
        return 'Last Year';
      case TimeRange.all:
        return 'All Time';
    }
  }

  Color _getStatusColor(VitalStatus status) {
    switch (status) {
      case VitalStatus.low:
        return Colors.blue;
      case VitalStatus.normal:
        return Colors.green;
      case VitalStatus.high:
        return Colors.red;
    }
  }

  String _getStatusDisplayName(VitalStatus status) {
    switch (status) {
      case VitalStatus.low:
        return 'Low';
      case VitalStatus.normal:
        return 'Normal';
      case VitalStatus.high:
        return 'High';
    }
  }

  Color _getTrendColor(TrendDirection direction) {
    switch (direction) {
      case TrendDirection.increasing:
        return Colors.red;
      case TrendDirection.decreasing:
        return Colors.green;
      case TrendDirection.stable:
        return Colors.blue;
      case TrendDirection.volatile:
        return Colors.orange;
    }
  }

  IconData _getTrendIcon(TrendDirection direction) {
    switch (direction) {
      case TrendDirection.increasing:
        return Icons.trending_up;
      case TrendDirection.decreasing:
        return Icons.trending_down;
      case TrendDirection.stable:
        return Icons.trending_flat;
      case TrendDirection.volatile:
        return Icons.swap_vert;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _valueController.dispose();
    _secondaryValueController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
