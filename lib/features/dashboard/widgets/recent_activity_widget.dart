import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/database/app_database.dart';
import '../../../shared/navigation/app_router.dart';
import '../../../shared/providers/simple_profile_providers.dart';
import '../../../shared/theme/design_system.dart';
import '../../../shared/widgets/modern_card.dart';

// Provider for recent medical records based on selected profile
final recentMedicalRecordsProvider = FutureProvider<List<MedicalRecord>>((
  ref,
) async {
  final selectedProfile = await ref.watch(simpleSelectedProfileProvider.future);

  if (selectedProfile == null) {
    return <MedicalRecord>[];
  }

  try {
    final database = AppDatabase.instance;
    var query = database.select(database.medicalRecords)
      ..where(
        (record) =>
            record.profileId.equals(selectedProfile.id) &
            record.isActive.equals(true),
      )
      ..orderBy([
        (record) => drift.OrderingTerm(
          expression: record.recordDate,
          mode: drift.OrderingMode.desc,
        ),
      ])
      ..limit(5);

    return await query.get();
  } catch (e) {
    print('Error loading recent records: $e');
    return <MedicalRecord>[];
  }
});

class RecentActivityWidget extends ConsumerWidget {
  const RecentActivityWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedProfileAsync = ref.watch(simpleSelectedProfileProvider);

    return selectedProfileAsync.when(
      loading: () => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Recent Activity',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Loading profile...',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      error: (error, stack) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Recent Activity',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildEmptyActivityState(context),
            ],
          ),
        ),
      ),
      data: (selectedProfile) {
        // If no profile is selected, show empty state immediately
        if (selectedProfile == null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.history,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Recent Activity',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildEmptyActivityState(context),
                ],
              ),
            ),
          );
        }

        // Use the provider defined outside build method
        final recentRecordsAsync = ref.watch(recentMedicalRecordsProvider);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.history,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Recent Activity',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Full activity log - Coming with navigation integration',
                            ),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        minimumSize: const Size(0, 32),
                      ),
                      child: const Text(
                        'View All',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                recentRecordsAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Loading recent activity...',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  error: (error, stack) => _buildErrorState(context, error),
                  data: (records) => records.isEmpty
                      ? _buildEmptyActivityState(context)
                      : _buildActivityList(context, records),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error, size: 48),
          const SizedBox(height: 8),
          Text('Error loading activity', style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            error.toString(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyActivityState(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            color: theme.colorScheme.primary,
            size: 48,
          ),
          const SizedBox(height: 8),
          Text(
            'No recent activity',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your medical records and activities will appear here',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Add your first medical record to see activity here',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Record'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList(BuildContext context, List<MedicalRecord> records) {
    if (records.isEmpty) {
      return _buildEmptyActivityState(context);
    }

    return Column(
      children: records
          .map((record) => _buildActivityItem(context, record))
          .toList(),
    );
  }

  Widget _buildActivityItem(BuildContext context, MedicalRecord record) {
    final theme = Theme.of(context);
    final isRecent = record.createdAt.isAfter(
      DateTime.now().subtract(const Duration(hours: 24)),
    );

    // Get gradient for record type
    final recordGradient = HealthBoxDesignSystem.getRecordTypeGradient(record.recordType);

    return ModernCard(
      elevation: CardElevation.low,
      onTap: () => context.push('${AppRoutes.medicalRecordDetail}/${record.id}'),
      enableHoverEffect: true,
      hoverElevation: CardElevation.medium,
      enablePressEffect: true,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Activity Type Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: recordGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: HealthBoxDesignSystem.coloredShadow(
                recordGradient.colors.first,
                opacity: 0.3,
              ),
            ),
            child: Icon(
              _getRecordTypeIcon(record.recordType),
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Activity Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        record.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isRecent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          gradient: HealthBoxDesignSystem.successGradient,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: HealthBoxDesignSystem.coloredShadow(
                            HealthBoxDesignSystem.successGradient.colors.first,
                            opacity: 0.3,
                          ),
                        ),
                        child: Text(
                          'NEW',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      record.recordType,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getRecordTypeColor(record.recordType),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      ' • ',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      _formatActivityTime(record.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                if (record.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 2),
                  Text(
                    record.description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          // Arrow Icon
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
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

  String _formatActivityTime(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
