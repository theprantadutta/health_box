import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/database/app_database.dart';
import '../../../shared/providers/profile_providers.dart';
import '../../../shared/providers/medical_records_providers.dart';
import '../services/prescription_service.dart';
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
import '../../../shared/widgets/hb_list_tile.dart';
import '../../../shared/widgets/hb_state_widgets.dart';
import 'dart:developer' as developer;

class PrescriptionFormScreen extends ConsumerStatefulWidget {
  final String? profileId;
  final Prescription? prescription;

  const PrescriptionFormScreen({super.key, this.profileId, this.prescription});

  @override
  ConsumerState<PrescriptionFormScreen> createState() =>
      _PrescriptionFormScreenState();
}

class _PrescriptionFormScreenState
    extends ConsumerState<PrescriptionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _medicationNameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _doctorController = TextEditingController();
  final _pharmacyController = TextEditingController();
  final _refillsController = TextEditingController();

  DateTime? _recordDate;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedProfileId;
  bool _isActive = true;
  bool _isLoading = false;
  List<AttachmentResult> _attachments = [];

  // Reminder settings
  bool _enableReminder = false;
  ReminderType _reminderType = ReminderType.notification;
  String _alarmSound = 'gentle';
  double _alarmVolume = 0.7;

  bool get _isEditing => widget.prescription != null;

  @override
  void initState() {
    super.initState();
    _selectedProfileId = widget.profileId;
    _initializeFields();
  }

  void _initializeFields() {
    if (_isEditing) {
      final prescription = widget.prescription!;
      _titleController.text = prescription.title;
      _descriptionController.text = prescription.description ?? '';
      _medicationNameController.text = prescription.medicationName ?? '';
      _dosageController.text = prescription.dosage ?? '';
      _frequencyController.text = prescription.frequency ?? '';
      _instructionsController.text = prescription.instructions ?? '';
      _doctorController.text = prescription.prescribingDoctor ?? '';
      _pharmacyController.text = prescription.pharmacy ?? '';
      _refillsController.text = prescription.refillsRemaining?.toString() ?? '';
      _recordDate = prescription.recordDate;
      _startDate = prescription.startDate;
      _endDate = prescription.endDate;
      _selectedProfileId = prescription.profileId;
      _isActive = prescription.isPrescriptionActive;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profilesAsync = ref.watch(allProfilesProvider);

    return Scaffold(
      appBar: HBAppBar.gradient(
        title: _isEditing ? 'Edit Prescription' : 'New Prescription',
        gradient: RecordTypeUtils.getGradient('prescription'),
        actions: [
          if (_isLoading)
            Padding(
              padding: EdgeInsets.all(AppSpacing.base),
              child: const HBLoading.small(centered: false),
            )
          else
            HBButton.text(
              onPressed: _savePrescription,
              child: const Text('SAVE', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(context.responsivePadding),
          children: [
            // Profile Selection
            if (!_isEditing) _buildProfileSelection(profilesAsync),

            _buildBasicInfoSection(),
            SizedBox(height: AppSpacing.base),
            _buildMedicationInfoSection(),
            SizedBox(height: AppSpacing.base),
            _buildPrescriptionDetailsSection(),
            SizedBox(height: AppSpacing.base),
            _buildReminderSettingsSection(),
            SizedBox(height: AppSpacing.xl2),
            _buildSaveButton(),
            SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSelection(
    AsyncValue<List<FamilyMemberProfile>> profilesAsync,
  ) {
    return Column(
      children: [
        profilesAsync.when(
          loading: () => const HBLoading.medium(),
          error: (error, stack) => HBErrorState(
            errorMessage: 'Error loading profiles: $error',
          ),
          data: (profiles) => HBCard.elevated(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  'Select Profile',
                  Icons.person,
                  AppColors.primaryGradient,
                ),
                SizedBox(height: AppSpacing.base),
                DropdownButtonFormField<String?>(
                  value: _selectedProfileId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Family Member',
                    hintText: 'Select family member',
                    prefixIcon: const Icon(Icons.person),
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
                  items: profiles
                      .map(
                        (profile) => DropdownMenuItem<String?>(
                          value: profile.id,
                          child: Text('${profile.firstName} ${profile.lastName}'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedProfileId = value),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: AppSpacing.base),
        _buildAttachmentsSection(),
        SizedBox(height: AppSpacing.base),
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
            'Add prescription images, doctor notes, or pharmacy receipts',
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
            maxFiles: 8,
            allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
            maxFileSizeMB: 25,
          ),
        ],
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
            RecordTypeUtils.getGradient('prescription'),
          ),
          SizedBox(height: AppSpacing.lg),
          HBTextField.filled(
            controller: _titleController,
            label: 'Title',
            hint: 'Prescription title',
            prefixIcon: Icons.title,
            validator: HBValidators.required,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.multiline(
            controller: _descriptionController,
            label: 'Description',
            hint: 'Additional details',
            minLines: 3,
            maxLines: 5,
          ),
          SizedBox(height: AppSpacing.base),
          _buildDateField('Record Date', _recordDate, (date) {
            setState(() => _recordDate = date);
          }, required: true),
        ],
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
            controller: _medicationNameController,
            label: 'Medication Name',
            hint: 'Enter medication name',
            prefixIcon: Icons.medication,
            validator: HBValidators.required,
          ),
          SizedBox(height: AppSpacing.base),
          Row(
            children: [
              Expanded(
                child: HBTextField.filled(
                  controller: _dosageController,
                  label: 'Dosage',
                  hint: 'e.g., 10mg',
                  prefixIcon: Icons.straighten,
                  validator: HBValidators.required,
                ),
              ),
              SizedBox(width: AppSpacing.base),
              Expanded(
                child: HBTextField.filled(
                  controller: _frequencyController,
                  label: 'Frequency',
                  hint: 'e.g., Twice daily',
                  prefixIcon: Icons.schedule,
                  validator: HBValidators.required,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.multiline(
            controller: _instructionsController,
            label: 'Instructions',
            hint: 'Take with food, etc.',
            minLines: 2,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionDetailsSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Prescription Details',
            Icons.receipt_long,
            AppColors.successGradient,
          ),
          SizedBox(height: AppSpacing.lg),
          HBTextField.filled(
            controller: _doctorController,
            label: 'Prescribing Doctor',
            hint: 'Doctor name',
            prefixIcon: Icons.person_pin_circle,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.filled(
            controller: _pharmacyController,
            label: 'Pharmacy',
            hint: 'Pharmacy name',
            prefixIcon: Icons.local_pharmacy,
          ),
          SizedBox(height: AppSpacing.base),
          Row(
            children: [
              Expanded(
                child: _buildDateField('Start Date', _startDate, (date) {
                  setState(() => _startDate = date);
                }),
              ),
              SizedBox(width: AppSpacing.base),
              Expanded(
                child: _buildDateField('End Date', _endDate, (date) {
                  setState(() => _endDate = date);
                }),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.number(
            controller: _refillsController,
            label: 'Refills Remaining',
            hint: 'Number of refills',
            prefixIcon: Icons.repeat,
          ),
          SizedBox(height: AppSpacing.base),
          HBListTile.switchTile(
            title: 'Active',
            subtitle: 'Is prescription currently active?',
            icon: Icons.medication,
            value: _isActive,
            onChanged: (value) => setState(() => _isActive = value),
            iconColor: context.colorScheme.primary,
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
            Icons.notifications_active,
            AppColors.warningGradient,
          ),
          SizedBox(height: AppSpacing.base),
          HBListTile.switchTile(
            title: 'Enable Reminders',
            subtitle: 'Get reminded when it\'s time to take your prescription',
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
              helpText: 'Choose how you want to be reminded about your prescription',
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
                label: 'Prescription Alarm Volume',
              ),
            ],
            SizedBox(height: AppSpacing.base),
            ReminderPreview(
              title: _medicationNameController.text.isNotEmpty
                ? 'Take ${_medicationNameController.text}'
                : 'Prescription Reminder',
              description: _dosageController.text.isNotEmpty
                ? 'Dosage: ${_dosageController.text}'
                : 'Time to take your prescription',
              scheduledTime: DateTime.now().add(const Duration(hours: 1)),
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

  Widget _buildDateField(
    String label,
    DateTime? date,
    ValueChanged<DateTime> onChanged, {
    bool required = false,
  }) {
    return InkWell(
      onTap: () => _selectDate(onChanged),
      borderRadius: AppRadii.radiusMd,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          prefixIcon: const Icon(Icons.calendar_today),
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
        child: Text(
          date != null
              ? '${date.day}/${date.month}/${date.year}'
              : 'Select date',
          style: date != null
              ? null
              : TextStyle(color: context.colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return HBButton.primary(
      onPressed: _isLoading ? null : _savePrescription,
      icon: _isLoading ? null : (_isEditing ? Icons.save : Icons.add),
      child: _isLoading
          ? const HBLoading.small(centered: false)
          : Text(_isEditing ? 'Save Changes' : 'Add Prescription'),
    );
  }

  Future<void> _selectDate(ValueChanged<DateTime> onChanged) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) onChanged(picked);
  }

  Future<void> _savePrescription() async {
    if (!_formKey.currentState!.validate() ||
        _recordDate == null ||
        _selectedProfileId == null) {
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
      final service = ref.read(prescriptionServiceProvider);
      final selectedProfileId = widget.profileId;

      if (selectedProfileId == null) {
        throw Exception('No profile selected');
      }

      if (_isEditing && widget.prescription != null) {
        final request = UpdatePrescriptionRequest(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          dosage: _dosageController.text.trim().isEmpty
              ? null
              : _dosageController.text.trim(),
          prescribingDoctor: _doctorController.text.trim().isEmpty
              ? null
              : _doctorController.text.trim(),
          pharmacy: _pharmacyController.text.trim().isEmpty
              ? null
              : _pharmacyController.text.trim(),
          startDate: _startDate,
          endDate: _endDate,
          refillsRemaining: _refillsController.text.trim().isEmpty
              ? null
              : int.tryParse(_refillsController.text.trim()),
        );

        await service.updatePrescription(widget.prescription!.id, request);
      } else {
        final request = CreatePrescriptionRequest(
          profileId: selectedProfileId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          recordDate: _startDate ?? DateTime.now(),
          medicationName: _medicationNameController.text.trim().isEmpty
              ? null
              : _medicationNameController.text.trim(),
          dosage: _dosageController.text.trim().isEmpty
              ? null
              : _dosageController.text.trim(),
          frequency: _frequencyController.text.trim().isEmpty
              ? null
              : _frequencyController.text.trim(),
          instructions: _instructionsController.text.trim().isEmpty
              ? null
              : _instructionsController.text.trim(),
          prescribingDoctor: _doctorController.text.trim().isEmpty
              ? null
              : _doctorController.text.trim(),
          pharmacy: _pharmacyController.text.trim().isEmpty
              ? null
              : _pharmacyController.text.trim(),
          startDate: _startDate,
          endDate: _endDate,
          refillsRemaining: _refillsController.text.trim().isEmpty
              ? null
              : int.tryParse(_refillsController.text.trim()),
          isPrescriptionActive: true,
        );

        await service.createPrescription(request);
      }

      developer.log(
        _isEditing
          ? 'Prescription updated successfully: ${widget.prescription!.id}'
          : 'Prescription created successfully for profile: $selectedProfileId',
        name: 'PrescriptionForm',
        level: 800,
      );

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
                Expanded(
                  child: Text(
                    _isEditing
                        ? 'Prescription updated successfully'
                        : 'Prescription saved successfully',
                  ),
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
        'Failed to save prescription',
        name: 'PrescriptionForm',
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
                  child: Text('Failed to save. Please try again.'),
                ),
              ],
            ),
            backgroundColor: context.colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadii.radiusMd),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _savePrescription(),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _medicationNameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _instructionsController.dispose();
    _doctorController.dispose();
    _pharmacyController.dispose();
    _refillsController.dispose();
    super.dispose();
  }
}
