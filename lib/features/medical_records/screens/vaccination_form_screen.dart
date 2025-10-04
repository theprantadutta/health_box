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
import '../../../shared/widgets/modern_text_field.dart';

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
    // This will be implemented with the vaccination service
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Vaccination' : 'New Vaccination'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: HealthBoxDesignSystem.vaccinationGradient,
            boxShadow: [
              BoxShadow(
                color: HealthBoxDesignSystem.vaccinationGradient.colors.first.withValues(alpha: 0.3),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
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
          padding: const EdgeInsets.all(16),
          children: [
            _buildBasicInfoSection(),
            const SizedBox(height: 16),
            _buildVaccineDetailsSection(),
            const SizedBox(height: 16),
            _buildAdministrationSection(),
            const SizedBox(height: 16),
            _buildDosageSection(),
            const SizedBox(height: 16),
            _buildAttachmentsSection(),
            const SizedBox(height: 16),
            _buildCompletionSection(),
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
          hintText: 'e.g., COVID-19 Vaccination',
          prefixIcon: const Icon(Icons.vaccines),
          focusGradient: HealthBoxDesignSystem.vaccinationGradient,
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
          hintText: 'Additional notes about this vaccination',
          focusGradient: HealthBoxDesignSystem.vaccinationGradient,
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

  Widget _buildVaccineDetailsSection() {
    return _buildModernSection(
      title: 'Vaccine Details',
      icon: Icons.medical_services,
      children: [
        ModernTextField(
          controller: _vaccineNameController,
          labelText: 'Vaccine Name *',
          hintText: 'e.g., Pfizer-BioNTech COVID-19',
          prefixIcon: const Icon(Icons.medical_services),
          focusGradient: HealthBoxDesignSystem.vaccinationGradient,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vaccine name is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _selectedManufacturer,
          decoration: const InputDecoration(
            labelText: 'Manufacturer',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.business),
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
        const SizedBox(height: 16),
        ModernTextField(
          controller: _batchNumberController,
          labelText: 'Batch/Lot Number',
          hintText: 'e.g., EJ1685',
          prefixIcon: const Icon(Icons.tag),
          focusGradient: HealthBoxDesignSystem.vaccinationGradient,
        ),
      ],
    );
  }

  Widget _buildAdministrationSection() {
    return _buildModernSection(
      title: 'Administration Details',
      icon: Icons.local_hospital,
      children: [
        ListTile(
          title: const Text('Administration Date'),
          subtitle: Text(_formatDate(_administrationDate)),
          trailing: const Icon(Icons.calendar_today),
          onTap: () => _selectDate(context, isRecordDate: false),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _selectedSite,
          decoration: const InputDecoration(
            labelText: 'Administration Site',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_on),
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
        const SizedBox(height: 16),
        ModernTextField(
          controller: _administeredByController,
          labelText: 'Administered By',
          hintText: 'Healthcare provider name',
          prefixIcon: const Icon(Icons.person),
          focusGradient: HealthBoxDesignSystem.vaccinationGradient,
        ),
      ],
    );
  }

  Widget _buildDosageSection() {
    return _buildModernSection(
      title: 'Dosage Information',
      icon: Icons.numbers,
      children: [
        ModernTextField(
          controller: _doseNumberController,
          labelText: 'Dose Number',
          hintText: 'e.g., 1, 2, 3',
          prefixIcon: const Icon(Icons.numbers),
          focusGradient: HealthBoxDesignSystem.vaccinationGradient,
          keyboardType: TextInputType.number,
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
        const SizedBox(height: 16),
        ListTile(
          title: const Text('Next Due Date'),
          subtitle: Text(_nextDueDate != null
              ? _formatDate(_nextDueDate!)
              : 'Not set'),
          trailing: const Icon(Icons.schedule),
          onTap: () => _selectNextDueDate(context),
        ),
        if (_nextDueDate != null)
          TextButton(
            onPressed: () {
              setState(() => _nextDueDate = null);
            },
            child: const Text('Clear Next Due Date'),
          ),
      ],
    );
  }

  Widget _buildCompletionSection() {
    return _buildModernSection(
      title: 'Completion Status',
      icon: Icons.check_circle_outline,
      children: [
        SwitchListTile(
          title: const Text('Mark as Complete'),
          subtitle: const Text(
            'Check this if this completes the vaccination series',
          ),
          value: _isComplete,
          onChanged: (value) {
            setState(() => _isComplete = value);
          },
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context,
      {required bool isRecordDate}) async {
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

      // Log success
      developer.log(
        'Vaccination created successfully for profile: $selectedProfileId',
        name: 'VaccinationForm',
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
                  child: Text('Vaccination saved successfully'),
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
        'Failed to save vaccination',
        name: 'VaccinationForm',
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
                  child: Text('Failed to save vaccination. Please try again.'),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  Widget _buildAttachmentsSection() {
    return _buildModernSection(
      title: 'Attachments',
      icon: Icons.attach_file,
      children: [
        Text(
          'Add vaccination cards, certificates, or related documents',
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
        const SizedBox(height: 24),
        _buildReminderSection(),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildReminderSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Enable Reminder Toggle
        Row(
          children: [
            Icon(
              Icons.schedule_outlined,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Vaccination Reminders',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
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
        const SizedBox(height: 8),
        Text(
          'Set up reminders for vaccination boosters or follow-up appointments',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (_enableReminder) ...[
          const SizedBox(height: 16),
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
            const SizedBox(height: 16),
            AlarmSoundPicker(
              selectedSound: _alarmSound,
              onSoundChanged: (sound) {
                setState(() {
                  _alarmSound = sound;
                });
              },
              previewVolume: _alarmVolume,
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
            ),
          ],
          const SizedBox(height: 16),
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

  Widget _buildModernSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
    LinearGradient? gradient,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sectionGradient = gradient ?? HealthBoxDesignSystem.vaccinationGradient;

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
    _vaccineNameController.dispose();
    _manufacturerController.dispose();
    _batchNumberController.dispose();
    _administeredByController.dispose();
    _doseNumberController.dispose();
    super.dispose();
  }
}