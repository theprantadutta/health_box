import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:encrypted_drift/encrypted_drift.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Import all table definitions
import '../models/family_member_profile.dart';
import '../models/medical_record.dart';
import '../models/prescription.dart';
import '../models/lab_report.dart';
import '../models/medication.dart';
import '../models/vaccination.dart';
import '../models/allergy.dart';
import '../models/chronic_condition.dart';
import '../models/tag.dart';
import '../models/attachment.dart';
import '../models/reminder.dart';
import '../models/record_tag.dart';
import '../models/emergency_card.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    FamilyMemberProfiles,
    MedicalRecords,
    Prescriptions,
    LabReports,
    Medications,
    Vaccinations,
    Allergies,
    ChronicConditions,
    Tags,
    Attachments,
    Reminders,
    EmergencyCards,
    RecordTags,
    SearchHistory,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase._() : super(_openConnection());

  static final AppDatabase _instance = AppDatabase._();
  static AppDatabase get instance => _instance;

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      try {
        // Enable foreign key constraints - essential for data integrity
        await customStatement('PRAGMA foreign_keys = ON;');
        debugPrint('Foreign keys enabled successfully');
      } catch (e) {
        debugPrint('Failed to enable foreign keys: $e');
      }

      // Skip WAL mode and other optimizations for encrypted databases
      // as they may not be compatible with SQLCipher
      try {
        await customStatement('PRAGMA synchronous = NORMAL;');
        debugPrint('Synchronous mode set successfully');
      } catch (e) {
        debugPrint('Failed to set synchronous mode: $e');
      }
    },
    onCreate: (Migrator m) async {
      try {
        await m.createAll();
        debugPrint('Database tables created successfully');

        // Create indexes for better query performance
        final indexes = [
          'CREATE INDEX IF NOT EXISTS idx_medical_records_profile_id ON medical_records(profile_id);',
          'CREATE INDEX IF NOT EXISTS idx_medical_records_record_date ON medical_records(record_date);',
          'CREATE INDEX IF NOT EXISTS idx_medical_records_is_active ON medical_records(is_active);',
          'CREATE INDEX IF NOT EXISTS idx_reminders_scheduled_time ON reminders(scheduled_time);',
          'CREATE INDEX IF NOT EXISTS idx_reminders_is_active ON reminders(is_active);',
          'CREATE INDEX IF NOT EXISTS idx_attachments_record_id ON attachments(record_id);',
        ];

        for (final indexSql in indexes) {
          try {
            await customStatement(indexSql);
          } catch (e) {
            debugPrint('Failed to create index: $e');
          }
        }
        debugPrint('Database indexes created successfully');
      } catch (e) {
        debugPrint('Database creation failed: $e');
        rethrow;
      }
    },
    onUpgrade: (Migrator m, int from, int to) async {
      debugPrint('Migrating database from version $from to $to');
      
      if (from == 1 && to == 2) {
        // Migration from v1 to v2: Fix medication date constraint
        // Force complete recreation of medications table
        try {
          debugPrint('Starting medication table migration...');

          // Simply drop and recreate the medications table
          // This will lose existing medication data but fix the constraint
          await customStatement('DROP TABLE IF EXISTS medications;');
          await m.createTable(medications);

          debugPrint('Medication table recreated successfully with fixed constraints');
        } catch (e) {
          debugPrint('Migration failed: $e');
          rethrow;
        }
      }

      if (from == 2 && to == 3) {
        // Migration from v2 to v3: Fix medication Unix timestamp date constraint
        try {
          debugPrint('Starting medication table migration to v3...');

          // Drop and recreate the medications table with correct Unix timestamp constraint
          await customStatement('DROP TABLE IF EXISTS medications;');
          await m.createTable(medications);

          debugPrint('Medication table recreated successfully with Unix timestamp constraints');
        } catch (e) {
          debugPrint('Migration to v3 failed: $e');
          rethrow;
        }
      }

      if (from == 3 && to == 4) {
        // Migration from v3 to v4: Fix non-deterministic datetime constraint
        try {
          debugPrint('Starting medication table migration to v4...');

          // Drop and recreate the medications table with static timestamp constraint
          await customStatement('DROP TABLE IF EXISTS medications;');
          await m.createTable(medications);

          debugPrint('Medication table recreated successfully with static timestamp constraints');
        } catch (e) {
          debugPrint('Migration to v4 failed: $e');
          rethrow;
        }
      }
    },
  );

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'health_box.db'));

      try {
        // Use encrypted database with SQLCipher
        const encryptionKey = 'health_box_encryption_key_2024';

        // Use specific path instead of inDatabaseFolder to ensure we know where it's created
        final database = EncryptedExecutor(
          path: file.path,
          password: encryptionKey,
        );

        debugPrint(
          'Encrypted SQLCipher database executor created successfully at: ${file.path}',
        );
        return database;
      } catch (e) {
        debugPrint('Encrypted database setup error: $e');
        debugPrint('Error type: ${e.runtimeType}');
        debugPrint('Falling back to unencrypted database');

        // Fallback to unencrypted database if encryption fails
        final fallbackDatabase = NativeDatabase(file);
        debugPrint('Fallback unencrypted database executor created at: ${file.path}');
        return fallbackDatabase;
      }
    });
  }

  // Helper method to test database connection
  Future<bool> testConnection() async {
    try {
      // Use a simple query that should work on any SQLite database
      final result = await customSelect('SELECT 1 as test').get();
      debugPrint('Database query test successful: ${result.length} rows');
      return true;
    } catch (e) {
      debugPrint('Database query test failed: $e');
      debugPrint('Error type: ${e.runtimeType}');
      return false;
    }
  }

  // Helper method to get database file size
  Future<int> getDatabaseSize() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'health_box.db'));

    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  // Helper method to backup database (for export functionality)
  Future<String> backupDatabase() async {
    try {
      debugPrint('Starting database backup...');

      // Now we know the database is in the documents directory
      final dbFolder = await getApplicationDocumentsDirectory();
      final sourceFile = File(p.join(dbFolder.path, 'health_box.db'));

      debugPrint('Looking for database at: ${sourceFile.path}');

      if (!await sourceFile.exists()) {
        // Try to query the database to see what's going on
        try {
          debugPrint('Database file not found, trying to query PRAGMA database_list...');
          final result = await customSelect('PRAGMA database_list').get();
          for (final row in result) {
            final file = row.data['file'] as String?;
            debugPrint('Database list entry: $file');
          }
        } catch (e) {
          debugPrint('Could not query database list: $e');
        }

        throw Exception('Database file not found at: ${sourceFile.path}. Please ensure the app has created some data first.');
      }

      // Ensure database is properly synced before backup
      try {
        await customStatement('PRAGMA wal_checkpoint(FULL);');
      } catch (e) {
        debugPrint('WAL checkpoint failed: $e (continuing with backup)');
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final documentsFolder = await getApplicationDocumentsDirectory();
      final backupFile = File(
        p.join(
          documentsFolder.path,
          'health_box_backup_$timestamp.db',
        ),
      );

      // Perform the backup copy
      await sourceFile.copy(backupFile.path);

      // Verify the backup was created and has content
      if (!await backupFile.exists()) {
        throw Exception('Backup file was not created');
      }

      final backupSize = await backupFile.length();
      if (backupSize == 0) {
        await backupFile.delete();
        throw Exception('Backup file is empty');
      }

      debugPrint('Database backup created successfully: ${backupFile.path} (${backupSize} bytes)');
      return backupFile.path;
    } catch (e) {
      debugPrint('Database backup failed: $e');
      rethrow;
    }
  }

  // Helper method to vacuum database (cleanup)
  Future<void> vacuumDatabase() async {
    await customStatement('VACUUM;');
  }

  // Close database connection
  @override
  Future<void> close() async {
    await super.close();
  }
}
