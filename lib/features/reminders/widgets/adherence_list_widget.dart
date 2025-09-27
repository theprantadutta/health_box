import 'package:flutter/material.dart';

import '../../../data/database/app_database.dart';
import '../../../data/models/medication_adherence.dart';

/// Widget displaying medication adherence records in a list format
class AdherenceListWidget extends StatefulWidget {
  final List<MedicationAdherenceData> adherenceRecords;
  final void Function(MedicationAdherenceData record)? onRecordTapped;

  const AdherenceListWidget({
    super.key,
    required this.adherenceRecords,
    this.onRecordTapped,
  });

  @override
  State<AdherenceListWidget> createState() => _AdherenceListWidgetState();
}

class _AdherenceListWidgetState extends State<AdherenceListWidget> {
  String _groupBy = 'date'; // 'date', 'medication', 'status'
  bool _showOnlyMissed = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilterControls(),
        Expanded(
          child: _buildRecordsList(),
        ),
      ],
    );
  }

  Widget _buildFilterControls() {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'View Options',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _groupBy,
                    decoration: const InputDecoration(
                      labelText: 'Group by',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'date', child: Text('Date')),
                      DropdownMenuItem(value: 'medication', child: Text('Medication')),
                      DropdownMenuItem(value: 'status', child: Text('Status')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _groupBy = value;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('Show only missed'),
                    value: _showOnlyMissed,
                    onChanged: (value) {
                      setState(() {
                        _showOnlyMissed = value ?? false;
                      });
                    },
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordsList() {
    final filteredRecords = _getFilteredRecords();
    final groupedRecords = _getGroupedRecords(filteredRecords);

    if (groupedRecords.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: groupedRecords.length,
      itemBuilder: (context, index) {
        final group = groupedRecords[index];
        return _buildGroupSection(group);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _showOnlyMissed ? Icons.check_circle : Icons.medication,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            _showOnlyMissed ? 'No missed medications!' : 'No records found',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            _showOnlyMissed
                ? 'Great job staying on track with your medications!'
                : 'Take your medications to start tracking adherence',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGroupSection(RecordGroup group) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getGroupIcon(),
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    group.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Chip(
                  label: Text('${group.records.length}'),
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                ),
              ],
            ),
          ),
          ...group.records.map((record) => _buildRecordTile(record)),
        ],
      ),
    );
  }

  Widget _buildRecordTile(MedicationAdherenceData record) {
    final theme = Theme.of(context);

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (record.status) {
      case MedicationAdherenceStatus.taken:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Taken on time';
        break;
      case MedicationAdherenceStatus.takenLate:
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        statusText = 'Taken late';
        break;
      case MedicationAdherenceStatus.missed:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Missed';
        break;
      case MedicationAdherenceStatus.skipped:
        statusColor = Colors.grey;
        statusIcon = Icons.skip_next;
        statusText = 'Skipped';
        break;
      case MedicationAdherenceStatus.rescheduled:
        statusColor = Colors.blue;
        statusIcon = Icons.update;
        statusText = 'Rescheduled';
        break;
      default:
        statusColor = theme.colorScheme.onSurfaceVariant;
        statusIcon = Icons.help;
        statusText = record.status;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: statusColor.withValues(alpha: 0.2),
        child: Icon(
          statusIcon,
          color: statusColor,
          size: 20,
        ),
      ),
      title: Text(
        record.medicationName,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${record.dosage}'),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                'Scheduled: ${_formatDateTime(record.scheduledTime)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (record.recordedTime != record.scheduledTime) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  Icons.done,
                  size: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Recorded: ${_formatDateTime(record.recordedTime)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
          if (record.notes != null && record.notes!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                record.notes!,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (record.status == MedicationAdherenceStatus.takenLate)
            Text(
              _getDelayText(record),
              style: theme.textTheme.bodySmall?.copyWith(
                color: statusColor,
                fontSize: 10,
              ),
            ),
        ],
      ),
      onTap: () => widget.onRecordTapped?.call(record),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  List<MedicationAdherenceData> _getFilteredRecords() {
    var records = widget.adherenceRecords;

    if (_showOnlyMissed) {
      records = records
          .where((r) => r.status == MedicationAdherenceStatus.missed)
          .toList();
    }

    return records;
  }

  List<RecordGroup> _getGroupedRecords(List<MedicationAdherenceData> records) {
    final groups = <RecordGroup>[];

    switch (_groupBy) {
      case 'date':
        final groupedByDate = <String, List<MedicationAdherenceData>>{};
        for (final record in records) {
          final dateKey = _formatDateKey(record.scheduledTime);
          groupedByDate.putIfAbsent(dateKey, () => []).add(record);
        }
        for (final entry in groupedByDate.entries) {
          entry.value.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
          groups.add(RecordGroup(entry.key, entry.value));
        }
        groups.sort((a, b) => b.title.compareTo(a.title)); // Most recent first
        break;

      case 'medication':
        final groupedByMedication = <String, List<MedicationAdherenceData>>{};
        for (final record in records) {
          groupedByMedication.putIfAbsent(record.medicationName, () => []).add(record);
        }
        for (final entry in groupedByMedication.entries) {
          entry.value.sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));
          groups.add(RecordGroup(entry.key, entry.value));
        }
        groups.sort((a, b) => a.title.compareTo(b.title));
        break;

      case 'status':
        final groupedByStatus = <String, List<MedicationAdherenceData>>{};
        for (final record in records) {
          final statusName = MedicationAdherenceStatus.getDisplayName(record.status);
          groupedByStatus.putIfAbsent(statusName, () => []).add(record);
        }
        for (final entry in groupedByStatus.entries) {
          entry.value.sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));
          groups.add(RecordGroup(entry.key, entry.value));
        }
        // Custom sort for status
        groups.sort((a, b) {
          final statusOrder = [
            'Taken on Time',
            'Taken Late',
            'Missed',
            'Skipped',
            'Rescheduled'
          ];
          return statusOrder.indexOf(a.title).compareTo(statusOrder.indexOf(b.title));
        });
        break;
    }

    return groups;
  }

  IconData _getGroupIcon() {
    switch (_groupBy) {
      case 'date':
        return Icons.calendar_today;
      case 'medication':
        return Icons.medication;
      case 'status':
        return Icons.info;
      default:
        return Icons.folder;
    }
  }

  String _formatDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(date.year, date.month, date.day);

    if (dateDay == today) {
      return 'Today';
    } else if (dateDay == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (dateDay.isAfter(today.subtract(const Duration(days: 7)))) {
      return _getDayName(date.weekday);
    } else {
      return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final date = _formatDateKey(dateTime);
    final time = _formatTime(dateTime);
    return '$date at $time';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _getDayName(int weekday) {
    const days = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday];
  }

  String _getMonthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month];
  }

  String _getDelayText(MedicationAdherenceData record) {
    final delay = record.recordedTime.difference(record.scheduledTime);
    final hours = delay.inHours;
    final minutes = delay.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m late';
    } else {
      return '${minutes}m late';
    }
  }
}

/// Data class for grouping records
class RecordGroup {
  final String title;
  final List<MedicationAdherenceData> records;

  RecordGroup(this.title, this.records);
}