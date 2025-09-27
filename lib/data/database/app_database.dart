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
import '../models/medication_batch.dart';
import '../models/vaccination.dart';
import '../models/allergy.dart';
import '../models/chronic_condition.dart';
import '../models/surgical_record.dart';
import '../models/radiology_record.dart';
import '../models/pathology_record.dart';
import '../models/discharge_summary.dart';
import '../models/hospital_admission.dart';
import '../models/dental_record.dart';
import '../models/mental_health_record.dart';
import '../models/general_record.dart';
import '../models/tag.dart';
import '../models/attachment.dart';
import '../models/reminder.dart';
import '../models/record_tag.dart';
import '../models/emergency_card.dart';
import '../models/sync_preferences.dart';
import '../models/search_history.dart';
import '../models/medication_adherence.dart';
import '../models/notification_settings.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    FamilyMemberProfiles,
    MedicalRecords,
    Prescriptions,
    LabReports,
    Medications,
    MedicationBatches,
    Vaccinations,
    Allergies,
    ChronicConditions,
    SurgicalRecords,
    RadiologyRecords,
    PathologyRecords,
    DischargeSummaries,
    HospitalAdmissions,
    DentalRecords,
    MentalHealthRecords,
    GeneralRecords,
    Tags,
    Attachments,
    Reminders,
    EmergencyCards,
    RecordTags,
    SearchHistory,
    MedicationAdherence,
    NotificationSettings,
    SyncPreferences,
    UploadQueue,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase._() : super(_openConnection());

  static final AppDatabase _instance = AppDatabase._();
  static AppDatabase get instance => _instance;

  @override
  int get schemaVersion => 10;

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

      if (from == 4 && to == 5) {
        // Migration from v4 to v5: Add new medical record types
        try {
          debugPrint('Starting migration to v5 - adding new medical record types...');

          // Create all new tables
          await m.createTable(surgicalRecords);
          await m.createTable(radiologyRecords);
          await m.createTable(pathologyRecords);
          await m.createTable(dischargeSummaries);
          await m.createTable(hospitalAdmissions);
          await m.createTable(dentalRecords);
          await m.createTable(mentalHealthRecords);
          await m.createTable(generalRecords);
          await m.createTable(searchHistory);

          // Update the medical_records table constraint to include new record types
          // First, we need to backup existing data, drop table, recreate, and restore
          await customStatement('''
            CREATE TEMPORARY TABLE medical_records_backup AS
            SELECT * FROM medical_records;
          ''');

          await customStatement('DROP TABLE medical_records;');
          await m.createTable(medicalRecords);

          await customStatement('''
            INSERT INTO medical_records
            SELECT * FROM medical_records_backup;
          ''');

          await customStatement('DROP TABLE medical_records_backup;');

          debugPrint('Migration to v5 completed successfully');
        } catch (e) {
          debugPrint('Migration to v5 failed: $e');
          rethrow;
        }
      }

      if (from == 5 && to == 6) {
        // Migration from v5 to v6: Enhanced attachment model
        try {
          debugPrint('Starting migration to v6 - enhancing attachment model...');

          // Backup existing attachments data
          await customStatement('''
            CREATE TEMPORARY TABLE attachments_backup AS
            SELECT * FROM attachments;
          ''');

          // Drop and recreate attachments table with new fields
          await customStatement('DROP TABLE attachments;');
          await m.createTable(attachments);

          // Restore existing data with default values for new fields
          await customStatement('''
            INSERT INTO attachments (
              id, record_id, file_name, file_path, file_type, mime_type,
              file_size, description, created_at, updated_at, is_active, is_synced,
              thumbnail_path, sort_order, is_confidential
            )
            SELECT
              id, record_id, file_name, file_path, file_type, mime_type,
              file_size, description, created_at, updated_at, is_active, is_synced,
              NULL, 0, 0
            FROM attachments_backup;
          ''');

          await customStatement('DROP TABLE attachments_backup;');

          debugPrint('Migration to v6 completed successfully');
        } catch (e) {
          debugPrint('Migration to v6 failed: $e');
          rethrow;
        }
      }

      if (from == 6 && to == 7) {
        // Migration from v6 to v7: Enhanced prescription model for appointments
        try {
          debugPrint('Starting migration to v7 - enhancing prescription model for appointments...');

          // Backup existing prescriptions data
          await customStatement('''
            CREATE TEMPORARY TABLE prescriptions_backup AS
            SELECT * FROM prescriptions;
          ''');

          // Drop and recreate prescriptions table with new fields
          await customStatement('DROP TABLE prescriptions;');
          await m.createTable(prescriptions);

          // Restore existing data with default values for new fields
          await customStatement('''
            INSERT INTO prescriptions (
              id, profile_id, record_type, title, description, record_date,
              created_at, updated_at, is_active, prescription_type,
              medication_name, dosage, frequency, instructions, prescribing_doctor,
              pharmacy, start_date, end_date, refills_remaining, is_prescription_active,
              appointment_date, appointment_time, doctor_name, specialty, clinic_name,
              clinic_address, appointment_type, reason_for_visit, appointment_status,
              appointment_notes, reminder_set, reminder_minutes
            )
            SELECT
              id, profile_id, record_type, title, description, record_date,
              created_at, updated_at, is_active, 'prescription',
              medication_name, dosage, frequency, instructions, prescribing_doctor,
              pharmacy, start_date, end_date, refills_remaining, is_prescription_active,
              NULL, NULL, NULL, NULL, NULL,
              NULL, NULL, NULL, NULL,
              NULL, 0, NULL
            FROM prescriptions_backup;
          ''');

          await customStatement('DROP TABLE prescriptions_backup;');

          debugPrint('Migration to v7 completed successfully');
        } catch (e) {
          debugPrint('Migration to v7 failed: $e');
          rethrow;
        }
      }

      if (from == 7 && to == 8) {
        // Migration from v7 to v8: Add medication adherence tracking
        try {
          debugPrint('Starting migration to v8 - adding medication adherence tracking...');

          // Create medication adherence table
          await m.createTable(medicationAdherence);

          // Add indexes for better performance
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_medication_adherence_reminder_id ON medication_adherence(reminder_id);'
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_medication_adherence_medication_id ON medication_adherence(medication_id);'
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_medication_adherence_profile_id ON medication_adherence(profile_id);'
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_medication_adherence_scheduled_time ON medication_adherence(scheduled_time);'
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_medication_adherence_status ON medication_adherence(status);'
          );

          debugPrint('Migration to v8 completed successfully');
        } catch (e) {
          debugPrint('Migration to v8 failed: $e');
          rethrow;
        }
      }

      if (from == 8 && to == 9) {
        // Migration from v8 to v9: Add notification settings table
        try {
          debugPrint('Starting migration to v9 - adding notification settings...');

          // Create notification settings table
          await m.createTable(notificationSettings);

          // Add indexes for better performance
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_notification_settings_profile_id ON notification_settings(profile_id);'
          );

          debugPrint('Migration to v9 completed successfully');
        } catch (e) {
          debugPrint('Migration to v9 failed: $e');
          rethrow;
        }
      }

      if (from == 9 && to == 10) {
        // Migration from v9 to v10: Add medication batches system
        try {
          debugPrint('Starting migration to v10 - adding medication batches...');

          // Create medication batches table
          await m.createTable(medicationBatches);

          // Add batch_id column to medications table
          await customStatement('ALTER TABLE medications ADD COLUMN batch_id TEXT;');

          // Add foreign key constraint (will be enforced in new inserts/updates)
          // Note: SQLite doesn't support adding FK constraints to existing tables,
          // but we have the constraint defined in the table schema for new operations

          // Add indexes for better performance
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_medication_batches_timing_type ON medication_batches(timing_type);'
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_medication_batches_is_active ON medication_batches(is_active);'
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_medications_batch_id ON medications(batch_id);'
          );

          debugPrint('Migration to v10 completed successfully');
        } catch (e) {
          debugPrint('Migration to v10 failed: $e');
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
