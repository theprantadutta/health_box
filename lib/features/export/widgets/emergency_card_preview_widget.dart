import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/emergency_card_service.dart';
import '../../../data/database/app_database.dart';
import '../../../shared/providers/profile_providers.dart';

/// Widget that shows a preview of how the emergency card will look
class EmergencyCardPreviewWidget extends ConsumerWidget {
  final String profileId;
  final EmergencyCardConfig config;
  final void Function(EmergencyCardConfig)? onConfigChanged;
  final bool isEditable;

  const EmergencyCardPreviewWidget({
    super.key,
    required this.profileId,
    required this.config,
    this.onConfigChanged,
    this.isEditable = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileByIdProvider(profileId));

    return profileAsync.when(
      data: (profile) => profile != null
          ? _buildPreview(context, profile)
          : _buildError('Profile not found'),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildError(error.toString()),
    );
  }

  Widget _buildPreview(BuildContext context, FamilyMemberProfile profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPreviewInfo(context),
          const SizedBox(height: 16),
          _buildCard(context, profile),
          const SizedBox(height: 16),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildPreviewInfo(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Emergency Card Preview',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'This is how your emergency card will appear when printed. '
                  'The actual PDF will have better formatting and quality.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, FamilyMemberProfile profile) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCardHeader(context, profile),
          _buildCardBody(context, profile),
          _buildCardFooter(context),
        ],
      ),
    );
  }

  Widget _buildCardHeader(BuildContext context, FamilyMemberProfile profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'EMERGENCY MEDICAL CARD',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '${profile.firstName} ${profile.lastName}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCardBody(BuildContext context, FamilyMemberProfile profile) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildPersonalInfoSection(context, profile),
                const SizedBox(height: 12),
                _buildEmergencyContactsSection(context),
                const SizedBox(height: 12),
                _buildCriticalAllergiesSection(context),
                const SizedBox(height: 12),
                _buildCurrentMedicationsSection(context),
                const SizedBox(height: 12),
                _buildMedicalConditionsSection(context),
                if (config.additionalNotes != null && config.additionalNotes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildAdditionalNotesSection(context),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: _buildQRCodeSection(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(BuildContext context, FamilyMemberProfile profile) {
    return _buildSection(
      context,
      'PERSONAL INFORMATION',
      [
        _buildInfoRow('Date of Birth:', _formatDate(profile.dateOfBirth)),
        _buildInfoRow('Gender:', profile.gender),
        if (profile.bloodType != null)
          _buildInfoRow('Blood Type:', profile.bloodType!),
        if (profile.height != null)
          _buildInfoRow('Height:', '${profile.height}cm'),
        if (profile.weight != null)
          _buildInfoRow('Weight:', '${profile.weight}kg'),
      ],
    );
  }

  Widget _buildEmergencyContactsSection(BuildContext context) {
    return _buildSection(
      context,
      'EMERGENCY CONTACTS',
      [
        if (config.emergencyContact != null)
          Text(
            config.emergencyContact!,
            style: const TextStyle(fontSize: 10),
          ),
        if (config.secondaryContact != null) ...[
          const SizedBox(height: 4),
          Text(
            config.secondaryContact!,
            style: const TextStyle(fontSize: 10),
          ),
        ],
        if (config.insuranceInfo != null) ...[
          const SizedBox(height: 4),
          _buildInfoRow('Insurance:', config.insuranceInfo!, fontSize: 10),
        ],
      ],
    );
  }

  Widget _buildCriticalAllergiesSection(BuildContext context) {
    return _buildSection(
      context,
      'CRITICAL ALLERGIES',
      config.criticalAllergies.isEmpty
          ? [const Text('None reported', style: TextStyle(fontSize: 10))]
          : config.criticalAllergies.map((allergy) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 10, color: Colors.red)),
                  Expanded(
                    child: Text(
                      allergy,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
            )).toList(),
      backgroundColor: Colors.red.shade50,
      borderColor: Colors.red,
      titleColor: Colors.red,
    );
  }

  Widget _buildCurrentMedicationsSection(BuildContext context) {
    return _buildSection(
      context,
      'CURRENT MEDICATIONS',
      config.currentMedications.isEmpty
          ? [const Text('None reported', style: TextStyle(fontSize: 10))]
          : config.currentMedications.take(8).map((medication) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 10)),
                  Expanded(
                    child: Text(
                      medication,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
            )).toList(),
    );
  }

  Widget _buildMedicalConditionsSection(BuildContext context) {
    return _buildSection(
      context,
      'MEDICAL CONDITIONS',
      config.medicalConditions.isEmpty
          ? [const Text('None reported', style: TextStyle(fontSize: 10))]
          : config.medicalConditions.take(6).map((condition) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 10)),
                  Expanded(
                    child: Text(
                      condition,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
            )).toList(),
    );
  }

  Widget _buildAdditionalNotesSection(BuildContext context) {
    return _buildSection(
      context,
      'ADDITIONAL NOTES',
      [
        Text(
          config.additionalNotes!,
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children, {
    Color? backgroundColor,
    Color? borderColor,
    Color? titleColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: borderColor ?? Colors.grey.shade300,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: titleColor ?? Colors.red,
            ),
          ),
          const SizedBox(height: 6),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {double fontSize = 10}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: fontSize),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRCodeSection(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code, size: 40, color: Colors.grey),
              SizedBox(height: 4),
              Text(
                'QR CODE',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Scan with phone camera for digital access',
          style: TextStyle(fontSize: 8),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCardFooter(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Generated by HealthBox Mobile App',
            style: TextStyle(fontSize: 8),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            'Generated on: ${_formatDate(DateTime.now())} - Keep this card with you at all times',
            style: TextStyle(fontSize: 7, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (!isEditable) {
      return const SizedBox();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preview Actions',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editConfig(context),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showZoomedPreview(context),
                    icon: const Icon(Icons.zoom_in),
                    label: const Text('Zoom'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Preview Error',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  void _editConfig(BuildContext context) {
    // This would typically navigate to an edit dialog or screen
    if (onConfigChanged != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Edit Configuration'),
          content: const Text('This would open the edit configuration dialog.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  void _showZoomedPreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 600,
            maxHeight: 800,
          ),
          child: Column(
            children: [
              AppBar(
                title: const Text('Emergency Card Preview'),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Consumer(
                    builder: (context, ref, child) {
                      final profileAsync = ref.watch(profileByIdProvider(profileId));
                      return profileAsync.when(
                        data: (profile) => profile != null
                            ? _buildCard(context, profile)
                            : _buildError('Profile not found'),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (error, stack) => _buildError(error.toString()),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// A simplified version of the preview for use in smaller spaces
class EmergencyCardMiniPreview extends StatelessWidget {
  final String profileId;
  final EmergencyCardConfig config;

  const EmergencyCardMiniPreview({
    super.key,
    required this.profileId,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: const Text(
              'EMERGENCY CARD',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (config.criticalAllergies.isNotEmpty) ...[
                    const Text(
                      'ALLERGIES',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    Text(
                      config.criticalAllergies.take(2).join(', '),
                      style: const TextStyle(fontSize: 8),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (config.currentMedications.isNotEmpty) ...[
                    const Text(
                      'MEDICATIONS',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      config.currentMedications.take(2).join(', '),
                      style: const TextStyle(fontSize: 8),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}