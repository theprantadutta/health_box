import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/medical_records_providers.dart';
import '../services/surgical_record_service.dart';
import '../../../data/models/surgical_record.dart';
import '../../../shared/widgets/attachment_form_widget.dart';
import '../../../shared/services/attachment_service.dart';
import '../../../shared/theme/design_system.dart';
import '../../../shared/widgets/hb_app_bar.dart';
import '../../../shared/widgets/hb_button.dart';
import '../../../shared/widgets/hb_text_field.dart';
import '../../../shared/widgets/hb_card.dart';
import '../../../shared/widgets/hb_chip.dart';
import '../../../shared/widgets/hb_list_tile.dart';
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
      appBar: HBAppBar.gradient(
        title: _isEditing ? 'Edit Surgical Record' : 'New Surgical Record',
        gradient: RecordTypeUtils.getGradient('surgical'),
        actions: [
          HBButton.text(
            onPressed: _isLoading ? null : _saveSurgicalRecord,
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
            _buildProcedureDetailsSection(),
            SizedBox(height: AppSpacing.base),
            _buildSurgeryDetailsSection(),
            SizedBox(height: AppSpacing.base),
            _buildAnesthesiaSection(),
            SizedBox(height: AppSpacing.base),
            _buildClinicalDetailsSection(),
            SizedBox(height: AppSpacing.base),
            _buildRecoverySection(),
            SizedBox(height: AppSpacing.base),
            _buildAttachmentsSection(),
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
            RecordTypeUtils.getGradient('surgical'),
          ),
          SizedBox(height: AppSpacing.lg),
          HBTextField.filled(
            controller: _titleController,
            label: 'Title',
            hint: 'e.g., Appendectomy Surgery',
            prefixIcon: Icons.medical_services,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Title is required';
              }
              return null;
            },
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.multiline(
            controller: _descriptionController,
            label: 'Description',
            hint: 'Additional details about this procedure',
            prefixIcon: Icons.description,
            minLines: 3,
            maxLines: 5,
          ),
          SizedBox(height: AppSpacing.base),
          _buildDateTile(
            'Record Date',
            _recordDate,
            () => _selectDate(context, isRecordDate: true),
          ),
          SizedBox(height: AppSpacing.base),
          HBListTile.switchTile(
            title: 'Emergency Procedure',
            subtitle: 'Was this an emergency surgery?',
            icon: Icons.emergency,
            value: _isEmergency,
            onChanged: (value) {
              setState(() => _isEmergency = value);
            },
            iconColor: AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildProcedureDetailsSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Procedure Details',
            Icons.healing,
            RecordTypeUtils.getGradient('surgical'),
          ),
          SizedBox(height: AppSpacing.lg),
          HBTextField.filled(
            controller: _procedureNameController,
            label: 'Procedure Name',
            hint: 'e.g., Laparoscopic Appendectomy',
            prefixIcon: Icons.healing,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Procedure name is required';
              }
              return null;
            },
          ),
          SizedBox(height: AppSpacing.base),
          Text(
            'Common Surgical Categories',
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: AppTypography.fontWeightMedium,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: SurgicalCategories.allCategories.map((category) {
              return HBChip.filter(
                label: category,
                selected: false,
                onSelected: (selected) {
                  // Could be enhanced to auto-suggest procedure names
                  // based on the selected category
                },
              );
            }).toList(),
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.multiline(
            controller: _indicationController,
            label: 'Indication',
            hint: 'Reason for the procedure',
            prefixIcon: Icons.info,
            minLines: 2,
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildSurgeryDetailsSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Surgery Details',
            Icons.local_hospital,
            RecordTypeUtils.getGradient('surgical'),
          ),
          SizedBox(height: AppSpacing.lg),
          _buildDateTile(
            'Surgery Date',
            _surgeryDate,
            () => _selectDate(context, isRecordDate: false),
          ),
          SizedBox(height: AppSpacing.base),
          Row(
            children: [
              Expanded(
                child: _buildTimeTile(
                  'Start Time',
                  _surgeryStartTime,
                  () => _selectTime(context, isStartTime: true),
                ),
              ),
              SizedBox(width: AppSpacing.base),
              Expanded(
                child: _buildTimeTile(
                  'End Time',
                  _surgeryEndTime,
                  () => _selectTime(context, isStartTime: false),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.filled(
            controller: _surgeonNameController,
            label: 'Surgeon Name',
            hint: 'Primary surgeon',
            prefixIcon: Icons.person,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.filled(
            controller: _hospitalController,
            label: 'Hospital/Facility',
            hint: 'Where the surgery was performed',
            prefixIcon: Icons.local_hospital,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.filled(
            controller: _operatingRoomController,
            label: 'Operating Room',
            hint: 'e.g., OR 3',
            prefixIcon: Icons.room,
          ),
        ],
      ),
    );
  }

  Widget _buildAnesthesiaSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Anesthesia Information',
            Icons.masks,
            RecordTypeUtils.getGradient('surgical'),
          ),
          SizedBox(height: AppSpacing.lg),
          DropdownButtonFormField<String>(
            value: _selectedAnesthesiaType,
            decoration: InputDecoration(
              labelText: 'Anesthesia Type',
              prefixIcon: const Icon(Icons.masks),
              filled: true,
              fillColor: context.colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: AppRadii.radiusMd,
                borderSide: BorderSide.none,
              ),
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
          SizedBox(height: AppSpacing.base),
          HBTextField.filled(
            controller: _anesthesiologistController,
            label: 'Anesthesiologist',
            hint: 'Anesthesia provider name',
            prefixIcon: Icons.person,
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalDetailsSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Clinical Details',
            Icons.search,
            RecordTypeUtils.getGradient('surgical'),
          ),
          SizedBox(height: AppSpacing.lg),
          HBTextField.multiline(
            controller: _findingsController,
            label: 'Surgical Findings',
            hint: 'What was found during the procedure',
            prefixIcon: Icons.search,
            minLines: 3,
            maxLines: 5,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.multiline(
            controller: _complicationsController,
            label: 'Complications',
            hint: 'Any complications that occurred',
            prefixIcon: Icons.warning,
            minLines: 3,
            maxLines: 5,
          ),
        ],
      ),
    );
  }

  Widget _buildRecoverySection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Recovery & Follow-up',
            Icons.healing,
            RecordTypeUtils.getGradient('surgical'),
          ),
          SizedBox(height: AppSpacing.lg),
          HBTextField.multiline(
            controller: _recoveryNotesController,
            label: 'Recovery Notes',
            hint: 'Post-operative recovery details',
            prefixIcon: Icons.healing,
            minLines: 3,
            maxLines: 5,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.multiline(
            controller: _followUpPlanController,
            label: 'Follow-up Plan',
            hint: 'Planned follow-up appointments and care',
            prefixIcon: Icons.calendar_month,
            minLines: 3,
            maxLines: 5,
          ),
          SizedBox(height: AppSpacing.base),
          _buildDateTile(
            'Discharge Date',
            _dischargeDate,
            () => _selectDischargeDate(context),
            optional: true,
          ),
          if (_dischargeDate != null)
            Padding(
              padding: EdgeInsets.only(top: AppSpacing.sm),
              child: HBButton.text(
                onPressed: () {
                  setState(() => _dischargeDate = null);
                },
                child: const Text('Clear Discharge Date'),
              ),
            ),
        ],
      ),
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
                const Icon(Icons.check_circle_outline, color: Colors.white, size: AppSizes.iconSm),
                SizedBox(width: AppSpacing.sm),
                const Expanded(
                  child: Text('Surgical record saved successfully'),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadii.radiusMd),
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
                const Icon(Icons.error_outline, color: Colors.white, size: AppSizes.iconSm),
                SizedBox(width: AppSpacing.sm),
                const Expanded(
                  child: Text('Failed to save surgical record. Please try again.'),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadii.radiusMd),
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
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Attachments',
            Icons.attach_file,
            RecordTypeUtils.getGradient('surgical'),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Add surgical reports, operative notes, or post-op instructions',
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
            maxFiles: 10,
            allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
            maxFileSizeMB: 50,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
            Icon(Icons.calendar_today, color: context.colorScheme.onSurfaceVariant, size: AppSizes.iconMd),
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
            Icon(Icons.chevron_right, color: context.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeTile(String label, TimeOfDay? time, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.radiusMd,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHighest,
          borderRadius: AppRadii.radiusMd,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.access_time, color: context.colorScheme.onSurfaceVariant, size: AppSizes.iconSm),
                SizedBox(width: AppSpacing.sm),
                Text(
                  label,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              time != null ? time.format(context) : 'Not set',
              style: context.textTheme.bodyMedium?.copyWith(
                color: time != null ? context.colorScheme.onSurface : context.colorScheme.onSurfaceVariant,
                fontWeight: AppTypography.fontWeightMedium,
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