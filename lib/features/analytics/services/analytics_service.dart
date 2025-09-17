import 'dart:math' as math;

import 'package:logger/logger.dart';

enum VitalType {
  bloodPressure,
  heartRate,
  temperature,
  weight,
  height,
  bloodSugar,
  cholesterol,
  oxygenSaturation,
  respiratoryRate,
  bmi,
}

enum TimeRange { week, month, threeMonths, sixMonths, year, all }

enum TrendDirection { increasing, decreasing, stable, volatile }

class VitalReading {
  final String id;
  final String profileId;
  final VitalType type;
  final double value;
  final double? secondaryValue; // For blood pressure (diastolic)
  final String? unit;
  final DateTime timestamp;
  final String? notes;
  final Map<String, dynamic>? metadata;

  VitalReading({
    required this.id,
    required this.profileId,
    required this.type,
    required this.value,
    this.secondaryValue,
    this.unit,
    required this.timestamp,
    this.notes,
    this.metadata,
  });

  factory VitalReading.fromJson(Map<String, dynamic> json) {
    return VitalReading(
      id: json['id'] as String,
      profileId: json['profileId'] as String,
      type: VitalType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => VitalType.heartRate,
      ),
      value: (json['value'] as num).toDouble(),
      secondaryValue: json['secondaryValue'] != null
          ? (json['secondaryValue'] as num).toDouble()
          : null,
      unit: json['unit'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      notes: json['notes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'profileId': profileId,
    'type': type.name,
    'value': value,
    'secondaryValue': secondaryValue,
    'unit': unit,
    'timestamp': timestamp.toIso8601String(),
    'notes': notes,
    'metadata': metadata,
  };

  String get displayValue {
    if (secondaryValue != null) {
      return '${value.toInt()}/${secondaryValue!.toInt()}';
    }
    return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1);
  }

  bool isNormal() {
    final ranges = getNormalRanges(type);
    if (ranges == null) return true;

    switch (type) {
      case VitalType.bloodPressure:
        return value <= ranges['systolic_max']! &&
            value >= ranges['systolic_min']! &&
            (secondaryValue == null ||
                (secondaryValue! <= ranges['diastolic_max']! &&
                    secondaryValue! >= ranges['diastolic_min']!));
      default:
        return value >= ranges['min']! && value <= ranges['max']!;
    }
  }

  VitalStatus get status {
    if (isNormal()) return VitalStatus.normal;

    final ranges = getNormalRanges(type);
    if (ranges == null) return VitalStatus.normal;

    switch (type) {
      case VitalType.bloodPressure:
        if (value > ranges['systolic_max']! ||
            (secondaryValue != null &&
                secondaryValue! > ranges['diastolic_max']!)) {
          return VitalStatus.high;
        }
        return VitalStatus.low;
      default:
        return value > ranges['max']! ? VitalStatus.high : VitalStatus.low;
    }
  }

  static Map<String, double>? getNormalRanges(VitalType type) {
    switch (type) {
      case VitalType.bloodPressure:
        return {
          'systolic_min': 90,
          'systolic_max': 130,
          'diastolic_min': 60,
          'diastolic_max': 85,
        };
      case VitalType.heartRate:
        return {'min': 60, 'max': 100};
      case VitalType.temperature:
        return {'min': 36.1, 'max': 37.2}; // Celsius
      case VitalType.oxygenSaturation:
        return {'min': 95, 'max': 100};
      case VitalType.respiratoryRate:
        return {'min': 12, 'max': 20};
      case VitalType.bloodSugar:
        return {'min': 70, 'max': 140}; // mg/dL, fasting
      default:
        return null; // Weight, height, BMI, cholesterol vary by person
    }
  }
}

enum VitalStatus { low, normal, high }

class VitalTrend {
  final VitalType type;
  final TrendDirection direction;
  final double changePercent;
  final double averageValue;
  final int readingCount;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String summary;

  VitalTrend({
    required this.type,
    required this.direction,
    required this.changePercent,
    required this.averageValue,
    required this.readingCount,
    required this.periodStart,
    required this.periodEnd,
    required this.summary,
  });
}

class VitalStatistics {
  final VitalType type;
  final int totalReadings;
  final double average;
  final double minimum;
  final double maximum;
  final double standardDeviation;
  final VitalTrend trend;
  final List<VitalReading> readings;
  final Map<VitalStatus, int> statusDistribution;

  VitalStatistics({
    required this.type,
    required this.totalReadings,
    required this.average,
    required this.minimum,
    required this.maximum,
    required this.standardDeviation,
    required this.trend,
    required this.readings,
    required this.statusDistribution,
  });
}

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final Logger _logger = Logger();

  // In-memory cache for performance
  final Map<String, List<VitalReading>> _readingsCache = {};
  DateTime? _lastCacheUpdate;
  static const Duration _cacheValidityDuration = Duration(minutes: 5);

  Future<List<VitalReading>> getVitalReadings({
    required String profileId,
    VitalType? type,
    TimeRange timeRange = TimeRange.all,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final cacheKey = _getCacheKey(
        profileId,
        type,
        timeRange,
        startDate,
        endDate,
      );

      // Check cache first
      if (_isValidCache() && _readingsCache.containsKey(cacheKey)) {
        return _readingsCache[cacheKey]!;
      }

      // Calculate date range
      final dateRange = _calculateDateRange(timeRange, startDate, endDate);

      // In a real implementation, this would query the database
      // For now, we'll simulate with some sample data
      final readings = await _fetchReadingsFromDatabase(
        profileId,
        type,
        dateRange.start,
        dateRange.end,
      );

      // Cache the results
      _readingsCache[cacheKey] = readings;
      _lastCacheUpdate = DateTime.now();

      return readings;
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to get vital readings',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  Future<VitalReading> addVitalReading(VitalReading reading) async {
    try {
      // In a real implementation, this would save to database
      // For now, we'll simulate saving
      _logger.d(
        'Adding vital reading: ${reading.type.name} = ${reading.displayValue}',
      );

      // Clear cache to force refresh
      _clearCache();

      return reading;
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to add vital reading',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<bool> updateVitalReading(VitalReading reading) async {
    try {
      // In a real implementation, this would update in database
      _logger.d('Updating vital reading: ${reading.id}');

      // Clear cache to force refresh
      _clearCache();

      return true;
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to update vital reading',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<bool> deleteVitalReading(String readingId) async {
    try {
      // In a real implementation, this would delete from database
      _logger.d('Deleting vital reading: $readingId');

      // Clear cache to force refresh
      _clearCache();

      return true;
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to delete vital reading',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<VitalStatistics> getVitalStatistics({
    required String profileId,
    required VitalType type,
    TimeRange timeRange = TimeRange.month,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final readings = await getVitalReadings(
        profileId: profileId,
        type: type,
        timeRange: timeRange,
        startDate: startDate,
        endDate: endDate,
      );

      if (readings.isEmpty) {
        return VitalStatistics(
          type: type,
          totalReadings: 0,
          average: 0,
          minimum: 0,
          maximum: 0,
          standardDeviation: 0,
          trend: VitalTrend(
            type: type,
            direction: TrendDirection.stable,
            changePercent: 0,
            averageValue: 0,
            readingCount: 0,
            periodStart: DateTime.now(),
            periodEnd: DateTime.now(),
            summary: 'No data available',
          ),
          readings: [],
          statusDistribution: {},
        );
      }

      final values = readings.map((r) => r.value).toList();
      final average = values.reduce((a, b) => a + b) / values.length;
      final minimum = values.reduce(math.min);
      final maximum = values.reduce(math.max);

      // Calculate standard deviation
      final variance =
          values.map((v) => math.pow(v - average, 2)).reduce((a, b) => a + b) /
          values.length;
      final standardDeviation = math.sqrt(variance);

      // Calculate trend
      final trend = _calculateTrend(readings, type);

      // Calculate status distribution
      final statusDistribution = <VitalStatus, int>{};
      for (final reading in readings) {
        final status = reading.status;
        statusDistribution[status] = (statusDistribution[status] ?? 0) + 1;
      }

      return VitalStatistics(
        type: type,
        totalReadings: readings.length,
        average: average,
        minimum: minimum,
        maximum: maximum,
        standardDeviation: standardDeviation,
        trend: trend,
        readings: readings,
        statusDistribution: statusDistribution,
      );
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to get vital statistics',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<Map<VitalType, VitalStatistics>> getAllVitalStatistics({
    required String profileId,
    TimeRange timeRange = TimeRange.month,
  }) async {
    final statistics = <VitalType, VitalStatistics>{};

    for (final type in VitalType.values) {
      try {
        final stats = await getVitalStatistics(
          profileId: profileId,
          type: type,
          timeRange: timeRange,
        );

        if (stats.totalReadings > 0) {
          statistics[type] = stats;
        }
      } catch (e) {
        _logger.w('Failed to get statistics for ${type.name}', error: e);
      }
    }

    return statistics;
  }

  Future<List<VitalReading>> getAnomalousReadings({
    required String profileId,
    TimeRange timeRange = TimeRange.month,
  }) async {
    final anomalousReadings = <VitalReading>[];

    for (final type in VitalType.values) {
      final readings = await getVitalReadings(
        profileId: profileId,
        type: type,
        timeRange: timeRange,
      );

      final abnormalReadings = readings.where((r) => !r.isNormal()).toList();
      anomalousReadings.addAll(abnormalReadings);
    }

    // Sort by timestamp (newest first)
    anomalousReadings.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return anomalousReadings;
  }

  Future<Map<String, dynamic>> generateHealthReport({
    required String profileId,
    TimeRange timeRange = TimeRange.month,
  }) async {
    try {
      final allStats = await getAllVitalStatistics(
        profileId: profileId,
        timeRange: timeRange,
      );

      final anomalousReadings = await getAnomalousReadings(
        profileId: profileId,
        timeRange: timeRange,
      );

      final report = <String, dynamic>{
        'profileId': profileId,
        'generatedAt': DateTime.now().toIso8601String(),
        'timeRange': timeRange.name,
        'summary': _generateReportSummary(allStats, anomalousReadings),
        'statistics': allStats.map(
          (type, stats) => MapEntry(type.name, {
            'totalReadings': stats.totalReadings,
            'average': stats.average,
            'trend': stats.trend.direction.name,
            'changePercent': stats.trend.changePercent,
            'statusDistribution': stats.statusDistribution.map(
              (status, count) => MapEntry(status.name, count),
            ),
          }),
        ),
        'anomalousReadings': anomalousReadings.length,
        'recommendations': _generateRecommendations(
          allStats,
          anomalousReadings,
        ),
      };

      return report;
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to generate health report',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  VitalTrend _calculateTrend(List<VitalReading> readings, VitalType type) {
    if (readings.length < 2) {
      return VitalTrend(
        type: type,
        direction: TrendDirection.stable,
        changePercent: 0,
        averageValue: readings.isNotEmpty ? readings.first.value : 0,
        readingCount: readings.length,
        periodStart: readings.isNotEmpty
            ? readings.first.timestamp
            : DateTime.now(),
        periodEnd: readings.isNotEmpty
            ? readings.last.timestamp
            : DateTime.now(),
        summary: 'Insufficient data for trend analysis',
      );
    }

    // Sort by timestamp
    readings.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final firstHalf = readings.take(readings.length ~/ 2).toList();
    final secondHalf = readings.skip(readings.length ~/ 2).toList();

    final firstAvg =
        firstHalf.map((r) => r.value).reduce((a, b) => a + b) /
        firstHalf.length;
    final secondAvg =
        secondHalf.map((r) => r.value).reduce((a, b) => a + b) /
        secondHalf.length;

    final changePercent = ((secondAvg - firstAvg) / firstAvg) * 100;
    final overallAvg =
        readings.map((r) => r.value).reduce((a, b) => a + b) / readings.length;

    TrendDirection direction;
    String summary;

    if (changePercent.abs() < 5) {
      direction = TrendDirection.stable;
      summary = 'Values remain stable';
    } else if (changePercent > 15) {
      direction = TrendDirection.volatile;
      summary = 'Values show high volatility';
    } else if (changePercent > 0) {
      direction = TrendDirection.increasing;
      summary = 'Values trending upward';
    } else {
      direction = TrendDirection.decreasing;
      summary = 'Values trending downward';
    }

    return VitalTrend(
      type: type,
      direction: direction,
      changePercent: changePercent,
      averageValue: overallAvg,
      readingCount: readings.length,
      periodStart: readings.first.timestamp,
      periodEnd: readings.last.timestamp,
      summary: summary,
    );
  }

  String _generateReportSummary(
    Map<VitalType, VitalStatistics> stats,
    List<VitalReading> anomalousReadings,
  ) {
    if (stats.isEmpty) {
      return 'No vital signs data available for this period.';
    }

    final totalReadings = stats.values.fold(
      0,
      (sum, stat) => sum + stat.totalReadings,
    );
    final vitalsTracked = stats.length;
    final anomalousCount = anomalousReadings.length;

    String summary =
        'Tracked $vitalsTracked vital signs with $totalReadings total readings. ';

    if (anomalousCount == 0) {
      summary += 'All readings are within normal ranges.';
    } else {
      summary += '$anomalousCount readings were outside normal ranges.';
    }

    return summary;
  }

  List<String> _generateRecommendations(
    Map<VitalType, VitalStatistics> stats,
    List<VitalReading> anomalousReadings,
  ) {
    final recommendations = <String>[];

    if (anomalousReadings.isEmpty) {
      recommendations.add('Continue monitoring your vital signs regularly');
      recommendations.add('Maintain your current healthy lifestyle');
    } else {
      recommendations.add(
        'Consult with your healthcare provider about abnormal readings',
      );
      recommendations.add(
        'Consider increasing monitoring frequency for concerning values',
      );
    }

    // Type-specific recommendations
    for (final entry in stats.entries) {
      final type = entry.key;
      final stat = entry.value;

      if (stat.statusDistribution[VitalStatus.high] != null &&
          stat.statusDistribution[VitalStatus.high]! >
              stat.totalReadings * 0.3) {
        switch (type) {
          case VitalType.bloodPressure:
            recommendations.add(
              'Consider reducing sodium intake and increasing physical activity',
            );
            break;
          case VitalType.heartRate:
            recommendations.add(
              'Monitor heart rate during physical activity and rest',
            );
            break;
          case VitalType.weight:
            recommendations.add(
              'Consider consulting a nutritionist for weight management',
            );
            break;
          case VitalType.bloodSugar:
            recommendations.add(
              'Monitor blood sugar levels more frequently and review diet',
            );
            break;
          default:
            break;
        }
      }
    }

    return recommendations;
  }

  Future<List<VitalReading>> _fetchReadingsFromDatabase(
    String profileId,
    VitalType? type,
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Simulate database query with sample data
    await Future.delayed(const Duration(milliseconds: 100));

    final readings = <VitalReading>[];
    final random = math.Random();
    final now = DateTime.now();

    // Generate sample data for demonstration
    for (int i = 0; i < 30; i++) {
      final timestamp = now.subtract(Duration(days: i));

      if (timestamp.isBefore(startDate) || timestamp.isAfter(endDate)) {
        continue;
      }

      final types = type != null ? [type] : VitalType.values.take(5);

      for (final vitalType in types) {
        switch (vitalType) {
          case VitalType.bloodPressure:
            readings.add(
              VitalReading(
                id: 'bp_${profileId}_$i',
                profileId: profileId,
                type: vitalType,
                value: 110 + random.nextDouble() * 40, // 110-150
                secondaryValue: 70 + random.nextDouble() * 20, // 70-90
                unit: 'mmHg',
                timestamp: timestamp,
              ),
            );
            break;
          case VitalType.heartRate:
            readings.add(
              VitalReading(
                id: 'hr_${profileId}_$i',
                profileId: profileId,
                type: vitalType,
                value: 60 + random.nextDouble() * 40, // 60-100
                unit: 'bpm',
                timestamp: timestamp,
              ),
            );
            break;
          case VitalType.weight:
            readings.add(
              VitalReading(
                id: 'wt_${profileId}_$i',
                profileId: profileId,
                type: vitalType,
                value: 70 + random.nextDouble() * 30, // 70-100
                unit: 'kg',
                timestamp: timestamp,
              ),
            );
            break;
          case VitalType.temperature:
            readings.add(
              VitalReading(
                id: 'temp_${profileId}_$i',
                profileId: profileId,
                type: vitalType,
                value: 36.0 + random.nextDouble() * 2, // 36-38
                unit: '°C',
                timestamp: timestamp,
              ),
            );
            break;
          case VitalType.bloodSugar:
            readings.add(
              VitalReading(
                id: 'bs_${profileId}_$i',
                profileId: profileId,
                type: vitalType,
                value: 80 + random.nextDouble() * 80, // 80-160
                unit: 'mg/dL',
                timestamp: timestamp,
              ),
            );
            break;
          default:
            break;
        }
      }
    }

    return readings;
  }

  ({DateTime start, DateTime end}) _calculateDateRange(
    TimeRange timeRange,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    final now = DateTime.now();

    if (startDate != null && endDate != null) {
      return (start: startDate, end: endDate);
    }

    switch (timeRange) {
      case TimeRange.week:
        return (start: now.subtract(const Duration(days: 7)), end: now);
      case TimeRange.month:
        return (start: now.subtract(const Duration(days: 30)), end: now);
      case TimeRange.threeMonths:
        return (start: now.subtract(const Duration(days: 90)), end: now);
      case TimeRange.sixMonths:
        return (start: now.subtract(const Duration(days: 180)), end: now);
      case TimeRange.year:
        return (start: now.subtract(const Duration(days: 365)), end: now);
      case TimeRange.all:
        return (start: DateTime(2020), end: now);
    }
  }

  String _getCacheKey(
    String profileId,
    VitalType? type,
    TimeRange timeRange,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    return '$profileId-${type?.name ?? 'all'}-${timeRange.name}-$startDate-$endDate';
  }

  bool _isValidCache() {
    if (_lastCacheUpdate == null) return false;
    return DateTime.now().difference(_lastCacheUpdate!) <
        _cacheValidityDuration;
  }

  void _clearCache() {
    _readingsCache.clear();
    _lastCacheUpdate = null;
  }

  String getVitalTypeDisplayName(VitalType type) {
    switch (type) {
      case VitalType.bloodPressure:
        return 'Blood Pressure';
      case VitalType.heartRate:
        return 'Heart Rate';
      case VitalType.temperature:
        return 'Temperature';
      case VitalType.weight:
        return 'Weight';
      case VitalType.height:
        return 'Height';
      case VitalType.bloodSugar:
        return 'Blood Sugar';
      case VitalType.cholesterol:
        return 'Cholesterol';
      case VitalType.oxygenSaturation:
        return 'Oxygen Saturation';
      case VitalType.respiratoryRate:
        return 'Respiratory Rate';
      case VitalType.bmi:
        return 'BMI';
    }
  }

  String getVitalTypeUnit(VitalType type) {
    switch (type) {
      case VitalType.bloodPressure:
        return 'mmHg';
      case VitalType.heartRate:
        return 'bpm';
      case VitalType.temperature:
        return '°C';
      case VitalType.weight:
        return 'kg';
      case VitalType.height:
        return 'cm';
      case VitalType.bloodSugar:
        return 'mg/dL';
      case VitalType.cholesterol:
        return 'mg/dL';
      case VitalType.oxygenSaturation:
        return '%';
      case VitalType.respiratoryRate:
        return 'breaths/min';
      case VitalType.bmi:
        return 'kg/m²';
    }
  }
}
