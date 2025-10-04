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
import '../../../shared/widgets/modern_text_field.dart';
import '../../../shared/theme/design_system.dart';
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

  bool _basicInfoExpanded = true;
  bool _medicationInfoExpanded = true;
  bool _prescriptionDetailsExpanded = true;
  bool _reminderSettingsExpanded = true;

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

  @override
  Widget build(BuildContext context) {
    final profilesAsync = ref.watch(allProfilesProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: HealthBoxDesignSystem.prescriptionGradient,
            boxShadow: [
              BoxShadow(
                color: HealthBoxDesignSystem.prescriptionGradient.colors.first.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        title: Text(
          _isEditing ? 'Edit Prescription' : 'New Prescription',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _savePrescription,
              child: const Text(
                'SAVE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile Selection
            if (!_isEditing) _buildProfileSelection(profilesAsync),

            // Basic Information
            _buildExpandableSection(
              title: 'Basic Information',
              icon: Icons.info_outline,
              isExpanded: _basicInfoExpanded,
              onExpansionChanged: (value) => setState(() => _basicInfoExpanded = value),
              children: [
                ModernTextField(
                  controller: _titleController,
                  labelText: 'Title *',
                  prefixIcon: const Icon(Icons.title),
                  focusGradient: HealthBoxDesignSystem.medicalBlue,
                  validator: (value) =>
                      value?.trim().isEmpty == true ? 'Title is required' : null,
                ),
                const SizedBox(height: 16),

                ModernTextField(
                  controller: _descriptionController,
                  labelText: 'Description',
                  prefixIcon: const Icon(Icons.description),
                  focusGradient: HealthBoxDesignSystem.medicalBlue,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                _buildDateField('Record Date *', _recordDate, (date) {
                  setState(() => _recordDate = date);
                }),
              ],
            ),

            const SizedBox(height: 24),

            // Medication Information
            _buildExpandableSection(
              title: 'Medication Information',
              icon: Icons.medication,
              isExpanded: _medicationInfoExpanded,
              onExpansionChanged: (value) => setState(() => _medicationInfoExpanded = value),
              gradient: HealthBoxDesignSystem.medicationGradient,
              children: [
                ModernTextField(
                  controller: _medicationNameController,
                  labelText: 'Medication Name *',
                  prefixIcon: const Icon(Icons.medication),
                  focusGradient: HealthBoxDesignSystem.medicationGradient,
                  validator: (value) => value?.trim().isEmpty == true
                      ? 'Medication name is required'
                      : null,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: ModernTextField(
                        controller: _dosageController,
                        labelText: 'Dosage *',
                        hintText: 'e.g., 10mg',
                        prefixIcon: const Icon(Icons.straighten),
                        focusGradient: HealthBoxDesignSystem.medicationGradient,
                        validator: (value) => value?.trim().isEmpty == true
                            ? 'Dosage is required'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ModernTextField(
                        controller: _frequencyController,
                        labelText: 'Frequency *',
                        hintText: 'e.g., Twice daily',
                        prefixIcon: const Icon(Icons.schedule),
                        focusGradient: HealthBoxDesignSystem.medicationGradient,
                        validator: (value) => value?.trim().isEmpty == true
                            ? 'Frequency is required'
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                ModernTextField(
                  controller: _instructionsController,
                  labelText: 'Instructions',
                  hintText: 'Take with food, etc.',
                  prefixIcon: const Icon(Icons.info),
                  focusGradient: HealthBoxDesignSystem.medicationGradient,
                  maxLines: 2,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Prescription Details
            _buildExpandableSection(
              title: 'Prescription Details',
              icon: Icons.receipt_long,
              isExpanded: _prescriptionDetailsExpanded,
              onExpansionChanged: (value) => setState(() => _prescriptionDetailsExpanded = value),
              gradient: HealthBoxDesignSystem.medicalGreen,
              children: [
                ModernTextField(
                  controller: _doctorController,
                  labelText: 'Prescribing Doctor',
                  prefixIcon: const Icon(Icons.person_pin_circle),
                  focusGradient: HealthBoxDesignSystem.medicalGreen,
                ),
                const SizedBox(height: 16),

                ModernTextField(
                  controller: _pharmacyController,
                  labelText: 'Pharmacy',
                  prefixIcon: const Icon(Icons.local_pharmacy),
                  focusGradient: HealthBoxDesignSystem.medicalGreen,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildDateField('Start Date', _startDate, (date) {
                        setState(() => _startDate = date);
                      }),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDateField('End Date', _endDate, (date) {
                        setState(() => _endDate = date);
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                ModernTextField(
                  controller: _refillsController,
                  labelText: 'Refills Remaining',
                  prefixIcon: const Icon(Icons.repeat),
                  focusGradient: HealthBoxDesignSystem.medicalGreen,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                Card(
                  child: SwitchListTile(
                    title: const Text('Active'),
                    subtitle: const Text('Is prescription currently active?'),
                    value: _isActive,
                    onChanged: (value) => setState(() => _isActive = value),
                    secondary: const Icon(Icons.medication),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Reminder Settings
            _buildExpandableSection(
              title: 'Reminder Settings',
              icon: Icons.notifications_active,
              isExpanded: _reminderSettingsExpanded,
              onExpansionChanged: (value) => setState(() => _reminderSettingsExpanded = value),
              gradient: HealthBoxDesignSystem.medicalOrange,
              children: [
                _buildReminderSection(),
              ],
            ),

            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _savePrescription,
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(_isEditing ? Icons.save : Icons.add),
                label: Text(_isEditing ? 'Save Changes' : 'Add Prescription'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSelection(
    AsyncValue<List<FamilyMemberProfile>> profilesAsync,
  ) {
    return profilesAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error loading profiles: $error'),
      data: (profiles) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Select Profile'),
          const SizedBox(height: 16),
          InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Family Member *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: _selectedProfileId,
                isExpanded: true,
                hint: const Text('Select family member'),
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
            ),
          ),
          const SizedBox(height: 24),
          _buildAttachmentsSection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAttachmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Attachments'),
        const SizedBox(height: 8),
        Text(
          'Add prescription images, doctor notes, or pharmacy receipts',
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
          maxFiles: 8,
          allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
          maxFileSizeMB: 25,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildDateField(
    String label,
    DateTime? date,
    ValueChanged<DateTime> onChanged,
  ) {
    return InkWell(
      onTap: () => _selectDate(onChanged),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          date != null
              ? '${date.day}/${date.month}/${date.year}'
              : 'Select date',
          style: date != null
              ? null
              : TextStyle(color: Theme.of(context).hintColor),
        ),
      ),
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
        // Update existing prescription
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
        // Create new prescription
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

      // Log success
      developer.log(
        _isEditing
          ? 'Prescription updated successfully: ${widget.prescription!.id}'
          : 'Prescription created successfully for profile: $selectedProfileId',
        name: 'PrescriptionForm',
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
                Expanded(
                  child: Text(
                    _isEditing
                        ? 'Prescription updated successfully'
                        : 'Prescription saved successfully',
                  ),
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
        'Failed to save prescription',
        name: 'PrescriptionForm',
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
                  child: Text('Failed to save. Please try again.'),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  Widget _buildReminderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text('Enable Reminders'),
          subtitle: const Text('Get reminded when it\'s time to take your prescription'),
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
            helpText: 'Choose how you want to be reminded about your prescription',
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
              label: 'Prescription Alarm Volume',
            ),
            const SizedBox(height: 16),
          ],

          // Reminder Preview
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
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required ValueChanged<bool> onExpansionChanged,
    required List<Widget> children,
    LinearGradient? gradient,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sectionGradient = gradient ?? HealthBoxDesignSystem.medicalBlue;

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
            // Gradient Header Strip
            Container(
              height: 4,
              decoration: BoxDecoration(gradient: sectionGradient),
            ),
            // Expandable Content
            Theme(
              data: theme.copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Row(
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
                initiallyExpanded: isExpanded,
                onExpansionChanged: onExpansionChanged,
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
