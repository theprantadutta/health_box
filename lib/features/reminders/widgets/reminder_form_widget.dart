import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/reminder_service.dart';
import '../../../data/database/app_database.dart';
import '../../../shared/providers/reminder_providers.dart';

/// Form widget for creating and editing reminders
class ReminderFormWidget extends ConsumerStatefulWidget {
  final Reminder? reminder;
  final String? medicationId;
  final void Function(String reminderId)? onReminderCreated;
  final void Function()? onReminderUpdated;
  final void Function()? onCancel;

  const ReminderFormWidget({
    super.key,
    this.reminder,
    this.medicationId,
    this.onReminderCreated,
    this.onReminderUpdated,
    this.onCancel,
  });

  @override
  ConsumerState<ReminderFormWidget> createState() => _ReminderFormWidgetState();
}

class _ReminderFormWidgetState extends ConsumerState<ReminderFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedType = 'medication';
  String _selectedFrequency = 'daily';
  DateTime _selectedDateTime = DateTime.now().add(const Duration(hours: 1));
  TimeOfDay _selectedTime = TimeOfDay.now();
  List<int> _selectedDaysOfWeek = [];
  List<TimeOfDay> _timeSlots = [];
  bool _isActive = true;
  int _snoozeMinutes = 15;
  bool _isLoading = false;

  final List<String> _reminderTypes = [
    'medication',
    'appointment',
    'lab_test',
    'vaccination',
    'general',
  ];

  final List<String> _frequencies = [
    'once',
    'daily',
    'weekly',
    'monthly',
  ];

  final List<String> _daysOfWeekLabels = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    _initializeFormData();
  }

  void _initializeFormData() {
    if (widget.reminder != null) {
      final reminder = widget.reminder!;
      _titleController.text = reminder.title;
      _descriptionController.text = reminder.description ?? '';
      _selectedType = reminder.type;
      _selectedFrequency = reminder.frequency;
      _selectedDateTime = reminder.scheduledTime;
      _selectedTime = TimeOfDay.fromDateTime(reminder.scheduledTime);
      _isActive = reminder.isActive;
      _snoozeMinutes = reminder.snoozeMinutes;
      
      // Parse days of week if present
      if (reminder.daysOfWeek != null) {
        try {
          final daysJson = reminder.daysOfWeek!;
          // Simple JSON parsing - in production you might use dart:convert
          if (daysJson.isNotEmpty) {
            _selectedDaysOfWeek = daysJson
                .replaceAll('[', '')
                .replaceAll(']', '')
                .split(',')
                .map((e) => int.tryParse(e.trim()))
                .where((e) => e != null)
                .cast<int>()
                .toList();
          }
        } catch (e) {
          // Handle parsing errors
          _selectedDaysOfWeek = [];
        }
      }
      
      // Parse time slots if present
      if (reminder.timeSlots != null) {
        try {
          final _ = reminder.timeSlots!;
          // Simple parsing for time slots - would need proper JSON parsing
          _timeSlots = [_selectedTime]; // Default to current time for now
        } catch (e) {
          _timeSlots = [_selectedTime];
        }
      }
    } else {
      // Set default time to next hour
      final now = DateTime.now();
      _selectedDateTime = DateTime(now.year, now.month, now.day, now.hour + 1);
      _selectedTime = TimeOfDay(hour: now.hour + 1, minute: 0);
      _timeSlots = [_selectedTime];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildTitleField(),
              const SizedBox(height: 16),
              _buildDescriptionField(),
              const SizedBox(height: 16),
              _buildTypeSelector(),
              const SizedBox(height: 16),
              _buildFrequencySelector(),
              const SizedBox(height: 16),
              _buildDateTimeSelector(),
              if (_selectedFrequency == 'weekly') ...[
                const SizedBox(height: 16),
                _buildDaysOfWeekSelector(),
              ],
              if (_selectedFrequency == 'daily' && _selectedType == 'medication') ...[
                const SizedBox(height: 16),
                _buildTimeSlotsEditor(),
              ],
              const SizedBox(height: 16),
              _buildSnoozeSelector(),
              const SizedBox(height: 16),
              _buildActiveSwitch(),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      widget.reminder == null ? 'Create Reminder' : 'Edit Reminder',
      style: Theme.of(context).textTheme.titleLarge,
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'Title',
        hintText: 'Enter reminder title',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Title is required';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Description (Optional)',
        hintText: 'Enter additional details',
        border: OutlineInputBorder(),
      ),
      maxLines: 2,
    );
  }

  Widget _buildTypeSelector() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedType,
      decoration: const InputDecoration(
        labelText: 'Type',
        border: OutlineInputBorder(),
      ),
      items: _reminderTypes.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(_formatTypeLabel(type)),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedType = value;
          });
        }
      },
    );
  }

  Widget _buildFrequencySelector() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedFrequency,
      decoration: const InputDecoration(
        labelText: 'Frequency',
        border: OutlineInputBorder(),
      ),
      items: _frequencies.map((frequency) {
        return DropdownMenuItem(
          value: frequency,
          child: Text(_formatFrequencyLabel(frequency)),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedFrequency = value;
            // Reset day selection when frequency changes
            if (value != 'weekly') {
              _selectedDaysOfWeek.clear();
            }
          });
        }
      },
    );
  }

  Widget _buildDateTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Schedule',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _selectDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  '${_selectedDateTime.day}/${_selectedDateTime.month}/${_selectedDateTime.year}',
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _selectTime,
                icon: const Icon(Icons.access_time),
                label: Text(_selectedTime.format(context)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDaysOfWeekSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Days of Week',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: List.generate(_daysOfWeekLabels.length, (index) {
            final isSelected = _selectedDaysOfWeek.contains(index + 1);
            return FilterChip(
              label: Text(_daysOfWeekLabels[index]),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedDaysOfWeek.add(index + 1);
                  } else {
                    _selectedDaysOfWeek.remove(index + 1);
                  }
                  _selectedDaysOfWeek.sort();
                });
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTimeSlotsEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Time Slots',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            IconButton(
              onPressed: _addTimeSlot,
              icon: const Icon(Icons.add),
              tooltip: 'Add time slot',
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._timeSlots.asMap().entries.map((entry) {
          final index = entry.key;
          final timeSlot = entry.value;
          return ListTile(
            leading: const Icon(Icons.schedule),
            title: Text(timeSlot.format(context)),
            trailing: _timeSlots.length > 1
                ? IconButton(
                    onPressed: () => _removeTimeSlot(index),
                    icon: const Icon(Icons.delete),
                  )
                : null,
            onTap: () => _editTimeSlot(index),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSnoozeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Snooze Duration (minutes)',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          initialValue: _snoozeMinutes,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          items: [5, 10, 15, 30, 60, 120].map((minutes) {
            return DropdownMenuItem(
              value: minutes,
              child: Text('$minutes minutes'),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _snoozeMinutes = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildActiveSwitch() {
    return SwitchListTile(
      title: const Text('Active'),
      subtitle: const Text('Enable or disable this reminder'),
      value: _isActive,
      onChanged: (value) {
        setState(() {
          _isActive = value;
        });
      },
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (widget.onCancel != null)
          TextButton(
            onPressed: widget.onCancel,
            child: const Text('Cancel'),
          ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveReminder,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.reminder == null ? 'Create' : 'Update'),
        ),
      ],
    );
  }

  String _formatTypeLabel(String type) {
    return type.split('_').map((word) => 
        word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  String _formatFrequencyLabel(String frequency) {
    return frequency[0].toUpperCase() + frequency.substring(1);
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        _selectedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    
    if (time != null) {
      setState(() {
        _selectedTime = time;
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  void _addTimeSlot() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    
    if (time != null) {
      setState(() {
        _timeSlots.add(time);
      });
    }
  }

  void _removeTimeSlot(int index) {
    setState(() {
      _timeSlots.removeAt(index);
    });
  }

  void _editTimeSlot(int index) async {
    final time = await showTimePicker(
      context: context,
      initialTime: _timeSlots[index],
    );
    
    if (time != null) {
      setState(() {
        _timeSlots[index] = time;
      });
    }
  }

  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final reminderService = ref.read(reminderServiceProvider);
      
      if (widget.reminder == null) {
        // Create new reminder
        final request = CreateReminderRequest(
          medicationId: widget.medicationId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
          scheduledTime: _selectedDateTime,
          frequency: _selectedFrequency,
          daysOfWeek: _selectedDaysOfWeek.isNotEmpty
              ? _selectedDaysOfWeek.toString()
              : null,
          timeSlots: _timeSlots.length > 1
              ? _timeSlots.map((t) => '${t.hour}:${t.minute}').join(',')
              : null,
          isActive: _isActive,
          snoozeMinutes: _snoozeMinutes,
        );
        
        final reminderId = await reminderService.createReminder(request);
        widget.onReminderCreated?.call(reminderId);
      } else {
        // Update existing reminder
        final request = UpdateReminderRequest(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
          scheduledTime: _selectedDateTime,
          frequency: _selectedFrequency,
          daysOfWeek: _selectedDaysOfWeek.isNotEmpty
              ? _selectedDaysOfWeek.toString()
              : null,
          timeSlots: _timeSlots.length > 1
              ? _timeSlots.map((t) => '${t.hour}:${t.minute}').join(',')
              : null,
          isActive: _isActive,
          snoozeMinutes: _snoozeMinutes,
        );
        
        await reminderService.updateReminder(widget.reminder!.id, request);
        widget.onReminderUpdated?.call();
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.reminder == null 
                  ? 'Reminder created successfully'
                  : 'Reminder updated successfully'
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}