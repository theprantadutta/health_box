import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/database/app_database.dart';
import '../../../shared/providers/medical_records_providers.dart';
import '../../../shared/providers/profile_providers.dart';
import '../../../shared/theme/design_system.dart';

class MedicalRecordDetailScreen extends ConsumerWidget {
  final String recordId;
  final MedicalRecord? record;

  const MedicalRecordDetailScreen({
    super.key,
    required this.recordId,
    this.record,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use provided record or fetch by ID
    final recordAsync = record != null
        ? AsyncValue.data(record!)
        : ref.watch(medicalRecordByIdProvider(recordId));

    final recordGradient = recordAsync.value != null
        ? HealthBoxDesignSystem.getRecordTypeGradient(
            recordAsync.value!.recordType)
        : HealthBoxDesignSystem.medicalBlue;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Medical Record',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: recordGradient,
            boxShadow: [
              BoxShadow(
                color: recordGradient.colors.first.withValues(alpha: 0.3),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEdit(context, recordAsync.value),
            tooltip: 'Edit Record',
          ),
          PopupMenuButton<String>(
            onSelected: (value) =>
                _handleMenuAction(context, value, recordAsync.value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Share'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: recordAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(context, error),
        data: (record) => record == null
            ? _buildRecordNotFound(context)
            : _buildRecordDetail(context, ref, record),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading record',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordNotFound(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Record not found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'The medical record you\'re looking for doesn\'t exist or has been deleted',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordDetail(
    BuildContext context,
    WidgetRef ref,
    MedicalRecord record,
  ) {
    final profileAsync = ref.watch(profileByIdProvider(record.profileId));
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildRecordTypeChip(context, record.recordType),
                      const Spacer(),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDateTime(record.recordDate),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    record.title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (record.description?.isNotEmpty == true) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        record.description!,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.5,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Profile Information
          profileAsync.when(
            loading: () => const Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 16),
                    Text('Loading profile...'),
                  ],
                ),
              ),
            ),
            error: (error, stack) => Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Profile ID: ${record.profileId}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            data: (profile) => Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: theme.colorScheme.primary.withValues(
                        alpha: 0.15,
                      ),
                      child: Icon(
                        Icons.person,
                        size: 32,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Patient Information',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profile != null
                                ? '${profile.firstName} ${profile.lastName}'
                                : 'Unknown Profile',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (profile != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${_calculateAge(profile.dateOfBirth)} years • ${profile.gender}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Record Metadata
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Record Details',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInfoRow(
                    context,
                    'Record Type',
                    _formatRecordType(record.recordType),
                    Icons.category,
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    context,
                    'Record Date & Time',
                    _formatDateTime(record.recordDate),
                    Icons.calendar_today,
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    context,
                    'Created',
                    _formatDateTime(record.createdAt),
                    Icons.add_circle_outline,
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    context,
                    'Last Modified',
                    _formatDateTime(record.updatedAt),
                    Icons.edit_calendar,
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    context,
                    'Record ID',
                    record.id,
                    Icons.fingerprint,
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    context,
                    'Status',
                    record.isActive ? 'Active' : 'Inactive',
                    record.isActive ? Icons.check_circle : Icons.cancel,
                    valueColor: record.isActive
                        ? Colors.green
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordTypeChip(BuildContext context, String recordType) {
    final theme = Theme.of(context);
    final color = _getRecordTypeColor(recordType);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getRecordTypeIcon(recordType), size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            recordType,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(color: valueColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatRecordType(String recordType) {
    return recordType.split('_').map((word) =>
      word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }

  Color _getRecordTypeColor(String recordType) {
    switch (recordType.toLowerCase()) {
      case 'prescription':
        return Colors.blue;
      case 'medication':
        return Colors.green;
      case 'lab report':
        return Colors.orange;
      case 'vaccination':
        return Colors.purple;
      case 'allergy':
        return Colors.red;
      case 'chronic condition':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  IconData _getRecordTypeIcon(String recordType) {
    switch (recordType.toLowerCase()) {
      case 'prescription':
        return Icons.medication;
      case 'medication':
        return Icons.medical_services;
      case 'lab report':
        return Icons.science;
      case 'vaccination':
        return Icons.vaccines;
      case 'allergy':
        return Icons.warning;
      case 'chronic condition':
        return Icons.monitor_heart;
      default:
        return Icons.description;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year} at ${hour}:${minute}';
  }

  int _calculateAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  void _navigateToEdit(BuildContext context, MedicalRecord? record) {
    if (record == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Edit ${record.recordType} - Will be implemented in T056-T058',
        ),
      ),
    );
  }

  void _handleMenuAction(
    BuildContext context,
    String action,
    MedicalRecord? record,
  ) {
    if (record == null) return;

    switch (action) {
      case 'share':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Share functionality will be implemented in Phase 3.12',
            ),
          ),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(context, record);
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context, MedicalRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: Text(
          'Are you sure you want to delete "${record.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              context.pop(); // Return to previous screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Delete functionality will be implemented with service integration',
                  ),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
