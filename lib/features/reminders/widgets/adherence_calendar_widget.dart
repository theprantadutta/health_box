import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../data/database/app_database.dart';
import '../../../data/models/medication_adherence.dart';

/// Widget displaying medication adherence in calendar format
class AdherenceCalendarWidget extends StatefulWidget {
  final List<MedicationAdherenceData> adherenceRecords;
  final DateTime startDate;
  final DateTime endDate;
  final void Function(DateTime date)? onDateSelected;

  const AdherenceCalendarWidget({
    super.key,
    required this.adherenceRecords,
    required this.startDate,
    required this.endDate,
    this.onDateSelected,
  });

  @override
  State<AdherenceCalendarWidget> createState() => _AdherenceCalendarWidgetState();
}

class _AdherenceCalendarWidgetState extends State<AdherenceCalendarWidget> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  Map<DateTime, List<MedicationAdherenceData>> _eventsByDay = {};

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.startDate;
    _selectedDay = DateTime.now();
    _groupRecordsByDay();
  }

  @override
  void didUpdateWidget(AdherenceCalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.adherenceRecords != widget.adherenceRecords) {
      _groupRecordsByDay();
    }
  }

  void _groupRecordsByDay() {
    _eventsByDay.clear();

    for (final record in widget.adherenceRecords) {
      final day = DateTime(
        record.scheduledTime.year,
        record.scheduledTime.month,
        record.scheduledTime.day,
      );

      _eventsByDay.putIfAbsent(day, () => []).add(record);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCalendar(),
        const SizedBox(height: 16),
        _buildLegend(),
        const SizedBox(height: 16),
        Expanded(child: _buildSelectedDayDetails()),
      ],
    );
  }

  Widget _buildCalendar() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: TableCalendar<MedicationAdherenceData>(
          firstDay: widget.startDate,
          lastDay: widget.endDate,
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          eventLoader: (day) => _eventsByDay[day] ?? [],
          calendarFormat: CalendarFormat.month,
          startingDayOfWeek: StartingDayOfWeek.monday,
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            markerDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
          ),
          calendarBuilders: CalendarBuilders<MedicationAdherenceData>(
            markerBuilder: (context, day, events) {
              if (events.isEmpty) return null;

              return _buildDayMarkers(events);
            },
          ),
          onDaySelected: (selectedDay, focusedDay) {
            if (!isSameDay(_selectedDay, selectedDay)) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              widget.onDateSelected?.call(selectedDay);
            }
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
        ),
      ),
    );
  }

  Widget _buildDayMarkers(List<MedicationAdherenceData> events) {
    // Calculate adherence status for the day
    final takenCount = events
        .where((e) => MedicationAdherenceStatus.isPositiveAdherence(e.status))
        .length;
    final totalCount = events.length;
    final adherenceRate = totalCount > 0 ? takenCount / totalCount : 0.0;

    Color color;
    if (adherenceRate == 1.0) {
      color = Colors.green;
    } else if (adherenceRate >= 0.5) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Positioned(
      bottom: 1,
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildLegend() {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Legend',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem('All Taken', Colors.green),
                _buildLegendItem('Partially Taken', Colors.orange),
                _buildLegendItem('Missed', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildSelectedDayDetails() {
    if (_selectedDay == null) {
      return const Center(
        child: Text('Select a day to view details'),
      );
    }

    final dayEvents = _eventsByDay[_selectedDay!] ?? [];

    if (dayEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No medications scheduled',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              'for ${_formatDate(_selectedDay!)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${_formatDate(_selectedDay!)} - ${dayEvents.length} medications',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: dayEvents.length,
              itemBuilder: (context, index) {
                final record = dayEvents[index];
                return _buildMedicationTile(record);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationTile(MedicationAdherenceData record) {
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
        backgroundColor: statusColor.withOpacity(0.2),
        child: Icon(
          statusIcon,
          color: statusColor,
          size: 20,
        ),
      ),
      title: Text(record.medicationName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${record.dosage} • Scheduled: ${_formatTime(record.scheduledTime)}'),
          if (record.recordedTime != record.scheduledTime)
            Text(
              'Recorded: ${_formatTime(record.recordedTime)}',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          if (record.notes != null && record.notes!.isNotEmpty)
            Text(
              record.notes!,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
      trailing: Chip(
        label: Text(
          statusText,
          style: TextStyle(
            color: statusColor,
            fontSize: 12,
          ),
        ),
        backgroundColor: statusColor.withOpacity(0.1),
        side: BorderSide(color: statusColor.withOpacity(0.3)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  String _formatDate(DateTime date) {
    return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _getMonthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month];
  }
}