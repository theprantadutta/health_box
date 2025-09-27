import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
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
          SnackBar(content: Text('Error loading batches: $e')),
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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
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
            SnackBar(content: Text('Deleted batch "${batch.name}"')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting batch: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Batches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateBatchDialog,
            tooltip: 'Create New Batch',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _batches.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.medical_services,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No Medication Batches',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Create batches to group medications by timing\n(e.g., "After Breakfast", "Before Dinner")',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _showCreateBatchDialog,
                        child: const Text('Create First Batch'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadBatches,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
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
}