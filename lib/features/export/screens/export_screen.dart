import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/database/app_database.dart';
import '../../../data/repositories/profile_dao.dart';
import '../../../shared/theme/design_system.dart';
import '../../../shared/widgets/hb_app_bar.dart';
import '../../../shared/widgets/hb_card.dart';
import '../../../shared/widgets/hb_loading.dart';
import '../../../shared/widgets/hb_text_field.dart';
import '../../../shared/widgets/hb_button.dart';
import '../services/export_service.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  final ExportService _exportService = ExportService();

  // Form state
  ExportFormat _selectedFormat = ExportFormat.json;
  ExportScope _selectedScope = ExportScope.all;
  List<String> _selectedProfileIds = [];
  DateTime? _dateFrom;
  DateTime? _dateTo;
  bool _includeAttachments = true;
  bool _includeInactiveRecords = false;
  final TextEditingController _fileNameController = TextEditingController();

  // UI state
  bool _isLoading = false;
  bool _isExporting = false;
  double _exportProgress = 0.0;
  String _exportStatus = '';

  // Profile data
  List<FamilyMemberProfile> _profiles = [];

  @override
  void initState() {
    super.initState();
    _loadProfiles();
    _setupExportService();
  }

  void _setupExportService() {
    _exportService.onProgress = (progress, status) {
      if (mounted) {
        setState(() {
          _exportProgress = progress;
          _exportStatus = status;
        });
      }
    };
  }

  Future<void> _loadProfiles() async {
    setState(() => _isLoading = true);
    try {
      final database = AppDatabase.instance;
      final profileDao = ProfileDao(database);
      final profiles = await profileDao.getAllProfiles();
      setState(() {
        _profiles = profiles;
        _selectedProfileIds = profiles.map((p) => p.id).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profiles: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HBAppBar.gradient(
        title: 'Export Data',
        gradient: HealthBoxDesignSystem.medicalOrange,
        actions: [
          if (_isExporting)
            Padding(
              padding: EdgeInsets.all(AppSpacing.base),
              child: const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const HBLoading.circular()
          : SingleChildScrollView(
              padding: context.responsivePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isExporting) _buildProgressSection(),
                  if (!_isExporting) ...[
                    _buildFormatSection(),
                    SizedBox(height: AppSpacing.xl),
                    _buildScopeSection(),
                    SizedBox(height: AppSpacing.xl),
                    if (_selectedScope != ExportScope.all)
                      _buildProfileSelection(),
                    if (_selectedScope == ExportScope.medicalRecordsOnly ||
                        _selectedScope == ExportScope.remindersOnly) ...[
                      SizedBox(height: AppSpacing.xl),
                      _buildDateRangeSection(),
                    ],
                    SizedBox(height: AppSpacing.xl),
                    _buildOptionsSection(),
                    SizedBox(height: AppSpacing.xl),
                    _buildFileNameSection(),
                    SizedBox(height: AppSpacing.xxl),
                    _buildExportButton(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildProgressSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Exporting Data',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: AppTypography.fontWeightBold,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          LinearProgressIndicator(value: _exportProgress),
          SizedBox(height: AppSpacing.sm),
          Text(
            _exportStatus,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppSpacing.base),
          SizedBox(
            width: double.infinity,
            child: HBButton.outlined(
              text: 'Cancel',
              onPressed: _cancelExport,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Export Format',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: AppTypography.fontWeightBold,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          SegmentedButton<ExportFormat>(
            segments: ExportFormat.values
                .map((format) => ButtonSegment<ExportFormat>(
                      value: format,
                      label: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_getFormatDisplayName(format)),
                          Text(
                            _exportService.getFormatDescription(format),
                            style: context.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ))
                .toList(),
            selected: {_selectedFormat},
            onSelectionChanged: (Set<ExportFormat> selection) {
              setState(() => _selectedFormat = selection.first);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScopeSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Data to Export',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: AppTypography.fontWeightBold,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          SegmentedButton<ExportScope>(
            segments: ExportScope.values
                .map((scope) => ButtonSegment<ExportScope>(
                      value: scope,
                      label: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_getScopeDisplayName(scope)),
                          Text(
                            _getScopeDescription(scope),
                            style: context.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ))
                .toList(),
            selected: {_selectedScope},
            onSelectionChanged: (Set<ExportScope> selection) {
              setState(() => _selectedScope = selection.first);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSelection() {
    if (_profiles.isEmpty) {
      return HBCard.elevated(
        padding: EdgeInsets.all(AppSpacing.base),
        child: Text(
          'No profiles available',
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Select Profiles',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: AppTypography.fontWeightBold,
                  ),
                ),
              ),
              HBButton.text(
                text: _selectedProfileIds.length == _profiles.length
                    ? 'Deselect All'
                    : 'Select All',
                onPressed: () {
                  setState(() {
                    if (_selectedProfileIds.length == _profiles.length) {
                      _selectedProfileIds.clear();
                    } else {
                      _selectedProfileIds = _profiles
                          .map((p) => p.id)
                          .toList();
                    }
                  });
                },
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          for (final profile in _profiles)
            CheckboxListTile(
              title: Text('${profile.firstName} ${profile.lastName}'),
              subtitle: Text('Born: ${_formatDate(profile.dateOfBirth)}'),
              value: _selectedProfileIds.contains(profile.id),
              onChanged: (selected) {
                setState(() {
                  if (selected == true) {
                    _selectedProfileIds.add(profile.id);
                  } else {
                    _selectedProfileIds.remove(profile.id);
                  }
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Date Range (Optional)',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: AppTypography.fontWeightBold,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: ListTile(
                  title: const Text('From Date'),
                  subtitle: Text(
                    _dateFrom != null ? _formatDate(_dateFrom!) : 'Not set',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context, isFromDate: true),
                ),
              ),
              Expanded(
                child: ListTile(
                  title: const Text('To Date'),
                  subtitle: Text(
                    _dateTo != null ? _formatDate(_dateTo!) : 'Not set',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context, isFromDate: false),
                ),
              ),
            ],
          ),
          if (_dateFrom != null || _dateTo != null)
            HBButton.text(
              text: 'Clear Date Range',
              onPressed: () {
                setState(() {
                  _dateFrom = null;
                  _dateTo = null;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildOptionsSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Export Options',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: AppTypography.fontWeightBold,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          SwitchListTile(
            title: const Text('Include Attachments'),
            subtitle: const Text('Export file attachments with the data'),
            value: _includeAttachments,
            onChanged: (value) {
              setState(() => _includeAttachments = value);
            },
          ),
          SwitchListTile(
            title: const Text('Include Inactive Records'),
            subtitle: const Text('Export records marked as inactive'),
            value: _includeInactiveRecords,
            onChanged: (value) {
              setState(() => _includeInactiveRecords = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFileNameSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'File Name (Optional)',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: AppTypography.fontWeightBold,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          HBTextField.filled(
            controller: _fileNameController,
            label: 'Custom file name',
            hint: 'health_data_export_${DateTime.now().millisecondsSinceEpoch}',
            suffix: Text(
              '.${_exportService.getFormatExtension(_selectedFormat)}',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton() {
    final bool canExport =
        !_isExporting &&
        (_selectedScope == ExportScope.all || _selectedProfileIds.isNotEmpty);

    return HBButton.primary(
      text: 'Export Data',
      onPressed: canExport ? _performExport : null,
      icon: Icons.download,
      isExpanded: true,
    );
  }

  Future<void> _selectDate(
    BuildContext context, {
    required bool isFromDate,
  }) async {
    final initialDate = isFromDate ? _dateFrom : _dateTo;
    final firstDate = DateTime(2000);
    final lastDate = DateTime.now().add(const Duration(days: 365));

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (selectedDate != null) {
      setState(() {
        if (isFromDate) {
          _dateFrom = selectedDate;
          // If from date is after to date, clear to date
          if (_dateTo != null && selectedDate.isAfter(_dateTo!)) {
            _dateTo = null;
          }
        } else {
          _dateTo = selectedDate;
          // If to date is before from date, clear from date
          if (_dateFrom != null && selectedDate.isBefore(_dateFrom!)) {
            _dateFrom = null;
          }
        }
      });
    }
  }

  Future<void> _performExport() async {
    setState(() {
      _isExporting = true;
      _exportProgress = 0.0;
      _exportStatus = 'Preparing export...';
    });

    try {
      final options = ExportOptions(
        format: _selectedFormat,
        scope: _selectedScope,
        profileIds: _selectedScope != ExportScope.all
            ? _selectedProfileIds
            : null,
        dateFrom: _dateFrom,
        dateTo: _dateTo,
        includeAttachments: _includeAttachments,
        includeInactiveRecords: _includeInactiveRecords,
        customFileName: _fileNameController.text.trim().isEmpty
            ? null
            : _fileNameController.text.trim(),
      );

      final result = await _exportService.exportData(options);

      if (mounted) {
        if (result.success) {
          _showExportSuccessDialog(result);
        } else {
          _showExportErrorDialog(result.error ?? 'Unknown error occurred');
        }
      }
    } catch (e) {
      if (mounted) {
        _showExportErrorDialog(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
          _exportProgress = 0.0;
          _exportStatus = '';
        });
      }
    }
  }

  void _cancelExport() {
    // In a real implementation, you'd cancel the export operation
    setState(() {
      _isExporting = false;
      _exportProgress = 0.0;
      _exportStatus = '';
    });
  }

  void _showExportSuccessDialog(ExportResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Successful'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Exported ${result.itemCount} items successfully.'),
            SizedBox(height: AppSpacing.sm),
            Text('Format: ${result.format.toUpperCase()}'),
            if (result.filePath != null) ...[
              SizedBox(height: AppSpacing.sm),
              Text('Saved to: ${result.filePath}'),
            ],
          ],
        ),
        actions: [
          HBButton.text(text: 'OK', onPressed: () => context.pop()),
          if (result.filePath != null)
            HBButton.primary(
              text: 'Open',
              onPressed: () {
                context.pop();
                // In a real app, you'd open the file or share it
              },
            ),
        ],
      ),
    );
  }

  void _showExportErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Failed'),
        content: Text('Failed to export data:\n\n$error'),
        actions: [
          HBButton.text(text: 'OK', onPressed: () => context.pop()),
        ],
      ),
    );
  }

  String _getFormatDisplayName(ExportFormat format) {
    switch (format) {
      case ExportFormat.json:
        return 'JSON';
      case ExportFormat.csv:
        return 'CSV';
      case ExportFormat.pdf:
        return 'PDF';
      case ExportFormat.zip:
        return 'ZIP Archive';
      case ExportFormat.backup:
        return 'Health Box Backup';
    }
  }

  String _getScopeDisplayName(ExportScope scope) {
    switch (scope) {
      case ExportScope.all:
        return 'All Data';
      case ExportScope.profileOnly:
        return 'Profiles Only';
      case ExportScope.medicalRecordsOnly:
        return 'Medical Records Only';
      case ExportScope.remindersOnly:
        return 'Reminders Only';
      case ExportScope.attachmentsOnly:
        return 'Attachments Only';
    }
  }

  String _getScopeDescription(ExportScope scope) {
    switch (scope) {
      case ExportScope.all:
        return 'Export all profiles, medical records, reminders, and attachments';
      case ExportScope.profileOnly:
        return 'Export only family member profiles';
      case ExportScope.medicalRecordsOnly:
        return 'Export medical records for selected profiles';
      case ExportScope.remindersOnly:
        return 'Export reminders for selected profiles';
      case ExportScope.attachmentsOnly:
        return 'Export file attachments only';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }
}
