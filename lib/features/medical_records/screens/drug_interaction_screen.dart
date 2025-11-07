import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/design_system.dart';
import '../../../shared/widgets/hb_button.dart';
import '../../../shared/widgets/hb_text_field.dart';
import '../../../shared/widgets/hb_card.dart';
import '../services/medication_interaction_service.dart';
import '../widgets/interaction_warning_widget.dart';

/// Screen for checking drug interactions
class DrugInteractionScreen extends ConsumerStatefulWidget {
  final String? profileId;

  const DrugInteractionScreen({
    super.key,
    this.profileId,
  });

  @override
  ConsumerState<DrugInteractionScreen> createState() => _DrugInteractionScreenState();
}

class _DrugInteractionScreenState extends ConsumerState<DrugInteractionScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late MedicationInteractionService _interactionService;

  final _medicationController = TextEditingController();
  List<MedicationInteractionWarning> _currentWarnings = [];
  List<MedicationInteractionWarning> _newMedicationWarnings = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _interactionService = MedicationInteractionService();
    _loadCurrentInteractions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _medicationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Drug Interactions',
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
            gradient: HealthBoxDesignSystem.warningGradient,
            boxShadow: AppElevation.coloredShadow(
              HealthBoxDesignSystem.warningGradient.colors.first,
              opacity: 0.3,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showInteractionDatabaseInfo,
            icon: const Icon(Icons.info_outline, color: Colors.white),
            tooltip: 'About interaction database',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Current Medications', icon: Icon(Icons.medication)),
            Tab(text: 'Check New Drug', icon: Icon(Icons.search)),
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
                _buildCurrentMedicationsTab(),
                _buildCheckNewDrugTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentMedicationsTab() {
    if (_currentWarnings.isEmpty && !_isLoading) {
      return _buildNoInteractionsWidget();
    }

    return SingleChildScrollView(
      padding: context.responsivePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInteractionSummary(),
          SizedBox(height: AppSpacing.base),
          if (_currentWarnings.isNotEmpty)
            InteractionWarningWidget(
              warnings: _currentWarnings,
              showAllWarnings: true,
              onWarningTapped: _showWarningDetails,
            ),
        ],
      ),
    );
  }

  Widget _buildCheckNewDrugTab() {
    return SingleChildScrollView(
      padding: context.responsivePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildNewDrugChecker(),
          SizedBox(height: AppSpacing.xl),
          if (_newMedicationWarnings.isNotEmpty) ...[
            Text(
              'Potential Interactions',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: AppTypography.fontWeightBold,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            InteractionWarningWidget(
              warnings: _newMedicationWarnings,
              showAllWarnings: true,
              onWarningTapped: _showWarningDetails,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInteractionSummary() {
    final highCount = _currentWarnings
        .where((w) => w.interaction.severity == InteractionSeverity.high)
        .length;
    final mediumCount = _currentWarnings
        .where((w) => w.interaction.severity == InteractionSeverity.medium)
        .length;
    final lowCount = _currentWarnings
        .where((w) => w.interaction.severity == InteractionSeverity.low)
        .length;

    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Interaction Summary',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: AppTypography.fontWeightBold,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'High Risk',
                  highCount,
                  MedicationInteractionService.getSeverityColor(InteractionSeverity.high),
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Moderate',
                  mediumCount,
                  MedicationInteractionService.getSeverityColor(InteractionSeverity.medium),
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Low Risk',
                  lowCount,
                  MedicationInteractionService.getSeverityColor(InteractionSeverity.low),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          '$count',
          style: context.textTheme.headlineMedium?.copyWith(
            color: color,
            fontWeight: AppTypography.fontWeightBold,
          ),
        ),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildNewDrugChecker() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Check New Medication',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: AppTypography.fontWeightBold,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Enter a medication name to check for interactions with your current medications',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.filled(
            controller: _medicationController,
            label: 'Medication name',
            hint: 'e.g., Aspirin, Ibuprofen, Metformin',
            suffixIcon: Icons.search,
            onFieldSubmitted: (_) => _checkNewMedication(),
          ),
          SizedBox(height: AppSpacing.base),
          SizedBox(
            width: double.infinity,
            child: HBButton.primary(
              text: 'Check Interactions',
              onPressed: _checkNewMedication,
              icon: Icons.search,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoInteractionsWidget() {
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
              'No Interactions Found',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: AppTypography.fontWeightBold,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Your current medications appear to be safe to take together',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            HBButton.outlined(
              text: 'Check New Medication',
              onPressed: () => _tabController.animateTo(1),
              icon: Icons.search,
            ),
          ],
        ),
      ),
    );
  }

  // Action Methods

  Future<void> _loadCurrentInteractions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final warnings = await _interactionService.checkAllCurrentInteractions(
        profileId: widget.profileId,
      );

      if (mounted) {
        setState(() {
          _currentWarnings = warnings;
        });
      }
    } catch (e) {
      if (mounted) {
        // Handle error silently or show snackbar if needed
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkNewMedication() async {
    final medicationName = _medicationController.text.trim();
    if (medicationName.isEmpty) return;

    setState(() {
      _isLoading = true;
      _newMedicationWarnings = [];
    });

    try {
      final warnings = await _interactionService.checkInteractionsForNewMedication(
        newMedicationName: medicationName,
        profileId: widget.profileId,
      );

      if (mounted) {
        setState(() {
          _newMedicationWarnings = warnings;
        });

        if (warnings.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No interactions found for $medicationName'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking interactions: $e'),
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

  void _showWarningDetails(MedicationInteractionWarning warning) {
    showDialog<void>(
      context: context,
      builder: (context) => _InteractionDetailDialog(warning: warning),
    );
  }

  void _showInteractionDatabaseInfo() {
    final stats = _interactionService.getInteractionDatabaseStats();

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Interaction Database'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Coverage: ${stats.totalMedications} medications'),
            Text('Total interactions: ${stats.totalInteractions}'),
            SizedBox(height: AppSpacing.sm),
            Text('Severity breakdown:'),
            Text('• High risk: ${stats.highSeverityCount}'),
            Text('• Moderate risk: ${stats.mediumSeverityCount}'),
            Text('• Low risk: ${stats.lowSeverityCount}'),
            SizedBox(height: AppSpacing.base),
            Text(
              'This database contains basic interactions for common medications. Always consult healthcare providers for comprehensive drug interaction checking.',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Dialog showing detailed information about a specific interaction
class _InteractionDetailDialog extends StatelessWidget {
  final MedicationInteractionWarning warning;

  const _InteractionDetailDialog({
    required this.warning,
  });

  @override
  Widget build(BuildContext context) {
    final interaction = warning.interaction;
    final color = MedicationInteractionService.getSeverityColor(interaction.severity);

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            MedicationInteractionService.getSeverityIcon(interaction.severity),
            color: color,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Drug Interaction',
              style: context.textTheme.titleMedium?.copyWith(
                color: color,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Text(
              MedicationInteractionService.getSeverityLabel(interaction.severity),
              style: context.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: AppTypography.fontWeightBold,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.base),
          Text(
            'Medications:',
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: AppTypography.fontWeightBold,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text('• ${warning.primaryMedicationName}'),
          Text('• ${warning.secondaryMedicationName}'),
          SizedBox(height: AppSpacing.base),
          Text(
            'Description:',
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: AppTypography.fontWeightBold,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(interaction.description),
          SizedBox(height: AppSpacing.base),
          Text(
            'Recommendation:',
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: AppTypography.fontWeightBold,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            interaction.recommendation,
            style: context.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: AppTypography.fontWeightMedium,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            // TODO: Navigate to contact healthcare provider
          },
          child: const Text('Contact Provider'),
        ),
      ],
    );
  }
}
