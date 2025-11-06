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
import '../../../shared/widgets/reminder_type_selector.dart';
import '../../../shared/theme/design_system.dart';
import '../../../shared/widgets/hb_app_bar.dart';
import '../../../shared/widgets/hb_text_field.dart';
import '../../../shared/widgets/hb_button.dart';
import '../../../shared/widgets/hb_card.dart';
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
      appBar: HBAppBar.gradient(
        title: 'New Medication',
        gradient: RecordTypeUtils.getGradient('medication'),
        actions: [
          HBButton.text(
            onPressed: _isLoading ? null : _saveMedication,
            child: const Text('SAVE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(context.responsivePadding),
          children: [
            _buildMedicationInfoSection(),
            SizedBox(height: AppSpacing.base),
            _buildAttachmentsSection(),
            SizedBox(height: AppSpacing.base),
            _buildReminderSettingsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationInfoSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Medication Information',
            Icons.medication,
            RecordTypeUtils.getGradient('medication'),
          ),
          SizedBox(height: AppSpacing.lg),
          HBTextField.filled(
            controller: _nameController,
            label: 'Medication Name',
            hint: 'Enter medication name',
            prefixIcon: Icons.medication,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Medication name is required';
              }
              return null;
            },
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.filled(
            controller: _dosageController,
            label: 'Dosage',
            hint: 'e.g., 10mg',
            prefixIcon: Icons.straighten,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Dosage is required';
              }
              return null;
            },
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.filled(
            controller: _frequencyController,
            label: 'Frequency',
            hint: 'e.g., Twice daily',
            prefixIcon: Icons.schedule,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Frequency is required';
              }
              return null;
            },
          ),
          SizedBox(height: AppSpacing.base),
          _buildBatchDropdown(),
        ],
      ),
    );
  }

  Widget _buildBatchDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _selectedBatchId,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Medication Batch (Optional)',
            hintText: 'Select a batch for this medication',
            prefixIcon: const Icon(Icons.group_work),
            filled: true,
            fillColor: context.colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: AppRadii.radiusMd,
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.base,
              vertical: AppSpacing.md,
            ),
          ),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('No batch (individual medication)'),
            ),
            ..._availableBatches.map((batch) {
              return DropdownMenuItem<String>(
                value: batch.id,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(batch.name),
                    Text(
                      _getBatchDescription(batch),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          onChanged: (value) {
            setState(() => _selectedBatchId = value);
          },
        ),
        if (_selectedBatchId != null) ...[
          SizedBox(height: AppSpacing.sm),
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: context.colorScheme.primaryContainer,
              borderRadius: AppRadii.radiusMd,
              border: Border.all(
                color: context.colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info,
                  color: context.colorScheme.onPrimaryContainer,
                  size: AppSizes.iconSm,
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'This medication will be included in batch reminders. Individual reminder settings will be ignored.',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
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
            'Add medication labels, pill images, or doctor instructions',
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
            maxFiles: 6,
            allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
            maxFileSizeMB: 25,
          ),
        ],
      ),
    );
  }

  Widget _buildReminderSettingsSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Reminder Settings',
            Icons.notifications,
            AppColors.warningGradient,
          ),
          SizedBox(height: AppSpacing.base),
          ReminderSettingsWidget(
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
          ),
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

  Future<void> _saveMedication() async {
    developer.log('Starting medication save process', name: 'MedicationForm', level: 800);

    if (!_formKey.currentState!.validate()) {
      developer.log('Form validation failed', name: 'MedicationForm', level: 900);
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

    developer.log('Form validation passed', name: 'MedicationForm', level: 800);

    // Validate reminders if enabled
    if (_remindersEnabled && _reminderTimes.isEmpty) {
      developer.log('Reminders enabled but no times set', name: 'MedicationForm', level: 900);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber, color: Colors.white, size: 20),
              SizedBox(width: AppSpacing.sm),
              const Expanded(
                child: Text('Please add at least one reminder time or disable reminders'),
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
        reminderType: _reminderType.value,
        alarmSound: _alarmSound,
        alarmVolume: _alarmVolume,
        snoozeMinutes: _snoozeMinutes,
        reminderFrequency: _reminderFrequency,
      );

      developer.log('Calling service.createMedication with request', name: 'MedicationForm', level: 800);
      await service.createMedication(request);
      developer.log('Service.createMedication completed successfully', name: 'MedicationForm', level: 800);

      developer.log(
        'Medication created successfully for profile: $selectedProfileId',
        name: 'MedicationForm',
        level: 800,
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
                SizedBox(width: AppSpacing.sm),
                const Expanded(
                  child: Text('Medication saved successfully'),
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
        'Failed to save medication',
        name: 'MedicationForm',
        level: 1000,
        error: error,
        stackTrace: stackTrace,
      );

      if (mounted) {
        final errorMessage = error.toString().length > 100
            ? 'Failed to save medication. Please try again.'
            : 'Error: ${error.toString()}';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(errorMessage),
                ),
              ],
            ),
            backgroundColor: context.colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadii.radiusMd),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _saveMedication(),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    super.dispose();
  }
}
