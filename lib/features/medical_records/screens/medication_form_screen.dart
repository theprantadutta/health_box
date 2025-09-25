import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/medical_records_providers.dart';
import '../services/medication_service.dart';
import '../../../shared/widgets/attachment_form_widget.dart';
import '../../../shared/services/attachment_service.dart';
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
  bool _isLoading = false;
  List<AttachmentResult> _attachments = [];

  bool _medicationInfoExpanded = true;
  bool _attachmentsExpanded = true;
  bool _reminderSettingsExpanded = true;

  // Reminder settings
  bool _remindersEnabled = false;
  List<TimeOfDay> _reminderTimes = [];
  String _reminderFrequency = 'daily';
  int _snoozeMinutes = 15;

  @override
  void initState() {
    super.initState();
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text('Enable Reminders'),
          subtitle: const Text('Get notifications when it\'s time to take your medication'),
          value: _remindersEnabled,
          onChanged: (value) {
            setState(() {
              _remindersEnabled = value;
              if (!value) {
                _reminderTimes.clear();
              } else if (_reminderTimes.isEmpty) {
                // Add default reminder time
                _reminderTimes.add(TimeOfDay.now());
              }
            });
          },
        ),

        if (_remindersEnabled) ...[
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          Text(
            'Reminder Times',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),

          // Display reminder times
          ..._reminderTimes.asMap().entries.map((entry) {
            final index = entry.key;
            final timeOfDay = entry.value;
            return ListTile(
              leading: const Icon(Icons.schedule),
              title: Text(timeOfDay.format(context)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editReminderTime(index),
                  ),
                  if (_reminderTimes.length > 1)
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeReminderTime(index),
                    ),
                ],
              ),
            );
          }).toList(),

          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _addReminderTime,
            icon: const Icon(Icons.add),
            label: const Text('Add Reminder Time'),
          ),

          const SizedBox(height: 16),

          // Frequency selection
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Reminder Frequency',
              border: OutlineInputBorder(),
            ),
            initialValue: _reminderFrequency,
            items: const [
              DropdownMenuItem(value: 'daily', child: Text('Daily')),
              DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
              DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _reminderFrequency = value;
                });
              }
            },
          ),

          const SizedBox(height: 16),

          // Snooze duration
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(
              labelText: 'Snooze Duration (minutes)',
              border: OutlineInputBorder(),
            ),
            initialValue: _snoozeMinutes,
            items: const [
              DropdownMenuItem(value: 5, child: Text('5 minutes')),
              DropdownMenuItem(value: 10, child: Text('10 minutes')),
              DropdownMenuItem(value: 15, child: Text('15 minutes')),
              DropdownMenuItem(value: 30, child: Text('30 minutes')),
              DropdownMenuItem(value: 60, child: Text('1 hour')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _snoozeMinutes = value;
                });
              }
            },
          ),
        ],
      ],
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
        reminderTimes: _remindersEnabled
            ? _reminderTimes.map((timeOfDay) => MedicationTime(
                hour: timeOfDay.hour,
                minute: timeOfDay.minute,
              )).toList()
            : [],
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

  Future<void> _addReminderTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        _reminderTimes.add(time);
      });
    }
  }

  Future<void> _editReminderTime(int index) async {
    final time = await showTimePicker(
      context: context,
      initialTime: _reminderTimes[index],
    );

    if (time != null) {
      setState(() {
        _reminderTimes[index] = time;
      });
    }
  }

  void _removeReminderTime(int index) {
    setState(() {
      _reminderTimes.removeAt(index);
    });
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
