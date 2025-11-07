import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/design_system.dart';
import '../../../shared/widgets/hb_button.dart';
import '../../../shared/widgets/hb_text_field.dart';
import '../../../shared/widgets/hb_loading.dart';
import '../services/refill_reminder_service.dart';
import '../widgets/refill_info_card_widget.dart';

/// Screen for managing medication refill reminders
class RefillRemindersScreen extends ConsumerStatefulWidget {
  final String? profileId;

  const RefillRemindersScreen({
    super.key,
    this.profileId,
  });

  @override
  ConsumerState<RefillRemindersScreen> createState() => _RefillRemindersScreenState();
}

class _RefillRemindersScreenState extends ConsumerState<RefillRemindersScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late RefillReminderService _refillService;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _refillService = RefillReminderService();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Medication Refills',
          style: TextStyle(
            color: Colors.white,
            fontWeight: AppTypography.fontWeightBold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: HealthBoxDesignSystem.medicationGradient,
            boxShadow: AppElevation.coloredShadow(
              HealthBoxDesignSystem.medicationGradient.colors.first,
              opacity: 0.3,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _scheduleAllRefillReminders,
            icon: const Icon(Icons.schedule, color: Colors.white),
            tooltip: 'Schedule all refill reminders',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: _onMenuSelected,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('Refresh'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Refill Settings'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Urgent', icon: Icon(Icons.warning)),
            Tab(text: 'All Medications', icon: Icon(Icons.medication)),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_isLoading)
            const LinearProgressIndicator()
          else
            SizedBox(height: AppSpacing.xs),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUrgentTab(),
                _buildAllMedicationsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddRefillDialog,
        icon: const Icon(Icons.add),
        label: const Text('Record Refill'),
      ),
    );
  }

  Widget _buildUrgentTab() {
    return FutureBuilder<List<MedicationRefillInfo>>(
      future: _refillService.getLowInventoryMedications(
        profileId: widget.profileId,
        thresholdDays: 7,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const HBLoading.circular();
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        }

        final urgentMedications = snapshot.data ?? [];

        if (urgentMedications.isEmpty) {
          return _buildNoUrgentRefillsWidget();
        }

        return _buildRefillList(urgentMedications, showUrgencyOnly: true);
      },
    );
  }

  Widget _buildAllMedicationsTab() {
    return FutureBuilder<List<MedicationRefillInfo>>(
      future: _refillService.getAllMedicationRefillInfo(
        profileId: widget.profileId,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const HBLoading.circular();
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        }

        final allMedications = snapshot.data ?? [];

        if (allMedications.isEmpty) {
          return _buildNoMedicationsWidget();
        }

        return _buildRefillList(allMedications);
      },
    );
  }

  Widget _buildRefillList(
    List<MedicationRefillInfo> medications, {
    bool showUrgencyOnly = false,
  }) {
    // Filter medications if only showing urgent ones
    final filteredMedications = showUrgencyOnly
        ? medications
            .where((med) => _refillService.needsImmediateAttention(med))
            .toList()
        : medications;

    return ListView.builder(
      padding: context.responsivePadding,
      itemCount: filteredMedications.length,
      itemBuilder: (context, index) {
        final refillInfo = filteredMedications[index];
        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.md),
          child: RefillInfoCardWidget(
            refillInfo: refillInfo,
            onRefillTapped: () => _showRefillDialog(refillInfo),
            onViewMedication: () => _viewMedicationDetails(refillInfo.medication.id),
            onUpdatePillCount: () => _showUpdatePillCountDialog(refillInfo),
          ),
        );
      },
    );
  }

  Widget _buildNoUrgentRefillsWidget() {
    return Center(
      child: Padding(
        padding: context.responsivePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: AppSizes.iconXl * 1.5,
              color: AppColors.success,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'All Set!',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: AppTypography.fontWeightBold,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'No medications need immediate refills',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            HBButton.outlined(
              text: 'View All Medications',
              onPressed: () => _tabController.animateTo(1),
              icon: Icons.medication,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoMedicationsWidget() {
    return Center(
      child: Padding(
        padding: context.responsivePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medication,
              size: AppSizes.iconXl * 1.5,
              color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'No Medications Found',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: AppTypography.fontWeightBold,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Add medications with pill counts to track refills',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            HBButton.primary(
              text: 'Add Medication',
              onPressed: _navigateToAddMedication,
              icon: Icons.add,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: context.responsivePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: AppSizes.iconXl * 1.5,
              color: AppColors.error,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Error Loading Refills',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: AppTypography.fontWeightBold,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              error,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.lg),
            HBButton.primary(
              text: 'Retry',
              onPressed: () => setState(() {}),
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }

  // Action Methods

  Future<void> _scheduleAllRefillReminders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final scheduledCount = await _refillService.scheduleAllRefillReminders(
        profileId: widget.profileId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scheduled $scheduledCount refill reminders'),
            backgroundColor: AppColors.success,
          ),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to schedule reminders: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showRefillDialog(MedicationRefillInfo refillInfo) async {
    await showDialog<void>(
      context: context,
      builder: (context) => _RefillDialog(
        refillInfo: refillInfo,
        refillService: _refillService,
        onRefillRecorded: () {
          setState(() {}); // Refresh the lists
        },
      ),
    );
  }

  Future<void> _showUpdatePillCountDialog(MedicationRefillInfo refillInfo) async {
    final controller = TextEditingController(
      text: refillInfo.currentPillCount.toString(),
    );

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Pill Count'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              refillInfo.medicationName,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: AppTypography.fontWeightBold,
              ),
            ),
            SizedBox(height: AppSpacing.base),
            HBTextField.number(
              controller: controller,
              label: 'Current pill count',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final newCount = int.tryParse(controller.text);
              if (newCount != null && newCount >= 0) {
                Navigator.pop(context);
                await _updatePillCount(refillInfo.medication.id, newCount);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );

    controller.dispose();
  }

  Future<void> _showAddRefillDialog() async {
    // TODO: Show dialog to select medication and record refill
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add refill dialog coming soon'),
      ),
    );
  }

  Future<void> _updatePillCount(String medicationId, int newCount) async {
    try {
      await _refillService.updatePillCountWithRefillReschedule(
        medicationId: medicationId,
        newPillCount: newCount,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Pill count updated and refill reminder rescheduled'),
            backgroundColor: AppColors.success,
          ),
        );
        setState(() {}); // Refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update pill count: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _onMenuSelected(String value) {
    switch (value) {
      case 'refresh':
        setState(() {}); // Refresh the data
        break;
      case 'settings':
        _navigateToRefillSettings();
        break;
    }
  }

  void _viewMedicationDetails(String medicationId) {
    // TODO: Navigate to medication details screen
  }

  void _navigateToAddMedication() {
    // TODO: Navigate to add medication screen
  }

  void _navigateToRefillSettings() {
    // TODO: Navigate to refill settings screen
  }
}

/// Dialog for recording medication refills
class _RefillDialog extends StatefulWidget {
  final MedicationRefillInfo refillInfo;
  final RefillReminderService refillService;
  final VoidCallback onRefillRecorded;

  const _RefillDialog({
    required this.refillInfo,
    required this.refillService,
    required this.onRefillRecorded,
  });

  @override
  State<_RefillDialog> createState() => _RefillDialogState();
}

class _RefillDialogState extends State<_RefillDialog> {
  final _refillAmountController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _refillDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _refillAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Record Medication Refill'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.refillInfo.medicationName,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: AppTypography.fontWeightBold,
              ),
            ),
            Text(
              'Current count: ${widget.refillInfo.currentPillCount} pills',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppSpacing.base),
            HBTextField.number(
              controller: _refillAmountController,
              label: 'Refill amount',
              hint: 'Number of pills added',
            ),
            SizedBox(height: AppSpacing.base),
            ListTile(
              title: const Text('Refill date'),
              subtitle: Text('${_refillDate.day}/${_refillDate.month}/${_refillDate.year}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectRefillDate,
              contentPadding: EdgeInsets.zero,
            ),
            SizedBox(height: AppSpacing.base),
            HBTextField.multiline(
              controller: _notesController,
              label: 'Notes (optional)',
              hint: 'Pharmacy, prescription number, etc.',
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _recordRefill,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Record Refill'),
        ),
      ],
    );
  }

  Future<void> _selectRefillDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _refillDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _refillDate = picked;
      });
    }
  }

  Future<void> _recordRefill() async {
    final refillAmount = int.tryParse(_refillAmountController.text);
    if (refillAmount == null || refillAmount <= 0) {
      _showError('Please enter a valid refill amount');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.refillService.recordMedicationRefill(
        medicationId: widget.refillInfo.medication.id,
        refillAmount: refillAmount,
        refillDate: _refillDate,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onRefillRecorded();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Refill recorded: +$refillAmount pills'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to record refill: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }
}
