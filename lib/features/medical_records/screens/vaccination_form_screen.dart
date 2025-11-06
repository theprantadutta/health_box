import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;
import '../../../shared/providers/medical_records_providers.dart';
import '../services/vaccination_service.dart';
import '../../../data/models/vaccination.dart';
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

class VaccinationFormScreen extends ConsumerStatefulWidget {
  final String? profileId;
  final String? vaccinationId;

  const VaccinationFormScreen({
    super.key,
    this.profileId,
    this.vaccinationId,
  });

  @override
  ConsumerState<VaccinationFormScreen> createState() =>
      _VaccinationFormScreenState();
}

class _VaccinationFormScreenState extends ConsumerState<VaccinationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _vaccineNameController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _batchNumberController = TextEditingController();
  final _administeredByController = TextEditingController();
  final _doseNumberController = TextEditingController();

  DateTime _recordDate = DateTime.now();
  DateTime _administrationDate = DateTime.now();
  DateTime? _nextDueDate;
  String? _selectedSite;
  String? _selectedManufacturer;
  bool _isComplete = false;
  bool _isLoading = false;
  bool _isEditing = false;
  List<AttachmentResult> _attachments = [];

  // Reminder-related state
  bool _enableReminder = false;
  ReminderType _reminderType = ReminderType.notification;
  String _alarmSound = 'gentle';
  double _alarmVolume = 0.7;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.vaccinationId != null;
    if (_isEditing) {
      _loadVaccination();
    }
  }

  Future<void> _loadVaccination() async {
    // TODO: Load existing vaccination data when editing
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HBAppBar.gradient(
        title: _isEditing ? 'Edit Vaccination' : 'New Vaccination',
        gradient: RecordTypeUtils.getGradient('vaccination'),
        actions: [
          HBButton.text(
            onPressed: _isLoading ? null : _saveVaccination,
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
            _buildVaccineDetailsSection(),
            SizedBox(height: AppSpacing.base),
            _buildAdministrationSection(),
            SizedBox(height: AppSpacing.base),
            _buildDosageSection(),
            SizedBox(height: AppSpacing.base),
            _buildAttachmentsSection(),
            SizedBox(height: AppSpacing.base),
            _buildCompletionSection(),
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
            RecordTypeUtils.getGradient('vaccination'),
          ),
          SizedBox(height: AppSpacing.lg),
          HBTextField.filled(
            controller: _titleController,
            label: 'Title',
            hint: 'e.g., COVID-19 Vaccination',
            prefixIcon: Icons.vaccines,
            validator: HBValidators.required,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.multiline(
            controller: _descriptionController,
            label: 'Description',
            hint: 'Additional notes about this vaccination',
            minLines: 3,
            maxLines: 5,
          ),
          SizedBox(height: AppSpacing.base),
          _buildDateTile('Record Date', _recordDate, () => _selectDate(context, isRecordDate: true)),
        ],
      ),
    );
  }

  Widget _buildVaccineDetailsSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Vaccine Details',
            Icons.medical_services,
            AppColors.successGradient,
          ),
          SizedBox(height: AppSpacing.lg),
          HBTextField.filled(
            controller: _vaccineNameController,
            label: 'Vaccine Name',
            hint: 'e.g., Pfizer-BioNTech COVID-19',
            prefixIcon: Icons.medical_services,
            validator: HBValidators.required,
          ),
          SizedBox(height: AppSpacing.base),
          DropdownButtonFormField<String>(
            value: _selectedManufacturer,
            decoration: InputDecoration(
              labelText: 'Manufacturer',
              hintText: 'Select manufacturer',
              prefixIcon: const Icon(Icons.business),
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
            items: VaccineManufacturers.allManufacturers
                .map((manufacturer) => DropdownMenuItem(
                      value: manufacturer,
                      child: Text(manufacturer),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedManufacturer = value;
                _manufacturerController.text = value ?? '';
              });
            },
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.filled(
            controller: _batchNumberController,
            label: 'Batch/Lot Number',
            hint: 'e.g., EJ1685',
            prefixIcon: Icons.tag,
          ),
        ],
      ),
    );
  }

  Widget _buildAdministrationSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Administration Details',
            Icons.local_hospital,
            AppColors.primaryGradient,
          ),
          SizedBox(height: AppSpacing.lg),
          _buildDateTile('Administration Date', _administrationDate, () => _selectDate(context, isRecordDate: false)),
          SizedBox(height: AppSpacing.base),
          DropdownButtonFormField<String>(
            value: _selectedSite,
            decoration: InputDecoration(
              labelText: 'Administration Site',
              hintText: 'Select site',
              prefixIcon: const Icon(Icons.location_on),
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
            items: VaccinationSites.allSites
                .map((site) => DropdownMenuItem(
                      value: site,
                      child: Text(site),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() => _selectedSite = value);
            },
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.filled(
            controller: _administeredByController,
            label: 'Administered By',
            hint: 'Healthcare provider name',
            prefixIcon: Icons.person,
          ),
        ],
      ),
    );
  }

  Widget _buildDosageSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Dosage Information',
            Icons.numbers,
            AppColors.secondaryGradient,
          ),
          SizedBox(height: AppSpacing.lg),
          HBTextField.number(
            controller: _doseNumberController,
            label: 'Dose Number',
            hint: 'e.g., 1, 2, 3',
            prefixIcon: Icons.numbers,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final dose = int.tryParse(value);
                if (dose == null || dose <= 0) {
                  return 'Dose number must be a positive integer';
                }
              }
              return null;
            },
          ),
          SizedBox(height: AppSpacing.base),
          _buildDateTile(
            'Next Due Date',
            _nextDueDate,
            () => _selectNextDueDate(context),
            optional: true,
          ),
          if (_nextDueDate != null) ...[
            SizedBox(height: AppSpacing.sm),
            HBButton.text(
              onPressed: () {
                setState(() => _nextDueDate = null);
              },
              child: const Text('Clear Next Due Date'),
            ),
          ],
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
            'Add vaccination cards, certificates, or related documents',
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
          SizedBox(height: AppSpacing.xl),
          _buildReminderSection(),
        ],
      ),
    );
  }

  Widget _buildCompletionSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Completion Status',
            Icons.check_circle_outline,
            AppColors.successGradient,
          ),
          SizedBox(height: AppSpacing.base),
          HBListTile.switchTile(
            title: 'Mark as Complete',
            subtitle: 'Check this if this completes the vaccination series',
            icon: Icons.check_circle,
            value: _isComplete,
            onChanged: (value) {
              setState(() => _isComplete = value);
            },
            iconColor: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildReminderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.schedule_outlined,
              color: context.colorScheme.primary,
              size: AppSizes.iconMd,
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              'Vaccination Reminders',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: AppTypography.fontWeightSemiBold,
                color: context.colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            Switch(
              value: _enableReminder,
              onChanged: (value) {
                setState(() {
                  _enableReminder = value;
                });
              },
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          'Set up reminders for vaccination boosters or follow-up appointments',
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
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
            helpText: 'Choose how you want to be reminded about this vaccination',
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
              previewVolume: _alarmVolume,
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
            ),
          ],
          SizedBox(height: AppSpacing.base),
          ReminderPreview(
            title: _titleController.text.isNotEmpty
              ? 'Vaccination Reminder: ${_titleController.text}'
              : 'Vaccination Reminder',
            description: _nextDueDate != null
              ? 'Next dose due for ${_vaccineNameController.text.isNotEmpty ? _vaccineNameController.text : "vaccination"}'
              : 'Follow-up reminder for vaccination',
            scheduledTime: _nextDueDate ?? DateTime.now().add(const Duration(days: 30)),
            reminderType: _reminderType,
            alarmSound: _alarmSound,
            alarmVolume: _alarmVolume,
          ),
        ],
      ],
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
    final initialDate = isRecordDate ? _recordDate : _administrationDate;
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );

    if (selectedDate != null) {
      setState(() {
        if (isRecordDate) {
          _recordDate = selectedDate;
        } else {
          _administrationDate = selectedDate;
        }
      });
    }
  }

  Future<void> _selectNextDueDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _nextDueDate ?? _administrationDate.add(const Duration(days: 30)),
      firstDate: _administrationDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (selectedDate != null) {
      setState(() => _nextDueDate = selectedDate);
    }
  }

  Future<void> _saveVaccination() async {
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
      final service = VaccinationService();
      final selectedProfileId = widget.profileId;

      if (selectedProfileId == null) {
        throw Exception('No profile selected');
      }

      final request = CreateVaccinationRequest(
        profileId: selectedProfileId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        recordDate: _recordDate,
        vaccineName: _vaccineNameController.text.trim(),
        manufacturer: _manufacturerController.text.trim().isEmpty
            ? null
            : _manufacturerController.text.trim(),
        batchNumber: _batchNumberController.text.trim().isEmpty
            ? null
            : _batchNumberController.text.trim(),
        administrationDate: _administrationDate,
        administeredBy: _administeredByController.text.trim().isEmpty
            ? null
            : _administeredByController.text.trim(),
        site: _selectedSite,
        nextDueDate: _nextDueDate,
        doseNumber: _doseNumberController.text.trim().isEmpty
            ? null
            : int.tryParse(_doseNumberController.text.trim()),
        isComplete: _isComplete,
      );

      await service.createVaccination(request);

      developer.log(
        'Vaccination created successfully for profile: $selectedProfileId',
        name: 'VaccinationForm',
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
                const Expanded(
                  child: Text('Vaccination saved successfully'),
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
        'Failed to save vaccination',
        name: 'VaccinationForm',
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
                  child: Text('Failed to save vaccination. Please try again.'),
                ),
              ],
            ),
            backgroundColor: context.colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadii.radiusMd),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _saveVaccination(),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _vaccineNameController.dispose();
    _manufacturerController.dispose();
    _batchNumberController.dispose();
    _administeredByController.dispose();
    _doseNumberController.dispose();
    super.dispose();
  }
}
