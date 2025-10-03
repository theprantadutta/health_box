import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/design_system.dart';
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
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: HealthBoxDesignSystem.warningGradient,
            boxShadow: [
              BoxShadow(
                color: HealthBoxDesignSystem.warningGradient.colors.first.withValues(alpha: 0.3),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
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
            const SizedBox(height: 4),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInteractionSummary(),
          const SizedBox(height: 16),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildNewDrugChecker(),
          const SizedBox(height: 24),
          if (_newMedicationWarnings.isNotEmpty) ...[
            Text(
              'Potential Interactions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
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
    final theme = Theme.of(context);
    final highCount = _currentWarnings
        .where((w) => w.interaction.severity == InteractionSeverity.high)
        .length;
    final mediumCount = _currentWarnings
        .where((w) => w.interaction.severity == InteractionSeverity.medium)
        .length;
    final lowCount = _currentWarnings
        .where((w) => w.interaction.severity == InteractionSeverity.low)
        .length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Interaction Summary',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'High Risk',
                    highCount,
                    MedicationInteractionService.getSeverityColor(InteractionSeverity.high),
                    theme,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Moderate',
                    mediumCount,
                    MedicationInteractionService.getSeverityColor(InteractionSeverity.medium),
                    theme,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Low Risk',
                    lowCount,
                    MedicationInteractionService.getSeverityColor(InteractionSeverity.low),
                    theme,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    int count,
    Color color,
    ThemeData theme,
  ) {
    return Column(
      children: [
        Text(
          '$count',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildNewDrugChecker() {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Check New Medication',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter a medication name to check for interactions with your current medications',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _medicationController,
              decoration: InputDecoration(
                labelText: 'Medication name',
                hintText: 'e.g., Aspirin, Ibuprofen, Metformin',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: _checkNewMedication,
                  icon: const Icon(Icons.search),
                ),
              ),
              onSubmitted: (_) => _checkNewMedication(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _checkNewMedication,
                child: const Text('Check Interactions'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoInteractionsWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          Text(
            'No Interactions Found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Your current medications appear to be safe to take together',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => _tabController.animateTo(1),
            child: const Text('Check New Medication'),
          ),
        ],
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
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking interactions: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
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
            const SizedBox(height: 8),
            Text('Severity breakdown:'),
            Text('• High risk: ${stats.highSeverityCount}'),
            Text('• Moderate risk: ${stats.mediumSeverityCount}'),
            Text('• Low risk: ${stats.lowSeverityCount}'),
            const SizedBox(height: 16),
            Text(
              'This database contains basic interactions for common medications. Always consult healthcare providers for comprehensive drug interaction checking.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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
    final theme = Theme.of(context);
    final interaction = warning.interaction;
    final color = MedicationInteractionService.getSeverityColor(interaction.severity);

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            MedicationInteractionService.getSeverityIcon(interaction.severity),
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Drug Interaction',
              style: theme.textTheme.titleMedium?.copyWith(
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              MedicationInteractionService.getSeverityLabel(interaction.severity),
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Medications:',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text('• ${warning.primaryMedicationName}'),
          Text('• ${warning.secondaryMedicationName}'),
          const SizedBox(height: 16),
          Text(
            'Description:',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(interaction.description),
          const SizedBox(height: 16),
          Text(
            'Recommendation:',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            interaction.recommendation,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
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