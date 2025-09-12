import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../services/analytics_service.dart';

class VitalsChartWidget extends StatefulWidget {
  final List<VitalReading> readings;
  final VitalType vitalType;
  final TimeRange timeRange;
  final bool showNormalRange;
  final double? height;

  const VitalsChartWidget({
    super.key,
    required this.readings,
    required this.vitalType,
    required this.timeRange,
    this.showNormalRange = true,
    this.height,
  });

  @override
  State<VitalsChartWidget> createState() => _VitalsChartWidgetState();
}

class _VitalsChartWidgetState extends State<VitalsChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.readings.isEmpty) {
      return SizedBox(
        height: widget.height ?? 300,
        child: const Center(
          child: Text(
            'No data to display',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      height: widget.height ?? 300,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Chart header
              _buildChartHeader(),
              const SizedBox(height: 16),
              
              // Chart
              Expanded(
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return _buildChart();
                  },
                ),
              ),
              
              // Chart legend
              if (widget.showNormalRange) ...[
                const SizedBox(height: 16),
                _buildLegend(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartHeader() {
    final service = AnalyticsService();
    final displayName = service.getVitalTypeDisplayName(widget.vitalType);
    final unit = service.getVitalTypeUnit(widget.vitalType);
    
    return Row(
      children: [
        Icon(_getVitalTypeIcon(widget.vitalType), size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _getTimeRangeText(),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        if (widget.readings.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Latest',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '${widget.readings.last.displayValue} $unit',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildChart() {
    return widget.vitalType == VitalType.bloodPressure
        ? _buildBloodPressureChart()
        : _buildLineChart();
  }

  Widget _buildLineChart() {
    final spots = _generateSpots();
    final normalRange = VitalReading.getNormalRanges(widget.vitalType);
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _calculateGridInterval(),
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withValues(alpha: 0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: _calculateTimeInterval(),
              getTitlesWidget: (value, meta) {
                return _buildTimeLabel(value);
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            left: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
            bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots.map((spot) => FlSpot(
              spot.x,
              spot.y * _animation.value,
            )).toList(),
            isCurved: true,
            curveSmoothness: 0.1,
            color: _getVitalTypeColor(widget.vitalType),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: _getVitalTypeColor(widget.vitalType),
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: _getVitalTypeColor(widget.vitalType).withValues(alpha: 0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => Colors.black87,
            tooltipPadding: const EdgeInsets.all(8),
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final reading = widget.readings[barSpot.spotIndex];
                return LineTooltipItem(
                  '${reading.displayValue}\n${_formatDate(reading.timestamp)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
        extraLinesData: widget.showNormalRange && normalRange != null
            ? _buildNormalRangeLines(normalRange)
            : null,
        minY: _calculateMinY(),
        maxY: _calculateMaxY(),
      ),
    );
  }

  Widget _buildBloodPressureChart() {
    final systolicSpots = <FlSpot>[];
    final diastolicSpots = <FlSpot>[];
    
    for (int i = 0; i < widget.readings.length; i++) {
      final reading = widget.readings[i];
      final x = i.toDouble();
      
      systolicSpots.add(FlSpot(x, reading.value));
      if (reading.secondaryValue != null) {
        diastolicSpots.add(FlSpot(x, reading.secondaryValue!));
      }
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withValues(alpha: 0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: _calculateTimeInterval(),
              getTitlesWidget: (value, meta) {
                return _buildTimeLabel(value);
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            left: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
            bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
          ),
        ),
        lineBarsData: [
          // Systolic pressure line
          LineChartBarData(
            spots: systolicSpots.map((spot) => FlSpot(
              spot.x,
              spot.y * _animation.value,
            )).toList(),
            isCurved: true,
            curveSmoothness: 0.1,
            color: Colors.red,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.red,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
          ),
          // Diastolic pressure line
          if (diastolicSpots.isNotEmpty)
            LineChartBarData(
              spots: diastolicSpots.map((spot) => FlSpot(
                spot.x,
                spot.y * _animation.value,
              )).toList(),
              isCurved: true,
              curveSmoothness: 0.1,
              color: Colors.blue,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.blue,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
            ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => Colors.black87,
            tooltipPadding: const EdgeInsets.all(8),
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              final reading = widget.readings[touchedBarSpots.first.spotIndex];
              return [
                LineTooltipItem(
                  '${reading.displayValue}\n${_formatDate(reading.timestamp)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ];
            },
          ),
        ),
        extraLinesData: widget.showNormalRange
            ? _buildBloodPressureNormalRangeLines()
            : null,
        minY: 40,
        maxY: 200,
      ),
    );
  }

  Widget _buildLegend() {
    if (widget.vitalType == VitalType.bloodPressure) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem('Systolic', Colors.red),
          const SizedBox(width: 24),
          _buildLegendItem('Diastolic', Colors.blue),
          if (widget.showNormalRange) ...[
            const SizedBox(width: 24),
            _buildLegendItem('Normal Range', Colors.green.withValues(alpha: 0.3)),
          ],
        ],
      );
    } else if (widget.showNormalRange) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem(
            AnalyticsService().getVitalTypeDisplayName(widget.vitalType),
            _getVitalTypeColor(widget.vitalType),
          ),
          const SizedBox(width: 24),
          _buildLegendItem('Normal Range', Colors.green.withValues(alpha: 0.3)),
        ],
      );
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  List<FlSpot> _generateSpots() {
    final spots = <FlSpot>[];
    
    for (int i = 0; i < widget.readings.length; i++) {
      final reading = widget.readings[i];
      spots.add(FlSpot(i.toDouble(), reading.value));
    }
    
    return spots;
  }

  ExtraLinesData? _buildNormalRangeLines(Map<String, double> normalRange) {
    final minNormal = normalRange['min'];
    final maxNormal = normalRange['max'];
    
    if (minNormal == null || maxNormal == null) return null;
    
    return ExtraLinesData(
      horizontalLines: [
        HorizontalLine(
          y: minNormal,
          color: Colors.green.withValues(alpha: 0.5),
          strokeWidth: 2,
          dashArray: [5, 5],
        ),
        HorizontalLine(
          y: maxNormal,
          color: Colors.green.withValues(alpha: 0.5),
          strokeWidth: 2,
          dashArray: [5, 5],
        ),
      ],
    );
  }

  ExtraLinesData _buildBloodPressureNormalRangeLines() {
    return ExtraLinesData(
      horizontalLines: [
        // Normal systolic range
        HorizontalLine(
          y: 130,
          color: Colors.green.withValues(alpha: 0.5),
          strokeWidth: 2,
          dashArray: [5, 5],
        ),
        // Normal diastolic range  
        HorizontalLine(
          y: 85,
          color: Colors.green.withValues(alpha: 0.5),
          strokeWidth: 2,
          dashArray: [5, 5],
        ),
      ],
    );
  }

  Widget _buildTimeLabel(double value) {
    final index = value.toInt();
    if (index < 0 || index >= widget.readings.length) {
      return const Text('');
    }
    
    final reading = widget.readings[index];
    final date = reading.timestamp;
    
    String label;
    switch (widget.timeRange) {
      case TimeRange.week:
        label = '${date.day}/${date.month}';
        break;
      case TimeRange.month:
        label = '${date.day}/${date.month}';
        break;
      case TimeRange.threeMonths:
      case TimeRange.sixMonths:
        label = '${date.month}/${date.year.toString().substring(2)}';
        break;
      case TimeRange.year:
      case TimeRange.all:
        label = '${date.month}/${date.year.toString().substring(2)}';
        break;
    }
    
    return Text(
      label,
      style: const TextStyle(fontSize: 10),
    );
  }

  String _getTimeRangeText() {
    switch (widget.timeRange) {
      case TimeRange.week:
        return 'Last 7 days';
      case TimeRange.month:
        return 'Last 30 days';
      case TimeRange.threeMonths:
        return 'Last 3 months';
      case TimeRange.sixMonths:
        return 'Last 6 months';
      case TimeRange.year:
        return 'Last year';
      case TimeRange.all:
        return 'All time';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  double _calculateGridInterval() {
    if (widget.readings.isEmpty) return 10;
    
    final values = widget.readings.map((r) => r.value).toList();
    final min = values.reduce(math.min);
    final max = values.reduce(math.max);
    final range = max - min;
    
    if (range <= 10) return 2;
    if (range <= 50) return 10;
    if (range <= 100) return 20;
    return 50;
  }

  double _calculateTimeInterval() {
    final count = widget.readings.length;
    if (count <= 7) return 1;
    if (count <= 30) return count / 5;
    return count / 7;
  }

  double _calculateMinY() {
    if (widget.readings.isEmpty) return 0;
    
    if (widget.vitalType == VitalType.bloodPressure) {
      return 40; // Fixed minimum for blood pressure
    }
    
    final values = widget.readings.map((r) => r.value).toList();
    final min = values.reduce(math.min);
    final range = values.reduce(math.max) - min;
    
    return math.max(0, min - range * 0.1);
  }

  double _calculateMaxY() {
    if (widget.readings.isEmpty) return 100;
    
    if (widget.vitalType == VitalType.bloodPressure) {
      return 200; // Fixed maximum for blood pressure
    }
    
    final values = widget.readings.map((r) => r.value).toList();
    final max = values.reduce(math.max);
    final min = values.reduce(math.min);
    final range = max - min;
    
    return max + range * 0.1;
  }

  Color _getVitalTypeColor(VitalType type) {
    switch (type) {
      case VitalType.bloodPressure:
        return Colors.red;
      case VitalType.heartRate:
        return Colors.pink;
      case VitalType.temperature:
        return Colors.orange;
      case VitalType.weight:
        return Colors.purple;
      case VitalType.height:
        return Colors.indigo;
      case VitalType.bloodSugar:
        return Colors.teal;
      case VitalType.cholesterol:
        return Colors.amber;
      case VitalType.oxygenSaturation:
        return Colors.cyan;
      case VitalType.respiratoryRate:
        return Colors.lightGreen;
      case VitalType.bmi:
        return Colors.deepOrange;
    }
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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}