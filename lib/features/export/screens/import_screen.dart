import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../services/import_service.dart';

class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  final ImportService _importService = ImportService();

  // Form state
  String? _selectedFilePath;
  ImportFormat _selectedFormat = ImportFormat.json;
  ImportMode _selectedMode = ImportMode.merge;
  bool _createMissingProfiles = true;
  bool _updateExistingRecords = true;
  List<String> _allowedEntityTypes = [
    'profiles',
    'medicalRecords',
    'reminders',
    'tags',
    'attachments',
  ];

  // UI state
  bool _isValidating = false;
  bool _isImporting = false;
  double _importProgress = 0.0;
  String _importStatus = '';

  // Validation results
  ImportResult? _validationResult;
  bool _showValidationDetails = false;

  @override
  void initState() {
    super.initState();
    _setupImportService();
  }

  void _setupImportService() {
    _importService.onProgress = (progress, status) {
      if (mounted) {
        setState(() {
          _importProgress = progress;
          _importStatus = status;
        });
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Data'),
        actions: [
          if (_isValidating || _isImporting)
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isImporting) _buildProgressSection(),
            if (!_isImporting) ...[
              _buildFileSelectionSection(),
              const SizedBox(height: 24),
              if (_selectedFilePath != null) ...[
                _buildFormatSection(),
                const SizedBox(height: 24),
                _buildImportModeSection(),
                const SizedBox(height: 24),
                _buildOptionsSection(),
                const SizedBox(height: 24),
                _buildEntityTypesSection(),
                const SizedBox(height: 24),
                _buildValidationSection(),
                if (_validationResult != null) ...[
                  const SizedBox(height: 24),
                  _buildValidationResultsSection(),
                ],
                const SizedBox(height: 32),
                _buildImportButton(),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFileSelectionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select File',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_selectedFilePath != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.insert_drive_file, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getFileName(_selectedFilePath!),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            _selectedFilePath!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _selectedFilePath = null;
                          _validationResult = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _selectFile,
                icon: const Icon(Icons.file_open),
                label: Text(
                  _selectedFilePath == null
                      ? 'Choose File'
                      : 'Choose Different File',
                ),
              ),
            ),
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
              'Importing Data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: _importProgress),
            const SizedBox(height: 8),
            Text(_importStatus),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _cancelImport,
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
              'File Format',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SegmentedButton<ImportFormat>(
              segments: ImportFormat.values
                  .map((format) => ButtonSegment<ImportFormat>(
                        value: format,
                        label: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_getFormatDisplayName(format)),
                            Text(
                              _importService.getFormatDescription(format),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ))
                  .toList(),
              selected: {_selectedFormat},
              onSelectionChanged: (Set<ImportFormat> selection) {
                setState(() {
                  _selectedFormat = selection.first;
                  _validationResult = null; // Clear previous validation
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportModeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Import Mode',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SegmentedButton<ImportMode>(
              segments: ImportMode.values
                  .map((mode) => ButtonSegment<ImportMode>(
                        value: mode,
                        label: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_getModeDisplayName(mode)),
                            Text(
                              _getModeDescription(mode),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ))
                  .toList(),
              selected: {_selectedMode},
              onSelectionChanged: (Set<ImportMode> selection) {
                setState(() => _selectedMode = selection.first);
              },
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
              'Import Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Create Missing Profiles'),
              subtitle: const Text('Create new profiles if they don\'t exist'),
              value: _createMissingProfiles,
              onChanged: (value) {
                setState(() => _createMissingProfiles = value);
              },
            ),
            SwitchListTile(
              title: const Text('Update Existing Records'),
              subtitle: const Text('Update records that already exist'),
              value: _updateExistingRecords,
              onChanged: (value) {
                setState(() => _updateExistingRecords = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntityTypesSection() {
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
                    'Data Types to Import',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      final allTypes = [
                        'profiles',
                        'medicalRecords',
                        'reminders',
                        'tags',
                        'attachments',
                      ];
                      if (_allowedEntityTypes.length == allTypes.length) {
                        _allowedEntityTypes.clear();
                      } else {
                        _allowedEntityTypes = List.from(allTypes);
                      }
                    });
                  },
                  child: Text(
                    _allowedEntityTypes.length == 5
                        ? 'Deselect All'
                        : 'Select All',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final entityType in [
              'profiles',
              'medicalRecords',
              'reminders',
              'tags',
              'attachments',
            ])
              CheckboxListTile(
                title: Text(_getEntityTypeDisplayName(entityType)),
                subtitle: Text(_getEntityTypeDescription(entityType)),
                value: _allowedEntityTypes.contains(entityType),
                onChanged: (selected) {
                  setState(() {
                    if (selected == true) {
                      _allowedEntityTypes.add(entityType);
                    } else {
                      _allowedEntityTypes.remove(entityType);
                    }
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'File Validation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Validate the file before importing to check for errors and see what will be imported.',
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isValidating ? null : _validateFile,
                icon: _isValidating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(_isValidating ? 'Validating...' : 'Validate File'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationResultsSection() {
    if (_validationResult == null) return const SizedBox.shrink();

    final result = _validationResult!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  result.success ? Icons.check_circle : Icons.error,
                  color: result.success ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Validation Results',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(
                      () => _showValidationDetails = !_showValidationDetails,
                    );
                  },
                  child: Text(
                    _showValidationDetails ? 'Hide Details' : 'Show Details',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: result.success ? Colors.green[50] : Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: result.success ? Colors.green : Colors.red,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.success
                        ? 'File is valid and ready to import'
                        : 'File has validation errors',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: result.success
                          ? Colors.green[800]
                          : Colors.red[800],
                    ),
                  ),
                  if (result.error != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      result.error!,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ],
                ],
              ),
            ),

            // Validation issues summary
            if (result.validationIssues.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  if (result.hasErrors) ...[
                    Icon(Icons.error, color: Colors.red, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${result.validationIssues.where((i) => i.severity == ValidationSeverity.error).length} Errors',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (result.hasWarnings) ...[
                    Icon(Icons.warning, color: Colors.orange, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${result.validationIssues.where((i) => i.severity == ValidationSeverity.warning).length} Warnings',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),

              if (_showValidationDetails) ...[
                const SizedBox(height: 16),
                const Text(
                  'Issues Details:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: result.validationIssues
                          .map((issue) => _buildValidationIssueItem(issue))
                          .toList(),
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildValidationIssueItem(ValidationIssue issue) {
    Color color;
    IconData icon;

    switch (issue.severity) {
      case ValidationSeverity.error:
        color = Colors.red;
        icon = Icons.error;
        break;
      case ValidationSeverity.warning:
        color = Colors.orange;
        icon = Icons.warning;
        break;
      case ValidationSeverity.info:
        color = Colors.blue;
        icon = Icons.info;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(issue.message, style: TextStyle(color: color)),
                if (issue.field != null || issue.lineNumber != null)
                  Text(
                    '${issue.field != null ? 'Field: ${issue.field}' : ''}'
                    '${issue.field != null && issue.lineNumber != null ? ', ' : ''}'
                    '${issue.lineNumber != null ? 'Line: ${issue.lineNumber}' : ''}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportButton() {
    final bool canImport =
        !_isImporting &&
        _selectedFilePath != null &&
        _allowedEntityTypes.isNotEmpty &&
        (_validationResult?.success ?? false);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: canImport ? _performImport : null,
        icon: const Icon(Icons.upload),
        label: const Text('Import Data'),
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
      ),
    );
  }

  Future<void> _selectFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'csv', 'zip', 'hbbackup'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _selectedFilePath = file.path;
          _validationResult = null;

          // Auto-detect format based on file extension
          final extension = file.extension?.toLowerCase();
          switch (extension) {
            case 'json':
              _selectedFormat = ImportFormat.json;
              break;
            case 'csv':
              _selectedFormat = ImportFormat.csv;
              break;
            case 'zip':
              _selectedFormat = ImportFormat.zip;
              break;
            case 'hbbackup':
              _selectedFormat = ImportFormat.backup;
              break;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _validateFile() async {
    if (_selectedFilePath == null) return;

    setState(() {
      _isValidating = true;
      _validationResult = null;
    });

    try {
      final result = await _importService.validateFile(
        filePath: _selectedFilePath!,
        format: _selectedFormat,
      );

      if (mounted) {
        setState(() => _validationResult = result);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _validationResult = ImportResult(
            success: false,
            error: e.toString(),
            format: _selectedFormat.name,
          );
        });
      }
    } finally {
      if (mounted) setState(() => _isValidating = false);
    }
  }

  Future<void> _performImport() async {
    if (_selectedFilePath == null) return;

    setState(() {
      _isImporting = true;
      _importProgress = 0.0;
      _importStatus = 'Preparing import...';
    });

    try {
      final options = ImportOptions(
        format: _selectedFormat,
        mode: _selectedMode,
        createMissingProfiles: _createMissingProfiles,
        updateExistingRecords: _updateExistingRecords,
        allowedEntityTypes: _allowedEntityTypes,
      );

      final result = await _importService.importData(
        filePath: _selectedFilePath!,
        options: options,
      );

      if (mounted) {
        if (result.success) {
          _showImportSuccessDialog(result);
        } else {
          _showImportErrorDialog(result);
        }
      }
    } catch (e) {
      if (mounted) {
        _showImportErrorDialog(
          ImportResult(
            success: false,
            error: e.toString(),
            format: _selectedFormat.name,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
          _importProgress = 0.0;
          _importStatus = '';
        });
      }
    }
  }

  void _cancelImport() {
    // In a real implementation, you'd cancel the import operation
    setState(() {
      _isImporting = false;
      _importProgress = 0.0;
      _importStatus = '';
    });
  }

  void _showImportSuccessDialog(ImportResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Successful'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Successfully imported ${result.totalImported} items.'),
            if (result.totalSkipped > 0) ...[
              const SizedBox(height: 4),
              Text('Skipped ${result.totalSkipped} items.'),
            ],
            const SizedBox(height: 8),
            Text('Format: ${result.format.toUpperCase()}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop();
              context.pop(); // Go back to previous screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showImportErrorDialog(ImportResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Failed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Failed to import data:\n\n${result.error ?? 'Unknown error'}',
            ),
            if (result.totalErrors > 0) ...[
              const SizedBox(height: 8),
              Text('${result.totalErrors} errors occurred during import.'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _getFileName(String path) {
    return path.split('/').last.split('\\').last;
  }

  String _getFormatDisplayName(ImportFormat format) {
    switch (format) {
      case ImportFormat.json:
        return 'JSON';
      case ImportFormat.csv:
        return 'CSV';
      case ImportFormat.zip:
        return 'ZIP Archive';
      case ImportFormat.backup:
        return 'Health Box Backup';
    }
  }

  String _getModeDisplayName(ImportMode mode) {
    switch (mode) {
      case ImportMode.merge:
        return 'Merge';
      case ImportMode.replace:
        return 'Replace';
      case ImportMode.skipDuplicates:
        return 'Skip Duplicates';
    }
  }

  String _getModeDescription(ImportMode mode) {
    switch (mode) {
      case ImportMode.merge:
        return 'Update existing records and add new ones';
      case ImportMode.replace:
        return 'Replace existing records with imported data';
      case ImportMode.skipDuplicates:
        return 'Only import new records, skip existing ones';
    }
  }

  String _getEntityTypeDisplayName(String entityType) {
    switch (entityType) {
      case 'profiles':
        return 'Family Profiles';
      case 'medicalRecords':
        return 'Medical Records';
      case 'reminders':
        return 'Reminders';
      case 'tags':
        return 'Tags';
      case 'attachments':
        return 'Attachments';
      default:
        return entityType;
    }
  }

  String _getEntityTypeDescription(String entityType) {
    switch (entityType) {
      case 'profiles':
        return 'Family member information and profiles';
      case 'medicalRecords':
        return 'Medical records, prescriptions, lab reports, etc.';
      case 'reminders':
        return 'Medication and appointment reminders';
      case 'tags':
        return 'Tags for organizing medical records';
      case 'attachments':
        return 'File attachments and documents';
      default:
        return 'Import $entityType data';
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
