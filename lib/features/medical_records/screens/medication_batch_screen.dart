import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../../../shared/theme/design_system.dart';
import '../../../shared/widgets/hb_app_bar.dart';
import '../../../shared/widgets/hb_button.dart';
import '../../../shared/widgets/hb_loading.dart';
import '../services/medication_batch_service.dart';
import '../widgets/batch_card_widget.dart';
import '../widgets/batch_form_widget.dart';

class MedicationBatchScreen extends ConsumerStatefulWidget {
  const MedicationBatchScreen({super.key});

  @override
  ConsumerState<MedicationBatchScreen> createState() => _MedicationBatchScreenState();
}

class _MedicationBatchScreenState extends ConsumerState<MedicationBatchScreen> {
  final MedicationBatchService _batchService = MedicationBatchService();
  List<MedicationBatche> _batches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBatches();
  }

  Future<void> _loadBatches() async {
    try {
      setState(() => _isLoading = true);
      final batches = await _batchService.getActiveBatches();
      setState(() {
        _batches = batches;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading batches: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _showCreateBatchDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const BatchFormDialog(),
    );

    if (result == true) {
      await _loadBatches();
    }
  }

  Future<void> _showEditBatchDialog(MedicationBatche batch) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => BatchFormDialog(batch: batch),
    );

    if (result == true) {
      await _loadBatches();
    }
  }

  Future<void> _deleteBatch(MedicationBatche batch) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Batch'),
        content: Text(
          'Are you sure you want to delete "${batch.name}"?\n\n'
          'Any medications in this batch will become unassigned.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _batchService.deleteBatch(batch.id);
        await _loadBatches();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Deleted batch "${batch.name}"'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting batch: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HBAppBar.gradient(
        title: 'Medication Batches',
        gradient: HealthBoxDesignSystem.medicationGradient,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _showCreateBatchDialog,
            tooltip: 'Create New Batch',
          ),
        ],
      ),
      body: _isLoading
          ? const HBLoading.circular()
          : _batches.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadBatches,
                  child: ListView.builder(
                    padding: context.responsivePadding,
                    itemCount: _batches.length,
                    itemBuilder: (context, index) {
                      final batch = _batches[index];
                      return BatchCardWidget(
                        batch: batch,
                        onEdit: () => _showEditBatchDialog(batch),
                        onDelete: () => _deleteBatch(batch),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: context.responsivePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_services,
              size: AppSizes.iconXl * 1.5,
              color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'No Medication Batches',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: AppTypography.fontWeightBold,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Create batches to group medications by timing\n(e.g., "After Breakfast", "Before Dinner")',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            HBButton.primary(
              text: 'Create First Batch',
              onPressed: _showCreateBatchDialog,
              icon: Icons.add,
            ),
          ],
        ),
      ),
    );
  }
}
