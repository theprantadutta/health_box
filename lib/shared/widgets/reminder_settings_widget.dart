import 'package:flutter/material.dart';
import 'reminder_type_selector.dart';
import 'alarm_sound_picker.dart';
import 'alarm_volume_slider.dart';
import 'reminder_preview.dart';

/// Reusable comprehensive reminder settings widget
/// Used across all medical record forms and reminder creation screens
///
/// This widget provides a complete UI for configuring reminders with:
/// - Enable/disable toggle
/// - Reminder type selection (notification/alarm/both)
/// - Alarm sound picker
/// - Volume control
/// - Time slot management
/// - Frequency selection
/// - Snooze duration
/// - Live preview
class ReminderSettingsWidget extends StatefulWidget {
  final bool enabled;
  final ValueChanged<bool> onEnabledChanged;
  final List<TimeOfDay> reminderTimes;
  final ValueChanged<List<TimeOfDay>> onReminderTimesChanged;
  final ReminderType reminderType;
  final ValueChanged<ReminderType> onReminderTypeChanged;
  final String alarmSound;
  final ValueChanged<String> onAlarmSoundChanged;
  final double alarmVolume;
  final ValueChanged<double> onAlarmVolumeChanged;
  final String frequency;
  final ValueChanged<String> onFrequencyChanged;
  final int snoozeMinutes;
  final ValueChanged<int> onSnoozeMinutesChanged;
  final String? medicationName;
  final String? dosage;
  final bool showPreview;
  final bool showFrequency;
  final bool showSnooze;

  const ReminderSettingsWidget({
    super.key,
    required this.enabled,
    required this.onEnabledChanged,
    required this.reminderTimes,
    required this.onReminderTimesChanged,
    required this.reminderType,
    required this.onReminderTypeChanged,
    required this.alarmSound,
    required this.onAlarmSoundChanged,
    required this.alarmVolume,
    required this.onAlarmVolumeChanged,
    this.frequency = 'daily',
    required this.onFrequencyChanged,
    this.snoozeMinutes = 15,
    required this.onSnoozeMinutesChanged,
    this.medicationName,
    this.dosage,
    this.showPreview = true,
    this.showFrequency = true,
    this.showSnooze = true,
  });

  @override
  State<ReminderSettingsWidget> createState() => _ReminderSettingsWidgetState();
}

class _ReminderSettingsWidgetState extends State<ReminderSettingsWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Enable/Disable Switch
        SwitchListTile(
          title: const Text('Enable Reminders'),
          subtitle: const Text('Get notifications when it\'s time to take your medication'),
          value: widget.enabled,
          onChanged: (value) {
            widget.onEnabledChanged(value);
            // Auto-add first time slot if enabled and no times exist
            if (value && widget.reminderTimes.isEmpty) {
              widget.onReminderTimesChanged([TimeOfDay.now()]);
            }
          },
        ),

        if (widget.enabled) ...[
          const SizedBox(height: 16),

          // Reminder Type Selector
          ReminderTypeSelector(
            selectedType: widget.reminderType,
            onChanged: widget.onReminderTypeChanged,
            helpText: 'Choose how you want to be reminded',
          ),

          const SizedBox(height: 16),

          // Alarm Settings (only if alarm or both is selected)
          if (widget.reminderType == ReminderType.alarm ||
              widget.reminderType == ReminderType.both) ...[
            AlarmSoundPicker(
              selectedSound: widget.alarmSound,
              onSoundChanged: widget.onAlarmSoundChanged,
              showPreview: true,
            ),
            const SizedBox(height: 16),

            AlarmVolumeSlider(
              volume: widget.alarmVolume,
              onVolumeChanged: widget.onAlarmVolumeChanged,
            ),
            const SizedBox(height: 16),
          ],

          // Reminder Times
          _buildReminderTimesSection(),

          if (widget.showFrequency) ...[
            const SizedBox(height: 16),
            _buildFrequencySelector(),
          ],

          if (widget.showSnooze) ...[
            const SizedBox(height: 16),
            _buildSnoozeSelector(),
          ],

          // Preview (if enabled and we have data)
          if (widget.showPreview && widget.reminderTimes.isNotEmpty) ...[
            const SizedBox(height: 16),
            ReminderPreview(
              title: widget.medicationName != null && widget.medicationName!.isNotEmpty
                  ? 'Take ${widget.medicationName}'
                  : 'Medication Reminder',
              description: widget.dosage != null && widget.dosage!.isNotEmpty
                  ? 'Dosage: ${widget.dosage}'
                  : 'Time to take your medication',
              scheduledTime: DateTime.now().copyWith(
                hour: widget.reminderTimes.first.hour,
                minute: widget.reminderTimes.first.minute,
              ),
              reminderType: widget.reminderType,
              alarmSound: widget.alarmSound,
              alarmVolume: widget.alarmVolume,
              showTestButtons: true,
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildReminderTimesSection() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reminder Times',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                TextButton.icon(
                  onPressed: _addReminderTime,
                  icon: const Icon(Icons.add_alarm, size: 18),
                  label: const Text('Add Time'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (widget.reminderTimes.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No reminder times set. Tap "Add Time" to add one.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              )
            else
              ...widget.reminderTimes.asMap().entries.map((entry) {
                final index = entry.key;
                final time = entry.value;
                return _buildTimeSlot(time, index);
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlot(TimeOfDay time, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.access_time,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          time.format(context),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          _getTimeDescription(time),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editReminderTime(index),
              tooltip: 'Edit time',
            ),
            if (widget.reminderTimes.length > 1)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _removeReminderTime(index),
                tooltip: 'Remove time',
              ),
          ],
        ),
      ),
    );
  }

  String _getTimeDescription(TimeOfDay time) {
    final hour = time.hour;
    if (hour >= 5 && hour < 12) return 'Morning';
    if (hour >= 12 && hour < 17) return 'Afternoon';
    if (hour >= 17 && hour < 21) return 'Evening';
    return 'Night';
  }

  Widget _buildFrequencySelector() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Frequency',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: widget.frequency,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.repeat),
              ),
              items: const [
                DropdownMenuItem(value: 'once', child: Text('Once')),
                DropdownMenuItem(value: 'daily', child: Text('Daily')),
                DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
              ],
              onChanged: (value) {
                if (value != null) {
                  widget.onFrequencyChanged(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSnoozeSelector() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Snooze Duration',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: widget.snoozeMinutes,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.snooze),
              ),
              items: const [
                DropdownMenuItem(value: 5, child: Text('5 minutes')),
                DropdownMenuItem(value: 10, child: Text('10 minutes')),
                DropdownMenuItem(value: 15, child: Text('15 minutes')),
                DropdownMenuItem(value: 30, child: Text('30 minutes')),
                DropdownMenuItem(value: 60, child: Text('1 hour')),
              ],
              onChanged: (value) {
                if (value != null) {
                  widget.onSnoozeMinutesChanged(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addReminderTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      final updatedTimes = List<TimeOfDay>.from(widget.reminderTimes)..add(time);
      widget.onReminderTimesChanged(updatedTimes);
    }
  }

  Future<void> _editReminderTime(int index) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: widget.reminderTimes[index],
    );

    if (time != null) {
      final updatedTimes = List<TimeOfDay>.from(widget.reminderTimes);
      updatedTimes[index] = time;
      widget.onReminderTimesChanged(updatedTimes);
    }
  }

  void _removeReminderTime(int index) {
    if (widget.reminderTimes.length > 1) {
      final updatedTimes = List<TimeOfDay>.from(widget.reminderTimes)
        ..removeAt(index);
      widget.onReminderTimesChanged(updatedTimes);
    }
  }
}
