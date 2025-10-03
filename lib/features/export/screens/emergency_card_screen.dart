import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/emergency_card_service.dart';
import '../widgets/emergency_card_preview_widget.dart';
import '../../../data/database/app_database.dart';
import '../../../shared/providers/profile_providers.dart';
import '../../../shared/theme/design_system.dart';
import '../../medical_records/services/medical_records_service.dart';

/// Screen for configuring and generating emergency cards
class EmergencyCardScreen extends ConsumerStatefulWidget {
  final String profileId;

  const EmergencyCardScreen({super.key, required this.profileId});

  @override
  ConsumerState<EmergencyCardScreen> createState() =>
      _EmergencyCardScreenState();
}

class _EmergencyCardScreenState extends ConsumerState<EmergencyCardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _emergencyContactController = TextEditingController();
  final _secondaryContactController = TextEditingController();
  final _insuranceInfoController = TextEditingController();
  final _additionalNotesController = TextEditingController();

  // Configuration state
  List<String> _selectedAllergies = [];
  List<String> _selectedMedications = [];
  List<String> _selectedConditions = [];
  List<String> _customAllergies = [];
  List<String> _customMedications = [];
  List<String> _customConditions = [];

  // Options
  bool _includeQRCode = true;
  bool _includeMedications = true;
  bool _includeAllergies = true;
  bool _includeConditions = true;

  // Available data
  List<MedicalRecord> _availableAllergies = [];
  List<MedicalRecord> _availableMedications = [];
  List<MedicalRecord> _availableConditions = [];

  // Loading states
  bool _isLoading = false;
  bool _isGenerating = false;
  bool _isSaving = false;

  EmergencyCardService? _emergencyCardService;
  MedicalRecordsService? _medicalRecordsService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _emergencyCardService = EmergencyCardService();
    _medicalRecordsService = MedicalRecordsService();
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emergencyContactController.dispose();
    _secondaryContactController.dispose();
    _insuranceInfoController.dispose();
    _additionalNotesController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load existing config
      final existingConfig = await _emergencyCardService!
          .getEmergencyCardConfig(widget.profileId);

      if (existingConfig != null) {
        _emergencyContactController.text =
            existingConfig.emergencyContact ?? '';
        _secondaryContactController.text =
            existingConfig.secondaryContact ?? '';
        _insuranceInfoController.text = existingConfig.insuranceInfo ?? '';
        _additionalNotesController.text = existingConfig.additionalNotes ?? '';

        _selectedAllergies = List.from(existingConfig.criticalAllergies);
        _selectedMedications = List.from(existingConfig.currentMedications);
        _selectedConditions = List.from(existingConfig.medicalConditions);
      }

      // Load available medical records
      _availableAllergies = await _medicalRecordsService!.searchRecords(
        profileId: widget.profileId,
        recordType: 'allergy',
      );
      _availableMedications = await _medicalRecordsService!.searchRecords(
        profileId: widget.profileId,
        recordType: 'medication',
      );
      _availableConditions = await _medicalRecordsService!.searchRecords(
        profileId: widget.profileId,
        recordType: 'chronic_condition',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileByIdProvider(widget.profileId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Card', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: HealthBoxDesignSystem.errorGradient,
            boxShadow: [
              BoxShadow(
                color: HealthBoxDesignSystem.errorGradient.colors.first.withValues(alpha: 0.3),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Configure', icon: Icon(Icons.settings)),
            Tab(text: 'Preview', icon: Icon(Icons.preview)),
            Tab(text: 'Generate', icon: Icon(Icons.print)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _saveConfiguration,
            icon: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save, color: Colors.white),
            tooltip: 'Save Configuration',
          ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) => _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildConfigureTab(profile),
                  _buildPreviewTab(profile),
                  _buildGenerateTab(profile),
                ],
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text('Error loading profile: ${error.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfigureTab(FamilyMemberProfile? profile) {
    if (profile == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPersonalInfoCard(profile),
            const SizedBox(height: 16),
            _buildContactInfoCard(),
            const SizedBox(height: 16),
            _buildMedicalDataCard(),
            const SizedBox(height: 16),
            _buildOptionsCard(),
            const SizedBox(height: 16),
            _buildCustomNotesCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewTab(FamilyMemberProfile? profile) {
    if (profile == null) return const SizedBox();

    return EmergencyCardPreviewWidget(
      profileId: widget.profileId,
      config: _getCurrentConfig(),
      onConfigChanged: (config) => _updateFromConfig(config),
    );
  }

  Widget _buildGenerateTab(FamilyMemberProfile? profile) {
    if (profile == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Generate Emergency Card',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create a printable PDF emergency card that can be carried in a wallet or purse.',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isGenerating ? null : _generatePDFCard,
                          icon: _isGenerating
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.picture_as_pdf),
                          label: const Text('Generate PDF'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _generateQRCode,
                          icon: const Icon(Icons.qr_code),
                          label: const Text('QR Code Only'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Usage Instructions',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Print the PDF and carry it in your wallet\n'
                    '• Emergency responders can scan the QR code for digital access\n'
                    '• Keep the information updated regularly\n'
                    '• Consider laminating the card for durability',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Important',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This card contains sensitive medical information. '
                    'Ensure you understand your local privacy laws and '
                    'only share when necessary for medical emergencies.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard(FamilyMemberProfile profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoTile('Name', '${profile.firstName} ${profile.lastName}'),
            _buildInfoTile('Date of Birth', _formatDate(profile.dateOfBirth)),
            _buildInfoTile('Gender', profile.gender),
            if (profile.bloodType != null)
              _buildInfoTile('Blood Type', profile.bloodType!),
            if (profile.height != null)
              _buildInfoTile('Height', '${profile.height}cm'),
            if (profile.weight != null)
              _buildInfoTile('Weight', '${profile.weight}kg'),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Emergency Contacts',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emergencyContactController,
              decoration: const InputDecoration(
                labelText: 'Primary Emergency Contact',
                hintText: 'Name and phone number',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _secondaryContactController,
              decoration: const InputDecoration(
                labelText: 'Secondary Emergency Contact',
                hintText: 'Name and phone number',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _insuranceInfoController,
              decoration: const InputDecoration(
                labelText: 'Insurance Information',
                hintText: 'Provider and policy number',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalDataCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Medical Information',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildMedicalSection(
              'Critical Allergies',
              _availableAllergies,
              _selectedAllergies,
              _customAllergies,
              Icons.warning,
              Colors.red,
            ),
            const SizedBox(height: 16),
            _buildMedicalSection(
              'Current Medications',
              _availableMedications,
              _selectedMedications,
              _customMedications,
              Icons.medication,
              Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildMedicalSection(
              'Medical Conditions',
              _availableConditions,
              _selectedConditions,
              _customConditions,
              Icons.medical_information,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Card Options',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Include QR Code'),
              subtitle: const Text('Add QR code for digital access'),
              value: _includeQRCode,
              onChanged: (value) => setState(() => _includeQRCode = value),
            ),
            SwitchListTile(
              title: const Text('Include Medications'),
              subtitle: const Text('Show current medications'),
              value: _includeMedications,
              onChanged: (value) => setState(() => _includeMedications = value),
            ),
            SwitchListTile(
              title: const Text('Include Allergies'),
              subtitle: const Text('Show critical allergies'),
              value: _includeAllergies,
              onChanged: (value) => setState(() => _includeAllergies = value),
            ),
            SwitchListTile(
              title: const Text('Include Conditions'),
              subtitle: const Text('Show medical conditions'),
              value: _includeConditions,
              onChanged: (value) => setState(() => _includeConditions = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomNotesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Notes',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _additionalNotesController,
              decoration: const InputDecoration(
                hintText: 'Add any additional emergency information...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              maxLength: 500,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalSection(
    String title,
    List<MedicalRecord> available,
    List<String> selected,
    List<String> custom,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (available.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: available
                .map(
                  (record) => FilterChip(
                    label: Text(record.title),
                    selected: selected.contains(record.title),
                    onSelected: (isSelected) {
                      setState(() {
                        if (isSelected) {
                          selected.add(record.title);
                        } else {
                          selected.remove(record.title);
                        }
                      });
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
        ],
        OutlinedButton.icon(
          onPressed: () => _showAddCustomDialog(title, selected),
          icon: const Icon(Icons.add),
          label: Text('Add Custom $title'),
        ),
        if (selected.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Selected: ${selected.join(', ')}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddCustomDialog(String type, List<String> selected) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Custom $type'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter custom $type',
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => context.pop(controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && !selected.contains(result)) {
      setState(() {
        selected.add(result);
      });
    }
  }

  Future<void> _saveConfiguration() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final config = _getCurrentConfig();
      await _emergencyCardService!.saveEmergencyCardConfig(config);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuration saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving configuration: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _generatePDFCard() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      await _saveConfiguration();

      final filePath = await _emergencyCardService!.generateEmergencyCard(
        widget.profileId,
        includeQRCode: _includeQRCode,
        includeMedications: _includeMedications,
        includeAllergies: _includeAllergies,
        includeConditions: _includeConditions,
        customNotes: _additionalNotesController.text.trim().isNotEmpty
            ? _additionalNotesController.text.trim()
            : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Emergency card generated: $filePath'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Share',
              onPressed: () => _shareFile(filePath),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating card: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  Future<void> _generateQRCode() async {
    try {
      final qrBytes = await _emergencyCardService!.generateQRCodeImage(
        widget.profileId,
        size: 300.0,
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Emergency QR Code'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.memory(qrBytes, width: 250, height: 250),
                const SizedBox(height: 16),
                const Text('Scan with any QR code reader for emergency info'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () => _shareQRCode(qrBytes),
                child: const Text('Share'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating QR code: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  EmergencyCardConfig _getCurrentConfig() {
    return EmergencyCardConfig(
      profileId: widget.profileId,
      criticalAllergies: _selectedAllergies,
      currentMedications: _selectedMedications,
      medicalConditions: _selectedConditions,
      emergencyContact: _emergencyContactController.text.trim().isNotEmpty
          ? _emergencyContactController.text.trim()
          : null,
      secondaryContact: _secondaryContactController.text.trim().isNotEmpty
          ? _secondaryContactController.text.trim()
          : null,
      insuranceInfo: _insuranceInfoController.text.trim().isNotEmpty
          ? _insuranceInfoController.text.trim()
          : null,
      additionalNotes: _additionalNotesController.text.trim().isNotEmpty
          ? _additionalNotesController.text.trim()
          : null,
    );
  }

  void _updateFromConfig(EmergencyCardConfig config) {
    setState(() {
      _selectedAllergies = List.from(config.criticalAllergies);
      _selectedMedications = List.from(config.currentMedications);
      _selectedConditions = List.from(config.medicalConditions);
      _emergencyContactController.text = config.emergencyContact ?? '';
      _secondaryContactController.text = config.secondaryContact ?? '';
      _insuranceInfoController.text = config.insuranceInfo ?? '';
      _additionalNotesController.text = config.additionalNotes ?? '';
    });
  }

  void _shareFile(String filePath) {
    // Implementation would depend on platform-specific sharing
    // This would typically use share_plus package
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('File saved to: $filePath')));
  }

  void _shareQRCode(Uint8List qrBytes) {
    // Implementation would depend on platform-specific sharing
    // This would typically use share_plus package
    context.pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('QR code ready to share')));
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
