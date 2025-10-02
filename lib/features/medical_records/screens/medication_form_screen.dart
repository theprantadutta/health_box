import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/medical_records_providers.dart';
import '../services/medication_service.dart';
import '../services/medication_batch_service.dart';
import '../../../shared/widgets/attachment_form_widget.dart';
import '../../../shared/services/attachment_service.dart';
import '../../../data/database/app_database.dart';
import '../../../data/models/medication_batch.dart';
import '../../../shared/widgets/reminder_settings_widget.dart';
import '../../../shared/widgets/reminder_type_selector.dart'; // Import for ReminderType enum
import 'dart:developer' as developer;

class MedicationFormScreen extends ConsumerStatefulWidget {
  final String? profileId;

  const MedicationFormScreen({super.key, this.profileId});

  @override
  ConsumerState<MedicationFormScreen> createState() =>
      _MedicationFormScreenState();
}

class _MedicationFormScreenState extends ConsumerState<MedicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final MedicationBatchService _batchService = MedicationBatchService();
  bool _isLoading = false;
  List<AttachmentResult> _attachments = [];

  // Batch selection
  List<MedicationBatche> _availableBatches = [];
  String? _selectedBatchId;

  bool _medicationInfoExpanded = true;
  bool _attachmentsExpanded = true;
  bool _reminderSettingsExpanded = true;

  // Reminder settings
  bool _remindersEnabled = false;
  List<TimeOfDay> _reminderTimes = [];
  String _reminderFrequency = 'daily';
  int _snoozeMinutes = 15;

  // New reminder UI state
  ReminderType _reminderType = ReminderType.notification;
  String _alarmSound = 'gentle';
  double _alarmVolume = 0.7;

  @override
  void initState() {
    super.initState();
    _loadBatches();
  }

  Future<void> _loadBatches() async {
    try {
      final batches = await _batchService.getActiveBatches();
      setState(() {
        _availableBatches = batches;
      });
    } catch (e) {
      developer.log('Error loading batches: $e');
    }
  }

  String _getBatchDescription(MedicationBatche batch) {
    final timingDetails = _batchService.parseTimingDetails(
      batch.timingType,
      batch.timingDetails,
    );

    switch (batch.timingType) {
      case 'after_meal':
        if (timingDetails != null) {
          final mealTiming = MealTimingDetails.fromJson(timingDetails);
          final mealName = mealTiming.mealType == 'breakfast' ? 'breakfast' :
                          mealTiming.mealType == 'lunch' ? 'lunch' :
                          mealTiming.mealType == 'dinner' ? 'dinner' : mealTiming.mealType;
          return '${mealTiming.minutesAfterBefore} min after $mealName';
        }
        return 'After meal';
      case 'before_meal':
        if (timingDetails != null) {
          final mealTiming = MealTimingDetails.fromJson(timingDetails);
          final mealName = mealTiming.mealType == 'breakfast' ? 'breakfast' :
                          mealTiming.mealType == 'lunch' ? 'lunch' :
                          mealTiming.mealType == 'dinner' ? 'dinner' : mealTiming.mealType;
          return '${mealTiming.minutesAfterBefore} min before $mealName';
        }
        return 'Before meal';
      case 'fixed_time':
        if (timingDetails != null) {
          final fixedTiming = FixedTimeDetails.fromJson(timingDetails);
          return 'At ${fixedTiming.times.join(', ')}';
        }
        return 'Fixed time';
      case 'interval':
        if (timingDetails != null) {
          final intervalTiming = IntervalTimingDetails.fromJson(timingDetails);
          return 'Every ${intervalTiming.intervalHours} hours';
        }
        return 'Interval';
      case 'as_needed':
        return 'As needed';
      default:
        return batch.timingType;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Medication'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveMedication,
            child: const Text('SAVE'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildExpandableSection(
              title: 'Medication Information',
              icon: Icons.medication,
              isExpanded: _medicationInfoExpanded,
              onExpansionChanged: (value) => setState(() => _medicationInfoExpanded = value),
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Medication Name *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.medication),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Medication name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dosageController,
                  decoration: const InputDecoration(
                    labelText: 'Dosage *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.straighten),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Dosage is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _frequencyController,
                  decoration: const InputDecoration(
                    labelText: 'Frequency *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.schedule),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Frequency is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Batch Selection
                DropdownButtonFormField<String>(
                  initialValue: _selectedBatchId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Medication Batch (Optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.group_work),
                    hintText: 'Select a batch for this medication',
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text(
                        'No batch (individual medication)',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    ..._availableBatches.map((batch) {
                      return DropdownMenuItem<String>(
                        value: batch.id,
                        child: SizedBox(
                          width: double.maxFinite,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                batch.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                _getBatchDescription(batch),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedBatchId = value);
                  },
                ),
                if (_selectedBatchId != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info, color: Colors.blue, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This medication will be included in batch reminders. Individual reminder settings will be ignored.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            _buildExpandableSection(
              title: 'Attachments',
              icon: Icons.attach_file,
              isExpanded: _attachmentsExpanded,
              onExpansionChanged: (value) => setState(() => _attachmentsExpanded = value),
              children: [
                _buildAttachmentsContent(),
              ],
            ),
            const SizedBox(height: 16),

            _buildExpandableSection(
              title: 'Reminder Settings',
              icon: Icons.notifications,
              isExpanded: _reminderSettingsExpanded,
              onExpansionChanged: (value) => setState(() => _reminderSettingsExpanded = value),
              children: [
                _buildReminderSettingsContent(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add medication labels, pill images, or doctor instructions',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        AttachmentFormWidget(
          initialAttachments: _attachments,
          onAttachmentsChanged: (attachments) {
            setState(() {
              _attachments = attachments;
            });
          },
          maxFiles: 6,
          allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
          maxFileSizeMB: 25,
        ),
      ],
    );
  }

  Widget _buildReminderSettingsContent() {
    return ReminderSettingsWidget(
      enabled: _remindersEnabled,
      onEnabledChanged: (value) => setState(() => _remindersEnabled = value),
      reminderTimes: _reminderTimes,
      onReminderTimesChanged: (times) => setState(() => _reminderTimes = times),
      reminderType: _reminderType,
      onReminderTypeChanged: (type) => setState(() => _reminderType = type),
      alarmSound: _alarmSound,
      onAlarmSoundChanged: (sound) => setState(() => _alarmSound = sound),
      alarmVolume: _alarmVolume,
      onAlarmVolumeChanged: (volume) => setState(() => _alarmVolume = volume),
      frequency: _reminderFrequency,
      onFrequencyChanged: (freq) => setState(() => _reminderFrequency = freq),
      snoozeMinutes: _snoozeMinutes,
      onSnoozeMinutesChanged: (mins) => setState(() => _snoozeMinutes = mins),
      medicationName: _nameController.text,
      dosage: _dosageController.text,
      showPreview: true,
      showFrequency: true,
      showSnooze: true,
    );
  }

  Future<void> _saveMedication() async {
    developer.log('Starting medication save process', name: 'MedicationForm', level: 800);

    if (!_formKey.currentState!.validate()) {
      developer.log('Form validation failed', name: 'MedicationForm', level: 900);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all required fields'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    developer.log('Form validation passed', name: 'MedicationForm', level: 800);

    // Validate reminders if enabled
    if (_remindersEnabled && _reminderTimes.isEmpty) {
      developer.log('Reminders enabled but no times set', name: 'MedicationForm', level: 900);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please add at least one reminder time or disable reminders'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = ref.read(medicationServiceProvider);
      final selectedProfileId = widget.profileId;

      if (selectedProfileId == null) {
        developer.log('No profile selected', name: 'MedicationForm', level: 1000);
        throw Exception('No profile selected');
      }

      developer.log('Creating medication request for profile: $selectedProfileId', name: 'MedicationForm', level: 800);
      developer.log('Reminders enabled: $_remindersEnabled, Times: ${_reminderTimes.length}', name: 'MedicationForm', level: 800);

      final request = CreateMedicationRequest(
        profileId: selectedProfileId,
        title: _nameController.text.trim(),
        description:
            '${_dosageController.text.trim()} - ${_frequencyController.text.trim()}',
        recordDate: DateTime.now(),
        medicationName: _nameController.text.trim(),
        dosage: _dosageController.text.trim().isEmpty
            ? 'As prescribed'
            : _dosageController.text.trim(),
        frequency: _frequencyController.text.trim().isEmpty
            ? 'As needed'
            : _frequencyController.text.trim(),
        schedule: _frequencyController.text.trim().isEmpty
            ? 'Daily'
            : _frequencyController.text.trim(),
        startDate: DateTime.now(),
        reminderEnabled: _remindersEnabled,
        status: 'active',
        batchId: _selectedBatchId,
        reminderTimes: _remindersEnabled
            ? _reminderTimes.map((timeOfDay) => MedicationTime(
                hour: timeOfDay.hour,
                minute: timeOfDay.minute,
              )).toList()
            : [],
        // NEW: Add reminder settings for proper alarm/notification scheduling
        reminderType: _reminderType.value, // Convert enum to string
        alarmSound: _alarmSound,
        alarmVolume: _alarmVolume,
        snoozeMinutes: _snoozeMinutes,
        reminderFrequency: _reminderFrequency, // CRITICAL: Pass reminder frequency (once/daily/weekly/monthly), not medication frequency!
      );

      developer.log('Calling service.createMedication with request', name: 'MedicationForm', level: 800);
      await service.createMedication(request);
      developer.log('Service.createMedication completed successfully', name: 'MedicationForm', level: 800);

      // Log success
      developer.log(
        'Medication created successfully for profile: $selectedProfileId',
        name: 'MedicationForm',
        level: 800, // INFO level
      );

      // Refresh medical records providers
      ref.invalidate(allMedicalRecordsProvider);
      ref.invalidate(recordsByProfileIdProvider(selectedProfileId));

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Medication saved successfully'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (error, stackTrace) {
      // Log detailed error to console
      developer.log(
        'Failed to save medication',
        name: 'MedicationForm',
        level: 1000, // ERROR level
        error: error,
        stackTrace: stackTrace,
      );

      if (mounted) {
        // Show user-friendly error message with specific error details
        final errorMessage = error.toString().length > 100
            ? 'Failed to save medication. Please try again.'
            : 'Error: ${error.toString()}';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(errorMessage),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _saveMedication(),
            ),
            duration: const Duration(seconds: 5), // Show longer for error details
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required ValueChanged<bool> onExpansionChanged,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        initiallyExpanded: isExpanded,
        onExpansionChanged: onExpansionChanged,
        childrenPadding: const EdgeInsets.all(16),
        children: children,
      ),
    );
  }
}
