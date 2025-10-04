import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;
import '../../../shared/providers/medical_records_providers.dart';
import '../services/chronic_condition_service.dart';
import '../../../data/models/chronic_condition.dart';
import '../../../shared/widgets/attachment_form_widget.dart';
import '../../../shared/services/attachment_service.dart';
import '../../../shared/widgets/reminder_type_selector.dart';
import '../../../shared/widgets/alarm_sound_picker.dart';
import '../../../shared/widgets/alarm_volume_slider.dart';
import '../../../shared/widgets/reminder_preview.dart';
import '../../../shared/theme/design_system.dart';
import '../../../shared/widgets/modern_text_field.dart';

class ChronicConditionFormScreen extends ConsumerStatefulWidget {
  final String? profileId;
  final String? conditionId;

  const ChronicConditionFormScreen({
    super.key,
    this.profileId,
    this.conditionId,
  });

  @override
  ConsumerState<ChronicConditionFormScreen> createState() =>
      _ChronicConditionFormScreenState();
}

class _ChronicConditionFormScreenState
    extends ConsumerState<ChronicConditionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _conditionNameController = TextEditingController();
  final _diagnosingProviderController = TextEditingController();
  final _treatmentController = TextEditingController();
  final _managementPlanController = TextEditingController();
  final _medicationsController = TextEditingController();

  DateTime _recordDate = DateTime.now();
  DateTime _diagnosisDate = DateTime.now();
  String _selectedSeverity = ConditionSeverity.mild;
  String _selectedStatus = ConditionStatus.active;
  bool _isLoading = false;
  bool _isEditing = false;
  List<AttachmentResult> _attachments = [];

  // Reminder settings
  bool _enableReminder = false;
  ReminderType _reminderType = ReminderType.notification;
  String _alarmSound = 'gentle';
  double _alarmVolume = 0.7;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.conditionId != null;
    if (_isEditing) {
      _loadChronicCondition();
    }
  }

  Future<void> _loadChronicCondition() async {
    // TODO: Load existing chronic condition data when editing
    // This will be implemented with the chronic condition service
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Chronic Condition' : 'New Chronic Condition',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: HealthBoxDesignSystem.chronicConditionGradient,
            boxShadow: [
              BoxShadow(
                color: HealthBoxDesignSystem.chronicConditionGradient.colors.first.withValues(alpha: 0.3),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveChronicCondition,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
            child: Text(_isLoading ? 'SAVING...' : 'SAVE'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildBasicInfoSection(),
            const SizedBox(height: 16),
            _buildConditionDetailsSection(),
            const SizedBox(height: 16),
            _buildDiagnosisSection(),
            const SizedBox(height: 16),
            _buildSeverityAndStatusSection(),
            const SizedBox(height: 16),
            _buildTreatmentSection(),
            const SizedBox(height: 16),
            _buildAttachmentsSection(),
            const SizedBox(height: 16),
            _buildManagementSection(),
            const SizedBox(height: 16),
            _buildReminderSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildModernSection(
      title: 'Basic Information',
      icon: Icons.info_outline,
      children: [
        ModernTextField(
          controller: _titleController,
          labelText: 'Title *',
          hintText: 'e.g., Type 2 Diabetes Management',
          prefixIcon: const Icon(Icons.medical_information),
          focusGradient: HealthBoxDesignSystem.chronicConditionGradient,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Title is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: _descriptionController,
          labelText: 'Description',
          hintText: 'Additional details about this condition',
          focusGradient: HealthBoxDesignSystem.chronicConditionGradient,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        ListTile(
          title: const Text('Record Date'),
          subtitle: Text(_formatDate(_recordDate)),
          trailing: const Icon(Icons.calendar_today),
          onTap: () => _selectDate(context, isRecordDate: true),
        ),
      ],
    );
  }

  Widget _buildConditionDetailsSection() {
    return _buildModernSection(
      title: 'Condition Details',
      icon: Icons.local_hospital,
      children: [
        ModernTextField(
          controller: _conditionNameController,
          labelText: 'Condition Name *',
          hintText: 'e.g., Type 2 Diabetes, Hypertension',
          prefixIcon: const Icon(Icons.local_hospital),
          focusGradient: HealthBoxDesignSystem.chronicConditionGradient,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Condition name is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Text(
          'Common Condition Categories',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: ConditionCategories.allCategories.map((category) {
            return FilterChip(
              label: Text(category),
              selected: false,
              onSelected: (selected) {
                if (selected) {
                  // This could be enhanced to auto-suggest condition names
                  // based on the selected category
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDiagnosisSection() {
    return _buildModernSection(
      title: 'Diagnosis Information',
      icon: Icons.medical_information,
      children: [
        ListTile(
          title: const Text('Diagnosis Date'),
          subtitle: Text(_formatDate(_diagnosisDate)),
          trailing: const Icon(Icons.calendar_today),
          onTap: () => _selectDate(context, isRecordDate: false),
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: _diagnosingProviderController,
          labelText: 'Diagnosing Healthcare Provider',
          hintText: 'e.g., Dr. Smith, Cardiology',
          prefixIcon: const Icon(Icons.person),
          focusGradient: HealthBoxDesignSystem.chronicConditionGradient,
        ),
      ],
    );
  }

  Widget _buildSeverityAndStatusSection() {
    return _buildModernSection(
      title: 'Severity & Status',
      icon: Icons.priority_high,
      children: [
        Text(
          'Severity Level',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: ConditionSeverity.allSeverities
              .map((severity) => ButtonSegment<String>(
                    value: severity,
                    label: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_getSeverityDisplayName(severity)),
                        Text(
                          _getSeverityDescription(severity),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ))
              .toList(),
          selected: {_selectedSeverity},
          onSelectionChanged: (Set<String> selection) {
            if (selection.isNotEmpty) {
              setState(() => _selectedSeverity = selection.first);
            }
          },
        ),
        const SizedBox(height: 16),
        Text(
          'Current Status',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: ConditionStatus.allStatuses
              .map((status) => ButtonSegment<String>(
                    value: status,
                    label: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_getStatusDisplayName(status)),
                        Text(
                          _getStatusDescription(status),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ))
              .toList(),
          selected: {_selectedStatus},
          onSelectionChanged: (Set<String> selection) {
            if (selection.isNotEmpty) {
              setState(() => _selectedStatus = selection.first);
            }
          },
        ),
      ],
    );
  }

  Widget _buildTreatmentSection() {
    return _buildModernSection(
      title: 'Treatment Information',
      icon: Icons.medication,
      children: [
        ModernTextField(
          controller: _treatmentController,
          labelText: 'Current Treatment',
          hintText: 'e.g., Metformin 500mg twice daily',
          prefixIcon: const Icon(Icons.medication),
          focusGradient: HealthBoxDesignSystem.chronicConditionGradient,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: _medicationsController,
          labelText: 'Related Medications',
          hintText: 'List medications related to this condition',
          prefixIcon: const Icon(Icons.local_pharmacy),
          focusGradient: HealthBoxDesignSystem.chronicConditionGradient,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildAttachmentsSection() {
    return _buildModernSection(
      title: 'Attachments',
      icon: Icons.attach_file,
      children: [
        Text(
          'Add medical reports, test results, or care plans',
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
          maxFiles: 5,
          allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
          maxFileSizeMB: 25,
        ),
      ],
    );
  }

  Widget _buildManagementSection() {
    return _buildModernSection(
      title: 'Management Plan',
      icon: Icons.assignment,
      children: [
        ModernTextField(
          controller: _managementPlanController,
          labelText: 'Management Plan',
          hintText: 'Diet, exercise, monitoring guidelines, etc.',
          prefixIcon: const Icon(Icons.assignment),
          focusGradient: HealthBoxDesignSystem.chronicConditionGradient,
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildReminderSection() {
    return _buildModernSection(
      title: 'Reminder Settings',
      icon: Icons.notifications_outlined,
      children: [
        SwitchListTile(
          title: const Text('Enable Reminders'),
          subtitle: const Text('Get reminded about check-ups, medication, or monitoring'),
          value: _enableReminder,
          onChanged: (value) {
            setState(() {
              _enableReminder = value;
            });
          },
        ),

        if (_enableReminder) ...[
              const SizedBox(height: 16),

              // Reminder Type Selector
              ReminderTypeSelector(
                selectedType: _reminderType,
                onChanged: (type) {
                  setState(() {
                    _reminderType = type;
                  });
                },
                helpText: 'Choose how you want to be reminded about this condition',
              ),

              const SizedBox(height: 16),

              // Alarm Sound Picker (only show if alarm is selected)
              if (_reminderType == ReminderType.alarm || _reminderType == ReminderType.both) ...[
                AlarmSoundPicker(
                  selectedSound: _alarmSound,
                  onSoundChanged: (sound) {
                    setState(() {
                      _alarmSound = sound;
                    });
                  },
                  showPreview: true,
                ),
                const SizedBox(height: 16),

                AlarmVolumeSlider(
                  volume: _alarmVolume,
                  onVolumeChanged: (volume) {
                    setState(() {
                      _alarmVolume = volume;
                    });
                  },
                  previewSound: _alarmSound,
                  label: 'Condition Reminder Volume',
                ),
                const SizedBox(height: 16),
              ],

              // Reminder Preview
              ReminderPreview(
                title: _conditionNameController.text.isNotEmpty
                  ? '${_conditionNameController.text} Check-up'
                  : 'Chronic Condition Reminder',
                description: _managementPlanController.text.isNotEmpty
                  ? 'Management: ${_managementPlanController.text.substring(0, _managementPlanController.text.length > 50 ? 50 : _managementPlanController.text.length)}...'
                  : 'Time for your condition check-up or medication',
                scheduledTime: DateTime.now().add(const Duration(days: 7)),
                reminderType: _reminderType,
                alarmSound: _alarmSound,
                alarmVolume: _alarmVolume,
                showTestButtons: true,
              ),
            ],
      ],
    );
  }

  Future<void> _selectDate(BuildContext context,
      {required bool isRecordDate}) async {
    final initialDate = isRecordDate ? _recordDate : _diagnosisDate;
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        if (isRecordDate) {
          _recordDate = selectedDate;
        } else {
          _diagnosisDate = selectedDate;
        }
      });
    }
  }

  Future<void> _saveChronicCondition() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = ChronicConditionService();
      final selectedProfileId = widget.profileId;

      if (selectedProfileId == null) {
        throw Exception('No profile selected');
      }

      final request = CreateChronicConditionRequest(
        profileId: selectedProfileId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        recordDate: _recordDate,
        conditionName: _conditionNameController.text.trim(),
        diagnosisDate: _diagnosisDate,
        diagnosingProvider: _diagnosingProviderController.text.trim().isEmpty
            ? null
            : _diagnosingProviderController.text.trim(),
        severity: _selectedSeverity,
        status: _selectedStatus,
        treatment: _treatmentController.text.trim().isEmpty
            ? null
            : _treatmentController.text.trim(),
        managementPlan: _managementPlanController.text.trim().isEmpty
            ? null
            : _managementPlanController.text.trim(),
        relatedMedications: _medicationsController.text.trim().isEmpty
            ? null
            : _medicationsController.text.trim(),
      );

      await service.createChronicCondition(request);

      // Refresh medical records providers
      ref.invalidate(allMedicalRecordsProvider);
      ref.invalidate(recordsByProfileIdProvider(selectedProfileId));

      // Log success
      developer.log(
        'Chronic condition created successfully for profile: $selectedProfileId',
        name: 'ChronicConditionForm',
        level: 800, // INFO level
      );

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Chronic condition saved successfully'),
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
        'Failed to save chronic condition',
        name: 'ChronicConditionForm',
        level: 1000, // ERROR level
        error: error,
        stackTrace: stackTrace,
      );

      if (mounted) {
        // Show user-friendly error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Failed to save chronic condition. Please try again.'),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _saveChronicCondition(),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getSeverityDisplayName(String severity) {
    switch (severity) {
      case ConditionSeverity.mild:
        return 'Mild';
      case ConditionSeverity.moderate:
        return 'Moderate';
      case ConditionSeverity.severe:
        return 'Severe';
      default:
        return severity;
    }
  }

  String _getSeverityDescription(String severity) {
    switch (severity) {
      case ConditionSeverity.mild:
        return 'Minimal impact on daily activities';
      case ConditionSeverity.moderate:
        return 'Some limitation on daily activities';
      case ConditionSeverity.severe:
        return 'Significant impact on daily activities';
      default:
        return '';
    }
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case ConditionStatus.active:
        return 'Active';
      case ConditionStatus.managed:
        return 'Managed';
      case ConditionStatus.resolved:
        return 'Resolved';
      default:
        return status;
    }
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case ConditionStatus.active:
        return 'Currently experiencing symptoms or requiring treatment';
      case ConditionStatus.managed:
        return 'Under control with current treatment plan';
      case ConditionStatus.resolved:
        return 'No longer active or requiring treatment';
      default:
        return '';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildModernSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
    LinearGradient? gradient,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sectionGradient = gradient ?? HealthBoxDesignSystem.chronicConditionGradient;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: sectionGradient.colors.first.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: sectionGradient.colors.first.withValues(alpha: 0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(gradient: sectionGradient),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: sectionGradient,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: sectionGradient.colors.first.withValues(alpha: 0.3),
                              offset: const Offset(0, 2),
                              blurRadius: 6,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Icon(icon, size: 18, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...children,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _conditionNameController.dispose();
    _diagnosingProviderController.dispose();
    _treatmentController.dispose();
    _managementPlanController.dispose();
    _medicationsController.dispose();
    super.dispose();
  }
}