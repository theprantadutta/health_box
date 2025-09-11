import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:csv/csv.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:pdf/widgets.dart' as pw;

import '../../../data/database/app_database.dart';
import '../../../data/repositories/attachment_dao.dart';
import '../../../data/repositories/medical_record_dao.dart';
import '../../../data/repositories/profile_dao.dart';
import '../../../data/repositories/reminder_dao.dart';
import '../../../data/repositories/tag_dao.dart';

enum ExportFormat {
  json,
  csv,
  pdf,
  zip,
  backup,
}

enum ExportScope {
  all,
  profileOnly,
  medicalRecordsOnly,
  remindersOnly,
  attachmentsOnly,
}

class ExportResult {
  final bool success;
  final String? filePath;
  final String? error;
  final int itemCount;
  final String format;

  ExportResult({
    required this.success,
    this.filePath,
    this.error,
    this.itemCount = 0,
    required this.format,
  });
}

class ExportOptions {
  final ExportFormat format;
  final ExportScope scope;
  final List<String>? profileIds;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final bool includeAttachments;
  final bool includeInactiveRecords;
  final String? customFileName;
  final bool password;
  final String? passwordValue;

  ExportOptions({
    required this.format,
    this.scope = ExportScope.all,
    this.profileIds,
    this.dateFrom,
    this.dateTo,
    this.includeAttachments = true,
    this.includeInactiveRecords = false,
    this.customFileName,
    this.password = false,
    this.passwordValue,
  });
}

class ExportService {
  final AppDatabase _database;
  final Logger _logger = Logger();

  // DAOs
  late final ProfileDao _profileDao;
  late final MedicalRecordDao _medicalRecordDao;
  late final ReminderDao _reminderDao;
  late final TagDao _tagDao;
  late final AttachmentDao _attachmentDao;

  // Callbacks for progress tracking
  Function(double progress, String status)? onProgress;

  ExportService({AppDatabase? database})
      : _database = database ?? AppDatabase.instance {
    _initializeDAOs();
  }

  void _initializeDAOs() {
    _profileDao = ProfileDao(_database);
    _medicalRecordDao = MedicalRecordDao(_database);
    _reminderDao = ReminderDao(_database);
    _tagDao = TagDao(_database);
    _attachmentDao = AttachmentDao(_database);
  }

  Future<ExportResult> exportData(ExportOptions options) async {
    try {
      _updateProgress(0.0, 'Starting export...');

      switch (options.format) {
        case ExportFormat.json:
          return await _exportToJson(options);
        case ExportFormat.csv:
          return await _exportToCsv(options);
        case ExportFormat.pdf:
          return await _exportToPdf(options);
        case ExportFormat.zip:
          return await _exportToZip(options);
        case ExportFormat.backup:
          return await _exportToBackup(options);
      }
    } catch (e, stackTrace) {
      _logger.e('Export failed', error: e, stackTrace: stackTrace);
      return ExportResult(
        success: false,
        error: e.toString(),
        format: options.format.name,
      );
    }
  }

  Future<ExportResult> _exportToJson(ExportOptions options) async {
    _updateProgress(0.1, 'Collecting data...');

    final data = await _collectData(options);
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);

    _updateProgress(0.8, 'Writing file...');

    final file = await _createExportFile('json', options.customFileName);
    await file.writeAsString(jsonString);

    _updateProgress(1.0, 'Export complete');

    return ExportResult(
      success: true,
      filePath: file.path,
      itemCount: _countItems(data),
      format: 'json',
    );
  }

  Future<ExportResult> _exportToCsv(ExportOptions options) async {
    _updateProgress(0.1, 'Collecting data...');

    final data = await _collectData(options);
    final directory = await _getExportDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final baseFileName = options.customFileName ?? 'health_data_$timestamp';

    final files = <String>[];
    int totalItems = 0;

    _updateProgress(0.3, 'Converting to CSV...');

    // Export profiles
    if (data.containsKey('profiles')) {
      final profilesCsv = _convertToCSV(
        data['profiles'] as List<dynamic>,
        'profiles',
      );
      final profilesFile = File(p.join(directory.path, '${baseFileName}_profiles.csv'));
      await profilesFile.writeAsString(profilesCsv);
      files.add(profilesFile.path);
      totalItems += (data['profiles'] as List).length;
    }

    // Export medical records
    if (data.containsKey('medicalRecords')) {
      final recordsCsv = _convertToCSV(
        data['medicalRecords'] as List<dynamic>,
        'medicalRecords',
      );
      final recordsFile = File(p.join(directory.path, '${baseFileName}_medical_records.csv'));
      await recordsFile.writeAsString(recordsCsv);
      files.add(recordsFile.path);
      totalItems += (data['medicalRecords'] as List).length;
    }

    // Export reminders
    if (data.containsKey('reminders')) {
      final remindersCsv = _convertToCSV(
        data['reminders'] as List<dynamic>,
        'reminders',
      );
      final remindersFile = File(p.join(directory.path, '${baseFileName}_reminders.csv'));
      await remindersFile.writeAsString(remindersCsv);
      files.add(remindersFile.path);
      totalItems += (data['reminders'] as List).length;
    }

    _updateProgress(1.0, 'Export complete');

    return ExportResult(
      success: true,
      filePath: files.isNotEmpty ? files.first : null,
      itemCount: totalItems,
      format: 'csv',
    );
  }

  Future<ExportResult> _exportToPdf(ExportOptions options) async {
    _updateProgress(0.1, 'Collecting data...');

    final data = await _collectData(options);
    final pdf = pw.Document();

    _updateProgress(0.3, 'Generating PDF...');

    // Title page
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Health Box Medical Records Export',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Export Date: ${DateTime.now().toIso8601String().split('T')[0]}'),
            pw.SizedBox(height: 10),
            pw.Text('Export Scope: ${options.scope.name}'),
            pw.SizedBox(height: 10),
            pw.Text('Total Items: ${_countItems(data)}'),
            pw.Divider(),
          ],
        ),
      ),
    );

    // Add profiles section
    if (data.containsKey('profiles')) {
      _addProfilesToPdf(pdf, data['profiles'] as List<dynamic>);
    }

    // Add medical records section
    if (data.containsKey('medicalRecords')) {
      _addMedicalRecordsToPdf(pdf, data['medicalRecords'] as List<dynamic>);
    }

    // Add reminders section
    if (data.containsKey('reminders')) {
      _addRemindersToPdf(pdf, data['reminders'] as List<dynamic>);
    }

    _updateProgress(0.8, 'Writing PDF file...');

    final file = await _createExportFile('pdf', options.customFileName);
    await file.writeAsBytes(await pdf.save());

    _updateProgress(1.0, 'Export complete');

    return ExportResult(
      success: true,
      filePath: file.path,
      itemCount: _countItems(data),
      format: 'pdf',
    );
  }

  Future<ExportResult> _exportToZip(ExportOptions options) async {
    _updateProgress(0.1, 'Collecting data...');

    final data = await _collectData(options);
    final archive = Archive();

    _updateProgress(0.3, 'Creating archive...');

    // Add JSON data
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    final jsonBytes = utf8.encode(jsonString);
    archive.addFile(ArchiveFile('data.json', jsonBytes.length, jsonBytes));

    // Add CSV exports
    if (data.containsKey('profiles')) {
      final csv = _convertToCSV(data['profiles'] as List<dynamic>, 'profiles');
      final csvBytes = utf8.encode(csv);
      archive.addFile(ArchiveFile('profiles.csv', csvBytes.length, csvBytes));
    }

    if (data.containsKey('medicalRecords')) {
      final csv = _convertToCSV(data['medicalRecords'] as List<dynamic>, 'medicalRecords');
      final csvBytes = utf8.encode(csv);
      archive.addFile(ArchiveFile('medical_records.csv', csvBytes.length, csvBytes));
    }

    if (data.containsKey('reminders')) {
      final csv = _convertToCSV(data['reminders'] as List<dynamic>, 'reminders');
      final csvBytes = utf8.encode(csv);
      archive.addFile(ArchiveFile('reminders.csv', csvBytes.length, csvBytes));
    }

    _updateProgress(0.6, 'Adding attachments...');

    // Add attachments if requested
    if (options.includeAttachments && data.containsKey('attachments')) {
      await _addAttachmentsToArchive(archive, data['attachments'] as List<dynamic>);
    }

    _updateProgress(0.8, 'Compressing archive...');

    final zipData = ZipEncoder().encode(archive);

    final file = await _createExportFile('zip', options.customFileName);
    await file.writeAsBytes(zipData);

    _updateProgress(1.0, 'Export complete');

    return ExportResult(
      success: true,
      filePath: file.path,
      itemCount: _countItems(data),
      format: 'zip',
    );
  }

  Future<ExportResult> _exportToBackup(ExportOptions options) async {
    _updateProgress(0.1, 'Creating backup...');

    final data = await _collectData(options);
    final metadata = await _generateBackupMetadata(data);

    final backupData = {
      'version': '1.0.0',
      'timestamp': DateTime.now().toIso8601String(),
      'metadata': metadata,
      'data': data,
    };

    _updateProgress(0.8, 'Writing backup file...');

    final backupJson = const JsonEncoder.withIndent('  ').convert(backupData);
    final file = await _createExportFile('hbbackup', options.customFileName);
    await file.writeAsString(backupJson);

    _updateProgress(1.0, 'Backup complete');

    return ExportResult(
      success: true,
      filePath: file.path,
      itemCount: _countItems(data),
      format: 'backup',
    );
  }

  Future<Map<String, dynamic>> _collectData(ExportOptions options) async {
    final data = <String, dynamic>{};

    switch (options.scope) {
      case ExportScope.all:
        data['profiles'] = await _getProfilesData(options);
        data['medicalRecords'] = await _getMedicalRecordsData(options);
        data['reminders'] = await _getRemindersData(options);
        data['tags'] = await _getTagsData();
        if (options.includeAttachments) {
          data['attachments'] = await _getAttachmentsData(options);
        }
        break;

      case ExportScope.profileOnly:
        data['profiles'] = await _getProfilesData(options);
        break;

      case ExportScope.medicalRecordsOnly:
        data['medicalRecords'] = await _getMedicalRecordsData(options);
        if (options.includeAttachments) {
          data['attachments'] = await _getAttachmentsData(options);
        }
        break;

      case ExportScope.remindersOnly:
        data['reminders'] = await _getRemindersData(options);
        break;

      case ExportScope.attachmentsOnly:
        if (options.includeAttachments) {
          data['attachments'] = await _getAttachmentsData(options);
        }
        break;
    }

    return data;
  }

  Future<List<Map<String, dynamic>>> _getProfilesData(ExportOptions options) async {
    final profiles = await _profileDao.getAllProfiles();
    
    if (options.profileIds != null) {
      final filteredProfiles = profiles.where((p) => options.profileIds!.contains(p.id)).toList();
      return filteredProfiles.map((p) => p.toJson()).toList();
    }

    return profiles.map((p) => p.toJson()).toList();
  }

  Future<List<Map<String, dynamic>>> _getMedicalRecordsData(ExportOptions options) async {
    final records = await _medicalRecordDao.getAllRecords();
    final filteredRecords = records.where((record) {
      if (options.profileIds != null && !options.profileIds!.contains(record.profileId)) {
        return false;
      }

      if (!options.includeInactiveRecords && !record.isActive) {
        return false;
      }

      if (options.dateFrom != null && record.recordDate.isBefore(options.dateFrom!)) {
        return false;
      }

      if (options.dateTo != null && record.recordDate.isAfter(options.dateTo!)) {
        return false;
      }

      return true;
    }).toList();

    return filteredRecords.map((r) => r.toJson()).toList();
  }

  Future<List<Map<String, dynamic>>> _getRemindersData(ExportOptions options) async {
    final reminders = await _reminderDao.getAllReminders();
    final filteredReminders = reminders.where((reminder) {
      if (options.profileIds != null && reminder.recordId != null) {
        // For reminders, we need to check if the related record belongs to selected profiles
        // This is a simplified check - in a real implementation you'd join with medical records
        return true; // For now, include all reminders if any profiles are selected
      }

      if (options.dateFrom != null && reminder.scheduledTime.isBefore(options.dateFrom!)) {
        return false;
      }

      if (options.dateTo != null && reminder.scheduledTime.isAfter(options.dateTo!)) {
        return false;
      }

      return true;
    }).toList();

    return filteredReminders.map((r) => r.toJson()).toList();
  }

  Future<List<Map<String, dynamic>>> _getTagsData() async {
    final tags = await _tagDao.getAllTags();
    return tags.map((t) => t.toJson()).toList();
  }

  Future<List<Map<String, dynamic>>> _getAttachmentsData(ExportOptions options) async {
    final attachments = await _attachmentDao.getAllAttachments();
    return attachments.map((a) => a.toJson()).toList();
  }

  String _convertToCSV(List<dynamic> data, String entityType) {
    if (data.isEmpty) return '';

    final headers = _getCSVHeaders(entityType, data.first as Map<String, dynamic>);
    final rows = <List<dynamic>>[];
    rows.add(headers);

    for (final item in data) {
      final itemMap = item as Map<String, dynamic>;
      final row = headers.map((header) => itemMap[header] ?? '').toList();
      rows.add(row);
    }

    return const ListToCsvConverter().convert(rows);
  }

  List<String> _getCSVHeaders(String entityType, Map<String, dynamic> sample) {
    switch (entityType) {
      case 'profiles':
        return ['id', 'firstName', 'lastName', 'dateOfBirth', 'email', 'phone', 'createdAt'];
      case 'medicalRecords':
        return ['id', 'profileId', 'recordType', 'title', 'recordDate', 'isActive', 'createdAt'];
      case 'reminders':
        return ['id', 'profileId', 'title', 'description', 'scheduledTime', 'isActive'];
      default:
        return sample.keys.toList();
    }
  }

  void _addProfilesToPdf(pw.Document pdf, List<dynamic> profiles) {
    if (profiles.isEmpty) return;

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Family Profiles',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Divider(),
            for (final profile in profiles)
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 10),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '${profile['firstName']} ${profile['lastName']}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    if (profile['dateOfBirth'] != null)
                      pw.Text('DOB: ${profile['dateOfBirth']}'),
                    if (profile['email'] != null)
                      pw.Text('Email: ${profile['email']}'),
                    if (profile['phone'] != null)
                      pw.Text('Phone: ${profile['phone']}'),
                    pw.Divider(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _addMedicalRecordsToPdf(pw.Document pdf, List<dynamic> records) {
    if (records.isEmpty) return;

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Medical Records',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Divider(),
            for (final record in records.take(20)) // Limit for PDF space
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '${record['title']} (${record['recordType']})',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text('Date: ${record['recordDate']}'),
                    if (record['description'] != null)
                      pw.Text('Description: ${record['description']}'),
                    pw.Divider(),
                  ],
                ),
              ),
            if (records.length > 20)
              pw.Text('... and ${records.length - 20} more records'),
          ],
        ),
      ),
    );
  }

  void _addRemindersToPdf(pw.Document pdf, List<dynamic> reminders) {
    if (reminders.isEmpty) return;

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Reminders',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Divider(),
            for (final reminder in reminders.take(30)) // Limit for PDF space
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 6),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '${reminder['title']}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text('Scheduled: ${reminder['scheduledTime']}'),
                    if (reminder['description'] != null)
                      pw.Text('${reminder['description']}'),
                    pw.Divider(),
                  ],
                ),
              ),
            if (reminders.length > 30)
              pw.Text('... and ${reminders.length - 30} more reminders'),
          ],
        ),
      ),
    );
  }

  Future<void> _addAttachmentsToArchive(Archive archive, List<dynamic> attachments) async {
    for (final attachment in attachments) {
      final attachmentMap = attachment as Map<String, dynamic>;
      final filePath = attachmentMap['filePath'] as String?;

      if (filePath != null && filePath.isNotEmpty) {
        final file = File(filePath);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          final fileName = p.basename(filePath);
          archive.addFile(ArchiveFile('attachments/$fileName', bytes.length, bytes));
        }
      }
    }
  }

  Future<Map<String, dynamic>> _generateBackupMetadata(Map<String, dynamic> data) async {
    return {
      'exportedAt': DateTime.now().toIso8601String(),
      'version': '1.0.0',
      'appVersion': '1.0.0', // This should come from package info
      'deviceInfo': 'Flutter App', // This should come from device info
      'itemCounts': {
        'profiles': (data['profiles'] as List?)?.length ?? 0,
        'medicalRecords': (data['medicalRecords'] as List?)?.length ?? 0,
        'reminders': (data['reminders'] as List?)?.length ?? 0,
        'tags': (data['tags'] as List?)?.length ?? 0,
        'attachments': (data['attachments'] as List?)?.length ?? 0,
      },
    };
  }

  int _countItems(Map<String, dynamic> data) {
    int count = 0;
    for (final value in data.values) {
      if (value is List) {
        count += value.length;
      }
    }
    return count;
  }

  Future<File> _createExportFile(String extension, String? customFileName) async {
    final directory = await _getExportDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = customFileName ?? 'health_data_export_$timestamp';
    return File(p.join(directory.path, '$fileName.$extension'));
  }

  Future<Directory> _getExportDirectory() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final exportDir = Directory(p.join(documentsDir.path, 'exports'));
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    return exportDir;
  }

  void _updateProgress(double progress, String status) {
    onProgress?.call(progress, status);
  }

  List<ExportFormat> getSupportedFormats() {
    return ExportFormat.values;
  }

  String getFormatDescription(ExportFormat format) {
    switch (format) {
      case ExportFormat.json:
        return 'JSON format for developers and data processing';
      case ExportFormat.csv:
        return 'CSV files for spreadsheet applications';
      case ExportFormat.pdf:
        return 'PDF document for printing and viewing';
      case ExportFormat.zip:
        return 'ZIP archive with all data and attachments';
      case ExportFormat.backup:
        return 'Health Box backup file for importing later';
    }
  }

  String getFormatExtension(ExportFormat format) {
    switch (format) {
      case ExportFormat.json:
        return 'json';
      case ExportFormat.csv:
        return 'csv';
      case ExportFormat.pdf:
        return 'pdf';
      case ExportFormat.zip:
        return 'zip';
      case ExportFormat.backup:
        return 'hbbackup';
    }
  }
}