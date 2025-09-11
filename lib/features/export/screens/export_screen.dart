import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../../../data/repositories/profile_dao.dart';
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
            backgroundColor: Colors.red,
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
      appBar: AppBar(
        title: const Text('Export Data'),
        actions: [
          if (_isExporting)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isExporting) _buildProgressSection(),
                  if (!_isExporting) ...[
                    _buildFormatSection(),
                    const SizedBox(height: 24),
                    _buildScopeSection(),
                    const SizedBox(height: 24),
                    if (_selectedScope != ExportScope.all)
                      _buildProfileSelection(),
                    if (_selectedScope == ExportScope.medicalRecordsOnly ||
                        _selectedScope == ExportScope.remindersOnly) ...[
                      const SizedBox(height: 24),
                      _buildDateRangeSection(),
                    ],
                    const SizedBox(height: 24),
                    _buildOptionsSection(),
                    const SizedBox(height: 24),
                    _buildFileNameSection(),
                    const SizedBox(height: 32),
                    _buildExportButton(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildProgressSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Exporting Data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: _exportProgress),
            const SizedBox(height: 8),
            Text(_exportStatus),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _cancelExport,
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Export Format',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            for (final format in ExportFormat.values)
              RadioListTile<ExportFormat>(
                title: Text(_getFormatDisplayName(format)),
                subtitle: Text(_exportService.getFormatDescription(format)),
                value: format,
                groupValue: _selectedFormat,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedFormat = value);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScopeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data to Export',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            for (final scope in ExportScope.values)
              RadioListTile<ExportScope>(
                title: Text(_getScopeDisplayName(scope)),
                subtitle: Text(_getScopeDescription(scope)),
                value: scope,
                groupValue: _selectedScope,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedScope = value);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSelection() {
    if (_profiles.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No profiles available'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Select Profiles',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
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
                  child: Text(
                    _selectedProfileIds.length == _profiles.length
                        ? 'Deselect All'
                        : 'Select All',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final profile in _profiles)
              CheckboxListTile(
                title: Text('${profile.firstName} ${profile.lastName}'),
                subtitle: profile.dateOfBirth != null
                    ? Text('Born: ${_formatDate(profile.dateOfBirth)}')
                    : null,
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
      ),
    );
  }

  Widget _buildDateRangeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Date Range (Optional)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
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
              TextButton(
                onPressed: () {
                  setState(() {
                    _dateFrom = null;
                    _dateTo = null;
                  });
                },
                child: const Text('Clear Date Range'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Export Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
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
      ),
    );
  }

  Widget _buildFileNameSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'File Name (Optional)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _fileNameController,
              decoration: InputDecoration(
                labelText: 'Custom file name',
                hintText:
                    'health_data_export_${DateTime.now().millisecondsSinceEpoch}',
                suffixText:
                    '.${_exportService.getFormatExtension(_selectedFormat)}',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton() {
    final bool canExport =
        !_isExporting &&
        (_selectedScope == ExportScope.all || _selectedProfileIds.isNotEmpty);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: canExport ? _performExport : null,
        icon: const Icon(Icons.download),
        label: const Text('Export Data'),
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
      ),
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
            const SizedBox(height: 8),
            Text('Format: ${result.format.toUpperCase()}'),
            if (result.filePath != null) ...[
              const SizedBox(height: 8),
              Text('Saved to: ${result.filePath}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          if (result.filePath != null)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // In a real app, you'd open the file or share it
              },
              child: const Text('Open'),
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
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
