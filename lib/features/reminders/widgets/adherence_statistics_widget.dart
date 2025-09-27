import 'package:flutter/material.dart';

import '../../../data/repositories/medication_adherence_dao.dart';
import '../services/medication_adherence_service.dart';

/// Widget displaying comprehensive medication adherence statistics
class AdherenceStatisticsWidget extends StatelessWidget {
  final AdherenceStatistics statistics;
  final DateRange dateRange;

  const AdherenceStatisticsWidget({
    super.key,
    required this.statistics,
    required this.dateRange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Adherence Summary',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${dateRange.dayCount} days • ${statistics.totalRecords} doses',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            _buildOverallAdherence(context),
            const SizedBox(height: 20),
            _buildDetailedBreakdown(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallAdherence(BuildContext context) {
    final theme = Theme.of(context);
    final adherenceRate = statistics.adherenceRate;
    final adherencePercentage = (adherenceRate * 100).toInt();

    Color color;
    IconData icon;
    String status;

    if (adherenceRate >= 0.9) {
      color = Colors.green;
      icon = Icons.check_circle;
      status = 'Excellent';
    } else if (adherenceRate >= 0.8) {
      color = Colors.lightGreen;
      icon = Icons.thumb_up;
      status = 'Good';
    } else if (adherenceRate >= 0.7) {
      color = Colors.orange;
      icon = Icons.warning;
      status = 'Fair';
    } else {
      color = Colors.red;
      icon = Icons.error;
      status = 'Needs Improvement';
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    '$adherencePercentage%',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Overall Adherence',
                style: theme.textTheme.titleMedium,
              ),
              Text(
                status,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 120,
          height: 120,
          child: _buildCircularProgress(adherenceRate, color),
        ),
      ],
    );
  }

  Widget _buildCircularProgress(double value, Color color) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(
            value: value,
            strokeWidth: 8,
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        Text(
          '${(value * 100).toInt()}%',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedBreakdown(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detailed Breakdown',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildBreakdownRow(
          context,
          'Taken on Time',
          statistics.takenCount,
          statistics.totalRecords,
          Colors.green,
          Icons.check_circle_outline,
        ),
        _buildBreakdownRow(
          context,
          'Taken Late',
          statistics.takenLateCount,
          statistics.totalRecords,
          Colors.orange,
          Icons.schedule,
        ),
        _buildBreakdownRow(
          context,
          'Missed',
          statistics.missedCount,
          statistics.totalRecords,
          Colors.red,
          Icons.cancel_outlined,
        ),
        if (statistics.skippedCount > 0)
          _buildBreakdownRow(
            context,
            'Skipped',
            statistics.skippedCount,
            statistics.totalRecords,
            Colors.grey,
            Icons.skip_next,
          ),
        if (statistics.rescheduledCount > 0)
          _buildBreakdownRow(
            context,
            'Rescheduled',
            statistics.rescheduledCount,
            statistics.totalRecords,
            Colors.blue,
            Icons.update,
          ),
      ],
    );
  }

  Widget _buildBreakdownRow(
    BuildContext context,
    String label,
    int count,
    int total,
    Color color,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final percentage = total > 0 ? (count / total * 100) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Container(
            width: 60,
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: color.withValues(alpha: 0.2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: total > 0 ? count / total : 0.0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 60,
            child: Text(
              '$count (${percentage.toInt()}%)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}