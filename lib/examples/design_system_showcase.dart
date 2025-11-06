import 'package:flutter/material.dart';
import '../shared/theme/design_system.dart';
import '../shared/widgets/gradient_button.dart';
import '../shared/widgets/gradient_chip.dart';
import '../shared/widgets/health_bottom_sheet.dart';
import '../shared/widgets/health_dialog.dart';
import '../shared/widgets/modern_card.dart';
import '../shared/widgets/modern_text_field.dart';

/// HealthBox Design System Showcase
///
/// This screen demonstrates all design system components and patterns.
/// Use this as a reference when building new screens or components.
///
/// To view: Navigate to /design-system-showcase in your app
class DesignSystemShowcase extends StatefulWidget {
  const DesignSystemShowcase({super.key});

  @override
  State<DesignSystemShowcase> createState() => _DesignSystemShowcaseState();
}

class _DesignSystemShowcaseState extends State<DesignSystemShowcase> {
  int _selectedTab = 0;
  final TextEditingController _textController = TextEditingController();
  bool _selectedChip1 = false;
  bool _selectedChip2 = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System Showcase'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Tabs
          _buildTabs(),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(HealthBoxDesignSystem.spacing4),
              child: _buildTabContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: HealthBoxDesignSystem.shadowSm,
      ),
      child: Row(
        children: [
          _buildTab('Colors', 0),
          _buildTab('Components', 1),
          _buildTab('Typography', 2),
          _buildTab('Dialogs', 3),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: HealthBoxDesignSystem.spacing3,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? HealthBoxDesignSystem.primaryBlue
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected
                  ? HealthBoxDesignSystem.fontWeightSemiBold
                  : HealthBoxDesignSystem.fontWeightNormal,
              color: isSelected
                  ? HealthBoxDesignSystem.primaryBlue
                  : HealthBoxDesignSystem.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildColorsTab();
      case 1:
        return _buildComponentsTab();
      case 2:
        return _buildTypographyTab();
      case 3:
        return _buildDialogsTab();
      default:
        return const SizedBox();
    }
  }

  // ============ COLORS TAB ============

  Widget _buildColorsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Primary Colors'),
        _buildColorRow([
          _buildColorSwatch(
            'Primary Blue',
            HealthBoxDesignSystem.primaryBlue,
          ),
          _buildColorSwatch(
            'Primary Light',
            HealthBoxDesignSystem.primaryBlueLight,
          ),
          _buildColorSwatch(
            'Primary Dark',
            HealthBoxDesignSystem.primaryBlueDark,
          ),
        ]),

        SizedBox(height: HealthBoxDesignSystem.spacing6),
        _buildSectionTitle('Accent Colors'),
        _buildColorRow([
          _buildColorSwatch('Purple', HealthBoxDesignSystem.accentPurple),
          _buildColorSwatch('Green', HealthBoxDesignSystem.accentGreen),
          _buildColorSwatch('Orange', HealthBoxDesignSystem.accentOrange),
        ]),
        SizedBox(height: HealthBoxDesignSystem.spacing3),
        _buildColorRow([
          _buildColorSwatch('Pink', HealthBoxDesignSystem.accentPink),
          _buildColorSwatch('Cyan', HealthBoxDesignSystem.accentCyan),
          const Spacer(),
        ]),

        SizedBox(height: HealthBoxDesignSystem.spacing6),
        _buildSectionTitle('Semantic Colors'),
        _buildColorRow([
          _buildColorSwatch('Success', HealthBoxDesignSystem.successColor),
          _buildColorSwatch('Warning', HealthBoxDesignSystem.warningColor),
          _buildColorSwatch('Error', HealthBoxDesignSystem.errorColor),
        ]),

        SizedBox(height: HealthBoxDesignSystem.spacing6),
        _buildSectionTitle('Medical Gradients'),
        _buildGradientCard(
          'Medication',
          HealthBoxDesignSystem.medicationGradient,
        ),
        _buildGradientCard(
          'Prescription',
          HealthBoxDesignSystem.prescriptionGradient,
        ),
        _buildGradientCard(
          'Lab Report',
          HealthBoxDesignSystem.labReportGradient,
        ),
        _buildGradientCard(
          'Vaccination',
          HealthBoxDesignSystem.vaccinationGradient,
        ),
        _buildGradientCard(
          'Allergy',
          HealthBoxDesignSystem.allergyGradient,
        ),
      ],
    );
  }

  Widget _buildColorRow(List<Widget> children) {
    return Row(
      children: children
          .map((child) => Expanded(child: child))
          .toList()
          .expand((widget) => [widget, const SizedBox(width: 8)])
          .toList()
        ..removeLast(),
    );
  }

  Widget _buildColorSwatch(String label, Color color) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 80,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(
              HealthBoxDesignSystem.radiusBase,
            ),
            boxShadow: HealthBoxDesignSystem.shadowSm,
          ),
        ),
        SizedBox(height: HealthBoxDesignSystem.spacing2),
        Text(
          label,
          style: TextStyle(
            fontSize: HealthBoxDesignSystem.textSizeXs,
            color: HealthBoxDesignSystem.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildGradientCard(String label, LinearGradient gradient) {
    return Container(
      margin: EdgeInsets.only(bottom: HealthBoxDesignSystem.spacing3),
      height: 60,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(HealthBoxDesignSystem.radiusBase),
        boxShadow: HealthBoxDesignSystem.coloredShadow(gradient.colors.first),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }

  // ============ COMPONENTS TAB ============

  Widget _buildComponentsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Buttons'),
        _buildButtonsSection(),

        SizedBox(height: HealthBoxDesignSystem.spacing6),
        _buildSectionTitle('Chips'),
        _buildChipsSection(),

        SizedBox(height: HealthBoxDesignSystem.spacing6),
        _buildSectionTitle('Text Fields'),
        _buildTextFieldsSection(),

        SizedBox(height: HealthBoxDesignSystem.spacing6),
        _buildSectionTitle('Cards'),
        _buildCardsSection(),
      ],
    );
  }

  Widget _buildButtonsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Primary buttons
        HealthButton(
          onPressed: () {},
          style: HealthButtonStyle.primary,
          child: const Text('Primary Button'),
        ),
        SizedBox(height: HealthBoxDesignSystem.spacing2),

        // Success button
        HealthButton(
          onPressed: () {},
          style: HealthButtonStyle.success,
          child: const Text('Success Button'),
        ),
        SizedBox(height: HealthBoxDesignSystem.spacing2),

        // Warning button
        HealthButton(
          onPressed: () {},
          style: HealthButtonStyle.warning,
          child: const Text('Warning Button'),
        ),
        SizedBox(height: HealthBoxDesignSystem.spacing2),

        // Error button
        HealthButton(
          onPressed: () {},
          style: HealthButtonStyle.error,
          child: const Text('Error Button'),
        ),
        SizedBox(height: HealthBoxDesignSystem.spacing3),

        // Button sizes
        Row(
          children: [
            Expanded(
              child: HealthButton(
                onPressed: () {},
                size: HealthButtonSize.small,
                child: const Text('Small'),
              ),
            ),
            SizedBox(width: HealthBoxDesignSystem.spacing2),
            Expanded(
              child: HealthButton(
                onPressed: () {},
                size: HealthButtonSize.medium,
                child: const Text('Medium'),
              ),
            ),
            SizedBox(width: HealthBoxDesignSystem.spacing2),
            Expanded(
              child: HealthButton(
                onPressed: () {},
                size: HealthButtonSize.large,
                child: const Text('Large'),
              ),
            ),
          ],
        ),
        SizedBox(height: HealthBoxDesignSystem.spacing3),

        // Loading button
        HealthButton(
          onPressed: () {},
          isLoading: true,
          child: const Text('Loading...'),
        ),
      ],
    );
  }

  Widget _buildChipsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Regular chips
        Wrap(
          spacing: HealthBoxDesignSystem.spacing2,
          runSpacing: HealthBoxDesignSystem.spacing2,
          children: [
            GradientChip(
              label: 'Medication',
              gradient: HealthBoxDesignSystem.medicationGradient,
              icon: Icons.medication,
            ),
            GradientChip(
              label: 'Prescription',
              gradient: HealthBoxDesignSystem.prescriptionGradient,
              icon: Icons.receipt,
            ),
            GradientChip(
              label: 'Lab Report',
              gradient: HealthBoxDesignSystem.labReportGradient,
              icon: Icons.science,
            ),
          ],
        ),
        SizedBox(height: HealthBoxDesignSystem.spacing3),

        // Filter chips
        Text(
          'Filter Chips',
          style: TextStyle(
            fontSize: HealthBoxDesignSystem.textSizeSm,
            fontWeight: HealthBoxDesignSystem.fontWeightMedium,
          ),
        ),
        SizedBox(height: HealthBoxDesignSystem.spacing2),
        Wrap(
          spacing: HealthBoxDesignSystem.spacing2,
          runSpacing: HealthBoxDesignSystem.spacing2,
          children: [
            GradientFilterChip(
              label: 'All Records',
              selected: _selectedChip1,
              onSelected: () => setState(() => _selectedChip1 = !_selectedChip1),
            ),
            GradientFilterChip(
              label: 'Recent',
              selected: _selectedChip2,
              onSelected: () => setState(() => _selectedChip2 = !_selectedChip2),
              selectedGradient: HealthBoxDesignSystem.successGradient,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextFieldsSection() {
    return Column(
      children: [
        ModernTextField(
          labelText: 'Medication Name',
          hintText: 'Enter medication name',
          controller: _textController,
          prefixIcon: const Icon(Icons.medication),
        ),
        SizedBox(height: HealthBoxDesignSystem.spacing3),
        ModernTextField(
          labelText: 'Notes',
          hintText: 'Add notes here',
          maxLines: 3,
          useGradientBorder: false,
        ),
      ],
    );
  }

  Widget _buildCardsSection() {
    return Column(
      children: [
        ModernCard(
          elevation: CardElevation.low,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Default Card',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: HealthBoxDesignSystem.fontWeightSemiBold,
                    ),
              ),
              SizedBox(height: HealthBoxDesignSystem.spacing2),
              Text(
                'This is a card with low elevation and default styling.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: HealthBoxDesignSystem.textSecondary,
                    ),
              ),
            ],
          ),
        ),
        SizedBox(height: HealthBoxDesignSystem.spacing3),
        ModernCard(
          medicalTheme: MedicalCardTheme.primary,
          useGradientShadow: true,
          onTap: () {},
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: HealthBoxDesignSystem.medicalBlue,
                  borderRadius: BorderRadius.circular(
                    HealthBoxDesignSystem.radiusBase,
                  ),
                ),
                child: const Icon(Icons.favorite, color: Colors.white),
              ),
              SizedBox(width: HealthBoxDesignSystem.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Interactive Card',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: HealthBoxDesignSystem.fontWeightSemiBold,
                          ),
                    ),
                    Text(
                      'Tap me!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: HealthBoxDesignSystem.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ],
    );
  }

  // ============ TYPOGRAPHY TAB ============

  Widget _buildTypographyTab() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Display Styles'),
        Text('Display Large', style: theme.textTheme.displayLarge),
        Text('Display Medium', style: theme.textTheme.displayMedium),
        Text('Display Small', style: theme.textTheme.displaySmall),
        SizedBox(height: HealthBoxDesignSystem.spacing6),

        _buildSectionTitle('Headline Styles'),
        Text('Headline Large', style: theme.textTheme.headlineLarge),
        Text('Headline Medium', style: theme.textTheme.headlineMedium),
        Text('Headline Small', style: theme.textTheme.headlineSmall),
        SizedBox(height: HealthBoxDesignSystem.spacing6),

        _buildSectionTitle('Title Styles'),
        Text('Title Large', style: theme.textTheme.titleLarge),
        Text('Title Medium', style: theme.textTheme.titleMedium),
        Text('Title Small', style: theme.textTheme.titleSmall),
        SizedBox(height: HealthBoxDesignSystem.spacing6),

        _buildSectionTitle('Body Styles'),
        Text('Body Large', style: theme.textTheme.bodyLarge),
        Text('Body Medium', style: theme.textTheme.bodyMedium),
        Text('Body Small', style: theme.textTheme.bodySmall),
        SizedBox(height: HealthBoxDesignSystem.spacing6),

        _buildSectionTitle('Label Styles'),
        Text('Label Large', style: theme.textTheme.labelLarge),
        Text('Label Medium', style: theme.textTheme.labelMedium),
        Text('Label Small', style: theme.textTheme.labelSmall),
      ],
    );
  }

  // ============ DIALOGS TAB ============

  Widget _buildDialogsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle('Dialogs'),
        HealthButton(
          onPressed: () => _showInfoDialog(),
          child: const Text('Show Info Dialog'),
        ),
        SizedBox(height: HealthBoxDesignSystem.spacing2),
        HealthButton(
          onPressed: () => _showConfirmationDialog(),
          style: HealthButtonStyle.warning,
          child: const Text('Show Confirmation Dialog'),
        ),
        SizedBox(height: HealthBoxDesignSystem.spacing2),
        HealthButton(
          onPressed: () => _showSuccessDialog(),
          style: HealthButtonStyle.success,
          child: const Text('Show Success Dialog'),
        ),
        SizedBox(height: HealthBoxDesignSystem.spacing2),
        HealthButton(
          onPressed: () => _showErrorDialog(),
          style: HealthButtonStyle.error,
          child: const Text('Show Error Dialog'),
        ),
        SizedBox(height: HealthBoxDesignSystem.spacing6),

        _buildSectionTitle('Bottom Sheets'),
        HealthButton(
          onPressed: () => _showConfirmationBottomSheet(),
          child: const Text('Show Confirmation Bottom Sheet'),
        ),
        SizedBox(height: HealthBoxDesignSystem.spacing2),
        HealthButton(
          onPressed: () => _showListSelectionBottomSheet(),
          child: const Text('Show List Selection'),
        ),
        SizedBox(height: HealthBoxDesignSystem.spacing2),
        HealthButton(
          onPressed: () => _showActionSheet(),
          child: const Text('Show Action Sheet'),
        ),
      ],
    );
  }

  // ============ HELPER METHODS ============

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: HealthBoxDesignSystem.spacing3,
        top: HealthBoxDesignSystem.spacing2,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: HealthBoxDesignSystem.fontWeightSemiBold,
            ),
      ),
    );
  }

  // ============ DIALOG HANDLERS ============

  void _showInfoDialog() {
    HealthDialog.showInfo(
      context: context,
      title: 'Information',
      message: 'This is an informational dialog using the HealthBox design system.',
      icon: Icons.info_outline,
    );
  }

  void _showConfirmationDialog() async {
    final result = await HealthDialog.showConfirmation(
      context: context,
      title: 'Delete Record',
      message: 'Are you sure you want to delete this medical record? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      isDangerous: true,
      icon: Icons.delete_outline,
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Record deleted')),
      );
    }
  }

  void _showSuccessDialog() {
    HealthDialog.showSuccess(
      context: context,
      title: 'Success!',
      message: 'Your medical record has been saved successfully.',
      autoDismissDuration: const Duration(seconds: 2),
    );
  }

  void _showErrorDialog() {
    HealthDialog.showError(
      context: context,
      title: 'Error',
      message: 'Failed to save the medical record. Please try again.',
    );
  }

  void _showConfirmationBottomSheet() async {
    final result = await HealthBottomSheet.showConfirmation(
      context: context,
      title: 'Archive Record',
      message: 'Do you want to archive this medical record?',
      confirmText: 'Archive',
      icon: Icons.archive_outlined,
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Record archived')),
      );
    }
  }

  void _showListSelectionBottomSheet() async {
    final result = await HealthBottomSheet.showListSelection<String>(
      context: context,
      title: 'Select Record Type',
      showSearch: true,
      items: [
        HealthBottomSheetItem(
          value: 'medication',
          label: 'Medication',
          icon: Icons.medication,
          gradient: HealthBoxDesignSystem.medicationGradient,
        ),
        HealthBottomSheetItem(
          value: 'prescription',
          label: 'Prescription',
          icon: Icons.receipt,
          gradient: HealthBoxDesignSystem.prescriptionGradient,
        ),
        HealthBottomSheetItem(
          value: 'lab_report',
          label: 'Lab Report',
          icon: Icons.science,
          gradient: HealthBoxDesignSystem.labReportGradient,
        ),
        HealthBottomSheetItem(
          value: 'vaccination',
          label: 'Vaccination',
          icon: Icons.vaccines,
          gradient: HealthBoxDesignSystem.vaccinationGradient,
        ),
      ],
    );

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected: $result')),
      );
    }
  }

  void _showActionSheet() async {
    final result = await HealthBottomSheet.showActionSheet<String>(
      context: context,
      title: 'Record Actions',
      subtitle: 'Choose an action for this record',
      actions: [
        const HealthActionSheetItem(
          value: 'edit',
          label: 'Edit Record',
          icon: Icons.edit,
        ),
        const HealthActionSheetItem(
          value: 'share',
          label: 'Share Record',
          icon: Icons.share,
        ),
        const HealthActionSheetItem(
          value: 'delete',
          label: 'Delete Record',
          icon: Icons.delete,
          isDangerous: true,
        ),
      ],
    );

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Action: $result')),
      );
    }
  }
}
