import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/medical_records_providers.dart';
import '../services/medication_service.dart';
import '../../../shared/widgets/attachment_form_widget.dart';
import '../../../shared/services/attachment_service.dart';
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
  bool _isLoading = false;
  List<AttachmentResult> _attachments = [];

  bool _medicationInfoExpanded = true;
  bool _attachmentsExpanded = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Medication'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveMedication,
            child: const Text('SAVE'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildExpandableSection(
              title: 'Medication Information',
              icon: Icons.medication,
              isExpanded: _medicationInfoExpanded,
              onExpansionChanged: (value) => setState(() => _medicationInfoExpanded = value),
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Medication Name *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.medication),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dosageController,
                  decoration: const InputDecoration(
                    labelText: 'Dosage *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.straighten),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _frequencyController,
                  decoration: const InputDecoration(
                    labelText: 'Frequency *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.schedule),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildExpandableSection(
              title: 'Attachments',
              icon: Icons.attach_file,
              isExpanded: _attachmentsExpanded,
              onExpansionChanged: (value) => setState(() => _attachmentsExpanded = value),
              children: [
                _buildAttachmentsContent(),
              ],
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.notifications, size: 48),
                    const SizedBox(height: 8),
                    const Text('Reminder Setup'),
                    const SizedBox(height: 8),
                    Text(
                      'Medication reminders will be implemented with the notification service in Phase 3.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add medication labels, pill images, or doctor instructions',
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
          maxFiles: 6,
          allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
          maxFileSizeMB: 25,
        ),
      ],
    );
  }

  Future<void> _saveMedication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = ref.read(medicationServiceProvider);
      final selectedProfileId = widget.profileId;

      if (selectedProfileId == null) {
        throw Exception('No profile selected');
      }

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
        reminderEnabled: false,
        status: 'active',
        reminderTimes: [],
      );

      await service.createMedication(request);

      // Log success
      developer.log(
        'Medication created successfully for profile: $selectedProfileId',
        name: 'MedicationForm',
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
                  child: Text('Medication saved successfully'),
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
        'Failed to save medication',
        name: 'MedicationForm',
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
                  child: Text('Failed to save medication. Please try again.'),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _saveMedication(),
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

  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required ValueChanged<bool> onExpansionChanged,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        initiallyExpanded: isExpanded,
        onExpansionChanged: onExpansionChanged,
        childrenPadding: const EdgeInsets.all(16),
        children: children,
      ),
    );
  }
}
