import 'package:flutter/material.dart';

import '../services/medication_interaction_service.dart';

/// Widget for displaying medication interaction warnings
class InteractionWarningWidget extends StatelessWidget {
  final List<MedicationInteractionWarning> warnings;
  final bool showAllWarnings;
  final VoidCallback? onViewAllTapped;
  final Function(MedicationInteractionWarning)? onWarningTapped;

  const InteractionWarningWidget({
    super.key,
    required this.warnings,
    this.showAllWarnings = false,
    this.onViewAllTapped,
    this.onWarningTapped,
  });

  @override
  Widget build(BuildContext context) {
    if (warnings.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final displayWarnings = showAllWarnings
        ? warnings
        : warnings.take(3).toList(); // Show max 3 warnings by default

    return Card(
      color: _getCardColor(theme),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 12),
            ...displayWarnings.map((warning) => _buildWarningItem(warning, theme)),
            if (!showAllWarnings && warnings.length > 3) ...[
              const SizedBox(height: 8),
              _buildViewAllButton(theme),
            ],
            const SizedBox(height: 12),
            _buildDisclaimerText(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final highestSeverity = warnings.map((w) => w.interaction.severity).reduce(
      (a, b) => a.index > b.index ? a : b,
    );

    return Row(
      children: [
        Icon(
          MedicationInteractionService.getSeverityIcon(highestSeverity),
          color: MedicationInteractionService.getSeverityColor(highestSeverity),
          size: 24,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Drug Interaction ${warnings.length == 1 ? 'Warning' : 'Warnings'} (${warnings.length})',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: MedicationInteractionService.getSeverityColor(highestSeverity),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWarningItem(
    MedicationInteractionWarning warning,
    ThemeData theme,
  ) {
    final severity = warning.interaction.severity;
    final color = MedicationInteractionService.getSeverityColor(severity);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => onWarningTapped?.call(warning),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      MedicationInteractionService.getSeverityLabel(severity),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${warning.primaryMedicationName} + ${warning.secondaryMedicationName}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                warning.interaction.description,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Recommendation: ${warning.interaction.recommendation}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewAllButton(ThemeData theme) {
    return Center(
      child: TextButton.icon(
        onPressed: onViewAllTapped,
        icon: const Icon(Icons.expand_more),
        label: Text('View ${warnings.length - 3} more warnings'),
      ),
    );
  }

  Widget _buildDisclaimerText(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Always consult your healthcare provider about potential drug interactions',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCardColor(ThemeData theme) {
    if (warnings.isEmpty) return theme.cardColor;

    final highestSeverity = warnings.map((w) => w.interaction.severity).reduce(
      (a, b) => a.index > b.index ? a : b,
    );

    switch (highestSeverity) {
      case InteractionSeverity.high:
        return const Color(0xFFFFEBEE); // Light red
      case InteractionSeverity.medium:
        return const Color(0xFFFFF3E0); // Light orange
      case InteractionSeverity.low:
        return const Color(0xFFFFFDE7); // Light yellow
    }
  }
}

/// Compact version of interaction warning for use in lists
class InteractionWarningBadge extends StatelessWidget {
  final List<MedicationInteractionWarning> warnings;
  final VoidCallback? onTapped;

  const InteractionWarningBadge({
    super.key,
    required this.warnings,
    this.onTapped,
  });

  @override
  Widget build(BuildContext context) {
    if (warnings.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final highestSeverity = warnings.map((w) => w.interaction.severity).reduce(
      (a, b) => a.index > b.index ? a : b,
    );
    final color = MedicationInteractionService.getSeverityColor(highestSeverity);

    return InkWell(
      onTap: onTapped,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              MedicationInteractionService.getSeverityIcon(highestSeverity),
              size: 16,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              '${warnings.length} interaction${warnings.length == 1 ? '' : 's'}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-screen dialog for viewing all interaction warnings
class InteractionWarningsDialog extends StatelessWidget {
  final List<MedicationInteractionWarning> warnings;
  final String? title;

  const InteractionWarningsDialog({
    super.key,
    required this.warnings,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text(title ?? 'Drug Interaction Warnings'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
        body: warnings.isEmpty
            ? _buildNoWarningsWidget(theme)
            : _buildWarningsList(theme),
      ),
    );
  }

  Widget _buildNoWarningsWidget(ThemeData theme) {
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
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Your medications appear to be safe to take together',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWarningsList(ThemeData theme) {
    // Group warnings by severity
    final highWarnings = warnings
        .where((w) => w.interaction.severity == InteractionSeverity.high)
        .toList();
    final mediumWarnings = warnings
        .where((w) => w.interaction.severity == InteractionSeverity.medium)
        .toList();
    final lowWarnings = warnings
        .where((w) => w.interaction.severity == InteractionSeverity.low)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (highWarnings.isNotEmpty) ...[
            _buildSeveritySection('High Risk Interactions', highWarnings, theme),
            const SizedBox(height: 24),
          ],
          if (mediumWarnings.isNotEmpty) ...[
            _buildSeveritySection('Moderate Risk Interactions', mediumWarnings, theme),
            const SizedBox(height: 24),
          ],
          if (lowWarnings.isNotEmpty) ...[
            _buildSeveritySection('Low Risk Interactions', lowWarnings, theme),
            const SizedBox(height: 24),
          ],
          _buildGeneralDisclaimer(theme),
        ],
      ),
    );
  }

  Widget _buildSeveritySection(
    String title,
    List<MedicationInteractionWarning> sectionWarnings,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title (${sectionWarnings.length})',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        InteractionWarningWidget(
          warnings: sectionWarnings,
          showAllWarnings: true,
        ),
      ],
    );
  }

  Widget _buildGeneralDisclaimer(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.medical_services,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Important Medical Disclaimer',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'This interaction checker is for informational purposes only and is not a substitute for professional medical advice. Always consult with your healthcare provider, pharmacist, or other qualified medical professional before making any changes to your medication regimen.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}