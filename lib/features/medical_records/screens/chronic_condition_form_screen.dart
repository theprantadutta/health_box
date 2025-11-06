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
import '../../../shared/widgets/hb_app_bar.dart';
import '../../../shared/widgets/hb_text_field.dart';
import '../../../shared/widgets/hb_button.dart';
import '../../../shared/widgets/hb_card.dart';
import '../../../shared/widgets/hb_chip.dart';
import '../../../shared/widgets/hb_list_tile.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HBAppBar.gradient(
        title: _isEditing ? 'Edit Chronic Condition' : 'New Chronic Condition',
        gradient: RecordTypeUtils.getGradient('chronic_condition'),
        actions: [
          HBButton.text(
            onPressed: _isLoading ? null : _saveChronicCondition,
            child: Text(
              _isLoading ? 'SAVING...' : 'SAVE',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(context.responsivePadding),
          children: [
            _buildBasicInfoSection(),
            SizedBox(height: AppSpacing.base),
            _buildConditionDetailsSection(),
            SizedBox(height: AppSpacing.base),
            _buildDiagnosisSection(),
            SizedBox(height: AppSpacing.base),
            _buildSeverityAndStatusSection(),
            SizedBox(height: AppSpacing.base),
            _buildTreatmentSection(),
            SizedBox(height: AppSpacing.base),
            _buildAttachmentsSection(),
            SizedBox(height: AppSpacing.base),
            _buildManagementSection(),
            SizedBox(height: AppSpacing.base),
            _buildReminderSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Basic Information',
            Icons.info_outline,
            RecordTypeUtils.getGradient('chronic_condition'),
          ),
          SizedBox(height: AppSpacing.lg),
          HBTextField.filled(
            controller: _titleController,
            label: 'Title',
            hint: 'e.g., Type 2 Diabetes Management',
            prefixIcon: Icons.medical_information,
            validator: HBValidators.required,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.multiline(
            controller: _descriptionController,
            label: 'Description',
            hint: 'Additional details about this condition',
            minLines: 3,
            maxLines: 5,
          ),
          SizedBox(height: AppSpacing.base),
          _buildDateTile('Record Date', _recordDate, () => _selectDate(context, isRecordDate: true)),
        ],
      ),
    );
  }

  Widget _buildConditionDetailsSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Condition Details',
            Icons.local_hospital,
            AppColors.primaryGradient,
          ),
          SizedBox(height: AppSpacing.lg),
          HBTextField.filled(
            controller: _conditionNameController,
            label: 'Condition Name',
            hint: 'e.g., Type 2 Diabetes, Hypertension',
            prefixIcon: Icons.local_hospital,
            validator: HBValidators.required,
          ),
          SizedBox(height: AppSpacing.base),
          Text(
            'Common Condition Categories',
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: AppTypography.fontWeightMedium,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: ConditionCategories.allCategories.map((category) {
              return HBChip.filter(
                label: category,
                selected: false,
                onSelected: (selected) {
                  // Could auto-suggest based on category
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosisSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Diagnosis Information',
            Icons.medical_information,
            AppColors.secondaryGradient,
          ),
          SizedBox(height: AppSpacing.lg),
          _buildDateTile('Diagnosis Date', _diagnosisDate, () => _selectDate(context, isRecordDate: false)),
          SizedBox(height: AppSpacing.base),
          HBTextField.filled(
            controller: _diagnosingProviderController,
            label: 'Diagnosing Healthcare Provider',
            hint: 'e.g., Dr. Smith, Cardiology',
            prefixIcon: Icons.person,
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityAndStatusSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Severity & Status',
            Icons.priority_high,
            AppColors.warningGradient,
          ),
          SizedBox(height: AppSpacing.base),
          Text(
            'Severity Level',
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: AppTypography.fontWeightMedium,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
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
                            style: context.textTheme.bodySmall,
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
          SizedBox(height: AppSpacing.base),
          Text(
            'Current Status',
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: AppTypography.fontWeightMedium,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
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
                            style: context.textTheme.bodySmall,
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
      ),
    );
  }

  Widget _buildTreatmentSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Treatment Information',
            Icons.medication,
            AppColors.successGradient,
          ),
          SizedBox(height: AppSpacing.lg),
          HBTextField.multiline(
            controller: _treatmentController,
            label: 'Current Treatment',
            hint: 'e.g., Metformin 500mg twice daily',
            minLines: 3,
            maxLines: 5,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.multiline(
            controller: _medicationsController,
            label: 'Related Medications',
            hint: 'List medications related to this condition',
            minLines: 2,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Attachments',
            Icons.attach_file,
            AppColors.secondaryGradient,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Add medical reports, test results, or care plans',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppSpacing.base),
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
      ),
    );
  }

  Widget _buildManagementSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Management Plan',
            Icons.assignment,
            AppColors.primaryGradient,
          ),
          SizedBox(height: AppSpacing.lg),
          HBTextField.multiline(
            controller: _managementPlanController,
            label: 'Management Plan',
            hint: 'Diet, exercise, monitoring guidelines, etc.',
            minLines: 4,
            maxLines: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildReminderSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Reminder Settings',
            Icons.notifications_outlined,
            AppColors.warningGradient,
          ),
          SizedBox(height: AppSpacing.base),
          HBListTile.switchTile(
            title: 'Enable Reminders',
            subtitle: 'Get reminded about check-ups, medication, or monitoring',
            icon: Icons.notifications,
            value: _enableReminder,
            onChanged: (value) {
              setState(() {
                _enableReminder = value;
              });
            },
            iconColor: AppColors.warning,
          ),
          if (_enableReminder) ...[
            SizedBox(height: AppSpacing.base),
            ReminderTypeSelector(
              selectedType: _reminderType,
              onChanged: (type) {
                setState(() {
                  _reminderType = type;
                });
              },
              helpText: 'Choose how you want to be reminded about this condition',
            ),
            if (_reminderType == ReminderType.alarm || _reminderType == ReminderType.both) ...[
              SizedBox(height: AppSpacing.base),
              AlarmSoundPicker(
                selectedSound: _alarmSound,
                onSoundChanged: (sound) {
                  setState(() {
                    _alarmSound = sound;
                  });
                },
                showPreview: true,
              ),
              SizedBox(height: AppSpacing.base),
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
            ],
            SizedBox(height: AppSpacing.base),
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
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Gradient gradient) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(AppRadii.md),
            boxShadow: AppElevation.coloredShadow(
              gradient.colors.first,
              opacity: 0.3,
            ),
          ),
          child: Icon(icon, size: AppSizes.iconMd, color: Colors.white),
        ),
        SizedBox(width: AppSpacing.md),
        Text(
          title,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: AppTypography.fontWeightSemiBold,
            color: context.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildDateTile(String label, DateTime? date, VoidCallback onTap, {bool optional = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.radiusMd,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHighest,
          borderRadius: AppRadii.radiusMd,
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: context.colorScheme.onSurfaceVariant,
              size: AppSizes.iconMd,
            ),
            SizedBox(width: AppSpacing.base),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    date != null ? _formatDate(date) : (optional ? 'Not set' : 'Select date'),
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: date != null ? context.colorScheme.onSurface : context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: context.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, {required bool isRecordDate}) async {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber, color: Colors.white, size: 20),
              SizedBox(width: AppSpacing.sm),
              const Expanded(
                child: Text('Please fill in all required fields'),
              ),
            ],
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadii.radiusMd),
        ),
      );
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

      ref.invalidate(allMedicalRecordsProvider);
      ref.invalidate(recordsByProfileIdProvider(selectedProfileId));

      developer.log(
        'Chronic condition created successfully for profile: $selectedProfileId',
        name: 'ChronicConditionForm',
        level: 800,
      );

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                SizedBox(width: AppSpacing.sm),
                const Expanded(
                  child: Text('Chronic condition saved successfully'),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadii.radiusMd),
          ),
        );
      }
    } catch (error, stackTrace) {
      developer.log(
        'Failed to save chronic condition',
        name: 'ChronicConditionForm',
        level: 1000,
        error: error,
        stackTrace: stackTrace,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                SizedBox(width: AppSpacing.sm),
                const Expanded(
                  child: Text('Failed to save chronic condition. Please try again.'),
                ),
              ],
            ),
            backgroundColor: context.colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadii.radiusMd),
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
        return 'Minimal impact';
      case ConditionSeverity.moderate:
        return 'Some limitation';
      case ConditionSeverity.severe:
        return 'Significant impact';
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
        return 'Experiencing symptoms';
      case ConditionStatus.managed:
        return 'Under control';
      case ConditionStatus.resolved:
        return 'No longer active';
      default:
        return '';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
