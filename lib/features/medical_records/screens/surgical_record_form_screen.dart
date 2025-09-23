import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/medical_records_providers.dart';
import '../services/surgical_record_service.dart';
import '../../../data/models/surgical_record.dart';
import '../widgets/attachment_picker_widget.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

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
  List<File> _selectedFiles = [];

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
        title: Text(_isEditing ? 'Edit Surgical Record' : 'New Surgical Record'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveSurgicalRecord,
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
            const SizedBox(height: 24),
            _buildProcedureDetailsSection(),
            const SizedBox(height: 24),
            _buildSurgeryDetailsSection(),
            const SizedBox(height: 24),
            _buildAnesthesiaSection(),
            const SizedBox(height: 24),
            _buildClinicalDetailsSection(),
            const SizedBox(height: 24),
            _buildRecoverySection(),
            const SizedBox(height: 24),
            _buildAttachmentsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'e.g., Appendectomy Surgery',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medical_services),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Additional details about this procedure',
                border: OutlineInputBorder(),
              ),
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
        ),
      ),
    );
  }

  Widget _buildProcedureDetailsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Procedure Details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _procedureNameController,
              decoration: const InputDecoration(
                labelText: 'Procedure Name *',
                hintText: 'e.g., Laparoscopic Appendectomy',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.healing),
              ),
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
            TextFormField(
              controller: _indicationController,
              decoration: const InputDecoration(
                labelText: 'Indication',
                hintText: 'Reason for the procedure',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.info),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurgeryDetailsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Surgery Details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
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
            TextFormField(
              controller: _surgeonNameController,
              decoration: const InputDecoration(
                labelText: 'Surgeon Name',
                hintText: 'Primary surgeon',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _hospitalController,
              decoration: const InputDecoration(
                labelText: 'Hospital/Facility',
                hintText: 'Where the surgery was performed',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_hospital),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _operatingRoomController,
              decoration: const InputDecoration(
                labelText: 'Operating Room',
                hintText: 'e.g., OR 3',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.room),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnesthesiaSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Anesthesia Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedAnesthesiaType,
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
            TextFormField(
              controller: _anesthesiologistController,
              decoration: const InputDecoration(
                labelText: 'Anesthesiologist',
                hintText: 'Anesthesia provider name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClinicalDetailsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Clinical Details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _findingsController,
              decoration: const InputDecoration(
                labelText: 'Surgical Findings',
                hintText: 'What was found during the procedure',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _complicationsController,
              decoration: const InputDecoration(
                labelText: 'Complications',
                hintText: 'Any complications that occurred',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.warning),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecoverySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recovery & Follow-up',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _recoveryNotesController,
              decoration: const InputDecoration(
                labelText: 'Recovery Notes',
                hintText: 'Post-operative recovery details',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.healing),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _followUpPlanController,
              decoration: const InputDecoration(
                labelText: 'Follow-up Plan',
                hintText: 'Planned follow-up appointments and care',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_month),
              ),
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
        ),
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
          const SnackBar(
            content: Text('Surgical record saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save surgical record: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save surgical record: $e'),
            backgroundColor: Colors.red,
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
    return AttachmentPickerWidget(
      onFilesSelected: (files) {
        setState(() {
          _selectedFiles = files;
        });
      },
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      maxFiles: 10,
      maxFileSizeBytes: 50 * 1024 * 1024,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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