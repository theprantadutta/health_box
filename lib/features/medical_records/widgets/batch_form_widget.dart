import 'package:flutter/material.dart';

import '../../../data/database/app_database.dart';
import '../../../data/models/medication_batch.dart';
import '../services/medication_batch_service.dart';

class BatchFormDialog extends StatefulWidget {
  final MedicationBatche? batch;

  const BatchFormDialog({super.key, this.batch});

  @override
  State<BatchFormDialog> createState() => _BatchFormDialogState();
}

class _BatchFormDialogState extends State<BatchFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final MedicationBatchService _batchService = MedicationBatchService();

  String _selectedTimingType = MedicationBatchTimingType.afterMeal;
  String _selectedMealType = MealType.breakfast;
  int _minutesOffset = 30;
  List<TimeOfDay> _fixedTimes = [];
  int _intervalHours = 6;
  TimeOfDay? _intervalStartTime;
  TimeOfDay? _intervalEndTime;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.batch != null) {
      _populateForm();
    }
  }

  void _populateForm() {
    final batch = widget.batch!;
    _nameController.text = batch.name;
    _descriptionController.text = batch.description ?? '';
    _selectedTimingType = batch.timingType;

    final timingDetails = _batchService.parseTimingDetails(
      batch.timingType,
      batch.timingDetails,
    );

    if (timingDetails != null) {
      switch (batch.timingType) {
        case MedicationBatchTimingType.afterMeal:
        case MedicationBatchTimingType.beforeMeal:
          final mealTiming = MealTimingDetails.fromJson(timingDetails);
          _selectedMealType = mealTiming.mealType;
          _minutesOffset = mealTiming.minutesAfterBefore;
          break;

        case MedicationBatchTimingType.fixedTime:
          final fixedTiming = FixedTimeDetails.fromJson(timingDetails);
          _fixedTimes = fixedTiming.times.map((timeStr) {
            final parts = timeStr.split(':');
            return TimeOfDay(
              hour: int.parse(parts[0]),
              minute: int.parse(parts[1]),
            );
          }).toList();
          break;

        case MedicationBatchTimingType.interval:
          final intervalTiming = IntervalTimingDetails.fromJson(timingDetails);
          _intervalHours = intervalTiming.intervalHours;
          if (intervalTiming.startTime != null) {
            final parts = intervalTiming.startTime!.split(':');
            _intervalStartTime = TimeOfDay(
              hour: int.parse(parts[0]),
              minute: int.parse(parts[1]),
            );
          }
          if (intervalTiming.endTime != null) {
            final parts = intervalTiming.endTime!.split(':');
            _intervalEndTime = TimeOfDay(
              hour: int.parse(parts[0]),
              minute: int.parse(parts[1]),
            );
          }
          break;
      }
    }
  }

  Map<String, dynamic>? _buildTimingDetails() {
    switch (_selectedTimingType) {
      case MedicationBatchTimingType.afterMeal:
      case MedicationBatchTimingType.beforeMeal:
        return MealTimingDetails(
          mealType: _selectedMealType,
          minutesAfterBefore: _minutesOffset,
        ).toJson();

      case MedicationBatchTimingType.fixedTime:
        return FixedTimeDetails(
          times: _fixedTimes.map((time) =>
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'
          ).toList(),
        ).toJson();

      case MedicationBatchTimingType.interval:
        return IntervalTimingDetails(
          intervalHours: _intervalHours,
          startTime: _intervalStartTime != null
              ? '${_intervalStartTime!.hour.toString().padLeft(2, '0')}:${_intervalStartTime!.minute.toString().padLeft(2, '0')}'
              : null,
          endTime: _intervalEndTime != null
              ? '${_intervalEndTime!.hour.toString().padLeft(2, '0')}:${_intervalEndTime!.minute.toString().padLeft(2, '0')}'
              : null,
        ).toJson();

      case MedicationBatchTimingType.asNeeded:
        return null;

      default:
        return null;
    }
  }

  Future<void> _saveBatch() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final timingDetails = _buildTimingDetails();

      if (widget.batch == null) {
        // Create new batch
        await _batchService.createBatch(
          name: _nameController.text.trim(),
          timingType: _selectedTimingType,
          timingDetails: timingDetails,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        );
      } else {
        // Update existing batch
        await _batchService.updateBatch(
          id: widget.batch!.id,
          name: _nameController.text.trim(),
          timingType: _selectedTimingType,
          timingDetails: timingDetails,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving batch: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildTimingConfiguration() {
    switch (_selectedTimingType) {
      case MedicationBatchTimingType.afterMeal:
      case MedicationBatchTimingType.beforeMeal:
        return Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedMealType,
              decoration: const InputDecoration(
                labelText: 'Meal',
                border: OutlineInputBorder(),
              ),
              items: MealType.allMeals.map((meal) {
                return DropdownMenuItem(
                  value: meal,
                  child: Text(MealType.getDisplayName(meal)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedMealType = value!);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _minutesOffset.toString(),
              decoration: InputDecoration(
                labelText: _selectedTimingType == MedicationBatchTimingType.afterMeal
                    ? 'Minutes After Meal'
                    : 'Minutes Before Meal',
                border: const OutlineInputBorder(),
                suffixText: 'min',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter minutes';
                }
                final minutes = int.tryParse(value);
                if (minutes == null || minutes < 0 || minutes > 480) {
                  return 'Please enter a valid number (0-480)';
                }
                return null;
              },
              onChanged: (value) {
                final minutes = int.tryParse(value);
                if (minutes != null) {
                  _minutesOffset = minutes;
                }
              },
            ),
          ],
        );

      case MedicationBatchTimingType.fixedTime:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Fixed Times'),
                const Spacer(),
                TextButton.icon(
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() {
                        _fixedTimes.add(time);
                        _fixedTimes.sort((a, b) => a.hour.compareTo(b.hour));
                      });
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Time'),
                ),
              ],
            ),
            if (_fixedTimes.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No times added. Tap "Add Time" to set specific times.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...(_fixedTimes.map((time) => ListTile(
                leading: const Icon(Icons.schedule),
                title: Text(time.format(context)),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () {
                    setState(() => _fixedTimes.remove(time));
                  },
                ),
              ))),
          ],
        );

      case MedicationBatchTimingType.interval:
        return Column(
          children: [
            TextFormField(
              initialValue: _intervalHours.toString(),
              decoration: const InputDecoration(
                labelText: 'Interval Hours',
                border: OutlineInputBorder(),
                suffixText: 'hours',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter interval hours';
                }
                final hours = int.tryParse(value);
                if (hours == null || hours < 1 || hours > 24) {
                  return 'Please enter a valid number (1-24)';
                }
                return null;
              },
              onChanged: (value) {
                final hours = int.tryParse(value);
                if (hours != null) {
                  _intervalHours = hours;
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Start Time (Optional)'),
                    subtitle: Text(_intervalStartTime?.format(context) ?? 'Not set'),
                    trailing: _intervalStartTime != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _intervalStartTime = null),
                          )
                        : null,
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _intervalStartTime ?? TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() => _intervalStartTime = time);
                      }
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('End Time (Optional)'),
                    subtitle: Text(_intervalEndTime?.format(context) ?? 'Not set'),
                    trailing: _intervalEndTime != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _intervalEndTime = null),
                          )
                        : null,
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _intervalEndTime ?? TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() => _intervalEndTime = time);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        );

      case MedicationBatchTimingType.asNeeded:
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'As-needed medications don\'t have automatic reminders. '
            'They can be taken when required.',
            style: TextStyle(color: Colors.grey),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.batch == null ? 'Create Batch' : 'Edit Batch'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Batch Name *',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., Morning Medications',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Batch name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedTimingType,
                  decoration: const InputDecoration(
                    labelText: 'Timing Type',
                    border: OutlineInputBorder(),
                  ),
                  items: MedicationBatchTimingType.allTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(MedicationBatchTimingType.getDisplayName(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedTimingType = value!);
                  },
                ),
                const SizedBox(height: 16),
                _buildTimingConfiguration(),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                    hintText: 'Additional notes about this batch',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveBatch,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.batch == null ? 'Create' : 'Save'),
        ),
      ],
    );
  }
}