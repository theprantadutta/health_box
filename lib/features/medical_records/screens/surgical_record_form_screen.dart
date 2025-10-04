import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/medical_records_providers.dart';
import '../services/surgical_record_service.dart';
import '../../../data/models/surgical_record.dart';
import '../../../shared/widgets/attachment_form_widget.dart';
import '../../../shared/services/attachment_service.dart';
import '../../../shared/theme/design_system.dart';
import '../../../shared/widgets/modern_text_field.dart';
import 'dart:developer' as developer;

class SurgicalRecordFormScreen extends ConsumerStatefulWidget {
  final String? profileId;
  final String? surgicalRecordId;

  const SurgicalRecordFormScreen({
    super.key,
    this.profileId,
    this.surgicalRecordId,
  });

  @override
  ConsumerState<SurgicalRecordFormScreen> createState() =>
      _SurgicalRecordFormScreenState();
}

class _SurgicalRecordFormScreenState
    extends ConsumerState<SurgicalRecordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _procedureNameController = TextEditingController();
  final _surgeonNameController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _operatingRoomController = TextEditingController();
  final _anesthesiologistController = TextEditingController();
  final _indicationController = TextEditingController();
  final _findingsController = TextEditingController();
  final _complicationsController = TextEditingController();
  final _recoveryNotesController = TextEditingController();
  final _followUpPlanController = TextEditingController();

  DateTime _recordDate = DateTime.now();
  DateTime _surgeryDate = DateTime.now();
  TimeOfDay? _surgeryStartTime;
  TimeOfDay? _surgeryEndTime;
  DateTime? _dischargeDate;
  String? _selectedAnesthesiaType;
  bool _isEmergency = false;
  bool _isLoading = false;
  bool _isEditing = false;
  List<AttachmentResult> _attachments = [];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.surgicalRecordId != null;
    if (_isEditing) {
      _loadSurgicalRecord();
    }
  }

  Future<void> _loadSurgicalRecord() async {
    // TODO: Load existing surgical record data when editing
    // This will be implemented with the surgical record service
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Surgical Record' : 'New Surgical Record',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: HealthBoxDesignSystem.surgicalGradient,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveSurgicalRecord,
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
            _buildProcedureDetailsSection(),
            const SizedBox(height: 16),
            _buildSurgeryDetailsSection(),
            const SizedBox(height: 16),
            _buildAnesthesiaSection(),
            const SizedBox(height: 16),
            _buildClinicalDetailsSection(),
            const SizedBox(height: 16),
            _buildRecoverySection(),
            const SizedBox(height: 16),
            _buildAttachmentsSection(),
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
          hintText: 'e.g., Appendectomy Surgery',
          prefixIcon: const Icon(Icons.medical_services),
          focusGradient: HealthBoxDesignSystem.surgicalGradient,
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
          hintText: 'Additional details about this procedure',
          prefixIcon: const Icon(Icons.description),
          focusGradient: HealthBoxDesignSystem.surgicalGradient,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        ListTile(
          title: const Text('Record Date'),
          subtitle: Text(_formatDate(_recordDate)),
          trailing: const Icon(Icons.calendar_today),
          onTap: () => _selectDate(context, isRecordDate: true),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Emergency Procedure'),
          subtitle: const Text('Was this an emergency surgery?'),
          value: _isEmergency,
          onChanged: (value) {
            setState(() => _isEmergency = value);
          },
        ),
      ],
    );
  }

  Widget _buildProcedureDetailsSection() {
    return _buildModernSection(
      title: 'Procedure Details',
      icon: Icons.healing,
      children: [
        ModernTextField(
          controller: _procedureNameController,
          labelText: 'Procedure Name *',
          hintText: 'e.g., Laparoscopic Appendectomy',
          prefixIcon: const Icon(Icons.healing),
          focusGradient: HealthBoxDesignSystem.surgicalGradient,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Procedure name is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Text(
          'Common Surgical Categories',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: SurgicalCategories.allCategories.map((category) {
            return FilterChip(
              label: Text(category),
              selected: false,
              onSelected: (selected) {
                // Could be enhanced to auto-suggest procedure names
                // based on the selected category
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: _indicationController,
          labelText: 'Indication',
          hintText: 'Reason for the procedure',
          prefixIcon: const Icon(Icons.info),
          focusGradient: HealthBoxDesignSystem.surgicalGradient,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildSurgeryDetailsSection() {
    return _buildModernSection(
      title: 'Surgery Details',
      icon: Icons.local_hospital,
      children: [
        ListTile(
          title: const Text('Surgery Date'),
          subtitle: Text(_formatDate(_surgeryDate)),
          trailing: const Icon(Icons.calendar_today),
          onTap: () => _selectDate(context, isRecordDate: false),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ListTile(
                title: const Text('Start Time'),
                subtitle: Text(_surgeryStartTime != null
                    ? _surgeryStartTime!.format(context)
                    : 'Not set'),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectTime(context, isStartTime: true),
              ),
            ),
            Expanded(
              child: ListTile(
                title: const Text('End Time'),
                subtitle: Text(_surgeryEndTime != null
                    ? _surgeryEndTime!.format(context)
                    : 'Not set'),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectTime(context, isStartTime: false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: _surgeonNameController,
          labelText: 'Surgeon Name',
          hintText: 'Primary surgeon',
          prefixIcon: const Icon(Icons.person),
          focusGradient: HealthBoxDesignSystem.surgicalGradient,
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: _hospitalController,
          labelText: 'Hospital/Facility',
          hintText: 'Where the surgery was performed',
          prefixIcon: const Icon(Icons.local_hospital),
          focusGradient: HealthBoxDesignSystem.surgicalGradient,
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: _operatingRoomController,
          labelText: 'Operating Room',
          hintText: 'e.g., OR 3',
          prefixIcon: const Icon(Icons.room),
          focusGradient: HealthBoxDesignSystem.surgicalGradient,
        ),
      ],
    );
  }

  Widget _buildAnesthesiaSection() {
    return _buildModernSection(
      title: 'Anesthesia Information',
      icon: Icons.masks,
      children: [
        DropdownButtonFormField<String>(
          initialValue: _selectedAnesthesiaType,
          decoration: const InputDecoration(
            labelText: 'Anesthesia Type',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.masks),
          ),
          items: AnesthesiaTypes.allTypes
              .map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() => _selectedAnesthesiaType = value);
          },
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: _anesthesiologistController,
          labelText: 'Anesthesiologist',
          hintText: 'Anesthesia provider name',
          prefixIcon: const Icon(Icons.person),
          focusGradient: HealthBoxDesignSystem.surgicalGradient,
        ),
      ],
    );
  }

  Widget _buildClinicalDetailsSection() {
    return _buildModernSection(
      title: 'Clinical Details',
      icon: Icons.search,
      children: [
        ModernTextField(
          controller: _findingsController,
          labelText: 'Surgical Findings',
          hintText: 'What was found during the procedure',
          prefixIcon: const Icon(Icons.search),
          focusGradient: HealthBoxDesignSystem.surgicalGradient,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: _complicationsController,
          labelText: 'Complications',
          hintText: 'Any complications that occurred',
          prefixIcon: const Icon(Icons.warning),
          focusGradient: HealthBoxDesignSystem.surgicalGradient,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildRecoverySection() {
    return _buildModernSection(
      title: 'Recovery & Follow-up',
      icon: Icons.healing,
      children: [
        ModernTextField(
          controller: _recoveryNotesController,
          labelText: 'Recovery Notes',
          hintText: 'Post-operative recovery details',
          prefixIcon: const Icon(Icons.healing),
          focusGradient: HealthBoxDesignSystem.surgicalGradient,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: _followUpPlanController,
          labelText: 'Follow-up Plan',
          hintText: 'Planned follow-up appointments and care',
          prefixIcon: const Icon(Icons.calendar_month),
          focusGradient: HealthBoxDesignSystem.surgicalGradient,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        ListTile(
          title: const Text('Discharge Date'),
          subtitle: Text(_dischargeDate != null
              ? _formatDate(_dischargeDate!)
              : 'Not set'),
          trailing: const Icon(Icons.exit_to_app),
          onTap: () => _selectDischargeDate(context),
        ),
        if (_dischargeDate != null)
          TextButton(
            onPressed: () {
              setState(() => _dischargeDate = null);
            },
            child: const Text('Clear Discharge Date'),
          ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context,
      {required bool isRecordDate}) async {
    final initialDate = isRecordDate ? _recordDate : _surgeryDate;
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
          _surgeryDate = selectedDate;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context,
      {required bool isStartTime}) async {
    final initialTime = isStartTime
        ? (_surgeryStartTime ?? TimeOfDay.now())
        : (_surgeryEndTime ?? TimeOfDay.now());

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (selectedTime != null) {
      setState(() {
        if (isStartTime) {
          _surgeryStartTime = selectedTime;
        } else {
          _surgeryEndTime = selectedTime;
        }
      });
    }
  }

  Future<void> _selectDischargeDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _dischargeDate ?? _surgeryDate,
      firstDate: _surgeryDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      setState(() => _dischargeDate = selectedDate);
    }
  }

  Future<void> _saveSurgicalRecord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = SurgicalRecordService();
      final selectedProfileId = widget.profileId;

      if (selectedProfileId == null) {
        throw Exception('No profile selected');
      }

      // Combine surgery date with start/end times
      DateTime? surgeryStartDateTime;
      DateTime? surgeryEndDateTime;

      if (_surgeryStartTime != null) {
        surgeryStartDateTime = DateTime(
          _surgeryDate.year,
          _surgeryDate.month,
          _surgeryDate.day,
          _surgeryStartTime!.hour,
          _surgeryStartTime!.minute,
        );
      }

      if (_surgeryEndTime != null) {
        surgeryEndDateTime = DateTime(
          _surgeryDate.year,
          _surgeryDate.month,
          _surgeryDate.day,
          _surgeryEndTime!.hour,
          _surgeryEndTime!.minute,
        );
      }

      final request = CreateSurgicalRecordRequest(
        profileId: selectedProfileId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        recordDate: _recordDate,
        procedureName: _procedureNameController.text.trim(),
        surgeonName: _surgeonNameController.text.trim().isEmpty
            ? null
            : _surgeonNameController.text.trim(),
        hospital: _hospitalController.text.trim().isEmpty
            ? null
            : _hospitalController.text.trim(),
        operatingRoom: _operatingRoomController.text.trim().isEmpty
            ? null
            : _operatingRoomController.text.trim(),
        surgeryDate: _surgeryDate,
        surgeryStartTime: surgeryStartDateTime,
        surgeryEndTime: surgeryEndDateTime,
        anesthesiaType: _selectedAnesthesiaType,
        anesthesiologist: _anesthesiologistController.text.trim().isEmpty
            ? null
            : _anesthesiologistController.text.trim(),
        indication: _indicationController.text.trim().isEmpty
            ? null
            : _indicationController.text.trim(),
        findings: _findingsController.text.trim().isEmpty
            ? null
            : _findingsController.text.trim(),
        complications: _complicationsController.text.trim().isEmpty
            ? null
            : _complicationsController.text.trim(),
        recoveryNotes: _recoveryNotesController.text.trim().isEmpty
            ? null
            : _recoveryNotesController.text.trim(),
        followUpPlan: _followUpPlanController.text.trim().isEmpty
            ? null
            : _followUpPlanController.text.trim(),
        dischargeDate: _dischargeDate,
        isEmergency: _isEmergency,
      );

      await service.createSurgicalRecord(request);

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
                  child: Text('Surgical record saved successfully'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }

      // Log success
      developer.log(
        'Surgical record created successfully for profile: $selectedProfileId',
        name: 'SurgicalRecordForm',
        level: 800, // INFO level
      );
    } catch (error, stackTrace) {
      // Log detailed error to console
      developer.log(
        'Failed to save surgical record',
        name: 'SurgicalRecordForm',
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
                  child: Text('Failed to save surgical record. Please try again.'),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _saveSurgicalRecord(),
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
          'Add surgical reports, operative notes, or post-op instructions',
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
          maxFiles: 10,
          allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
          maxFileSizeMB: 50,
        ),
      ],
    );
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
    final sectionGradient = gradient ?? HealthBoxDesignSystem.surgicalGradient;

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
    _procedureNameController.dispose();
    _surgeonNameController.dispose();
    _hospitalController.dispose();
    _operatingRoomController.dispose();
    _anesthesiologistController.dispose();
    _indicationController.dispose();
    _findingsController.dispose();
    _complicationsController.dispose();
    _recoveryNotesController.dispose();
    _followUpPlanController.dispose();
    super.dispose();
  }
}